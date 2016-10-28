From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH v2 net 2/2] geneve: avoid using stale geneve socket.
Date: Fri, 28 Oct 2016 09:59:16 -0700
Message-ID: <1477673956-127319-2-git-send-email-pshelar@ovn.org>
References: <1477673956-127319-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:42086 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756388AbcJ1Q7X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 12:59:23 -0400
In-Reply-To: <1477673956-127319-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is similar to earlier vxlan patch.
Geneve device close operation frees geneve socket. This
operation can race with geneve-xmit function which
dereferences geneve socket. Following patch uses RCU
mechanism to avoid this situation.

Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
Acked-by: John W. Linville <linville@tuxdriver.com>
---
 drivers/net/geneve.c | 45 ++++++++++++++++++++++++++++++++++-----------
 1 file changed, 34 insertions(+), 11 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 16af1ce..42edd7b 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -58,9 +58,9 @@ struct geneve_dev {
 	struct hlist_node  hlist;	/* vni hash table */
 	struct net	   *net;	/* netns for packet i/o */
 	struct net_device  *dev;	/* netdev for geneve tunnel */
-	struct geneve_sock *sock4;	/* IPv4 socket used for geneve tunnel */
+	struct geneve_sock __rcu *sock4;	/* IPv4 socket used for geneve tunnel */
 #if IS_ENABLED(CONFIG_IPV6)
-	struct geneve_sock *sock6;	/* IPv6 socket used for geneve tunnel */
+	struct geneve_sock __rcu *sock6;	/* IPv6 socket used for geneve tunnel */
 #endif
 	u8                 vni[3];	/* virtual network ID for tunnel */
 	u8                 ttl;		/* TTL override */
@@ -543,9 +543,19 @@ static void __geneve_sock_release(struct geneve_sock *gs)
 
 static void geneve_sock_release(struct geneve_dev *geneve)
 {
-	__geneve_sock_release(geneve->sock4);
+	struct geneve_sock *gs4 = rtnl_dereference(geneve->sock4);
 #if IS_ENABLED(CONFIG_IPV6)
-	__geneve_sock_release(geneve->sock6);
+	struct geneve_sock *gs6 = rtnl_dereference(geneve->sock6);
+
+	rcu_assign_pointer(geneve->sock6, NULL);
+#endif
+
+	rcu_assign_pointer(geneve->sock4, NULL);
+	synchronize_net();
+
+	__geneve_sock_release(gs4);
+#if IS_ENABLED(CONFIG_IPV6)
+	__geneve_sock_release(gs6);
 #endif
 }
 
@@ -586,10 +596,10 @@ static int geneve_sock_add(struct geneve_dev *geneve, bool ipv6)
 	gs->flags = geneve->flags;
 #if IS_ENABLED(CONFIG_IPV6)
 	if (ipv6)
-		geneve->sock6 = gs;
+		rcu_assign_pointer(geneve->sock6, gs);
 	else
 #endif
-		geneve->sock4 = gs;
+		rcu_assign_pointer(geneve->sock4, gs);
 
 	hash = geneve_net_vni_hash(geneve->vni);
 	hlist_add_head_rcu(&geneve->hlist, &gs->vni_list[hash]);
@@ -603,9 +613,7 @@ static int geneve_open(struct net_device *dev)
 	bool metadata = geneve->collect_md;
 	int ret = 0;
 
-	geneve->sock4 = NULL;
 #if IS_ENABLED(CONFIG_IPV6)
-	geneve->sock6 = NULL;
 	if (ipv6 || metadata)
 		ret = geneve_sock_add(geneve, true);
 #endif
@@ -720,6 +728,9 @@ static struct rtable *geneve_get_v4_rt(struct sk_buff *skb,
 	struct rtable *rt = NULL;
 	__u8 tos;
 
+	if (!rcu_dereference(geneve->sock4))
+		return ERR_PTR(-EIO);
+
 	memset(fl4, 0, sizeof(*fl4));
 	fl4->flowi4_mark = skb->mark;
 	fl4->flowi4_proto = IPPROTO_UDP;
@@ -772,11 +783,15 @@ static struct dst_entry *geneve_get_v6_dst(struct sk_buff *skb,
 {
 	bool use_cache = ip_tunnel_dst_cache_usable(skb, info);
 	struct geneve_dev *geneve = netdev_priv(dev);
-	struct geneve_sock *gs6 = geneve->sock6;
 	struct dst_entry *dst = NULL;
 	struct dst_cache *dst_cache;
+	struct geneve_sock *gs6;
 	__u8 prio;
 
+	gs6 = rcu_dereference(geneve->sock6);
+	if (!gs6)
+		return ERR_PTR(-EIO);
+
 	memset(fl6, 0, sizeof(*fl6));
 	fl6->flowi6_mark = skb->mark;
 	fl6->flowi6_proto = IPPROTO_UDP;
@@ -842,7 +857,7 @@ static netdev_tx_t geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 				   struct ip_tunnel_info *info)
 {
 	struct geneve_dev *geneve = netdev_priv(dev);
-	struct geneve_sock *gs4 = geneve->sock4;
+	struct geneve_sock *gs4;
 	struct rtable *rt = NULL;
 	const struct iphdr *iip; /* interior IP header */
 	int err = -EINVAL;
@@ -853,6 +868,10 @@ static netdev_tx_t geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 	bool xnet = !net_eq(geneve->net, dev_net(geneve->dev));
 	u32 flags = geneve->flags;
 
+	gs4 = rcu_dereference(geneve->sock4);
+	if (!gs4)
+		goto tx_error;
+
 	if (geneve->collect_md) {
 		if (unlikely(!info || !(info->mode & IP_TUNNEL_INFO_TX))) {
 			netdev_dbg(dev, "no tunnel metadata\n");
@@ -932,9 +951,9 @@ static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 				    struct ip_tunnel_info *info)
 {
 	struct geneve_dev *geneve = netdev_priv(dev);
-	struct geneve_sock *gs6 = geneve->sock6;
 	struct dst_entry *dst = NULL;
 	const struct iphdr *iip; /* interior IP header */
+	struct geneve_sock *gs6;
 	int err = -EINVAL;
 	struct flowi6 fl6;
 	__u8 prio, ttl;
@@ -943,6 +962,10 @@ static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 	bool xnet = !net_eq(geneve->net, dev_net(geneve->dev));
 	u32 flags = geneve->flags;
 
+	gs6 = rcu_dereference(geneve->sock6);
+	if (!gs6)
+		goto tx_error;
+
 	if (geneve->collect_md) {
 		if (unlikely(!info || !(info->mode & IP_TUNNEL_INFO_TX))) {
 			netdev_dbg(dev, "no tunnel metadata\n");
-- 
1.9.1
