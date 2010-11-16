From: Thomas Graf <tgraf@infradead.org>
Subject: [PATCH net-next 3/4] ipv4: AF_INET link address family
Date: Tue, 16 Nov 2010 09:32:48 -0500
Message-ID: <20101116143248.GC26669@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:47281 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754749Ab0KPOcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 09:32:48 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implements the AF_INET link address family exposing the per
device configuration settings via netlink using the attribute
IFLA_INET_CONF.

The format of IFLA_INET_CONF differs depending on the direction
the attribute is sent. The attribute sent by the kernel consists
of a u32 array, basically a 1:1 copy of in_device->cnf.data[].
The attribute expected by the kernel must consist of a sequence
of nested u32 attributes, each representing a change request,
e.g.
	[IFLA_INET_CONF] = {
		[IPV4_DEVCONF_FORWARDING] = 1,
		[IPV4_DEVCONF_NOXFRM] = 0,
	}

libnl userspace API documentation and example available from:
http://www.infradead.org/~tgr/libnl/doc-git/group__link__inet.html

Signed-off-by: Thomas Graf <tgraf@infradead.org>

Index: net-next-2.6/net/ipv4/devinet.c
===================================================================
--- net-next-2.6.orig/net/ipv4/devinet.c
+++ net-next-2.6/net/ipv4/devinet.c
@@ -1256,6 +1256,72 @@ errout:
 		rtnl_set_sk_err(net, RTNLGRP_IPV4_IFADDR, err);
 }
 
+static size_t inet_get_link_af_size(const struct net_device *dev)
+{
+	struct in_device *in_dev = __in_dev_get_rcu(dev);
+
+	if (!in_dev)
+		return 0;
+
+	return nla_total_size(IPV4_DEVCONF_MAX * 4); /* IFLA_INET_CONF */
+}
+
+static int inet_fill_link_af(struct sk_buff *skb, const struct net_device *dev)
+{
+	struct in_device *in_dev = __in_dev_get_rcu(dev);
+	struct nlattr *nla;
+	int i;
+
+	if (!in_dev)
+		return -ENODATA;
+
+	nla = nla_reserve(skb, IFLA_INET_CONF, IPV4_DEVCONF_MAX * 4);
+	if (nla == NULL)
+		return -EMSGSIZE;
+
+	for (i = 0; i < IPV4_DEVCONF_MAX; i++)
+		((u32 *) nla_data(nla))[i] = in_dev->cnf.data[i];
+
+	return 0;
+}
+
+static const struct nla_policy inet_af_policy[IFLA_INET_MAX+1] = {
+	[IFLA_INET_CONF]	= { .type = NLA_NESTED },
+};
+
+static int inet_parse_link_af(struct net_device *dev, const struct nlattr *nla)
+{
+	struct in_device *in_dev = __in_dev_get_rcu(dev);
+	struct nlattr *a, *tb[IFLA_INET_MAX+1];
+	int err, rem;
+
+	if (!in_dev)
+		return -EOPNOTSUPP;
+
+	err = nla_parse_nested(tb, IFLA_INET_MAX, nla, inet_af_policy);
+	if (err < 0)
+		return err;
+
+	if (tb[IFLA_INET_CONF]) {
+		nla_for_each_nested(a, tb[IFLA_INET_CONF], rem) {
+			int cfgid = nla_type(a);
+
+			if (nla_len(a) < 4)
+				return -EINVAL;
+
+			if (cfgid <= 0 || cfgid > IPV4_DEVCONF_MAX)
+				return -EINVAL;
+		}
+	}
+
+	if (tb[IFLA_INET_CONF]) {
+		nla_for_each_nested(a, tb[IFLA_INET_CONF], rem)
+			ipv4_devconf_set(in_dev, nla_type(a), nla_get_u32(a));
+	}
+
+	return 0;
+}
+
 #ifdef CONFIG_SYSCTL
 
 static void devinet_copy_dflt_conf(struct net *net, int i)
@@ -1619,6 +1685,13 @@ static __net_initdata struct pernet_oper
 	.exit = devinet_exit_net,
 };
 
+static struct rtnl_af_ops inet_af_ops = {
+	.family		  = AF_INET,
+	.fill_link_af	  = inet_fill_link_af,
+	.get_link_af_size = inet_get_link_af_size,
+	.parse_link_af	  = inet_parse_link_af,
+};
+
 void __init devinet_init(void)
 {
 	register_pernet_subsys(&devinet_ops);
@@ -1626,6 +1699,8 @@ void __init devinet_init(void)
 	register_gifconf(PF_INET, inet_gifconf);
 	register_netdevice_notifier(&ip_netdev_notifier);
 
+	rtnl_af_register(&inet_af_ops);
+
 	rtnl_register(PF_INET, RTM_NEWADDR, inet_rtm_newaddr, NULL);
 	rtnl_register(PF_INET, RTM_DELADDR, inet_rtm_deladdr, NULL);
 	rtnl_register(PF_INET, RTM_GETADDR, NULL, inet_dump_ifaddr);
Index: net-next-2.6/include/linux/if_link.h
===================================================================
--- net-next-2.6.orig/include/linux/if_link.h
+++ net-next-2.6/include/linux/if_link.h
@@ -147,6 +147,14 @@ enum {
 #define IFLA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ifinfomsg))
 #endif
 
+enum {
+	IFLA_INET_UNSPEC,
+	IFLA_INET_CONF,
+	__IFLA_INET_MAX,
+};
+
+#define IFLA_INET_MAX (__IFLA_INET_MAX - 1)
+
 /* ifi_flags.
 
    IFF_* flags.
