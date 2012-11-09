From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 2/4] sit: advertise tunnel param via rtnl
Date: Fri,  9 Nov 2012 10:51:09 +0100
Message-ID: <1352454671-4336-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1352454671-4336-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:57266 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013Ab2KIJkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 04:40:23 -0500
In-Reply-To: <1352454671-4336-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/sit.c | 57 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 56 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 3ed54ff..b543c56 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -68,6 +68,7 @@
 static int ipip6_tunnel_init(struct net_device *dev);
 static void ipip6_tunnel_setup(struct net_device *dev);
 static void ipip6_dev_free(struct net_device *dev);
+static struct rtnl_link_ops sit_link_ops __read_mostly;
 
 static int sit_net_id __read_mostly;
 struct sit_net {
@@ -282,6 +283,7 @@ static struct ip_tunnel *ipip6_tunnel_locate(struct net *net,
 		goto failed_free;
 
 	strcpy(nt->parms.name, dev->name);
+	dev->rtnl_link_ops = &sit_link_ops;
 
 	dev_hold(dev);
 
@@ -1216,6 +1218,47 @@ static int __net_init ipip6_fb_tunnel_init(struct net_device *dev)
 	return 0;
 }
 
+static size_t sit_get_size(const struct net_device *dev)
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
+static int sit_fill_info(struct sk_buff *skb, const struct net_device *dev)
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
+static struct rtnl_link_ops sit_link_ops __read_mostly = {
+	.kind		= "sit",
+	.maxtype	= IFLA_IPTUN_MAX,
+	.priv_size	= sizeof(struct ip_tunnel),
+	.get_size	= sit_get_size,
+	.fill_info	= sit_fill_info,
+};
+
 static struct xfrm_tunnel sit_handler __read_mostly = {
 	.handler	=	ipip6_rcv,
 	.err_handler	=	ipip6_err,
@@ -1302,6 +1345,7 @@ static struct pernet_operations sit_net_ops = {
 
 static void __exit sit_cleanup(void)
 {
+	rtnl_link_unregister(&sit_link_ops);
 	xfrm4_tunnel_deregister(&sit_handler, AF_INET6);
 
 	unregister_pernet_device(&sit_net_ops);
@@ -1319,10 +1363,21 @@ static int __init sit_init(void)
 		return err;
 	err = xfrm4_tunnel_register(&sit_handler, AF_INET6);
 	if (err < 0) {
-		unregister_pernet_device(&sit_net_ops);
 		pr_info("%s: can't add protocol\n", __func__);
+		goto xfrm_tunnel_failed;
 	}
+	err = rtnl_link_register(&sit_link_ops);
+	if (err < 0)
+		goto rtnl_link_failed;
+
+out:
 	return err;
+
+rtnl_link_failed:
+	xfrm4_tunnel_deregister(&sit_handler, AF_INET6);
+xfrm_tunnel_failed:
+	unregister_pernet_device(&sit_net_ops);
+	goto out;
 }
 
 module_init(sit_init);
-- 
1.7.12
