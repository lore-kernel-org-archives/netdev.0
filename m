From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: [PATCH net-next] net: add netlink_ext_ack support to rtnl_link_ops
Date: Sat, 24 Jun 2017 13:35:17 +0200
Message-ID: <01256ebba091f2108ebeff43e61305bb533067d4.1498303258.git.mschiffer@universe-factory.net>
Cc: linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-can@vger.kernel.org,
        osmocom-net-gprs@lists.osmocom.org, linux-ppp@vger.kernel.org,
        linux-wpan@vger.kernel.org
To: dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, j.vosburgh@gmail.com, vfalico@gmail.com,
        andy@greyhouse.net, dmitry.tarnyagin@lockless.no,
        wg@grandegger.com, mkl@pengutronix.de, pablo@netfilter.org,
        laforge@gnumonks.org, paulus@samba.org, jiri@resnulli.us,
        dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        davem@davemloft.net, stephen@networkplumber.org,
        arvid.brodin@alten.se, alex.aring@gmail.com,
        stefan@osg.samsung.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        johannes@sipsolutions.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following functions are extended with a netlink_ext_ack argument to
allow extended error reporting:

* validate
* newlink
* changelink
* slave_validate
* slave_changelink

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
---

Checkpatch is unhappy about the long lines in include/net/rtnetlink.h, but
I guess it's as readable as it gets...

Most work was done by the following Coccinelle snippet, the original
version of which was provided by Johannes Berg:

@ops1@
identifier newfn, ops;
@@
struct rtnl_link_ops ops = {
	.newlink = newfn,
...
};

@@
identifier ops1.newfn;
identifier src_net, dev, tb, data;
@@
-int newfn(struct net *src_net, struct net_device *dev,
-	   struct nlattr *tb[], struct nlattr *data[])
+int newfn(struct net *src_net, struct net_device *dev,
+	   struct nlattr *tb[], struct nlattr *data[],
+	   struct netlink_ext_ack *extack)
{...}

@ops2@
identifier chfn, ops;
@@
struct rtnl_link_ops ops = {
	.changelink = chfn,
...
};

@@
identifier ops2.chfn;
identifier dev, tb, data;
@@
-int chfn(struct net_device *dev,
-	  struct nlattr *tb[], struct nlattr *data[])
+int chfn(struct net_device *dev,
+	  struct nlattr *tb[], struct nlattr *data[],
+	  struct netlink_ext_ack *extack)
{...}

@ops3@
identifier valfn, ops;
@@
struct rtnl_link_ops ops = {
	.validate = valfn,
...
};

@@
identifier ops3.valfn;
identifier tb, data;
@@
-int valfn(struct nlattr *tb[], struct nlattr *data[])
+int valfn(struct nlattr *tb[], struct nlattr *data[],
+	   struct netlink_ext_ack *extack)
{...}

@ops4@
identifier chfn, ops;
@@
struct rtnl_link_ops ops = {
	.slave_changelink = chfn,
...
};

@@
identifier ops4.chfn;
identifier dev, slave_dev, tb, data;
@@
-int chfn(struct net_device *dev, struct net_device *slave_dev,
-	  struct nlattr *tb[], struct nlattr *data[])
+int chfn(struct net_device *dev, struct net_device *slave_dev,
+	  struct nlattr *tb[], struct nlattr *data[],
+	  struct netlink_ext_ack *extack)
{...}

@ops5@
identifier valfn, ops;
@@
struct rtnl_link_ops ops = {
	.slave_validate = valfn,
...
};

@@
identifier ops5.valfn;
identifier tb, data;
@@
-int valfn(struct nlattr *tb[], struct nlattr *data[])
+int valfn(struct nlattr *tb[], struct nlattr *data[],
+	   struct netlink_ext_ack *extack)
{...}

 drivers/infiniband/ulp/ipoib/ipoib_netlink.c | 10 ++++++----
 drivers/net/bonding/bond_netlink.c           | 16 ++++++++++------
 drivers/net/caif/caif_hsi.c                  |  6 ++++--
 drivers/net/can/dev.c                        | 11 +++++++----
 drivers/net/can/vxcan.c                      |  3 ++-
 drivers/net/dummy.c                          |  3 ++-
 drivers/net/geneve.c                         |  6 ++++--
 drivers/net/gtp.c                            |  6 ++++--
 drivers/net/ifb.c                            |  3 ++-
 drivers/net/ipvlan/ipvlan.h                  |  3 ++-
 drivers/net/ipvlan/ipvlan_main.c             |  9 ++++++---
 drivers/net/ipvlan/ipvtap.c                  |  9 ++++-----
 drivers/net/macsec.c                         |  9 ++++++---
 drivers/net/macvlan.c                        |  9 ++++++---
 drivers/net/macvtap.c                        |  7 +++----
 drivers/net/nlmon.c                          |  3 ++-
 drivers/net/ppp/ppp_generic.c                |  6 ++++--
 drivers/net/team/team.c                      |  6 ++++--
 drivers/net/tun.c                            |  3 ++-
 drivers/net/veth.c                           |  8 +++++---
 drivers/net/vrf.c                            |  6 ++++--
 drivers/net/vxlan.c                          |  9 ++++++---
 include/net/rtnetlink.h                      | 15 ++++++++++-----
 net/8021q/vlan_netlink.c                     | 13 ++++++++-----
 net/bridge/br_netlink.c                      | 15 ++++++++++-----
 net/caif/chnl_net.c                          |  6 ++++--
 net/core/rtnetlink.c                         | 13 ++++++++-----
 net/hsr/hsr_netlink.c                        |  3 ++-
 net/ieee802154/6lowpan/core.c                |  6 ++++--
 net/ipv4/ip_gre.c                            | 16 ++++++++++------
 net/ipv4/ip_vti.c                            |  9 ++++++---
 net/ipv4/ipip.c                              |  9 ++++++---
 net/ipv6/ip6_gre.c                           | 14 +++++++++-----
 net/ipv6/ip6_tunnel.c                        |  9 ++++++---
 net/ipv6/ip6_vti.c                           |  9 ++++++---
 net/ipv6/sit.c                               |  9 ++++++---
 36 files changed, 190 insertions(+), 107 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_netlink.c b/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
