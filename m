From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 v3] net: consolidate and fix
 ethtool_ops->get_settings calling
Date: Sat, 3 Sep 2011 15:34:30 +0200
Message-ID: <20110903133428.GA2821@minipsycho>
References: <1314905304-16485-1-git-send-email-jpirko@redhat.com>
 <20110902122630.GC1991@minipsycho>
 <1314989161.3419.5.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ralf@linux-mips.org, fubar@us.ibm.com,
        andy@greyhouse.net, kaber@trash.net, bprakash@broadcom.com,
        JBottomley@parallels.com, robert.w.love@intel.com,
        davem@davemloft.net, shemminger@linux-foundation.org,
        decot@google.com, mirq-linux@rere.qmqm.pl,
        alexander.h.duyck@intel.com, amit.salecha@qlogic.com,
        eric.dumazet@gmail.com, therbert@google.com,
        paulmck@linux.vnet.ibm.com, laijs@cn.fujitsu.com,
        xiaosuo@gmail.com, greearb@candelatech.com, loke.chetan@gmail.com,
        linux-mips@linux-mips.org, linux-scsi@vger.kernel.org,
        devel@open-fcoe.org, bridge@lists.linux-foundation.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <1314989161.3419.5.camel@bwh-desktop>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

This patch does several things:
- introduces __ethtool_get_settings which is called from ethtool code and
  from drivers as well. Put ASSERT_RTNL there.
- dev_ethtool_get_settings() is replaced by __ethtool_get_settings()
- changes calling in drivers so rtnl locking is respected. In
  iboe_get_rate was previously ->get_settings() called unlocked. This
  fixes it. Also prb_calc_retire_blk_tmo() in af_packet.c had the same
  problem. Also fixed by calling __dev_get_by_index() instead of
  dev_get_by_index() and holding rtnl_lock for both calls.
- introduces rtnl_lock in bnx2fc_vport_create() and fcoe_vport_create()
  so bnx2fc_if_create() and fcoe_if_create() are called locked as they
  are from other places.
- use __ethtool_get_settings() in bonding code

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

v2->v3:
	-removed dev_ethtool_get_settings()
	-added ASSERT_RTNL into __ethtool_get_settings()
	-prb_calc_retire_blk_tmo - use __dev_get_by_index() and lock
	 around it and __ethtool_get_settings() call
v1->v2:
        add missing export_symbol 
 
---
 arch/mips/txx9/generic/setup_tx4939.c |    2 +-
 drivers/net/bonding/bond_main.c       |   13 +++-----
 drivers/net/macvlan.c                 |    3 +-
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c     |    4 ++-
 drivers/scsi/fcoe/fcoe.c              |    4 ++-
 include/linux/ethtool.h               |    3 ++
 include/linux/netdevice.h             |    3 --
 include/rdma/ib_addr.h                |    6 +++-
 net/8021q/vlan_dev.c                  |    3 +-
 net/bridge/br_if.c                    |    2 +-
 net/core/dev.c                        |   24 ---------------
 net/core/ethtool.c                    |   20 +++++++++---
 net/core/net-sysfs.c                  |    4 +-
 net/packet/af_packet.c                |   52 +++++++++++++++++----------------
 14 files changed, 69 insertions(+), 74 deletions(-)

