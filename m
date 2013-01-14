From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 05/10] bnx2x: Added nvram personalities support
Date: Mon, 14 Jan 2013 17:11:45 +0200
Message-ID: <1358176310-31504-6-git-send-email-yuvalmin@broadcom.com>
References: <1358176310-31504-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4309 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757268Ab3ANQKF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2013 11:10:05 -0500
In-Reply-To: <1358176310-31504-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a device is configured to act as either iscsi or fcoe
device in its nvram, prevent the other from being misused by
preventing its activation in the driver.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h  | 4 ++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 7 +++++++
 2 files changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 3369a50..d2e79be 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -899,6 +899,10 @@ struct port_feat_cfg {		    /* port 0: 0x454  port 1: 0x4c8 */
 		#define PORT_FEAT_CFG_DCBX_DISABLED                  0x00000000
 		#define PORT_FEAT_CFG_DCBX_ENABLED                   0x00000100
 
+		#define PORT_FEAT_CFG_STORAGE_PERSONALITY_MASK        0x00000C00
+		#define PORT_FEAT_CFG_STORAGE_PERSONALITY_FCOE        0x00000400
+		#define PORT_FEAT_CFG_STORAGE_PERSONALITY_ISCSI       0x00000800
+
 	#define PORT_FEATURE_EN_SIZE_MASK                   0x0f000000
 	#define PORT_FEATURE_EN_SIZE_SHIFT                           24
 	#define PORT_FEATURE_WOL_ENABLED                             0x01000000
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 7233946..3b05184 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10526,6 +10526,13 @@ static void bnx2x_get_port_hwinfo(struct bnx2x *bp)
 	bp->wol = (!(bp->flags & NO_WOL_FLAG) &&
 		   (config & PORT_FEATURE_WOL_ENABLED));
 
+	if ((config & PORT_FEAT_CFG_STORAGE_PERSONALITY_MASK) ==
+	    PORT_FEAT_CFG_STORAGE_PERSONALITY_FCOE && !IS_MF(bp))
+		bp->flags |= NO_ISCSI_FLAG;
+	if ((config & PORT_FEAT_CFG_STORAGE_PERSONALITY_MASK) ==
+	    PORT_FEAT_CFG_STORAGE_PERSONALITY_ISCSI && !(IS_MF(bp)))
+		bp->flags |= NO_FCOE_FLAG;
+
 	BNX2X_DEV_INFO("lane_config 0x%08x  speed_cap_mask0 0x%08x  link_config0 0x%08x\n",
 		       bp->link_params.lane_config,
 		       bp->link_params.speed_cap_mask[0],
-- 
1.8.1.227.g44fe835
