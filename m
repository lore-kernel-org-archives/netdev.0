From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 03/10] amd-xgbe-phy: Provide support for
 auto-negotiation timeout
Date: Thu, 19 Mar 2015 12:12:43 -0500
Message-ID: <20150319171243.26446.55518.stgit@tlendack-t1.amdoffice.net>
References: <20150319171225.26446.36048.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0105.outbound.protection.outlook.com ([157.56.111.105]:50788
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751996AbbCSR2I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2015 13:28:08 -0400
In-Reply-To: <20150319171225.26446.36048.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, there is no interrupt code that indicates auto-negotiation
has timed out. If the auto-negotiation has timed out then the start of
a new auto-negotiation will begin again with a new base page being
received. The state machine could be in a state that is not expecting
this interrupt code which results in an error during auto-negotiation.

Update the code to timestamp when the auto-negotiation starts.  Should
another page received interrupt code occur before auto-negotiation has
completed but after the auto-negotiation timeout, then reset the state
machine to allow the auto-negotiation to continue.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/phy/amd-xgbe-phy.c |   20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/phy/amd-xgbe-phy.c b/drivers/net/phy/amd-xgbe-phy.c
index 4b95caf..823b316 100644
--- a/drivers/net/phy/amd-xgbe-phy.c
+++ b/drivers/net/phy/amd-xgbe-phy.c
@@ -78,6 +78,7 @@
 #include <linux/bitops.h>
 #include <linux/property.h>
 #include <linux/acpi.h>
+#include <linux/time.h>
 
 MODULE_AUTHOR("Tom Lendacky <thomas.lendacky@amd.com>");
 MODULE_LICENSE("Dual BSD/GPL");
@@ -100,6 +101,8 @@ MODULE_DESCRIPTION("AMD 10GbE (amd-xgbe) PHY driver");
 #define XGBE_PHY_SPEED_2500		1
 #define XGBE_PHY_SPEED_10000		2
 
+#define XGBE_AN_NS_TIMEOUT		(500 * NSEC_PER_MSEC)	/* 500 ms */
+
 #define XGBE_AN_INT_CMPLT		0x01
 #define XGBE_AN_INC_LINK		0x02
 #define XGBE_AN_PG_RCV			0x04
@@ -434,6 +437,7 @@ struct amd_xgbe_phy_priv {
 	unsigned int an_supported;
 	unsigned int parallel_detect;
 	unsigned int fec_ability;
+	struct timespec64 an_start;
 
 	unsigned int lpm_ctrl;		/* CTRL1 for resume */
 };
@@ -902,8 +906,23 @@ static enum amd_xgbe_phy_an amd_xgbe_an_page_received(struct phy_device *phydev)
 {
 	struct amd_xgbe_phy_priv *priv = phydev->priv;
 	enum amd_xgbe_phy_rx *state;
+	struct timespec64 rcv_time, diff_time;
 	int ret;
 
+	getnstimeofday64(&rcv_time);
+	if (!timespec64_to_ns(&priv->an_start)) {
+		priv->an_start = rcv_time;
+	} else {
+		diff_time = timespec64_sub(rcv_time, priv->an_start);
+		if (timespec64_to_ns(&diff_time) > XGBE_AN_NS_TIMEOUT) {
+			/* Auto-negotiation timed out, reset state */
+			priv->kr_state = AMD_XGBE_RX_BPA;
+			priv->kx_state = AMD_XGBE_RX_BPA;
+
+			priv->an_start = rcv_time;
+		}
+	}
+
 	state = amd_xgbe_phy_in_kr_mode(phydev) ? &priv->kr_state
 						: &priv->kx_state;
 
@@ -1078,6 +1097,7 @@ again:
 		priv->an_state = AMD_XGBE_AN_READY;
 		priv->kr_state = AMD_XGBE_RX_BPA;
 		priv->kx_state = AMD_XGBE_RX_BPA;
+		priv->an_start = ns_to_timespec64(0);
 	}
 
 	if (cur_state != priv->an_state)