index 28884781311b..3e44087935ae 100644
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
@@ -93,7 +94,8 @@ static int ipoib_changelink(struct net_device *dev,
 }
 
 static int ipoib_new_child_link(struct net *src_net, struct net_device *dev,
-			       struct nlattr *tb[], struct nlattr *data[])
+				struct nlattr *tb[], struct nlattr *data[],
+				struct netlink_ext_ack *extack)
 {
 	struct net_device *pdev;
 	struct ipoib_dev_priv *ppriv;
@@ -133,7 +135,7 @@ static int ipoib_new_child_link(struct net *src_net, struct net_device *dev,
 			       child_pkey, IPOIB_RTNL_CHILD);
 
 	if (!err && data)
-		err = ipoib_changelink(dev, tb, data);
+		err = ipoib_changelink(dev, tb, data, extack);
 	return err;
 }
 
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 47a8103610bc..a1b33aa6054a 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -118,7 +118,8 @@ static const struct nla_policy bond_slave_policy[IFLA_BOND_SLAVE_MAX + 1] = {
 	[IFLA_BOND_SLAVE_QUEUE_ID]	= { .type = NLA_U16 },
 };
 
-static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
+static int bond_validate(struct nlattr *tb[], struct nlattr *data[],
+			 struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
@@ -131,7 +132,8 @@ static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
 
 static int bond_slave_changelink(struct net_device *bond_dev,
 				 struct net_device *slave_dev,
-				 struct nlattr *tb[], struct nlattr *data[])
+				 struct nlattr *tb[], struct nlattr *data[],
+				 struct netlink_ext_ack *extack)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct bond_opt_value newval;
@@ -156,8 +158,9 @@ static int bond_slave_changelink(struct net_device *bond_dev,
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
@@ -438,11 +441,12 @@ static int bond_changelink(struct net_device *bond_dev,
 }
 
 static int bond_newlink(struct net *src_net, struct net_device *bond_dev,
-			struct nlattr *tb[], struct nlattr *data[])
+			struct nlattr *tb[], struct nlattr *data[],
+			struct netlink_ext_ack *extack)
 {
 	int err;
 
-	err = bond_changelink(bond_dev, tb, data);
+	err = bond_changelink(bond_dev, tb, data, extack);
 	if (err < 0)
 		return err;
 
diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 11ba6e3eea22..438966bf51c2 100644
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
@@ -1399,7 +1400,8 @@ static int caif_hsi_fill_info(struct sk_buff *skb, const struct net_device *dev)
 }
 
 static int caif_hsi_newlink(struct net *src_net, struct net_device *dev,
-			  struct nlattr *tb[], struct nlattr *data[])
+			    struct nlattr *tb[], struct nlattr *data[],
+			    struct netlink_ext_ack *extack)
 {
 	struct cfhsi *cfhsi = NULL;
 	struct cfhsi_ops *(*get_ops)(void);
diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index a3011c001080..365a8cc62405 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -848,7 +848,8 @@ static const struct nla_policy can_policy[IFLA_CAN_MAX + 1] = {
 				= { .len = sizeof(struct can_bittiming_const) },
 };
 
-static int can_validate(struct nlattr *tb[], struct nlattr *data[])
+static int can_validate(struct nlattr *tb[], struct nlattr *data[],
+			struct netlink_ext_ack *extack)
 {
 	bool is_can_fd = false;
 
@@ -880,8 +881,9 @@ static int can_validate(struct nlattr *tb[], struct nlattr *data[])
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
@@ -1146,7 +1148,8 @@ static int can_fill_xstats(struct sk_buff *skb, const struct net_device *dev)
 }
 
 static int can_newlink(struct net *src_net, struct net_device *dev,
-		       struct nlattr *tb[], struct nlattr *data[])
+		       struct nlattr *tb[], struct nlattr *data[],
+		       struct netlink_ext_ack *extack)
 {
 	return -EOPNOTSUPP;
 }
diff --git a/drivers/net/can/vxcan.c b/drivers/net/can/vxcan.c
index cfe889e8f172..8404e8852a0f 100644
--- a/drivers/net/can/vxcan.c
+++ b/drivers/net/can/vxcan.c
@@ -163,7 +163,8 @@ static void vxcan_setup(struct net_device *dev)
 static struct rtnl_link_ops vxcan_link_ops;
 
 static int vxcan_newlink(struct net *net, struct net_device *dev,
-			 struct nlattr *tb[], struct nlattr *data[])
+			 struct nlattr *tb[], struct nlattr *data[],
+			 struct netlink_ext_ack *extack)
 {
 	struct vxcan_priv *priv;
 	struct net_device *peer;
diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 9905b52fe293..d0c165d2086e 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -356,7 +356,8 @@ static void dummy_setup(struct net_device *dev)
 	dev->max_mtu = ETH_MAX_MTU;
 }
 
