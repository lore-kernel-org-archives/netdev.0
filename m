From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH RFC] tcp: use seqlock for all cached tcp_metrics
Date: Sun, 22 Jul 2012 12:44:28 +0300
Message-ID: <1342950268-2380-1-git-send-email-ja@ssi.bg>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:47782 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751103Ab2GVJhL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jul 2012 05:37:11 -0400
Received: from ja.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.14.4/8.14.4) with ESMTP id q6M9ifFq002410
	for <netdev@vger.kernel.org>; Sun, 22 Jul 2012 12:44:41 +0300
Received: (from root@localhost)
	by ja.ssi.bg (8.14.4/8.14.4/Submit) id q6M9ifOC002406
	for netdev@vger.kernel.org; Sun, 22 Jul 2012 12:44:41 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	The ability to reclaim existing cache entries
requires metrics to be accessed with additional seqlock.
fastopen_cache tried to provide such locking for its values
but there is always the risk to access reclaimed entry.

	So, we add global metrics_seqlock and two macros to
access metrics for read/write purposes. The macros are not
checkpatch friendly but with capital letters and no gotos in
the code we avoid additional level of indentation.

	We provide access structure, initialized according to
the socket type with information about the hash bucket, dst, etc.

	We also fix some problems:

- tcpm_stamp was not updated in tcpm_check_stamp when tcpm_suck_dst
was called, move the update into tcpm_suck_dst, so that we do not
call it infinitely on every next cache hit

- in tcp_tw_remember_stamp we incorrectly checked tw instead of tm,
it can lead to oops if the cached entry is not found

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

	Open questions:

- is it safe to upgrade a seqlock reader to writer? May be
it is a good idea to provide such method seqlock_is_upgraded
in include/linux/seqlock.h. In our case it can safe 1 of the 3
lookups that we do in write mode.

 net/ipv4/tcp_metrics.c |  471 +++++++++++++++++++++++++++++-------------------
 1 files changed, 287 insertions(+), 184 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 992f1bf..6c623cc 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -49,6 +49,11 @@ struct tcp_metrics_block {
 	struct tcp_fastopen_metrics	tcpm_fastopen;
 };
 
