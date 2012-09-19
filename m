From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next v1] net: use a per task frag allocator
Date: Wed, 19 Sep 2012 18:56:01 +0200
Message-ID: <1348073761.26523.1095.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

We currently use a per socket page reserve for tcp_sendmsg() operations.

This page is used to build fragments for skbs.

Its done to increase probability of coalescing small write() into
single segments in skbs still in write queue (not yet sent)

But it wastes a lot of memory for applications handling many mostly
idle sockets, since each socket holds one page in sk->sk_sndmsg_page

Its also quite inefficient to build TSO packets of 64KB, because we need
about 16 pages per skb on arches where PAGE_SIZE = 4096, so we hit
page allocator more than wanted.

This patch switches this frag allocator from socket to task structure,
and uses bigger pages.

(up to 32768 bytes per frag, thats order-3 pages on x86)

This increases TCP stream performance by 20% on loopback device,
but also benefits on other network devices, since 8x less frags are
mapped on transmit and unmapped on tx completion.

Its possible some TSO enabled hardware cant cope with bigger fragments,
but their ndo_start_xmit() should already handle this, splitting a
fragment in sub fragments, since some arches have PAGE_SIZE=65536

Successfully tested on various ethernet devices.
(ixgbe, igb, bnx2x, tg3, mellanox mlx4)

Followup patches can use this infrastructure in two other spots
and get rid of the socket sk_sndmsg_page.