-static int dummy_validate(struct nlattr *tb[], struct nlattr *data[])
+static int dummy_validate(struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index d586ad93aaff..eb77201cb718 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1058,7 +1058,8 @@ static const struct nla_policy geneve_policy[IFLA_GENEVE_MAX + 1] = {
 	[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]	= { .type = NLA_U8 },
 };
 
-static int geneve_validate(struct nlattr *tb[], struct nlattr *data[])
+static int geneve_validate(struct nlattr *tb[], struct nlattr *data[],
+			   struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
@@ -1181,7 +1182,8 @@ static void init_tnl_info(struct ip_tunnel_info *info, __u16 dst_port)
 }
 
 static int geneve_newlink(struct net *net, struct net_device *dev,
-			  struct nlattr *tb[], struct nlattr *data[])
+			  struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	bool use_udp6_rx_checksums = false;
 	struct ip_tunnel_info info;
diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 8e333a8a2295..1542e837fdfa 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -636,7 +636,8 @@ static void gtp_hashtable_free(struct gtp_dev *gtp);
 static int gtp_encap_enable(struct gtp_dev *gtp, struct nlattr *data[]);
 
 static int gtp_newlink(struct net *src_net, struct net_device *dev,
-			struct nlattr *tb[], struct nlattr *data[])
+		       struct nlattr *tb[], struct nlattr *data[],
+		       struct netlink_ext_ack *extack)
 {
 	struct gtp_dev *gtp;
 	struct gtp_net *gn;
@@ -697,7 +698,8 @@ static const struct nla_policy gtp_policy[IFLA_GTP_MAX + 1] = {
 	[IFLA_GTP_ROLE]			= { .type = NLA_U32 },
 };
 
-static int gtp_validate(struct nlattr *tb[], struct nlattr *data[])
+static int gtp_validate(struct nlattr *tb[], struct nlattr *data[],
+			struct netlink_ext_ack *extack)
 {
 	if (!data)
 		return -EINVAL;
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 144ea5ae8ab4..8870bd2a2e8a 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -273,7 +273,8 @@ static int ifb_open(struct net_device *dev)
 	return 0;
 }
 
-static int ifb_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ifb_validate(struct nlattr *tb[], struct nlattr *data[],
+			struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index 7919369c0a72..ba8173a0b62e 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -140,7 +140,8 @@ unsigned int ipvlan_nf_input(void *priv, struct sk_buff *skb,
 void ipvlan_count_rx(const struct ipvl_dev *ipvlan,
 		     unsigned int len, bool success, bool mcast);
 int ipvlan_link_new(struct net *src_net, struct net_device *dev,
-		    struct nlattr *tb[], struct nlattr *data[]);
+		    struct nlattr *tb[], struct nlattr *data[],
+		    struct netlink_ext_ack *extack);
 void ipvlan_link_delete(struct net_device *dev, struct list_head *head);
 void ipvlan_link_setup(struct net_device *dev);
 int ipvlan_link_register(struct rtnl_link_ops *ops);
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index dc888dd344eb..f37e3c1fd4e7 100644
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
@@ -476,7 +477,8 @@ static size_t ipvlan_nl_getsize(const struct net_device *dev)
 		);
 }
 