+#define TCP_METRICS_TIMEOUT		(60 * 60 * HZ)
+#define TCP_METRICS_RECLAIM_DEPTH	5
+
+static DEFINE_SEQLOCK(metrics_seqlock);
+
 static bool tcp_metric_locked(struct tcp_metrics_block *tm,
 			      enum tcp_metric_index idx)
 {
@@ -101,12 +106,19 @@ struct tcpm_hash_bucket {
 	struct tcp_metrics_block __rcu	*chain;
 };
 
-static DEFINE_SPINLOCK(tcp_metrics_lock);
+static inline struct tcpm_hash_bucket *tcpm_hash_bucket_get(struct net *net,
+							    unsigned int hash)
+{
+	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
+	return net->ipv4.tcp_metrics_hash + hash;
+}
 
 static void tcpm_suck_dst(struct tcp_metrics_block *tm, struct dst_entry *dst)
 {
 	u32 val;
 
+	tm->tcpm_stamp = jiffies;
+
 	val = 0;
 	if (dst_metric_locked(dst, RTAX_RTT))
 		val |= 1 << TCP_METRIC_RTT;
@@ -132,20 +144,111 @@ static void tcpm_suck_dst(struct tcp_metrics_block *tm, struct dst_entry *dst)
 	tm->tcpm_fastopen.cookie.len = 0;
 }
 
-static struct tcp_metrics_block *tcpm_new(struct dst_entry *dst,
-					  struct inetpeer_addr *addr,
-					  unsigned int hash,
-					  bool reclaim)
+/* Read if present */
+#define TCP_METRIC_MODE_READ		0x00
+
+/* Can refresh metrics from dst if expired */
+#define TCP_METRIC_MODE_REFRESH		0x01
+
+/* Write access is required/acquired */
+#define TCP_METRIC_MODE_WRITE		0x02
+
+/* Can create new or reclaim existing entry */
+#define TCP_METRIC_MODE_CREATE		0x04
+
+/* Writer needs exclusive access */
+#define TCP_METRIC_MODE_SET		(TCP_METRIC_MODE_REFRESH | \
+					 TCP_METRIC_MODE_WRITE | \
+					 TCP_METRIC_MODE_CREATE)
+
+/* Writer needs exclusive access only if entry is already cached */
+#define TCP_METRIC_MODE_UPDATE		(TCP_METRIC_MODE_REFRESH | \
+					 TCP_METRIC_MODE_WRITE)
+
+/* Reader needs up to date metrics only if already cached,
+ * can become writer on refresh
+ */
+#define TCP_METRIC_MODE_GET_CACHED	TCP_METRIC_MODE_REFRESH
+
+/* Reader needs up to date metrics, can become writer on refresh or
+ * reclaim/create
+ */
+#define TCP_METRIC_MODE_GET		(TCP_METRIC_MODE_REFRESH | \
+					 TCP_METRIC_MODE_CREATE)
+
+struct tcp_metrics_access {
+	struct inetpeer_addr		addr;
+	struct tcpm_hash_bucket		*hb;
+	struct dst_entry		*dst;
+	int				mode;
+	unsigned int			seq;
+};
+
+/* Start access for metrics:
+ * - on return tm can be dereferenced only before TCP_METRIC_ACCESS_STOP
+ * - Writers will update before TCP_METRIC_ACCESS_STOP
+ * - Readers should copy values before TCP_METRIC_ACCESS_STOP and
+ * will return values after TCP_METRIC_ACCESS_STOP
+ */
+#define TCP_METRIC_ACCESS_START(a, tm, m)	\
+	do {					\
+		a.mode = (m);			\
+		tm = tcpm_start(&a)
+
+/* Stop accessing the metrics, readers will retry on clash with writer */
+#define TCP_METRIC_ACCESS_STOP(a) } while (unlikely(tcpm_stop(&a)))
+
+/* Start access for metrics under RCU protection
+ * dst: used for refresh, optional, required for TCP_METRIC_MODE_CREATE
+ * Return with locked seqlock in R/W mode depending on TCP_METRIC_MODE_WRITE
+ * Caller should call tcpm_stop in all cases
+ */
+static struct tcp_metrics_block *tcpm_start(struct tcp_metrics_access *a)
 {
+	struct dst_entry *dst = a->dst;
+	struct tcpm_hash_bucket *hb = a->hb;
+	struct inetpeer_addr *addr = &a->addr;
+	int mode = a->mode;
 	struct tcp_metrics_block *tm;
-	struct net *net;
+	int depth;
 
-	spin_lock_bh(&tcp_metrics_lock);
-	net = dev_net(dst->dev);
-	if (unlikely(reclaim)) {
+	if (likely(!(mode & TCP_METRIC_MODE_WRITE)))
+		a->seq = read_seqbegin(&metrics_seqlock);
+	else
+		write_seqlock_bh(&metrics_seqlock);
+
+restart:
+	depth = 0;
+	for (tm = rcu_dereference(hb->chain); tm;
+	     tm = rcu_dereference(tm->tcpm_next)) {
+		if (addr_same(&tm->tcpm_addr, addr))
+			break;
+		depth++;
+	}
+
+	if (tm) {
+		if (mode & TCP_METRIC_MODE_REFRESH &&
+		    unlikely(time_after(jiffies, tm->tcpm_stamp +
+					TCP_METRICS_TIMEOUT)) && dst)
+			goto refresh;
+		return tm;
+	}
+
+	if (!(mode & TCP_METRIC_MODE_CREATE))
+		return NULL;
+	if (!(mode & TCP_METRIC_MODE_WRITE)) {
+		mode |= TCP_METRIC_MODE_WRITE;
+		a->mode = mode;
+		write_seqlock_bh(&metrics_seqlock);
+		/* !seqlock_is_upgraded(&metrics_seqlock, a->seq) ? */
+		if (read_seqretry(&metrics_seqlock, a->seq + 1))
+			goto restart;
+	}
+
+	if (depth > TCP_METRICS_RECLAIM_DEPTH) {
 		struct tcp_metrics_block *oldest;
 
-		oldest = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain);
+		oldest = rcu_dereference(hb->chain);
 		for (tm = rcu_dereference(oldest->tcpm_next); tm;
 		     tm = rcu_dereference(tm->tcpm_next)) {
 			if (time_before(tm->tcpm_stamp, oldest->tcpm_stamp))
@@ -155,165 +258,115 @@ static struct tcp_metrics_block *tcpm_new(struct dst_entry *dst,
 	} else {
 		tm = kmalloc(sizeof(*tm), GFP_ATOMIC);
 		if (!tm)
-			goto out_unlock;
+			return NULL;
+		tm->tcpm_next = hb->chain;
+		rcu_assign_pointer(hb->chain, tm);
 	}
 	tm->tcpm_addr = *addr;
-	tm->tcpm_stamp = jiffies;
 
+reset:
 	tcpm_suck_dst(tm, dst);
-
-	if (likely(!reclaim)) {
-		tm->tcpm_next = net->ipv4.tcp_metrics_hash[hash].chain;
-		rcu_assign_pointer(net->ipv4.tcp_metrics_hash[hash].chain, tm);
-	}
-
-out_unlock:
-	spin_unlock_bh(&tcp_metrics_lock);
 	return tm;
-}
 
-#define TCP_METRICS_TIMEOUT		(60 * 60 * HZ)
-
-static void tcpm_check_stamp(struct tcp_metrics_block *tm, struct dst_entry *dst)
-{
-	if (tm && unlikely(time_after(jiffies, tm->tcpm_stamp + TCP_METRICS_TIMEOUT)))
-		tcpm_suck_dst(tm, dst);
-}
-
-#define TCP_METRICS_RECLAIM_DEPTH	5
-#define TCP_METRICS_RECLAIM_PTR		(struct tcp_metrics_block *) 0x1UL
-
-static struct tcp_metrics_block *tcp_get_encode(struct tcp_metrics_block *tm, int depth)
-{
-	if (tm)
-		return tm;
-	if (depth > TCP_METRICS_RECLAIM_DEPTH)
-		return TCP_METRICS_RECLAIM_PTR;
-	return NULL;
+refresh:
+	if (mode & TCP_METRIC_MODE_WRITE)
+		goto reset;
+	mode |= TCP_METRIC_MODE_WRITE;
+	a->mode = mode;
+	write_seqlock_bh(&metrics_seqlock);
+	/* seqlock_is_upgraded(&metrics_seqlock, a->seq) ? */
+	if (!read_seqretry(&metrics_seqlock, a->seq + 1))
+		goto reset;
+	if (addr_same(&tm->tcpm_addr, addr))
+		goto reset;
+	goto restart;
 }
 
-static struct tcp_metrics_block *__tcp_get_metrics(const struct inetpeer_addr *addr,
-						   struct net *net, unsigned int hash)
+/* Stop Read/Write (0) or retry Read (1) */
+static inline int tcpm_stop(struct tcp_metrics_access *a)
 {
-	struct tcp_metrics_block *tm;
-	int depth = 0;
-
-	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
-	     tm = rcu_dereference(tm->tcpm_next)) {
-		if (addr_same(&tm->tcpm_addr, addr))
-			break;
-		depth++;
-	}
-	return tcp_get_encode(tm, depth);
+	if (likely(!(a->mode & TCP_METRIC_MODE_WRITE)))
+		return read_seqretry(&metrics_seqlock, a->seq);
+	write_sequnlock_bh(&metrics_seqlock);
+	return 0;
 }
 
-static struct tcp_metrics_block *__tcp_get_metrics_req(struct request_sock *req,
-						       struct dst_entry *dst)
+/* Fill access structure from socket req */
+static bool tcpm_access_from_sock_req(struct tcp_metrics_access *a,
+				      struct request_sock *req,
+				      struct dst_entry *dst)
 {
-	struct tcp_metrics_block *tm;
-	struct inetpeer_addr addr;
 	unsigned int hash;
-	struct net *net;
 
-	addr.family = req->rsk_ops->family;
-	switch (addr.family) {
+	a->addr.family = req->rsk_ops->family;
+	switch (a->addr.family) {
 	case AF_INET:
-		addr.addr.a4 = inet_rsk(req)->rmt_addr;
-		hash = (__force unsigned int) addr.addr.a4;
+		a->addr.addr.a4 = inet_rsk(req)->rmt_addr;
+		hash = (__force unsigned int) a->addr.addr.a4;
 		break;
 	case AF_INET6:
-		*(struct in6_addr *)addr.addr.a6 = inet6_rsk(req)->rmt_addr;
+		*(struct in6_addr *)a->addr.addr.a6 = inet6_rsk(req)->rmt_addr;
 		hash = ipv6_addr_hash(&inet6_rsk(req)->rmt_addr);
 		break;
 	default:
-		return NULL;
+		return false;
 	}
 
-	net = dev_net(dst->dev);
-	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
-
-	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
-	     tm = rcu_dereference(tm->tcpm_next)) {
-		if (addr_same(&tm->tcpm_addr, &addr))
-			break;
-	}
-	tcpm_check_stamp(tm, dst);
-	return tm;
+	a->hb = tcpm_hash_bucket_get(dev_net(dst->dev), hash);
+	a->dst = dst;
+	return true;
 }
 
-static struct tcp_metrics_block *__tcp_get_metrics_tw(struct inet_timewait_sock *tw)
+/* Fill access structure from tw socket */
+static bool tcpm_access_from_tw_sock(struct tcp_metrics_access *a,
+				     struct inet_timewait_sock *tw)
 {
 	struct inet6_timewait_sock *tw6;
-	struct tcp_metrics_block *tm;
-	struct inetpeer_addr addr;
 	unsigned int hash;
-	struct net *net;
 
-	addr.family = tw->tw_family;
-	switch (addr.family) {
+	a->addr.family = tw->tw_family;
+	switch (a->addr.family) {
 	case AF_INET:
-		addr.addr.a4 = tw->tw_daddr;
-		hash = (__force unsigned int) addr.addr.a4;
+		a->addr.addr.a4 = tw->tw_daddr;
+		hash = (__force unsigned int) a->addr.addr.a4;
 		break;
 	case AF_INET6:
 		tw6 = inet6_twsk((struct sock *)tw);
-		*(struct in6_addr *)addr.addr.a6 = tw6->tw_v6_daddr;
+		*(struct in6_addr *) a->addr.addr.a6 = tw6->tw_v6_daddr;
 		hash = ipv6_addr_hash(&tw6->tw_v6_daddr);
 		break;
 	default:
-		return NULL;
+		return false;
 	}
 
-	net = twsk_net(tw);
-	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
-
-	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
-	     tm = rcu_dereference(tm->tcpm_next)) {
-		if (addr_same(&tm->tcpm_addr, &addr))
-			break;
-	}
-	return tm;
+	a->hb = tcpm_hash_bucket_get(twsk_net(tw), hash);
+	a->dst = NULL;
+	return true;
 }
 
-static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
-						 struct dst_entry *dst,
-						 bool create)
+/* Fill access structure from normal socket */
+static bool tcpm_access_from_sock(struct tcp_metrics_access *a,
+				  struct sock *sk, struct dst_entry *dst)
 {
-	struct tcp_metrics_block *tm;
-	struct inetpeer_addr addr;
 	unsigned int hash;
-	struct net *net;
-	bool reclaim;
 
-	addr.family = sk->sk_family;
-	switch (addr.family) {
+	a->addr.family = sk->sk_family;
+	switch (a->addr.family) {
 	case AF_INET:
-		addr.addr.a4 = inet_sk(sk)->inet_daddr;
-		hash = (__force unsigned int) addr.addr.a4;
+		a->addr.addr.a4 = inet_sk(sk)->inet_daddr;
+		hash = (__force unsigned int) a->addr.addr.a4;
 		break;
 	case AF_INET6:
-		*(struct in6_addr *)addr.addr.a6 = inet6_sk(sk)->daddr;
+		*(struct in6_addr *) a->addr.addr.a6 = inet6_sk(sk)->daddr;
 		hash = ipv6_addr_hash(&inet6_sk(sk)->daddr);
 		break;
 	default:
-		return NULL;
-	}
-
-	net = dev_net(dst->dev);
-	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
-
-	tm = __tcp_get_metrics(&addr, net, hash);
-	reclaim = false;
-	if (tm == TCP_METRICS_RECLAIM_PTR) {
-		reclaim = true;
-		tm = NULL;
+		return false;
 	}
-	if (!tm && create)
-		tm = tcpm_new(dst, &addr, hash, reclaim);
-	else
-		tcpm_check_stamp(tm, dst);
 
-	return tm;
+	a->hb = tcpm_hash_bucket_get(dev_net(dst->dev), hash);
+	a->dst = dst;
+	return true;
 }
 
 /* Save metrics learned by this TCP session.  This function is called
@@ -325,10 +378,11 @@ void tcp_update_metrics(struct sock *sk)
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct dst_entry *dst = __sk_dst_get(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct tcp_metrics_access a;
 	struct tcp_metrics_block *tm;
 	unsigned long rtt;
 	u32 val;
-	int m;
+	int m, reset_rtt, mode;
 
 	if (sysctl_tcp_nometrics_save || !dst)
 		return;
@@ -336,21 +390,29 @@ void tcp_update_metrics(struct sock *sk)
 	if (dst->flags & DST_HOST)
 		dst_confirm(dst);
 
+	if (!tcpm_access_from_sock(&a, sk, dst))
+		return;
+
+	reset_rtt = 0;
 	rcu_read_lock();
 	if (icsk->icsk_backoff || !tp->srtt) {
 		/* This session failed to estimate rtt. Why?
 		 * Probably, no packets returned in time.  Reset our
 		 * results.
 		 */
-		tm = tcp_get_metrics(sk, dst, false);
-		if (tm && !tcp_metric_locked(tm, TCP_METRIC_RTT))
-			tcp_metric_set(tm, TCP_METRIC_RTT, 0);
-		goto out_unlock;
-	} else
-		tm = tcp_get_metrics(sk, dst, true);
+		reset_rtt = 1;
+	}
 
