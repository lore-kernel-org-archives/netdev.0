From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 03/10] ip6tnl: add support of link creation via rtnl
Date: Wed, 14 Nov 2012 16:14:00 +0100
Message-ID: <1352906047-11604-4-git-send-email-nicolas.dichtel@6wind.com>
References: <1352906047-11604-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34724 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964801Ab2KNPQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 10:16:11 -0500
In-Reply-To: <1352906047-11604-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add the support of 'ip link .. type ip6tnl'.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/ip6_tunnel.c | 164 +++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 149 insertions(+), 15 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 6d35426..c583a87 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -259,6 +259,33 @@ static void ip6_dev_free(struct net_device *dev)
 	free_netdev(dev);
 }
 
+static int ip6_tnl_create2(struct net_device *dev)
+{
+	struct ip6_tnl *t = netdev_priv(dev);
+	struct net *net = dev_net(dev);
+	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
+	int err;
+
+	t = netdev_priv(dev);
+	err = ip6_tnl_dev_init(dev);
+	if (err < 0)
+		goto out;
+
+	err = register_netdevice(dev);
+	if (err < 0)
+		goto out;
+
+	strcpy(t->parms.name, dev->name);
+	dev->rtnl_link_ops = &ip6_link_ops;
+
+	dev_hold(dev);
+	ip6_tnl_link(ip6n, t);
+	return 0;
+
+out:
+	return err;
+}
+
 /**
  * ip6_tnl_create - create a new tunnel
  *   @p: tunnel parameters
@@ -277,7 +304,6 @@ static struct ip6_tnl *ip6_tnl_create(struct net *net, struct __ip6_tnl_parm *p)
 	struct ip6_tnl *t;
 	char name[IFNAMSIZ];
 	int err;
-	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 
 	if (p->name[0])
 		strlcpy(name, p->name, IFNAMSIZ);
@@ -292,18 +318,10 @@ static struct ip6_tnl *ip6_tnl_create(struct net *net, struct __ip6_tnl_parm *p)
 
 	t = netdev_priv(dev);
 	t->parms = *p;
-	err = ip6_tnl_dev_init(dev);
+	err = ip6_tnl_create2(dev);
 	if (err < 0)
 		goto failed_free;
 
-	if ((err = register_netdevice(dev)) < 0)
-		goto failed_free;
-
-	strcpy(t->parms.name, dev->name);
-	dev->rtnl_link_ops = &ip6_link_ops;
-
-	dev_hold(dev);
-	ip6_tnl_link(ip6n, t);
 	return t;
 
 failed_free:
@@ -1238,6 +1256,20 @@ ip6_tnl_change(struct ip6_tnl *t, const struct __ip6_tnl_parm *p)
 	return 0;
 }
 
+static int ip6_tnl_update(struct ip6_tnl *t, struct __ip6_tnl_parm *p)
+{
+	struct net *net = dev_net(t->dev);
+	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
+	int err;
+
+	ip6_tnl_unlink(ip6n, t);
+	synchronize_net();
+	err = ip6_tnl_change(t, p);
+	ip6_tnl_link(ip6n, t);
+	netdev_state_change(t->dev);
+	return err;
+}
+
 static void
 ip6_tnl_parm_from_user(struct __ip6_tnl_parm *p, const struct ip6_tnl_parm *u)
 {
@@ -1346,11 +1378,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			} else
 				t = netdev_priv(dev);
 
-			ip6_tnl_unlink(ip6n, t);
-			synchronize_net();
-			err = ip6_tnl_change(t, &p1);
-			ip6_tnl_link(ip6n, t);
-			netdev_state_change(dev);
+			err = ip6_tnl_update(t, &p1);
 		}
 		if (t) {
 			err = 0;
@@ -1506,6 +1534,96 @@ static int __net_init ip6_fb_tnl_dev_init(struct net_device *dev)
 	return 0;
 }
 
+static int ip6_tnl_validate(struct nlattr *tb[], struct nlattr *data[])
+{
+	u8 proto;
+
+	if (!data)
+		return 0;
+
+	proto = nla_get_u8(data[IFLA_IPTUN_PROTO]);
+	if (proto != IPPROTO_IPV6 &&
+	    proto != IPPROTO_IPIP &&
+	    proto != 0)
+		return -EINVAL;
+
+	return 0;
+}
+
+static void ip6_tnl_netlink_parms(struct nlattr *data[],
+				  struct __ip6_tnl_parm *parms)
+{
+	memset(parms, 0, sizeof(*parms));
+
+	if (!data)
+		return;
+
+	if (data[IFLA_IPTUN_LINK])
+		parms->link = nla_get_u32(data[IFLA_IPTUN_LINK]);
+
+	if (data[IFLA_IPTUN_LOCAL])
+		nla_memcpy(&parms->laddr, data[IFLA_IPTUN_LOCAL],
+			   sizeof(struct in6_addr));
+
+	if (data[IFLA_IPTUN_REMOTE])
+		nla_memcpy(&parms->raddr, data[IFLA_IPTUN_REMOTE],
+			   sizeof(struct in6_addr));
+
+	if (data[IFLA_IPTUN_TTL])
+		parms->hop_limit = nla_get_u8(data[IFLA_IPTUN_TTL]);
+
+	if (data[IFLA_IPTUN_ENCAP_LIMIT])
+		parms->encap_limit = nla_get_u8(data[IFLA_IPTUN_ENCAP_LIMIT]);
+
+	if (data[IFLA_IPTUN_FLOWINFO])
+		parms->flowinfo = nla_get_u32(data[IFLA_IPTUN_FLOWINFO]);
+
+	if (data[IFLA_IPTUN_FLAGS])
+		parms->flags = nla_get_u32(data[IFLA_IPTUN_FLAGS]);
+
+	if (data[IFLA_IPTUN_PROTO])
+		parms->proto = nla_get_u8(data[IFLA_IPTUN_PROTO]);
+}
+
+static int ip6_tnl_newlink(struct net *src_net, struct net_device *dev,
+			   struct nlattr *tb[], struct nlattr *data[])
+{
+	struct net *net = dev_net(dev);
+	struct ip6_tnl *nt;
+
+	nt = netdev_priv(dev);
+	ip6_tnl_netlink_parms(data, &nt->parms);
+
+	if (ip6_tnl_locate(net, &nt->parms, 0))
+		return -EEXIST;
+
+	return ip6_tnl_create2(dev);
+}
+
+static int ip6_tnl_changelink(struct net_device *dev, struct nlattr *tb[],
+			      struct nlattr *data[])
+{
+	struct ip6_tnl *t;
+	struct __ip6_tnl_parm p;
+	struct net *net = dev_net(dev);
+	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
+
+	if (dev == ip6n->fb_tnl_dev)
+		return -EINVAL;
+
+	ip6_tnl_netlink_parms(data, &p);
+
+	t = ip6_tnl_locate(net, &p, 0);
+
+	if (t) {
+		if (t->dev != dev)
+			return -EEXIST;
+	} else
+		t = netdev_priv(dev);
+
+	return ip6_tnl_update(t, &p);
+}
+
 static size_t ip6_tnl_get_size(const struct net_device *dev)
 {
 	return
@@ -1550,10 +1668,26 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
+static const struct nla_policy ip6_tnl_policy[IFLA_IPTUN_MAX + 1] = {
+	[IFLA_IPTUN_LINK]		= { .type = NLA_U32 },
+	[IFLA_IPTUN_LOCAL]		= { .len = sizeof(struct in6_addr) },
+	[IFLA_IPTUN_REMOTE]		= { .len = sizeof(struct in6_addr) },
+	[IFLA_IPTUN_TTL]		= { .type = NLA_U8 },
+	[IFLA_IPTUN_ENCAP_LIMIT]	= { .type = NLA_U8 },
+	[IFLA_IPTUN_FLOWINFO]		= { .type = NLA_U32 },
+	[IFLA_IPTUN_FLAGS]		= { .type = NLA_U32 },
+	[IFLA_IPTUN_PROTO]		= { .type = NLA_U8 },
+};
+
 static struct rtnl_link_ops ip6_link_ops __read_mostly = {
 	.kind		= "ip6tnl",
 	.maxtype	= IFLA_IPTUN_MAX,
+	.policy		= ip6_tnl_policy,
 	.priv_size	= sizeof(struct ip6_tnl),
+	.setup		= ip6_tnl_dev_setup,
+	.validate	= ip6_tnl_validate,
+	.newlink	= ip6_tnl_newlink,
+	.changelink	= ip6_tnl_changelink,
 	.get_size	= ip6_tnl_get_size,
 	.fill_info	= ip6_tnl_fill_info,
 };
-- 
1.7.12
