From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v1] net: use a per task frag allocator
Date: Fri, 21 Sep 2012 16:57:13 +0200
Message-ID: <1348239433.2669.522.camel@edumazet-glaptop>
References: <1348073761.26523.1095.camel@edumazet-glaptop>
	 <20120920.174827.1245530945282009606.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120920.174827.1245530945282009606.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-09-20 at 17:48 -0400, David Miller wrote:

> 
> I like this a lot and I look forward to your upcoming changes to
> convert the other two sk_sndmsg_page users as well, but I can't
> apply this to net-next just yet.
> 

Sure, I was not expecting a merge at this early stage.

> The question on fallback is a good one and something we have
> to resolve before applying this.
> 
> Note in particular that sk_allocation can be set to just about
> anything, and this also has potential interaction issues with
> SOCK_MEMALLOC.

It seems the SOCK_MEMALLOC is only used in the receive path ?

current tcp_sendmsg() uses a mere :

static inline struct page *sk_stream_alloc_page(struct sock *sk)
{
	struct page *page = NULL;

	page = alloc_pages(sk->sk_allocation, 0);
...

So there is no test on SOCK_MEMALLOC flag, and everything is contained
in sk_allocation.


What I did on v2 is to use either :

- Per task __GFP_WAIT frag allocator (current->task_frag)

- Per socket !__GFP_WAIT frag allocator (sk->sk_frag), used only
  on 'special' sockets (kernel icmp sockets for example), or any socket
  that use GFP_ATOMIC for its sk_allocation mode

Both use a common helper trying to allocate "32768 bytes" pages,
with fallback to smaller ones in case of memory pressure.

I removed the special cork->page Herbert Xu introduced
for the lockless udp send : we can use the per task task_frag for this.

I also covered ipv6/ipv4 append_data use to benefit from high order
pages as well.

This patch actually removes 40 LOC in the kernel ;)

Thanks

(As a followup, sk_enter_memory_pressure() could be moved from
include/net/sock.h to net/core/sock.c)

[PATCH net-next v2] net: use a per task frag allocator

We currently use a per socket order-0 page cache for tcp_sendmsg()
operations.

This page is used to build fragments for skbs.

Its done to increase probability of coalescing small write() into
single segments in skbs still in write queue (not yet sent)

But it wastes a lot of memory for applications handling many mostly
idle sockets, since each socket holds one page in sk->sk_sndmsg_page

Its also quite inefficient to build TSO 64KB packets, because we need
about 16 pages per skb on arches where PAGE_SIZE = 4096, so we hit
page allocator more than wanted.

This patch adds a per task frag allocator and uses bigger pages,
if available. An automatic fallback is done in case of memory pressure.

(up to 32768 bytes per frag, thats order-3 pages on x86)

This increases TCP stream performance by 20% on loopback device,
but also benefits on other network devices, since 8x less frags are
mapped on transmit and unmapped on tx completion. Alexander Duyck
mentioned a probable performance win on systems with IOMMU enabled.

Its possible some SG enabled hardware cant cope with bigger fragments,
but their ndo_start_xmit() should already handle this, splitting a
fragment in sub fragments, since some arches have PAGE_SIZE=65536

