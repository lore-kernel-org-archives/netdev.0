From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6] net: consolidate and fix ethtool_ops->get_settings calling
Date: Thu,  1 Sep 2011 21:28:24 +0200
Message-ID: <1314905304-16485-1-git-send-email-jpirko@redhat.com>
Cc: ralf@linux-mips.org, fubar@us.ibm.com, andy@greyhouse.net,
        kaber@trash.net, bprakash@broadcom.com, JBottomley@parallels.com,
        robert.w.love@intel.com, davem@davemloft.net,
        shemminger@linux-foundation.org, decot@google.com,
        bhutchings@solarflare.com, mirq-linux@rere.qmqm.pl,
        alexander.h.duyck@intel.com, amit.salecha@qlogic.com,
        eric.dumazet@gmail.com, therbert@google.com,
        paulmck@linux.vnet.ibm.com, laijs@cn.fujitsu.com,
        xiaosuo@gmail.com, greearb@candelatech.com, loke.chetan@gmail.com,
        linux-mips@linux-mips.org, linux-scsi@vger.kernel.org,
        devel@open-fcoe.org, bridge@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

This patch does several things:
- introduces __ethtool_get_settings which is called from ethtool code and
  from dev_ethtool_get_settings() as well.
- dev_ethtool_get_settings() becomes rtnl wrapper for
  __ethtool_get_settings()
- changes calling in drivers so rtnl locking is respected. In
  iboe_get_rate was previously ->get_settings() called unlocked. This
  fixes it
- introduces rtnl_lock in bnx2fc_vport_create() and fcoe_vport_create()
  so bnx2fc_if_create() and fcoe_if_create() are called locked as they
  are from other places.
- prb_calc_retire_blk_tmo() in af_packet.c was not calling get_settings
  with rtnl_lock. So use dev_ethtool_get_settings here.
- use __ethtool_get_settings() in bonding code

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 arch/mips/txx9/generic/setup_tx4939.c |    2 +-
 drivers/net/bonding/bond_main.c       |   13 ++++------
 drivers/net/macvlan.c                 |    3 +-
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c     |    4 ++-
 drivers/scsi/fcoe/fcoe.c              |    4 ++-
 include/linux/ethtool.h               |    3 ++
 net/8021q/vlan_dev.c                  |    3 +-
 net/bridge/br_if.c                    |    2 +-
 net/core/dev.c                        |   17 +++++---------
 net/core/ethtool.c                    |   17 +++++++++----
 net/core/net-sysfs.c                  |    4 +-
 net/packet/af_packet.c                |   41 +++++++++++++++-----------------
 12 files changed, 59 insertions(+), 54 deletions(-)

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
index 11b0fc7..abdc0e3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4570,22 +4570,17 @@ void dev_set_rx_mode(struct net_device *dev)
  *	@dev: device
  *	@cmd: memory area for ethtool_ops::get_settings() result
  *
- *      The cmd arg is initialized properly (cleared and
- *      ethtool_cmd::cmd field set to ETHTOOL_GSET).
- *
- *	Return device's ethtool_ops::get_settings() result value or
- *	-EOPNOTSUPP when device doesn't expose
- *	ethtool_ops::get_settings() operation.
+ *	This is wrapper taking rtnl lock for __ethtool_get_settings()
  */
 int dev_ethtool_get_settings(struct net_device *dev,
 			     struct ethtool_cmd *cmd)
 {
-	if (!dev->ethtool_ops || !dev->ethtool_ops->get_settings)
-		return -EOPNOTSUPP;
+	int ret;
 
-	memset(cmd, 0, sizeof(struct ethtool_cmd));
-	cmd->cmd = ETHTOOL_GSET;
-	return dev->ethtool_ops->get_settings(dev, cmd);
+	rtnl_lock();
+	ret = __ethtool_get_settings(dev, cmd);
+	rtnl_unlock();
+	return ret;
 }
 EXPORT_SYMBOL(dev_ethtool_get_settings);
 
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 6cdba5f..94326d4 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -569,15 +569,22 @@ int __ethtool_set_flags(struct net_device *dev, u32 data)
 	return 0;
 }
 
+int __ethtool_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	if (!dev->ethtool_ops || !dev->ethtool_ops->get_settings)
+		return -EOPNOTSUPP;
+
+	memset(cmd, 0, sizeof(struct ethtool_cmd));
+	cmd->cmd = ETHTOOL_GSET;
+	return dev->ethtool_ops->get_settings(dev, cmd);
+}
+
 static int ethtool_get_settings(struct net_device *dev, void __user *useraddr)
 {
-	struct ethtool_cmd cmd = { .cmd = ETHTOOL_GSET };
 	int err;
+	struct ethtool_cmd cmd;
 
-	if (!dev->ethtool_ops->get_settings)
-		return -EOPNOTSUPP;
-
-	err = dev->ethtool_ops->get_settings(dev, &cmd);
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
index 2ea3d63..1bcc794 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -530,33 +530,30 @@ static int prb_calc_retire_blk_tmo(struct packet_sock *po,
 {
 	struct net_device *dev;
 	unsigned int mbits = 0, msec = 0, div = 0, tmo = 0;
+	struct ethtool_cmd ecmd;
 
 	dev = dev_get_by_index(sock_net(&po->sk), po->ifindex);
 	if (unlikely(dev == NULL))
 		return DEFAULT_PRB_RETIRE_TOV;
 
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
+	if (!dev_ethtool_get_settings(dev, &ecmd)) {
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
