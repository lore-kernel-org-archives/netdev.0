From: Jiri Benc <jbenc@redhat.com>
Subject: [RFC PATCH net-next 6/9] rtnetlink: add strict parameter to validate callbacks
Date: Thu, 15 Oct 2015 18:39:11 +0200
Message-ID: <09f92fe95abc7eeb284e14422a291b068eb7552f.1444926905.git.jbenc@redhat.com>
References: <cover.1444926905.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50114 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753167AbbJOQjl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 12:39:41 -0400
In-Reply-To: <cover.1444926905.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is in preparation for rtnetlink to be able to handle strict attribute
checking.

The only rtnl_link_ops users that can have nested attributes (and thus need
to know whether we're in strict validation mode or not) are 8021q and veth.
veth will be handled in a separate patch. 8021q is trivial, it just passes
the parameter through to nla_strict_validate_nested.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/bonding/bond_netlink.c |  3 ++-
 drivers/net/dummy.c                |  3 ++-
 drivers/net/geneve.c               |  3 ++-
 drivers/net/ifb.c                  |  3 ++-
 drivers/net/ipvlan/ipvlan_main.c   |  3 ++-
 drivers/net/macvlan.c              |  3 ++-
 drivers/net/nlmon.c                |  3 ++-
 drivers/net/team/team.c            |  3 ++-
 drivers/net/tun.c                  |  3 ++-
 drivers/net/veth.c                 |  5 +++--
 drivers/net/vrf.c                  |  3 ++-
 drivers/net/vxlan.c                |  3 ++-
 include/net/rtnetlink.h            |  6 ++++--
 net/8021q/vlan_netlink.c           | 12 +++++++-----
 net/bridge/br_netlink.c            |  3 ++-
 net/core/rtnetlink.c               |  5 +++--
 net/ieee802154/6lowpan/core.c      |  3 ++-
 net/ipv4/ip_gre.c                  |  8 +++++---
 net/ipv4/ip_vti.c                  |  3 ++-
 net/ipv6/ip6_gre.c                 |  8 +++++---
 net/ipv6/ip6_tunnel.c              |  3 ++-
 net/ipv6/ip6_vti.c                 |  3 ++-
 net/ipv6/sit.c                     |  3 ++-
 23 files changed, 61 insertions(+), 34 deletions(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index db760e84119f..71c7bfeb96f3 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -118,7 +118,8 @@ static const struct nla_policy bond_slave_policy[IFLA_BOND_SLAVE_MAX + 1] = {
 	[IFLA_BOND_SLAVE_QUEUE_ID]	= { .type = NLA_U16 },
 };
 
-static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
+static int bond_validate(struct nlattr *tb[], struct nlattr *data[],
+			 bool strict)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 815eb94990f5..45601fb973e3 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -152,7 +152,8 @@ static void dummy_setup(struct net_device *dev)
 	eth_hw_addr_random(dev);
 }
 
-static int dummy_validate(struct nlattr *tb[], struct nlattr *data[])
+static int dummy_validate(struct nlattr *tb[], struct nlattr *data[],
+			  bool strict)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 8f5c02eed47d..1b3e7bc649c7 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -765,7 +765,8 @@ static const struct nla_policy geneve_policy[IFLA_GENEVE_MAX + 1] = {
 	[IFLA_GENEVE_COLLECT_METADATA]	= { .type = NLA_FLAG },
 };
 
-static int geneve_validate(struct nlattr *tb[], struct nlattr *data[])
+static int geneve_validate(struct nlattr *tb[], struct nlattr *data[],
+			   bool strict)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index cc56fac3c3f8..ae2636e9cd7a 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -276,7 +276,8 @@ static int ifb_open(struct net_device *dev)
 	return 0;
 }
 
-static int ifb_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ifb_validate(struct nlattr *tb[], struct nlattr *data[],
+			bool strict)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index a9268db4e349..51e9353d0459 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -404,7 +404,8 @@ static size_t ipvlan_nl_getsize(const struct net_device *dev)
 		);
 }
 
-static int ipvlan_nl_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ipvlan_nl_validate(struct nlattr *tb[], struct nlattr *data[],
+			      bool strict)
 {
 	if (data && data[IFLA_IPVLAN_MODE]) {
 		u16 mode = nla_get_u16(data[IFLA_IPVLAN_MODE]);
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 86f6c6292c27..60b3fb556144 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1121,7 +1121,8 @@ static void macvlan_port_destroy(struct net_device *dev)
 	kfree_rcu(port, rcu);
 }
 
-static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
+static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[],
+			    bool strict)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
diff --git a/drivers/net/nlmon.c b/drivers/net/nlmon.c
index 7b7c70e2341e..3dd893cd0291 100644
--- a/drivers/net/nlmon.c
+++ b/drivers/net/nlmon.c
@@ -147,7 +147,8 @@ static void nlmon_setup(struct net_device *dev)
 	dev->mtu = NLMSG_GOODSIZE;
 }
 