-static int ipvlan_nl_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ipvlan_nl_validate(struct nlattr *tb[], struct nlattr *data[],
+			      struct netlink_ext_ack *extack)
 {
 	if (data && data[IFLA_IPVLAN_MODE]) {
 		u16 mode = nla_get_u16(data[IFLA_IPVLAN_MODE]);
@@ -508,7 +510,8 @@ static int ipvlan_nl_fillinfo(struct sk_buff *skb,
 }
 
 int ipvlan_link_new(struct net *src_net, struct net_device *dev,
-		    struct nlattr *tb[], struct nlattr *data[])
+		    struct nlattr *tb[], struct nlattr *data[],
+		    struct netlink_ext_ack *extack)
 {
 	struct ipvl_dev *ipvlan = netdev_priv(dev);
 	struct ipvl_port *port;
diff --git a/drivers/net/ipvlan/ipvtap.c b/drivers/net/ipvlan/ipvtap.c
index 2b713b63b62c..22f133ea8d7b 100644
--- a/drivers/net/ipvlan/ipvtap.c
+++ b/drivers/net/ipvlan/ipvtap.c
@@ -73,10 +73,9 @@ static void ipvtap_update_features(struct tap_dev *tap,
 	netdev_update_features(vlan->dev);
 }
 
-static int ipvtap_newlink(struct net *src_net,
-			  struct net_device *dev,
-			  struct nlattr *tb[],
-			  struct nlattr *data[])
+static int ipvtap_newlink(struct net *src_net, struct net_device *dev,
+			  struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	struct ipvtap_dev *vlantap = netdev_priv(dev);
 	int err;
@@ -98,7 +97,7 @@ static int ipvtap_newlink(struct net *src_net,
 	/* Don't put anything that may fail after macvlan_common_newlink
 	 * because we can't undo what it does.
 	 */
-	err =  ipvlan_link_new(src_net, dev, tb, data);
+	err =  ipvlan_link_new(src_net, dev, tb, data, extack);
 	if (err) {
 		netdev_rx_handler_unregister(dev);
 		return err;
diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index e370d7c894cb..5e1ab1160856 100644
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
@@ -3203,7 +3204,8 @@ static int macsec_add_dev(struct net_device *dev, sci_t sci, u8 icv_len)
 }
 
 static int macsec_newlink(struct net *net, struct net_device *dev,
-			  struct nlattr *tb[], struct nlattr *data[])
+			  struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	struct macsec_dev *macsec = macsec_priv(dev);
 	struct net_device *real_dev;
@@ -3285,7 +3287,8 @@ static int macsec_newlink(struct net *net, struct net_device *dev,
 	return err;
 }
 
-static int macsec_validate_attr(struct nlattr *tb[], struct nlattr *data[])
+static int macsec_validate_attr(struct nlattr *tb[], struct nlattr *data[],
+				struct netlink_ext_ack *extack)
 {
 	u64 csid = MACSEC_DEFAULT_CIPHER_ID;
 	u8 icv_len = DEFAULT_ICV_LEN;
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 8ca274c6df3d..9ffff0362a11 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1162,7 +1162,8 @@ static void macvlan_port_destroy(struct net_device *dev)
 	kfree(port);
 }
 
-static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
+static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[],
+			    struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
@@ -1390,7 +1391,8 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 EXPORT_SYMBOL_GPL(macvlan_common_newlink);
 
 static int macvlan_newlink(struct net *src_net, struct net_device *dev,
-			   struct nlattr *tb[], struct nlattr *data[])
+			   struct nlattr *tb[], struct nlattr *data[],
+			   struct netlink_ext_ack *extack)
 {
 	return macvlan_common_newlink(src_net, dev, tb, data);
 }
@@ -1408,7 +1410,8 @@ void macvlan_dellink(struct net_device *dev, struct list_head *head)
 EXPORT_SYMBOL_GPL(macvlan_dellink);
 
 static int macvlan_changelink(struct net_device *dev,
-		struct nlattr *tb[], struct nlattr *data[])
+			      struct nlattr *tb[], struct nlattr *data[],
+			      struct netlink_ext_ack *extack)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	enum macvlan_mode mode;
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index da85057680d6..91e7b19bbf86 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -77,10 +77,9 @@ static void macvtap_update_features(struct tap_dev *tap,
 	netdev_update_features(vlan->dev);
 }
 
-static int macvtap_newlink(struct net *src_net,
-			   struct net_device *dev,
-			   struct nlattr *tb[],
-			   struct nlattr *data[])
+static int macvtap_newlink(struct net *src_net, struct net_device *dev,
+			   struct nlattr *tb[], struct nlattr *data[],
+			   struct netlink_ext_ack *extack)
 {
 	struct macvtap_dev *vlantap = netdev_priv(dev);
 	int err;
diff --git a/drivers/net/nlmon.c b/drivers/net/nlmon.c
index c4b3362da4a2..4b22955de191 100644
--- a/drivers/net/nlmon.c
+++ b/drivers/net/nlmon.c
@@ -127,7 +127,8 @@ static void nlmon_setup(struct net_device *dev)
 	dev->min_mtu = sizeof(struct nlmsghdr);
 }
 
-static int nlmon_validate(struct nlattr *tb[], struct nlattr *data[])
+static int nlmon_validate(struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS])
 		return -EINVAL;
diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index d42091f11eb8..13028833bee3 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -1061,7 +1061,8 @@ static const struct nla_policy ppp_nl_policy[IFLA_PPP_MAX + 1] = {
 	[IFLA_PPP_DEV_FD]	= { .type = NLA_S32 },
 };
 
-static int ppp_nl_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ppp_nl_validate(struct nlattr *tb[], struct nlattr *data[],
+			   struct netlink_ext_ack *extack)
 {
 	if (!data)
 		return -EINVAL;
@@ -1075,7 +1076,8 @@ static int ppp_nl_validate(struct nlattr *tb[], struct nlattr *data[])
 }
 
 static int ppp_nl_newlink(struct net *src_net, struct net_device *dev,
-			  struct nlattr *tb[], struct nlattr *data[])
+			  struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	struct ppp_config conf = {
 		.unit = -1,
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 629a412dc690..464570409796 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2101,7 +2101,8 @@ static void team_setup(struct net_device *dev)
 }
 
 static int team_newlink(struct net *src_net, struct net_device *dev,
-			struct nlattr *tb[], struct nlattr *data[])
+			struct nlattr *tb[], struct nlattr *data[],
+			struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS] == NULL)
 		eth_hw_addr_random(dev);
@@ -2109,7 +2110,8 @@ static int team_newlink(struct net *src_net, struct net_device *dev,
 	return register_netdevice(dev);
 }
 
