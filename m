From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [BK PATCH] sk_dst_cache annotation
Date: Sat, 15 Jan 2005 16:00:08 +0900 (JST)
Message-ID: <20050115.160008.04476889.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

I had looked around sk_dst_cache and now I have several doubts.

Following changesets depend on herbert's changeset.
(I removed that one from my changesets to avoid conflict.)

You can pull them from
  bk://bk.skbuff.net:20611/linux-2.6-refcnt

Thank you.

HEADLINES
---------
ChangeSet@1.2334, 2005-01-15 15:47:01+09:00, yoshfuji@linux-ipv6.org
 [TCP] Update MSS using exact dst, which the caller expects.
ChangeSet@1.2335, 2005-01-15 15:47:12+09:00, yoshfuji@linux-ipv6.org
 [NET] Always hold refcnt for dst when we use sk_dst_cache.
ChangeSet@1.2336, 2005-01-15 15:47:23+09:00, yoshfuji@linux-ipv6.org
 [NET] Introduce dst_check() to check if dst is still up-to-date.
ChangeSet@1.2337, 2005-01-15 15:47:35+09:00, yoshfuji@linux-ipv6.org
 [NET] Use sk_dst_check() to hold appropriate lock and refcnt.
ChangeSet@1.2338, 2005-01-15 15:47:46+09:00, yoshfuji@linux-ipv6.org
 [NET] Use sk_dst_set() for sk_dst_reset().
ChangeSet@1.2339, 2005-01-15 15:47:58+09:00, yoshfuji@linux-ipv6.org
 [DECNET] use sk_dst_set() to store sk_dst_cache. Clean up.
ChangeSet@1.2340, 2005-01-15 15:48:09+09:00, yoshfuji@linux-ipv6.org
 [NET] Use dst_clone() where appropriate.
ChangeSet@1.2341, 2005-01-15 15:48:21+09:00, yoshfuji@linux-ipv6.org
 [NET] Hold appropriate lock and refcnt when we do dst_negative_advice().


DIFFSTATS
---------
 include/net/dst.h       |   16 +++++++++++---
 include/net/sock.h      |   52 ++++++++++++++++++++++++++++++++++++++++++++----
 include/net/tcp.h       |   12 ++++++++++-
 net/decnet/af_decnet.c  |   18 ++++++++++++----
 net/decnet/dn_nsp_out.c |   39 ++++++++++++++++++------------------
 net/ipv4/ip_output.c    |    6 ++---
 net/ipv4/tcp_input.c    |   11 +++++++---
 net/ipv4/tcp_ipv4.c     |   20 +++++++++++-------
 net/ipv4/tcp_output.c   |   27 ++++++++++++++++--------
 net/ipv4/tcp_timer.c    |    4 +--
 net/ipv6/ip6_tunnel.c   |    3 --
 net/ipv6/tcp_ipv6.c     |   20 +++++++++---------
 12 files changed, 159 insertions(+), 69 deletions(-)


CHANGESETS
----------
ChangeSet@1.2334, 2005-01-15 15:47:01+09:00, yoshfuji@linux-ipv6.org
 [TCP] Update MSS using exact dst, which the caller expects.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	2005-01-15 15:54:11 +09:00
+++ b/include/net/tcp.h	2005-01-15 15:54:11 +09:00
@@ -961,7 +961,17 @@
 
 extern void tcp_delete_keepalive_timer(struct sock *);
 extern void tcp_reset_keepalive_timer(struct sock *, unsigned long);
-extern unsigned int tcp_sync_mss(struct sock *sk, u32 pmtu);
+
+extern unsigned int __tcp_sync_mss(struct sock *sk, struct dst_entry *dst,
+				   u32 pmtu);
+static inline unsigned int tcp_sync_mss(struct sock *sk, u32 pmtu)
+{
+	struct dst_entry *dst = sk_dst_get(sk);
+	unsigned int mss = __tcp_sync_mss(sk, dst, pmtu);
+	dst_release(dst);
+	return mss;
+}
+
 extern unsigned int tcp_current_mss(struct sock *sk, int large);
 
 #ifdef TCP_DEBUG