-static int nlmon_validate(struct nlattr *tb[], struct nlattr *data[])
+static int nlmon_validate(struct nlattr *tb[], struct nlattr *data[],
+			  bool strict)
 {
 	if (tb[IFLA_ADDRESS])
 		return -EINVAL;
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 651d35ea22c5..e36e14db6f48 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2086,7 +2086,8 @@ static int team_newlink(struct net *src_net, struct net_device *dev,
 	return register_netdevice(dev);
 }
 
-static int team_validate(struct nlattr *tb[], struct nlattr *data[])
+static int team_validate(struct nlattr *tb[], struct nlattr *data[],
+			 bool strict)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index b1878faea397..610bafb3b1c2 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1468,7 +1468,8 @@ static void tun_setup(struct net_device *dev)
 /* Trivial set of netlink ops to allow deleting tun or tap
  * device with netlink.
  */
-static int tun_validate(struct nlattr *tb[], struct nlattr *data[])
+static int tun_validate(struct nlattr *tb[], struct nlattr *data[],
+			bool strict)
 {
 	return -EINVAL;
 }
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 0ef4a5ad5557..af0bf39147ba 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -327,7 +327,8 @@ static void veth_setup(struct net_device *dev)
  * netlink interface
  */
 
-static int veth_validate(struct nlattr *tb[], struct nlattr *data[])
+static int veth_validate(struct nlattr *tb[], struct nlattr *data[],
+			 bool strict)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
@@ -370,7 +371,7 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 		if (err < 0)
 			return err;
 
-		err = veth_validate(peer_tb, NULL);
+		err = veth_validate(peer_tb, NULL, false);
 		if (err < 0)
 			return err;
 
diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 92fa3e1ea65c..a3f9b4703a93 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -887,7 +887,8 @@ static void vrf_setup(struct net_device *dev)
 	dev->features |= NETIF_F_NETNS_LOCAL;
 }
 
-static int vrf_validate(struct nlattr *tb[], struct nlattr *data[])
+static int vrf_validate(struct nlattr *tb[], struct nlattr *data[],
+			bool strict)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ce704df7681b..764eaac91c97 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2478,7 +2478,8 @@ static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_REMCSUM_NOPARTIAL]	= { .type = NLA_FLAG },
 };
 
-static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
+static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[],
+			  bool strict)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN) {
diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 58bf1f5ad6a1..9f730f2395de 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -78,7 +78,8 @@ struct rtnl_link_ops {
 	int			maxtype;
 	const struct nla_policy	*policy;
 	int			(*validate)(struct nlattr *tb[],
-					    struct nlattr *data[]);
+					    struct nlattr *data[],
+					    bool strict);
 
 	int			(*newlink)(struct net *src_net,
 					   struct net_device *dev,
@@ -103,7 +104,8 @@ struct rtnl_link_ops {
 	int			slave_maxtype;
 	const struct nla_policy	*slave_policy;
 	int			(*slave_validate)(struct nlattr *tb[],
-						  struct nlattr *data[]);
+						  struct nlattr *data[],
+						  bool strict);
 	int			(*slave_changelink)(struct net_device *dev,
 						    struct net_device *slave_dev,
 						    struct nlattr *tb[],
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index c92b52f37d38..ba69c408312d 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -31,14 +31,16 @@ static const struct nla_policy vlan_map_policy[IFLA_VLAN_QOS_MAX + 1] = {
 };
 
 
-static inline int vlan_validate_qos_map(struct nlattr *attr)
+static inline int vlan_validate_qos_map(struct nlattr *attr, bool strict)
 {
 	if (!attr)
 		return 0;
-	return nla_validate_nested(attr, IFLA_VLAN_QOS_MAX, vlan_map_policy);
+	return nla_strict_validate_nested(attr, IFLA_VLAN_QOS_MAX, strict,
+					  vlan_map_policy);
 }
 
-static int vlan_validate(struct nlattr *tb[], struct nlattr *data[])
+static int vlan_validate(struct nlattr *tb[], struct nlattr *data[],
+			 bool strict)
 {
 	struct ifla_vlan_flags *flags;
 	u16 id;
@@ -77,10 +79,10 @@ static int vlan_validate(struct nlattr *tb[], struct nlattr *data[])
 			return -EINVAL;
 	}
 
-	err = vlan_validate_qos_map(data[IFLA_VLAN_INGRESS_QOS]);
+	err = vlan_validate_qos_map(data[IFLA_VLAN_INGRESS_QOS], strict);
 	if (err < 0)
 		return err;
-	err = vlan_validate_qos_map(data[IFLA_VLAN_EGRESS_QOS]);
+	err = vlan_validate_qos_map(data[IFLA_VLAN_EGRESS_QOS], strict);
 	if (err < 0)
 		return err;
 	return 0;
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 94b4de8c4646..f144344a3f38 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -746,7 +746,8 @@ int br_dellink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 
 	return err;
 }
-static int br_validate(struct nlattr *tb[], struct nlattr *data[])
+static int br_validate(struct nlattr *tb[], struct nlattr *data[],
+		       bool strict)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index dedc539b960c..205b7acbd6bf 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2197,7 +2197,7 @@ replay:
 				data = attr;
 			}
 			if (ops->validate) {
-				err = ops->validate(tb, data);
+				err = ops->validate(tb, data, false);
 				if (err < 0)
 					return err;
 			}
@@ -2215,7 +2215,8 @@ replay:
 				slave_data = slave_attr;
 			}
 			if (m_ops->slave_validate) {
-				err = m_ops->slave_validate(tb, slave_data);
+				err = m_ops->slave_validate(tb, slave_data,
+							    false);
 				if (err < 0)
 					return err;
 			}
