From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: [PATCH net-next v2 2/5] net: add netlink_ext_ack argument to rtnl_link_ops.changelink
Date: Sun, 25 Jun 2017 23:56:00 +0200
Message-ID: <5cc33eef7e73931895b806a6151297a4408c4505.1498425679.git.mschiffer@universe-factory.net>
References: <cover.1498425679.git.mschiffer@universe-factory.net>
Cc: linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-can@vger.kernel.org,
        linux-ppp@vger.kernel.org, linux-wpan@vger.kernel.org
To: dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, j.vosburgh@gmail.com, vfalico@gmail.com,
        andy@greyhouse.net, wg@grandegger.com, mkl@pengutronix.de,
        pablo@netfilter.org, laforge@gnumonks.org, paulus@samba.org,
        jiri@resnulli.us, dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        davem@davemloft.net, stephen@networkplumber.org,
        arvid.brodin@alten.se, alex.aring@gmail.com,
        stefan@osg.samsung.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from chaos.universe-factory.net ([31.24.148.19]:42868 "EHLO
        chaos.universe-factory.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751370AbdFYV4P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2017 17:56:15 -0400
In-Reply-To: <cover.1498425679.git.mschiffer@universe-factory.net>
In-Reply-To: <cover.1498425679.git.mschiffer@universe-factory.net>
References: <cover.1498425679.git.mschiffer@universe-factory.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for extended error reporting.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
---
 drivers/infiniband/ulp/ipoib/ipoib_netlink.c | 7 ++++---
 drivers/net/bonding/bond_netlink.c           | 7 ++++---
 drivers/net/caif/caif_hsi.c                  | 3 ++-
 drivers/net/can/dev.c                        | 5 +++--
 drivers/net/ipvlan/ipvlan_main.c             | 3 ++-
 drivers/net/macsec.c                         | 3 ++-
 drivers/net/macvlan.c                        | 3 ++-
 drivers/net/vxlan.c                          | 3 ++-
 include/net/rtnetlink.h                      | 3 ++-
 net/8021q/vlan_netlink.c                     | 7 ++++---
 net/bridge/br_netlink.c                      | 5 +++--
 net/caif/chnl_net.c                          | 3 ++-
 net/core/rtnetlink.c                         | 2 +-
 net/ipv4/ip_gre.c                            | 3 ++-
 net/ipv4/ip_vti.c                            | 3 ++-
 net/ipv4/ipip.c                              | 3 ++-
 net/ipv6/ip6_gre.c                           | 3 ++-
 net/ipv6/ip6_tunnel.c                        | 3 ++-
 net/ipv6/ip6_vti.c                           | 3 ++-
 net/ipv6/sit.c                               | 3 ++-
 20 files changed, 47 insertions(+), 28 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_netlink.c b/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
index 8b75f80da56c..3e44087935ae 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
@@ -64,8 +64,9 @@ static int ipoib_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	return -EMSGSIZE;
 }
 
-static int ipoib_changelink(struct net_device *dev,
-			    struct nlattr *tb[], struct nlattr *data[])
+static int ipoib_changelink(struct net_device *dev, struct nlattr *tb[],
+			    struct nlattr *data[],
+			    struct netlink_ext_ack *extack)
 {
 	u16 mode, umcast;
 	int ret = 0;
@@ -134,7 +135,7 @@ static int ipoib_new_child_link(struct net *src_net, struct net_device *dev,
 			       child_pkey, IPOIB_RTNL_CHILD);
 
 	if (!err && data)
-		err = ipoib_changelink(dev, tb, data);
+		err = ipoib_changelink(dev, tb, data, extack);
 	return err;
 }
 
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index f817fb8005ef..cb803c026f1f 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -156,8 +156,9 @@ static int bond_slave_changelink(struct net_device *bond_dev,
 	return 0;
 }
 
