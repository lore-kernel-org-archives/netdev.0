From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 2/4] sit: allow to configure 6rd tunnels via netlink
Date: Fri, 16 Nov 2012 17:14:14 +0100
Message-ID: <1353082456-21234-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1353082456-21234-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:37993 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148Ab2KPQNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 11:13:31 -0500
In-Reply-To: <1353082456-21234-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add the support of 6RD tunnels management via netlink.
Note that netdev_state_change() is now called when 6RD parameters are updated.

6RD parameters are updated only if there is at least one 6RD attribute.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/if_tunnel.h |   4 ++
 net/ipv6/sit.c                 | 149 ++++++++++++++++++++++++++++++++++-------
 2 files changed, 128 insertions(+), 25 deletions(-)

diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index 5ab0c8d..aee73d0 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -49,6 +49,10 @@ enum {
 	IFLA_IPTUN_FLAGS,
 	IFLA_IPTUN_PROTO,
 	IFLA_IPTUN_PMTUDISC,
+	IFLA_IPTUN_6RD_PREFIX,
+	IFLA_IPTUN_6RD_RELAY_PREFIX,
+	IFLA_IPTUN_6RD_PREFIXLEN,
+	IFLA_IPTUN_6RD_RELAY_PREFIXLEN,
 	__IFLA_IPTUN_MAX,
 };
 #define IFLA_IPTUN_MAX	(__IFLA_IPTUN_MAX - 1)
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index ca6c2c8..504422d 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -936,6 +936,38 @@ static void ipip6_tunnel_update(struct ip_tunnel *t, struct ip_tunnel_parm *p)
 	netdev_state_change(t->dev);
 }
 
