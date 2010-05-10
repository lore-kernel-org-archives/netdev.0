From: kaber@trash.net
Subject: [PATCH 76/84] netfilter: xt_TEE: resolve oif using netdevice notifiers
Date: Mon, 10 May 2010 22:18:47 +0200
Message-ID: <1273522735-24672-77-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54526 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756948Ab0EJUT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:28 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Replace the runtime oif name resolving by netdevice notifier based
resolving. When an oif is given, a netdevice notifier is registered
to resolve the name on NETDEV_REGISTER or NETDEV_CHANGE and unresolve
it again on NETDEV_UNREGISTER or NETDEV_CHANGE to a different name.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/xt_TEE.h |    3 +
 net/netfilter/xt_TEE.c           |  103 +++++++++++++++++++++++++++++--------
 2 files changed, 83 insertions(+), 23 deletions(-)

diff --git a/include/linux/netfilter/xt_TEE.h b/include/linux/netfilter/xt_TEE.h
index 55d4a50..5c21d5c 100644
--- a/include/linux/netfilter/xt_TEE.h
+++ b/include/linux/netfilter/xt_TEE.h
@@ -4,6 +4,9 @@
 struct xt_tee_tginfo {
 	union nf_inet_addr gw;
 	char oif[16];
+
+	/* used internally by the kernel */
+	struct xt_tee_priv *priv __attribute__((aligned(8)));
 };
 
 #endif /* _XT_TEE_TARGET_H */
diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index 842e701..49da6c0 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -15,6 +15,7 @@
 #include <linux/percpu.h>
 #include <linux/route.h>
 #include <linux/skbuff.h>
+#include <linux/notifier.h>
 #include <net/checksum.h>
 #include <net/icmp.h>
 #include <net/ip.h>
@@ -32,6 +33,12 @@
 #	define WITH_IPV6 1
 #endif
 
+struct xt_tee_priv {
+	struct notifier_block	notifier;
+	struct xt_tee_tginfo	*tginfo;
+	int			oif;
+};
+
 static const union nf_inet_addr tee_zero_address;
 static DEFINE_PER_CPU(bool, tee_active);
 
@@ -49,20 +56,6 @@ static struct net *pick_net(struct sk_buff *skb)
 	return &init_net;
 }
 
-static bool tee_tg_route_oif(struct flowi *f, struct net *net,
-			     const struct xt_tee_tginfo *info)
-{
-	const struct net_device *dev;
-
-	if (*info->oif != '\0')
-		return true;
-	dev = dev_get_by_name(net, info->oif);
-	if (dev == NULL)
-		return false;
-	f->oif = dev->ifindex;
-	return true;
-}
-
 static bool
 tee_tg_route4(struct sk_buff *skb, const struct xt_tee_tginfo *info)
 {
@@ -72,8 +65,11 @@ tee_tg_route4(struct sk_buff *skb, const struct xt_tee_tginfo *info)
 	struct flowi fl;
 
 	memset(&fl, 0, sizeof(fl));
-	if (!tee_tg_route_oif(&fl, net, info))
-		return false;
+	if (info->priv) {
+		if (info->priv->oif == -1)
+			return false;
+		fl.oif = info->priv->oif;
+	}
 	fl.nl_u.ip4_u.daddr = info->gw.ip;
 	fl.nl_u.ip4_u.tos   = RT_TOS(iph->tos);
 	fl.nl_u.ip4_u.scope = RT_SCOPE_UNIVERSE;
@@ -149,8 +145,11 @@ tee_tg_route6(struct sk_buff *skb, const struct xt_tee_tginfo *info)
 	struct flowi fl;
 
 	memset(&fl, 0, sizeof(fl));
-	if (!tee_tg_route_oif(&fl, net, info))
-		return false;
+	if (info->priv) {
+		if (info->priv->oif == -1)
+			return false;
+		fl.oif = info->priv->oif;
+	}
 	fl.nl_u.ip6_u.daddr = info->gw.in6;
 	fl.nl_u.ip6_u.flowlabel = ((iph->flow_lbl[0] & 0xF) << 16) |
 				  (iph->flow_lbl[1] << 8) | iph->flow_lbl[2];
@@ -198,15 +197,71 @@ tee_tg6(struct sk_buff *skb, const struct xt_target_param *par)
 }
 #endif /* WITH_IPV6 */
 
+static int tee_netdev_event(struct notifier_block *this, unsigned long event,
+			    void *ptr)
+{
+	struct net_device *dev = ptr;
+	struct xt_tee_priv *priv;
+
+	priv = container_of(this, struct xt_tee_priv, notifier);
+	switch (event) {
+	case NETDEV_REGISTER:
+		if (!strcmp(dev->name, priv->tginfo->oif))
+			priv->oif = dev->ifindex;
+		break;
+	case NETDEV_UNREGISTER:
+		if (dev->ifindex == priv->oif)
+			priv->oif = -1;
+		break;
+	case NETDEV_CHANGENAME:
+		if (!strcmp(dev->name, priv->tginfo->oif))
+			priv->oif = dev->ifindex;
+		else if (dev->ifindex == priv->oif)
+			priv->oif = -1;
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
 static int tee_tg_check(const struct xt_tgchk_param *par)
 {
-	const struct xt_tee_tginfo *info = par->targinfo;
+	struct xt_tee_tginfo *info = par->targinfo;
+	struct xt_tee_priv *priv;
 
-	if (info->oif[sizeof(info->oif)-1] != '\0')
-		return -EINVAL;
 	/* 0.0.0.0 and :: not allowed */
-	return (memcmp(&info->gw, &tee_zero_address,
-	       sizeof(tee_zero_address)) == 0) ? -EINVAL : 0;
+	if (memcmp(&info->gw, &tee_zero_address,
+		   sizeof(tee_zero_address)) == 0)
+		return -EINVAL;
+
+	if (info->oif[0]) {
+		if (info->oif[sizeof(info->oif)-1] != '\0')
+			return -EINVAL;
+
+		priv = kzalloc(sizeof(*priv), GFP_KERNEL);
+		if (priv == NULL)
+			return -ENOMEM;
+
+		priv->tginfo  = info;
+		priv->oif     = -1;
+		priv->notifier.notifier_call = tee_netdev_event;
+		info->priv    = priv;
+
+		register_netdevice_notifier(&priv->notifier);
+	} else
+		info->priv = NULL;
+
+	return 0;
+}
+
+static void tee_tg_destroy(const struct xt_tgdtor_param *par)
+{
+	struct xt_tee_tginfo *info = par->targinfo;
+
+	if (info->priv) {
+		unregister_netdevice_notifier(&info->priv->notifier);
+		kfree(info->priv);
+	}
 }
 
 static struct xt_target tee_tg_reg[] __read_mostly = {
@@ -217,6 +272,7 @@ static struct xt_target tee_tg_reg[] __read_mostly = {
 		.target     = tee_tg4,
 		.targetsize = sizeof(struct xt_tee_tginfo),
 		.checkentry = tee_tg_check,
+		.destroy    = tee_tg_destroy,
 		.me         = THIS_MODULE,
 	},
 #ifdef WITH_IPV6
@@ -227,6 +283,7 @@ static struct xt_target tee_tg_reg[] __read_mostly = {
 		.target     = tee_tg6,
 		.targetsize = sizeof(struct xt_tee_tginfo),
 		.checkentry = tee_tg_check,
+		.destroy    = tee_tg_destroy,
 		.me         = THIS_MODULE,
 	},
 #endif
-- 
1.7.0.4

