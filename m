From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH v2 net-next 09/12] bnx2x: add fan failure event handling
Date: Sun, 13 Nov 2011 14:47:26 +0200
Message-ID: <1321188449-5822-10-git-send-email-dmitry@broadcom.com>
References: <1321188449-5822-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Ariel Elior" <ariele@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4279 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752831Ab1KMMrw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Nov 2011 07:47:52 -0500
In-Reply-To: <1321188449-5822-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

Shut down the device in case of fan failure to prevent HW damage.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    3 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   24 +++++++++++++++++++++-
 2 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 23e91f4..78613ef 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1141,6 +1141,7 @@ struct bnx2x_fw_stats_data {
 enum {
 	BNX2X_SP_RTNL_SETUP_TC,
 	BNX2X_SP_RTNL_TX_TIMEOUT,
+	BNX2X_SP_RTNL_FAN_FAILURE,
 };
 
 
@@ -2048,6 +2049,8 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define BNX2X_VPD_LEN			128
 #define VENDOR_ID_LEN			4
 
+int bnx2x_close(struct net_device *dev);
+
 /* Congestion management fairness mode */
 #define CMNG_FNS_NONE		0
 #define CMNG_FNS_MINMAX		1
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 967c41b..33ff60d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -3299,6 +3299,17 @@ static inline void bnx2x_fan_failure(struct bnx2x *bp)
 	netdev_err(bp->dev, "Fan Failure on Network Controller has caused"
 	       " the driver to shutdown the card to prevent permanent"
 	       " damage.  Please contact OEM Support for assistance\n");
+
+	/*
+	 * Scheudle device reset (unload)
+	 * This is due to some boards consuming sufficient power when driver is
+	 * up to overheat if fan fails.
+	 */
+	smp_mb__before_clear_bit();
+	set_bit(BNX2X_SP_RTNL_FAN_FAILURE, &bp->sp_rtnl_state);
+	smp_mb__after_clear_bit();
+	schedule_delayed_work(&bp->sp_rtnl_task, 0);
+
 }
 
 static inline void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 attn)
@@ -8503,6 +8514,17 @@ sp_rtnl_not_reset:
 	if (test_and_clear_bit(BNX2X_SP_RTNL_SETUP_TC, &bp->sp_rtnl_state))
 		bnx2x_setup_tc(bp->dev, bp->dcbx_port_params.ets.num_of_cos);
 
+	/*
+	 * in case of fan failure we need to reset id if the "stop on error"
+	 * debug flag is set, since we trying to prevent permanent overheating
+	 * damage
+	 */
+	if (test_and_clear_bit(BNX2X_SP_RTNL_FAN_FAILURE, &bp->sp_rtnl_state)) {
+		DP(BNX2X_MSG_SP, "fan failure detected. Unloading driver");
+		netif_device_detach(bp->dev);
+		bnx2x_close(bp->dev);
+	}
+
 sp_rtnl_exit:
 	rtnl_unlock();
 }
@@ -9969,7 +9991,7 @@ static int bnx2x_open(struct net_device *dev)
 }
 
 /* called with rtnl_lock */
-static int bnx2x_close(struct net_device *dev)
+int bnx2x_close(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
-- 
1.7.7.2