+#ifdef CONFIG_IPV6_SIT_6RD
+static int ipip6_tunnel_update_6rd(struct ip_tunnel *t,
+				   struct ip_tunnel_6rd *ip6rd)
+{
+	struct in6_addr prefix;
+	__be32 relay_prefix;
+
+	if (ip6rd->relay_prefixlen > 32 ||
+	    ip6rd->prefixlen + (32 - ip6rd->relay_prefixlen) > 64)
+		return -EINVAL;
+
+	ipv6_addr_prefix(&prefix, &ip6rd->prefix, ip6rd->prefixlen);
+	if (!ipv6_addr_equal(&prefix, &ip6rd->prefix))
+		return -EINVAL;
+	if (ip6rd->relay_prefixlen)
+		relay_prefix = ip6rd->relay_prefix &
+			       htonl(0xffffffffUL <<
+				     (32 - ip6rd->relay_prefixlen));
+	else
+		relay_prefix = 0;
+	if (relay_prefix != ip6rd->relay_prefix)
+		return -EINVAL;
+
+	t->ip6rd.prefix = prefix;
+	t->ip6rd.relay_prefix = relay_prefix;
+	t->ip6rd.prefixlen = ip6rd->prefixlen;
+	t->ip6rd.relay_prefixlen = ip6rd->relay_prefixlen;
+	netdev_state_change(t->dev);
+	return 0;
+}
+#endif
+
 static int
 ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 {
@@ -1105,31 +1137,9 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 		t = netdev_priv(dev);
 
 		if (cmd != SIOCDEL6RD) {
-			struct in6_addr prefix;
-			__be32 relay_prefix;
-
-			err = -EINVAL;
-			if (ip6rd.relay_prefixlen > 32 ||
-			    ip6rd.prefixlen + (32 - ip6rd.relay_prefixlen) > 64)
-				goto done;
-
-			ipv6_addr_prefix(&prefix, &ip6rd.prefix,
-					 ip6rd.prefixlen);
-			if (!ipv6_addr_equal(&prefix, &ip6rd.prefix))
+			err = ipip6_tunnel_update_6rd(t, &ip6rd);
+			if (err < 0)
 				goto done;
-			if (ip6rd.relay_prefixlen)
-				relay_prefix = ip6rd.relay_prefix &
-					       htonl(0xffffffffUL <<
-						     (32 - ip6rd.relay_prefixlen));
-			else
-				relay_prefix = 0;
-			if (relay_prefix != ip6rd.relay_prefix)
-				goto done;
-
-			t->ip6rd.prefix = prefix;
-			t->ip6rd.relay_prefix = relay_prefix;
-			t->ip6rd.prefixlen = ip6rd.prefixlen;
-			t->ip6rd.relay_prefixlen = ip6rd.relay_prefixlen;
 		} else
 			ipip6_tunnel_clone_6rd(dev, sitn);
 
@@ -1261,11 +1271,53 @@ static void ipip6_netlink_parms(struct nlattr *data[],
 		parms->i_flags = nla_get_be16(data[IFLA_IPTUN_FLAGS]);
 }
 
+#ifdef CONFIG_IPV6_SIT_6RD
+/* This function returns true when 6RD attributes are present in the nl msg */
+static bool ipip6_netlink_6rd_parms(struct nlattr *data[],
+				    struct ip_tunnel_6rd *ip6rd)
+{
+	bool ret = false;
+	memset(ip6rd, 0, sizeof(*ip6rd));
+
+	if (!data)
+		return ret;
+
+	if (data[IFLA_IPTUN_6RD_PREFIX]) {
+		ret = true;
+		nla_memcpy(&ip6rd->prefix, data[IFLA_IPTUN_6RD_PREFIX],
+			   sizeof(struct in6_addr));
+	}
+
+	if (data[IFLA_IPTUN_6RD_RELAY_PREFIX]) {
+		ret = true;
+		ip6rd->relay_prefix =
+			nla_get_be32(data[IFLA_IPTUN_6RD_RELAY_PREFIX]);
+	}
+
+	if (data[IFLA_IPTUN_6RD_PREFIXLEN]) {
+		ret = true;
+		ip6rd->prefixlen = nla_get_u16(data[IFLA_IPTUN_6RD_PREFIXLEN]);
+	}
+
+	if (data[IFLA_IPTUN_6RD_RELAY_PREFIXLEN]) {
+		ret = true;
+		ip6rd->relay_prefixlen =
+			nla_get_u16(data[IFLA_IPTUN_6RD_RELAY_PREFIXLEN]);
+	}
+
+	return ret;
+}
+#endif
+
 static int ipip6_newlink(struct net *src_net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[])
 {
 	struct net *net = dev_net(dev);
 	struct ip_tunnel *nt;
+#ifdef CONFIG_IPV6_SIT_6RD
+	struct ip_tunnel_6rd ip6rd;
+#endif
+	int err;
 
 	nt = netdev_priv(dev);
 	ipip6_netlink_parms(data, &nt->parms);
@@ -1273,7 +1325,16 @@ static int ipip6_newlink(struct net *src_net, struct net_device *dev,
 	if (ipip6_tunnel_locate(net, &nt->parms, 0))
 		return -EEXIST;
 
-	return ipip6_tunnel_create(dev);
+	err = ipip6_tunnel_create(dev);
+	if (err < 0)
+		return err;
+
+#ifdef CONFIG_IPV6_SIT_6RD
+	if (ipip6_netlink_6rd_parms(data, &ip6rd))
+		err = ipip6_tunnel_update_6rd(nt, &ip6rd);
+#endif
+
+	return err;
 }
 
 static int ipip6_changelink(struct net_device *dev, struct nlattr *tb[],
@@ -1283,6 +1344,9 @@ static int ipip6_changelink(struct net_device *dev, struct nlattr *tb[],
 	struct ip_tunnel_parm p;
 	struct net *net = dev_net(dev);
 	struct sit_net *sitn = net_generic(net, sit_net_id);
+#ifdef CONFIG_IPV6_SIT_6RD
+	struct ip_tunnel_6rd ip6rd;
+#endif
 
 	if (dev == sitn->fb_tunnel_dev)
 		return -EINVAL;
@@ -1302,6 +1366,12 @@ static int ipip6_changelink(struct net_device *dev, struct nlattr *tb[],
 		t = netdev_priv(dev);
 
 	ipip6_tunnel_update(t, &p);
+
+#ifdef CONFIG_IPV6_SIT_6RD
+	if (ipip6_netlink_6rd_parms(data, &ip6rd))
+		return ipip6_tunnel_update_6rd(t, &ip6rd);
+#endif
+
 	return 0;
 }
 
@@ -1322,6 +1392,16 @@ static size_t ipip6_get_size(const struct net_device *dev)
 		nla_total_size(1) +
 		/* IFLA_IPTUN_FLAGS */
 		nla_total_size(2) +
+#ifdef CONFIG_IPV6_SIT_6RD
+		/* IFLA_IPTUN_6RD_PREFIX */
+		nla_total_size(sizeof(struct in6_addr)) +
+		/* IFLA_IPTUN_6RD_RELAY_PREFIX */
+		nla_total_size(4) +
+		/* IFLA_IPTUN_6RD_PREFIXLEN */
+		nla_total_size(2) +
+		/* IFLA_IPTUN_6RD_RELAY_PREFIXLEN */
+		nla_total_size(2) +
+#endif
 		0;
 }
 
@@ -1339,6 +1419,19 @@ static int ipip6_fill_info(struct sk_buff *skb, const struct net_device *dev)
 		       !!(parm->iph.frag_off & htons(IP_DF))) ||
 	    nla_put_be16(skb, IFLA_IPTUN_FLAGS, parm->i_flags))
 		goto nla_put_failure;
+
+#ifdef CONFIG_IPV6_SIT_6RD
+	if (nla_put(skb, IFLA_IPTUN_6RD_PREFIX, sizeof(struct in6_addr),
+		    &tunnel->ip6rd.prefix) ||
+	    nla_put_be32(skb, IFLA_IPTUN_6RD_RELAY_PREFIX,
+			 tunnel->ip6rd.relay_prefix) ||
+	    nla_put_u16(skb, IFLA_IPTUN_6RD_PREFIXLEN,
+			tunnel->ip6rd.prefixlen) ||
+	    nla_put_u16(skb, IFLA_IPTUN_6RD_RELAY_PREFIXLEN,
+			tunnel->ip6rd.relay_prefixlen))
+		goto nla_put_failure;
+#endif
+
 	return 0;
 
 nla_put_failure:
@@ -1353,6 +1446,12 @@ static const struct nla_policy ipip6_policy[IFLA_IPTUN_MAX + 1] = {
 	[IFLA_IPTUN_TOS]		= { .type = NLA_U8 },
 	[IFLA_IPTUN_PMTUDISC]		= { .type = NLA_U8 },
 	[IFLA_IPTUN_FLAGS]		= { .type = NLA_U16 },
+#ifdef CONFIG_IPV6_SIT_6RD
+	[IFLA_IPTUN_6RD_PREFIX]		= { .len = sizeof(struct in6_addr) },
+	[IFLA_IPTUN_6RD_RELAY_PREFIX]	= { .type = NLA_U32 },
+	[IFLA_IPTUN_6RD_PREFIXLEN]	= { .type = NLA_U16 },
+	[IFLA_IPTUN_6RD_RELAY_PREFIXLEN] = { .type = NLA_U16 },
+#endif
 };
 
 static struct rtnl_link_ops sit_link_ops __read_mostly = {
-- 
1.7.12
