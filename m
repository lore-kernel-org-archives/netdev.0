From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 1/4] net: rtnetlink: make priv_size a function for devs
 with dynamic size
Date: Wed, 11 Sep 2013 11:46:21 -0700
Message-ID: <20130911184619.26914.7450.stgit@nitbit.x32>
References: <20130911184441.26914.10336.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: vfalico@redhat.com, john.ronciak@intel.com, netdev@vger.kernel.org,
	shannon.nelson@intel.com
To: stephen@networkplumber.org, bhutchings@solarflare.com,
	ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:65253 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755012Ab3IKSql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 14:46:41 -0400
Received: by mail-ob0-f178.google.com with SMTP id ef5so8962864obb.9
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 11:46:40 -0700 (PDT)
In-Reply-To: <20130911184441.26914.10336.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The priv_size rtnl_link_op today is a fixed size_t value.

For upcoming VSI support via rtnl_link_ops it is useful to allow this
size to be configurable. This patch converts the existing static
definition into a function that returns the size_t value.

To make this conversion as easy as possible the patch uses a new
macro RTNL_LINK_OPS_PRIV_SIZE which existing users can call to
generate a function equivalent to the previous static value.

RFC NOTE: I'm not entirely sure the macro makes the code easier
          to read or just obfuscates what is really happening.
          Any opinions?

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_netlink.c |    4 +++-
 drivers/net/bonding/bond_main.c              |    4 +++-
 drivers/net/caif/caif_hsi.c                  |    4 +++-
 drivers/net/ifb.c                            |    4 +++-
 drivers/net/macvlan.c                        |    4 +++-
 drivers/net/nlmon.c                          |    4 +++-
 drivers/net/team/team.c                      |    4 +++-
 drivers/net/tun.c                            |    4 +++-
 drivers/net/veth.c                           |    4 +++-
 drivers/net/vxlan.c                          |    4 +++-
 include/net/rtnetlink.h                      |   11 ++++++++++-
 net/8021q/vlan_netlink.c                     |    4 +++-
 net/bridge/br_netlink.c                      |    4 +++-
 net/core/rtnetlink.c                         |    2 +-
 net/ieee802154/6lowpan.c                     |    4 +++-
 net/ipv4/ip_gre.c                            |    6 ++++--
 net/ipv4/ip_tunnel.c                         |    2 +-
 net/ipv4/ip_vti.c                            |    4 +++-
 net/ipv4/ipip.c                              |    4 +++-
 net/ipv6/ip6_tunnel.c                        |    4 +++-
 net/ipv6/sit.c                               |    4 +++-
 21 files changed, 67 insertions(+), 22 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_netlink.c b/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
index f81abe1..8fd93fc 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
@@ -155,11 +155,13 @@ static size_t ipoib_get_size(const struct net_device *dev)
 		nla_total_size(2);	/* IFLA_IPOIB_UMCAST */
 }
 
+RTNL_LINK_OPS_PRIV_SIZE(ipoib, ipoib_dev_priv);
+
 static struct rtnl_link_ops ipoib_link_ops __read_mostly = {
 	.kind		= "ipoib",
 	.maxtype	= IFLA_IPOIB_MAX,
 	.policy		= ipoib_policy,
-	.priv_size	= sizeof(struct ipoib_dev_priv),
+	.priv_size	= ipoib_priv_size,
 	.setup		= ipoib_setup,
 	.newlink	= ipoib_new_child_link,
 	.changelink	= ipoib_changelink,
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 39e5b1c..1b3caf4 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4503,9 +4503,11 @@ static unsigned int bond_get_num_tx_queues(void)
 	return tx_queues;
 }
 
+RTNL_LINK_OPS_PRIV_SIZE(bond, bonding);
+
 static struct rtnl_link_ops bond_link_ops __read_mostly = {
 	.kind			= "bond",
-	.priv_size		= sizeof(struct bonding),
+	.priv_size		= bond_priv_size,
 	.setup			= bond_setup,
 	.validate		= bond_validate,
 	.get_num_tx_queues	= bond_get_num_tx_queues,
diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 5e40a8b..bf4f19a 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -1445,9 +1445,11 @@ err:
 	return -ENODEV;
 }
 
