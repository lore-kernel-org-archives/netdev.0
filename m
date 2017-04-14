From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4 : retrieve port information from firmware
Date: Fri, 14 Apr 2017 19:13:10 +0530
Message-ID: <1492177390-4910-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, Ganesh Goudar <ganeshgr@chelsio.com>,
        Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:63250 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751475AbdDNNnT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 09:43:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

issue get port information command to firmware to retrieve port
information and update if it is different from what was last
recorded and also add indication for supported link modes for
firmware port types FW_PORT_TYPE_SFP28, FW_PORT_TYPE_KR_SFP28,
FW_PORT_TYPE_CR4_QSFP.

Based on the original work by Casey Leedom <leedom@chelsio.com>

Signed-off-by: Casey Leedom <leedom@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c | 34 +++++++++++++++++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  7 ++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 38 ++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |  1 +
 5 files changed, 78 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 163543b..66ed696 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1544,6 +1544,7 @@ int t4_ofld_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
 		    unsigned int vf, unsigned int eqid);
 int t4_sge_ctxt_flush(struct adapter *adap, unsigned int mbox);
 void t4_handle_get_port_info(struct port_info *pi, const __be64 *rpl);
+int t4_update_port_info(struct port_info *pi);
 int t4_handle_fw_rpl(struct adapter *adap, const __be64 *rpl);
 void t4_db_full(struct adapter *adapter);
 void t4_db_dropped(struct adapter *adapter);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
