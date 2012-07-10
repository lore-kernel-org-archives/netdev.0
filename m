From: David Miller <davem@davemloft.net>
Subject: [PATCH 03/16] tcp: Maintain dynamic metrics in local cache.
Date: Tue, 10 Jul 2012 08:07:14 -0700 (PDT)
Message-ID: <20120710.080714.2272376193166978850.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38405 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753855Ab2GJPHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 11:07:15 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id BB62A58662D
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 08:07:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Maintain a local hash table of TCP dynamic metrics blobs.

Computed TCP metrics are no longer maintained in the route metrics.

The table uses RCU and an extremely simple hash so that it has low
latency and low overhead.  A simple hash is legitimate because we only
make metrics blobs for fully established connections.

Some tweaking of the default hash table sizes, metric timeouts, and
the hash chain length limit certainly could use some tweaking.  But
the basic design seems sound.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/tcp.h      |    1 +
 net/ipv4/tcp.c         |    2 +
 net/ipv4/tcp_metrics.c |  517 +++++++++++++++++++++++++++++++++++++++---------
 3 files changed, 427 insertions(+), 93 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5478356..0900d63 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -389,6 +389,7 @@ extern void tcp_enter_loss(struct sock *sk, int how);
 extern void tcp_clear_retrans(struct tcp_sock *tp);
 extern void tcp_update_metrics(struct sock *sk);
 extern void tcp_init_metrics(struct sock *sk);
+extern void tcp_metrics_init(void);
 extern bool tcp_peer_is_proven(struct request_sock *req, struct dst_entry *dst);
 extern void tcp_disable_fack(struct tcp_sock *tp);
 extern void tcp_close(struct sock *sk, long timeout);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3ba605f..29aa0c8 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3563,6 +3563,8 @@ void __init tcp_init(void)
 	pr_info("Hash tables configured (established %u bind %u)\n",
 		tcp_hashinfo.ehash_mask + 1, tcp_hashinfo.bhash_size);
 
+	tcp_metrics_init();
+
 	tcp_register_congestion_control(&tcp_reno);
 
 	memset(&tcp_secret_one.secrets[0], 0, sizeof(tcp_secret_one.secrets));
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 9afe703..286af75 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -1,134 +1,414 @@
+#include <linux/rcupdate.h>
+#include <linux/spinlock.h>
+#include <linux/jiffies.h>
+#include <linux/bootmem.h>
 #include <linux/module.h>
 #include <linux/cache.h>
+#include <linux/slab.h>
+#include <linux/init.h>
 #include <linux/tcp.h>
 
 #include <net/inet_connection_sock.h>
 #include <net/request_sock.h>
+#include <net/inetpeer.h>
 #include <net/sock.h>
 #include <net/dst.h>
 #include <net/tcp.h>
 
 int sysctl_tcp_nometrics_save __read_mostly;
 