diff -Nru a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c	2005-01-15 15:54:11 +09:00
+++ b/net/ipv4/tcp_ipv4.c	2005-01-15 15:54:11 +09:00
@@ -948,7 +948,7 @@
 
 	if (inet->pmtudisc != IP_PMTUDISC_DONT &&
 	    tp->pmtu_cookie > mtu) {
-		tcp_sync_mss(sk, mtu);
+		__tcp_sync_mss(sk, dst, mtu);
 
 		/* Resend the TCP packet because it's
 		 * clear that the old packet has been
@@ -1581,7 +1581,7 @@
 	newtp->ext2_header_len = dst->header_len;
 	newinet->id = newtp->write_seq ^ jiffies;
 
-	tcp_sync_mss(newsk, dst_pmtu(dst));
+	__tcp_sync_mss(newsk, dst, dst_pmtu(dst));
 	newtp->advmss = dst_metric(dst, RTAX_ADVMSS);
 	tcp_initialize_rcv_mss(newsk);
 
diff -Nru a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c	2005-01-15 15:54:11 +09:00
+++ b/net/ipv4/tcp_output.c	2005-01-15 15:54:11 +09:00
@@ -618,10 +618,10 @@
    this function.			--ANK (980731)
  */
 
-unsigned int tcp_sync_mss(struct sock *sk, u32 pmtu)
+unsigned int __tcp_sync_mss(struct sock *sk, struct dst_entry *dst,
+			    u32 pmtu)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct dst_entry *dst = __sk_dst_get(sk);
 	int mss_now;
 
 	if (dst && dst->ops->get_mss)
@@ -676,7 +676,7 @@
 		u32 mtu = dst_pmtu(dst);
 		if (mtu != tp->pmtu_cookie ||
 		    tp->ext2_header_len != dst->header_len)
-			mss_now = tcp_sync_mss(sk, mtu);
+			mss_now = __tcp_sync_mss(sk, dst, mtu);
 	}
 
 	do_large = (large &&
@@ -1430,7 +1430,7 @@
 	if (tp->user_mss)
 		tp->mss_clamp = tp->user_mss;
 	tp->max_window = 0;
-	tcp_sync_mss(sk, dst_pmtu(dst));
+	__tcp_sync_mss(sk, dst, dst_pmtu(dst));
 
 	if (!tp->window_clamp)
 		tp->window_clamp = dst_metric(dst, RTAX_WINDOW);
@@ -1724,4 +1724,4 @@
 EXPORT_SYMBOL(tcp_connect);
 EXPORT_SYMBOL(tcp_make_synack);
 EXPORT_SYMBOL(tcp_simple_retransmit);
-EXPORT_SYMBOL(tcp_sync_mss);
+EXPORT_SYMBOL(__tcp_sync_mss);
diff -Nru a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c	2005-01-15 15:54:11 +09:00
+++ b/net/ipv6/tcp_ipv6.c	2005-01-15 15:54:11 +09:00
@@ -814,7 +814,7 @@
 			dst_hold(dst);
 
 		if (tp->pmtu_cookie > dst_pmtu(dst)) {
-			tcp_sync_mss(sk, dst_pmtu(dst));
+			__tcp_sync_mss(sk, dst, dst_pmtu(dst));
 			tcp_simple_retransmit(sk);
 		} /* else let the usual retransmit timer handle it */
 		dst_release(dst);
@@ -1444,7 +1444,7 @@
 					newnp->opt->opt_flen;
 	newtp->ext2_header_len = dst->header_len;
 
-	tcp_sync_mss(newsk, dst_pmtu(dst));
+	__tcp_sync_mss(newsk, dst, dst_pmtu(dst));
 	newtp->advmss = dst_metric(dst, RTAX_ADVMSS);
 	tcp_initialize_rcv_mss(newsk);
 

ChangeSet@1.2335, 2005-01-15 15:47:12+09:00, yoshfuji@linux-ipv6.org
 [NET] Always hold refcnt for dst when we use sk_dst_cache.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h	2005-01-15 15:54:16 +09:00
+++ b/include/net/sock.h	2005-01-15 15:54:16 +09:00
@@ -922,12 +922,6 @@
 extern unsigned long sock_i_ino(struct sock *sk);
 
 static inline struct dst_entry *
-__sk_dst_get(struct sock *sk)
-{
-	return sk->sk_dst_cache;
-}
-
-static inline struct dst_entry *
 sk_dst_get(struct sock *sk)
 {
 	struct dst_entry *dst;
diff -Nru a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
--- a/net/decnet/af_decnet.c	2005-01-15 15:54:16 +09:00
+++ b/net/decnet/af_decnet.c	2005-01-15 15:54:16 +09:00
@@ -807,14 +807,17 @@
 static int dn_confirm_accept(struct sock *sk, long *timeo, int allocation)
 {
 	struct dn_scp *scp = DN_SK(sk);
+	struct dst_entry *dst;
 	DEFINE_WAIT(wait);
 	int err;
 
 	if (scp->state != DN_CR)
 		return -EINVAL;
 
+	dst = sk_dst_get(sk);
+
 	scp->state = DN_CC;
-	scp->segsize_loc = dst_path_metric(__sk_dst_get(sk), RTAX_ADVMSS);
+	scp->segsize_loc = dst_path_metric(dst, RTAX_ADVMSS);
 	dn_send_conn_conf(sk, allocation);
 
 	prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
@@ -843,6 +846,9 @@
 	} else if (scp->state != DN_CC) {
 		sk->sk_socket->state = SS_UNCONNECTED;
 	}
+
+	dst_release(dst);
+
 	return err;
 }
 
@@ -1859,7 +1865,7 @@
 
 static inline unsigned int dn_current_mss(struct sock *sk, int flags)
 {
-	struct dst_entry *dst = __sk_dst_get(sk);
+	struct dst_entry *dst;
 	struct dn_scp *scp = DN_SK(sk);
 	int mss_now = min_t(int, scp->segsize_loc, scp->segsize_rem);
 
@@ -1867,10 +1873,14 @@
 	if (flags & MSG_OOB)
 		return 16;
 
+	dst = sk_dst_get(sk);
+
 	/* This works out the maximum size of segment we can send out */
 	if (dst) {
 		u32 mtu = dst_pmtu(dst);
 		mss_now = min_t(int, dn_mss_from_pmtu(dst->dev, mtu), mss_now);
+
+		dst_release(dst);
 	}
 
 	return mss_now;
diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	2005-01-15 15:54:16 +09:00
+++ b/net/ipv4/tcp_input.c	2005-01-15 15:54:16 +09:00
@@ -711,7 +711,7 @@
 void tcp_update_metrics(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct dst_entry *dst = __sk_dst_get(sk);
+	struct dst_entry *dst = sk_dst_get(sk);
 
 	if (sysctl_tcp_nometrics_save)
 		return;
@@ -728,7 +728,7 @@
 			 */
 			if (!(dst_metric_locked(dst, RTAX_RTT)))
 				dst->metrics[RTAX_RTT-1] = 0;
-			return;
+			goto out;
 		}
 
 		m = dst_metric(dst, RTAX_RTT) - tp->srtt;
@@ -795,6 +795,8 @@
 				dst->metrics[RTAX_REORDERING-1] = tp->reordering;
 		}
 	}
