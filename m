From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/3] ixgbe: Add DCB for 82599, remove BCN support
Date: Fri, 27 Feb 2009 17:44:48 -0800
Message-ID: <20090228014447.22664.49249.stgit@lost.foo-projects.org>
References: <20090228013916.22664.54781.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:57784 "EHLO
	QMTA08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757545AbZB1BpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 20:45:07 -0500
In-Reply-To: <20090228013916.22664.54781.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

This patch adds the DCB (Data Center Bridging) support for 82599 hardware.
This is similar to how the 82598 DCB code works.

This patch also removes the BCN (Backwards Congestion Notification) netlink
configuration code from the driver.  BCN was a pre-standard congestion
notification framework, and was not what the IEEE body decided upon for
standard congestion management. QCN (802.1Qau), Quantized Congestion
Notification is the accepted standard, which is not supported by 82599,
hence we remove the support altogether.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb.c       |   17 +
 drivers/net/ixgbe/ixgbe_dcb.h       |   54 ++--
 drivers/net/ixgbe/ixgbe_dcb_82599.c |  472 +++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_dcb_82599.h |  127 +++++++++
 drivers/net/ixgbe/ixgbe_dcb_nl.c    |  193 --------------
 5 files changed, 644 insertions(+), 219 deletions(-)
 create mode 100644 drivers/net/ixgbe/ixgbe_dcb_82599.c
 create mode 100644 drivers/net/ixgbe/ixgbe_dcb_82599.h

diff --git a/drivers/net/ixgbe/ixgbe_dcb.c b/drivers/net/ixgbe/ixgbe_dcb.c
index 2a60c89..a156228 100644
--- a/drivers/net/ixgbe/ixgbe_dcb.c
+++ b/drivers/net/ixgbe/ixgbe_dcb.c
@@ -31,6 +31,7 @@
 #include "ixgbe_type.h"
 #include "ixgbe_dcb.h"
 #include "ixgbe_dcb_82598.h"
