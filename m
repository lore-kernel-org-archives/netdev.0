From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 21/21] ixgbe: DCB, PFC not cleared until reset occurs
Date: Sat, 12 Mar 2011 04:20:28 -0800
Message-ID: <1299932428-3114-22-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:11283 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754022Ab1CLMVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2011 07:21:03 -0500
In-Reply-To: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

The PFC configuration is not cleared until the device is reset. This
has not been a problem because setting DCB attributes forced a
hardware reset. Now that we no longer require this reset to occur
PFC remains configured even after being disabled until the
device is reset.

This removes a goto in the PFC hardware set routines for 82598 and
82599 devices that was short circuiting the clear.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_dcb_82598.c |   44 +++++++++++++---------------
 drivers/net/ixgbe/ixgbe_dcb_82599.c |   54 +++++++++++++++++------------------
 2 files changed, 47 insertions(+), 51 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.c b/drivers/net/ixgbe/ixgbe_dcb_82598.c
index c97cf91..1bc57e5 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82598.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82598.c
@@ -233,21 +233,27 @@ s32 ixgbe_dcb_config_pfc_82598(struct ixgbe_hw *hw, u8 pfc_en)
 	u32 reg, rx_pba_size;
 	u8  i;
 
-	if (!pfc_en)
-		goto out;
-
-	/* Enable Transmit Priority Flow Control */
-	reg = IXGBE_READ_REG(hw, IXGBE_RMCS);
-	reg &= ~IXGBE_RMCS_TFCE_802_3X;
-	/* correct the reporting of our flow control status */
-	reg |= IXGBE_RMCS_TFCE_PRIORITY;
-	IXGBE_WRITE_REG(hw, IXGBE_RMCS, reg);
-
-	/* Enable Receive Priority Flow Control */
-	reg = IXGBE_READ_REG(hw, IXGBE_FCTRL);
-	reg &= ~IXGBE_FCTRL_RFCE;
-	reg |= IXGBE_FCTRL_RPFCE;
-	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, reg);
+	if (pfc_en) {
+		/* Enable Transmit Priority Flow Control */
+		reg = IXGBE_READ_REG(hw, IXGBE_RMCS);
+		reg &= ~IXGBE_RMCS_TFCE_802_3X;
+		/* correct the reporting of our flow control status */
+		reg |= IXGBE_RMCS_TFCE_PRIORITY;
+		IXGBE_WRITE_REG(hw, IXGBE_RMCS, reg);
+
+		/* Enable Receive Priority Flow Control */
+		reg = IXGBE_READ_REG(hw, IXGBE_FCTRL);
+		reg &= ~IXGBE_FCTRL_RFCE;
+		reg |= IXGBE_FCTRL_RPFCE;
+		IXGBE_WRITE_REG(hw, IXGBE_FCTRL, reg);
+
+		/* Configure pause time */
+		for (i = 0; i < (MAX_TRAFFIC_CLASS >> 1); i++)
+			IXGBE_WRITE_REG(hw, IXGBE_FCTTV(i), 0x68006800);
+
+		/* Configure flow control refresh threshold value */
+		IXGBE_WRITE_REG(hw, IXGBE_FCRTV, 0x3400);
+	}
 
 	/*
 	 * Configure flow control thresholds and enable priority flow control
@@ -273,14 +279,6 @@ s32 ixgbe_dcb_config_pfc_82598(struct ixgbe_hw *hw, u8 pfc_en)
 		IXGBE_WRITE_REG(hw, IXGBE_FCRTH(i), reg);
 	}
 
-	/* Configure pause time */
-	for (i = 0; i < (MAX_TRAFFIC_CLASS >> 1); i++)
-		IXGBE_WRITE_REG(hw, IXGBE_FCTTV(i), 0x68006800);
-
-	/* Configure flow control refresh threshold value */
-	IXGBE_WRITE_REG(hw, IXGBE_FCRTV, 0x3400);
-
-out:
 	return 0;
 }
 
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ixgbe/ixgbe_dcb_82599.c
index 0a482bb..025af8c 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.c
@@ -253,13 +253,6 @@ s32 ixgbe_dcb_config_pfc_82599(struct ixgbe_hw *hw, u8 pfc_en)
 {
 	u32 i, reg, rx_pba_size;
 
-	/* If PFC is disabled globally then fall back to LFC. */
-	if (!pfc_en) {
-		for (i = 0; i < MAX_TRAFFIC_CLASS; i++)
-			hw->mac.ops.fc_enable(hw, i);
-		goto out;
-	}
-
 	/* Configure PFC Tx thresholds per TC */
 	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
 		int enabled = pfc_en & (1 << i);
@@ -278,28 +271,33 @@ s32 ixgbe_dcb_config_pfc_82599(struct ixgbe_hw *hw, u8 pfc_en)
 		IXGBE_WRITE_REG(hw, IXGBE_FCRTH_82599(i), reg);
 	}
 
-	/* Configure pause time (2 TCs per register) */
-	reg = hw->fc.pause_time | (hw->fc.pause_time << 16);
-	for (i = 0; i < (MAX_TRAFFIC_CLASS / 2); i++)
-		IXGBE_WRITE_REG(hw, IXGBE_FCTTV(i), reg);
-
-	/* Configure flow control refresh threshold value */
-	IXGBE_WRITE_REG(hw, IXGBE_FCRTV, hw->fc.pause_time / 2);
-
-	/* Enable Transmit PFC */
-	reg = IXGBE_FCCFG_TFCE_PRIORITY;
-	IXGBE_WRITE_REG(hw, IXGBE_FCCFG, reg);
+	if (pfc_en) {
+		/* Configure pause time (2 TCs per register) */
+		reg = hw->fc.pause_time | (hw->fc.pause_time << 16);
+		for (i = 0; i < (MAX_TRAFFIC_CLASS / 2); i++)
+			IXGBE_WRITE_REG(hw, IXGBE_FCTTV(i), reg);
+
+		/* Configure flow control refresh threshold value */
+		IXGBE_WRITE_REG(hw, IXGBE_FCRTV, hw->fc.pause_time / 2);
+
+
+		reg = IXGBE_FCCFG_TFCE_PRIORITY;
+		IXGBE_WRITE_REG(hw, IXGBE_FCCFG, reg);
+		/*
+		 * Enable Receive PFC
+		 * We will always honor XOFF frames we receive when
+		 * we are in PFC mode.
+		 */
+		reg = IXGBE_READ_REG(hw, IXGBE_MFLCN);
+		reg &= ~IXGBE_MFLCN_RFCE;
+		reg |= IXGBE_MFLCN_RPFCE | IXGBE_MFLCN_DPF;
+		IXGBE_WRITE_REG(hw, IXGBE_MFLCN, reg);
+
+	} else {
+		for (i = 0; i < MAX_TRAFFIC_CLASS; i++)
+			hw->mac.ops.fc_enable(hw, i);
+	}
 
-	/*
-	 * Enable Receive PFC
-	 * We will always honor XOFF frames we receive when
-	 * we are in PFC mode.
-	 */
-	reg = IXGBE_READ_REG(hw, IXGBE_MFLCN);
-	reg &= ~IXGBE_MFLCN_RFCE;
-	reg |= IXGBE_MFLCN_RPFCE | IXGBE_MFLCN_DPF;
-	IXGBE_WRITE_REG(hw, IXGBE_MFLCN, reg);
-out:
 	return 0;
 }
 
-- 
1.7.4

