From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 1/4] ipip: advertise tunnel param via rtnl
Date: Fri,  9 Nov 2012 10:51:08 +0100
Message-ID: <1352454671-4336-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1352454671-4336-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:57262 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976Ab2KIJkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 04:40:22 -0500
In-Reply-To: <1352454671-4336-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/if_tunnel.h | 11 ++++++++
 net/ipv4/ipip.c                | 57 +++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 67 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index 5db5942..ccb21d5 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -37,6 +37,17 @@ struct ip_tunnel_parm {
 	struct iphdr		iph;
 };
 
+enum {
+	IFLA_IPTUN_UNSPEC,
+	IFLA_IPTUN_LINK,
+	IFLA_IPTUN_LOCAL,
+	IFLA_IPTUN_REMOTE,
+	IFLA_IPTUN_TTL,
+	IFLA_IPTUN_TOS,
+	__IFLA_IPTUN_MAX,
+};
+#define IFLA_IPTUN_MAX	(__IFLA_IPTUN_MAX - 1)
+
 /* SIT-mode i_flags */
 #define	SIT_ISATAP	0x0001
 
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index e15b452..37e1ca2 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -138,6 +138,7 @@ struct ipip_net {
 static int ipip_tunnel_init(struct net_device *dev);
 static void ipip_tunnel_setup(struct net_device *dev);
 static void ipip_dev_free(struct net_device *dev);
+static struct rtnl_link_ops ipip_link_ops __read_mostly;
 
 /*
  * Locking : hash tables are protected by RCU and RTNL
@@ -305,6 +306,7 @@ static struct ip_tunnel *ipip_tunnel_locate(struct net *net,
 		goto failed_free;
 
 	strcpy(nt->parms.name, dev->name);
+	dev->rtnl_link_ops = &ipip_link_ops;
 
 	dev_hold(dev);
 	ipip_tunnel_link(ipn, nt);
@@ -829,6 +831,47 @@ static int __net_init ipip_fb_tunnel_init(struct net_device *dev)
 	return 0;
 }
 
+static size_t ipip_get_size(const struct net_device *dev)
+{
+	return
+		/* IFLA_IPTUN_LINK */
+		nla_total_size(4) +
+		/* IFLA_IPTUN_LOCAL */
+		nla_total_size(4) +
+		/* IFLA_IPTUN_REMOTE */
+		nla_total_size(4) +
+		/* IFLA_IPTUN_TTL */
+		nla_total_size(1) +
+		/* IFLA_IPTUN_TOS */
+		nla_total_size(1) +
+		0;
+}
+
+static int ipip_fill_info(struct sk_buff *skb, const struct net_device *dev)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct ip_tunnel_parm *parm = &tunnel->parms;
+
+	if (nla_put_u32(skb, IFLA_IPTUN_LINK, parm->link) ||
+	    nla_put_be32(skb, IFLA_IPTUN_LOCAL, parm->iph.saddr) ||
+	    nla_put_be32(skb, IFLA_IPTUN_REMOTE, parm->iph.daddr) ||
+	    nla_put_u8(skb, IFLA_IPTUN_TTL, parm->iph.ttl) ||
+	    nla_put_u8(skb, IFLA_IPTUN_TOS, parm->iph.tos))
+		goto nla_put_failure;
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+static struct rtnl_link_ops ipip_link_ops __read_mostly = {
+	.kind		= "ipip",
+	.maxtype	= IFLA_IPTUN_MAX,
+	.priv_size	= sizeof(struct ip_tunnel),
+	.get_size	= ipip_get_size,
+	.fill_info	= ipip_fill_info,
+};
+
 static struct xfrm_tunnel ipip_handler __read_mostly = {
 	.handler	=	ipip_rcv,
 	.err_handler	=	ipip_err,
@@ -925,14 +968,26 @@ static int __init ipip_init(void)
 		return err;
 	err = xfrm4_tunnel_register(&ipip_handler, AF_INET);
 	if (err < 0) {
-		unregister_pernet_device(&ipip_net_ops);
 		pr_info("%s: can't register tunnel\n", __func__);
+		goto xfrm_tunnel_failed;
 	}
+	err = rtnl_link_register(&ipip_link_ops);
+	if (err < 0)
+		goto rtnl_link_failed;
+
+out:
 	return err;
+
+rtnl_link_failed:
+	xfrm4_tunnel_deregister(&ipip_handler, AF_INET);
+xfrm_tunnel_failed:
+	unregister_pernet_device(&ipip_net_ops);
+	goto out;
 }
 
 static void __exit ipip_fini(void)
 {
+	rtnl_link_unregister(&ipip_link_ops);
 	if (xfrm4_tunnel_deregister(&ipip_handler, AF_INET))
 		pr_info("%s: can't deregister tunnel\n", __func__);
 
-- 
1.7.12
