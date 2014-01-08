From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH net-next v2 2/5] tcp: metrics: Add source-address to tcp-metrics
Date: Wed,  8 Jan 2014 16:05:56 +0100
Message-ID: <1389193559-16756-3-git-send-email-christoph.paasch@uclouvain.be>
References: <1389193559-16756-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>, Julian Anastasov <ja@ssi.bg>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:62344 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755809AbaAHPGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 10:06:17 -0500
Received: by mail-wg0-f50.google.com with SMTP id l18so636837wgh.17
        for <netdev@vger.kernel.org>; Wed, 08 Jan 2014 07:06:16 -0800 (PST)
In-Reply-To: <1389193559-16756-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We add the source-address to the tcp-metrics, so that different metrics
will be used per source/destination-pair. We use the destination-hash to
store the metric inside the hash-table. That way, deleting and dumping
via "ip tcp_metrics" is easy.

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 net/ipv4/tcp_metrics.c | 34 +++++++++++++++++++++++++---------
 1 file changed, 25 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index f9b5f519a4ea..de32aa41a846 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -31,6 +31,7 @@ struct tcp_fastopen_metrics {
 
 struct tcp_metrics_block {
 	struct tcp_metrics_block __rcu	*tcpm_next;
+	struct inetpeer_addr		tcpm_saddr;
 	struct inetpeer_addr		tcpm_daddr;
 	unsigned long			tcpm_stamp;
 	u32				tcpm_ts;
@@ -131,6 +132,7 @@ static void tcpm_suck_dst(struct tcp_metrics_block *tm, struct dst_entry *dst,
 }
 
 static struct tcp_metrics_block *tcpm_new(struct dst_entry *dst,
+					  struct inetpeer_addr *saddr,
 					  struct inetpeer_addr *daddr,
 					  unsigned int hash,
 					  bool reclaim)
@@ -155,6 +157,7 @@ static struct tcp_metrics_block *tcpm_new(struct dst_entry *dst,
 		if (!tm)
 			goto out_unlock;
 	}
+	tm->tcpm_saddr = *saddr;
 	tm->tcpm_daddr = *daddr;
 
 	tcpm_suck_dst(tm, dst, true);
@@ -189,7 +192,8 @@ static struct tcp_metrics_block *tcp_get_encode(struct tcp_metrics_block *tm, in
 	return NULL;
 }
 
-static struct tcp_metrics_block *__tcp_get_metrics(const struct inetpeer_addr *daddr,
+static struct tcp_metrics_block *__tcp_get_metrics(const struct inetpeer_addr *saddr,
+						   const struct inetpeer_addr *daddr,
 						   struct net *net, unsigned int hash)
 {
 	struct tcp_metrics_block *tm;
@@ -197,7 +201,8 @@ static struct tcp_metrics_block *__tcp_get_metrics(const struct inetpeer_addr *d
 
 	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
-		if (addr_same(&tm->tcpm_daddr, daddr))
+		if (addr_same(&tm->tcpm_saddr, saddr) &&
+		    addr_same(&tm->tcpm_daddr, daddr))
 			break;
 		depth++;
 	}
@@ -208,18 +213,21 @@ static struct tcp_metrics_block *__tcp_get_metrics_req(struct request_sock *req,
 						       struct dst_entry *dst)
 {
 	struct tcp_metrics_block *tm;
-	struct inetpeer_addr daddr;
+	struct inetpeer_addr saddr, daddr;
 	unsigned int hash;
 	struct net *net;
 
+	saddr.family = req->rsk_ops->family;
 	daddr.family = req->rsk_ops->family;
 	switch (daddr.family) {
 	case AF_INET:
+		saddr.addr.a4 = inet_rsk(req)->ir_loc_addr;
 		daddr.addr.a4 = inet_rsk(req)->ir_rmt_addr;
 		hash = (__force unsigned int) daddr.addr.a4;
 		break;
 #if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
+		*(struct in6_addr *)saddr.addr.a6 = inet_rsk(req)->ir_v6_loc_addr;
 		*(struct in6_addr *)daddr.addr.a6 = inet_rsk(req)->ir_v6_rmt_addr;
 		hash = ipv6_addr_hash(&inet_rsk(req)->ir_v6_rmt_addr);
 		break;
@@ -233,7 +241,8 @@ static struct tcp_metrics_block *__tcp_get_metrics_req(struct request_sock *req,
 
 	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
-		if (addr_same(&tm->tcpm_daddr, &daddr))
+		if (addr_same(&tm->tcpm_saddr, &saddr) &&
+		    addr_same(&tm->tcpm_daddr, &daddr))
 			break;
 	}
 	tcpm_check_stamp(tm, dst);
@@ -243,18 +252,21 @@ static struct tcp_metrics_block *__tcp_get_metrics_req(struct request_sock *req,
 static struct tcp_metrics_block *__tcp_get_metrics_tw(struct inet_timewait_sock *tw)
 {
 	struct tcp_metrics_block *tm;
-	struct inetpeer_addr daddr;
+	struct inetpeer_addr saddr, daddr;
 	unsigned int hash;
 	struct net *net;
 
+	saddr.family = tw->tw_family;
 	daddr.family = tw->tw_family;
 	switch (daddr.family) {
 	case AF_INET:
+		saddr.addr.a4 = tw->tw_rcv_saddr;
 		daddr.addr.a4 = tw->tw_daddr;
 		hash = (__force unsigned int) daddr.addr.a4;
 		break;
 #if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
+		*(struct in6_addr *)saddr.addr.a6 = tw->tw_v6_rcv_saddr;
 		*(struct in6_addr *)daddr.addr.a6 = tw->tw_v6_daddr;
 		hash = ipv6_addr_hash(&tw->tw_v6_daddr);
 		break;
@@ -268,7 +280,8 @@ static struct tcp_metrics_block *__tcp_get_metrics_tw(struct inet_timewait_sock
 
 	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
-		if (addr_same(&tm->tcpm_daddr, &daddr))
+		if (addr_same(&tm->tcpm_saddr, &saddr) &&
+		    addr_same(&tm->tcpm_daddr, &daddr))
 			break;
 	}
 	return tm;
@@ -279,19 +292,22 @@ static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
 						 bool create)
 {
 	struct tcp_metrics_block *tm;
-	struct inetpeer_addr daddr;
+	struct inetpeer_addr saddr, daddr;
 	unsigned int hash;
 	struct net *net;
 	bool reclaim;
 
+	saddr.family = sk->sk_family;
 	daddr.family = sk->sk_family;
 	switch (daddr.family) {
 	case AF_INET:
+		saddr.addr.a4 = inet_sk(sk)->inet_saddr;
 		daddr.addr.a4 = inet_sk(sk)->inet_daddr;
 		hash = (__force unsigned int) daddr.addr.a4;
 		break;
 #if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
+		*(struct in6_addr *)saddr.addr.a6 = sk->sk_v6_rcv_saddr;
 		*(struct in6_addr *)daddr.addr.a6 = sk->sk_v6_daddr;
 		hash = ipv6_addr_hash(&sk->sk_v6_daddr);
 		break;
@@ -303,14 +319,14 @@ static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
 	net = dev_net(dst->dev);
 	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
 
-	tm = __tcp_get_metrics(&daddr, net, hash);
+	tm = __tcp_get_metrics(&saddr, &daddr, net, hash);
 	reclaim = false;
 	if (tm == TCP_METRICS_RECLAIM_PTR) {
 		reclaim = true;
 		tm = NULL;
 	}
 	if (!tm && create)
-		tm = tcpm_new(dst, &daddr, hash, reclaim);
+		tm = tcpm_new(dst, &saddr, &daddr, hash, reclaim);
 	else
 		tcpm_check_stamp(tm, dst);
 
-- 
1.8.3.2