+out:
+	dst_release(dst);
 }
 
 /* Numbers are taken from RFC2414.  */
@@ -816,7 +818,7 @@
 static void tcp_init_metrics(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct dst_entry *dst = __sk_dst_get(sk);
+	struct dst_entry *dst = sk_dst_get(sk);
 
 	if (dst == NULL)
 		goto reset;
@@ -870,6 +872,8 @@
 		goto reset;
 	tp->snd_cwnd = tcp_init_cwnd(tp, dst);
 	tp->snd_cwnd_stamp = tcp_time_stamp;
+out:
+	dst_release(dst);
 	return;
 
 reset:
@@ -882,6 +886,7 @@
 		tp->mdev = tp->mdev_max = tp->rttvar = TCP_TIMEOUT_INIT;
 		tp->rto = TCP_TIMEOUT_INIT;
 	}
+	goto out;
 }
 
 static void tcp_update_reordering(struct tcp_sock *tp, int metric, int ts)
diff -Nru a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c	2005-01-15 15:54:16 +09:00
+++ b/net/ipv4/tcp_ipv4.c	2005-01-15 15:54:16 +09:00
@@ -1973,7 +1973,7 @@
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct rtable *rt = (struct rtable *)__sk_dst_get(sk);
+	struct rtable *rt = (struct rtable *)sk_dst_get(sk);
 	struct inet_peer *peer = NULL;
 	int release_it = 0;
 
