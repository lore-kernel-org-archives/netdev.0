From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: DCB,
	fix TX hang occurring in stress condition with PFC
Date: Thu, 28 Oct 2010 03:59:57 -0700
Message-ID: <20101028105957.27748.39154.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:54819 "EHLO
	qmta05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758192Ab0J1K77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 06:59:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

The DCB credits refill quantum _must_ be greater than half the max
packet size. This is needed to guarantee that TX DMA operations
are not attempted during a pause state. Additionally, the min IFG
must be set correctly for DCB mode. If a DMA operation is
requested unexpectedly during the pause state the HW data
store may be corrupted leading to a DMA hang.  The DMA hang
requires a reset to correct. This fixes the HW configuration
to avoid this condition.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb.c       |   39 +++++++++++++++++++++++++++++++----
 drivers/net/ixgbe/ixgbe_dcb.h       |    5 ++--
 drivers/net/ixgbe/ixgbe_dcb_82599.c |    5 ++++
 drivers/net/ixgbe/ixgbe_dcb_82599.h |    3 +++
 drivers/net/ixgbe/ixgbe_main.c      |   12 +++++++++--
 5 files changed, 54 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb.c b/drivers/net/ixgbe/ixgbe_dcb.c
index 8bb9ddb..0d44c64 100644
--- a/drivers/net/ixgbe/ixgbe_dcb.c
+++ b/drivers/net/ixgbe/ixgbe_dcb.c
@@ -43,9 +43,12 @@
  * ixgbe_dcb_check_config().
  */
 s32 ixgbe_dcb_calculate_tc_credits(struct ixgbe_dcb_config *dcb_config,
-                                   u8 direction)
+				   int max_frame, u8 direction)
 {
 	struct tc_bw_alloc *p;
+	int min_credit;
+	int min_multiplier;
+	int min_percent = 100;
 	s32 ret_val = 0;
 	/* Initialization values default for Tx settings */
 	u32 credit_refill       = 0;
@@ -59,6 +62,31 @@ s32 ixgbe_dcb_calculate_tc_credits(struct ixgbe_dcb_config *dcb_config,
 		goto out;
 	}
 
+	min_credit = ((max_frame / 2) + DCB_CREDIT_QUANTUM - 1) /
+			DCB_CREDIT_QUANTUM;
+
+	/* Find smallest link percentage */
+	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
+		p = &dcb_config->tc_config[i].path[direction];
+		bw_percent = dcb_config->bw_percentage[direction][p->bwg_id];
+		link_percentage = p->bwg_percent;
+
+		link_percentage = (link_percentage * bw_percent) / 100;
+
+		if (link_percentage && link_percentage < min_percent)
+			min_percent = link_percentage;
+	}
+
+	/*
+	 * The ratio between traffic classes will control the bandwidth
+	 * percentages seen on the wire. To calculate this ratio we use
+	 * a multiplier. It is required that the refill credits must be
+	 * larger than the max frame size so here we find the smallest
+	 * multiplier that will allow all bandwidth percentages to be
+	 * greater than the max frame size.
+	 */
+	min_multiplier = (min_credit / min_percent) + 1;
+
 	/* Find out the link percentage for each TC first */
 	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
 		p = &dcb_config->tc_config[i].path[direction];