Open for discussion : Should we fallback to smaller pages
if order-3 page allocations fail ?

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/sched.h |    6 ++++++
 include/net/sock.h    |   12 +++++++++---
 kernel/exit.c         |    3 +++
 kernel/fork.c         |    1 +
 net/ipv4/tcp.c        |   34 +++++++++++++++++-----------------
 net/ipv4/tcp_ipv4.c   |    4 +---
 6 files changed, 37 insertions(+), 23 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index b8c8664..ad61100 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1530,6 +1530,12 @@ struct task_struct {
 	 * cache last used pipe for splice
 	 */
 	struct pipe_inode_info *splice_pipe;
+	/*
+	 * cache for page frag allocator
+	 */
+	struct page *sndmsg_page;
+	unsigned int sndmsg_off;
+
 #ifdef	CONFIG_TASK_DELAY_ACCT
 	struct task_delay_info *delays;
 #endif
diff --git a/include/net/sock.h b/include/net/sock.h
index 181b711..431122c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -247,8 +247,8 @@ struct cg_proto;
   *	@sk_stamp: time stamp of last packet received
   *	@sk_socket: Identd and reporting IO signals
   *	@sk_user_data: RPC layer private data
-  *	@sk_sndmsg_page: cached page for sendmsg
-  *	@sk_sndmsg_off: cached offset for sendmsg
+  *	@sk_sndmsg_page: cached page for splice/ip6_append_data()
+  *	@sk_sndmsg_off: cached offset for splice/ip6_append_data()
   *	@sk_peek_off: current peek_offset value
   *	@sk_send_head: front of stuff to transmit
   *	@sk_security: used by security modules
@@ -2034,11 +2034,17 @@ static inline void sk_stream_moderate_sndbuf(struct sock *sk)
 
 struct sk_buff *sk_stream_alloc_skb(struct sock *sk, int size, gfp_t gfp);
 
+/* On 32bit arches, an skb frag is limited to 2^15, because
+ * (struct skb_frag_struct)->size/offset are u16
+ */
+#define SNDMSG_PAGE_ORDER	min(get_order(32768), PAGE_ALLOC_COSTLY_ORDER)
+#define SNDMSG_PAGE_SIZE	(PAGE_SIZE << SNDMSG_PAGE_ORDER)
+
 static inline struct page *sk_stream_alloc_page(struct sock *sk)
 {
 	struct page *page = NULL;
 
-	page = alloc_pages(sk->sk_allocation, 0);
+	page = alloc_pages(sk->sk_allocation | __GFP_COMP, SNDMSG_PAGE_ORDER);
 	if (!page) {
 		sk_enter_memory_pressure(sk);
 		sk_stream_moderate_sndbuf(sk);
diff --git a/kernel/exit.c b/kernel/exit.c
index f65345f..487b81a 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -1046,6 +1046,9 @@ void do_exit(long code)
 	if (tsk->splice_pipe)
 		__free_pipe_info(tsk->splice_pipe);
 
+	if (tsk->sndmsg_page)
+		put_page(tsk->sndmsg_page);
+
 	validate_creds_for_do_exit(tsk);
 
 	preempt_disable();
diff --git a/kernel/fork.c b/kernel/fork.c
index 2c8857e..60b58af 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -330,6 +330,7 @@ static struct task_struct *dup_task_struct(struct task_struct *orig)
 	tsk->btrace_seq = 0;
 #endif
 	tsk->splice_pipe = NULL;
+	tsk->sndmsg_page = NULL;
 
 	account_kernel_stack(ti, 1);
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index df83d74..7942d82 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1152,16 +1152,16 @@ new_segment:
 			} else {
 				bool merge = false;
 				int i = skb_shinfo(skb)->nr_frags;
-				struct page *page = sk->sk_sndmsg_page;
+				struct page *page = current->sndmsg_page;
 				int off;
 
 				if (page && page_count(page) == 1)
-					sk->sk_sndmsg_off = 0;
+					current->sndmsg_off = 0;
 
-				off = sk->sk_sndmsg_off;
+				off = current->sndmsg_off;
 
 				if (skb_can_coalesce(skb, i, page, off) &&
-				    off != PAGE_SIZE) {
+				    off != SNDMSG_PAGE_SIZE) {
 					/* We can extend the last page
 					 * fragment. */
 					merge = true;
@@ -1173,16 +1173,16 @@ new_segment:
 					tcp_mark_push(tp, skb);
 					goto new_segment;
 				} else if (page) {
-					if (off == PAGE_SIZE) {
+					if (off == SNDMSG_PAGE_SIZE) {
 						put_page(page);
-						sk->sk_sndmsg_page = page = NULL;
+						current->sndmsg_page = page = NULL;
 						off = 0;
 					}
 				} else
 					off = 0;
 
-				if (copy > PAGE_SIZE - off)
-					copy = PAGE_SIZE - off;
+				if (copy > SNDMSG_PAGE_SIZE - off)
+					copy = SNDMSG_PAGE_SIZE - off;
 
 				if (!sk_wmem_schedule(sk, copy))
 					goto wait_for_memory;
@@ -1198,12 +1198,12 @@ new_segment:
 				err = skb_copy_to_page_nocache(sk, from, skb,
 							       page, off, copy);
 				if (err) {
-					/* If this page was new, give it to the
-					 * socket so it does not get leaked.
+					/* If this page was new, remember it
+					 * so it does not get leaked.
 					 */
-					if (!sk->sk_sndmsg_page) {
-						sk->sk_sndmsg_page = page;
-						sk->sk_sndmsg_off = 0;
+					if (!current->sndmsg_page) {
+						current->sndmsg_page = page;
+						current->sndmsg_off = 0;
 					}
 					goto do_error;
 				}
@@ -1213,15 +1213,15 @@ new_segment:
 					skb_frag_size_add(&skb_shinfo(skb)->frags[i - 1], copy);
 				} else {
 					skb_fill_page_desc(skb, i, page, off, copy);
-					if (sk->sk_sndmsg_page) {
+					if (current->sndmsg_page) {
 						get_page(page);
-					} else if (off + copy < PAGE_SIZE) {
+					} else if (off + copy < SNDMSG_PAGE_SIZE) {
 						get_page(page);
-						sk->sk_sndmsg_page = page;
+						current->sndmsg_page = page;
 					}
 				}
 
-				sk->sk_sndmsg_off = off + copy;
+				current->sndmsg_off = off + copy;
 			}
 
 			if (!copied)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index e64abed..e457d65 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2196,9 +2196,7 @@ void tcp_v4_destroy_sock(struct sock *sk)
 	if (inet_csk(sk)->icsk_bind_hash)
 		inet_put_port(sk);
 
-	/*
-	 * If sendmsg cached page exists, toss it.
-	 */
+	/* If cached page exists, toss it. */
 	if (sk->sk_sndmsg_page) {
 		__free_page(sk->sk_sndmsg_page);
 		sk->sk_sndmsg_page = NULL;
