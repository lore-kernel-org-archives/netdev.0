From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next 6/24] bnx2x: disable fairness if ETS is enabled
Date: Tue, 14 Jun 2011 14:33:13 +0300
Message-ID: <201106141433.14361.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3785 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756043Ab1FNLd5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 07:33:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_dcb.h  |    2 ++
 drivers/net/bnx2x/bnx2x_main.c |    8 ++++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_dcb.h b/drivers/net/bnx2x/bnx2x_dcb.h
index bed369d..5bedd85 100644
--- a/drivers/net/bnx2x/bnx2x_dcb.h
+++ b/drivers/net/bnx2x/bnx2x_dcb.h
@@ -60,6 +60,8 @@ struct bnx2x_dcbx_port_params {
 #define BNX2X_DCBX_OVERWRITE_SETTINGS_DISABLE		0
 #define BNX2X_DCBX_OVERWRITE_SETTINGS_ENABLE		1
 #define BNX2X_DCBX_OVERWRITE_SETTINGS_INVALID	(BNX2X_DCBX_CONFIG_INV_VALUE)
+#define BNX2X_IS_ETS_ENABLED(bp) ((bp)->dcb_state == BNX2X_DCB_STATE_ON &&\
+				  (bp)->dcbx_port_params.ets.enabled)
 
 struct bnx2x_config_lldp_params {
 	u32 overwrite_settings;
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index e5eb2a2..e6439a3 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -1931,8 +1931,12 @@ static void bnx2x_calc_vn_weight_sum(struct bnx2x *bp)
 		bp->vn_weight_sum += vn_min_rate;
 	}
 
-	/* ... only if all min rates are zeros - disable fairness */
-	if (all_zero) {
+	/* if ETS or all min rates are zeros - disable fairness */
+	if (BNX2X_IS_ETS_ENABLED(bp)) {
+		bp->cmng.flags.cmng_enables &=
+					~CMNG_FLAGS_PER_PORT_FAIRNESS_VN;
+		DP(NETIF_MSG_IFUP, "Fairness will be disabled due to ETS\n");
+	} else if (all_zero) {
 		bp->cmng.flags.cmng_enables &=
 					~CMNG_FLAGS_PER_PORT_FAIRNESS_VN;
 		DP(NETIF_MSG_IFUP, "All MIN values are zeroes"
-- 
1.7.2.2