-static int team_validate(struct nlattr *tb[], struct nlattr *data[])
+static int team_validate(struct nlattr *tb[], struct nlattr *data[],
+			 struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index ae49f4b99b67..3d4c24572ecd 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1580,7 +1580,8 @@ static void tun_setup(struct net_device *dev)
 /* Trivial set of netlink ops to allow deleting tun or tap
  * device with netlink.
  */
-static int tun_validate(struct nlattr *tb[], struct nlattr *data[])
+static int tun_validate(struct nlattr *tb[], struct nlattr *data[],
+			struct netlink_ext_ack *extack)
 {
 	return -EINVAL;
 }
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 0156fe8cac17..b33553b1e19c 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -329,7 +329,8 @@ static void veth_setup(struct net_device *dev)
  * netlink interface
  */
 
-static int veth_validate(struct nlattr *tb[], struct nlattr *data[])
+static int veth_validate(struct nlattr *tb[], struct nlattr *data[],
+			 struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
@@ -347,7 +348,8 @@ static int veth_validate(struct nlattr *tb[], struct nlattr *data[])
 static struct rtnl_link_ops veth_link_ops;
 
 static int veth_newlink(struct net *src_net, struct net_device *dev,
-			 struct nlattr *tb[], struct nlattr *data[])
+			struct nlattr *tb[], struct nlattr *data[],
+			struct netlink_ext_ack *extack)
 {
 	int err;
 	struct net_device *peer;
@@ -373,7 +375,7 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 		if (err < 0)
 			return err;
 
-		err = veth_validate(peer_tb, NULL);
+		err = veth_validate(peer_tb, NULL, extack);
 		if (err < 0)
 			return err;
 
diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 997ef25189fd..f4d0054981c6 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -1372,7 +1372,8 @@ static void vrf_setup(struct net_device *dev)
 	dev->priv_flags |= IFF_NO_QUEUE;
 }
 
-static int vrf_validate(struct nlattr *tb[], struct nlattr *data[])
+static int vrf_validate(struct nlattr *tb[], struct nlattr *data[],
+			struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
@@ -1389,7 +1390,8 @@ static void vrf_dellink(struct net_device *dev, struct list_head *head)
 }
 
 static int vrf_newlink(struct net *src_net, struct net_device *dev,
-		       struct nlattr *tb[], struct nlattr *data[])
+		       struct nlattr *tb[], struct nlattr *data[],
+		       struct netlink_ext_ack *extack)
 {
 	struct net_vrf *vrf = netdev_priv(dev);
 	bool *add_fib_rules;
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 653b2bb32be1..0dafd8e6c665 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2711,7 +2711,8 @@ static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_REMCSUM_NOPARTIAL]	= { .type = NLA_FLAG },
 };
 
-static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
+static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN) {
@@ -3333,7 +3334,8 @@ static int vxlan_nl2conf(struct nlattr *tb[], struct nlattr *data[],
 }
 
 static int vxlan_newlink(struct net *src_net, struct net_device *dev,
-			 struct nlattr *tb[], struct nlattr *data[])
+			 struct nlattr *tb[], struct nlattr *data[],
+			 struct netlink_ext_ack *extack)
 {
 	struct vxlan_config conf;
 	int err;
@@ -3346,7 +3348,8 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 }
 
 static int vxlan_changelink(struct net_device *dev, struct nlattr *tb[],
-			    struct nlattr *data[])
+			    struct nlattr *data[],
+			    struct netlink_ext_ack *extack)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_rdst *dst = &vxlan->default_dst;
diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 78fa5fe32947..abe6b733d473 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -63,15 +63,18 @@ struct rtnl_link_ops {
 	int			maxtype;
 	const struct nla_policy	*policy;
 	int			(*validate)(struct nlattr *tb[],
-					    struct nlattr *data[]);
+					    struct nlattr *data[],
+					    struct netlink_ext_ack *extack);
 
 	int			(*newlink)(struct net *src_net,
 					   struct net_device *dev,
 					   struct nlattr *tb[],
-					   struct nlattr *data[]);
+					   struct nlattr *data[],
+					   struct netlink_ext_ack *extack);
 	int			(*changelink)(struct net_device *dev,
 					      struct nlattr *tb[],
-					      struct nlattr *data[]);
+					      struct nlattr *data[],
+					      struct netlink_ext_ack *extack);
 	void			(*dellink)(struct net_device *dev,
 					   struct list_head *head);
 
@@ -88,11 +91,13 @@ struct rtnl_link_ops {
 	int			slave_maxtype;
 	const struct nla_policy	*slave_policy;
 	int			(*slave_validate)(struct nlattr *tb[],
-						  struct nlattr *data[]);
+						  struct nlattr *data[],
+						  struct netlink_ext_ack *extack);
 	int			(*slave_changelink)(struct net_device *dev,
 						    struct net_device *slave_dev,
 						    struct nlattr *tb[],
-						    struct nlattr *data[]);
+						    struct nlattr *data[],
+						    struct netlink_ext_ack *extack);
 	size_t			(*get_slave_size)(const struct net_device *dev,
 						  const struct net_device *slave_dev);
 	int			(*fill_slave_info)(struct sk_buff *skb,
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index 9c94aad153b3..5e831de3103e 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -39,7 +39,8 @@ static inline int vlan_validate_qos_map(struct nlattr *attr)
 				   NULL);
 }
 