+#include "ixgbe_dcb_82599.h"
 
 /**
  * ixgbe_dcb_config - Struct containing DCB settings.
@@ -215,6 +216,8 @@ s32 ixgbe_dcb_get_tc_stats(struct ixgbe_hw *hw, struct ixgbe_hw_stats *stats,
 	s32 ret = 0;
 	if (hw->mac.type == ixgbe_mac_82598EB)
 		ret = ixgbe_dcb_get_tc_stats_82598(hw, stats, tc_count);
+	else if (hw->mac.type == ixgbe_mac_82599EB)
+		ret = ixgbe_dcb_get_tc_stats_82599(hw, stats, tc_count);
 	return ret;
 }
 
@@ -232,6 +235,8 @@ s32 ixgbe_dcb_get_pfc_stats(struct ixgbe_hw *hw, struct ixgbe_hw_stats *stats,
 	s32 ret = 0;
 	if (hw->mac.type == ixgbe_mac_82598EB)
 		ret = ixgbe_dcb_get_pfc_stats_82598(hw, stats, tc_count);
+	else if (hw->mac.type == ixgbe_mac_82599EB)
+		ret = ixgbe_dcb_get_pfc_stats_82599(hw, stats, tc_count);
 	return ret;
 }
 
@@ -248,6 +253,8 @@ s32 ixgbe_dcb_config_rx_arbiter(struct ixgbe_hw *hw,
 	s32 ret = 0;
 	if (hw->mac.type == ixgbe_mac_82598EB)
 		ret = ixgbe_dcb_config_rx_arbiter_82598(hw, dcb_config);
+	else if (hw->mac.type == ixgbe_mac_82599EB)
+		ret = ixgbe_dcb_config_rx_arbiter_82599(hw, dcb_config);
 	return ret;
 }
 
@@ -264,6 +271,8 @@ s32 ixgbe_dcb_config_tx_desc_arbiter(struct ixgbe_hw *hw,
 	s32 ret = 0;
 	if (hw->mac.type == ixgbe_mac_82598EB)
 		ret = ixgbe_dcb_config_tx_desc_arbiter_82598(hw, dcb_config);
+	else if (hw->mac.type == ixgbe_mac_82599EB)
+		ret = ixgbe_dcb_config_tx_desc_arbiter_82599(hw, dcb_config);
 	return ret;
 }
 
@@ -280,6 +289,8 @@ s32 ixgbe_dcb_config_tx_data_arbiter(struct ixgbe_hw *hw,
 	s32 ret = 0;
 	if (hw->mac.type == ixgbe_mac_82598EB)
 		ret = ixgbe_dcb_config_tx_data_arbiter_82598(hw, dcb_config);
+	else if (hw->mac.type == ixgbe_mac_82599EB)
+		ret = ixgbe_dcb_config_tx_data_arbiter_82599(hw, dcb_config);
 	return ret;
 }
 
@@ -296,6 +307,8 @@ s32 ixgbe_dcb_config_pfc(struct ixgbe_hw *hw,
 	s32 ret = 0;
 	if (hw->mac.type == ixgbe_mac_82598EB)
 		ret = ixgbe_dcb_config_pfc_82598(hw, dcb_config);
+	else if (hw->mac.type == ixgbe_mac_82599EB)
+		ret = ixgbe_dcb_config_pfc_82599(hw, dcb_config);
 	return ret;
 }
 
@@ -311,6 +324,8 @@ s32 ixgbe_dcb_config_tc_stats(struct ixgbe_hw *hw)
 	s32 ret = 0;
 	if (hw->mac.type == ixgbe_mac_82598EB)
 		ret = ixgbe_dcb_config_tc_stats_82598(hw);
+	else if (hw->mac.type == ixgbe_mac_82599EB)
+		ret = ixgbe_dcb_config_tc_stats_82599(hw);
 	return ret;
 }
 
@@ -327,6 +342,8 @@ s32 ixgbe_dcb_hw_config(struct ixgbe_hw *hw,
 	s32 ret = 0;
 	if (hw->mac.type == ixgbe_mac_82598EB)
 		ret = ixgbe_dcb_hw_config_82598(hw, dcb_config);
+	else if (hw->mac.type == ixgbe_mac_82599EB)
+		ret = ixgbe_dcb_hw_config_82599(hw, dcb_config);
 	return ret;
 }
 
diff --git a/drivers/net/ixgbe/ixgbe_dcb.h b/drivers/net/ixgbe/ixgbe_dcb.h
index 0da5c6d..64a9fa1 100644
--- a/drivers/net/ixgbe/ixgbe_dcb.h
+++ b/drivers/net/ixgbe/ixgbe_dcb.h
@@ -75,6 +75,26 @@ enum strict_prio_type {
 	prio_link
 };
 
+/* DCB capability definitions */
+#define IXGBE_DCB_PG_SUPPORT        0x00000001
+#define IXGBE_DCB_PFC_SUPPORT       0x00000002
+#define IXGBE_DCB_BCN_SUPPORT       0x00000004
+#define IXGBE_DCB_UP2TC_SUPPORT     0x00000008
+#define IXGBE_DCB_GSP_SUPPORT       0x00000010
+
+#define IXGBE_DCB_8_TC_SUPPORT      0x80
+
+struct dcb_support {
+	/* DCB capabilities */
+	u32 capabilities;
+
+	/* Each bit represents a number of TCs configurable in the hw.
+	 * If 8 traffic classes can be configured, the value is 0x80.
+	 */
+	u8  traffic_classes;
+	u8  pfc_traffic_classes;
+};
+
 /* Traffic class bandwidth allocation per direction */
 struct tc_bw_alloc {
 	u8 bwg_id;		  /* Bandwidth Group (BWG) ID */
@@ -108,38 +128,18 @@ enum dcb_rx_pba_cfg {
 	pba_80_48      /* PBA[0-3] each use 80KB, PBA[4-7] each use 48KB */
 };
 
-/*
- * This structure contains many values encoded as fixed-point
- * numbers, meaning that some of bits are dedicated to the
- * magnitude and others to the fraction part. In the comments
- * this is shown as f=n, where n is the number of fraction bits.
- * These fraction bits are always the low-order bits. The size
- * of the magnitude is not specified.
- */
-struct bcn_config {
-	u32 rp_admin_mode[MAX_TRAFFIC_CLASS]; /* BCN enabled, per TC */
-	u32 bcna_option[2]; /* BCNA Port + MAC Addr */
-	u32 rp_w;        /* Derivative Weight, f=3 */
-	u32 rp_gi;       /* Increase Gain, f=12 */
-	u32 rp_gd;       /* Decrease Gain, f=12 */
-	u32 rp_ru;       /* Rate Unit */
-	u32 rp_alpha;    /* Max Decrease Factor, f=12 */
-	u32 rp_beta;     /* Max Increase Factor, f=12 */
-	u32 rp_ri;       /* Initial Rate */
-	u32 rp_td;       /* Drift Interval Timer */
-	u32 rp_rd;       /* Drift Increase */
-	u32 rp_tmax;     /* Severe Congestion Backoff Timer Range */
-	u32 rp_rmin;     /* Severe Congestion Restart Rate */
-	u32 rp_wrtt;     /* RTT Moving Average Weight */
+struct dcb_num_tcs {
+	u8 pg_tcs;
+	u8 pfc_tcs;
 };
 
 struct ixgbe_dcb_config {
-	struct bcn_config bcn;
-
+	struct dcb_support support;
+	struct dcb_num_tcs num_tcs;
 	struct tc_configuration tc_config[MAX_TRAFFIC_CLASS];
 	u8     bw_percentage[2][MAX_BW_GROUP]; /* One each for Tx/Rx */
-
-	bool  round_robin_enable;
+	bool   pfc_mode_enable;
+	bool   round_robin_enable;
 
 	enum dcb_rx_pba_cfg rx_pba_cfg;
 
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ixgbe/ixgbe_dcb_82599.c
new file mode 100644
index 0000000..1467d56
--- /dev/null
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.c
@@ -0,0 +1,472 @@
+/*******************************************************************************
+
+  Intel 10 Gigabit PCI Express Linux driver
+  Copyright(c) 1999 - 2009 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#include "ixgbe.h"
+#include "ixgbe_type.h"
+#include "ixgbe_dcb.h"
+#include "ixgbe_dcb_82599.h"
+
+/**
+ * ixgbe_dcb_get_tc_stats_82599 - Returns status for each traffic class
+ * @hw: pointer to hardware structure
+ * @stats: pointer to statistics structure
+ * @tc_count:  Number of elements in bwg_array.
+ *
+ * This function returns the status data for each of the Traffic Classes in use.
+ */
+s32 ixgbe_dcb_get_tc_stats_82599(struct ixgbe_hw *hw,
+                                 struct ixgbe_hw_stats *stats,
+                                 u8 tc_count)
+{
+	int tc;
+
+	if (tc_count > MAX_TRAFFIC_CLASS)
+		return DCB_ERR_PARAM;
+	/* Statistics pertaining to each traffic class */
+	for (tc = 0; tc < tc_count; tc++) {
+		/* Transmitted Packets */
+		stats->qptc[tc] += IXGBE_READ_REG(hw, IXGBE_QPTC(tc));
+		/* Transmitted Bytes */
+		stats->qbtc[tc] += IXGBE_READ_REG(hw, IXGBE_QBTC(tc));
+		/* Received Packets */
+		stats->qprc[tc] += IXGBE_READ_REG(hw, IXGBE_QPRC(tc));
+		/* Received Bytes */
+		stats->qbrc[tc] += IXGBE_READ_REG(hw, IXGBE_QBRC(tc));
+	}
+
+	return 0;
+}
+
+/**
+ * ixgbe_dcb_get_pfc_stats_82599 - Return CBFC status data
+ * @hw: pointer to hardware structure
+ * @stats: pointer to statistics structure
+ * @tc_count:  Number of elements in bwg_array.
+ *
+ * This function returns the CBFC status data for each of the Traffic Classes.
+ */
+s32 ixgbe_dcb_get_pfc_stats_82599(struct ixgbe_hw *hw,
+                                  struct ixgbe_hw_stats *stats,
+                                  u8 tc_count)
+{
+	int tc;
+
+	if (tc_count > MAX_TRAFFIC_CLASS)
+		return DCB_ERR_PARAM;
+	for (tc = 0; tc < tc_count; tc++) {
+		/* Priority XOFF Transmitted */
+		stats->pxofftxc[tc] += IXGBE_READ_REG(hw, IXGBE_PXOFFTXC(tc));
+		/* Priority XOFF Received */
+		stats->pxoffrxc[tc] += IXGBE_READ_REG(hw, IXGBE_PXOFFRXCNT(tc));
+	}
+
+	return 0;
+}
+
+/**
+ * ixgbe_dcb_config_packet_buffers_82599 - Configure DCB packet buffers
+ * @hw: pointer to hardware structure
+ * @dcb_config: pointer to ixgbe_dcb_config structure
+ *
+ * Configure packet buffers for DCB mode.
+ */
+s32 ixgbe_dcb_config_packet_buffers_82599(struct ixgbe_hw *hw,
+                                          struct ixgbe_dcb_config *dcb_config)
+{
+	s32 ret_val = 0;
+	u32 value = IXGBE_RXPBSIZE_64KB;
+	u8  i = 0;
+
+	/* Setup Rx packet buffer sizes */
+	switch (dcb_config->rx_pba_cfg) {
+	case pba_80_48:
+		/* Setup the first four at 80KB */
+		value = IXGBE_RXPBSIZE_80KB;
+		for (; i < 4; i++)
+			IXGBE_WRITE_REG(hw, IXGBE_RXPBSIZE(i), value);
+		/* Setup the last four at 48KB...don't re-init i */
+		value = IXGBE_RXPBSIZE_48KB;
+		/* Fall Through */
+	case pba_equal:
+	default:
+		for (; i < IXGBE_MAX_PACKET_BUFFERS; i++)
+			IXGBE_WRITE_REG(hw, IXGBE_RXPBSIZE(i), value);
+
+		/* Setup Tx packet buffer sizes */
+		for (i = 0; i < IXGBE_MAX_PACKET_BUFFERS; i++) {
+			IXGBE_WRITE_REG(hw, IXGBE_TXPBSIZE(i),
+			                IXGBE_TXPBSIZE_20KB);
+			IXGBE_WRITE_REG(hw, IXGBE_TXPBTHRESH(i),
+			                IXGBE_TXPBTHRESH_DCB);
+		}
+		break;
+	}
+
+	return ret_val;
+}
+
+/**
+ * ixgbe_dcb_config_rx_arbiter_82599 - Config Rx Data arbiter
+ * @hw: pointer to hardware structure
+ * @dcb_config: pointer to ixgbe_dcb_config structure
+ *
+ * Configure Rx Packet Arbiter and credits for each traffic class.
+ */
+s32 ixgbe_dcb_config_rx_arbiter_82599(struct ixgbe_hw *hw,
+                                      struct ixgbe_dcb_config *dcb_config)
+{
+	struct tc_bw_alloc    *p;
+	u32    reg           = 0;
+	u32    credit_refill = 0;
+	u32    credit_max    = 0;
+	u8     i             = 0;
+
+	/* Disable the arbiter before changing parameters */
+	IXGBE_WRITE_REG(hw, IXGBE_RTRPCS, IXGBE_RTRPCS_ARBDIS);
+
+	/* Map all traffic classes to their UP, 1 to 1 */
+	reg = 0;
+	for (i = 0; i < MAX_TRAFFIC_CLASS; i++)
+		reg |= (i << (i * IXGBE_RTRUP2TC_UP_SHIFT));
+	IXGBE_WRITE_REG(hw, IXGBE_RTRUP2TC, reg);
+
+	/* Configure traffic class credits and priority */
+	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
+		p = &dcb_config->tc_config[i].path[DCB_RX_CONFIG];
+
+		credit_refill = p->data_credits_refill;
+		credit_max    = p->data_credits_max;
+		reg = credit_refill | (credit_max << IXGBE_RTRPT4C_MCL_SHIFT);
+
+		reg |= (u32)(p->bwg_id) << IXGBE_RTRPT4C_BWG_SHIFT;
+
+		if (p->prio_type == prio_link)
+			reg |= IXGBE_RTRPT4C_LSP;
+
+		IXGBE_WRITE_REG(hw, IXGBE_RTRPT4C(i), reg);
+	}
+
+	/*
+	 * Configure Rx packet plane (recycle mode; WSP) and
+	 * enable arbiter
+	 */
+	reg = IXGBE_RTRPCS_RRM | IXGBE_RTRPCS_RAC;
+	IXGBE_WRITE_REG(hw, IXGBE_RTRPCS, reg);
+
+	return 0;
+}
+
+/**
+ * ixgbe_dcb_config_tx_desc_arbiter_82599 - Config Tx Desc. arbiter
+ * @hw: pointer to hardware structure
+ * @dcb_config: pointer to ixgbe_dcb_config structure
+ *
+ * Configure Tx Descriptor Arbiter and credits for each traffic class.
+ */
+s32 ixgbe_dcb_config_tx_desc_arbiter_82599(struct ixgbe_hw *hw,
+                                           struct ixgbe_dcb_config *dcb_config)
+{
+	struct tc_bw_alloc *p;
+	u32    reg, max_credits;
+	u8     i;
+
+	/* Disable the arbiter before changing parameters */
+	IXGBE_WRITE_REG(hw, IXGBE_RTTDCS, IXGBE_RTTDCS_ARBDIS);
+
+	/* Clear the per-Tx queue credits; we use per-TC instead */
+	for (i = 0; i < 128; i++) {
+		IXGBE_WRITE_REG(hw, IXGBE_RTTDQSEL, i);
+		IXGBE_WRITE_REG(hw, IXGBE_RTTDT1C, 0);
+	}
+
+	/* Configure traffic class credits and priority */
+	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
+		p = &dcb_config->tc_config[i].path[DCB_TX_CONFIG];
+		max_credits = dcb_config->tc_config[i].desc_credits_max;
+		reg = max_credits << IXGBE_RTTDT2C_MCL_SHIFT;
+		reg |= p->data_credits_refill;
+		reg |= (u32)(p->bwg_id) << IXGBE_RTTDT2C_BWG_SHIFT;
+
+		if (p->prio_type == prio_group)
+			reg |= IXGBE_RTTDT2C_GSP;
+
+		if (p->prio_type == prio_link)
+			reg |= IXGBE_RTTDT2C_LSP;
+
+		IXGBE_WRITE_REG(hw, IXGBE_RTTDT2C(i), reg);
+	}
+
+	/*
+	 * Configure Tx descriptor plane (recycle mode; WSP) and
+	 * enable arbiter
+	 */
+	reg = IXGBE_RTTDCS_TDPAC | IXGBE_RTTDCS_TDRM;
+	IXGBE_WRITE_REG(hw, IXGBE_RTTDCS, reg);
+
+	return 0;
+}
+
+/**
+ * ixgbe_dcb_config_tx_data_arbiter_82599 - Config Tx Data arbiter
+ * @hw: pointer to hardware structure
+ * @dcb_config: pointer to ixgbe_dcb_config structure
+ *
+ * Configure Tx Packet Arbiter and credits for each traffic class.
+ */
+s32 ixgbe_dcb_config_tx_data_arbiter_82599(struct ixgbe_hw *hw,
+                                           struct ixgbe_dcb_config *dcb_config)
+{
+	struct tc_bw_alloc *p;
+	u32 reg;
+	u8 i;
+
+	/* Disable the arbiter before changing parameters */
+	IXGBE_WRITE_REG(hw, IXGBE_RTTPCS, IXGBE_RTTPCS_ARBDIS);
+
+	/* Map all traffic classes to their UP, 1 to 1 */
+	reg = 0;
+	for (i = 0; i < MAX_TRAFFIC_CLASS; i++)
+		reg |= (i << (i * IXGBE_RTTUP2TC_UP_SHIFT));
+	IXGBE_WRITE_REG(hw, IXGBE_RTTUP2TC, reg);
+
+	/* Configure traffic class credits and priority */
+	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
+		p = &dcb_config->tc_config[i].path[DCB_TX_CONFIG];
+		reg = p->data_credits_refill;
+		reg |= (u32)(p->data_credits_max) << IXGBE_RTTPT2C_MCL_SHIFT;
+		reg |= (u32)(p->bwg_id) << IXGBE_RTTPT2C_BWG_SHIFT;
+
+		if (p->prio_type == prio_group)
+			reg |= IXGBE_RTTPT2C_GSP;
+
+		if (p->prio_type == prio_link)
+			reg |= IXGBE_RTTPT2C_LSP;
+
+		IXGBE_WRITE_REG(hw, IXGBE_RTTPT2C(i), reg);
+	}
+
+	/*
+	 * Configure Tx packet plane (recycle mode; SP; arb delay) and
+	 * enable arbiter
+	 */
+	reg = IXGBE_RTTPCS_TPPAC | IXGBE_RTTPCS_TPRM |
+	      (IXGBE_RTTPCS_ARBD_DCB << IXGBE_RTTPCS_ARBD_SHIFT);
+	IXGBE_WRITE_REG(hw, IXGBE_RTTPCS, reg);
+
+	return 0;
+}
+
+/**
+ * ixgbe_dcb_config_pfc_82599 - Configure priority flow control
+ * @hw: pointer to hardware structure
+ * @dcb_config: pointer to ixgbe_dcb_config structure
+ *
+ * Configure Priority Flow Control (PFC) for each traffic class.
+ */
+s32 ixgbe_dcb_config_pfc_82599(struct ixgbe_hw *hw,
+                               struct ixgbe_dcb_config *dcb_config)
+{
+	u32 i, reg;
+
+	/* If PFC is disabled globally then fall back to LFC. */
+	if (!dcb_config->pfc_mode_enable) {
+		for (i = 0; i < MAX_TRAFFIC_CLASS; i++)
+			hw->mac.ops.setup_fc(hw, i);
+		goto out;
+	}
+
+	/* PFC is mutually exclusive with link flow control */
+	hw->fc.current_mode = ixgbe_fc_none;
+
+	/* Configure PFC Tx thresholds per TC */
+	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
+		/* Config and remember Tx */
+		if (dcb_config->tc_config[i].dcb_pfc == pfc_enabled_full ||
+		    dcb_config->tc_config[i].dcb_pfc == pfc_enabled_tx) {
+			reg = hw->fc.high_water | IXGBE_FCRTH_FCEN;
+			IXGBE_WRITE_REG(hw, IXGBE_FCRTH_82599(i), reg);
+			reg = hw->fc.low_water | IXGBE_FCRTL_XONE;
+			IXGBE_WRITE_REG(hw, IXGBE_FCRTL_82599(i), reg);
+		} else {
+			IXGBE_WRITE_REG(hw, IXGBE_FCRTH_82599(i), 0);
+			IXGBE_WRITE_REG(hw, IXGBE_FCRTL_82599(i), 0);
+		}
+	}
+
+	/* Configure pause time (2 TCs per register) */
+	reg = hw->fc.pause_time | (hw->fc.pause_time << 16);
+	for (i = 0; i < (MAX_TRAFFIC_CLASS / 2); i++)
+		IXGBE_WRITE_REG(hw, IXGBE_FCTTV(i), reg);
+
+	/* Configure flow control refresh threshold value */
+	IXGBE_WRITE_REG(hw, IXGBE_FCRTV, hw->fc.pause_time / 2);
+
+	/* Enable Transmit PFC */
+	reg = IXGBE_FCCFG_TFCE_PRIORITY;
+	IXGBE_WRITE_REG(hw, IXGBE_FCCFG, reg);
+
+	/*
+	 * Enable Receive PFC
+	 * We will always honor XOFF frames we receive when
+	 * we are in PFC mode.
+	 */
+	reg = IXGBE_READ_REG(hw, IXGBE_MFLCN);
+	reg &= ~IXGBE_MFLCN_RFCE;
+	reg |= IXGBE_MFLCN_RPFCE;
+	IXGBE_WRITE_REG(hw, IXGBE_MFLCN, reg);
+out:
+	return 0;
+}
+
+/**
+ * ixgbe_dcb_config_tc_stats_82599 - Config traffic class statistics
+ * @hw: pointer to hardware structure
+ *
+ * Configure queue statistics registers, all queues belonging to same traffic
+ * class uses a single set of queue statistics counters.
+ */
+s32 ixgbe_dcb_config_tc_stats_82599(struct ixgbe_hw *hw)
+{
+	u32 reg = 0;
+	u8  i   = 0;
+
+	/*
+	 * Receive Queues stats setting
+	 * 32 RQSMR registers, each configuring 4 queues.
+	 * Set all 16 queues of each TC to the same stat
+	 * with TC 'n' going to stat 'n'.
+	 */
+	for (i = 0; i < 32; i++) {
+		reg = 0x01010101 * (i / 4);
+		IXGBE_WRITE_REG(hw, IXGBE_RQSMR(i), reg);
+	}
+	/*
+	 * Transmit Queues stats setting
+	 * 32 TQSM registers, each controlling 4 queues.
+	 * Set all queues of each TC to the same stat
+	 * with TC 'n' going to stat 'n'.
+	 * Tx queues are allocated non-uniformly to TCs:
+	 * 32, 32, 16, 16, 8, 8, 8, 8.
+	 */
+	for (i = 0; i < 32; i++) {
+		if (i < 8)
+			reg = 0x00000000;
+		else if (i < 16)
+			reg = 0x01010101;
+		else if (i < 20)
+			reg = 0x02020202;
+		else if (i < 24)
+			reg = 0x03030303;
+		else if (i < 26)
+			reg = 0x04040404;
+		else if (i < 28)
+			reg = 0x05050505;
+		else if (i < 30)
+			reg = 0x06060606;
+		else
+			reg = 0x07070707;
+		IXGBE_WRITE_REG(hw, IXGBE_TQSM(i), reg);
+	}
+
+	return 0;
+}
+
+/**
+ * ixgbe_dcb_config_82599 - Configure general DCB parameters
+ * @hw: pointer to hardware structure
+ * @dcb_config: pointer to ixgbe_dcb_config structure
+ *
+ * Configure general DCB parameters.
+ */
+s32 ixgbe_dcb_config_82599(struct ixgbe_hw *hw)
+{
+	u32 reg;
+	u32 q;
+
+	/* Disable the Tx desc arbiter so that MTQC can be changed */
+	reg = IXGBE_READ_REG(hw, IXGBE_RTTDCS);
+	reg |= IXGBE_RTTDCS_ARBDIS;
+	IXGBE_WRITE_REG(hw, IXGBE_RTTDCS, reg);
+
+	/* Enable DCB for Rx with 8 TCs */
+	reg = IXGBE_READ_REG(hw, IXGBE_MRQC);
+	switch (reg & IXGBE_MRQC_MRQE_MASK) {
+	case 0:
+	case IXGBE_MRQC_RT4TCEN:
+		/* RSS disabled cases */
+		reg = (reg & ~IXGBE_MRQC_MRQE_MASK) | IXGBE_MRQC_RT8TCEN;
+		break;
+	case IXGBE_MRQC_RSSEN:
+	case IXGBE_MRQC_RTRSS4TCEN:
+		/* RSS enabled cases */
+		reg = (reg & ~IXGBE_MRQC_MRQE_MASK) | IXGBE_MRQC_RTRSS8TCEN;
+		break;
+	default:
+		/* Unsupported value, assume stale data, overwrite no RSS */
+		reg = (reg & ~IXGBE_MRQC_MRQE_MASK) | IXGBE_MRQC_RT8TCEN;
+	}
+	IXGBE_WRITE_REG(hw, IXGBE_MRQC, reg);
+
+	/* Enable DCB for Tx with 8 TCs */
+	reg = IXGBE_MTQC_RT_ENA | IXGBE_MTQC_8TC_8TQ;
+	IXGBE_WRITE_REG(hw, IXGBE_MTQC, reg);
+
+	/* Disable drop for all queues */
+	for (q = 0; q < 128; q++)
+		IXGBE_WRITE_REG(hw, IXGBE_QDE, q << IXGBE_QDE_IDX_SHIFT);
+
+	/* Enable the Tx desc arbiter */
+	reg = IXGBE_READ_REG(hw, IXGBE_RTTDCS);
+	reg &= ~IXGBE_RTTDCS_ARBDIS;
+	IXGBE_WRITE_REG(hw, IXGBE_RTTDCS, reg);
+
+	return 0;
+}
+
+/**
+ * ixgbe_dcb_hw_config_82599 - Configure and enable DCB
+ * @hw: pointer to hardware structure
+ * @dcb_config: pointer to ixgbe_dcb_config structure
+ *
+ * Configure dcb settings and enable dcb mode.
+ */
+s32 ixgbe_dcb_hw_config_82599(struct ixgbe_hw *hw,
+                              struct ixgbe_dcb_config *dcb_config)
+{
+	u32  pap = 0;
+
+	ixgbe_dcb_config_packet_buffers_82599(hw, dcb_config);
+	ixgbe_dcb_config_82599(hw);
+	ixgbe_dcb_config_rx_arbiter_82599(hw, dcb_config);
+	ixgbe_dcb_config_tx_desc_arbiter_82599(hw, dcb_config);
+	ixgbe_dcb_config_tx_data_arbiter_82599(hw, dcb_config);
+	ixgbe_dcb_config_pfc_82599(hw, dcb_config);
+	ixgbe_dcb_config_tc_stats_82599(hw);
+
+	return 0;
+}
+
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.h b/drivers/net/ixgbe/ixgbe_dcb_82599.h
new file mode 100644
index 0000000..9e5e282
--- /dev/null
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.h
@@ -0,0 +1,127 @@
+/*******************************************************************************
+
+  Intel 10 Gigabit PCI Express Linux driver
+  Copyright(c) 1999 - 2009 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#ifndef _DCB_82599_CONFIG_H_
+#define _DCB_82599_CONFIG_H_
+
+/* DCB register definitions */
+#define IXGBE_RTTDCS_TDPAC      0x00000001 /* 0 Round Robin,
+                                            * 1 WSP - Weighted Strict Priority
+                                            */
+#define IXGBE_RTTDCS_VMPAC      0x00000002 /* 0 Round Robin,
+                                            * 1 WRR - Weighted Round Robin
+                                            */
+#define IXGBE_RTTDCS_TDRM       0x00000010 /* Transmit Recycle Mode */
+#define IXGBE_RTTDCS_ARBDIS     0x00000040 /* DCB arbiter disable */
+#define IXGBE_RTTDCS_BDPM       0x00400000 /* Bypass Data Pipe - must clear! */
+#define IXGBE_RTTDCS_BPBFSM     0x00800000 /* Bypass PB Free Space - must
+                                             * clear!
+                                             */
+#define IXGBE_RTTDCS_SPEED_CHG  0x80000000 /* Link speed change */
+
+/* Receive UP2TC mapping */
+#define IXGBE_RTRUP2TC_UP_SHIFT 3
+/* Transmit UP2TC mapping */
+#define IXGBE_RTTUP2TC_UP_SHIFT 3
+
+#define IXGBE_RTRPT4C_MCL_SHIFT 12 /* Offset to Max Credit Limit setting */
+#define IXGBE_RTRPT4C_BWG_SHIFT 9  /* Offset to BWG index */
+#define IXGBE_RTRPT4C_GSP       0x40000000 /* GSP enable bit */
+#define IXGBE_RTRPT4C_LSP       0x80000000 /* LSP enable bit */
+
+#define IXGBE_RDRXCTL_MPBEN     0x00000010 /* DMA config for multiple packet
+                                            * buffers enable
+                                            */
+#define IXGBE_RDRXCTL_MCEN      0x00000040 /* DMA config for multiple cores
+                                            * (RSS) enable
+                                            */
+
+/* RTRPCS Bit Masks */
+#define IXGBE_RTRPCS_RRM        0x00000002 /* Receive Recycle Mode enable */
+/* Receive Arbitration Control: 0 Round Robin, 1 DFP */
+#define IXGBE_RTRPCS_RAC        0x00000004
+#define IXGBE_RTRPCS_ARBDIS     0x00000040 /* Arbitration disable bit */
+
+/* RTTDT2C Bit Masks */
+#define IXGBE_RTTDT2C_MCL_SHIFT 12
+#define IXGBE_RTTDT2C_BWG_SHIFT 9
+#define IXGBE_RTTDT2C_GSP       0x40000000
+#define IXGBE_RTTDT2C_LSP       0x80000000
+
+#define IXGBE_RTTPT2C_MCL_SHIFT 12
+#define IXGBE_RTTPT2C_BWG_SHIFT 9
+#define IXGBE_RTTPT2C_GSP       0x40000000
+#define IXGBE_RTTPT2C_LSP       0x80000000
+
+/* RTTPCS Bit Masks */
+#define IXGBE_RTTPCS_TPPAC      0x00000020 /* 0 Round Robin,
+                                            * 1 SP - Strict Priority
+                                            */
+#define IXGBE_RTTPCS_ARBDIS     0x00000040 /* Arbiter disable */
+#define IXGBE_RTTPCS_TPRM       0x00000100 /* Transmit Recycle Mode enable */
+#define IXGBE_RTTPCS_ARBD_SHIFT 22
+#define IXGBE_RTTPCS_ARBD_DCB   0x4        /* Arbitration delay in DCB mode */
+
+#define IXGBE_TXPBSIZE_20KB     0x00005000 /* 20KB Packet Buffer */
+#define IXGBE_TXPBSIZE_40KB     0x0000A000 /* 40KB Packet Buffer */
+#define IXGBE_RXPBSIZE_48KB     0x0000C000 /* 48KB Packet Buffer */
+#define IXGBE_RXPBSIZE_64KB     0x00010000 /* 64KB Packet Buffer */
+#define IXGBE_RXPBSIZE_80KB     0x00014000 /* 80KB Packet Buffer */
+#define IXGBE_RXPBSIZE_128KB    0x00020000 /* 128KB Packet Buffer */
+
+#define IXGBE_TXPBTHRESH_DCB    0xA        /* THRESH value for DCB mode */
+
+
+/* DCB hardware-specific driver APIs */
+
+/* DCB PFC functions */
+s32 ixgbe_dcb_config_pfc_82599(struct ixgbe_hw *hw,
+                               struct ixgbe_dcb_config *dcb_config);
+s32 ixgbe_dcb_get_pfc_stats_82599(struct ixgbe_hw *hw,
+                                  struct ixgbe_hw_stats *stats,
+                                  u8 tc_count);
+
+/* DCB traffic class stats */
+s32 ixgbe_dcb_config_tc_stats_82599(struct ixgbe_hw *hw);
+s32 ixgbe_dcb_get_tc_stats_82599(struct ixgbe_hw *hw,
+                                 struct ixgbe_hw_stats *stats,
+                                 u8 tc_count);
+
+/* DCB config arbiters */
+s32 ixgbe_dcb_config_tx_desc_arbiter_82599(struct ixgbe_hw *hw,
+                                           struct ixgbe_dcb_config *dcb_config);
+s32 ixgbe_dcb_config_tx_data_arbiter_82599(struct ixgbe_hw *hw,
+                                           struct ixgbe_dcb_config *dcb_config);
+s32 ixgbe_dcb_config_rx_arbiter_82599(struct ixgbe_hw *hw,
+                                      struct ixgbe_dcb_config *dcb_config);
+
+
+/* DCB hw initialization */
+s32 ixgbe_dcb_hw_config_82599(struct ixgbe_hw *hw,
+                              struct ixgbe_dcb_config *config);
+
+#endif /* _DCB_82599_CONFIG_H */
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index dd9d1d6..087cf88 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -35,6 +35,7 @@
 #define BIT_PG_RX	0x04
 #define BIT_PG_TX	0x08
 #define BIT_BCN         0x10
