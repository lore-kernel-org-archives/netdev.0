From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net] cxgb4vf: Fix ethtool get_settings for VF driver
Date: Mon, 22 Dec 2014 15:14:37 +0530
Message-ID: <1419241477-15718-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:32491 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753733AbaLVJiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 04:38:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Decode and display Port Type and Module Type for ethtool get_settings() call

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h     |    4 +
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |  140 ++++++++++++++++++--
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |    2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |   54 ++++----
 4 files changed, 160 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h b/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
index d00a751..6049f70 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
@@ -96,6 +96,9 @@ struct port_info {
 	s16 xact_addr_filt;		/* index of our MAC address filter */
 	u16 rss_size;			/* size of VI's RSS table slice */
 	u8 pidx;			/* index into adapter port[] */
+	s8 mdio_addr;
+	u8 port_type;			/* firmware port type */
+	u8 mod_type;			/* firmware module type */
 	u8 port_id;			/* physical port ID */
 	u8 nqsets;			/* # of "Queue Sets" */
 	u8 first_qset;			/* index of first "Queue Set" */
@@ -522,6 +525,7 @@ static inline struct adapter *netdev2adap(const struct net_device *dev)
  * is "contracted" to provide for the common code.
  */
 void t4vf_os_link_changed(struct adapter *, int, int);
+void t4vf_os_portmod_changed(struct adapter *, int);
 
 /*
  * SGE function prototype declarations.
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index aa74ec3..2215d43 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -44,6 +44,7 @@
 #include <linux/etherdevice.h>
 #include <linux/debugfs.h>
 #include <linux/ethtool.h>
+#include <linux/mdio.h>
 
 #include "t4vf_common.h"
 #include "t4vf_defs.h"
@@ -210,6 +211,38 @@ void t4vf_os_link_changed(struct adapter *adapter, int pidx, int link_ok)
 }
 
 /*
+ * THe port module type has changed on the indicated "port" (Virtual
+ * Interface).
+ */
+void t4vf_os_portmod_changed(struct adapter *adapter, int pidx)
+{
+	static const char * const mod_str[] = {
+		NULL, "LR", "SR", "ER", "passive DA", "active DA", "LRM"
+	};
+	const struct net_device *dev = adapter->port[pidx];
+	const struct port_info *pi = netdev_priv(dev);
+
+	if (pi->mod_type == FW_PORT_MOD_TYPE_NONE)
+		dev_info(adapter->pdev_dev, "%s: port module unplugged\n",
+			 dev->name);
+	else if (pi->mod_type < ARRAY_SIZE(mod_str))
+		dev_info(adapter->pdev_dev, "%s: %s port module inserted\n",
+			 dev->name, mod_str[pi->mod_type]);
+	else if (pi->mod_type == FW_PORT_MOD_TYPE_NOTSUPPORTED)
+		dev_info(adapter->pdev_dev, "%s: unsupported optical port "
+			 "module inserted\n", dev->name);
+	else if (pi->mod_type == FW_PORT_MOD_TYPE_UNKNOWN)
+		dev_info(adapter->pdev_dev, "%s: unknown port module inserted,"
+			 "forcing TWINAX\n", dev->name);
+	else if (pi->mod_type == FW_PORT_MOD_TYPE_ERROR)
+		dev_info(adapter->pdev_dev, "%s: transceiver module error\n",
+			 dev->name);
+	else
+		dev_info(adapter->pdev_dev, "%s: unknown module type %d "
+			 "inserted\n", dev->name, pi->mod_type);
+}
+
+/*
  * Net device operations.
  * ======================
  */
@@ -1193,24 +1226,103 @@ static void cxgb4vf_poll_controller(struct net_device *dev)
  * state of the port to which we're linked.
  */
 
-/*
- * Return current port link settings.
- */
-static int cxgb4vf_get_settings(struct net_device *dev,
-				struct ethtool_cmd *cmd)
-{
-	const struct port_info *pi = netdev_priv(dev);
+static unsigned int t4vf_from_fw_linkcaps(enum fw_port_type type,
+					  unsigned int caps)
+{
+	unsigned int v = 0;
+
+	if (type == FW_PORT_TYPE_BT_SGMII || type == FW_PORT_TYPE_BT_XFI ||
+	    type == FW_PORT_TYPE_BT_XAUI) {
+		v |= SUPPORTED_TP;
+		if (caps & FW_PORT_CAP_SPEED_100M)
+			v |= SUPPORTED_100baseT_Full;
+		if (caps & FW_PORT_CAP_SPEED_1G)
+			v |= SUPPORTED_1000baseT_Full;
+		if (caps & FW_PORT_CAP_SPEED_10G)
+			v |= SUPPORTED_10000baseT_Full;
+	} else if (type == FW_PORT_TYPE_KX4 || type == FW_PORT_TYPE_KX) {
+		v |= SUPPORTED_Backplane;
+		if (caps & FW_PORT_CAP_SPEED_1G)
+			v |= SUPPORTED_1000baseKX_Full;
+		if (caps & FW_PORT_CAP_SPEED_10G)
+			v |= SUPPORTED_10000baseKX4_Full;
+	} else if (type == FW_PORT_TYPE_KR)
+		v |= SUPPORTED_Backplane | SUPPORTED_10000baseKR_Full;
+	else if (type == FW_PORT_TYPE_BP_AP)
+		v |= SUPPORTED_Backplane | SUPPORTED_10000baseR_FEC |
+		     SUPPORTED_10000baseKR_Full | SUPPORTED_1000baseKX_Full;
+	else if (type == FW_PORT_TYPE_BP4_AP)
+		v |= SUPPORTED_Backplane | SUPPORTED_10000baseR_FEC |
+		     SUPPORTED_10000baseKR_Full | SUPPORTED_1000baseKX_Full |
+		     SUPPORTED_10000baseKX4_Full;
+	else if (type == FW_PORT_TYPE_FIBER_XFI ||
+		 type == FW_PORT_TYPE_FIBER_XAUI ||
+		 type == FW_PORT_TYPE_SFP ||
+		 type == FW_PORT_TYPE_QSFP_10G ||
+		 type == FW_PORT_TYPE_QSA) {
+		v |= SUPPORTED_FIBRE;
+		if (caps & FW_PORT_CAP_SPEED_1G)
+			v |= SUPPORTED_1000baseT_Full;
+		if (caps & FW_PORT_CAP_SPEED_10G)
+			v |= SUPPORTED_10000baseT_Full;
+	} else if (type == FW_PORT_TYPE_BP40_BA ||
+		   type == FW_PORT_TYPE_QSFP) {
+		v |= SUPPORTED_40000baseSR4_Full;
+		v |= SUPPORTED_FIBRE;
+	}
+
+	if (caps & FW_PORT_CAP_ANEG)
+		v |= SUPPORTED_Autoneg;
+	return v;
+}
+
+static int cxgb4vf_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	const struct port_info *p = netdev_priv(dev);
+
+	if (p->port_type == FW_PORT_TYPE_BT_SGMII ||
+	    p->port_type == FW_PORT_TYPE_BT_XFI ||
+	    p->port_type == FW_PORT_TYPE_BT_XAUI)
+		cmd->port = PORT_TP;
+	else if (p->port_type == FW_PORT_TYPE_FIBER_XFI ||
+		 p->port_type == FW_PORT_TYPE_FIBER_XAUI)
+		cmd->port = PORT_FIBRE;
+	else if (p->port_type == FW_PORT_TYPE_SFP ||
+		 p->port_type == FW_PORT_TYPE_QSFP_10G ||
+		 p->port_type == FW_PORT_TYPE_QSA ||
+		 p->port_type == FW_PORT_TYPE_QSFP) {
+		if (p->mod_type == FW_PORT_MOD_TYPE_LR ||
+		    p->mod_type == FW_PORT_MOD_TYPE_SR ||
+		    p->mod_type == FW_PORT_MOD_TYPE_ER ||
+		    p->mod_type == FW_PORT_MOD_TYPE_LRM)
+			cmd->port = PORT_FIBRE;
+		else if (p->mod_type == FW_PORT_MOD_TYPE_TWINAX_PASSIVE ||
+			 p->mod_type == FW_PORT_MOD_TYPE_TWINAX_ACTIVE)
+			cmd->port = PORT_DA;
+		else
+			cmd->port = PORT_OTHER;
+	} else
+		cmd->port = PORT_OTHER;
 
-	cmd->supported = pi->link_cfg.supported;
-	cmd->advertising = pi->link_cfg.advertising;
+	if (p->mdio_addr >= 0) {
+		cmd->phy_address = p->mdio_addr;
+		cmd->transceiver = XCVR_EXTERNAL;
+		cmd->mdio_support = p->port_type == FW_PORT_TYPE_BT_SGMII ?
+			MDIO_SUPPORTS_C22 : MDIO_SUPPORTS_C45;
+	} else {
+		cmd->phy_address = 0;  /* not really, but no better option */
+		cmd->transceiver = XCVR_INTERNAL;
+		cmd->mdio_support = 0;
+	}
+
+	cmd->supported = t4vf_from_fw_linkcaps(p->port_type,
+					       p->link_cfg.supported);
+	cmd->advertising = t4vf_from_fw_linkcaps(p->port_type,
+					    p->link_cfg.advertising);
 	ethtool_cmd_speed_set(cmd,
-			      netif_carrier_ok(dev) ? pi->link_cfg.speed : -1);
+			      netif_carrier_ok(dev) ? p->link_cfg.speed : 0);
 	cmd->duplex = DUPLEX_FULL;
-
-	cmd->port = (cmd->supported & SUPPORTED_TP) ? PORT_TP : PORT_FIBRE;
-	cmd->phy_address = pi->port_id;
-	cmd->transceiver = XCVR_EXTERNAL;
-	cmd->autoneg = pi->link_cfg.autoneg;
+	cmd->autoneg = p->link_cfg.autoneg;
 	cmd->maxtxpkt = 0;
 	cmd->maxrxpkt = 0;
 	return 0;
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
index 8d3237f..b9debb4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
@@ -230,7 +230,7 @@ struct adapter_params {
 
 static inline bool is_10g_port(const struct link_config *lc)
 {
-	return (lc->supported & SUPPORTED_10000baseT_Full) != 0;
+	return (lc->supported & FW_PORT_CAP_SPEED_10G) != 0;
 }
 
 static inline bool is_x_10g_port(const struct link_config *lc)
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index 02e8833..21dc9a2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -245,6 +245,10 @@ static int hash_mac_addr(const u8 *addr)
 	return a & 0x3f;
 }
 
+#define ADVERT_MASK (FW_PORT_CAP_SPEED_100M | FW_PORT_CAP_SPEED_1G |\
+		     FW_PORT_CAP_SPEED_10G | FW_PORT_CAP_SPEED_40G | \
+		     FW_PORT_CAP_SPEED_100G | FW_PORT_CAP_ANEG)
+
 /**
  *	init_link_config - initialize a link's SW state
  *	@lc: structure holding the link state
@@ -259,8 +263,8 @@ static void init_link_config(struct link_config *lc, unsigned int caps)
 	lc->requested_speed = 0;
 	lc->speed = 0;
 	lc->requested_fc = lc->fc = PAUSE_RX | PAUSE_TX;
-	if (lc->supported & SUPPORTED_Autoneg) {
-		lc->advertising = lc->supported;
+	if (lc->supported & FW_PORT_CAP_ANEG) {
+		lc->advertising = lc->supported & ADVERT_MASK;
 		lc->autoneg = AUTONEG_ENABLE;
 		lc->requested_fc |= PAUSE_AUTONEG;
 	} else {
@@ -280,7 +284,6 @@ int t4vf_port_init(struct adapter *adapter, int pidx)
 	struct fw_vi_cmd vi_cmd, vi_rpl;
 	struct fw_port_cmd port_cmd, port_rpl;
 	int v;
-	u32 word;
 
 	/*
 	 * Execute a VI Read command to get our Virtual Interface information
@@ -319,19 +322,11 @@ int t4vf_port_init(struct adapter *adapter, int pidx)
 	if (v)
 		return v;
 
-	v = 0;
-	word = be16_to_cpu(port_rpl.u.info.pcap);
-	if (word & FW_PORT_CAP_SPEED_100M)
-		v |= SUPPORTED_100baseT_Full;
-	if (word & FW_PORT_CAP_SPEED_1G)
-		v |= SUPPORTED_1000baseT_Full;
-	if (word & FW_PORT_CAP_SPEED_10G)
-		v |= SUPPORTED_10000baseT_Full;
-	if (word & FW_PORT_CAP_SPEED_40G)
-		v |= SUPPORTED_40000baseSR4_Full;
-	if (word & FW_PORT_CAP_ANEG)
-		v |= SUPPORTED_Autoneg;
-	init_link_config(&pi->link_cfg, v);
+	v = be32_to_cpu(port_rpl.u.info.lstatus_to_modtype);
+	pi->port_type = FW_PORT_CMD_PTYPE_G(v);
+	pi->mod_type = FW_PORT_MOD_TYPE_NA;
+
+	init_link_config(&pi->link_cfg, be16_to_cpu(port_rpl.u.info.pcap));
 
 	return 0;
 }
@@ -1491,7 +1486,7 @@ int t4vf_handle_fw_rpl(struct adapter *adapter, const __be64 *rpl)
 		 */
 		const struct fw_port_cmd *port_cmd =
 			(const struct fw_port_cmd *)rpl;