-static int bond_changelink(struct net_device *bond_dev,
-			   struct nlattr *tb[], struct nlattr *data[])
+static int bond_changelink(struct net_device *bond_dev, struct nlattr *tb[],
+			   struct nlattr *data[],
+			   struct netlink_ext_ack *extack)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct bond_opt_value newval;
@@ -443,7 +444,7 @@ static int bond_newlink(struct net *src_net, struct net_device *bond_dev,
 {
 	int err;
 
-	err = bond_changelink(bond_dev, tb, data);
+	err = bond_changelink(bond_dev, tb, data, extack);
 	if (err < 0)
 		return err;
 
diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index ed4723a9031f..438966bf51c2 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -1352,7 +1352,8 @@ static void cfhsi_netlink_parms(struct nlattr *data[], struct cfhsi *cfhsi)
 }
 
 static int caif_hsi_changelink(struct net_device *dev, struct nlattr *tb[],
-				struct nlattr *data[])
+			       struct nlattr *data[],
+			       struct netlink_ext_ack *extack)
 {
 	cfhsi_netlink_parms(data, netdev_priv(dev));
 	netdev_state_change(dev);
diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 7f99e8a5dd09..6d8191f2ad32 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -880,8 +880,9 @@ static int can_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
-static int can_changelink(struct net_device *dev,
-			  struct nlattr *tb[], struct nlattr *data[])
+static int can_changelink(struct net_device *dev, struct nlattr *tb[],
+			  struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	struct can_priv *priv = netdev_priv(dev);
 	int err;
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 7bda5f630ac9..e7d54072d7b3 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -455,7 +455,8 @@ static const struct ethtool_ops ipvlan_ethtool_ops = {
 };
 
 static int ipvlan_nl_changelink(struct net_device *dev,
-				struct nlattr *tb[], struct nlattr *data[])
+				struct nlattr *tb[], struct nlattr *data[],
+				struct netlink_ext_ack *extack)
 {
 	struct ipvl_dev *ipvlan = netdev_priv(dev);
 	struct ipvl_port *port = ipvlan_port_get_rtnl(ipvlan->phy_dev);
diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 60f3e3089ec3..38ba3d73ac15 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -3056,7 +3056,8 @@ static void macsec_changelink_common(struct net_device *dev,
 }
 
 static int macsec_changelink(struct net_device *dev, struct nlattr *tb[],
-			     struct nlattr *data[])
+			     struct nlattr *data[],
+			     struct netlink_ext_ack *extack)
 {
 	if (!data)
 		return 0;
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 526d23db3b71..3064416578a9 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1409,7 +1409,8 @@ void macvlan_dellink(struct net_device *dev, struct list_head *head)
 EXPORT_SYMBOL_GPL(macvlan_dellink);
 
 static int macvlan_changelink(struct net_device *dev,
-		struct nlattr *tb[], struct nlattr *data[])
+			      struct nlattr *tb[], struct nlattr *data[],
+			      struct netlink_ext_ack *extack)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	enum macvlan_mode mode;
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 50a208747179..60c40349e73e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -3347,7 +3347,8 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 }
 
 static int vxlan_changelink(struct net_device *dev, struct nlattr *tb[],
-			    struct nlattr *data[])
+			    struct nlattr *data[],
+			    struct netlink_ext_ack *extack)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_rdst *dst = &vxlan->default_dst;
diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 33332a104ac5..f7d0320f75b0 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -72,7 +72,8 @@ struct rtnl_link_ops {
 					   struct netlink_ext_ack *extack);
 	int			(*changelink)(struct net_device *dev,
 					      struct nlattr *tb[],
-					      struct nlattr *data[]);
+					      struct nlattr *data[],
+					      struct netlink_ext_ack *extack);
 	void			(*dellink)(struct net_device *dev,
 					   struct list_head *head);
 
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index 11b74e2b1036..f08b5e192e45 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -87,8 +87,9 @@ static int vlan_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
-static int vlan_changelink(struct net_device *dev,
-			   struct nlattr *tb[], struct nlattr *data[])
+static int vlan_changelink(struct net_device *dev, struct nlattr *tb[],
+			   struct nlattr *data[],
+			   struct netlink_ext_ack *extack)
 {
 	struct ifla_vlan_flags *flags;
 	struct ifla_vlan_qos_mapping *m;
@@ -154,7 +155,7 @@ static int vlan_newlink(struct net *src_net, struct net_device *dev,
 	else if (dev->mtu > max_mtu)
 		return -EINVAL;
 
-	err = vlan_changelink(dev, tb, data);
+	err = vlan_changelink(dev, tb, data, extack);
 	if (err < 0)
 		return err;
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 39c1fa104c8d..37e4ec2953b2 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -960,7 +960,8 @@ static const struct nla_policy br_policy[IFLA_BR_MAX + 1] = {
 };
 
 static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
-			 struct nlattr *data[])
+			 struct nlattr *data[],
+			 struct netlink_ext_ack *extack)
 {
 	struct net_bridge *br = netdev_priv(brdev);
 	int err;
@@ -1229,7 +1230,7 @@ static int br_dev_newlink(struct net *src_net, struct net_device *dev,
 	if (err)
 		return err;
 
-	err = br_changelink(dev, tb, data);
+	err = br_changelink(dev, tb, data, extack);
 	if (err)
 		unregister_netdevice(dev);
 	return err;
diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index 3ad833cd042f..922ac1d605b3 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -485,7 +485,8 @@ static int ipcaif_newlink(struct net *src_net, struct net_device *dev,
 }
 
 static int ipcaif_changelink(struct net_device *dev, struct nlattr *tb[],
-			     struct nlattr *data[])
+			     struct nlattr *data[],
+			     struct netlink_ext_ack *extack)
 {
 	struct chnl_net *caifdev;
 	ASSERT_RTNL();
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 8b3faa00905f..bac81d1bb24d 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2620,7 +2620,7 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 				    !ops->changelink)
 					return -EOPNOTSUPP;
 
-				err = ops->changelink(dev, tb, data);
+				err = ops->changelink(dev, tb, data, extack);
 				if (err < 0)
 					return err;
 				status |= DO_SETLINK_NOTIFY;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 989f29f2f0d5..a63985c4bec7 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -980,7 +980,8 @@ static int ipgre_newlink(struct net *src_net, struct net_device *dev,
 }
 
 static int ipgre_changelink(struct net_device *dev, struct nlattr *tb[],
-			    struct nlattr *data[])
+			    struct nlattr *data[],
+			    struct netlink_ext_ack *extack)
 {
 	struct ip_tunnel *t = netdev_priv(dev);
 	struct ip_tunnel_parm p;
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index d748c5017d3b..24acff67a4f2 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -514,7 +514,8 @@ static int vti_newlink(struct net *src_net, struct net_device *dev,
 }
 
 static int vti_changelink(struct net_device *dev, struct nlattr *tb[],
-			  struct nlattr *data[])
+			  struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	struct ip_tunnel *t = netdev_priv(dev);
 	__u32 fwmark = t->fwmark;
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 51132060397d..eb7fe7b0046f 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -489,7 +489,8 @@ static int ipip_newlink(struct net *src_net, struct net_device *dev,
 }
 
 static int ipip_changelink(struct net_device *dev, struct nlattr *tb[],
-			   struct nlattr *data[])
+			   struct nlattr *data[],
+			   struct netlink_ext_ack *extack)
 {
 	struct ip_tunnel *t = netdev_priv(dev);
 	struct ip_tunnel_parm p;
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index f7c949d41fda..7232b28425f3 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1404,7 +1404,8 @@ static int ip6gre_newlink(struct net *src_net, struct net_device *dev,
 }
 
 static int ip6gre_changelink(struct net_device *dev, struct nlattr *tb[],
-			    struct nlattr *data[])
+			     struct nlattr *data[],
+			     struct netlink_ext_ack *extack)
 {
 	struct ip6_tnl *t, *nt = netdev_priv(dev);
 	struct net *net = nt->net;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index ca12b2e33ae3..d9f60a173107 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -2006,7 +2006,8 @@ static int ip6_tnl_newlink(struct net *src_net, struct net_device *dev,
 }
 
 static int ip6_tnl_changelink(struct net_device *dev, struct nlattr *tb[],
-			      struct nlattr *data[])
+			      struct nlattr *data[],
+			      struct netlink_ext_ack *extack)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
 	struct __ip6_tnl_parm p;
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 736a4f3f731d..2afdddb48e69 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -967,7 +967,8 @@ static void vti6_dellink(struct net_device *dev, struct list_head *head)
 }
 
 static int vti6_changelink(struct net_device *dev, struct nlattr *tb[],
-			   struct nlattr *data[])
+			   struct nlattr *data[],
+			   struct netlink_ext_ack *extack)
 {
 	struct ip6_tnl *t;
 	struct __ip6_tnl_parm p;
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index f7445fdb5e64..b8000429f78d 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1574,7 +1574,8 @@ static int ipip6_newlink(struct net *src_net, struct net_device *dev,
 }
 
 static int ipip6_changelink(struct net_device *dev, struct nlattr *tb[],
-			  struct nlattr *data[])
+			    struct nlattr *data[],
+			    struct netlink_ext_ack *extack)
 {
 	struct ip_tunnel *t = netdev_priv(dev);
 	struct ip_tunnel_parm p;
-- 
2.13.1