@@ -1995,10 +1995,10 @@
 		}
 		if (release_it)
 			inet_putpeer(peer);
-		return 1;
 	}
 
-	return 0;
+	dst_release(&rt->u.dst);
+	return (peer != NULL);
 }
 
 int tcp_v4_tw_remember_stamp(struct tcp_tw_bucket *tw)
diff -Nru a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c	2005-01-15 15:54:16 +09:00
+++ b/net/ipv4/tcp_output.c	2005-01-15 15:54:16 +09:00
@@ -92,7 +92,7 @@
 static __u16 tcp_advertise_mss(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct dst_entry *dst = __sk_dst_get(sk);
+	struct dst_entry *dst = sk_dst_get(sk);
 	int mss = tp->advmss;
 
 	if (dst && dst_metric(dst, RTAX_ADVMSS) < mss) {
@@ -100,6 +100,8 @@
 		tp->advmss = mss;
 	}
 
+	dst_release(dst);
+
 	return (__u16)mss;
 }
 
@@ -128,10 +130,11 @@
 				       struct sk_buff *skb, struct sock *sk)
 {
 	u32 now = tcp_time_stamp;
+	struct dst_entry *dst = sk_dst_get(sk);
 
 	if (!tcp_get_pcount(&tp->packets_out) &&
 	    (s32)(now - tp->lsndtime) > tp->rto)
-		tcp_cwnd_restart(tp, __sk_dst_get(sk));
+		tcp_cwnd_restart(tp, dst);
 
 	tp->lsndtime = now;
 
@@ -140,6 +143,8 @@
 	 */
 	if ((u32)(now - tp->ack.lrcvtime) < tp->ack.ato)
 		tp->ack.pingpong = 1;
+
+	dst_release(dst);
 }
 
 static __inline__ void tcp_event_ack_sent(struct sock *sk)
@@ -668,7 +673,7 @@
 unsigned int tcp_current_mss(struct sock *sk, int large)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct dst_entry *dst = __sk_dst_get(sk);
+	struct dst_entry *dst = sk_dst_get(sk);
 	unsigned int do_large, mss_now;
 
 	mss_now = tp->mss_cache_std;
@@ -679,6 +684,8 @@
 			mss_now = __tcp_sync_mss(sk, dst, mtu);
 	}
 
+	dst_release(dst);
+
 	do_large = (large &&
 		    (sk->sk_route_caps & NETIF_F_TSO) &&
 		    !tp->urg_mode);
