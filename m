From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 10/10] sit: add support of link creation via rtnl
Date: Wed, 14 Nov 2012 16:14:07 +0100
Message-ID: <1352906047-11604-11-git-send-email-nicolas.dichtel@6wind.com>
References: <1352906047-11604-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34755 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964816Ab2KNPQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 10:16:12 -0500
In-Reply-To: <1352906047-11604-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add the support of 'ip link .. type sit'.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/sit.c | 178 ++++++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 150 insertions(+), 28 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 28c1b82..7db6c54 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -232,6 +232,37 @@ static void ipip6_tunnel_clone_6rd(struct net_device *dev, struct sit_net *sitn)
 #endif
 }
 
+static int ipip6_tunnel_create(struct net_device *dev)
+{
+	struct ip_tunnel *t = netdev_priv(dev);
+	struct net *net = dev_net(dev);
+	struct sit_net *sitn = net_generic(net, sit_net_id);
+	int err;
+
+	err = ipip6_tunnel_init(dev);
+	if (err < 0)
+		goto out;
+	ipip6_tunnel_clone_6rd(dev, sitn);
+
+	if (t->parms.i_flags & SIT_ISATAP)
+		dev->priv_flags |= IFF_ISATAP;
+
+	err = register_netdevice(dev);
+	if (err < 0)
+		goto out;
+
+	strcpy(t->parms.name, dev->name);
+	dev->rtnl_link_ops = &sit_link_ops;
+
+	dev_hold(dev);
+
+	ipip6_tunnel_link(sitn, t);
+	return 0;
+
+out:
+	return err;
+}
+
 static struct ip_tunnel *ipip6_tunnel_locate(struct net *net,
 		struct ip_tunnel_parm *parms, int create)
 {
@@ -272,22 +303,9 @@ static struct ip_tunnel *ipip6_tunnel_locate(struct net *net,
 	nt = netdev_priv(dev);
 
 	nt->parms = *parms;
-	if (ipip6_tunnel_init(dev) < 0)
-		goto failed_free;
-	ipip6_tunnel_clone_6rd(dev, sitn);
-
-	if (parms->i_flags & SIT_ISATAP)
-		dev->priv_flags |= IFF_ISATAP;
-
-	if (register_netdevice(dev) < 0)
+	if (ipip6_tunnel_create(dev) < 0)
 		goto failed_free;
 
-	strcpy(nt->parms.name, dev->name);
-	dev->rtnl_link_ops = &sit_link_ops;
-
-	dev_hold(dev);
-
-	ipip6_tunnel_link(sitn, nt);
 	return nt;
 
 failed_free:
@@ -916,6 +934,27 @@ static void ipip6_tunnel_bind_dev(struct net_device *dev)
 	dev->iflink = tunnel->parms.link;
 }
 
+static void ipip6_tunnel_update(struct ip_tunnel *t, struct ip_tunnel_parm *p)
+{
+	struct net *net = dev_net(t->dev);
+	struct sit_net *sitn = net_generic(net, sit_net_id);
+
+	ipip6_tunnel_unlink(sitn, t);
+	synchronize_net();
+	t->parms.iph.saddr = p->iph.saddr;
+	t->parms.iph.daddr = p->iph.daddr;
+	memcpy(t->dev->dev_addr, &p->iph.saddr, 4);
+	memcpy(t->dev->broadcast, &p->iph.daddr, 4);
+	ipip6_tunnel_link(sitn, t);
+	t->parms.iph.ttl = p->iph.ttl;
+	t->parms.iph.tos = p->iph.tos;
+	if (t->parms.link != p->link) {
+		t->parms.link = p->link;
+		ipip6_tunnel_bind_dev(t->dev);
+	}
+	netdev_state_change(t->dev);
+}
+
 static int
 ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 {
@@ -999,20 +1038,7 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 				t = netdev_priv(dev);
 			}
 
-			ipip6_tunnel_unlink(sitn, t);
-			synchronize_net();
-			t->parms.iph.saddr = p.iph.saddr;
-			t->parms.iph.daddr = p.iph.daddr;
-			memcpy(dev->dev_addr, &p.iph.saddr, 4);
-			memcpy(dev->broadcast, &p.iph.daddr, 4);
-			ipip6_tunnel_link(sitn, t);
-			t->parms.iph.ttl = p.iph.ttl;
-			t->parms.iph.tos = p.iph.tos;
-			if (t->parms.link != p.link) {
-				t->parms.link = p.link;
-				ipip6_tunnel_bind_dev(dev);
-			}
-			netdev_state_change(dev);
+			ipip6_tunnel_update(t, &p);
 		}
 
 		if (t) {
@@ -1216,6 +1242,88 @@ static int __net_init ipip6_fb_tunnel_init(struct net_device *dev)
 	return 0;
 }
 
