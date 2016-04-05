From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 4/9] bnxt_en: Add EEE setup code.
Date: Tue,  5 Apr 2016 14:08:58 -0400
Message-ID: <1459879743-16960-5-git-send-email-michael.chan@broadcom.com>
References: <1459879743-16960-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:3597 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757362AbcDESJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 14:09:07 -0400
In-Reply-To: <1459879743-16960-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. Add bnxt_hwrm_set_eee() function to setup EEE firmware parameters based
on the bp->eee settings.
2. The new function bnxt_eee_config_ok() will check if EEE parameters need
to be modified due to autoneg changes.
3. bnxt_hwrm_set_link() has added a new parameter to update EEE.  If the
parameter is set, it will call bnxt_hwrm_set_eee().

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 58 ++++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  4 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h |  1 +
 4 files changed, 60 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 7442e20..2c3c795 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4711,7 +4711,30 @@ int bnxt_hwrm_set_pause(struct bnxt *bp)
 	return rc;
 }
 
-int bnxt_hwrm_set_link_setting(struct bnxt *bp, bool set_pause)
+static void bnxt_hwrm_set_eee(struct bnxt *bp,
+			      struct hwrm_port_phy_cfg_input *req)
+{
+	struct ethtool_eee *eee = &bp->eee;
+
+	if (eee->eee_enabled) {
+		u16 eee_speeds;
+		u32 flags = PORT_PHY_CFG_REQ_FLAGS_EEE_ENABLE;
+
+		if (eee->tx_lpi_enabled)
+			flags |= PORT_PHY_CFG_REQ_FLAGS_EEE_TX_LPI_ENABLE;
+		else
+			flags |= PORT_PHY_CFG_REQ_FLAGS_EEE_TX_LPI_DISABLE;
+
+		req->flags |= cpu_to_le32(flags);
+		eee_speeds = bnxt_get_fw_auto_link_speeds(eee->advertised);
+		req->eee_link_speed_mask = cpu_to_le16(eee_speeds);
+		req->tx_lpi_timer = cpu_to_le32(eee->tx_lpi_timer);
+	} else {
+		req->flags |= cpu_to_le32(PORT_PHY_CFG_REQ_FLAGS_EEE_DISABLE);
+	}
+}
+
+int bnxt_hwrm_set_link_setting(struct bnxt *bp, bool set_pause, bool set_eee)
 {
 	struct hwrm_port_phy_cfg_input req = {0};
 
@@ -4720,14 +4743,42 @@ int bnxt_hwrm_set_link_setting(struct bnxt *bp, bool set_pause)
 		bnxt_hwrm_set_pause_common(bp, &req);
 
 	bnxt_hwrm_set_link_common(bp, &req);
+
+	if (set_eee)
+		bnxt_hwrm_set_eee(bp, &req);
 	return hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
 }
 
+static bool bnxt_eee_config_ok(struct bnxt *bp)
+{
+	struct ethtool_eee *eee = &bp->eee;
+	struct bnxt_link_info *link_info = &bp->link_info;
+
+	if (!(bp->flags & BNXT_FLAG_EEE_CAP))
+		return true;
+
+	if (eee->eee_enabled) {
+		u32 advertising =
+			_bnxt_fw_to_ethtool_adv_spds(link_info->advertising, 0);
+
+		if (!(link_info->autoneg & BNXT_AUTONEG_SPEED)) {
+			eee->eee_enabled = 0;
+			return false;
+		}
+		if (eee->advertised & ~advertising) {
+			eee->advertised = advertising & eee->supported;
+			return false;
+		}
+	}
+	return true;
+}
+
 static int bnxt_update_phy_setting(struct bnxt *bp)
 {
 	int rc;
 	bool update_link = false;
 	bool update_pause = false;
+	bool update_eee = false;
 	struct bnxt_link_info *link_info = &bp->link_info;
 
 	rc = bnxt_update_link(bp, true);
@@ -4757,8 +4808,11 @@ static int bnxt_update_phy_setting(struct bnxt *bp)
 			update_link = true;
 	}
 
+	if (!bnxt_eee_config_ok(bp))
+		update_eee = true;
+
 	if (update_link)
-		rc = bnxt_hwrm_set_link_setting(bp, update_pause);
+		rc = bnxt_hwrm_set_link_setting(bp, update_pause, update_eee);
 	else if (update_pause)
 		rc = bnxt_hwrm_set_pause(bp);
 	if (rc) {
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 5e83405..a981e2c 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1112,7 +1112,7 @@ int hwrm_send_message_silent(struct bnxt *, void *, u32, int);
 int bnxt_hwrm_set_coal(struct bnxt *);
 int bnxt_hwrm_func_qcaps(struct bnxt *);
 int bnxt_hwrm_set_pause(struct bnxt *);
-int bnxt_hwrm_set_link_setting(struct bnxt *, bool);
+int bnxt_hwrm_set_link_setting(struct bnxt *, bool, bool);
 int bnxt_open_nic(struct bnxt *, bool, bool);
 int bnxt_close_nic(struct bnxt *, bool, bool);
 int bnxt_get_max_rings(struct bnxt *, int *, int *, bool);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index bdc6220..14f0520 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -763,7 +763,7 @@ static u32 bnxt_get_fw_speed(struct net_device *dev, u16 ethtool_speed)
 	return 0;
 }
 
-static u16 bnxt_get_fw_auto_link_speeds(u32 advertising)
+u16 bnxt_get_fw_auto_link_speeds(u32 advertising)
 {
 	u16 fw_speed_mask = 0;
 
@@ -840,7 +840,7 @@ static int bnxt_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	}
 
 	if (netif_running(dev))
-		rc = bnxt_hwrm_set_link_setting(bp, set_pause);
+		rc = bnxt_hwrm_set_link_setting(bp, set_pause, false);
 
 set_setting_exit:
 	return rc;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h
index e061f8f..3abc03b 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.h
@@ -14,5 +14,6 @@ extern const struct ethtool_ops bnxt_ethtool_ops;
 
 u32 _bnxt_fw_to_ethtool_adv_spds(u16, u8);
 u32 bnxt_fw_to_ethtool_speed(u16);
+u16 bnxt_get_fw_auto_link_speeds(u32);
 
 #endif
-- 
1.8.3.1