@@ -1417,7 +1424,7 @@
  */ 
 static inline void tcp_connect_init(struct sock *sk)
 {
-	struct dst_entry *dst = __sk_dst_get(sk);
+	struct dst_entry *dst = sk_dst_get(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	/* We'll fix this up when we get a response from the other end.
@@ -1460,6 +1467,8 @@
 	tp->rto = TCP_TIMEOUT_INIT;
 	tp->retransmits = 0;
 	tcp_clear_retrans(tp);
+
+	dst_release(dst);
 }
 
 /*

ChangeSet@1.2336, 2005-01-15 15:47:23+09:00, yoshfuji@linux-ipv6.org
 [NET] Introduce dst_check() to check if dst is still up-to-date.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/dst.h b/include/net/dst.h
--- a/include/net/dst.h	2005-01-15 15:54:20 +09:00
+++ b/include/net/dst.h	2005-01-15 15:54:20 +09:00
@@ -129,6 +129,14 @@
 	return dst_metric(dst, RTAX_LOCK) & (1<<metric);
 }
 
+static inline struct dst_entry *
+dst_check(struct dst_entry *dst, u32 cookie)
+{
+	if (!dst || !dst->obsolete)
+		return NULL;
+	return dst->ops->check(dst, cookie);
+}
+
 static inline void dst_hold(struct dst_entry * dst)
 {
 	atomic_inc(&dst->__refcnt);
diff -Nru a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h	2005-01-15 15:54:20 +09:00
+++ b/include/net/sock.h	2005-01-15 15:54:20 +09:00
@@ -975,7 +975,7 @@
 {
 	struct dst_entry *dst = sk->sk_dst_cache;
 
-	if (dst && dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
+	if (dst_check(dst, cookie) == NULL) {
 		sk->sk_dst_cache = NULL;
 		return NULL;
 	}
@@ -988,7 +988,7 @@
 {
 	struct dst_entry *dst = sk_dst_get(sk);
 
-	if (dst && dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
+	if (dst_check(dst, cookie) == NULL) {
 		sk_dst_reset(sk);
 		return NULL;
 	}
diff -Nru a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
--- a/net/ipv6/ip6_tunnel.c	2005-01-15 15:54:20 +09:00
+++ b/net/ipv6/ip6_tunnel.c	2005-01-15 15:54:20 +09:00
@@ -91,8 +91,7 @@
 {
 	struct dst_entry *dst = t->dst_cache;
 
-	if (dst && dst->obsolete && 
-	    dst->ops->check(dst, t->dst_cookie) == NULL) {
+	if (dst_check(dst, t->dst_cookie) == NULL) {
 		t->dst_cache = NULL;
 		return NULL;
 	}

ChangeSet@1.2337, 2005-01-15 15:47:35+09:00, yoshfuji@linux-ipv6.org
 [NET] Use sk_dst_check() to hold appropriate lock and refcnt.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h	2005-01-15 15:54:25 +09:00
+++ b/include/net/sock.h	2005-01-15 15:54:25 +09:00
@@ -971,19 +971,6 @@
 }
 
 static inline struct dst_entry *
-__sk_dst_check(struct sock *sk, u32 cookie)
-{
-	struct dst_entry *dst = sk->sk_dst_cache;
-
-	if (dst_check(dst, cookie) == NULL) {
-		sk->sk_dst_cache = NULL;
-		return NULL;
-	}
-
-	return dst;
-}
-
-static inline struct dst_entry *
 sk_dst_check(struct sock *sk, u32 cookie)
 {
 	struct dst_entry *dst = sk_dst_get(sk);
diff -Nru a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
--- a/net/ipv4/ip_output.c	2005-01-15 15:54:25 +09:00
+++ b/net/ipv4/ip_output.c	2005-01-15 15:54:25 +09:00
@@ -310,7 +310,7 @@
 		goto packet_routed;
 
 	/* Make sure we can route this packet. */
-	rt = (struct rtable *)__sk_dst_check(sk, 0);
+	rt = (struct rtable *)sk_dst_check(sk, 0);
 	if (rt == NULL) {
 		u32 daddr;
 
@@ -337,10 +337,10 @@
 			if (ip_route_output_flow(&rt, &fl, sk, 0))
 				goto no_route;
 		}
-		__sk_dst_set(sk, &rt->u.dst);
+		__sk_dst_set(sk, dst_clone(&rt->u.dst));
 		tcp_v4_setup_caps(sk, &rt->u.dst);
 	}
-	skb->dst = dst_clone(&rt->u.dst);
+	skb->dst = &rt->u.dst;
 
 packet_routed:
 	if (opt && opt->is_strictroute && rt->rt_dst != rt->rt_gateway)
diff -Nru a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c	2005-01-15 15:54:25 +09:00
+++ b/net/ipv4/tcp_ipv4.c	2005-01-15 15:54:25 +09:00
@@ -933,7 +933,7 @@
      	 * There is a small race when the user changes this flag in the
 	 * route, but I think that's acceptable.
 	 */
-	if ((dst = __sk_dst_check(sk, 0)) == NULL)
+	if ((dst = sk_dst_check(sk, 0)) == NULL)
 		return;
 
 	dst->ops->update_pmtu(dst, mtu);
@@ -957,6 +957,8 @@
 		 */
 		tcp_simple_retransmit(sk);
 	} /* else let the usual retransmit timer handle it */
