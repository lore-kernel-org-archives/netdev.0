From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/6] e1000e: partial revert of 3ec2a2b8 plus FC
	workraround for 82577/8
Date: Thu, 19 Nov 2009 14:34:20 -0800
Message-ID: <20091119223406.29164.22513.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:45480 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752284AbZKSWec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 17:34:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Commit 3ec2a2b80f3eb53851fe4cef9e65b5d33376ef89 broke Tx/Rx when using
jumbo frames on certain parts (i.e. only PAUSE frames could be exchanged
once the high water mark was reached preventing normal packet traffic).
This patch reverts the breakage and sets appropriate high and low water
marks of the Rx FIFO for 82577/82578 which require a workaround due to a
flow control issue in hardware.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/e1000.h   |    2 ++
 drivers/net/e1000e/ich8lan.c |    1 +
 drivers/net/e1000e/netdev.c  |   41 +++++++++++++++++++++++++++++------------
 3 files changed, 32 insertions(+), 12 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 189dfa2..3e187b0 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -141,6 +141,8 @@ struct e1000_info;
 #define HV_TNCRS_UPPER		PHY_REG(778, 29) /* Transmit with no CRS */
 #define HV_TNCRS_LOWER		PHY_REG(778, 30)
 
+#define E1000_FCRTV_PCH     0x05F40 /* PCH Flow Control Refresh Timer Value */
+
 /* BM PHY Copper Specific Status */
 #define BM_CS_STATUS                      17
 #define BM_CS_STATUS_LINK_UP              0x0400
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 51ddb04..92cf103 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -3558,6 +3558,7 @@ struct e1000_info e1000_pch_info = {
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_FLASH
 				  | FLAG_HAS_JUMBO_FRAMES
+				  | FLAG_DISABLE_FC_PAUSE_TIME /* errata */
 				  | FLAG_APME_IN_WUC,
 	.pba			= 26,
 	.max_hw_frame_size	= 4096,
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 0687c6a..a1a5a6f 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2769,25 +2769,38 @@ void e1000e_reset(struct e1000_adapter *adapter)
 	/*
 	 * flow control settings
 	 *
-	 * The high water mark must be low enough to fit two full frame
+	 * The high water mark must be low enough to fit one full frame
 	 * (or the size used for early receive) above it in the Rx FIFO.
 	 * Set it to the lower of:
 	 * - 90% of the Rx FIFO size, and
 	 * - the full Rx FIFO size minus the early receive size (for parts
 	 *   with ERT support assuming ERT set to E1000_ERT_2048), or
-	 * - the full Rx FIFO size minus two full frames
+	 * - the full Rx FIFO size minus one full frame
 	 */
-	if ((adapter->flags & FLAG_HAS_ERT) &&
-	    (adapter->netdev->mtu > ETH_DATA_LEN))
-		hwm = min(((pba << 10) * 9 / 10),
-			  ((pba << 10) - (E1000_ERT_2048 << 3)));
-	else
-		hwm = min(((pba << 10) * 9 / 10),
-			  ((pba << 10) - (2 * adapter->max_frame_size)));
+	if (hw->mac.type == e1000_pchlan) {
+		/*
+		 * Workaround PCH LOM adapter hangs with certain network
+		 * loads.  If hangs persist, try disabling Tx flow control.
+		 */
+		if (adapter->netdev->mtu > ETH_DATA_LEN) {
+			fc->high_water = 0x3500;
+			fc->low_water  = 0x1500;
+		} else {
+			fc->high_water = 0x5000;
+			fc->low_water  = 0x3000;
+		}
+	} else {
+		if ((adapter->flags & FLAG_HAS_ERT) &&
+		    (adapter->netdev->mtu > ETH_DATA_LEN))
+			hwm = min(((pba << 10) * 9 / 10),
+				  ((pba << 10) - (E1000_ERT_2048 << 3)));
+		else
+			hwm = min(((pba << 10) * 9 / 10),
+				  ((pba << 10) - adapter->max_frame_size));
 
-	fc->high_water = hwm & E1000_FCRTH_RTH; /* 8-byte granularity */
-	fc->low_water = (fc->high_water - (2 * adapter->max_frame_size));
-	fc->low_water &= E1000_FCRTL_RTL; /* 8-byte granularity */
+		fc->high_water = hwm & E1000_FCRTH_RTH; /* 8-byte granularity */
+		fc->low_water = fc->high_water - 8;
+	}
 
 	if (adapter->flags & FLAG_DISABLE_FC_PAUSE_TIME)
 		fc->pause_time = 0xFFFF;
@@ -2813,6 +2826,10 @@ void e1000e_reset(struct e1000_adapter *adapter)
 	if (mac->ops.init_hw(hw))
 		e_err("Hardware Error\n");
 
+	/* additional part of the flow-control workaround above */
+	if (hw->mac.type == e1000_pchlan)
+		ew32(FCRTV_PCH, 0x1000);
+
 	e1000_update_mng_vlan(adapter);
 
 	/* Enable h/w to recognize an 802.1Q VLAN Ethernet packet */