-		u32 word;
+		u32 stat, mod;
 		int action, port_id, link_ok, speed, fc, pidx;
 
 		/*
@@ -1509,21 +1504,21 @@ int t4vf_handle_fw_rpl(struct adapter *adapter, const __be64 *rpl)
 		port_id = FW_PORT_CMD_PORTID_G(
 			be32_to_cpu(port_cmd->op_to_portid));
 
-		word = be32_to_cpu(port_cmd->u.info.lstatus_to_modtype);
-		link_ok = (word & FW_PORT_CMD_LSTATUS_F) != 0;
+		stat = be32_to_cpu(port_cmd->u.info.lstatus_to_modtype);
+		link_ok = (stat & FW_PORT_CMD_LSTATUS_F) != 0;
 		speed = 0;
 		fc = 0;
-		if (word & FW_PORT_CMD_RXPAUSE_F)
+		if (stat & FW_PORT_CMD_RXPAUSE_F)
 			fc |= PAUSE_RX;
-		if (word & FW_PORT_CMD_TXPAUSE_F)
+		if (stat & FW_PORT_CMD_TXPAUSE_F)
 			fc |= PAUSE_TX;
-		if (word & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_100M))
+		if (stat & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_100M))
 			speed = 100;
-		else if (word & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_1G))
+		else if (stat & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_1G))
 			speed = 1000;
-		else if (word & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_10G))
+		else if (stat & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_10G))
 			speed = 10000;
-		else if (word & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_40G))
+		else if (stat & FW_PORT_CMD_LSPEED_V(FW_PORT_CAP_SPEED_40G))
 			speed = 40000;
 
 		/*
@@ -1540,12 +1535,21 @@ int t4vf_handle_fw_rpl(struct adapter *adapter, const __be64 *rpl)
 				continue;
 
 			lc = &pi->link_cfg;
+
+			mod = FW_PORT_CMD_MODTYPE_G(stat);
+			if (mod != pi->mod_type) {
+				pi->mod_type = mod;
+				t4vf_os_portmod_changed(adapter, pidx);
+			}
+
 			if (link_ok != lc->link_ok || speed != lc->speed ||
 			    fc != lc->fc) {
 				/* something changed */
 				lc->link_ok = link_ok;
 				lc->speed = speed;
 				lc->fc = fc;
+				lc->supported =
+					be16_to_cpu(port_cmd->u.info.pcap);
 				t4vf_os_link_changed(adapter, pidx, link_ok);
 			}
 		}
-- 
1.7.1
