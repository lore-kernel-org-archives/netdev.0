From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 1/4] bnxt_en: Disallow forced speed for 10GBaseT devices.
Date: Mon, 11 Apr 2016 04:11:11 -0400
Message-ID: <1460362274-21771-2-git-send-email-michael.chan@broadcom.com>
References: <1460362274-21771-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:57523 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010AbcDKILQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 04:11:16 -0400
In-Reply-To: <1460362274-21771-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

10GBaseT devices must autonegotiate to determine master/slave clocking.
Disallow forced speed in ethtool .set_settings() for these devices.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 1 +
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         | 1 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 8 ++++++++
 3 files changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 597e472..a06dcaa 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4611,6 +4611,7 @@ static int bnxt_update_link(struct bnxt *bp, bool chng_link_state)
 	link_info->phy_ver[1] = resp->phy_min;
 	link_info->phy_ver[2] = resp->phy_bld;
 	link_info->media_type = resp->media_type;
+	link_info->phy_type = resp->phy_type;
 	link_info->transceiver = resp->xcvr_pkg_type;
 	link_info->phy_addr = resp->eee_config_phy_addr &
 			      PORT_PHY_QCFG_RESP_PHY_ADDR_MASK;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index cc8e38a..26dac2f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -759,6 +759,7 @@ struct bnxt_ntuple_filter {
 };
 
 struct bnxt_link_info {
+	u8			phy_type;
 	u8			media_type;
 	u8			transceiver;
 	u8			phy_addr;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index a2e9324..d6e41f2 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -850,7 +850,15 @@ static int bnxt_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		set_pause = true;
 	} else {
 		u16 fw_speed;
+		u8 phy_type = link_info->phy_type;
 
+		if (phy_type == PORT_PHY_QCFG_RESP_PHY_TYPE_BASET  ||
+		    phy_type == PORT_PHY_QCFG_RESP_PHY_TYPE_BASETE ||
+		    link_info->media_type == PORT_PHY_QCFG_RESP_MEDIA_TYPE_TP) {
+			netdev_err(dev, "10GBase-T devices must autoneg\n");
+			rc = -EINVAL;
+			goto set_setting_exit;
+		}
 		/* TODO: currently don't support half duplex */
 		if (cmd->duplex == DUPLEX_HALF) {
 			netdev_err(dev, "HALF DUPLEX is not supported!\n");
-- 
1.8.3.1