+
+	dst_release(dst);
 }
 
 /*
@@ -1908,13 +1910,15 @@
 int tcp_v4_rebuild_header(struct sock *sk)
 {
 	struct inet_sock *inet = inet_sk(sk);
-	struct rtable *rt = (struct rtable *)__sk_dst_check(sk, 0);
+	struct rtable *rt = (struct rtable *)sk_dst_check(sk, 0);
 	u32 daddr;
 	int err;
 
 	/* Route is OK, nothing to do. */
-	if (rt)
+	if (rt) {
+		dst_release(&rt->u.dst);
 		return 0;
+	}
 
 	/* Reroute. */
 	daddr = inet->daddr;
diff -Nru a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c	2005-01-15 15:54:25 +09:00
+++ b/net/ipv6/tcp_ipv6.c	2005-01-15 15:54:25 +09:00
@@ -782,7 +782,7 @@
 			goto out;
 
 		/* icmp should have updated the destination cache entry */
-		dst = __sk_dst_check(sk, np->dst_cookie);
+		dst = sk_dst_check(sk, np->dst_cookie);
 
 		if (dst == NULL) {
 			struct inet_sock *inet = inet_sk(sk);
@@ -810,8 +810,7 @@
 				goto out;
 			}
 
-		} else
-			dst_hold(dst);
+		}
 
 		if (tp->pmtu_cookie > dst_pmtu(dst)) {
 			__tcp_sync_mss(sk, dst, dst_pmtu(dst));
@@ -1751,7 +1750,7 @@
 	struct dst_entry *dst;
 	struct ipv6_pinfo *np = inet6_sk(sk);
 
-	dst = __sk_dst_check(sk, np->dst_cookie);
+	dst = sk_dst_check(sk, np->dst_cookie);
 
 	if (dst == NULL) {
 		struct inet_sock *inet = inet_sk(sk);
@@ -1792,7 +1791,8 @@
 		sk->sk_route_caps = dst->dev->features &
 			~(NETIF_F_IP_CSUM | NETIF_F_TSO);
 		tcp_sk(sk)->ext2_header_len = dst->header_len;
-	}
+	} else
+		dst_release(dst);
 
 	return 0;
 }
@@ -1823,7 +1823,7 @@
 		final_p = &final;
 	}
 
-	dst = __sk_dst_check(sk, np->dst_cookie);
+	dst = sk_dst_check(sk, np->dst_cookie);
 
 	if (dst == NULL) {
 		int err = ip6_dst_lookup(sk, &dst, &fl);
@@ -1842,13 +1842,13 @@
 			return err;
 		}
 
-		ip6_dst_store(sk, dst, NULL);
+		ip6_dst_store(sk, dst_clone(dst), NULL);
 		sk->sk_route_caps = dst->dev->features &
 			~(NETIF_F_IP_CSUM | NETIF_F_TSO);
 		tcp_sk(sk)->ext2_header_len = dst->header_len;
 	}
 
