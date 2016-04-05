From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 03/10] bnxt_en: Add basic EEE support.
Date: Tue,  5 Apr 2016 04:22:35 -0400
Message-ID: <1459844562-24576-4-git-send-email-michael.chan@broadcom.com>
References: <1459844562-24576-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:57168 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753550AbcDEIWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 04:22:43 -0400
In-Reply-To: <1459844562-24576-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get EEE capability and the initial EEE settings from firmware.
Add "EEE is active | not active" to link up dmesg.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 82 ++++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  4 ++
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h |  1 +
 4 files changed, 87 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 2b5a541..7442e20 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4488,12 +4488,49 @@ static void bnxt_report_link(struct bnxt *bp)
 		speed = bnxt_fw_to_ethtool_speed(bp->link_info.link_speed);
 		netdev_info(bp->dev, "NIC Link is Up, %d Mbps %s duplex, Flow control: %s\n",
 			    speed, duplex, flow_ctrl);
+		if (bp->flags & BNXT_FLAG_EEE_CAP)
+			netdev_info(bp->dev, "EEE is %s\n",
+				    bp->eee.eee_active ? "active" :
+							 "not active");
 	} else {
 		netif_carrier_off(bp->dev);
 		netdev_err(bp->dev, "NIC Link is Down\n");
 	}
 }
 
+static int bnxt_hwrm_phy_qcaps(struct bnxt *bp)
+{
+	int rc = 0;
+	struct hwrm_port_phy_qcaps_input req = {0};
+	struct hwrm_port_phy_qcaps_output *resp = bp->hwrm_cmd_resp_addr;
+
+	if (bp->hwrm_spec_code < 0x10201)
+		return 0;
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_PORT_PHY_QCAPS, -1, -1);
+
+	mutex_lock(&bp->hwrm_cmd_lock);
+	rc = _hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+	if (rc)
+		goto hwrm_phy_qcaps_exit;
+
+	if (resp->eee_supported & PORT_PHY_QCAPS_RESP_EEE_SUPPORTED) {
+		struct ethtool_eee *eee = &bp->eee;
+		u16 fw_speeds = le16_to_cpu(resp->supported_speeds_eee_mode);
+
+		bp->flags |= BNXT_FLAG_EEE_CAP;
+		eee->supported = _bnxt_fw_to_ethtool_adv_spds(fw_speeds, 0);
+		bp->lpi_tmr_lo = le32_to_cpu(resp->tx_lpi_timer_low) &
+				 PORT_PHY_QCAPS_RESP_TX_LPI_TIMER_LOW_MASK;
+		bp->lpi_tmr_hi = le32_to_cpu(resp->valid_tx_lpi_timer_high) &
+				 PORT_PHY_QCAPS_RESP_TX_LPI_TIMER_HIGH_MASK;
+	}
+
+hwrm_phy_qcaps_exit:
+	mutex_unlock(&bp->hwrm_cmd_lock);
+	return rc;
+}
+
 static int bnxt_update_link(struct bnxt *bp, bool chng_link_state)
 {
 	int rc = 0;
@@ -4535,8 +4572,44 @@ static int bnxt_update_link(struct bnxt *bp, bool chng_link_state)
 	link_info->phy_ver[2] = resp->phy_bld;
 	link_info->media_type = resp->media_type;
 	link_info->transceiver = resp->xcvr_pkg_type;
-	link_info->phy_addr = resp->eee_config_phy_addr;
+	link_info->phy_addr = resp->eee_config_phy_addr &
+			      PORT_PHY_QCFG_RESP_PHY_ADDR_MASK;
+
+	if (bp->flags & BNXT_FLAG_EEE_CAP) {
+		struct ethtool_eee *eee = &bp->eee;
+		u16 fw_speeds;
+
+		eee->eee_active = 0;
+		if (resp->eee_config_phy_addr &
+		    PORT_PHY_QCFG_RESP_EEE_CONFIG_EEE_ACTIVE) {
+			eee->eee_active = 1;
+			fw_speeds = le16_to_cpu(
+				resp->link_partner_adv_eee_link_speed_mask);
+			eee->lp_advertised =
+				_bnxt_fw_to_ethtool_adv_spds(fw_speeds, 0);
+		}
+
+		/* Pull initial EEE config */
+		if (!chng_link_state) {
+			if (resp->eee_config_phy_addr &
+			    PORT_PHY_QCFG_RESP_EEE_CONFIG_EEE_ENABLED)
+				eee->eee_enabled = 1;
 
+			fw_speeds = le16_to_cpu(resp->adv_eee_link_speed_mask);
+			eee->advertised =
+				_bnxt_fw_to_ethtool_adv_spds(fw_speeds, 0);
+
+			if (resp->eee_config_phy_addr &
+			    PORT_PHY_QCFG_RESP_EEE_CONFIG_EEE_TX_LPI) {
+				__le32 tmr;
+
+				eee->tx_lpi_enabled = 1;
+				tmr = resp->xcvr_identifier_type_tx_lpi_timer;
+				eee->tx_lpi_timer = le32_to_cpu(tmr) &
+					PORT_PHY_QCFG_RESP_TX_LPI_TIMER_MASK;
+			}
+		}
+	}
 	/* TODO: need to add more logic to report VF link */
 	if (chng_link_state) {
 		if (link_info->phy_link_status == BNXT_LINK_LINK)
@@ -5825,6 +5898,13 @@ static int bnxt_probe_phy(struct bnxt *bp)
 	int rc = 0;
 	struct bnxt_link_info *link_info = &bp->link_info;
 
+	rc = bnxt_hwrm_phy_qcaps(bp);
+	if (rc) {
+		netdev_err(bp->dev, "Probe phy can't get phy capabilities (rc: %x)\n",
+			   rc);
+		return rc;
+	}
+
 	rc = bnxt_update_link(bp, false);
 	if (rc) {
 		netdev_err(bp->dev, "Probe phy can't update link (rc: %x)\n",
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index e98c37a..5e83405 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -874,6 +874,7 @@ struct bnxt {
 	#define BNXT_FLAG_RFS		0x100
 	#define BNXT_FLAG_SHARED_RINGS	0x200
 	#define BNXT_FLAG_PORT_STATS	0x400
+	#define BNXT_FLAG_EEE_CAP	0x1000
 
 	#define BNXT_FLAG_ALL_CONFIG_FEATS (BNXT_FLAG_TPA |		\
 					    BNXT_FLAG_RFS |		\
@@ -1011,6 +1012,9 @@ struct bnxt {
 	int			ntp_fltr_count;
 
 	struct bnxt_link_info	link_info;
+	struct ethtool_eee	eee;
+	u32			lpi_tmr_lo;
+	u32			lpi_tmr_hi;
 };
 
 #ifdef CONFIG_NET_RX_BUSY_POLL
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 99b1740..bdc6220 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -597,7 +597,7 @@ static void bnxt_get_drvinfo(struct net_device *dev,
 	kfree(pkglog);
 }
 
-static u32 _bnxt_fw_to_ethtool_adv_spds(u16 fw_speeds, u8 fw_pause)
+u32 _bnxt_fw_to_ethtool_adv_spds(u16 fw_speeds, u8 fw_pause)
 {
 	u32 speed_mask = 0;
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h
index b2d8bd3..e061f8f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h
@@ -12,6 +12,7 @@
 
 extern const struct ethtool_ops bnxt_ethtool_ops;
 
+u32 _bnxt_fw_to_ethtool_adv_spds(u16, u8);
 u32 bnxt_fw_to_ethtool_speed(u16);
 
 #endif
-- 
1.8.3.1