+enum tcp_metric_index {
+	TCP_METRIC_RTT,
+	TCP_METRIC_RTTVAR,
+	TCP_METRIC_SSTHRESH,
+	TCP_METRIC_CWND,
+	TCP_METRIC_REORDERING,
+
+	/* Always last.  */
+	TCP_METRIC_MAX,
+};
+
+struct tcp_metrics_block {
+	struct tcp_metrics_block __rcu	*tcpm_next;
+	struct inetpeer_addr		tcpm_addr;
+	unsigned long			tcpm_stamp;
+	u32				tcpm_lock;
+	u32				tcpm_vals[TCP_METRIC_MAX];
+};
+
+static bool tcp_metric_locked(struct tcp_metrics_block *tm,
+			      enum tcp_metric_index idx)
+{
+	return tm->tcpm_lock & (1 << idx);
+}
+
+static u32 tcp_metric_get(struct tcp_metrics_block *tm,
+			  enum tcp_metric_index idx)
+{
+	return tm->tcpm_vals[idx];
+}
+
+static u32 tcp_metric_get_jiffies(struct tcp_metrics_block *tm,
+				  enum tcp_metric_index idx)
+{
+	return msecs_to_jiffies(tm->tcpm_vals[idx]);
+}
+
+static void tcp_metric_set(struct tcp_metrics_block *tm,
+			   enum tcp_metric_index idx,
+			   u32 val)
+{
+	tm->tcpm_vals[idx] = val;
+}
+
+static void tcp_metric_set_msecs(struct tcp_metrics_block *tm,
+				 enum tcp_metric_index idx,
+				 u32 val)
+{
+	tm->tcpm_vals[idx] = jiffies_to_msecs(val);
+}
+
+static bool addr_same(const struct inetpeer_addr *a,
+		      const struct inetpeer_addr *b)
+{
+	int i, n;
+
+	if (a->family != b->family)
+		return false;
+	n = (a->family == AF_INET ? 1 : 4);
+	for (i = 0; i < n; i++) {
+		if (a->addr.a6[i] != b->addr.a6[i])
+			return false;
+	}
+	return true;
+}
+
+struct tcpm_hash_bucket {
+	struct tcp_metrics_block __rcu	*chain;
+};
+
+static struct tcpm_hash_bucket *tcp_metrics_hash __read_mostly;
+static unsigned int tcp_metrics_hash_mask __read_mostly;
+
+static DEFINE_SPINLOCK(tcp_metrics_lock);
+
+static void tcpm_suck_dst(struct tcp_metrics_block *tm, struct dst_entry *dst)
+{
+	u32 val;
+
+	val = 0;
+	if (dst_metric_locked(dst, RTAX_RTT))
+		val |= 1 << TCP_METRIC_RTT;
+	if (dst_metric_locked(dst, RTAX_RTTVAR))
+		val |= 1 << TCP_METRIC_RTTVAR;
+	if (dst_metric_locked(dst, RTAX_SSTHRESH))
+		val |= 1 << TCP_METRIC_SSTHRESH;
+	if (dst_metric_locked(dst, RTAX_CWND))
+		val |= 1 << TCP_METRIC_CWND;
+	if (dst_metric_locked(dst, RTAX_REORDERING))
+		val |= 1 << TCP_METRIC_REORDERING;
+	tm->tcpm_lock = val;
+
+	tm->tcpm_vals[TCP_METRIC_RTT] = dst_metric_raw(dst, RTAX_RTT);
+	tm->tcpm_vals[TCP_METRIC_RTTVAR] = dst_metric_raw(dst, RTAX_RTTVAR);
+	tm->tcpm_vals[TCP_METRIC_SSTHRESH] = dst_metric_raw(dst, RTAX_SSTHRESH);
+	tm->tcpm_vals[TCP_METRIC_CWND] = dst_metric_raw(dst, RTAX_CWND);
+	tm->tcpm_vals[TCP_METRIC_REORDERING] = dst_metric_raw(dst, RTAX_REORDERING);
+}
+
+static struct tcp_metrics_block *tcpm_new(struct dst_entry *dst,
+					  struct inetpeer_addr *addr,
+					  unsigned int hash,
+					  bool reclaim)
+{
+	struct tcp_metrics_block *tm;
+
+	spin_lock_bh(&tcp_metrics_lock);
+	if (unlikely(reclaim)) {
+		struct tcp_metrics_block *oldest;
+
+		oldest = rcu_dereference(tcp_metrics_hash[hash].chain);
+		for (tm = rcu_dereference(oldest->tcpm_next); tm;
+		     tm = rcu_dereference(tm->tcpm_next)) {
+			if (time_before(tm->tcpm_stamp, oldest->tcpm_stamp))
+				oldest = tm;
+		}
+		tm = oldest;
+	} else {
+		tm = kmalloc(sizeof(*tm), GFP_ATOMIC);
+		if (!tm)
+			goto out_unlock;
+	}
+	tm->tcpm_addr = *addr;
+	tm->tcpm_stamp = jiffies;
+
+	tcpm_suck_dst(tm, dst);
+
+	if (likely(!reclaim)) {
+		tm->tcpm_next = tcp_metrics_hash[hash].chain;
+		rcu_assign_pointer(tcp_metrics_hash[hash].chain, tm);
+	}
+
+out_unlock:
+	spin_unlock_bh(&tcp_metrics_lock);
+	return tm;
+}
+
+#define TCP_METRICS_TIMEOUT		(60 * 60 * HZ)
+
+static void tcpm_check_stamp(struct tcp_metrics_block *tm, struct dst_entry *dst)
+{
+	if (tm && unlikely(time_after(jiffies, tm->tcpm_stamp + TCP_METRICS_TIMEOUT)))
+		tcpm_suck_dst(tm, dst);
+}
+
+#define TCP_METRICS_RECLAIM_DEPTH	5
+#define TCP_METRICS_RECLAIM_PTR		(struct tcp_metrics_block *) 0x1UL
+
+static struct tcp_metrics_block *__tcp_get_metrics(const struct inetpeer_addr *addr,
+						   unsigned int hash)
+{
+	struct tcp_metrics_block *tm;
+	int depth = 0;
+
+	for (tm = rcu_dereference(tcp_metrics_hash[hash].chain); tm;
+	     tm = rcu_dereference(tm->tcpm_next)) {
+		if (addr_same(&tm->tcpm_addr, addr))
+			break;
+		depth++;
+	}
+	return (tm ? tm : (depth > TCP_METRICS_RECLAIM_DEPTH ?
+			   TCP_METRICS_RECLAIM_PTR :
+			   NULL));
+}
+
+static struct tcp_metrics_block *__tcp_get_metrics_req(struct request_sock *req,
+						       struct dst_entry *dst)
+{
+	struct tcp_metrics_block *tm;
+	struct inetpeer_addr addr;
+	unsigned int hash;
+
+	addr.family = req->rsk_ops->family;
+	switch (addr.family) {
+	case AF_INET:
+		hash = addr.addr.a4 = inet_rsk(req)->rmt_addr;
+		break;
+	case AF_INET6:
+		*(struct in6_addr *)addr.addr.a6 = inet6_rsk(req)->rmt_addr;
+		hash = (addr.addr.a6[0] ^
+			addr.addr.a6[1] ^
+			addr.addr.a6[2] ^
+			addr.addr.a6[3]);
+		break;
+	default:
+		return NULL;
+	}
+
+	hash ^= (hash >> 24) ^ (hash >> 16) ^ (hash >> 8);
+	hash &= tcp_metrics_hash_mask;
+
+	for (tm = rcu_dereference(tcp_metrics_hash[hash].chain); tm;
+	     tm = rcu_dereference(tm->tcpm_next)) {
+		if (addr_same(&tm->tcpm_addr, &addr))
+			break;
+	}
+	tcpm_check_stamp(tm, dst);
+	return tm;
+}
+
+static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
+						 struct dst_entry *dst,
+						 bool create)
+{
+	struct tcp_metrics_block *tm;
+	struct inetpeer_addr addr;
+	unsigned int hash;
+	bool reclaim;
+
+	addr.family = sk->sk_family;
+	switch (addr.family) {
+	case AF_INET:
+		hash = addr.addr.a4 = inet_sk(sk)->inet_daddr;
+		break;
+	case AF_INET6:
+		*(struct in6_addr *)addr.addr.a6 = inet6_sk(sk)->daddr;
+		hash = (addr.addr.a6[0] ^
+			addr.addr.a6[1] ^
+			addr.addr.a6[2] ^
+			addr.addr.a6[3]);
+		break;
+	default:
+		return NULL;
+	}
+
+	hash ^= (hash >> 24) ^ (hash >> 16) ^ (hash >> 8);
+	hash &= tcp_metrics_hash_mask;
+
+	tm = __tcp_get_metrics(&addr, hash);
+	reclaim = false;
+	if (tm == TCP_METRICS_RECLAIM_PTR) {
+		reclaim = true;
+		tm = NULL;
+	}
+	if (!tm && create)
+		tm = tcpm_new(dst, &addr, hash, reclaim);
+	else
+		tcpm_check_stamp(tm, dst);
+
+	return tm;
+}
+
 /* Save metrics learned by this TCP session.  This function is called
  * only, when TCP finishes successfully i.e. when it enters TIME-WAIT
  * or goes from LAST-ACK to CLOSE.
  */
 void tcp_update_metrics(struct sock *sk)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