index 02f80fe..9227a66 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
@@ -500,7 +500,11 @@ static int from_fw_port_mod_type(enum fw_port_type port_type,
 	} else if (port_type == FW_PORT_TYPE_SFP ||
 		   port_type == FW_PORT_TYPE_QSFP_10G ||
 		   port_type == FW_PORT_TYPE_QSA ||
-		   port_type == FW_PORT_TYPE_QSFP) {
+		   port_type == FW_PORT_TYPE_QSFP ||
+		   port_type == FW_PORT_TYPE_CR4_QSFP ||
+		   port_type == FW_PORT_TYPE_CR_QSFP ||
+		   port_type == FW_PORT_TYPE_CR2_QSFP ||
+		   port_type == FW_PORT_TYPE_SFP28) {
 		if (mod_type == FW_PORT_MOD_TYPE_LR ||
 		    mod_type == FW_PORT_MOD_TYPE_SR ||
 		    mod_type == FW_PORT_MOD_TYPE_ER ||
@@ -511,6 +515,9 @@ static int from_fw_port_mod_type(enum fw_port_type port_type,
 			return PORT_DA;
 		else
 			return PORT_OTHER;
+	} else if (port_type == FW_PORT_TYPE_KR4_100G ||
+		   port_type == FW_PORT_TYPE_KR_SFP28) {
+		return PORT_NONE;
 	}
 
 	return PORT_OTHER;
@@ -618,7 +625,21 @@ static void fw_caps_to_lmm(enum fw_port_type port_type,
 	case FW_PORT_TYPE_CR_QSFP:
 	case FW_PORT_TYPE_SFP28:
 		SET_LMM(FIBRE);
-		SET_LMM(25000baseCR_Full);
+		FW_CAPS_TO_LMM(SPEED_1G, 1000baseT_Full);
+		FW_CAPS_TO_LMM(SPEED_10G, 10000baseT_Full);
+		FW_CAPS_TO_LMM(SPEED_25G, 25000baseCR_Full);
+		break;
+
+	case FW_PORT_TYPE_KR_SFP28:
+		SET_LMM(Backplane);
+		FW_CAPS_TO_LMM(SPEED_1G, 1000baseT_Full);
+		FW_CAPS_TO_LMM(SPEED_10G, 10000baseKR_Full);
+		FW_CAPS_TO_LMM(SPEED_25G, 25000baseKR_Full);
+		break;
+
+	case FW_PORT_TYPE_CR2_QSFP:
+		SET_LMM(FIBRE);
+		SET_LMM(50000baseSR2_Full);
 		break;
 
 	case FW_PORT_TYPE_KR4_100G:
@@ -674,13 +695,20 @@ static unsigned int lmm_to_fw_caps(const unsigned long *link_mode_mask)
 static int get_link_ksettings(struct net_device *dev,
 			      struct ethtool_link_ksettings *link_ksettings)
 {
-	const struct port_info *pi = netdev_priv(dev);
+	struct port_info *pi = netdev_priv(dev);
 	struct ethtool_link_settings *base = &link_ksettings->base;
 
 	ethtool_link_ksettings_zero_link_mode(link_ksettings, supported);
 	ethtool_link_ksettings_zero_link_mode(link_ksettings, advertising);
 	ethtool_link_ksettings_zero_link_mode(link_ksettings, lp_advertising);
 
+	/* For the nonce, the Firmware doesn't send up Port State changes
+	 * when the Virtual Interface attached to the Port is down.  So
+	 * if it's down, let's grab any changes.
+	 */
+	if (!netif_running(dev))
+		(void)t4_update_port_info(pi);
+
 	base->port = from_fw_port_mod_type(pi->port_type, pi->mod_type);
 
 	if (pi->mdio_addr >= 0) {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index aa71019..7b350de 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2266,6 +2266,13 @@ static int cxgb_open(struct net_device *dev)
 			return err;
 	}
 
+	/* It's possible that the basic port information could have
+	 * changed since we first read it.
+	 */
+	err = t4_update_port_info(pi);
+	if (err < 0)
+		return err;
+
 	err = link_start(dev);
 	if (!err)
 		netif_tx_start_all_queues(dev);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 0de8eb7..347205a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -7345,11 +7345,49 @@ void t4_handle_get_port_info(struct port_info *pi, const __be64 *rpl)
 		lc->fc = fc;
 		lc->supported = be16_to_cpu(p->u.info.pcap);
 		lc->lp_advertising = be16_to_cpu(p->u.info.lpacap);
+		lc->advertising = lc->supported & ADVERT_MASK;
+
+		if (lc->supported & FW_PORT_CAP_ANEG) {
+			lc->autoneg = AUTONEG_ENABLE;
+		} else {
+			lc->advertising = 0;
+			lc->autoneg = AUTONEG_DISABLE;
+		}
+
 		t4_os_link_changed(adap, pi->port_id, link_ok);
 	}
 }
 
 /**
+ *	t4_update_port_info - retrieve and update port information if changed
+ *	@pi: the port_info
+ *
+ *	We issue a Get Port Information Command to the Firmware and, if
+ *	successful, we check to see if anything is different from what we
+ *	last recorded and update things accordingly.
+ */
+int t4_update_port_info(struct port_info *pi)
+{
+	struct fw_port_cmd port_cmd;
+	int ret;
+
+	memset(&port_cmd, 0, sizeof(port_cmd));
+	port_cmd.op_to_portid = cpu_to_be32(FW_CMD_OP_V(FW_PORT_CMD) |
+					    FW_CMD_REQUEST_F | FW_CMD_READ_F |
+					    FW_PORT_CMD_PORTID_V(pi->port_id));
+	port_cmd.action_to_len16 = cpu_to_be32(
+		FW_PORT_CMD_ACTION_V(FW_PORT_ACTION_GET_PORT_INFO) |
+		FW_LEN16(port_cmd));
+	ret = t4_wr_mbox(pi->adapter, pi->adapter->mbox,
+			 &port_cmd, sizeof(port_cmd), &port_cmd);
+	if (ret)
+		return ret;
+
+	t4_handle_get_port_info(pi, (__be64 *)&port_cmd);
+	return 0;
+}
+
+/**
  *      t4_handle_fw_rpl - process a FW reply message
  *      @adap: the adapter
  *      @rpl: start of the FW message
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index ccc05f8..21a187e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -2571,6 +2571,7 @@ enum fw_port_type {
 	FW_PORT_TYPE_CR_QSFP,
 	FW_PORT_TYPE_CR2_QSFP,
 	FW_PORT_TYPE_SFP28,
+	FW_PORT_TYPE_KR_SFP28,
 
 	FW_PORT_TYPE_NONE = FW_PORT_CMD_PTYPE_M
 };
-- 
2.1.0