+#define BIT_LINKSPEED   0x80
 
 int ixgbe_copy_dcb_cfg(struct ixgbe_dcb_config *src_dcb_cfg,
                        struct ixgbe_dcb_config *dst_dcb_cfg, int tc_max)
@@ -89,25 +90,6 @@ int ixgbe_copy_dcb_cfg(struct ixgbe_dcb_config *src_dcb_cfg,
 			src_dcb_cfg->tc_config[i - DCB_PFC_UP_ATTR_0].dcb_pfc;
 	}
 
-	for (i = DCB_BCN_ATTR_RP_0; i < DCB_BCN_ATTR_RP_ALL; i++) {
-		dst_dcb_cfg->bcn.rp_admin_mode[i - DCB_BCN_ATTR_RP_0] =
-			src_dcb_cfg->bcn.rp_admin_mode[i - DCB_BCN_ATTR_RP_0];
-	}
-	dst_dcb_cfg->bcn.bcna_option[0] = src_dcb_cfg->bcn.bcna_option[0];
-	dst_dcb_cfg->bcn.bcna_option[1] = src_dcb_cfg->bcn.bcna_option[1];
-	dst_dcb_cfg->bcn.rp_alpha = src_dcb_cfg->bcn.rp_alpha;
-	dst_dcb_cfg->bcn.rp_beta = src_dcb_cfg->bcn.rp_beta;
-	dst_dcb_cfg->bcn.rp_gd = src_dcb_cfg->bcn.rp_gd;
-	dst_dcb_cfg->bcn.rp_gi = src_dcb_cfg->bcn.rp_gi;
-	dst_dcb_cfg->bcn.rp_tmax = src_dcb_cfg->bcn.rp_tmax;
-	dst_dcb_cfg->bcn.rp_td = src_dcb_cfg->bcn.rp_td;
-	dst_dcb_cfg->bcn.rp_rmin = src_dcb_cfg->bcn.rp_rmin;
-	dst_dcb_cfg->bcn.rp_w = src_dcb_cfg->bcn.rp_w;
-	dst_dcb_cfg->bcn.rp_rd = src_dcb_cfg->bcn.rp_rd;
-	dst_dcb_cfg->bcn.rp_ru = src_dcb_cfg->bcn.rp_ru;
-	dst_dcb_cfg->bcn.rp_wrtt = src_dcb_cfg->bcn.rp_wrtt;
-	dst_dcb_cfg->bcn.rp_ri = src_dcb_cfg->bcn.rp_ri;
-
 	return 0;
 }
 