@@ -73,8 +101,9 @@ s32 ixgbe_dcb_calculate_tc_credits(struct ixgbe_dcb_config *dcb_config,
 		/* Save link_percentage for reference */
 		p->link_percent = (u8)link_percentage;
 
-		/* Calculate credit refill and save it */
-		credit_refill = link_percentage * MINIMUM_CREDIT_REFILL;
+		/* Calculate credit refill ratio using multiplier */
+		credit_refill = min(link_percentage * min_multiplier,
+				    MAX_CREDIT_REFILL);
 		p->data_credits_refill = (u16)credit_refill;
 
 		/* Calculate maximum credit for the TC */
@@ -85,8 +114,8 @@ s32 ixgbe_dcb_calculate_tc_credits(struct ixgbe_dcb_config *dcb_config,
 		 * of a TC is too small, the maximum credit may not be
 		 * enough to send out a jumbo frame in data plane arbitration.
 		 */
-		if (credit_max && (credit_max < MINIMUM_CREDIT_FOR_JUMBO))
-			credit_max = MINIMUM_CREDIT_FOR_JUMBO;
+		if (credit_max && (credit_max < min_credit))
+			credit_max = min_credit;
 
 		if (direction == DCB_TX_CONFIG) {
 			/*
diff --git a/drivers/net/ixgbe/ixgbe_dcb.h b/drivers/net/ixgbe/ixgbe_dcb.h
index eb1059f..0208a87 100644
--- a/drivers/net/ixgbe/ixgbe_dcb.h
+++ b/drivers/net/ixgbe/ixgbe_dcb.h
@@ -150,15 +150,14 @@ struct ixgbe_dcb_config {
 /* DCB driver APIs */
 
 /* DCB credits calculation */
-s32 ixgbe_dcb_calculate_tc_credits(struct ixgbe_dcb_config *, u8);
+s32 ixgbe_dcb_calculate_tc_credits(struct ixgbe_dcb_config *, int, u8);
 
 /* DCB hw initialization */
 s32 ixgbe_dcb_hw_config(struct ixgbe_hw *, struct ixgbe_dcb_config *);
 
 /* DCB definitions for credit calculation */
+#define DCB_CREDIT_QUANTUM	64   /* DCB Quantum */
 #define MAX_CREDIT_REFILL       511  /* 0x1FF * 64B = 32704B */
-#define MINIMUM_CREDIT_REFILL   5    /* 5*64B = 320B */
-#define MINIMUM_CREDIT_FOR_JUMBO 145  /* 145= UpperBound((9*1024+54)/64B) for 9KB jumbo frame */
 #define DCB_MAX_TSO_SIZE        (32*1024) /* MAX TSO packet size supported in DCB mode */
 #define MINIMUM_CREDIT_FOR_TSO  (DCB_MAX_TSO_SIZE/64 + 1) /* 513 for 32KB TSO packet */
 #define MAX_CREDIT              4095 /* Maximum credit supported: 256KB * 1204 / 64B */
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ixgbe/ixgbe_dcb_82599.c
index 67c219f..05f2247 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.c
@@ -397,6 +397,11 @@ static s32 ixgbe_dcb_config_82599(struct ixgbe_hw *hw)
 	reg &= ~IXGBE_RTTDCS_ARBDIS;
 	IXGBE_WRITE_REG(hw, IXGBE_RTTDCS, reg);
 
+	/* Enable Security TX Buffer IFG for DCB */
+	reg = IXGBE_READ_REG(hw, IXGBE_SECTXMINIFG);
+	reg |= IXGBE_SECTX_DCB;
+	IXGBE_WRITE_REG(hw, IXGBE_SECTXMINIFG, reg);
+
 	return 0;
 }
 
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.h b/drivers/net/ixgbe/ixgbe_dcb_82599.h
index 18d7fbf..3841649 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.h
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.h
@@ -95,6 +95,9 @@
 
 #define IXGBE_TXPBTHRESH_DCB    0xA        /* THRESH value for DCB mode */
 
+/* SECTXMINIFG DCB */
+#define IXGBE_SECTX_DCB		0x00001F00 /* DCB TX Buffer IFG */
+
 
 /* DCB hardware-specific driver APIs */
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index f856312..2bd3eb4 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3347,6 +3347,7 @@ static void ixgbe_napi_disable_all(struct ixgbe_adapter *adapter)
 static void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
+	int max_frame = adapter->netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 	u32 txdctl;
 	int i, j;
 
@@ -3359,8 +3360,15 @@ static void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
 	if (hw->mac.type == ixgbe_mac_82598EB)
 		netif_set_gso_max_size(adapter->netdev, 32768);
 
-	ixgbe_dcb_calculate_tc_credits(&adapter->dcb_cfg, DCB_TX_CONFIG);
-	ixgbe_dcb_calculate_tc_credits(&adapter->dcb_cfg, DCB_RX_CONFIG);
+#ifdef CONFIG_FCOE
+	if (adapter->netdev->features & NETIF_F_FCOE_MTU)
+		max_frame = max(max_frame, IXGBE_FCOE_JUMBO_FRAME_SIZE);
+#endif
+
+	ixgbe_dcb_calculate_tc_credits(&adapter->dcb_cfg, max_frame,
+					DCB_TX_CONFIG);
+	ixgbe_dcb_calculate_tc_credits(&adapter->dcb_cfg, max_frame,
+					DCB_RX_CONFIG);
 
 	/* reconfigure the hardware */
 	ixgbe_dcb_hw_config(&adapter->hw, &adapter->dcb_cfg);