-	skb->dst = dst_clone(dst);
+	skb->dst = dst;
 
 	/* Restore final destination back after routing done */
 	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);

ChangeSet@1.2338, 2005-01-15 15:47:46+09:00, yoshfuji@linux-ipv6.org
 [NET] Use sk_dst_set() for sk_dst_reset().
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h	2005-01-15 15:54:30 +09:00
+++ b/include/net/sock.h	2005-01-15 15:54:30 +09:00
@@ -952,23 +952,8 @@
 	write_unlock(&sk->sk_dst_lock);
 }
 
-static inline void
-__sk_dst_reset(struct sock *sk)
-{
-	struct dst_entry *old_dst;
-
-	old_dst = sk->sk_dst_cache;
-	sk->sk_dst_cache = NULL;
-	dst_release(old_dst);
-}
-
-static inline void
-sk_dst_reset(struct sock *sk)
-{
-	write_lock(&sk->sk_dst_lock);
-	__sk_dst_reset(sk);
-	write_unlock(&sk->sk_dst_lock);
-}
+#define __sk_dst_reset(_sk)	__sk_dst_set((_sk), NULL)
+#define sk_dst_reset(_sk)	sk_dst_set((_sk), NULL)
 
 static inline struct dst_entry *
 sk_dst_check(struct sock *sk, u32 cookie)

ChangeSet@1.2339, 2005-01-15 15:47:58+09:00, yoshfuji@linux-ipv6.org
 [DECNET] use sk_dst_set() to store sk_dst_cache. Clean up.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/decnet/dn_nsp_out.c b/net/decnet/dn_nsp_out.c
--- a/net/decnet/dn_nsp_out.c	2005-01-15 15:54:34 +09:00
+++ b/net/decnet/dn_nsp_out.c	2005-01-15 15:54:34 +09:00
@@ -78,34 +78,35 @@
 	struct sock *sk = skb->sk;
 	struct dn_scp *scp = DN_SK(sk);
 	struct dst_entry *dst;
-	struct flowi fl;
 
 	skb->h.raw = skb->data;
 	scp->stamp = jiffies;
 
 	dst = sk_dst_check(sk, 0);
-	if (dst) {
-try_again:
-		skb->dst = dst;
-		dst_output(skb);
-		return;
-	}
 
-	memset(&fl, 0, sizeof(fl));
-	fl.oif = sk->sk_bound_dev_if;
-	fl.fld_src = dn_saddr2dn(&scp->addr);
-	fl.fld_dst = dn_saddr2dn(&scp->peer);
-	dn_sk_ports_copy(&fl, scp);
-	fl.proto = DNPROTO_NSP;
-	if (dn_route_output_sock(&sk->sk_dst_cache, &fl, sk, 0) == 0) {
-		dst = sk_dst_get(sk);
+	if (dst == NULL) {
+		struct flowi fl;
+
+		memset(&fl, 0, sizeof(fl));
+		fl.oif = sk->sk_bound_dev_if;
+		fl.fld_src = dn_saddr2dn(&scp->addr);
+		fl.fld_dst = dn_saddr2dn(&scp->peer);
+		dn_sk_ports_copy(&fl, scp);
+		fl.proto = DNPROTO_NSP;
+
+		if (dn_route_output_sock(&dst, &fl, sk, 0)) {
+			sk->sk_err = EHOSTUNREACH;  
+			if (!sock_flag(sk, SOCK_DEAD))
+				sk->sk_state_change(sk);
+			return;
+		}
+
 		sk->sk_route_caps = dst->dev->features;
-		goto try_again;
+		sk_dst_set(sk, dst_clone(dst));
 	}
 
-	sk->sk_err = EHOSTUNREACH;
-	if (!sock_flag(sk, SOCK_DEAD))
-		sk->sk_state_change(sk);
+	skb->dst = dst;
+	dst_output(skb);
 }
 
 

