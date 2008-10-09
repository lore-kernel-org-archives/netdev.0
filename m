From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/4] gre: Add netlink interface
Date: Thu, 09 Oct 2008 15:05:27 +0800
Message-ID: <E1KnpaR-0004PW-OB@gondolin.me.apana.org.au>
References: <20081009070424.GA16684@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53910 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755095AbYJIHFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 03:05:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gre: Add netlink interface

This patch adds a netlink interface that will eventually displace
the existing ioctl interface.  It utilises the elegant rtnl_link_ops
mechanism.

This also means that user-space no longer needs to rely on the
tunnel interface being of type GRE to identify GRE tunnels.  The
identification can now occur using rtnl_link_ops.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/if_tunnel.h |   19 +++
 net/ipv4/ip_gre.c         |  247 +++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 262 insertions(+), 4 deletions(-)

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index d4efe40..aeab2cb 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -2,6 +2,7 @@
 #define _IF_TUNNEL_H_
 
 #include <linux/types.h>
+#include <linux/ip.h>
 
 #define SIOCGETTUNNEL   (SIOCDEVPRIVATE + 0)
 #define SIOCADDTUNNEL   (SIOCDEVPRIVATE + 1)
@@ -47,4 +48,22 @@ struct ip_tunnel_prl {
 /* PRL flags */
 #define	PRL_DEFAULT		0x0001
 
+enum
+{
+	IFLA_GRE_UNSPEC,
+	IFLA_GRE_LINK,
+	IFLA_GRE_IFLAGS,
+	IFLA_GRE_OFLAGS,
+	IFLA_GRE_IKEY,
+	IFLA_GRE_OKEY,
+	IFLA_GRE_LOCAL,
+	IFLA_GRE_REMOTE,
+	IFLA_GRE_TTL,
+	IFLA_GRE_TOS,
+	IFLA_GRE_PMTUDISC,
+	__IFLA_GRE_MAX,
+};
+
+#define IFLA_GRE_MAX	(__IFLA_GRE_MAX - 1)
+
 #endif /* _IF_TUNNEL_H_ */
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 80622dd..25d2c77 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -41,6 +41,7 @@
 #include <net/xfrm.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
+#include <net/rtnetlink.h>
 
 #ifdef CONFIG_IPV6
 #include <net/ipv6.h>
@@ -117,6 +118,7 @@
    Alexey Kuznetsov.
  */
 
+static struct rtnl_link_ops ipgre_link_ops __read_mostly;
 static int ipgre_tunnel_init(struct net_device *dev);
 static void ipgre_tunnel_setup(struct net_device *dev);
 static int ipgre_tunnel_bind_dev(struct net_device *dev);
@@ -286,9 +288,9 @@ static struct ip_tunnel * ipgre_tunnel_locate(struct net *net,
 			goto failed_free;
 	}
 
-	dev->init = ipgre_tunnel_init;
 	nt = netdev_priv(dev);
 	nt->parms = *parms;
+	dev->rtnl_link_ops = &ipgre_link_ops;
 
 	dev->mtu = ipgre_tunnel_bind_dev(dev);
 
@@ -1087,6 +1089,7 @@ static int ipgre_close(struct net_device *dev)
 
 static void ipgre_tunnel_setup(struct net_device *dev)
 {
+	dev->init		= ipgre_tunnel_init;
 	dev->uninit		= ipgre_tunnel_uninit;
 	dev->destructor 	= free_netdev;
 	dev->hard_start_xmit	= ipgre_tunnel_xmit;
@@ -1196,6 +1199,7 @@ static int ipgre_init_net(struct net *net)
 
 	ign->fb_tunnel_dev->init = ipgre_fb_tunnel_init;
 	dev_net_set(ign->fb_tunnel_dev, net);
+	ign->fb_tunnel_dev->rtnl_link_ops = &ipgre_link_ops;
 
 	if ((err = register_netdev(ign->fb_tunnel_dev)))
 		goto err_reg_dev;
@@ -1228,6 +1232,229 @@ static struct pernet_operations ipgre_net_ops = {
 	.exit = ipgre_exit_net,
 };
 
+static int ipgre_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
+{
+	__be16 flags;
+
+	if (!data)
+		return 0;
+
+	flags = 0;
+	if (data[IFLA_GRE_IFLAGS])
+		flags |= nla_get_be16(data[IFLA_GRE_IFLAGS]);
+	if (data[IFLA_GRE_OFLAGS])
+		flags |= nla_get_be16(data[IFLA_GRE_OFLAGS]);
+	if (flags & (GRE_VERSION|GRE_ROUTING))
+		return -EINVAL;
+
+	return 0;
+}
+
+static void ipgre_netlink_parms(struct nlattr *data[],
+				struct ip_tunnel_parm *parms)
+{
+	memset(parms, 0, sizeof(parms));
+
+	parms->iph.protocol = IPPROTO_GRE;
+
+	if (!data)
+		return;
+
+	if (data[IFLA_GRE_LINK])
+		parms->link = nla_get_u32(data[IFLA_GRE_LINK]);
+
+	if (data[IFLA_GRE_IFLAGS])
+		parms->i_flags = nla_get_be16(data[IFLA_GRE_IFLAGS]);
+
+	if (data[IFLA_GRE_OFLAGS])
+		parms->o_flags = nla_get_be16(data[IFLA_GRE_OFLAGS]);
+
+	if (data[IFLA_GRE_IKEY])
+		parms->i_key = nla_get_be32(data[IFLA_GRE_IKEY]);
+
+	if (data[IFLA_GRE_OKEY])
+		parms->o_key = nla_get_be32(data[IFLA_GRE_OKEY]);
+
+	if (data[IFLA_GRE_LOCAL])
+		memcpy(&parms->iph.saddr, nla_data(data[IFLA_GRE_LOCAL]), 4);
+
+	if (data[IFLA_GRE_REMOTE])
+		memcpy(&parms->iph.daddr, nla_data(data[IFLA_GRE_REMOTE]), 4);
+
+	if (data[IFLA_GRE_TTL])
+		parms->iph.ttl = nla_get_u8(data[IFLA_GRE_TTL]);
+
+	if (data[IFLA_GRE_TOS])
+		parms->iph.tos = nla_get_u8(data[IFLA_GRE_TOS]);
+
+	if (!data[IFLA_GRE_PMTUDISC] || nla_get_u8(data[IFLA_GRE_PMTUDISC]))
+		parms->iph.frag_off = htons(IP_DF);
+}
+
+static int ipgre_newlink(struct net_device *dev, struct nlattr *tb[],
+			 struct nlattr *data[])
+{
+	struct ip_tunnel *nt;
+	struct net *net = dev_net(dev);
+	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
+	int mtu;
+	int err;
+
+	nt = netdev_priv(dev);
+	ipgre_netlink_parms(data, &nt->parms);
+
+	if (ipgre_tunnel_locate(net, &nt->parms, 0))
+		return -EEXIST;
+
+	mtu = ipgre_tunnel_bind_dev(dev);
+	if (!tb[IFLA_MTU])
+		dev->mtu = mtu;
+
+	err = register_netdevice(dev);
+	if (err)
+		goto out;
+
+	dev_hold(dev);
+	ipgre_tunnel_link(ign, nt);
+
+out:
+	return err;
+}
+
+static int ipgre_changelink(struct net_device *dev, struct nlattr *tb[],
+			    struct nlattr *data[])
+{
+	struct ip_tunnel *t, *nt;
+	struct net *net = dev_net(dev);
+	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
+	struct ip_tunnel_parm p;
+	int mtu;
+
+	if (dev == ign->fb_tunnel_dev)
+		return -EINVAL;
+
+	nt = netdev_priv(dev);
+	ipgre_netlink_parms(data, &p);
+
+	t = ipgre_tunnel_locate(net, &p, 0);
+
+	if (t) {
+		if (t->dev != dev)
+			return -EEXIST;
+	} else {
+		unsigned nflags = 0;
+
+		t = nt;
+
+		if (ipv4_is_multicast(p.iph.daddr))
+			nflags = IFF_BROADCAST;
+		else if (p.iph.daddr)
+			nflags = IFF_POINTOPOINT;
+
+		if ((dev->flags ^ nflags) &
+		    (IFF_POINTOPOINT | IFF_BROADCAST))
+			return -EINVAL;
+
+		ipgre_tunnel_unlink(ign, t);
+		t->parms.iph.saddr = p.iph.saddr;
+		t->parms.iph.daddr = p.iph.daddr;
+		t->parms.i_key = p.i_key;
+		memcpy(dev->dev_addr, &p.iph.saddr, 4);
+		memcpy(dev->broadcast, &p.iph.daddr, 4);
+		ipgre_tunnel_link(ign, t);
+		netdev_state_change(dev);
+	}
+
+	t->parms.o_key = p.o_key;
+	t->parms.iph.ttl = p.iph.ttl;
+	t->parms.iph.tos = p.iph.tos;
+	t->parms.iph.frag_off = p.iph.frag_off;
+
+	if (t->parms.link != p.link) {
+		t->parms.link = p.link;
+		mtu = ipgre_tunnel_bind_dev(dev);
+		if (!tb[IFLA_MTU])
+			dev->mtu = mtu;
+		netdev_state_change(dev);
+	}
+
+	return 0;
+}
+
+static size_t ipgre_get_size(const struct net_device *dev)
+{
+	return
+		/* IFLA_GRE_LINK */
+		nla_total_size(4) +
+		/* IFLA_GRE_IFLAGS */
+		nla_total_size(2) +
+		/* IFLA_GRE_OFLAGS */
+		nla_total_size(2) +
+		/* IFLA_GRE_IKEY */
+		nla_total_size(4) +
+		/* IFLA_GRE_OKEY */
+		nla_total_size(4) +
+		/* IFLA_GRE_LOCAL */
+		nla_total_size(4) +
+		/* IFLA_GRE_REMOTE */
+		nla_total_size(4) +
+		/* IFLA_GRE_TTL */
+		nla_total_size(1) +
+		/* IFLA_GRE_TOS */
+		nla_total_size(1) +
+		/* IFLA_GRE_PMTUDISC */
+		nla_total_size(1) +
+		0;
+}
+
+static int ipgre_fill_info(struct sk_buff *skb, const struct net_device *dev)
+{
+	struct ip_tunnel *t = netdev_priv(dev);
+	struct ip_tunnel_parm *p = &t->parms;
+
+	NLA_PUT_U32(skb, IFLA_GRE_LINK, p->link);
+	NLA_PUT_BE16(skb, IFLA_GRE_IFLAGS, p->i_flags);
+	NLA_PUT_BE16(skb, IFLA_GRE_OFLAGS, p->o_flags);
+	NLA_PUT_BE32(skb, IFLA_GRE_IFLAGS, p->i_flags);
+	NLA_PUT_BE32(skb, IFLA_GRE_OFLAGS, p->o_flags);
+	NLA_PUT(skb, IFLA_GRE_LOCAL, 4, &p->iph.saddr);
+	NLA_PUT(skb, IFLA_GRE_REMOTE, 4, &p->iph.daddr);
+	NLA_PUT_U8(skb, IFLA_GRE_TTL, p->iph.ttl);
+	NLA_PUT_U8(skb, IFLA_GRE_TOS, p->iph.tos);
+	NLA_PUT_U8(skb, IFLA_GRE_PMTUDISC, !!(p->iph.frag_off & htons(IP_DF)));
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+static const struct nla_policy ipgre_policy[IFLA_GRE_MAX + 1] = {
+	[IFLA_GRE_LINK]		= { .type = NLA_U32 },
+	[IFLA_GRE_IFLAGS]	= { .type = NLA_U16 },
+	[IFLA_GRE_OFLAGS]	= { .type = NLA_U16 },
+	[IFLA_GRE_IKEY]		= { .type = NLA_U32 },
+	[IFLA_GRE_OKEY]		= { .type = NLA_U32 },
+	[IFLA_GRE_LOCAL]	= { .len = 4 },
+	[IFLA_GRE_REMOTE]	= { .len = 4 },
+	[IFLA_GRE_TTL]		= { .type = NLA_U8 },
+	[IFLA_GRE_TOS]		= { .type = NLA_U8 },
+	[IFLA_GRE_PMTUDISC]	= { .type = NLA_U8 },
+};
+
+static struct rtnl_link_ops ipgre_link_ops __read_mostly = {
+	.kind		= "gre",
+	.maxtype	= IFLA_GRE_MAX,
+	.policy		= ipgre_policy,
+	.priv_size	= sizeof(struct ip_tunnel),
+	.setup		= ipgre_tunnel_setup,
+	.validate	= ipgre_tunnel_validate,
+	.newlink	= ipgre_newlink,
+	.changelink	= ipgre_changelink,
+	.get_size	= ipgre_get_size,
+	.fill_info	= ipgre_fill_info,
+};
+
 /*
  *	And now the modules code and kernel interface.
  */
@@ -1245,19 +1472,31 @@ static int __init ipgre_init(void)
 
 	err = register_pernet_gen_device(&ipgre_net_id, &ipgre_net_ops);
 	if (err < 0)
-		inet_del_protocol(&ipgre_protocol, IPPROTO_GRE);
+		goto gen_device_failed;
 
+	err = rtnl_link_register(&ipgre_link_ops);
+	if (err < 0)
+		goto rtnl_link_failed;
+
+out:
 	return err;
+
+rtnl_link_failed:
+	unregister_pernet_gen_device(ipgre_net_id, &ipgre_net_ops);
+gen_device_failed:
+	inet_del_protocol(&ipgre_protocol, IPPROTO_GRE);
+	goto out;
 }
 
 static void __exit ipgre_fini(void)
 {
+	rtnl_link_unregister(&ipgre_link_ops);
+	unregister_pernet_gen_device(ipgre_net_id, &ipgre_net_ops);
 	if (inet_del_protocol(&ipgre_protocol, IPPROTO_GRE) < 0)
 		printk(KERN_INFO "ipgre close: can't remove protocol\n");
-
-	unregister_pernet_gen_device(ipgre_net_id, &ipgre_net_ops);
 }
 
 module_init(ipgre_init);
 module_exit(ipgre_fini);
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("rtnl-link-gre");