@@ -444,175 +426,6 @@ static void ixgbe_dcbnl_setpfcstate(struct net_device *netdev, u8 state)
 	return;
 }
 
-static void ixgbe_dcbnl_getbcnrp(struct net_device *netdev, int priority,
-				  u8 *setting)
-{
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-
-	*setting = adapter->dcb_cfg.bcn.rp_admin_mode[priority];
-}
-
-
-static void ixgbe_dcbnl_getbcncfg(struct net_device *netdev, int enum_index,
-				  u32 *setting)
-{
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-
-	switch (enum_index) {
-	case DCB_BCN_ATTR_BCNA_0:
-		*setting = adapter->dcb_cfg.bcn.bcna_option[0];
-		break;
-	case DCB_BCN_ATTR_BCNA_1:
-		*setting = adapter->dcb_cfg.bcn.bcna_option[1];
-		break;
-	case DCB_BCN_ATTR_ALPHA:
-		*setting = adapter->dcb_cfg.bcn.rp_alpha;
-		break;
-	case DCB_BCN_ATTR_BETA:
-		*setting = adapter->dcb_cfg.bcn.rp_beta;
-		break;
-	case DCB_BCN_ATTR_GD:
-		*setting = adapter->dcb_cfg.bcn.rp_gd;
-		break;
-	case DCB_BCN_ATTR_GI:
-		*setting = adapter->dcb_cfg.bcn.rp_gi;
-		break;
-	case DCB_BCN_ATTR_TMAX:
-		*setting = adapter->dcb_cfg.bcn.rp_tmax;
-		break;
-	case DCB_BCN_ATTR_TD:
-		*setting = adapter->dcb_cfg.bcn.rp_td;
-		break;
-	case DCB_BCN_ATTR_RMIN:
-		*setting = adapter->dcb_cfg.bcn.rp_rmin;
-		break;
-	case DCB_BCN_ATTR_W:
-		*setting = adapter->dcb_cfg.bcn.rp_w;
-		break;
-	case DCB_BCN_ATTR_RD:
-		*setting = adapter->dcb_cfg.bcn.rp_rd;
-		break;
-	case DCB_BCN_ATTR_RU:
-		*setting = adapter->dcb_cfg.bcn.rp_ru;
-		break;
-	case DCB_BCN_ATTR_WRTT:
-		*setting = adapter->dcb_cfg.bcn.rp_wrtt;
-		break;
-	case DCB_BCN_ATTR_RI:
-		*setting = adapter->dcb_cfg.bcn.rp_ri;
-		break;
-	default:
-		*setting = -1;
-	}
-}
-
-static void ixgbe_dcbnl_setbcnrp(struct net_device *netdev, int priority,
-				 u8 setting)
-{
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-
-	adapter->temp_dcb_cfg.bcn.rp_admin_mode[priority] = setting;
-
-	if (adapter->temp_dcb_cfg.bcn.rp_admin_mode[priority] !=
-	    adapter->dcb_cfg.bcn.rp_admin_mode[priority])
-		adapter->dcb_set_bitmap |= BIT_BCN;
-}
-
-static void ixgbe_dcbnl_setbcncfg(struct net_device *netdev, int enum_index,
-				 u32 setting)
-{
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-
-	switch (enum_index) {
-	case DCB_BCN_ATTR_BCNA_0:
-		adapter->temp_dcb_cfg.bcn.bcna_option[0] = setting;
-		if (adapter->temp_dcb_cfg.bcn.bcna_option[0] !=
-			adapter->dcb_cfg.bcn.bcna_option[0])
-			adapter->dcb_set_bitmap |= BIT_BCN;
-		break;
-	case DCB_BCN_ATTR_BCNA_1:
-		adapter->temp_dcb_cfg.bcn.bcna_option[1] = setting;
-		if (adapter->temp_dcb_cfg.bcn.bcna_option[1] !=
-			adapter->dcb_cfg.bcn.bcna_option[1])
-			adapter->dcb_set_bitmap |= BIT_BCN;
-		break;
-	case DCB_BCN_ATTR_ALPHA:
-		adapter->temp_dcb_cfg.bcn.rp_alpha = setting;
-		if (adapter->temp_dcb_cfg.bcn.rp_alpha !=
-		    adapter->dcb_cfg.bcn.rp_alpha)
-			adapter->dcb_set_bitmap |= BIT_BCN;
-		break;
-	case DCB_BCN_ATTR_BETA:
-		adapter->temp_dcb_cfg.bcn.rp_beta = setting;
-		if (adapter->temp_dcb_cfg.bcn.rp_beta !=
-		    adapter->dcb_cfg.bcn.rp_beta)
-			adapter->dcb_set_bitmap |= BIT_BCN;
-		break;
-	case DCB_BCN_ATTR_GD:
-		adapter->temp_dcb_cfg.bcn.rp_gd = setting;
-		if (adapter->temp_dcb_cfg.bcn.rp_gd !=
-		    adapter->dcb_cfg.bcn.rp_gd)
-			adapter->dcb_set_bitmap |= BIT_BCN;
-		break;
-	case DCB_BCN_ATTR_GI:
-		adapter->temp_dcb_cfg.bcn.rp_gi = setting;
-		if (adapter->temp_dcb_cfg.bcn.rp_gi !=
-		    adapter->dcb_cfg.bcn.rp_gi)
-			adapter->dcb_set_bitmap |= BIT_BCN;
-		break;
-	case DCB_BCN_ATTR_TMAX:
-		adapter->temp_dcb_cfg.bcn.rp_tmax = setting;
-		if (adapter->temp_dcb_cfg.bcn.rp_tmax !=
-		    adapter->dcb_cfg.bcn.rp_tmax)
-			adapter->dcb_set_bitmap |= BIT_BCN;
-		break;
-	case DCB_BCN_ATTR_TD:
-		adapter->temp_dcb_cfg.bcn.rp_td = setting;
-		if (adapter->temp_dcb_cfg.bcn.rp_td !=
-		    adapter->dcb_cfg.bcn.rp_td)
-			adapter->dcb_set_bitmap |= BIT_BCN;
-		break;
-	case DCB_BCN_ATTR_RMIN:
-		adapter->temp_dcb_cfg.bcn.rp_rmin = setting;
-		if (adapter->temp_dcb_cfg.bcn.rp_rmin !=
-		    adapter->dcb_cfg.bcn.rp_rmin)
-			adapter->dcb_set_bitmap |= BIT_BCN;
-		break;
-	case DCB_BCN_ATTR_W:
-		adapter->temp_dcb_cfg.bcn.rp_w = setting;
-		if (adapter->temp_dcb_cfg.bcn.rp_w !=
-		    adapter->dcb_cfg.bcn.rp_w)
-			adapter->dcb_set_bitmap |= BIT_BCN;
-		break;
-	case DCB_BCN_ATTR_RD:
-		adapter->temp_dcb_cfg.bcn.rp_rd = setting;
-		if (adapter->temp_dcb_cfg.bcn.rp_rd !=
-		    adapter->dcb_cfg.bcn.rp_rd)
-			adapter->dcb_set_bitmap |= BIT_BCN;
-		break;
-	case DCB_BCN_ATTR_RU:
-		adapter->temp_dcb_cfg.bcn.rp_ru = setting;
-		if (adapter->temp_dcb_cfg.bcn.rp_ru !=
-		    adapter->dcb_cfg.bcn.rp_ru)
-			adapter->dcb_set_bitmap |= BIT_BCN;
-		break;
-	case DCB_BCN_ATTR_WRTT:
-		adapter->temp_dcb_cfg.bcn.rp_wrtt = setting;
-		if (adapter->temp_dcb_cfg.bcn.rp_wrtt !=
-		    adapter->dcb_cfg.bcn.rp_wrtt)
-			adapter->dcb_set_bitmap |= BIT_BCN;
-		break;
-	case DCB_BCN_ATTR_RI:
-		adapter->temp_dcb_cfg.bcn.rp_ri = setting;
-		if (adapter->temp_dcb_cfg.bcn.rp_ri !=
-		    adapter->dcb_cfg.bcn.rp_ri)
-			adapter->dcb_set_bitmap |= BIT_BCN;
-		break;
-	default:
-		break;
-	}
-}
-
 struct dcbnl_rtnl_ops dcbnl_ops = {
 	.getstate	= ixgbe_dcbnl_get_state,
 	.setstate	= ixgbe_dcbnl_set_state,
@@ -633,9 +446,5 @@ struct dcbnl_rtnl_ops dcbnl_ops = {
 	.setnumtcs	= ixgbe_dcbnl_setnumtcs,
 	.getpfcstate	= ixgbe_dcbnl_getpfcstate,
 	.setpfcstate	= ixgbe_dcbnl_setpfcstate,
-	.getbcncfg      = ixgbe_dcbnl_getbcncfg,
-	.getbcnrp       = ixgbe_dcbnl_getbcnrp,
-	.setbcncfg      = ixgbe_dcbnl_setbcncfg,
-	.setbcnrp       = ixgbe_dcbnl_setbcnrp
 };
 