ChangeSet@1.2340, 2005-01-15 15:48:09+09:00, yoshfuji@linux-ipv6.org
 [NET] Use dst_clone() where appropriate.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h	2005-01-15 15:54:39 +09:00
+++ b/include/net/sock.h	2005-01-15 15:54:39 +09:00
@@ -928,8 +928,7 @@
 
 	read_lock(&sk->sk_dst_lock);
 	dst = sk->sk_dst_cache;
-	if (dst)
-		dst_hold(dst);
+	dst_clone(dst);
 	read_unlock(&sk->sk_dst_lock);
 	return dst;
 }

ChangeSet@1.2341, 2005-01-15 15:48:21+09:00, yoshfuji@linux-ipv6.org
 [NET] Hold appropriate lock and refcnt when we do dst_negative_advice().
 
 Migrate dst_negative_advice() to sk_dst_negative_advice(),
 which holds appropriate lock and refcnt.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/dst.h b/include/net/dst.h
--- a/include/net/dst.h	2005-01-15 15:54:43 +09:00
+++ b/include/net/dst.h	2005-01-15 15:54:43 +09:00
@@ -199,11 +199,11 @@
 		neigh_confirm(dst->neighbour);
 }
 
-static inline void dst_negative_advice(struct dst_entry **dst_p)
+static inline struct dst_entry *dst_negative_advice(struct dst_entry *dst)
 {
-	struct dst_entry * dst = *dst_p;
-	if (dst && dst->ops->negative_advice)
-		*dst_p = dst->ops->negative_advice(dst);
+	if (!dst || !dst->ops->negative_advice)
+		return dst;
+	return dst->ops->negative_advice(dst);
 }
 
 static inline void dst_link_failure(struct sk_buff *skb)
diff -Nru a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h	2005-01-15 15:54:43 +09:00
+++ b/include/net/sock.h	2005-01-15 15:54:43 +09:00
@@ -967,6 +967,15 @@
 	return dst;
 }
 
+static inline void sk_dst_negative_advice(struct sock *sk)
+{
+	struct dst_entry *dst = sk_dst_get(sk);
+	if (likely(dst_negative_advice(dst) == NULL))
+		sk_dst_reset(sk);
+	else
+		dst_release(dst);
+}
+
 static inline void sk_charge_skb(struct sock *sk, struct sk_buff *skb)
 {
 	sk->sk_wmem_queued   += skb->truesize;
diff -Nru a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
--- a/net/decnet/af_decnet.c	2005-01-15 15:54:43 +09:00
+++ b/net/decnet/af_decnet.c	2005-01-15 15:54:43 +09:00
@@ -1941,8 +1941,8 @@
 		goto out_err;
 	}
 
-	if ((flags & MSG_TRYHARD) && sk->sk_dst_cache)
-		dst_negative_advice(&sk->sk_dst_cache);
+	if (flags & MSG_TRYHARD)
+		sk_dst_negative_advice(sk);
 
 	mss = scp->segsize_rem;
 	fctype = scp->services_rem & NSP_FC_MASK;
diff -Nru a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
--- a/net/ipv4/tcp_timer.c	2005-01-15 15:54:43 +09:00
+++ b/net/ipv4/tcp_timer.c	2005-01-15 15:54:43 +09:00
@@ -159,7 +159,7 @@
 
 	if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV)) {
 		if (tp->retransmits)
-			dst_negative_advice(&sk->sk_dst_cache);
+			sk_dst_negative_advice(sk);
 		retry_until = tp->syn_retries ? : sysctl_tcp_syn_retries;
 	} else {
 		if (tp->retransmits >= sysctl_tcp_retries1) {
@@ -183,7 +183,7 @@
                            Golden words :-).
 		   */
 
-			dst_negative_advice(&sk->sk_dst_cache);
+			sk_dst_negative_advice(sk);
 		}
 
 		retry_until = sysctl_tcp_retries2;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