+static void ipip6_netlink_parms(struct nlattr *data[],
+				struct ip_tunnel_parm *parms)
+{
+	memset(parms, 0, sizeof(*parms));
+
+	parms->iph.version = 4;
+	parms->iph.protocol = IPPROTO_IPV6;
+	parms->iph.ihl = 5;
+	parms->iph.ttl = 64;
+
+	if (!data)
+		return;
+
+	if (data[IFLA_IPTUN_LINK])
+		parms->link = nla_get_u32(data[IFLA_IPTUN_LINK]);
+
+	if (data[IFLA_IPTUN_LOCAL])
+		parms->iph.saddr = nla_get_u32(data[IFLA_IPTUN_LOCAL]);
+
+	if (data[IFLA_IPTUN_REMOTE])
+		parms->iph.daddr = nla_get_u32(data[IFLA_IPTUN_REMOTE]);
+
+	if (data[IFLA_IPTUN_TTL]) {
+		parms->iph.ttl = nla_get_u8(data[IFLA_IPTUN_TTL]);
+		if (parms->iph.ttl)
+			parms->iph.frag_off = htons(IP_DF);
+	}
+
+	if (data[IFLA_IPTUN_TOS])
+		parms->iph.tos = nla_get_u8(data[IFLA_IPTUN_TOS]);
+
+	if (!data[IFLA_IPTUN_PMTUDISC] || nla_get_u8(data[IFLA_IPTUN_PMTUDISC]))
+		parms->iph.frag_off = htons(IP_DF);
+
+	if (data[IFLA_IPTUN_FLAGS])
+		parms->i_flags = nla_get_u16(data[IFLA_IPTUN_FLAGS]);
+}
+
+static int ipip6_newlink(struct net *src_net, struct net_device *dev,
+			 struct nlattr *tb[], struct nlattr *data[])
+{
+	struct net *net = dev_net(dev);
+	struct ip_tunnel *nt;
+
+	nt = netdev_priv(dev);
+	ipip6_netlink_parms(data, &nt->parms);
+
+	if (ipip6_tunnel_locate(net, &nt->parms, 0))
+		return -EEXIST;
+
+	return ipip6_tunnel_create(dev);
+}
+
+static int ipip6_changelink(struct net_device *dev, struct nlattr *tb[],
+			  struct nlattr *data[])
+{
+	struct ip_tunnel *t;
+	struct ip_tunnel_parm p;
+	struct net *net = dev_net(dev);
+	struct sit_net *sitn = net_generic(net, sit_net_id);
+
+	if (dev == sitn->fb_tunnel_dev)
+		return -EINVAL;
+
+	ipip6_netlink_parms(data, &p);
+
+	if (((dev->flags & IFF_POINTOPOINT) && !p.iph.daddr) ||
+	    (!(dev->flags & IFF_POINTOPOINT) && p.iph.daddr))
+		return -EINVAL;
+
+	t = ipip6_tunnel_locate(net, &p, 0);
+
+	if (t) {
+		if (t->dev != dev)
+			return -EEXIST;
+	} else
+		t = netdev_priv(dev);
+
+	ipip6_tunnel_update(t, &p);
+	return 0;
+}
+
 static size_t ipip6_get_size(const struct net_device *dev)
 {
 	return
@@ -1256,10 +1364,24 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
+static const struct nla_policy ipip6_policy[IFLA_IPTUN_MAX + 1] = {
+	[IFLA_IPTUN_LINK]		= { .type = NLA_U32 },
+	[IFLA_IPTUN_LOCAL]		= { .type = NLA_U32 },
+	[IFLA_IPTUN_REMOTE]		= { .type = NLA_U32 },
+	[IFLA_IPTUN_TTL]		= { .type = NLA_U8 },
+	[IFLA_IPTUN_TOS]		= { .type = NLA_U8 },
+	[IFLA_IPTUN_PMTUDISC]		= { .type = NLA_U8 },
+	[IFLA_IPTUN_FLAGS]		= { .type = NLA_U16 },
+};
+
 static struct rtnl_link_ops sit_link_ops __read_mostly = {
 	.kind		= "sit",
 	.maxtype	= IFLA_IPTUN_MAX,
+	.policy		= ipip6_policy,
 	.priv_size	= sizeof(struct ip_tunnel),
+	.setup		= ipip6_tunnel_setup,
+	.newlink	= ipip6_newlink,
+	.changelink	= ipip6_changelink,
 	.get_size	= ipip6_get_size,
 	.fill_info	= ipip6_fill_info,
 };
-- 
1.7.12