diff --git a/arch/mips/txx9/generic/setup_tx4939.c b/arch/mips/txx9/generic/setup_tx4939.c
index e9f95dc..ba3cec3 100644
--- a/arch/mips/txx9/generic/setup_tx4939.c
+++ b/arch/mips/txx9/generic/setup_tx4939.c
@@ -321,7 +321,7 @@ void __init tx4939_sio_init(unsigned int sclk, unsigned int cts_mask)
 static u32 tx4939_get_eth_speed(struct net_device *dev)
 {
 	struct ethtool_cmd cmd;
-	if (dev_ethtool_get_settings(dev, &cmd))
+	if (__ethtool_get_settings(dev, &cmd))
 		return 100;	/* default 100Mbps */
 
 	return ethtool_cmd_speed(&cmd);
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 8cb75a6..1dcb07c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -557,7 +557,7 @@ down:
 static int bond_update_speed_duplex(struct slave *slave)
 {
 	struct net_device *slave_dev = slave->dev;
-	struct ethtool_cmd etool = { .cmd = ETHTOOL_GSET };
+	struct ethtool_cmd ecmd;
 	u32 slave_speed;
 	int res;
 
@@ -565,18 +565,15 @@ static int bond_update_speed_duplex(struct slave *slave)
 	slave->speed = SPEED_100;
 	slave->duplex = DUPLEX_FULL;
 
-	if (!slave_dev->ethtool_ops || !slave_dev->ethtool_ops->get_settings)
-		return -1;
-
-	res = slave_dev->ethtool_ops->get_settings(slave_dev, &etool);
+	res = __ethtool_get_settings(slave_dev, &ecmd);
 	if (res < 0)
 		return -1;
 
-	slave_speed = ethtool_cmd_speed(&etool);
+	slave_speed = ethtool_cmd_speed(&ecmd);
 	if (slave_speed == 0 || slave_speed == ((__u32) -1))
 		return -1;
 
-	switch (etool.duplex) {
+	switch (ecmd.duplex) {
 	case DUPLEX_FULL:
 	case DUPLEX_HALF:
 		break;
@@ -585,7 +582,7 @@ static int bond_update_speed_duplex(struct slave *slave)
 	}
 
 	slave->speed = slave_speed;
-	slave->duplex = etool.duplex;
+	slave->duplex = ecmd.duplex;
 
 	return 0;
 }
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 836e13f..b100c90 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -543,7 +543,8 @@ static int macvlan_ethtool_get_settings(struct net_device *dev,
 					struct ethtool_cmd *cmd)
 {
 	const struct macvlan_dev *vlan = netdev_priv(dev);
-	return dev_ethtool_get_settings(vlan->lowerdev, cmd);
+
+	return __ethtool_get_settings(vlan->lowerdev, cmd);
 }
 
 static const struct ethtool_ops macvlan_ethtool_ops = {
diff --git a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
index 2c780a7..820a184 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
@@ -673,7 +673,7 @@ static void bnx2fc_link_speed_update(struct fc_lport *lport)
 	struct net_device *netdev = interface->netdev;
 	struct ethtool_cmd ecmd;
 
-	if (!dev_ethtool_get_settings(netdev, &ecmd)) {
+	if (!__ethtool_get_settings(netdev, &ecmd)) {
 		lport->link_supported_speeds &=
 			~(FC_PORTSPEED_1GBIT | FC_PORTSPEED_10GBIT);
 		if (ecmd.supported & (SUPPORTED_1000baseT_Half |
@@ -1001,9 +1001,11 @@ static int bnx2fc_vport_create(struct fc_vport *vport, bool disabled)
 			"this interface\n");
 		return -EIO;
 	}
+	rtnl_lock();
 	mutex_lock(&bnx2fc_dev_lock);
 	vn_port = bnx2fc_if_create(interface, &vport->dev, 1);
 	mutex_unlock(&bnx2fc_dev_lock);
+	rtnl_unlock();
 
 	if (IS_ERR(vn_port)) {
 		printk(KERN_ERR PFX "bnx2fc_vport_create (%s) failed\n",
diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index 3416ab6..83aa3ac 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -2043,7 +2043,7 @@ int fcoe_link_speed_update(struct fc_lport *lport)
 	struct net_device *netdev = fcoe_netdev(lport);
 	struct ethtool_cmd ecmd;
 
-	if (!dev_ethtool_get_settings(netdev, &ecmd)) {
+	if (!__ethtool_get_settings(netdev, &ecmd)) {
 		lport->link_supported_speeds &=
 			~(FC_PORTSPEED_1GBIT | FC_PORTSPEED_10GBIT);
 		if (ecmd.supported & (SUPPORTED_1000baseT_Half |
@@ -2452,7 +2452,9 @@ static int fcoe_vport_create(struct fc_vport *vport, bool disabled)
 	}
 
 	mutex_lock(&fcoe_config_mutex);
+	rtnl_lock();
 	vn_port = fcoe_if_create(fcoe, &vport->dev, 1);
+	rtnl_unlock();
 	mutex_unlock(&fcoe_config_mutex);
 
 	if (IS_ERR(vn_port)) {
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 3829712..8571f18 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -728,6 +728,9 @@ enum ethtool_sfeatures_retval_bits {
 /* needed by dev_disable_lro() */
 extern int __ethtool_set_flags(struct net_device *dev, u32 flags);
 
+extern int __ethtool_get_settings(struct net_device *dev,
+				  struct ethtool_cmd *cmd);
+
 /**
  * enum ethtool_phys_id_state - indicator state for physical identification
  * @ETHTOOL_ID_INACTIVE: Physical ID indicator should be deactivated
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index dad7e4d..8b1080b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2600,9 +2600,6 @@ static inline int netif_is_bond_slave(struct net_device *dev)
 
 extern struct pernet_operations __net_initdata loopback_net_ops;
 
-int dev_ethtool_get_settings(struct net_device *dev,
-			     struct ethtool_cmd *cmd);
-
 static inline u32 dev_ethtool_get_rx_csum(struct net_device *dev)
 {
 	if (dev->features & NETIF_F_RXCSUM)
diff --git a/include/rdma/ib_addr.h b/include/rdma/ib_addr.h
index ae8c68f..639a449 100644
--- a/include/rdma/ib_addr.h
+++ b/include/rdma/ib_addr.h
@@ -218,8 +218,12 @@ static inline int iboe_get_rate(struct net_device *dev)
 {
 	struct ethtool_cmd cmd;
 	u32 speed;
+	int err;
 
-	if (dev_ethtool_get_settings(dev, &cmd))
+	rtnl_lock();
+	err = __ethtool_get_settings(dev, &cmd);
+	rtnl_unlock();
+	if (err)
 		return IB_RATE_PORT_CURRENT;
 
 	speed = ethtool_cmd_speed(&cmd);
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index eba705b..c8cf939 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -610,7 +610,8 @@ static int vlan_ethtool_get_settings(struct net_device *dev,
 				     struct ethtool_cmd *cmd)
 {
 	const struct vlan_dev_info *vlan = vlan_dev_info(dev);
-	return dev_ethtool_get_settings(vlan->real_dev, cmd);
+
+	return __ethtool_get_settings(vlan->real_dev, cmd);
 }
 
 static void vlan_ethtool_get_drvinfo(struct net_device *dev,
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index b365bba..043a5eb 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -35,7 +35,7 @@ static int port_cost(struct net_device *dev)
 {
 	struct ethtool_cmd ecmd;
 
-	if (!dev_ethtool_get_settings(dev, &ecmd)) {
+	if (!__ethtool_get_settings(dev, &ecmd)) {
 		switch (ethtool_cmd_speed(&ecmd)) {
 		case SPEED_10000:
 			return 2;
diff --git a/net/core/dev.c b/net/core/dev.c
index 11b0fc7..94f3254 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4566,30 +4566,6 @@ void dev_set_rx_mode(struct net_device *dev)
 }
 
 /**
- *	dev_ethtool_get_settings - call device's ethtool_ops::get_settings()
- *	@dev: device
- *	@cmd: memory area for ethtool_ops::get_settings() result
- *
- *      The cmd arg is initialized properly (cleared and
- *      ethtool_cmd::cmd field set to ETHTOOL_GSET).
- *
- *	Return device's ethtool_ops::get_settings() result value or
- *	-EOPNOTSUPP when device doesn't expose
- *	ethtool_ops::get_settings() operation.
- */
-int dev_ethtool_get_settings(struct net_device *dev,
-			     struct ethtool_cmd *cmd)
-{
-	if (!dev->ethtool_ops || !dev->ethtool_ops->get_settings)
-		return -EOPNOTSUPP;
-
-	memset(cmd, 0, sizeof(struct ethtool_cmd));
-	cmd->cmd = ETHTOOL_GSET;
-	return dev->ethtool_ops->get_settings(dev, cmd);
-}
-EXPORT_SYMBOL(dev_ethtool_get_settings);
-
-/**
  *	dev_get_flags - get flags reported to userspace
  *	@dev: device
  *
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 6cdba5f..f444817 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -569,15 +569,25 @@ int __ethtool_set_flags(struct net_device *dev, u32 data)
 	return 0;
 }
 
-static int ethtool_get_settings(struct net_device *dev, void __user *useraddr)
+int __ethtool_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct ethtool_cmd cmd = { .cmd = ETHTOOL_GSET };
-	int err;
+	ASSERT_RTNL();
 
-	if (!dev->ethtool_ops->get_settings)
+	if (!dev->ethtool_ops || !dev->ethtool_ops->get_settings)
 		return -EOPNOTSUPP;
 
-	err = dev->ethtool_ops->get_settings(dev, &cmd);
+	memset(cmd, 0, sizeof(struct ethtool_cmd));
+	cmd->cmd = ETHTOOL_GSET;
+	return dev->ethtool_ops->get_settings(dev, cmd);
+}
+EXPORT_SYMBOL(__ethtool_get_settings);
+
+static int ethtool_get_settings(struct net_device *dev, void __user *useraddr)
+{
+	int err;
+	struct ethtool_cmd cmd;
+
+	err = __ethtool_get_settings(dev, &cmd);
 	if (err < 0)
 		return err;
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 90fdb46..48e6279 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -172,7 +172,7 @@ static ssize_t show_speed(struct device *dev,
 
 	if (netif_running(netdev)) {
 		struct ethtool_cmd cmd;
-		if (!dev_ethtool_get_settings(netdev, &cmd))
+		if (!__ethtool_get_settings(netdev, &cmd))
 			ret = sprintf(buf, fmt_udec, ethtool_cmd_speed(&cmd));
 	}
 	rtnl_unlock();
@@ -190,7 +190,7 @@ static ssize_t show_duplex(struct device *dev,
 
 	if (netif_running(netdev)) {
 		struct ethtool_cmd cmd;
-		if (!dev_ethtool_get_settings(netdev, &cmd))
+		if (!__ethtool_get_settings(netdev, &cmd))
 			ret = sprintf(buf, "%s\n",
 				      cmd.duplex ? "full" : "half");
 	}
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 2ea3d63..25e68f5 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -530,33 +530,35 @@ static int prb_calc_retire_blk_tmo(struct packet_sock *po,
 {
 	struct net_device *dev;
 	unsigned int mbits = 0, msec = 0, div = 0, tmo = 0;
+	struct ethtool_cmd ecmd;
+	int err;
 
-	dev = dev_get_by_index(sock_net(&po->sk), po->ifindex);
-	if (unlikely(dev == NULL))
+	rtnl_lock();
+	dev = __dev_get_by_index(sock_net(&po->sk), po->ifindex);
+	if (unlikely(!dev)) {
+		rtnl_unlock();
 		return DEFAULT_PRB_RETIRE_TOV;
-
-	if (dev->ethtool_ops && dev->ethtool_ops->get_settings) {
-		struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET, };
-
-		if (!dev->ethtool_ops->get_settings(dev, &ecmd)) {
-			switch (ecmd.speed) {
-			case SPEED_10000:
-				msec = 1;
-				div = 10000/1000;
-				break;
-			case SPEED_1000:
-				msec = 1;
-				div = 1000/1000;
-				break;
-			/*
-			 * If the link speed is so slow you don't really
-			 * need to worry about perf anyways
-			 */
-			case SPEED_100:
-			case SPEED_10:
-			default:
-				return DEFAULT_PRB_RETIRE_TOV;
-			}
+	}
+	err = __ethtool_get_settings(dev, &ecmd);
+	rtnl_unlock();
+	if (!err) {
+		switch (ecmd.speed) {
+		case SPEED_10000:
+			msec = 1;
+			div = 10000/1000;
+			break;
+		case SPEED_1000:
+			msec = 1;
+			div = 1000/1000;
+			break;
+		/*
+		 * If the link speed is so slow you don't really
+		 * need to worry about perf anyways
+		 */
+		case SPEED_100:
+		case SPEED_10:
+		default:
+			return DEFAULT_PRB_RETIRE_TOV;
 		}
 	}
 
-- 
1.7.6
