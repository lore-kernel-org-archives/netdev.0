From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH net-next v2 5/5] tcp: metrics: Allow selective get/del of tcp-metrics based on src IP
Date: Wed,  8 Jan 2014 16:05:59 +0100
Message-ID: <1389193559-16756-6-git-send-email-christoph.paasch@uclouvain.be>
References: <1389193559-16756-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>, Julian Anastasov <ja@ssi.bg>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:33089 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755809AbaAHPGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 10:06:22 -0500
Received: by mail-wi0-f173.google.com with SMTP id hn9so5649618wib.12
        for <netdev@vger.kernel.org>; Wed, 08 Jan 2014 07:06:21 -0800 (PST)
In-Reply-To: <1389193559-16756-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We want to be able to get/del tcp-metrics based on the src IP. This
patch adds the necessary parsing of the netlink attribute and if the
source address is set, it will match on this one too.

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 net/ipv4/tcp_metrics.c | 48 ++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 38 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index e150f264c8e2..699a42faab9c 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -877,44 +877,66 @@ done:
 	return skb->len;
 }
 
-static int parse_nl_addr(struct genl_info *info, struct inetpeer_addr *addr,
-			 unsigned int *hash, int optional)
+static int __parse_nl_addr(struct genl_info *info, struct inetpeer_addr *addr,
+			   unsigned int *hash, int optional, int v4, int v6)
 {
 	struct nlattr *a;
 
-	a = info->attrs[TCP_METRICS_ATTR_ADDR_IPV4];
+	a = info->attrs[v4];
 	if (a) {
 		addr->family = AF_INET;
 		addr->addr.a4 = nla_get_be32(a);
-		*hash = (__force unsigned int) addr->addr.a4;
+		if (hash)
+			*hash = (__force unsigned int) addr->addr.a4;
 		return 0;
 	}
-	a = info->attrs[TCP_METRICS_ATTR_ADDR_IPV6];
+	a = info->attrs[v6];
 	if (a) {
 		if (nla_len(a) != sizeof(struct in6_addr))
 			return -EINVAL;
 		addr->family = AF_INET6;
 		memcpy(addr->addr.a6, nla_data(a), sizeof(addr->addr.a6));
-		*hash = ipv6_addr_hash((struct in6_addr *) addr->addr.a6);
+		if (hash)
+			*hash = ipv6_addr_hash((struct in6_addr *) addr->addr.a6);
 		return 0;
 	}
 	return optional ? 1 : -EAFNOSUPPORT;
 }
 
+static int parse_nl_addr(struct genl_info *info, struct inetpeer_addr *addr,
+			 unsigned int *hash, int optional)
+{
+	return __parse_nl_addr(info, addr, hash, optional,
+			       TCP_METRICS_ATTR_ADDR_IPV4,
+			       TCP_METRICS_ATTR_ADDR_IPV6);
+}
+
+static int parse_nl_saddr(struct genl_info *info, struct inetpeer_addr *addr)
+{
+	return __parse_nl_addr(info, addr, NULL, 0,
+			       TCP_METRICS_ATTR_SADDR_IPV4,
+			       TCP_METRICS_ATTR_SADDR_IPV6);
+}
+
 static int tcp_metrics_nl_cmd_get(struct sk_buff *skb, struct genl_info *info)
 {
 	struct tcp_metrics_block *tm;
-	struct inetpeer_addr daddr;
+	struct inetpeer_addr saddr, daddr;
 	unsigned int hash;
 	struct sk_buff *msg;
 	struct net *net = genl_info_net(info);
 	void *reply;
 	int ret;
+	bool src = true;
 
 	ret = parse_nl_addr(info, &daddr, &hash, 0);
 	if (ret < 0)
 		return ret;
 
+	ret = parse_nl_saddr(info, &saddr);
+	if (ret < 0)
+		src = false;
+
 	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
 	if (!msg)
 		return -ENOMEM;
@@ -929,7 +951,8 @@ static int tcp_metrics_nl_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	rcu_read_lock();
 	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
 	     tm = rcu_dereference(tm->tcpm_next)) {
-		if (addr_same(&tm->tcpm_daddr, &daddr)) {
+		if (addr_same(&tm->tcpm_daddr, &daddr) &&
+		    (!src || addr_same(&tm->tcpm_saddr, &saddr))) {
 			ret = tcp_metrics_fill_info(msg, tm);
 			break;
 		}
@@ -984,23 +1007,28 @@ static int tcp_metrics_nl_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	struct tcpm_hash_bucket *hb;
 	struct tcp_metrics_block *tm, *tmlist = NULL;
 	struct tcp_metrics_block __rcu **pp;
-	struct inetpeer_addr daddr;
+	struct inetpeer_addr saddr, daddr;
 	unsigned int hash;
 	struct net *net = genl_info_net(info);
 	int ret;
+	bool src = true;
 
 	ret = parse_nl_addr(info, &daddr, &hash, 1);
 	if (ret < 0)
 		return ret;
 	if (ret > 0)
 		return tcp_metrics_flush_all(net);
+	ret = parse_nl_saddr(info, &saddr);
+	if (ret < 0)
+		src = false;
 
 	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
 	hb = net->ipv4.tcp_metrics_hash + hash;
 	pp = &hb->chain;
 	spin_lock_bh(&tcp_metrics_lock);
 	for (tm = deref_locked_genl(*pp); tm; tm = deref_locked_genl(*pp)) {
-		if (addr_same(&tm->tcpm_daddr, &daddr)) {
+		if (addr_same(&tm->tcpm_daddr, &daddr) &&
+		    (!src || addr_same(&tm->tcpm_saddr, &saddr))) {
 			*pp = tm->tcpm_next;
 			tm->tcpm_next = tmlist;
 			tmlist = tm;
-- 
1.8.3.2
