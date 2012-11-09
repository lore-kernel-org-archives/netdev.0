From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 3/3] ip6tnl: advertise tunnel param via rtnl
Date: Fri,  9 Nov 2012 17:10:01 +0100
Message-ID: <1352477401-19044-4-git-send-email-nicolas.dichtel@6wind.com>
References: <1352467239.19779.564.camel@edumazet-glaptop>
 <1352477401-19044-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:57913 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753914Ab2KIP6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 10:58:12 -0500
In-Reply-To: <1352477401-19044-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is usefull for daemons that monitor link event to have the full parameters of
these interfaces when a rtnl message is sent.
It allows also to dump them via rtnetlink.

It is based on what is done for GRE tunnels.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/if_tunnel.h |  3 +++
 net/ipv6/ip6_tunnel.c          | 57 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 60 insertions(+)

diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index ccb21d5..c1bf0b5 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -44,6 +44,9 @@ enum {
 	IFLA_IPTUN_REMOTE,
 	IFLA_IPTUN_TTL,
 	IFLA_IPTUN_TOS,
+	IFLA_IPTUN_ENCAP_LIMIT,
+	IFLA_IPTUN_FLOWINFO,
+	IFLA_IPTUN_FLAGS,
 	__IFLA_IPTUN_MAX,
 };
 #define IFLA_IPTUN_MAX	(__IFLA_IPTUN_MAX - 1)
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 09482f7..424ed45 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -83,6 +83,7 @@ static u32 HASH(const struct in6_addr *addr1, const struct in6_addr *addr2)
 
 static int ip6_tnl_dev_init(struct net_device *dev);
 static void ip6_tnl_dev_setup(struct net_device *dev);
+static struct rtnl_link_ops ip6_link_ops __read_mostly;
 
 static int ip6_tnl_net_id __read_mostly;
 struct ip6_tnl_net {
@@ -299,6 +300,7 @@ static struct ip6_tnl *ip6_tnl_create(struct net *net, struct __ip6_tnl_parm *p)
 		goto failed_free;
 
 	strcpy(t->parms.name, dev->name);
+	dev->rtnl_link_ops = &ip6_link_ops;
 
 	dev_hold(dev);
 	ip6_tnl_link(ip6n, t);
@@ -1504,6 +1506,55 @@ static int __net_init ip6_fb_tnl_dev_init(struct net_device *dev)
 	return 0;
 }
 
+static size_t ip6_get_size(const struct net_device *dev)
+{
+	return
+		/* IFLA_IPTUN_LINK */
+		nla_total_size(4) +
+		/* IFLA_IPTUN_LOCAL */
+		nla_total_size(sizeof(struct in6_addr)) +
+		/* IFLA_IPTUN_REMOTE */
+		nla_total_size(sizeof(struct in6_addr)) +
+		/* IFLA_IPTUN_TTL */
+		nla_total_size(1) +
+		/* IFLA_IPTUN_ENCAP_LIMIT */
+		nla_total_size(1) +
+		/* IFLA_IPTUN_FLOWINFO */
+		nla_total_size(4) +
+		/* IFLA_IPTUN_FLAGS */
+		nla_total_size(4) +
+		0;
+}
+
+static int ip6_fill_info(struct sk_buff *skb, const struct net_device *dev)
+{
+	struct ip6_tnl *tunnel = netdev_priv(dev);
+	struct __ip6_tnl_parm *parm = &tunnel->parms;
+
+	if (nla_put_u32(skb, IFLA_IPTUN_LINK, parm->link) ||
+	    nla_put(skb, IFLA_IPTUN_LOCAL, sizeof(struct in6_addr),
+		    &parm->raddr) ||
+	    nla_put(skb, IFLA_IPTUN_REMOTE, sizeof(struct in6_addr),
+		    &parm->laddr) ||
+	    nla_put_u8(skb, IFLA_IPTUN_TTL, parm->hop_limit) ||
+	    nla_put_u8(skb, IFLA_IPTUN_ENCAP_LIMIT, parm->encap_limit) ||
+	    nla_put_be32(skb, IFLA_IPTUN_FLOWINFO, parm->flowinfo) ||
+	    nla_put_u32(skb, IFLA_IPTUN_FLAGS, parm->flags))
+		goto nla_put_failure;
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+static struct rtnl_link_ops ip6_link_ops __read_mostly = {
+	.kind		= "ip6tnl",
+	.maxtype	= IFLA_IPTUN_MAX,
+	.priv_size	= sizeof(struct ip6_tnl),
+	.get_size	= ip6_get_size,
+	.fill_info	= ip6_fill_info,
+};
+
 static struct xfrm6_tunnel ip4ip6_handler __read_mostly = {
 	.handler	= ip4ip6_rcv,
 	.err_handler	= ip4ip6_err,
@@ -1612,9 +1663,14 @@ static int __init ip6_tunnel_init(void)
 		pr_err("%s: can't register ip6ip6\n", __func__);
 		goto out_ip6ip6;
 	}
+	err = rtnl_link_register(&ip6_link_ops);
+	if (err < 0)
+		goto rtnl_link_failed;
 
 	return 0;
 
+rtnl_link_failed:
+	xfrm6_tunnel_deregister(&ip6ip6_handler, AF_INET6);
 out_ip6ip6:
 	xfrm6_tunnel_deregister(&ip4ip6_handler, AF_INET);
 out_ip4ip6:
@@ -1629,6 +1685,7 @@ out_pernet:
 
 static void __exit ip6_tunnel_cleanup(void)
 {
+	rtnl_link_unregister(&ip6_link_ops);
 	if (xfrm6_tunnel_deregister(&ip4ip6_handler, AF_INET))
 		pr_info("%s: can't deregister ip4ip6\n", __func__);
 
-- 
1.7.12