Successfully tested on various ethernet devices.
(ixgbe, igb, bnx2x, tg3, mellanox mlx4)

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
---
v2: uses existing page_frag structure to hold page/offset/size
    convert linear_to_page()/__ip_append_data()/ip6_append_data()
    remove @page and @off fields from struct inet_cork
    move the destructor from tcp_v4_destroy_sock() to sk_common_release

 include/linux/sched.h   |    3 +
 include/net/inet_sock.h |    4 -
 include/net/sock.h      |   27 +++++++-----
 kernel/exit.c           |    3 +
 kernel/fork.c           |    1 
 net/core/skbuff.c       |   37 ++++-------------
 net/core/sock.c         |   48 ++++++++++++++++++++++-
 net/ipv4/ip_output.c    |   70 +++++++++++++--------------------
 net/ipv4/tcp.c          |   79 ++++++++++----------------------------
 net/ipv4/tcp_ipv4.c     |    8 ---
 net/ipv6/ip6_output.c   |   65 ++++++++++++-------------------
 11 files changed, 153 insertions(+), 192 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index b8c8664..a8e2413 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1530,6 +1530,9 @@ struct task_struct {
 	 * cache last used pipe for splice
 	 */
 	struct pipe_inode_info *splice_pipe;
+
+	struct page_frag task_frag;
+
 #ifdef	CONFIG_TASK_DELAY_ACCT
 	struct task_delay_info *delays;
 #endif
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 613cfa4..256c1ed 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -101,10 +101,8 @@ struct inet_cork {
 	__be32			addr;
 	struct ip_options	*opt;
 	unsigned int		fragsize;
-	struct dst_entry	*dst;
 	int			length; /* Total length of all frames */
-	struct page		*page;
-	u32			off;
+	struct dst_entry	*dst;
 	u8			tx_flags;
 };
 
diff --git a/include/net/sock.h b/include/net/sock.h
index 181b711..42053759 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -247,8 +247,7 @@ struct cg_proto;
   *	@sk_stamp: time stamp of last packet received
   *	@sk_socket: Identd and reporting IO signals
   *	@sk_user_data: RPC layer private data
-  *	@sk_sndmsg_page: cached page for sendmsg
-  *	@sk_sndmsg_off: cached offset for sendmsg
+  *	@sk_frag: cached page frag
   *	@sk_peek_off: current peek_offset value
   *	@sk_send_head: front of stuff to transmit
   *	@sk_security: used by security modules
@@ -362,9 +361,8 @@ struct sock {
 	ktime_t			sk_stamp;
 	struct socket		*sk_socket;
 	void			*sk_user_data;
-	struct page		*sk_sndmsg_page;
+	struct page_frag	sk_frag;
 	struct sk_buff		*sk_send_head;
-	__u32			sk_sndmsg_off;
 	__s32			sk_peek_off;
 	int			sk_write_pending;
 #ifdef CONFIG_SECURITY
@@ -2034,18 +2032,23 @@ static inline void sk_stream_moderate_sndbuf(struct sock *sk)
 
 struct sk_buff *sk_stream_alloc_skb(struct sock *sk, int size, gfp_t gfp);
 
-static inline struct page *sk_stream_alloc_page(struct sock *sk)
+/**
+ * sk_page_frag - return an appropriate page_frag
+ * @sk: socket
+ *
+ * If socket allocation mode allows current thread to sleep, it means its
+ * safe to use the per task page_frag instead of the per socket one.
+ */
+static inline struct page_frag *sk_page_frag(struct sock *sk)
 {
-	struct page *page = NULL;
+	if (sk->sk_allocation & __GFP_WAIT)
+		return &current->task_frag;
 
-	page = alloc_pages(sk->sk_allocation, 0);
-	if (!page) {
-		sk_enter_memory_pressure(sk);
-		sk_stream_moderate_sndbuf(sk);
-	}
-	return page;
+	return &sk->sk_frag;
 }
 
+extern bool sk_page_frag_refill(struct sock *sk, struct page_frag *pfrag);
+
 /*
  *	Default write policy as shown to user space via poll/select/SIGIO
  */
diff --git a/kernel/exit.c b/kernel/exit.c
index f65345f..42f2595 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -1046,6 +1046,9 @@ void do_exit(long code)
 	if (tsk->splice_pipe)
 		__free_pipe_info(tsk->splice_pipe);
 
+	if (tsk->task_frag.page)
+		put_page(tsk->task_frag.page);
+
 	validate_creds_for_do_exit(tsk);
 
 	preempt_disable();
diff --git a/kernel/fork.c b/kernel/fork.c
index 2c8857e..01565b9 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -330,6 +330,7 @@ static struct task_struct *dup_task_struct(struct task_struct *orig)
 	tsk->btrace_seq = 0;
 #endif
 	tsk->splice_pipe = NULL;
+	tsk->task_frag.page = NULL;
 
 	account_kernel_stack(ti, 1);
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index fe00d12..2ede3cf 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1655,38 +1655,19 @@ static struct page *linear_to_page(struct page *page, unsigned int *len,
 				   unsigned int *offset,
 				   struct sk_buff *skb, struct sock *sk)
 {
-	struct page *p = sk->sk_sndmsg_page;
-	unsigned int off;
+	struct page_frag *pfrag = sk_page_frag(sk);
 
-	if (!p) {
-new_page:
-		p = sk->sk_sndmsg_page = alloc_pages(sk->sk_allocation, 0);
-		if (!p)
-			return NULL;
-
-		off = sk->sk_sndmsg_off = 0;
-		/* hold one ref to this page until it's full */
-	} else {
-		unsigned int mlen;
-
-		/* If we are the only user of the page, we can reset offset */
-		if (page_count(p) == 1)
-			sk->sk_sndmsg_off = 0;
-		off = sk->sk_sndmsg_off;
-		mlen = PAGE_SIZE - off;
-		if (mlen < 64 && mlen < *len) {
-			put_page(p);
-			goto new_page;
-		}
+	if (!sk_page_frag_refill(sk, pfrag))
+		return NULL;
 
-		*len = min_t(unsigned int, *len, mlen);
-	}
+	*len = min_t(unsigned int, *len, pfrag->size - pfrag->offset);
 
-	memcpy(page_address(p) + off, page_address(page) + *offset, *len);
-	sk->sk_sndmsg_off += *len;
-	*offset = off;
+	memcpy(page_address(pfrag->page) + pfrag->offset,
+	       page_address(page) + *offset, *len);
+	*offset = pfrag->offset;
+	pfrag->offset += *len;
 
-	return p;
+	return pfrag->page;
 }
 
 static bool spd_can_coalesce(const struct splice_pipe_desc *spd,
diff --git a/net/core/sock.c b/net/core/sock.c
index 2693f76..a9f6a4d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1744,6 +1744,45 @@ struct sk_buff *sock_alloc_send_skb(struct sock *sk, unsigned long size,
 }
 EXPORT_SYMBOL(sock_alloc_send_skb);
 
+/* On 32bit arches, an skb frag is limited to 2^15 */
+#define SKB_FRAG_PAGE_ORDER	get_order(32768)
+
+bool sk_page_frag_refill(struct sock *sk, struct page_frag *pfrag)
+{
+	int order;
+
+	if (pfrag->page) {
+		if (atomic_read(&pfrag->page->_count) == 1) {
+			pfrag->offset = 0;
+			return true;
+		}
+		if (pfrag->offset < pfrag->size)
+			return true;
+		put_page(pfrag->page);
+	}
+
+	/* We restrict high order allocations to users that can afford to wait */
+	order = (sk->sk_allocation & __GFP_WAIT) ? SKB_FRAG_PAGE_ORDER : 0;
+
+	do {
+		gfp_t gfp = sk->sk_allocation;
+
+		if (order)
+			gfp |= __GFP_COMP | __GFP_NOWARN;
+		pfrag->page = alloc_pages(gfp, order);
+		if (likely(pfrag->page)) {
+			pfrag->offset = 0;
+			pfrag->size = PAGE_SIZE << order;
+			return true;
+		}
+	} while (--order >= 0);
+
+	sk_enter_memory_pressure(sk);
+	sk_stream_moderate_sndbuf(sk);
+	return false;
+}
+EXPORT_SYMBOL(sk_page_frag_refill);
+
 static void __lock_sock(struct sock *sk)
 	__releases(&sk->sk_lock.slock)
 	__acquires(&sk->sk_lock.slock)
@@ -2173,8 +2212,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 	sk->sk_error_report	=	sock_def_error_report;
 	sk->sk_destruct		=	sock_def_destruct;
 
-	sk->sk_sndmsg_page	=	NULL;
-	sk->sk_sndmsg_off	=	0;
+	sk->sk_frag.page	=	NULL;
 	sk->sk_peek_off		=	-1;
 
 	sk->sk_peer_pid 	=	NULL;
@@ -2417,6 +2455,12 @@ void sk_common_release(struct sock *sk)
 	xfrm_sk_free_policy(sk);
 
 	sk_refcnt_debug_release(sk);
+
+	if (sk->sk_frag.page) {
+		put_page(sk->sk_frag.page);
+		sk->sk_frag.page = NULL;
+	}
+
 	sock_put(sk);
 }
 EXPORT_SYMBOL(sk_common_release);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index a5beab1..24a29a3 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -793,6 +793,7 @@ static int __ip_append_data(struct sock *sk,
 			    struct flowi4 *fl4,
 			    struct sk_buff_head *queue,
 			    struct inet_cork *cork,
+			    struct page_frag *pfrag,
 			    int getfrag(void *from, char *to, int offset,
 					int len, int odd, struct sk_buff *skb),
 			    void *from, int length, int transhdrlen,
@@ -987,47 +988,30 @@ alloc_new_skb:
 			}
 		} else {
 			int i = skb_shinfo(skb)->nr_frags;
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[i-1];
-			struct page *page = cork->page;
-			int off = cork->off;
-			unsigned int left;
-
-			if (page && (left = PAGE_SIZE - off) > 0) {
-				if (copy >= left)
-					copy = left;
-				if (page != skb_frag_page(frag)) {
-					if (i == MAX_SKB_FRAGS) {
-						err = -EMSGSIZE;
-						goto error;
-					}
-					skb_fill_page_desc(skb, i, page, off, 0);
-					skb_frag_ref(skb, i);
-					frag = &skb_shinfo(skb)->frags[i];
-				}
-			} else if (i < MAX_SKB_FRAGS) {
-				if (copy > PAGE_SIZE)
-					copy = PAGE_SIZE;
-				page = alloc_pages(sk->sk_allocation, 0);
-				if (page == NULL)  {
-					err = -ENOMEM;
-					goto error;
-				}
-				cork->page = page;
-				cork->off = 0;
 
-				skb_fill_page_desc(skb, i, page, 0, 0);
-				frag = &skb_shinfo(skb)->frags[i];
-			} else {
-				err = -EMSGSIZE;
-				goto error;
-			}
-			if (getfrag(from, skb_frag_address(frag)+skb_frag_size(frag),
-				    offset, copy, skb->len, skb) < 0) {
-				err = -EFAULT;
+			err = -ENOMEM;
+			if (!sk_page_frag_refill(sk, pfrag))
 				goto error;
+
+			if (!skb_can_coalesce(skb, i, pfrag->page,
+					      pfrag->offset)) {
+				err = -EMSGSIZE;
+				if (i == MAX_SKB_FRAGS)
+					goto error;
+
+				__skb_fill_page_desc(skb, i, pfrag->page,
+						     pfrag->offset, 0);
+				skb_shinfo(skb)->nr_frags = ++i;
+				get_page(pfrag->page);
 			}
-			cork->off += copy;
-			skb_frag_size_add(frag, copy);
+			copy = min_t(int, copy, pfrag->size - pfrag->offset);
+			if (getfrag(from,
+				    page_address(pfrag->page) + pfrag->offset,
+				    offset, copy, skb->len, skb) < 0)
+				goto error_efault;
+
+			pfrag->offset += copy;
+			skb_frag_size_add(&skb_shinfo(skb)->frags[i - 1], copy);
 			skb->len += copy;
 			skb->data_len += copy;
 			skb->truesize += copy;
@@ -1039,6 +1023,8 @@ alloc_new_skb:
 
 	return 0;
 
+error_efault:
+	err = -EFAULT;
 error:
 	cork->length -= length;
 	IP_INC_STATS(sock_net(sk), IPSTATS_MIB_OUTDISCARDS);
@@ -1079,8 +1065,6 @@ static int ip_setup_cork(struct sock *sk, struct inet_cork *cork,
 	cork->dst = &rt->dst;
 	cork->length = 0;
 	cork->tx_flags = ipc->tx_flags;
-	cork->page = NULL;
-	cork->off = 0;
 
 	return 0;
 }
@@ -1117,7 +1101,8 @@ int ip_append_data(struct sock *sk, struct flowi4 *fl4,
 		transhdrlen = 0;
 	}
 
-	return __ip_append_data(sk, fl4, &sk->sk_write_queue, &inet->cork.base, getfrag,
+	return __ip_append_data(sk, fl4, &sk->sk_write_queue, &inet->cork.base,
+				sk_page_frag(sk), getfrag,
 				from, length, transhdrlen, flags);
 }
 
@@ -1439,7 +1424,8 @@ struct sk_buff *ip_make_skb(struct sock *sk,
 	if (err)
 		return ERR_PTR(err);
 
-	err = __ip_append_data(sk, fl4, &queue, &cork, getfrag,
+	err = __ip_append_data(sk, fl4, &queue, &cork,
+			       &current->task_frag, getfrag,
 			       from, length, transhdrlen, flags);
 	if (err) {
 		__ip_flush_pending_frames(sk, &queue, &cork);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index df83d74..ede98db 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1150,78 +1150,43 @@ new_segment:
 				if (err)
 					goto do_fault;
 			} else {
-				bool merge = false;
+				bool merge = true;
 				int i = skb_shinfo(skb)->nr_frags;
-				struct page *page = sk->sk_sndmsg_page;
-				int off;
-
-				if (page && page_count(page) == 1)
-					sk->sk_sndmsg_off = 0;
-
-				off = sk->sk_sndmsg_off;
-
-				if (skb_can_coalesce(skb, i, page, off) &&
-				    off != PAGE_SIZE) {
-					/* We can extend the last page
-					 * fragment. */
-					merge = true;
-				} else if (i == MAX_SKB_FRAGS || !sg) {
-					/* Need to add new fragment and cannot
-					 * do this because interface is non-SG,
-					 * or because all the page slots are
-					 * busy. */
-					tcp_mark_push(tp, skb);
-					goto new_segment;
-				} else if (page) {
-					if (off == PAGE_SIZE) {
-						put_page(page);
-						sk->sk_sndmsg_page = page = NULL;
-						off = 0;
+				struct page_frag *pfrag = sk_page_frag(sk);
+
+				if (!sk_page_frag_refill(sk, pfrag))
+					goto wait_for_memory;
+
+				if (!skb_can_coalesce(skb, i, pfrag->page,
+						      pfrag->offset)) {
+					if (i == MAX_SKB_FRAGS || !sg) {
+						tcp_mark_push(tp, skb);
+						goto new_segment;
 					}
-				} else
-					off = 0;
+					merge = false;
+				}
 
-				if (copy > PAGE_SIZE - off)
-					copy = PAGE_SIZE - off;
+				copy = min_t(int, copy, pfrag->size - pfrag->offset);
 
 				if (!sk_wmem_schedule(sk, copy))
 					goto wait_for_memory;
 
-				if (!page) {
-					/* Allocate new cache page. */
-					if (!(page = sk_stream_alloc_page(sk)))
-						goto wait_for_memory;
-				}
-
-				/* Time to copy data. We are close to
-				 * the end! */
 				err = skb_copy_to_page_nocache(sk, from, skb,
-							       page, off, copy);
-				if (err) {
-					/* If this page was new, give it to the
-					 * socket so it does not get leaked.
-					 */
-					if (!sk->sk_sndmsg_page) {
-						sk->sk_sndmsg_page = page;
-						sk->sk_sndmsg_off = 0;
-					}
+							       pfrag->page,
+							       pfrag->offset,
+							       copy);
+				if (err)
 					goto do_error;
-				}
 
 				/* Update the skb. */
 				if (merge) {
 					skb_frag_size_add(&skb_shinfo(skb)->frags[i - 1], copy);
 				} else {
-					skb_fill_page_desc(skb, i, page, off, copy);
-					if (sk->sk_sndmsg_page) {
-						get_page(page);
-					} else if (off + copy < PAGE_SIZE) {
-						get_page(page);
-						sk->sk_sndmsg_page = page;
-					}
+					skb_fill_page_desc(skb, i, pfrag->page,
+							   pfrag->offset, copy);
+					get_page(pfrag->page);
 				}
-
-				sk->sk_sndmsg_off = off + copy;
+				pfrag->offset += copy;
 			}
 
 			if (!copied)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index e64abed..1bbee19 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2196,14 +2196,6 @@ void tcp_v4_destroy_sock(struct sock *sk)
 	if (inet_csk(sk)->icsk_bind_hash)
 		inet_put_port(sk);
 
-	/*
-	 * If sendmsg cached page exists, toss it.
-	 */
-	if (sk->sk_sndmsg_page) {
-		__free_page(sk->sk_sndmsg_page);
-		sk->sk_sndmsg_page = NULL;
-	}
-
 	/* TCP Cookie Transactions */
 	if (tp->cookie_values != NULL) {
 		kref_put(&tp->cookie_values->kref,
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 3dd4a37..aece3e7 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1279,8 +1279,6 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		if (dst_allfrag(rt->dst.path))
 			cork->flags |= IPCORK_ALLFRAG;
 		cork->length = 0;
-		sk->sk_sndmsg_page = NULL;
-		sk->sk_sndmsg_off = 0;
 		exthdrlen = (opt ? opt->opt_flen : 0) - rt->rt6i_nfheader_len;
 		length += exthdrlen;
 		transhdrlen += exthdrlen;
@@ -1504,48 +1502,31 @@ alloc_new_skb:
 			}
 		} else {
 			int i = skb_shinfo(skb)->nr_frags;
-			skb_frag_t *frag = &skb_shinfo(skb)->frags[i-1];
-			struct page *page = sk->sk_sndmsg_page;
-			int off = sk->sk_sndmsg_off;
-			unsigned int left;
-
-			if (page && (left = PAGE_SIZE - off) > 0) {
-				if (copy >= left)
-					copy = left;
-				if (page != skb_frag_page(frag)) {
-					if (i == MAX_SKB_FRAGS) {
-						err = -EMSGSIZE;
-						goto error;
-					}
-					skb_fill_page_desc(skb, i, page, sk->sk_sndmsg_off, 0);
-					skb_frag_ref(skb, i);
-					frag = &skb_shinfo(skb)->frags[i];
-				}
-			} else if(i < MAX_SKB_FRAGS) {
-				if (copy > PAGE_SIZE)
-					copy = PAGE_SIZE;
-				page = alloc_pages(sk->sk_allocation, 0);
-				if (page == NULL) {
-					err = -ENOMEM;
-					goto error;
-				}
-				sk->sk_sndmsg_page = page;
-				sk->sk_sndmsg_off = 0;
+			struct page_frag *pfrag = sk_page_frag(sk);
 
-				skb_fill_page_desc(skb, i, page, 0, 0);
-				frag = &skb_shinfo(skb)->frags[i];
-			} else {
-				err = -EMSGSIZE;
+			err = -ENOMEM;
+			if (!sk_page_frag_refill(sk, pfrag))
 				goto error;
+
+			if (!skb_can_coalesce(skb, i, pfrag->page,
+					      pfrag->offset)) {
+				err = -EMSGSIZE;
+				if (i == MAX_SKB_FRAGS)
+					goto error;
+
+				__skb_fill_page_desc(skb, i, pfrag->page,
+						     pfrag->offset, 0);
+				skb_shinfo(skb)->nr_frags = ++i;
+				get_page(pfrag->page);
 			}
+			copy = min_t(int, copy, pfrag->size - pfrag->offset);
 			if (getfrag(from,
-				    skb_frag_address(frag) + skb_frag_size(frag),
-				    offset, copy, skb->len, skb) < 0) {
-				err = -EFAULT;
-				goto error;
-			}
-			sk->sk_sndmsg_off += copy;
-			skb_frag_size_add(frag, copy);
+				    page_address(pfrag->page) + pfrag->offset,
+				    offset, copy, skb->len, skb) < 0)
+				goto error_efault;
+
+			pfrag->offset += copy;
+			skb_frag_size_add(&skb_shinfo(skb)->frags[i - 1], copy);
 			skb->len += copy;
 			skb->data_len += copy;
 			skb->truesize += copy;
@@ -1554,7 +1535,11 @@ alloc_new_skb:
 		offset += copy;
 		length -= copy;
 	}
+
 	return 0;
+
+error_efault:
+	err = -EFAULT;
 error:
 	cork->length -= length;
 	IP6_INC_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUTDISCARDS);