-static int vlan_validate(struct nlattr *tb[], struct nlattr *data[])
+static int vlan_validate(struct nlattr *tb[], struct nlattr *data[],
+			 struct netlink_ext_ack *extack)
 {
 	struct ifla_vlan_flags *flags;
 	u16 id;
@@ -87,8 +88,9 @@ static int vlan_validate(struct nlattr *tb[], struct nlattr *data[])
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
@@ -115,7 +117,8 @@ static int vlan_changelink(struct net_device *dev,
 }
 
 static int vlan_newlink(struct net *src_net, struct net_device *dev,
-			struct nlattr *tb[], struct nlattr *data[])
+			struct nlattr *tb[], struct nlattr *data[],
+			struct netlink_ext_ack *extack)
 {
 	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	struct net_device *real_dev;
@@ -153,7 +156,7 @@ static int vlan_newlink(struct net *src_net, struct net_device *dev,
 	else if (dev->mtu > max_mtu)
 		return -EINVAL;
 
-	err = vlan_changelink(dev, tb, data);
+	err = vlan_changelink(dev, tb, data, extack);
 	if (err < 0)
 		return err;
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 63dca347b73b..3bc890716c89 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -858,7 +858,9 @@ int br_dellink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 
 	return err;
 }
-static int br_validate(struct nlattr *tb[], struct nlattr *data[])
+
+static int br_validate(struct nlattr *tb[], struct nlattr *data[],
+		       struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
@@ -895,7 +897,8 @@ static int br_validate(struct nlattr *tb[], struct nlattr *data[])
 static int br_port_slave_changelink(struct net_device *brdev,
 				    struct net_device *dev,
 				    struct nlattr *tb[],
-				    struct nlattr *data[])
+				    struct nlattr *data[],
+				    struct netlink_ext_ack *extack)
 {
 	struct net_bridge *br = netdev_priv(brdev);
 	int ret;
@@ -960,7 +963,8 @@ static const struct nla_policy br_policy[IFLA_BR_MAX + 1] = {
 };
 
 static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
-			 struct nlattr *data[])
+			 struct nlattr *data[],
+			 struct netlink_ext_ack *extack)
 {
 	struct net_bridge *br = netdev_priv(brdev);
 	int err;
@@ -1213,7 +1217,8 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
 }
 
 static int br_dev_newlink(struct net *src_net, struct net_device *dev,
-			  struct nlattr *tb[], struct nlattr *data[])
+			  struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	struct net_bridge *br = netdev_priv(dev);
 	int err;
@@ -1228,7 +1233,7 @@ static int br_dev_newlink(struct net *src_net, struct net_device *dev,
 	if (err)
 		return err;
 
-	err = br_changelink(dev, tb, data);
+	err = br_changelink(dev, tb, data, extack);
 	if (err)
 		unregister_netdevice(dev);
 	return err;
diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index fe3c53efb949..922ac1d605b3 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -461,7 +461,8 @@ static void caif_netlink_parms(struct nlattr *data[],
 }
 
 static int ipcaif_newlink(struct net *src_net, struct net_device *dev,
-			  struct nlattr *tb[], struct nlattr *data[])
+			  struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	int ret;
 	struct chnl_net *caifdev;
@@ -484,7 +485,8 @@ static int ipcaif_newlink(struct net *src_net, struct net_device *dev,
 }
 
 static int ipcaif_changelink(struct net_device *dev, struct nlattr *tb[],
-			     struct nlattr *data[])
+			     struct nlattr *data[],
+			     struct netlink_ext_ack *extack)
 {
 	struct chnl_net *caifdev;
 	ASSERT_RTNL();
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9a1bd510c812..ed51de525a88 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2582,7 +2582,7 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 				data = attr;
 			}
 			if (ops->validate) {
-				err = ops->validate(tb, data);
+				err = ops->validate(tb, data, extack);
 				if (err < 0)
 					return err;
 			}
@@ -2601,7 +2601,8 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 				slave_data = slave_attr;
 			}
 			if (m_ops->slave_validate) {
-				err = m_ops->slave_validate(tb, slave_data);
+				err = m_ops->slave_validate(tb, slave_data,
+							    extack);
 				if (err < 0)
 					return err;
 			}
@@ -2620,7 +2621,7 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 				    !ops->changelink)
 					return -EOPNOTSUPP;
 
-				err = ops->changelink(dev, tb, data);
+				err = ops->changelink(dev, tb, data, extack);
 				if (err < 0)
 					return err;
 				status |= DO_SETLINK_NOTIFY;
@@ -2631,7 +2632,8 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 					return -EOPNOTSUPP;
 
 				err = m_ops->slave_changelink(master_dev, dev,
-							      tb, slave_data);
+							      tb, slave_data,
+							      extack);
 				if (err < 0)
 					return err;
 				status |= DO_SETLINK_NOTIFY;
@@ -2705,7 +2707,8 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 		dev->ifindex = ifm->ifi_index;
 
 		if (ops->newlink) {
-			err = ops->newlink(link_net ? : net, dev, tb, data);
+			err = ops->newlink(link_net ? : net, dev, tb, data,
+					   extack);
 			/* Drivers should call free_netdev() in ->destructor
 			 * and unregister it on failure after registration
 			 * so that device could be finally freed in rtnl_unlock.
diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
index 81dac16933fc..b9cce0fd5696 100644
--- a/net/hsr/hsr_netlink.c
+++ b/net/hsr/hsr_netlink.c
@@ -33,7 +33,8 @@ static const struct nla_policy hsr_policy[IFLA_HSR_MAX + 1] = {
  * hsr_dev_setup routine has been executed. Nice!
  */
 static int hsr_newlink(struct net *src_net, struct net_device *dev,
-		       struct nlattr *tb[], struct nlattr *data[])
+		       struct nlattr *tb[], struct nlattr *data[],
+		       struct netlink_ext_ack *extack)
 {
 	struct net_device *link[2];
 	unsigned char multicast_spec, hsr_version;
diff --git a/net/ieee802154/6lowpan/core.c b/net/ieee802154/6lowpan/core.c
index 0a866f332290..de2661cd0328 100644
--- a/net/ieee802154/6lowpan/core.c
+++ b/net/ieee802154/6lowpan/core.c
@@ -111,7 +111,8 @@ static void lowpan_setup(struct net_device *ldev)
 	ldev->features		|= NETIF_F_NETNS_LOCAL;
 }
 
