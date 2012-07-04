From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC PATCH] tcp: limit data skbs in qdisc layer
Date: Wed, 04 Jul 2012 12:11:27 +0200
Message-ID: <1341396687.2583.1757.camel@edumazet-glaptop>
References: <1340903237.13187.151.camel@edumazet-glaptop>
	<CAA93jw7agn2J6Hd7x22KWhENY5jqVjnk6uRr=3LJ5Anw7EgacQ@mail.gmail.com>
	<1340907151.13187.169.camel@edumazet-glaptop>
	<CAK6E8=dM0HNjjT=pDWzkBHs2Npi9foAnk1zxXdVLqBxA63dSqw@mail.gmail.com>
	<CAA93jw7ywd0auqN=k2J4fLOGYMLRH+agWr4P+_CisgvRtvgJUw@mail.gmail.com>
	<1340945457.29822.7.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Nandita Dukkipati <nanditad@google.com>, netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>, codel@lists.bufferbloat.net,
	Matt Mathis <mattmathis@google.com>, Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <1340945457.29822.7.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

On Fri, 2012-06-29 at 06:51 +0200, Eric Dumazet wrote:

> My long term plan is to reduce number of skbs queued in Qdisc for TCP
> stack, to reduce RTT (removing the artificial RTT bias because of local
> queues)

preliminar patch to give the rough idea :

sk->sk_wmem_alloc not allowed to grow above a given limit,
allowing no more than ~4 segments [1] per tcp socket in qdisc layer at a
given time. (if TSO is enabled, then a single TSO packet hits the limit)

This means we divert sock_wfree() to a tcp_wfree() handler, to
queue/send following frames when skb_orphan() is called for the already
queued skbs.

Note : While this lowers artificial cwnd and rtt, this means more work
has to be done by tx completion handler (softirq instead of preemptable
process context)

To reduce this possible source of latency, we can skb_try_orphan(skb) in
NIC drivers ndo_start_xmit() instead of waiting TX completion, but do
this orphaning only on BQL enabled drivers, or in drivers known to
possibly delay TX completion (NIU is an example, as David had to revert
BQL because of this delaying)

results on my dev machine (tg3 nic) are really impressive, using
standard pfifo_fast, and with or without TSO/GSO

I no longer have 3MBytes backlogged in qdisc by a single netperf
session, and both side socket autotuning no longer use 4 Mbytes.

tcp_write_xmit() call is probably very naive and lacks proper tests.

Note :

[1] because sk_wmem_alloc accounts skb truesize, mss*4 test allow less
then 4 frames, but it seems ok.

 drivers/net/ethernet/broadcom/tg3.c |    1 
 include/linux/skbuff.h              |    6 +++
 include/net/sock.h                  |    1 
 net/ipv4/tcp_output.c               |   44 +++++++++++++++++++++++++-
 4 files changed, 51 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index e47ff8b..ce0ca96 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -7020,6 +7020,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	skb_tx_timestamp(skb);
 	netdev_tx_sent_queue(txq, skb->len);
+	skb_try_orphan(skb);
 
 	/* Sync BD data before updating mailbox */
 	wmb();
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 885c9bd..c4d4d15 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1667,6 +1667,12 @@ static inline void skb_orphan(struct sk_buff *skb)
 	skb->sk		= NULL;
 }
 
+static inline void skb_try_orphan(struct sk_buff *skb)
+{
+	if (!skb_shinfo(skb)->tx_flags)
+		skb_orphan(skb);
+}
+
 /**
  *	__skb_queue_purge - empty a list
  *	@list: list to empty
diff --git a/include/net/sock.h b/include/net/sock.h
index 640432a..2ce17b1 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1389,6 +1389,7 @@ extern void release_sock(struct sock *sk);
 
 /* BH context may only use the following locking interface. */
 #define bh_lock_sock(__sk)	spin_lock(&((__sk)->sk_lock.slock))
+#define bh_trylock_sock(__sk)	spin_trylock(&((__sk)->sk_lock.slock))
 #define bh_lock_sock_nested(__sk) \
 				spin_lock_nested(&((__sk)->sk_lock.slock), \
 				SINGLE_DEPTH_NESTING)
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index c465d3e..4e6ef82 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -65,6 +65,8 @@ int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
 int sysctl_tcp_cookie_size __read_mostly = 0; /* TCP_COOKIE_MAX */
 EXPORT_SYMBOL_GPL(sysctl_tcp_cookie_size);
 
+static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
+			   int push_one, gfp_t gfp);
 
 /* Account for new data that has been sent to the network. */
 static void tcp_event_new_data_sent(struct sock *sk, const struct sk_buff *skb)
@@ -783,6 +785,34 @@ static unsigned int tcp_established_options(struct sock *sk, struct sk_buff *skb
 	return size;
 }
 
+/*
+ * Write buffer destructor automatically called from kfree_skb.
+ */
+void tcp_wfree(struct sk_buff *skb)
+{
+	struct sock *sk = skb->sk;
+	unsigned int len = skb->truesize;
+
+	atomic_sub(len - 1, &sk->sk_wmem_alloc);
+	if (bh_trylock_sock(sk)) {
+		if (!sock_owned_by_user(sk)) {
+			if ((1 << sk->sk_state) &
+			    (TCPF_CLOSE_WAIT | TCPF_ESTABLISHED))
+				tcp_write_xmit(sk,
+					       tcp_current_mss(sk),
+					       0, 0,
+					       GFP_ATOMIC);
+		} else {
+			/* TODO : might signal something here
+			 * so that user thread can call tcp_write_xmit()
+			 */
+		}
+		bh_unlock_sock(sk);
+	}
+
+	sk_free(sk);	
+}
+
 /* This routine actually transmits TCP packets queued in by
  * tcp_do_sendmsg().  This is used by both the initial
  * transmission and possible later retransmissions.
@@ -844,7 +874,11 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 
 	skb_push(skb, tcp_header_size);
 	skb_reset_transport_header(skb);
-	skb_set_owner_w(skb, sk);
+
+	skb_orphan(skb);
+	skb->sk = sk;
+	skb->destructor = tcp_wfree;
+	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
 
 	/* Build TCP header and checksum it. */
 	th = tcp_hdr(skb);
@@ -1780,6 +1814,14 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 	while ((skb = tcp_send_head(sk))) {
 		unsigned int limit;
 
+		/* yes, sk_wmem_alloc accounts skb truesize, so mss_now * 4
+		 * is a lazy approximation of our needs, but it seems ok
+		 */
+		if (atomic_read(&sk->sk_wmem_alloc) >= mss_now * 4) {
+			pr_debug("here we stop sending frame because sk_wmem_alloc %d\n",
+				atomic_read(&sk->sk_wmem_alloc));
+			break;
+		}
 		tso_segs = tcp_init_tso_segs(sk, skb, mss_now);
 		BUG_ON(!tso_segs);