diff --git a/net/ieee802154/6lowpan/core.c b/net/ieee802154/6lowpan/core.c
index 20c49c724ba0..145c1d4256e1 100644
--- a/net/ieee802154/6lowpan/core.c
+++ b/net/ieee802154/6lowpan/core.c
@@ -112,7 +112,8 @@ static void lowpan_setup(struct net_device *ldev)
 	ldev->features		|= NETIF_F_NETNS_LOCAL;
 }
 
-static int lowpan_validate(struct nlattr *tb[], struct nlattr *data[])
+static int lowpan_validate(struct nlattr *tb[], struct nlattr *data[],
+			   bool strict)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != IEEE802154_ADDR_LEN)
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index bd0679d90519..dd2b9801ed7a 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -881,7 +881,8 @@ static struct pernet_operations ipgre_net_ops = {
 	.size = sizeof(struct ip_tunnel_net),
 };
 
-static int ipgre_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ipgre_tunnel_validate(struct nlattr *tb[], struct nlattr *data[],
+				 bool strict)
 {
 	__be16 flags;
 
@@ -899,7 +900,8 @@ static int ipgre_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
-static int ipgre_tap_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ipgre_tap_validate(struct nlattr *tb[], struct nlattr *data[],
+			      bool strict)
 {
 	__be32 daddr;
 
@@ -920,7 +922,7 @@ static int ipgre_tap_validate(struct nlattr *tb[], struct nlattr *data[])
 	}
 
 out:
-	return ipgre_tunnel_validate(tb, data);
+	return ipgre_tunnel_validate(tb, data, strict);
 }
 
 static void ipgre_netlink_parms(struct net_device *dev,
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 4d8f0b698777..1e48c1fd74db 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -435,7 +435,8 @@ static struct pernet_operations vti_net_ops = {
 	.size = sizeof(struct ip_tunnel_net),
 };
 
-static int vti_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
+static int vti_tunnel_validate(struct nlattr *tb[], struct nlattr *data[],
+			       bool strict)
 {
 	return 0;
 }
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 3c7b9310b33f..58281ec6cc27 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1392,7 +1392,8 @@ static struct pernet_operations ip6gre_net_ops = {
 	.size = sizeof(struct ip6gre_net),
 };
 
-static int ip6gre_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ip6gre_tunnel_validate(struct nlattr *tb[], struct nlattr *data[],
+				  bool strict)
 {
 	__be16 flags;
 
@@ -1410,7 +1411,8 @@ static int ip6gre_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
-static int ip6gre_tap_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ip6gre_tap_validate(struct nlattr *tb[], struct nlattr *data[],
+			       bool strict)
 {
 	struct in6_addr daddr;
 
@@ -1431,7 +1433,7 @@ static int ip6gre_tap_validate(struct nlattr *tb[], struct nlattr *data[])
 	}
 
 out:
-	return ip6gre_tunnel_validate(tb, data);
+	return ip6gre_tunnel_validate(tb, data, strict);
 }
 
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index eabffbb89795..3fb0fcc50b47 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1683,7 +1683,8 @@ static int __net_init ip6_fb_tnl_dev_init(struct net_device *dev)
 	return 0;
 }
 
-static int ip6_tnl_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ip6_tnl_validate(struct nlattr *tb[], struct nlattr *data[],
+			    bool strict)
 {
 	u8 proto;
 
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 0a8610b33d79..abde61ddf9fa 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -899,7 +899,8 @@ static int __net_init vti6_fb_tnl_dev_init(struct net_device *dev)
 	return 0;
 }
 
-static int vti6_validate(struct nlattr *tb[], struct nlattr *data[])
+static int vti6_validate(struct nlattr *tb[], struct nlattr *data[],
+			 bool strict)
 {
 	return 0;
 }
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 94428fd85b2f..10b858a80183 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1424,7 +1424,8 @@ static int __net_init ipip6_fb_tunnel_init(struct net_device *dev)
 	return 0;
 }
 
-static int ipip6_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ipip6_validate(struct nlattr *tb[], struct nlattr *data[],
+			  bool strict)
 {
 	u8 proto;
 
-- 
1.8.3.1