-static int lowpan_validate(struct nlattr *tb[], struct nlattr *data[])
+static int lowpan_validate(struct nlattr *tb[], struct nlattr *data[],
+			   struct netlink_ext_ack *extack)
 {
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != IEEE802154_ADDR_LEN)
@@ -121,7 +122,8 @@ static int lowpan_validate(struct nlattr *tb[], struct nlattr *data[])
 }
 
 static int lowpan_newlink(struct net *src_net, struct net_device *ldev,
-			  struct nlattr *tb[], struct nlattr *data[])
+			  struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	struct net_device *wdev;
 	int ret;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 41394a4b9af9..7a7829e839c2 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -779,7 +779,8 @@ static struct pernet_operations ipgre_net_ops = {
 	.size = sizeof(struct ip_tunnel_net),
 };
 
-static int ipgre_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ipgre_tunnel_validate(struct nlattr *tb[], struct nlattr *data[],
+				 struct netlink_ext_ack *extack)
 {
 	__be16 flags;
 
@@ -802,7 +803,8 @@ static int ipgre_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
-static int ipgre_tap_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ipgre_tap_validate(struct nlattr *tb[], struct nlattr *data[],
+			      struct netlink_ext_ack *extack)
 {
 	__be32 daddr;
 
@@ -823,7 +825,7 @@ static int ipgre_tap_validate(struct nlattr *tb[], struct nlattr *data[])
 	}
 
 out:
-	return ipgre_tunnel_validate(tb, data);
+	return ipgre_tunnel_validate(tb, data, extack);
 }
 
 static int ipgre_netlink_parms(struct net_device *dev,
@@ -957,7 +959,8 @@ static void ipgre_tap_setup(struct net_device *dev)
 }
 
 static int ipgre_newlink(struct net *src_net, struct net_device *dev,
-			 struct nlattr *tb[], struct nlattr *data[])
+			 struct nlattr *tb[], struct nlattr *data[],
+			 struct netlink_ext_ack *extack)
 {
 	struct ip_tunnel_parm p;
 	struct ip_tunnel_encap ipencap;
@@ -979,7 +982,8 @@ static int ipgre_newlink(struct net *src_net, struct net_device *dev,
 }
 
 static int ipgre_changelink(struct net_device *dev, struct nlattr *tb[],
-			    struct nlattr *data[])
+			    struct nlattr *data[],
+			    struct netlink_ext_ack *extack)
 {
 	struct ip_tunnel *t = netdev_priv(dev);
 	struct ip_tunnel_parm p;
@@ -1155,7 +1159,7 @@ struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
 	t = netdev_priv(dev);
 	t->collect_md = true;
 
-	err = ipgre_newlink(net, dev, tb, NULL);
+	err = ipgre_newlink(net, dev, tb, NULL, NULL);
 	if (err < 0) {
 		free_netdev(dev);
 		return ERR_PTR(err);
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 4ec9affb2252..0192c255e508 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -465,7 +465,8 @@ static struct pernet_operations vti_net_ops = {
 	.size = sizeof(struct ip_tunnel_net),
 };
 
-static int vti_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
+static int vti_tunnel_validate(struct nlattr *tb[], struct nlattr *data[],
+			       struct netlink_ext_ack *extack)
 {
 	return 0;
 }
@@ -503,7 +504,8 @@ static void vti_netlink_parms(struct nlattr *data[],
 }
 
 static int vti_newlink(struct net *src_net, struct net_device *dev,
-		       struct nlattr *tb[], struct nlattr *data[])
+		       struct nlattr *tb[], struct nlattr *data[],
+		       struct netlink_ext_ack *extack)
 {
 	struct ip_tunnel_parm parms;
 	__u32 fwmark = 0;
@@ -513,7 +515,8 @@ static int vti_newlink(struct net *src_net, struct net_device *dev,
 }
 
 static int vti_changelink(struct net_device *dev, struct nlattr *tb[],
-			  struct nlattr *data[])
+			  struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	struct ip_tunnel *t = netdev_priv(dev);
 	__u32 fwmark = t->fwmark;
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 1e441c6f2160..fb1ad22b5e29 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -375,7 +375,8 @@ static int ipip_tunnel_init(struct net_device *dev)
 	return ip_tunnel_init(dev);
 }
 
-static int ipip_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ipip_tunnel_validate(struct nlattr *tb[], struct nlattr *data[],
+				struct netlink_ext_ack *extack)
 {
 	u8 proto;
 
@@ -469,7 +470,8 @@ static bool ipip_netlink_encap_parms(struct nlattr *data[],
 }
 
 static int ipip_newlink(struct net *src_net, struct net_device *dev,
-			struct nlattr *tb[], struct nlattr *data[])
+			struct nlattr *tb[], struct nlattr *data[],
+			struct netlink_ext_ack *extack)
 {
 	struct ip_tunnel *t = netdev_priv(dev);
 	struct ip_tunnel_parm p;
@@ -488,7 +490,8 @@ static int ipip_newlink(struct net *src_net, struct net_device *dev,
 }
 
 static int ipip_changelink(struct net_device *dev, struct nlattr *tb[],
-			   struct nlattr *data[])
+			   struct nlattr *data[],
+			   struct netlink_ext_ack *extack)
 {
 	struct ip_tunnel *t = netdev_priv(dev);
 	struct ip_tunnel_parm p;
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index e0e726c338a7..67ff2aaf5dcb 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1170,7 +1170,8 @@ static struct pernet_operations ip6gre_net_ops = {
 	.size = sizeof(struct ip6gre_net),
 };
 
-static int ip6gre_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ip6gre_tunnel_validate(struct nlattr *tb[], struct nlattr *data[],
+				  struct netlink_ext_ack *extack)
 {
 	__be16 flags;
 
@@ -1188,7 +1189,8 @@ static int ip6gre_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
-static int ip6gre_tap_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ip6gre_tap_validate(struct nlattr *tb[], struct nlattr *data[],
+			       struct netlink_ext_ack *extack)
 {
 	struct in6_addr daddr;
 
@@ -1209,7 +1211,7 @@ static int ip6gre_tap_validate(struct nlattr *tb[], struct nlattr *data[])
 	}
 
 out:
-	return ip6gre_tunnel_validate(tb, data);
+	return ip6gre_tunnel_validate(tb, data, extack);
 }
 
 
@@ -1342,7 +1344,8 @@ static bool ip6gre_netlink_encap_parms(struct nlattr *data[],
 }
 
 static int ip6gre_newlink(struct net *src_net, struct net_device *dev,
-	struct nlattr *tb[], struct nlattr *data[])
+			  struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	struct ip6_tnl *nt;
 	struct net *net = dev_net(dev);
@@ -1403,7 +1406,8 @@ static int ip6gre_newlink(struct net *src_net, struct net_device *dev,
 }
 
 static int ip6gre_changelink(struct net_device *dev, struct nlattr *tb[],
-			    struct nlattr *data[])
+			     struct nlattr *data[],
+			     struct netlink_ext_ack *extack)
 {
 	struct ip6_tnl *t, *nt = netdev_priv(dev);
 	struct net *net = nt->net;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 8c6c3c8e7eef..3a0ba2ae4b0f 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1885,7 +1885,8 @@ static int __net_init ip6_fb_tnl_dev_init(struct net_device *dev)
 	return 0;
 }
 
-static int ip6_tnl_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ip6_tnl_validate(struct nlattr *tb[], struct nlattr *data[],
+			    struct netlink_ext_ack *extack)
 {
 	u8 proto;
 
@@ -1974,7 +1975,8 @@ static bool ip6_tnl_netlink_encap_parms(struct nlattr *data[],
 }
 
 static int ip6_tnl_newlink(struct net *src_net, struct net_device *dev,
-			   struct nlattr *tb[], struct nlattr *data[])
+			   struct nlattr *tb[], struct nlattr *data[],
+			   struct netlink_ext_ack *extack)
 {
 	struct net *net = dev_net(dev);
 	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
@@ -2005,7 +2007,8 @@ static int ip6_tnl_newlink(struct net *src_net, struct net_device *dev,
 }
 
 static int ip6_tnl_changelink(struct net_device *dev, struct nlattr *tb[],
-			      struct nlattr *data[])
+			      struct nlattr *data[],
+			      struct netlink_ext_ack *extack)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
 	struct __ip6_tnl_parm p;
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 837ea1eefe7f..486c2305f53c 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -907,7 +907,8 @@ static int __net_init vti6_fb_tnl_dev_init(struct net_device *dev)
 	return 0;
 }
 