+	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct dst_entry *dst = __sk_dst_get(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct tcp_metrics_block *tm;
+	unsigned long rtt;
+	u32 val;
+	int m;
 
-	if (sysctl_tcp_nometrics_save)
+	if (sysctl_tcp_nometrics_save || !dst)
 		return;
 
-	if (dst && (dst->flags & DST_HOST)) {
-		const struct inet_connection_sock *icsk = inet_csk(sk);
-		int m;
-		unsigned long rtt;
-
+	if (dst->flags & DST_HOST)
 		dst_confirm(dst);
 
-		if (icsk->icsk_backoff || !tp->srtt) {
-			/* This session failed to estimate rtt. Why?
-			 * Probably, no packets returned in time.
-			 * Reset our results.
-			 */
-			if (!(dst_metric_locked(dst, RTAX_RTT)))
-				dst_metric_set(dst, RTAX_RTT, 0);
-			return;
-		}
+	rcu_read_lock();
+	if (icsk->icsk_backoff || !tp->srtt) {
+		/* This session failed to estimate rtt. Why?
+		 * Probably, no packets returned in time.  Reset our
+		 * results.
+		 */
+		tm = tcp_get_metrics(sk, dst, false);
+		if (tm && !tcp_metric_locked(tm, TCP_METRIC_RTT))
+			tcp_metric_set(tm, TCP_METRIC_RTT, 0);
+		goto out_unlock;
+	} else
+		tm = tcp_get_metrics(sk, dst, true);
 
-		rtt = dst_metric_rtt(dst, RTAX_RTT);
-		m = rtt - tp->srtt;
+	if (!tm)
+		goto out_unlock;
 
-		/* If newly calculated rtt larger than stored one,
-		 * store new one. Otherwise, use EWMA. Remember,
-		 * rtt overestimation is always better than underestimation.
-		 */
-		if (!(dst_metric_locked(dst, RTAX_RTT))) {
-			if (m <= 0)
-				set_dst_metric_rtt(dst, RTAX_RTT, tp->srtt);
-			else
-				set_dst_metric_rtt(dst, RTAX_RTT, rtt - (m >> 3));
-		}
+	rtt = tcp_metric_get_jiffies(tm, TCP_METRIC_RTT);
+	m = rtt - tp->srtt;
+
+	/* If newly calculated rtt larger than stored one, store new
+	 * one. Otherwise, use EWMA. Remember, rtt overestimation is
+	 * always better than underestimation.
+	 */
+	if (!tcp_metric_locked(tm, TCP_METRIC_RTT)) {
+		if (m <= 0)
+			rtt = tp->srtt;
+		else
+			rtt -= (m >> 3);
+		tcp_metric_set_msecs(tm, TCP_METRIC_RTT, rtt);
+	}
 
-		if (!(dst_metric_locked(dst, RTAX_RTTVAR))) {
-			unsigned long var;
-			if (m < 0)
-				m = -m;
+	if (!tcp_metric_locked(tm, TCP_METRIC_RTTVAR)) {
+		unsigned long var;
 
-			/* Scale deviation to rttvar fixed point */
-			m >>= 1;
-			if (m < tp->mdev)
-				m = tp->mdev;
+		if (m < 0)
+			m = -m;
 
-			var = dst_metric_rtt(dst, RTAX_RTTVAR);
-			if (m >= var)
-				var = m;
-			else
-				var -= (var - m) >> 2;
+		/* Scale deviation to rttvar fixed point */
+		m >>= 1;
+		if (m < tp->mdev)
+			m = tp->mdev;
 
-			set_dst_metric_rtt(dst, RTAX_RTTVAR, var);
-		}
+		var = tcp_metric_get_jiffies(tm, TCP_METRIC_RTTVAR);
+		if (m >= var)
+			var = m;
+		else
+			var -= (var - m) >> 2;
 
-		if (tcp_in_initial_slowstart(tp)) {
-			/* Slow start still did not finish. */
-			if (dst_metric(dst, RTAX_SSTHRESH) &&
-			    !dst_metric_locked(dst, RTAX_SSTHRESH) &&
-			    (tp->snd_cwnd >> 1) > dst_metric(dst, RTAX_SSTHRESH))
-				dst_metric_set(dst, RTAX_SSTHRESH, tp->snd_cwnd >> 1);
-			if (!dst_metric_locked(dst, RTAX_CWND) &&
-			    tp->snd_cwnd > dst_metric(dst, RTAX_CWND))
-				dst_metric_set(dst, RTAX_CWND, tp->snd_cwnd);
-		} else if (tp->snd_cwnd > tp->snd_ssthresh &&
-			   icsk->icsk_ca_state == TCP_CA_Open) {
-			/* Cong. avoidance phase, cwnd is reliable. */
-			if (!dst_metric_locked(dst, RTAX_SSTHRESH))
-				dst_metric_set(dst, RTAX_SSTHRESH,
-					       max(tp->snd_cwnd >> 1, tp->snd_ssthresh));
-			if (!dst_metric_locked(dst, RTAX_CWND))
-				dst_metric_set(dst, RTAX_CWND,
-					       (dst_metric(dst, RTAX_CWND) +
-						tp->snd_cwnd) >> 1);
-		} else {
-			/* Else slow start did not finish, cwnd is non-sense,
-			   ssthresh may be also invalid.
-			 */
-			if (!dst_metric_locked(dst, RTAX_CWND))
-				dst_metric_set(dst, RTAX_CWND,
-					       (dst_metric(dst, RTAX_CWND) +
-						tp->snd_ssthresh) >> 1);
-			if (dst_metric(dst, RTAX_SSTHRESH) &&
-			    !dst_metric_locked(dst, RTAX_SSTHRESH) &&
-			    tp->snd_ssthresh > dst_metric(dst, RTAX_SSTHRESH))
-				dst_metric_set(dst, RTAX_SSTHRESH, tp->snd_ssthresh);
-		}
+		tcp_metric_set_msecs(tm, TCP_METRIC_RTTVAR, var);
+	}
 
-		if (!dst_metric_locked(dst, RTAX_REORDERING)) {
-			if (dst_metric(dst, RTAX_REORDERING) < tp->reordering &&
+	if (tcp_in_initial_slowstart(tp)) {
+		/* Slow start still did not finish. */
+		if (!tcp_metric_locked(tm, TCP_METRIC_SSTHRESH)) {
+			val = tcp_metric_get(tm, TCP_METRIC_SSTHRESH);
+			if (val && (tp->snd_cwnd >> 1) > val)
+				tcp_metric_set(tm, TCP_METRIC_SSTHRESH,
+					       tp->snd_cwnd >> 1);
+		}
+		if (!tcp_metric_locked(tm, TCP_METRIC_CWND)) {
+			val = tcp_metric_get(tm, TCP_METRIC_CWND);
+			if (tp->snd_cwnd > val)
+				tcp_metric_set(tm, TCP_METRIC_CWND,
+					       tp->snd_cwnd);
+		}
+	} else if (tp->snd_cwnd > tp->snd_ssthresh &&
+		   icsk->icsk_ca_state == TCP_CA_Open) {
+		/* Cong. avoidance phase, cwnd is reliable. */
+		if (!tcp_metric_locked(tm, TCP_METRIC_SSTHRESH))
+			tcp_metric_set(tm, TCP_METRIC_SSTHRESH,
+				       max(tp->snd_cwnd >> 1, tp->snd_ssthresh));
+		if (!tcp_metric_locked(tm, TCP_METRIC_CWND)) {
+			val = tcp_metric_get(tm, TCP_METRIC_CWND);
+			tcp_metric_set(tm, RTAX_CWND, (val + tp->snd_cwnd) >> 1);
+		}
+	} else {
+		/* Else slow start did not finish, cwnd is non-sense,
+		 * ssthresh may be also invalid.
+		 */
+		if (!tcp_metric_locked(tm, TCP_METRIC_CWND)) {
+			val = tcp_metric_get(tm, TCP_METRIC_CWND);
+			tcp_metric_set(tm, TCP_METRIC_CWND,
+				       (val + tp->snd_ssthresh) >> 1);
+		}
+		if (!tcp_metric_locked(tm, TCP_METRIC_SSTHRESH)) {
+			val = tcp_metric_get(tm, TCP_METRIC_SSTHRESH);
+			if (val && tp->snd_ssthresh > val)
+				tcp_metric_set(tm, TCP_METRIC_SSTHRESH,
+					       tp->snd_ssthresh);
+		}
+		if (!tcp_metric_locked(tm, TCP_METRIC_REORDERING)) {
+			val = tcp_metric_get(tm, TCP_METRIC_REORDERING);
+			if (val < tp->reordering &&
 			    tp->reordering != sysctl_tcp_reordering)
-				dst_metric_set(dst, RTAX_REORDERING, tp->reordering);
+				tcp_metric_set(tm, TCP_METRIC_REORDERING,
+					       tp->reordering);
 		}
 	}
+	tm->tcpm_stamp = jiffies;
+out_unlock:
+	rcu_read_unlock();
 }
 
 /* Initialize metrics on socket. */
 
 void tcp_init_metrics(struct sock *sk)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
 	struct dst_entry *dst = __sk_dst_get(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct tcp_metrics_block *tm;
+	u32 val;
 
 	if (dst == NULL)
 		goto reset;
 
 	dst_confirm(dst);
 
-	if (dst_metric_locked(dst, RTAX_CWND))
-		tp->snd_cwnd_clamp = dst_metric(dst, RTAX_CWND);
-	if (dst_metric(dst, RTAX_SSTHRESH)) {
-		tp->snd_ssthresh = dst_metric(dst, RTAX_SSTHRESH);
+	rcu_read_lock();
+	tm = tcp_get_metrics(sk, dst, true);
+	if (!tm) {
+		rcu_read_unlock();
+		goto reset;
+	}
+
+	if (tcp_metric_locked(tm, TCP_METRIC_CWND))
+		tp->snd_cwnd_clamp = tcp_metric_get(tm, TCP_METRIC_CWND);
+
+	val = tcp_metric_get(tm, TCP_METRIC_SSTHRESH);
+	if (val) {
+		tp->snd_ssthresh = val;
 		if (tp->snd_ssthresh > tp->snd_cwnd_clamp)
 			tp->snd_ssthresh = tp->snd_cwnd_clamp;
 	} else {
@@ -137,16 +417,18 @@ void tcp_init_metrics(struct sock *sk)
 		 */
 		tp->snd_ssthresh = TCP_INFINITE_SSTHRESH;
 	}
-	if (dst_metric(dst, RTAX_REORDERING) &&
-	    tp->reordering != dst_metric(dst, RTAX_REORDERING)) {
+	val = tcp_metric_get(tm, TCP_METRIC_REORDERING);
+	if (val && tp->reordering != val) {
 		tcp_disable_fack(tp);
 		tcp_disable_early_retrans(tp);
-		tp->reordering = dst_metric(dst, RTAX_REORDERING);
+		tp->reordering = val;
 	}
 
-	if (dst_metric(dst, RTAX_RTT) == 0 || tp->srtt == 0)
+	val = tcp_metric_get(tm, TCP_METRIC_RTT);
+	if (val == 0 || tp->srtt == 0) {
+		rcu_read_unlock();
 		goto reset;
-
+	}
 	/* Initial rtt is determined from SYN,SYN-ACK.
 	 * The segment is small and rtt may appear much
 	 * less than real one. Use per-dst memory
@@ -161,14 +443,18 @@ void tcp_init_metrics(struct sock *sk)
 	 * to low value, and then abruptly stops to do it and starts to delay
 	 * ACKs, wait for troubles.
 	 */
-	if (dst_metric_rtt(dst, RTAX_RTT) > tp->srtt) {
-		tp->srtt = dst_metric_rtt(dst, RTAX_RTT);
+	val = msecs_to_jiffies(val);
+	if (val > tp->srtt) {
+		tp->srtt = val;
 		tp->rtt_seq = tp->snd_nxt;
 	}
-	if (dst_metric_rtt(dst, RTAX_RTTVAR) > tp->mdev) {
-		tp->mdev = dst_metric_rtt(dst, RTAX_RTTVAR);
+	val = tcp_metric_get_jiffies(tm, TCP_METRIC_RTTVAR);
+	if (val > tp->mdev) {
+		tp->mdev = val;
 		tp->mdev_max = tp->rttvar = max(tp->mdev, tcp_rto_min(sk));
 	}
+	rcu_read_unlock();
+
 	tcp_set_rto(sk);
 reset:
 	if (tp->srtt == 0) {
@@ -195,8 +481,53 @@ reset:
 
 bool tcp_peer_is_proven(struct request_sock *req, struct dst_entry *dst)
 {
+	struct tcp_metrics_block *tm;
+	bool ret;
+
 	if (!dst)
 		return false;
-	return dst_metric(dst, RTAX_RTT) ? true : false;
+
+	rcu_read_lock();
+	tm = __tcp_get_metrics_req(req, dst);
+	if (tm && tcp_metric_get(tm, TCP_METRIC_RTT))
+		ret = true;
+	else
+		ret = false;
+	rcu_read_unlock();
+
+	return ret;
 }
 EXPORT_SYMBOL_GPL(tcp_peer_is_proven);
+
+static __initdata unsigned long tcpmhash_entries;
+static int __init set_tcpmhash_entries(char *str)
+{
+	ssize_t ret;
+
+	if (!str)
+		return 0;
+
+	ret = kstrtoul(str, 0, &tcpmhash_entries);
+	if (ret)
+		return 0;
+
+	return 1;
+}
+__setup("tcpmhash_entries=", set_tcpmhash_entries);
+
+void __init tcp_metrics_init(void)
+{
+	tcp_metrics_hash = alloc_large_system_hash("TCP Metrics",
+						   sizeof(struct tcpm_hash_bucket),
+						   tcpmhash_entries,
+						   (totalram_pages >= 128 * 1024) ?
+						   18 : 20,
+						   0,
+						   NULL,
+						   &tcp_metrics_hash_mask,
+						   0,
+						   tcpmhash_entries ? 0 : 64 * 1024);
+
+	memset(tcp_metrics_hash, 0,
+	       (tcp_metrics_hash_mask + 1) * sizeof(struct tcpm_hash_bucket));
+}
-- 
1.7.10.4
