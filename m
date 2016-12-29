From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 04/14] bnxt_en: Fix and clarify link_info->advertising.
Date: Thu, 29 Dec 2016 12:13:34 -0500
Message-ID: <1483031624-20076-5-git-send-email-michael.chan@broadcom.com>
References: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:34286 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752912AbcL2ROD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 12:14:03 -0500
Received: by mail-pg0-f44.google.com with SMTP id y62so116419823pgy.1
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2016 09:14:03 -0800 (PST)
In-Reply-To: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The advertising field is closely related to the auto_link_speeds field.
The former is the user setting while the latter is the firmware setting.
Both should be u16.  We should use the advertising field in
bnxt_get_link_ksettings because the auto_link_speeds field may not
be updated with the latest from the firmware yet.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         | 4 ++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 5 +++--
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 277573b..4a8059f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5363,7 +5363,7 @@ static void bnxt_hwrm_set_link_common(struct bnxt *bp,
 {
 	u8 autoneg = bp->link_info.autoneg;
 	u16 fw_link_speed = bp->link_info.req_link_speed;
-	u32 advertising = bp->link_info.advertising;
+	u16 advertising = bp->link_info.advertising;
 
 	if (autoneg & BNXT_AUTONEG_SPEED) {
 		req->auto_mode |=
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index fddc316..0eb6401 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -828,7 +828,7 @@ struct bnxt_link_info {
 #define BNXT_LINK_SPEED_40GB	PORT_PHY_QCFG_RESP_LINK_SPEED_40GB
 #define BNXT_LINK_SPEED_50GB	PORT_PHY_QCFG_RESP_LINK_SPEED_50GB
 	u16			support_speeds;
-	u16			auto_link_speeds;
+	u16			auto_link_speeds;	/* fw adv setting */
 #define BNXT_LINK_SPEED_MSK_100MB PORT_PHY_QCFG_RESP_SUPPORT_SPEEDS_100MB
 #define BNXT_LINK_SPEED_MSK_1GB PORT_PHY_QCFG_RESP_SUPPORT_SPEEDS_1GB
 #define BNXT_LINK_SPEED_MSK_2GB PORT_PHY_QCFG_RESP_SUPPORT_SPEEDS_2GB
@@ -851,7 +851,7 @@ struct bnxt_link_info {
 	u8			req_duplex;
 	u8			req_flow_ctrl;
 	u16			req_link_speed;
-	u32			advertising;
+	u16			advertising;	/* user adv setting */
 	bool			force_link_chng;
 
 	/* a copy of phy_qcfg output used to report link
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 784aa77..1cfa7a6 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -893,7 +893,7 @@ u32 _bnxt_fw_to_ethtool_adv_spds(u16 fw_speeds, u8 fw_pause)
 static void bnxt_fw_to_ethtool_advertised_spds(struct bnxt_link_info *link_info,
 				struct ethtool_link_ksettings *lk_ksettings)
 {
-	u16 fw_speeds = link_info->auto_link_speeds;
+	u16 fw_speeds = link_info->advertising;
 	u8 fw_pause = 0;
 
 	if (link_info->autoneg & BNXT_AUTONEG_FLOW_CTRL)
@@ -1090,8 +1090,9 @@ static int bnxt_set_link_ksettings(struct net_device *dev,
 	struct bnxt *bp = netdev_priv(dev);
 	struct bnxt_link_info *link_info = &bp->link_info;
 	const struct ethtool_link_settings *base = &lk_ksettings->base;
-	u32 speed, fw_advertising = 0;
 	bool set_pause = false;
+	u16 fw_advertising = 0;
+	u32 speed;
 	int rc = 0;
 
 	if (!BNXT_SINGLE_PF(bp))
-- 
1.8.3.1