-static int vti6_validate(struct nlattr *tb[], struct nlattr *data[])
+static int vti6_validate(struct nlattr *tb[], struct nlattr *data[],
+			 struct netlink_ext_ack *extack)
 {
 	return 0;
 }
@@ -940,7 +941,8 @@ static void vti6_netlink_parms(struct nlattr *data[],
 }
 
 static int vti6_newlink(struct net *src_net, struct net_device *dev,
-			struct nlattr *tb[], struct nlattr *data[])
+			struct nlattr *tb[], struct nlattr *data[],
+			struct netlink_ext_ack *extack)
 {
 	struct net *net = dev_net(dev);
 	struct ip6_tnl *nt;
@@ -966,7 +968,8 @@ static void vti6_dellink(struct net_device *dev, struct list_head *head)
 }
 
 static int vti6_changelink(struct net_device *dev, struct nlattr *tb[],
-			   struct nlattr *data[])
+			   struct nlattr *data[],
+			   struct netlink_ext_ack *extack)
 {
 	struct ip6_tnl *t;
 	struct __ip6_tnl_parm p;
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 2378503577b0..e9958b1398cb 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1406,7 +1406,8 @@ static void __net_init ipip6_fb_tunnel_init(struct net_device *dev)
 	rcu_assign_pointer(sitn->tunnels_wc[0], tunnel);
 }
 
-static int ipip6_validate(struct nlattr *tb[], struct nlattr *data[])
+static int ipip6_validate(struct nlattr *tb[], struct nlattr *data[],
+			  struct netlink_ext_ack *extack)
 {
 	u8 proto;
 
@@ -1537,7 +1538,8 @@ static bool ipip6_netlink_6rd_parms(struct nlattr *data[],
 #endif
 
 static int ipip6_newlink(struct net *src_net, struct net_device *dev,
-			 struct nlattr *tb[], struct nlattr *data[])
+			 struct nlattr *tb[], struct nlattr *data[],
+			 struct netlink_ext_ack *extack)
 {
 	struct net *net = dev_net(dev);
 	struct ip_tunnel *nt;
@@ -1573,7 +1575,8 @@ static int ipip6_newlink(struct net *src_net, struct net_device *dev,
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