+RTNL_LINK_OPS_PRIV_SIZE(caif, cfhsi);
+
 static struct rtnl_link_ops caif_hsi_link_ops __read_mostly = {
 	.kind		= "cfhsi",
-	.priv_size	= sizeof(struct cfhsi),
+	.priv_size	= caif_priv_size,
 	.setup		= cfhsi_setup,
 	.maxtype	= __IFLA_CAIF_HSI_MAX,
 	.policy	= caif_hsi_policy,
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index a3bed28..ed8f5fa 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -251,9 +251,11 @@ static int ifb_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
+RTNL_LINK_OPS_PRIV_SIZE(ifb, ifb_private);
+
 static struct rtnl_link_ops ifb_link_ops __read_mostly = {
 	.kind		= "ifb",
-	.priv_size	= sizeof(struct ifb_private),
+	.priv_size	= ifb_priv_size,
 	.setup		= ifb_setup,
 	.validate	= ifb_validate,
 };
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 64dfaa3..6f293f7 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -934,10 +934,12 @@ static const struct nla_policy macvlan_policy[IFLA_MACVLAN_MAX + 1] = {
 	[IFLA_MACVLAN_FLAGS] = { .type = NLA_U16 },
 };
 
+RTNL_LINK_OPS_PRIV_SIZE(macvlan, macvlan_dev);
+
 int macvlan_link_register(struct rtnl_link_ops *ops)
 {
 	/* common fields */
-	ops->priv_size		= sizeof(struct macvlan_dev);
+	ops->priv_size		= macvlan_priv_size,
 	ops->validate		= macvlan_validate;
 	ops->maxtype		= IFLA_MACVLAN_MAX;
 	ops->policy		= macvlan_policy;
diff --git a/drivers/net/nlmon.c b/drivers/net/nlmon.c
index b57ce5f..693f357 100644
--- a/drivers/net/nlmon.c
+++ b/drivers/net/nlmon.c
@@ -154,9 +154,11 @@ static int nlmon_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
+RTNL_LINK_OPS_PRIV_SIZE(nlmon, nlmon);
+
 static struct rtnl_link_ops nlmon_link_ops __read_mostly = {
 	.kind			= "nlmon",
-	.priv_size		= sizeof(struct nlmon),
+	.priv_size		= nlmon_priv_size,
 	.setup			= nlmon_setup,
 	.validate		= nlmon_validate,
 };
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 50e43e6..b5f0526 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2068,9 +2068,11 @@ static unsigned int team_get_num_rx_queues(void)
 	return TEAM_DEFAULT_NUM_RX_QUEUES;
 }
 
+RTNL_LINK_OPS_PRIV_SIZE(team, team);
+
 static struct rtnl_link_ops team_link_ops __read_mostly = {
 	.kind			= DRV_NAME,
-	.priv_size		= sizeof(struct team),
+	.priv_size		= team_priv_size,
 	.setup			= team_setup,
 	.newlink		= team_newlink,
 	.validate		= team_validate,
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index a639de8..d5aebec 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1380,9 +1380,11 @@ static int tun_validate(struct nlattr *tb[], struct nlattr *data[])
 	return -EINVAL;
 }
 
+RTNL_LINK_OPS_PRIV_SIZE(tun, tun_struct);
+
 static struct rtnl_link_ops tun_link_ops __read_mostly = {
 	.kind		= DRV_NAME,
-	.priv_size	= sizeof(struct tun_struct),
+	.priv_size	= tun_priv_size,
 	.setup		= tun_setup,
 	.validate	= tun_validate,
 };
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index eee1f19..61f7122 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -434,9 +434,11 @@ static const struct nla_policy veth_policy[VETH_INFO_MAX + 1] = {
 	[VETH_INFO_PEER]	= { .len = sizeof(struct ifinfomsg) },
 };
 
+RTNL_LINK_OPS_PRIV_SIZE(veth, veth_priv);
+
 static struct rtnl_link_ops veth_link_ops = {
 	.kind		= DRV_NAME,
-	.priv_size	= sizeof(struct veth_priv),
+	.priv_size	= veth_priv_size,
 	.setup		= veth_setup,
 	.validate	= veth_validate,
 	.newlink	= veth_newlink,
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index bf64b41..cff4c45 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2616,11 +2616,13 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
+RTNL_LINK_OPS_PRIV_SIZE(vxlan, vxlan_dev);
+
 static struct rtnl_link_ops vxlan_link_ops __read_mostly = {
 	.kind		= "vxlan",
 	.maxtype	= IFLA_VXLAN_MAX,
 	.policy		= vxlan_policy,
-	.priv_size	= sizeof(struct vxlan_dev),
+	.priv_size	= vxlan_priv_size,
 	.setup		= vxlan_setup,
 	.validate	= vxlan_validate,
 	.newlink	= vxlan_newlink,
diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 7026648..b6a2ffb 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -4,6 +4,14 @@
 #include <linux/rtnetlink.h>
 #include <net/netlink.h>
 
+/* generate a get_priv function for simple field */
+#define RTNL_LINK_OPS_PRIV_SIZE(device, size_struct)		\
+static size_t device##_priv_size(struct net *src_net,		\
+				  struct nlattr *tb[])		\
+{								\
+	return sizeof(struct size_struct);			\
+}
+
 typedef int (*rtnl_doit_func)(struct sk_buff *, struct nlmsghdr *);
 typedef int (*rtnl_dumpit_func)(struct sk_buff *, struct netlink_callback *);
 typedef u16 (*rtnl_calcit_func)(struct sk_buff *, struct nlmsghdr *);
@@ -54,7 +62,8 @@ struct rtnl_link_ops {
 
 	const char		*kind;
 
-	size_t			priv_size;
+	size_t			(*priv_size)(struct net *src_net,
+					     struct nlattr *tb[]);
 	void			(*setup)(struct net_device *dev);
 
 	int			maxtype;
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index 3091297..6052370 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -238,11 +238,13 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
+RTNL_LINK_OPS_PRIV_SIZE(vlan, vlan_dev_priv);
+
 struct rtnl_link_ops vlan_link_ops __read_mostly = {
 	.kind		= "vlan",
 	.maxtype	= IFLA_VLAN_MAX,
 	.policy		= vlan_policy,
-	.priv_size	= sizeof(struct vlan_dev_priv),
+	.priv_size	= vlan_priv_size,
 	.setup		= vlan_setup,
 	.validate	= vlan_validate,
 	.newlink	= vlan_newlink,
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index b9259ef..3f4a792 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -469,9 +469,11 @@ static struct rtnl_af_ops br_af_ops = {
 	.get_link_af_size	= br_get_link_af_size,
 };
 
+RTNL_LINK_OPS_PRIV_SIZE(br, net_bridge);
+
 struct rtnl_link_ops br_link_ops __read_mostly = {
 	.kind		= "bridge",
-	.priv_size	= sizeof(struct net_bridge),
+	.priv_size	= br_priv_size,
 	.setup		= br_dev_setup,
 	.validate	= br_validate,
 	.dellink	= br_dev_delete,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 2a0e21d..76320fb 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1673,7 +1673,7 @@ struct net_device *rtnl_create_link(struct net *net,
 		num_rx_queues = ops->get_num_rx_queues();
 
 	err = -ENOMEM;
-	dev = alloc_netdev_mqs(ops->priv_size, ifname, ops->setup,
+	dev = alloc_netdev_mqs(ops->priv_size(net, tb), ifname, ops->setup,
 			       num_tx_queues, num_rx_queues);
 	if (!dev)
 		goto err;
diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index c85e71e..8ee9235 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -1420,9 +1420,11 @@ static void lowpan_dellink(struct net_device *dev, struct list_head *head)
 	dev_put(real_dev);
 }
 
+RTNL_LINK_OPS_PRIV_SIZE(lowpan, lowpan_dev_info);
+
 static struct rtnl_link_ops lowpan_link_ops __read_mostly = {
 	.kind		= "lowpan",
-	.priv_size	= sizeof(struct lowpan_dev_info),
+	.priv_size	= lowpan_priv_size,
 	.setup		= lowpan_setup,
 	.newlink	= lowpan_newlink,
 	.dellink	= lowpan_dellink,
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index d7aea4c..c3cfb7b 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -731,11 +731,13 @@ static const struct nla_policy ipgre_policy[IFLA_GRE_MAX + 1] = {
 	[IFLA_GRE_PMTUDISC]	= { .type = NLA_U8 },
 };
 
+RTNL_LINK_OPS_PRIV_SIZE(ipgre, ip_tunnel);
+
 static struct rtnl_link_ops ipgre_link_ops __read_mostly = {
 	.kind		= "gre",
 	.maxtype	= IFLA_GRE_MAX,
 	.policy		= ipgre_policy,
-	.priv_size	= sizeof(struct ip_tunnel),
+	.priv_size	= ipgre_priv_size,
 	.setup		= ipgre_tunnel_setup,
 	.validate	= ipgre_tunnel_validate,
 	.newlink	= ipgre_newlink,
@@ -749,7 +751,7 @@ static struct rtnl_link_ops ipgre_tap_ops __read_mostly = {
 	.kind		= "gretap",
 	.maxtype	= IFLA_GRE_MAX,
 	.policy		= ipgre_policy,
-	.priv_size	= sizeof(struct ip_tunnel),
+	.priv_size	= ipgre_priv_size,
 	.setup		= ipgre_tap_setup,
 	.validate	= ipgre_tap_validate,
 	.newlink	= ipgre_newlink,
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index ac9fabe..562dd12 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -293,7 +293,7 @@ static struct net_device *__ip_tunnel_create(struct net *net,
 	}
 
 	ASSERT_RTNL();
-	dev = alloc_netdev(ops->priv_size, name, ops->setup);
+	dev = alloc_netdev(ops->priv_size(net, NULL), name, ops->setup);
 	if (!dev) {
 		err = -ENOMEM;
 		goto failed;
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index e805e7b..545cc20 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -416,11 +416,13 @@ static const struct nla_policy vti_policy[IFLA_VTI_MAX + 1] = {
 	[IFLA_VTI_REMOTE]	= { .len = FIELD_SIZEOF(struct iphdr, daddr) },
 };
 
+RTNL_LINK_OPS_PRIV_SIZE(vti, ip_tunnel);
+
 static struct rtnl_link_ops vti_link_ops __read_mostly = {
 	.kind		= "vti",
 	.maxtype	= IFLA_VTI_MAX,
 	.policy		= vti_policy,
-	.priv_size	= sizeof(struct ip_tunnel),
+	.priv_size	= vti_priv_size,
 	.setup		= vti_tunnel_setup,
 	.validate	= vti_tunnel_validate,
 	.newlink	= vti_newlink,
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 7f80fb4..ee5a926 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -408,11 +408,13 @@ static const struct nla_policy ipip_policy[IFLA_IPTUN_MAX + 1] = {
 	[IFLA_IPTUN_PMTUDISC]		= { .type = NLA_U8 },
 };
 
+RTNL_LINK_OPS_PRIV_SIZE(ipip, ip_tunnel);
+
 static struct rtnl_link_ops ipip_link_ops __read_mostly = {
 	.kind		= "ipip",
 	.maxtype	= IFLA_IPTUN_MAX,
 	.policy		= ipip_policy,
-	.priv_size	= sizeof(struct ip_tunnel),
+	.priv_size	= ipip_priv_size,
 	.setup		= ipip_tunnel_setup,
 	.newlink	= ipip_newlink,
 	.changelink	= ipip_changelink,
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 61355f7..2ab41b9 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1682,11 +1682,13 @@ static const struct nla_policy ip6_tnl_policy[IFLA_IPTUN_MAX + 1] = {
 	[IFLA_IPTUN_PROTO]		= { .type = NLA_U8 },
 };
 
+RTNL_LINK_OPS_PRIV_SIZE(ip6_tnl, ip6_tnl);
+
 static struct rtnl_link_ops ip6_link_ops __read_mostly = {
 	.kind		= "ip6tnl",
 	.maxtype	= IFLA_IPTUN_MAX,
 	.policy		= ip6_tnl_policy,
-	.priv_size	= sizeof(struct ip6_tnl),
+	.priv_size	= ip6_tnl_priv_size,
 	.setup		= ip6_tnl_dev_setup,
 	.validate	= ip6_tnl_validate,
 	.newlink	= ip6_tnl_newlink,
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 7ee5cb9..bd638ba 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1540,11 +1540,13 @@ static const struct nla_policy ipip6_policy[IFLA_IPTUN_MAX + 1] = {
 #endif
 };
 
+RTNL_LINK_OPS_PRIV_SIZE(ipip6, ip_tunnel);
+
 static struct rtnl_link_ops sit_link_ops __read_mostly = {
 	.kind		= "sit",
 	.maxtype	= IFLA_IPTUN_MAX,
 	.policy		= ipip6_policy,
-	.priv_size	= sizeof(struct ip_tunnel),
+	.priv_size	= ipip6_priv_size,
 	.setup		= ipip6_tunnel_setup,
 	.validate	= ipip6_validate,
 	.newlink	= ipip6_newlink,
