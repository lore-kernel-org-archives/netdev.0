From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH net-next v2 1/5] tcp: metrics: rename tcpm_addr to tcpm_daddr
Date: Wed,  8 Jan 2014 16:05:55 +0100
Message-ID: <1389193559-16756-2-git-send-email-christoph.paasch@uclouvain.be>
References: <1389193559-16756-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>, Julian Anastasov <ja@ssi.bg>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:64932 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755664AbaAHPGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 10:06:15 -0500
Received: by mail-we0-f173.google.com with SMTP id t60so1538127wes.4
        for <netdev@vger.kernel.org>; Wed, 08 Jan 2014 07:06:14 -0800 (PST)
In-Reply-To: <1389193559-16756-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As we will add also the source-address, we rename all accesses to the
tcp-metrics address to use "daddr".

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 net/ipv4/tcp_metrics.c | 72 +++++++++++++++++++++++++-------------------------
 1 file changed, 36 insertions(+), 36 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 06493736fbc8..f9b5f519a4ea 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -31,7 +31,7 @@ struct tcp_fastopen_metrics {
 
 struct tcp_metrics_block {
 	struct tcp_metrics_block __rcu	*tcpm_next;
-	struct inetpeer_addr		tcpm_addr;
+	struct inetpeer_addr		tcpm_daddr;
 	unsigned long			tcpm_stamp;
 	u32				tcpm_ts;
 	u32				tcpm_ts_stamp;
@@ -131,7 +131,7 @@ static void tcpm_suck_dst(struct tcp_metrics_block *tm, struct dst_entry *dst,
 }
 
 static struct tcp_metrics_block *tcpm_new(struct dst_entry *dst,
-					  struct inetpeer_addr *addr,
+					  struct inetpeer_addr *daddr,
 					  unsigned int hash,
 					  bool reclaim)
 {
@@ -155,7 +155,7 @@ static struct tcp_metrics_block *tcpm_new(struct dst_entry *dst,
 		if (!tm)
 			goto out_unlock;
 	}
-	tm->tcpm_addr = *addr;
+	tm->tcpm_daddr = *daddr;
 
 	tcpm_suck_dst(tm, dst, true);
 
@@ -189,7 +189,7 @@ static struct tcp_metrics_block *tcp_get_encode(struct tcp_metrics_block *tm, in
 	return NULL;
 }
 
-static struct tcp_metrics_block *__tcp_get_metrics(const struct inetpeer_addr *addr,
+static struct tcp_metrics_block *__tcp_get_metrics(const struct inetpeer_addr *daddr,
 						   struct net *net, unsigned int hash)
 {
 	struct tcp_metrics_block *tm;
@@ -197,7 +197,7 @@ static struct tcp_metrics_block *__tcp_get_metrics(const struct inetpeer_addr *a
 
 	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
-		if (addr_same(&tm->tcpm_addr, addr))
+		if (addr_same(&tm->tcpm_daddr, daddr))
 			break;
 		depth++;
 	}
@@ -208,19 +208,19 @@ static struct tcp_metrics_block *__tcp_get_metrics_req(struct request_sock *req,
 						       struct dst_entry *dst)
 {
 	struct tcp_metrics_block *tm;
-	struct inetpeer_addr addr;
+	struct inetpeer_addr daddr;
 	unsigned int hash;
 	struct net *net;
 
-	addr.family = req->rsk_ops->family;
-	switch (addr.family) {
+	daddr.family = req->rsk_ops->family;
+	switch (daddr.family) {
 	case AF_INET:
-		addr.addr.a4 = inet_rsk(req)->ir_rmt_addr;
-		hash = (__force unsigned int) addr.addr.a4;
+		daddr.addr.a4 = inet_rsk(req)->ir_rmt_addr;
+		hash = (__force unsigned int) daddr.addr.a4;
 		break;
 #if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
-		*(struct in6_addr *)addr.addr.a6 = inet_rsk(req)->ir_v6_rmt_addr;
+		*(struct in6_addr *)daddr.addr.a6 = inet_rsk(req)->ir_v6_rmt_addr;
 		hash = ipv6_addr_hash(&inet_rsk(req)->ir_v6_rmt_addr);
 		break;
 #endif
@@ -233,7 +233,7 @@ static struct tcp_metrics_block *__tcp_get_metrics_req(struct request_sock *req,
 
 	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
-		if (addr_same(&tm->tcpm_addr, &addr))
+		if (addr_same(&tm->tcpm_daddr, &daddr))
 			break;
 	}
 	tcpm_check_stamp(tm, dst);
@@ -243,19 +243,19 @@ static struct tcp_metrics_block *__tcp_get_metrics_req(struct request_sock *req,
 static struct tcp_metrics_block *__tcp_get_metrics_tw(struct inet_timewait_sock *tw)
 {
 	struct tcp_metrics_block *tm;
-	struct inetpeer_addr addr;
+	struct inetpeer_addr daddr;
 	unsigned int hash;
 	struct net *net;
 
-	addr.family = tw->tw_family;
-	switch (addr.family) {
+	daddr.family = tw->tw_family;
+	switch (daddr.family) {
 	case AF_INET:
-		addr.addr.a4 = tw->tw_daddr;
-		hash = (__force unsigned int) addr.addr.a4;
+		daddr.addr.a4 = tw->tw_daddr;
+		hash = (__force unsigned int) daddr.addr.a4;
 		break;
 #if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
-		*(struct in6_addr *)addr.addr.a6 = tw->tw_v6_daddr;
+		*(struct in6_addr *)daddr.addr.a6 = tw->tw_v6_daddr;
 		hash = ipv6_addr_hash(&tw->tw_v6_daddr);
 		break;
 #endif
@@ -268,7 +268,7 @@ static struct tcp_metrics_block *__tcp_get_metrics_tw(struct inet_timewait_sock
 
 	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
-		if (addr_same(&tm->tcpm_addr, &addr))
+		if (addr_same(&tm->tcpm_daddr, &daddr))
 			break;
 	}
 	return tm;
@@ -279,20 +279,20 @@ static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
 						 bool create)
 {
 	struct tcp_metrics_block *tm;
-	struct inetpeer_addr addr;
+	struct inetpeer_addr daddr;
 	unsigned int hash;
 	struct net *net;
 	bool reclaim;
 
-	addr.family = sk->sk_family;
-	switch (addr.family) {
+	daddr.family = sk->sk_family;
+	switch (daddr.family) {
 	case AF_INET:
-		addr.addr.a4 = inet_sk(sk)->inet_daddr;
-		hash = (__force unsigned int) addr.addr.a4;
+		daddr.addr.a4 = inet_sk(sk)->inet_daddr;
+		hash = (__force unsigned int) daddr.addr.a4;
 		break;
 #if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
-		*(struct in6_addr *)addr.addr.a6 = sk->sk_v6_daddr;
+		*(struct in6_addr *)daddr.addr.a6 = sk->sk_v6_daddr;
 		hash = ipv6_addr_hash(&sk->sk_v6_daddr);
 		break;
 #endif
@@ -303,14 +303,14 @@ static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
 	net = dev_net(dst->dev);
 	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
 
-	tm = __tcp_get_metrics(&addr, net, hash);
+	tm = __tcp_get_metrics(&daddr, net, hash);
 	reclaim = false;
 	if (tm == TCP_METRICS_RECLAIM_PTR) {
 		reclaim = true;
 		tm = NULL;
 	}
 	if (!tm && create)
-		tm = tcpm_new(dst, &addr, hash, reclaim);
+		tm = tcpm_new(dst, &daddr, hash, reclaim);
 	else
 		tcpm_check_stamp(tm, dst);
 
@@ -724,15 +724,15 @@ static int tcp_metrics_fill_info(struct sk_buff *msg,
 	struct nlattr *nest;
 	int i;
 
-	switch (tm->tcpm_addr.family) {
+	switch (tm->tcpm_daddr.family) {
 	case AF_INET:
 		if (nla_put_be32(msg, TCP_METRICS_ATTR_ADDR_IPV4,
-				tm->tcpm_addr.addr.a4) < 0)
+				tm->tcpm_daddr.addr.a4) < 0)
 			goto nla_put_failure;
 		break;
 	case AF_INET6:
 		if (nla_put(msg, TCP_METRICS_ATTR_ADDR_IPV6, 16,
-			    tm->tcpm_addr.addr.a6) < 0)
+			    tm->tcpm_daddr.addr.a6) < 0)
 			goto nla_put_failure;
 		break;
 	default:
@@ -882,14 +882,14 @@ static int parse_nl_addr(struct genl_info *info, struct inetpeer_addr *addr,
 static int tcp_metrics_nl_cmd_get(struct sk_buff *skb, struct genl_info *info)
 {
 	struct tcp_metrics_block *tm;
-	struct inetpeer_addr addr;
+	struct inetpeer_addr daddr;
 	unsigned int hash;
 	struct sk_buff *msg;
 	struct net *net = genl_info_net(info);
 	void *reply;
 	int ret;
 
-	ret = parse_nl_addr(info, &addr, &hash, 0);
+	ret = parse_nl_addr(info, &daddr, &hash, 0);
 	if (ret < 0)
 		return ret;
 
@@ -907,7 +907,7 @@ static int tcp_metrics_nl_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	rcu_read_lock();
 	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
-		if (addr_same(&tm->tcpm_addr, &addr)) {
+		if (addr_same(&tm->tcpm_daddr, &daddr)) {
 			ret = tcp_metrics_fill_info(msg, tm);
 			break;
 		}
@@ -962,12 +962,12 @@ static int tcp_metrics_nl_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	struct tcpm_hash_bucket *hb;
 	struct tcp_metrics_block *tm;
 	struct tcp_metrics_block __rcu **pp;
-	struct inetpeer_addr addr;
+	struct inetpeer_addr daddr;
 	unsigned int hash;
 	struct net *net = genl_info_net(info);
 	int ret;
 
-	ret = parse_nl_addr(info, &addr, &hash, 1);
+	ret = parse_nl_addr(info, &daddr, &hash, 1);
 	if (ret < 0)
 		return ret;
 	if (ret > 0)
@@ -979,7 +979,7 @@ static int tcp_metrics_nl_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	spin_lock_bh(&tcp_metrics_lock);
 	for (tm = deref_locked_genl(*pp); tm;
 	     pp = &tm->tcpm_next, tm = deref_locked_genl(*pp)) {
-		if (addr_same(&tm->tcpm_addr, &addr)) {
+		if (addr_same(&tm->tcpm_daddr, &daddr)) {
 			*pp = tm->tcpm_next;
 			break;
 		}
-- 
1.8.3.2