+	mode = reset_rtt ? TCP_METRIC_MODE_UPDATE : TCP_METRIC_MODE_SET;
+	TCP_METRIC_ACCESS_START(a, tm, mode);
 	if (!tm)
-		goto out_unlock;
+		goto out_stop;
+
+	if (reset_rtt) {
+		if (!tcp_metric_locked(tm, TCP_METRIC_RTT))
+			tcp_metric_set(tm, TCP_METRIC_RTT, 0);
+		goto out_stop;
+	}
 
 	rtt = tcp_metric_get_jiffies(tm, TCP_METRIC_RTT);
 	m = rtt - tp->srtt;
@@ -435,7 +497,9 @@ void tcp_update_metrics(struct sock *sk)
 		}
 	}
 	tm->tcpm_stamp = jiffies;
-out_unlock:
+
+out_stop:;
+	TCP_METRIC_ACCESS_STOP(a);
 	rcu_read_unlock();
 }
 
@@ -445,6 +509,8 @@ void tcp_init_metrics(struct sock *sk)
 {
 	struct dst_entry *dst = __sk_dst_get(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct tcp_metrics_access a;
+	struct tcp_metrics_block copy;
 	struct tcp_metrics_block *tm;
 	u32 val;
 
@@ -453,12 +519,21 @@ void tcp_init_metrics(struct sock *sk)
 
 	dst_confirm(dst);
 
-	rcu_read_lock();
-	tm = tcp_get_metrics(sk, dst, true);
-	if (!tm) {
-		rcu_read_unlock();
+	if (!tcpm_access_from_sock(&a, sk, dst))
 		goto reset;
+
+	rcu_read_lock();
+	TCP_METRIC_ACCESS_START(a, tm, TCP_METRIC_MODE_GET);
+	if (tm) {
+		/* We need only metric values */
+		copy.tcpm_lock = tm->tcpm_lock;
+		memcpy(copy.tcpm_vals, tm->tcpm_vals, sizeof(tm->tcpm_vals));
 	}
+	TCP_METRIC_ACCESS_STOP(a);
+	rcu_read_unlock();
+	if (!tm)
+		goto reset;
+	tm = &copy;
 
 	if (tcp_metric_locked(tm, TCP_METRIC_CWND))
 		tp->snd_cwnd_clamp = tcp_metric_get(tm, TCP_METRIC_CWND);
@@ -482,10 +557,8 @@ void tcp_init_metrics(struct sock *sk)
 	}
 
 	val = tcp_metric_get(tm, TCP_METRIC_RTT);
-	if (val == 0 || tp->srtt == 0) {
-		rcu_read_unlock();
+	if (val == 0 || tp->srtt == 0)
 		goto reset;
-	}
 	/* Initial rtt is determined from SYN,SYN-ACK.
 	 * The segment is small and rtt may appear much
 	 * less than real one. Use per-dst memory
@@ -510,7 +583,6 @@ void tcp_init_metrics(struct sock *sk)
 		tp->mdev = val;
 		tp->mdev_max = tp->rttvar = max(tp->mdev, tcp_rto_min(sk));
 	}
-	rcu_read_unlock();
 
 	tcp_set_rto(sk);
 reset:
@@ -536,30 +608,41 @@ reset:
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
-bool tcp_peer_is_proven(struct request_sock *req, struct dst_entry *dst, bool paws_check)
+bool tcp_peer_is_proven(struct request_sock *req, struct dst_entry *dst,
+			bool paws_check)
 {
+	struct tcp_metrics_access a;
 	struct tcp_metrics_block *tm;
-	bool ret;
+	u32 tcpm_ts_stamp = 0;
+	u32 tcpm_ts = 0;
+	u32 rtt = 0;
+	bool ret = false;
 
-	if (!dst)
-		return false;
+	if (!dst || !tcpm_access_from_sock_req(&a, req, dst))
+		return ret;
 
 	rcu_read_lock();
-	tm = __tcp_get_metrics_req(req, dst);
+	TCP_METRIC_ACCESS_START(a, tm, TCP_METRIC_MODE_GET_CACHED);
+	if (tm) {
+		tcpm_ts_stamp = tm->tcpm_ts_stamp;
+		tcpm_ts = tm->tcpm_ts;
+		rtt = tcp_metric_get(tm, TCP_METRIC_RTT);
+	}
+	TCP_METRIC_ACCESS_STOP(a);
+	rcu_read_unlock();
 	if (paws_check) {
 		if (tm &&
-		    (u32)get_seconds() - tm->tcpm_ts_stamp < TCP_PAWS_MSL &&
-		    (s32)(tm->tcpm_ts - req->ts_recent) > TCP_PAWS_WINDOW)
+		    (u32) get_seconds() - tcpm_ts_stamp < TCP_PAWS_MSL &&
+		    (s32) (tcpm_ts - req->ts_recent) > TCP_PAWS_WINDOW)
 			ret = false;
 		else
 			ret = true;
 	} else {
-		if (tm && tcp_metric_get(tm, TCP_METRIC_RTT) && tm->tcpm_ts_stamp)
+		if (tm && rtt && tcpm_ts_stamp)
 			ret = true;
 		else
 			ret = false;
 	}
-	rcu_read_unlock();
 
 	return ret;
 }
@@ -567,19 +650,29 @@ EXPORT_SYMBOL_GPL(tcp_peer_is_proven);
 
 void tcp_fetch_timewait_stamp(struct sock *sk, struct dst_entry *dst)
 {
+	struct tcp_metrics_access a;
 	struct tcp_metrics_block *tm;
+	u32 tcpm_ts_stamp = 0;
+	u32 tcpm_ts = 0;
 
+	if (!tcpm_access_from_sock(&a, sk, dst))
+		return;
 	rcu_read_lock();
-	tm = tcp_get_metrics(sk, dst, true);
+	TCP_METRIC_ACCESS_START(a, tm, TCP_METRIC_MODE_GET);
+	if (tm) {
+		tcpm_ts_stamp = tm->tcpm_ts_stamp;
+		tcpm_ts = tm->tcpm_ts;
+	}
+	TCP_METRIC_ACCESS_STOP(a);
+	rcu_read_unlock();
 	if (tm) {
 		struct tcp_sock *tp = tcp_sk(sk);
 
-		if ((u32)get_seconds() - tm->tcpm_ts_stamp <= TCP_PAWS_MSL) {
-			tp->rx_opt.ts_recent_stamp = tm->tcpm_ts_stamp;
-			tp->rx_opt.ts_recent = tm->tcpm_ts;
+		if ((u32)get_seconds() - tcpm_ts_stamp <= TCP_PAWS_MSL) {
+			tp->rx_opt.ts_recent_stamp = tcpm_ts_stamp;
+			tp->rx_opt.ts_recent = tcpm_ts;
 		}
 	}
-	rcu_read_unlock();
 }
 EXPORT_SYMBOL_GPL(tcp_fetch_timewait_stamp);
 
@@ -591,37 +684,42 @@ EXPORT_SYMBOL_GPL(tcp_fetch_timewait_stamp);
 bool tcp_remember_stamp(struct sock *sk)
 {
 	struct dst_entry *dst = __sk_dst_get(sk);
+	struct tcp_metrics_access a;
+	struct tcp_metrics_block *tm;
 	bool ret = false;
 
-	if (dst) {
-		struct tcp_metrics_block *tm;
+	if (!dst || !tcpm_access_from_sock(&a, sk, dst))
+		return ret;
 
-		rcu_read_lock();
-		tm = tcp_get_metrics(sk, dst, true);
-		if (tm) {
-			struct tcp_sock *tp = tcp_sk(sk);
+	rcu_read_lock();
+	TCP_METRIC_ACCESS_START(a, tm, TCP_METRIC_MODE_SET);
+	if (tm) {
+		struct tcp_sock *tp = tcp_sk(sk);
 
-			if ((s32)(tm->tcpm_ts - tp->rx_opt.ts_recent) <= 0 ||
-			    ((u32)get_seconds() - tm->tcpm_ts_stamp > TCP_PAWS_MSL &&
-			     tm->tcpm_ts_stamp <= (u32)tp->rx_opt.ts_recent_stamp)) {
-				tm->tcpm_ts_stamp = (u32)tp->rx_opt.ts_recent_stamp;
-				tm->tcpm_ts = tp->rx_opt.ts_recent;
-			}
-			ret = true;
+		if ((s32)(tm->tcpm_ts - tp->rx_opt.ts_recent) <= 0 ||
+		    ((u32)get_seconds() - tm->tcpm_ts_stamp > TCP_PAWS_MSL &&
+		     tm->tcpm_ts_stamp <= (u32)tp->rx_opt.ts_recent_stamp)) {
+			tm->tcpm_ts_stamp = (u32)tp->rx_opt.ts_recent_stamp;
+			tm->tcpm_ts = tp->rx_opt.ts_recent;
 		}
-		rcu_read_unlock();
+		ret = true;
 	}
+	TCP_METRIC_ACCESS_STOP(a);
+	rcu_read_unlock();
 	return ret;
 }
 
 bool tcp_tw_remember_stamp(struct inet_timewait_sock *tw)
 {
+	struct tcp_metrics_access a;
 	struct tcp_metrics_block *tm;
 	bool ret = false;
 
+	if (!tcpm_access_from_tw_sock(&a, tw))
+		return ret;
 	rcu_read_lock();
-	tm = __tcp_get_metrics_tw(tw);
-	if (tw) {
+	TCP_METRIC_ACCESS_START(a, tm, TCP_METRIC_MODE_WRITE);
+	if (tm) {
 		const struct tcp_timewait_sock *tcptw;
 		struct sock *sk = (struct sock *) tw;
 
@@ -634,48 +732,53 @@ bool tcp_tw_remember_stamp(struct inet_timewait_sock *tw)
 		}
 		ret = true;
 	}
+	TCP_METRIC_ACCESS_STOP(a);
 	rcu_read_unlock();
 
 	return ret;
 }
 
-static DEFINE_SEQLOCK(fastopen_seqlock);
-
 void tcp_fastopen_cache_get(struct sock *sk, u16 *mss,
 			    struct tcp_fastopen_cookie *cookie,
 			    int *syn_loss, unsigned long *last_syn_loss)
 {
+	struct tcp_metrics_access a;
 	struct tcp_metrics_block *tm;
+	struct tcp_fastopen_metrics tfom_copy[1], *tfom;
+
+	if (!tcpm_access_from_sock(&a, sk, __sk_dst_get(sk)))
+		return;
 
 	rcu_read_lock();
-	tm = tcp_get_metrics(sk, __sk_dst_get(sk), false);
+	TCP_METRIC_ACCESS_START(a, tm, TCP_METRIC_MODE_GET_CACHED);
+	if (tm)
+		tfom_copy[0] = tm->tcpm_fastopen;
+	TCP_METRIC_ACCESS_STOP(a);
+	rcu_read_unlock();
 	if (tm) {
-		struct tcp_fastopen_metrics *tfom = &tm->tcpm_fastopen;
-		unsigned int seq;
-
-		do {
-			seq = read_seqbegin(&fastopen_seqlock);
-			if (tfom->mss)
-				*mss = tfom->mss;
-			*cookie = tfom->cookie;
-			*syn_loss = tfom->syn_loss;
-			*last_syn_loss = *syn_loss ? tfom->last_syn_loss : 0;
-		} while (read_seqretry(&fastopen_seqlock, seq));
+		tfom = tfom_copy;
+		if (tfom->mss)
+			*mss = tfom->mss;
+		*cookie = tfom->cookie;
+		*syn_loss = tfom->syn_loss;
+		*last_syn_loss = *syn_loss ? tfom->last_syn_loss : 0;
 	}
-	rcu_read_unlock();
 }
 
 void tcp_fastopen_cache_set(struct sock *sk, u16 mss,
 			    struct tcp_fastopen_cookie *cookie, bool syn_lost)
 {
+	struct tcp_metrics_access a;
 	struct tcp_metrics_block *tm;
 
+	if (!tcpm_access_from_sock(&a, sk, __sk_dst_get(sk)))
+		return;
+
 	rcu_read_lock();
-	tm = tcp_get_metrics(sk, __sk_dst_get(sk), true);
+	TCP_METRIC_ACCESS_START(a, tm, TCP_METRIC_MODE_SET);
 	if (tm) {
 		struct tcp_fastopen_metrics *tfom = &tm->tcpm_fastopen;
 
-		write_seqlock_bh(&fastopen_seqlock);
 		tfom->mss = mss;
 		if (cookie->len > 0)
 			tfom->cookie = *cookie;
@@ -684,8 +787,8 @@ void tcp_fastopen_cache_set(struct sock *sk, u16 mss,
 			tfom->last_syn_loss = jiffies;
 		} else
 			tfom->syn_loss = 0;
-		write_sequnlock_bh(&fastopen_seqlock);
 	}
+	TCP_METRIC_ACCESS_STOP(a);
 	rcu_read_unlock();
 }
 
-- 
1.7.3.4
