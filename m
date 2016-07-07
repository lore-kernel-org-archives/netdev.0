From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v2 1/4] tunnels: support MPLS over IPv4 tunnels
Date: Thu,  7 Jul 2016 07:56:12 +0200
Message-ID: <1467870975-28003-2-git-send-email-simon.horman@netronome.com>
References: <1467870975-28003-1-git-send-email-simon.horman@netronome.com>
Cc: Tom Herbert <tom@herbertland.com>, netdev@vger.kernel.org,
	Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:36720 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399AbcGGF42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 01:56:28 -0400
Received: by mail-wm0-f48.google.com with SMTP id f126so196754686wma.1
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 22:56:27 -0700 (PDT)
In-Reply-To: <1467870975-28003-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend tunnel support to MPLS over IPv4.  The implementation extends the
existing differentiation between IPIP and IPv6 over IPv4 to also cover MPLS
over IPv4.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Dinan Gunawardena <dinan.gunawardena@netronome.com>
---
 net/ipv4/tunnel4.c | 77 +++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 67 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tunnel4.c b/net/ipv4/tunnel4.c
index 0d0171830620..45cd4253583a 100644
--- a/net/ipv4/tunnel4.c
+++ b/net/ipv4/tunnel4.c
@@ -6,6 +6,7 @@
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/mutex.h>
+#include <linux/mpls.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/slab.h>
@@ -16,11 +17,14 @@
 
 static struct xfrm_tunnel __rcu *tunnel4_handlers __read_mostly;
 static struct xfrm_tunnel __rcu *tunnel64_handlers __read_mostly;
+static struct xfrm_tunnel __rcu *tunnelmpls4_handlers __read_mostly;
 static DEFINE_MUTEX(tunnel4_mutex);
 
 static inline struct xfrm_tunnel __rcu **fam_handlers(unsigned short family)
 {
-	return (family == AF_INET) ? &tunnel4_handlers : &tunnel64_handlers;
+	return (family == AF_INET) ? &tunnel4_handlers :
+		(family == AF_INET6) ? &tunnel64_handlers :
+		&tunnelmpls4_handlers;
 }
 
 int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned short family)
@@ -125,6 +129,26 @@ drop:
 }
 #endif
 
+#if IS_ENABLED(CONFIG_MPLS)
+static int tunnelmpls4_rcv(struct sk_buff *skb)
+{
+	struct xfrm_tunnel *handler;
+
+	if (!pskb_may_pull(skb, sizeof(struct mpls_label)))
+		goto drop;
+
+	for_each_tunnel_rcu(tunnelmpls4_handlers, handler)
+		if (!handler->handler(skb))
+			return 0;
+
+	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
+
+drop:
+	kfree_skb(skb);
+	return 0;
+}
+#endif
+
 static void tunnel4_err(struct sk_buff *skb, u32 info)
 {
 	struct xfrm_tunnel *handler;
@@ -145,6 +169,17 @@ static void tunnel64_err(struct sk_buff *skb, u32 info)
 }
 #endif
 
+#if IS_ENABLED(CONFIG_MPLS)
+static void tunnelmpls4_err(struct sk_buff *skb, u32 info)
+{
+	struct xfrm_tunnel *handler;
+
+	for_each_tunnel_rcu(tunnelmpls4_handlers, handler)
+		if (!handler->err_handler(skb, info))
+			break;
+}
+#endif
+
 static const struct net_protocol tunnel4_protocol = {
 	.handler	=	tunnel4_rcv,
 	.err_handler	=	tunnel4_err,
@@ -161,24 +196,46 @@ static const struct net_protocol tunnel64_protocol = {
 };
 #endif
 
+#if IS_ENABLED(CONFIG_MPLS)
+static const struct net_protocol tunnelmpls4_protocol = {
+	.handler	=	tunnelmpls4_rcv,
+	.err_handler	=	tunnelmpls4_err,
+	.no_policy	=	1,
+	.netns_ok	=	1,
+};
+#endif
+
 static int __init tunnel4_init(void)
 {
-	if (inet_add_protocol(&tunnel4_protocol, IPPROTO_IPIP)) {
-		pr_err("%s: can't add protocol\n", __func__);
-		return -EAGAIN;
-	}
+	if (inet_add_protocol(&tunnel4_protocol, IPPROTO_IPIP))
+		goto err_ipip;
 #if IS_ENABLED(CONFIG_IPV6)
-	if (inet_add_protocol(&tunnel64_protocol, IPPROTO_IPV6)) {
-		pr_err("tunnel64 init: can't add protocol\n");
-		inet_del_protocol(&tunnel4_protocol, IPPROTO_IPIP);
-		return -EAGAIN;
-	}
+	if (inet_add_protocol(&tunnel64_protocol, IPPROTO_IPV6))
+		goto err_ipv6;
+#endif
+#if IS_ENABLED(CONFIG_MPLS)
+	if (inet_add_protocol(&tunnelmpls4_protocol, IPPROTO_MPLS))
+		goto err_mpls;
 #endif
 	return 0;
+
+#if IS_ENABLED(CONFIG_IPV6)
+err_mpls:
+	inet_del_protocol(&tunnel4_protocol, IPPROTO_IPV6);
+#endif
+err_ipv6:
+	inet_del_protocol(&tunnel4_protocol, IPPROTO_IPIP);
+err_ipip:
+	pr_err("%s: can't add protocol\n", __func__);
+	return -EAGAIN;
 }
 
 static void __exit tunnel4_fini(void)
 {
+#if IS_ENABLED(CONFIG_MPLS)
+	if (inet_del_protocol(&tunnelmpls4_protocol, IPPROTO_MPLS))
+		pr_err("tunnelmpls4 close: can't remove protocol\n");
+#endif
 #if IS_ENABLED(CONFIG_IPV6)
 	if (inet_del_protocol(&tunnel64_protocol, IPPROTO_IPV6))
 		pr_err("tunnel64 close: can't remove protocol\n");
-- 
2.7.0.rc3.207.g0ac5344
