From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH 2/3] ixgbe: Add DCB hardware initialization routines
Date: Thu, 01 May 2008 17:43:05 -0700
Message-ID: <20080502004305.14392.78170.stgit@localhost.localdomain>
References: <20080502004254.14392.7599.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:29852 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754106AbYEBHmU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2008 03:42:20 -0400
In-Reply-To: <20080502004254.14392.7599.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the shared code functions for DCB functionality.  These
routines take care of the bandwidth credit calculations for the hardware
arbiters, takes care of priority grouping changes, and all the hardware
writes to enable these features in 82598.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb.c       |  330 +++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_dcb.h       |  168 +++++++++++++++
 drivers/net/ixgbe/ixgbe_dcb_82598.c |  400 +++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_dcb_82598.h |   98 +++++++++
 4 files changed, 996 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb.c b/drivers/net/ixgbe/ixgbe_dcb.c
new file mode 100644
index 0000000..28f190a
--- /dev/null
+++ b/drivers/net/ixgbe/ixgbe_dcb.c
@@ -0,0 +1,330 @@
+/*******************************************************************************
+
+  Intel 10 Gigabit PCI Express Linux driver
+  Copyright(c) 1999 - 2007 Intel Corporation.
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
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+
+#include "ixgbe.h"
+#include "ixgbe_type.h"
+#include "ixgbe_dcb.h"
+#include "ixgbe_dcb_82598.h"
+
+/**
+ * ixgbe_dcb_config - Struct containing DCB settings.
+ * @dcb_config: Pointer to DCB config structure
+ *
+ * This function checks DCB rules for DCB settings.
+ * The following rules are checked:
+ * 1. The sum of bandwidth percentages of all Bandwidth Groups must total 100%.
+ * 2. The sum of bandwidth percentages of all Traffic Classes within a Bandwidth
+ *    Group must total 100.
+ * 3. A Traffic Class should not be set to both Link Strict Priority
+ *    and Group Strict Priority.
+ * 4. Link strict Bandwidth Groups can only have link strict traffic classes
+ *    with zero bandwidth.
+ */
+s32 ixgbe_dcb_check_config(struct ixgbe_dcb_config *dcb_config)
+{
+	struct tc_bw_alloc *p;
+	s32 ret_val = 0;
+	u8 i, j, bw = 0, bw_id;
+	u8 bw_sum[2][MAX_BW_GROUP];
+	bool link_strict[2][MAX_BW_GROUP];
+
+	memset(bw_sum, 0, sizeof(bw_sum));
+	memset(link_strict, 0, sizeof(link_strict));
+
+	/* First Tx, then Rx */
+	for (i = 0; i < 2; i++) {
+		/* Check each traffic class for rule violation */
+		for (j = 0; j < MAX_TRAFFIC_CLASS; j++) {
+			p = &dcb_config->tc_config[j].path[i];
+
+			bw = p->bwg_percent;
+			bw_id = p->bwg_id;
+
+			if (bw_id >= MAX_BW_GROUP) {
+				ret_val = DCB_ERR_CONFIG;
+				goto err_config;
+			}
+			if (p->prio_type == prio_link) {
+				link_strict[i][bw_id] = true;
+				/* Link strict should have zero bandwidth */
+				if (bw) {
+					ret_val = DCB_ERR_LS_BW_NONZERO;
+					goto err_config;
+				}
+			} else if (!bw) {
+				/*
+				 * Traffic classes without link strict
+				 * should have non-zero bandwidth.
+				 */
+				ret_val = DCB_ERR_TC_BW_ZERO;
+				goto err_config;
+			}
+			bw_sum[i][bw_id] += bw;
+		}
+
+		bw = 0;
+
+		/* Check each bandwidth group for rule violation */
+		for (j = 0; j < MAX_BW_GROUP; j++) {
+			bw += dcb_config->bw_percentage[i][j];
+			/*
+			 * Sum of bandwidth percentages of all traffic classes
+			 * within a Bandwidth Group must total 100 except for
+			 * link strict group (zero bandwidth).
+			 */
+			if (link_strict[i][j]) {
+				if (bw_sum[i][j]) {
+					/*
+					 * Link strict group should have zero
+					 * bandwidth.
+					 */
+					ret_val = DCB_ERR_LS_BWG_NONZERO;
+					goto err_config;
+				}
+			} else if (bw_sum[i][j] != BW_PERCENT &&
+			           bw_sum[i][j] != 0) {
+				ret_val = DCB_ERR_TC_BW;
+				goto err_config;
+			}
+		}
+
+		if (bw != BW_PERCENT) {
+			ret_val = DCB_ERR_BW_GROUP;
+			goto err_config;
+		}
+	}
+
+err_config:
+	return ret_val;
+}
+
+/**
+ * ixgbe_dcb_calculate_tc_credits - Calculates traffic class credits
+ * @ixgbe_dcb_config: Struct containing DCB settings.
+ * @direction: Configuring either Tx or Rx.
+ *
+ * This function calculates the credits allocated to each traffic class.
+ * It should be called only after the rules are checked by
+ * ixgbe_dcb_check_config().
+ */
+s32 ixgbe_dcb_calculate_tc_credits(struct ixgbe_dcb_config *dcb_config,
+                                   u8 direction)
+{
+	struct tc_bw_alloc *p;
+	s32 ret_val = 0;
+	/* Initialization values default for Tx settings */
+	u32 credit_refill       = 0;
+	u32 credit_max          = 0;
+	u16 link_percentage     = 0;
+	u8  bw_percent          = 0;
+	u8  i;
+
+	if (dcb_config == NULL) {
+		ret_val = DCB_ERR_CONFIG;
+		goto out;
+	}
+
+	/* Find out the link percentage for each TC first */
+	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
+		p = &dcb_config->tc_config[i].path[direction];
+		bw_percent = dcb_config->bw_percentage[direction][p->bwg_id];
+
+		link_percentage = p->bwg_percent;
+		/* Must be careful of integer division for very small nums */
+		link_percentage = (link_percentage * bw_percent) / 100;
+		if (p->bwg_percent > 0 && link_percentage == 0)
+			link_percentage = 1;
+
+		/* Save link_percentage for reference */
+		p->link_percent = (u8)link_percentage;
+
+		/* Calculate credit refill and save it */
+		credit_refill = link_percentage * MINIMUM_CREDIT_REFILL;
+		p->data_credits_refill = (u16)credit_refill;
+
+		/* Calculate maximum credit for the TC */
+		credit_max = (link_percentage * MAX_CREDIT) / 100;
+
+		/*
+		 * Adjustment based on rule checking, if the percentage
+		 * of a TC is too small, the maximum credit may not be
+		 * enough to send out a jumbo frame in data plane arbitration.
+		 */
+		if (credit_max && credit_max < MINIMUM_CREDIT_FOR_JUMBO)
+			credit_max = MINIMUM_CREDIT_FOR_JUMBO;
+
+		if (direction == DCB_TX_CONFIG) {
+			/*
+			 * Adjustment based on rule checking, if the
+			 * percentage of a TC is too small, the maximum
+			 * credit may not be enough to send out a TSO
+			 * packet in descriptor plane arbitration.
+			 */
+			if (credit_max &&
+			    (credit_max < MINIMUM_CREDIT_FOR_TSO))
+				credit_max = MINIMUM_CREDIT_FOR_TSO;
+
+			dcb_config->tc_config[i].desc_credits_max = (u16)credit_max;
+		}
+
+		p->data_credits_max = (u16)credit_max;
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ * ixgbe_dcb_get_tc_stats - Returns status of each traffic class
+ * @hw: pointer to hardware structure
+ * @stats: pointer to statistics structure
+ * @tc_count:  Number of elements in bwg_array.
+ *
+ * This function returns the status data for each of the Traffic Classes in use.
+ */
+s32 ixgbe_dcb_get_tc_stats(struct ixgbe_hw *hw, struct ixgbe_hw_stats *stats,
+                           u8 tc_count)
+{
+	s32 ret = 0;
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		ret = ixgbe_dcb_get_tc_stats_82598(hw, stats, tc_count);
+	return ret;
+}
+
+/**
+ * ixgbe_dcb_get_pfc_stats - Returns CBFC status of each traffic class
+ * hw - pointer to hardware structure
+ * stats - pointer to statistics structure
+ * tc_count -  Number of elements in bwg_array.
+ *
+ * This function returns the CBFC status data for each of the Traffic Classes.
+ */
+s32 ixgbe_dcb_get_pfc_stats(struct ixgbe_hw *hw, struct ixgbe_hw_stats *stats,
+                            u8 tc_count)
+{
+	s32 ret = 0;
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		ret = ixgbe_dcb_get_pfc_stats_82598(hw, stats, tc_count);
+	return ret;
+}
+
+/**
+ * ixgbe_dcb_config_rx_arbiter - Config Rx arbiter
+ * @hw: pointer to hardware structure
+ * @dcb_config: pointer to ixgbe_dcb_config structure
+ *
+ * Configure Rx Data Arbiter and credits for each traffic class.
+ */
+s32 ixgbe_dcb_config_rx_arbiter(struct ixgbe_hw *hw,
+                                struct ixgbe_dcb_config *dcb_config)
+{
+	s32 ret = 0;
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		ret = ixgbe_dcb_config_rx_arbiter_82598(hw, dcb_config);
+	return ret;
+}
+
+/**
+ * ixgbe_dcb_config_tx_desc_arbiter - Config Tx Desc arbiter
+ * @hw: pointer to hardware structure
+ * @dcb_config: pointer to ixgbe_dcb_config structure
+ *
+ * Configure Tx Descriptor Arbiter and credits for each traffic class.
+ */
+s32 ixgbe_dcb_config_tx_desc_arbiter(struct ixgbe_hw *hw,
+                                     struct ixgbe_dcb_config *dcb_config)
+{
+	s32 ret = 0;
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		ret = ixgbe_dcb_config_tx_desc_arbiter_82598(hw, dcb_config);
+	return ret;
+}
+
+/**
+ * ixgbe_dcb_config_tx_data_arbiter - Config Tx data arbiter
+ * @hw: pointer to hardware structure
+ * @dcb_config: pointer to ixgbe_dcb_config structure
+ *
+ * Configure Tx Data Arbiter and credits for each traffic class.
+ */
+s32 ixgbe_dcb_config_tx_data_arbiter(struct ixgbe_hw *hw,
+                                     struct ixgbe_dcb_config *dcb_config)
+{
+	s32 ret = 0;
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		ret = ixgbe_dcb_config_tx_data_arbiter_82598(hw, dcb_config);
+	return ret;
+}
+
+/**
+ * ixgbe_dcb_config_pfc - Config priority flow control
+ * @hw: pointer to hardware structure
+ * @dcb_config: pointer to ixgbe_dcb_config structure
+ *
+ * Configure Priority Flow Control for each traffic class.
+ */
+s32 ixgbe_dcb_config_pfc(struct ixgbe_hw *hw,
+                         struct ixgbe_dcb_config *dcb_config)
+{
+	s32 ret = 0;
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		ret = ixgbe_dcb_config_pfc_82598(hw, dcb_config);
+	return ret;
+}
+
+/**
+ * ixgbe_dcb_config_tc_stats - Config traffic class statistics
+ * @hw: pointer to hardware structure
+ *
+ * Configure queue statistics registers, all queues belonging to same traffic
+ * class uses a single set of queue statistics counters.
+ */
+s32 ixgbe_dcb_config_tc_stats(struct ixgbe_hw *hw)
+{
+	s32 ret = 0;
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		ret = ixgbe_dcb_config_tc_stats_82598(hw);
+	return ret;
+}
+
+/**
+ * ixgbe_dcb_hw_config - Config and enable DCB
+ * @hw: pointer to hardware structure
+ * @dcb_config: pointer to ixgbe_dcb_config structure
+ *
+ * Configure dcb settings and enable dcb mode.
+ */
+s32 ixgbe_dcb_hw_config(struct ixgbe_hw *hw,
+                        struct ixgbe_dcb_config *dcb_config)
+{
+	s32 ret = 0;
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		ret = ixgbe_dcb_hw_config_82598(hw, dcb_config);
+	return ret;
+}
diff --git a/drivers/net/ixgbe/ixgbe_dcb.h b/drivers/net/ixgbe/ixgbe_dcb.h
new file mode 100644
index 0000000..e19a5f4
--- /dev/null
+++ b/drivers/net/ixgbe/ixgbe_dcb.h
@@ -0,0 +1,168 @@
+/*******************************************************************************
+
+  Intel 10 Gigabit PCI Express Linux driver
+  Copyright(c) 1999 - 2007 Intel Corporation.
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
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#ifndef _DCB_CONFIG_H_
+#define _DCB_CONFIG_H_
+
+#include "ixgbe_type.h"
+
+/* DCB data structures */
+
+#define IXGBE_MAX_PACKET_BUFFERS 8
+#define MAX_USER_PRIORITY        8
+#define MAX_TRAFFIC_CLASS        8
+#define MAX_BW_GROUP             8
+#define BW_PERCENT               100
+
+#define DCB_TX_CONFIG            0
+#define DCB_RX_CONFIG            1
+
+/* DCB error Codes */
+#define DCB_SUCCESS              0
+#define DCB_ERR_CONFIG           -1
+#define DCB_ERR_PARAM            -2
+
+/* Transmit and receive Errors */
+/* Error in bandwidth group allocation */
+#define DCB_ERR_BW_GROUP        -3
+/* Error in traffic class bandwidth allocation */
+#define DCB_ERR_TC_BW           -4
+/* Traffic class has both link strict and group strict enabled */
+#define DCB_ERR_LS_GS           -5
+/* Link strict traffic class has non zero bandwidth */
+#define DCB_ERR_LS_BW_NONZERO   -6
+/* Link strict bandwidth group has non zero bandwidth */
+#define DCB_ERR_LS_BWG_NONZERO  -7
+/*  Traffic class has zero bandwidth */
+#define DCB_ERR_TC_BW_ZERO      -8
+
+#define DCB_NOT_IMPLEMENTED      0x7FFFFFFF
+
+struct dcb_pfc_tc_debug
+{
+	u8  tc;
+	u8  pause_status;
+	u64 pause_quanta;
+};
+
+enum strict_prio_type {
+	prio_none = 0,
+	prio_group,
+	prio_link
+};
+
+/* Traffic class bandwidth allocation per direction */
+struct tc_bw_alloc
+{
+	u8 bwg_id;                /* Bandwidth Group (BWG) ID */
+	u8 bwg_percent;           /* % of BWG's bandwidth */
+	u8 link_percent;          /* % of link bandwidth */
+	u8 up_to_tc_bitmap;       /* User Priority to Traffic Class mapping */
+	u16 data_credits_refill;  /* Credit refill amount in 64B granularity */
+	u16 data_credits_max;     /* Max credits for a configured packet buffer
+	                           * in 64B granularity.*/
+	enum strict_prio_type prio_type; /* Link or Group Strict Priority */
+};
+
+enum dcb_pfc_type {
+	pfc_disabled = 0,
+	pfc_enabled_full,
+	pfc_enabled_tx,
+	pfc_enabled_rx
+};
+
+/* Traffic class configuration */
+struct tc_configuration
+{
+	struct tc_bw_alloc path[2]; /* One each for Tx/Rx */
+	enum dcb_pfc_type  dcb_pfc; /* Class based flow control setting */
+
+	u16 desc_credits_max; /* For Tx Descriptor arbitration */
+	u8 tc; /* Traffic class (TC) */
+};
+
+enum dcb_rx_pba_cfg {
+	pba_equal,     /* PBA[0-7] each use 64KB FIFO */
+	pba_80_48      /* PBA[0-3] each use 80KB, PBA[4-7] each use 48KB */
+};
+
+struct ixgbe_dcb_config
+{
+	struct tc_configuration tc_config[MAX_TRAFFIC_CLASS];
+	u8     bw_percentage[2][MAX_BW_GROUP]; /* One each for Tx/Rx */
+
+	bool  round_robin_enable;
+
+	enum dcb_rx_pba_cfg rx_pba_cfg;
+
+	u32  dcb_cfg_version; /* Not used...OS-specific? */
+	u32  link_speed; /* For bandwidth allocation validation purpose */
+};
+
+
+/* DCB driver APIs */
+
+/* DCB rule checking function.*/
+s32 ixgbe_dcb_check_config(struct ixgbe_dcb_config *config);
+
+/* DCB credits calculation */
+s32 ixgbe_dcb_calculate_tc_credits(struct ixgbe_dcb_config *config,
+                                   u8 direction);
+
+/* DCB PFC functions */
+s32 ixgbe_dcb_config_pfc(struct ixgbe_hw *hw,
+                         struct ixgbe_dcb_config *dcb_config);
+s32 ixgbe_dcb_get_pfc_stats(struct ixgbe_hw *hw, struct ixgbe_hw_stats *stats,
+                            u8 tc_count);
+
+/* DCB traffic class stats */
+s32 ixgbe_dcb_config_tc_stats(struct ixgbe_hw *);
+s32 ixgbe_dcb_get_tc_stats(struct ixgbe_hw *hw, struct ixgbe_hw_stats *stats,
+                           u8 tc_count);
+
+/* DCB config arbiters */
+s32 ixgbe_dcb_config_tx_desc_arbiter(struct ixgbe_hw *hw,
+                                     struct ixgbe_dcb_config *dcb_config);
+s32 ixgbe_dcb_config_tx_data_arbiter(struct ixgbe_hw *hw,
+                                     struct ixgbe_dcb_config *dcb_config);
+s32 ixgbe_dcb_config_rx_arbiter(struct ixgbe_hw *hw,
+                                struct ixgbe_dcb_config *dcb_config);
+
+/* DCB hw initialization */
+s32 ixgbe_dcb_hw_config(struct ixgbe_hw *hw, struct ixgbe_dcb_config *config);
+
+
+/* DCB definitions for credit calculation */
+#define MAX_CREDIT_REFILL       511  /* 0x1FF * 64B = 32704B */
+#define MINIMUM_CREDIT_REFILL   5    /* 5*64B = 320B */
+#define MINIMUM_CREDIT_FOR_JUMBO 145  /* 145= UpperBound((9*1024+54)/64B) for 9KB jumbo frame */
+#define DCB_MAX_TSO_SIZE        32*1024 /* MAX TSO packet size supported in DCB mode */
+#define MINIMUM_CREDIT_FOR_TSO  (DCB_MAX_TSO_SIZE/64 + 1) /* 513 for 32KB TSO packet */
+#define MAX_CREDIT              4095 /* Maximum credit supported: 256KB * 1204 / 64B */
+
+#endif /* _DCB_CONFIG_H */
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.c b/drivers/net/ixgbe/ixgbe_dcb_82598.c
new file mode 100644
index 0000000..39b63ee
--- /dev/null
+++ b/drivers/net/ixgbe/ixgbe_dcb_82598.c
@@ -0,0 +1,400 @@
+/*******************************************************************************
+
+  Intel 10 Gigabit PCI Express Linux driver
+  Copyright(c) 1999 - 2007 Intel Corporation.
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
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+
+#include "ixgbe_type.h"
+#include "ixgbe_dcb.h"
+#include "ixgbe_dcb_82598.h"
+
+/**
+ * ixgbe_dcb_get_tc_stats_82598 - Return status data for each traffic class
+ * @hw: pointer to hardware structure
+ * @stats: pointer to statistics structure
+ * @tc_count:  Number of elements in bwg_array.
+ *
+ * This function returns the status data for each of the Traffic Classes in use.
+ */
+s32 ixgbe_dcb_get_tc_stats_82598(struct ixgbe_hw *hw,
+                                 struct ixgbe_hw_stats *stats,
+                                 u8 tc_count)
+{
+	int tc;
+
+	if (tc_count > MAX_TRAFFIC_CLASS)
+		return DCB_ERR_PARAM;
+
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
+ * ixgbe_dcb_get_pfc_stats_82598 - Returns CBFC status data
+ * @hw: pointer to hardware structure
+ * @stats: pointer to statistics structure
+ * @tc_count:  Number of elements in bwg_array.
+ *
+ * This function returns the CBFC status data for each of the Traffic Classes.
+ */
+s32 ixgbe_dcb_get_pfc_stats_82598(struct ixgbe_hw *hw,
+                                  struct ixgbe_hw_stats *stats,
+                                  u8 tc_count)
+{
+	int tc;
+
+	if (tc_count > MAX_TRAFFIC_CLASS)
+		return DCB_ERR_PARAM;
+
+	for (tc = 0; tc < tc_count; tc++) {
+		/* Priority XOFF Transmitted */
+		stats->pxofftxc[tc] += IXGBE_READ_REG(hw, IXGBE_PXOFFTXC(tc));
+		/* Priority XOFF Received */
+		stats->pxoffrxc[tc] += IXGBE_READ_REG(hw, IXGBE_PXOFFRXC(tc));
+	}
+
+	return 0;
+}
+
+/**
+ * ixgbe_dcb_config_packet_buffers_82598 - Configure packet buffers
+ * @hw: pointer to hardware structure
+ * @dcb_config: pointer to ixgbe_dcb_config structure
+ *
+ * Configure packet buffers for DCB mode.
+ */ 
+s32 ixgbe_dcb_config_packet_buffers_82598(struct ixgbe_hw *hw,
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
+		for (; i < 4; i++) {
+			IXGBE_WRITE_REG(hw, IXGBE_RXPBSIZE(i), value);
+		}
+		/* Setup the last four at 48KB...don't re-init i */
+		value = IXGBE_RXPBSIZE_48KB;
+		/* Fall Through */
+	case pba_equal:
+	default:
+		for (; i < IXGBE_MAX_PACKET_BUFFERS; i++) {
+			IXGBE_WRITE_REG(hw, IXGBE_RXPBSIZE(i), value);
+		}
+
+		/* Setup Tx packet buffer sizes */
+		for (i = 0; i < IXGBE_MAX_PACKET_BUFFERS; i++) {
+			IXGBE_WRITE_REG(hw, IXGBE_TXPBSIZE(i),
+			                IXGBE_TXPBSIZE_40KB);
+		}
+		break;
+	}
+
+	return ret_val;
+}
+
+/**
+ * ixgbe_dcb_config_rx_arbiter_82598 - Config Rx data arbiter
+ * @hw: pointer to hardware structure
+ * @dcb_config: pointer to ixgbe_dcb_config structure
+ *
+ * Configure Rx Data Arbiter and credits for each traffic class.
+ */
+s32 ixgbe_dcb_config_rx_arbiter_82598(struct ixgbe_hw *hw,
+                                      struct ixgbe_dcb_config *dcb_config)
+{
+	struct tc_bw_alloc    *p;
+	u32    reg           = 0;
+	u32    credit_refill = 0;
+	u32    credit_max    = 0;
+	u8     i             = 0;
+
+	reg = IXGBE_READ_REG(hw, IXGBE_RUPPBMR) | IXGBE_RUPPBMR_MQA;
+	IXGBE_WRITE_REG(hw, IXGBE_RUPPBMR, reg);
+
+	reg = IXGBE_READ_REG(hw, IXGBE_RMCS);
+	/* Enable Arbiter */
+	reg &= ~IXGBE_RMCS_ARBDIS;
+	/* Enable Receive Recycle within the BWG */
+	reg |= IXGBE_RMCS_RRM;
+	/* Enable Deficit Fixed Priority arbitration*/
+	reg |= IXGBE_RMCS_DFP;
+
+	IXGBE_WRITE_REG(hw, IXGBE_RMCS, reg);
+
+	/* Configure traffic class credits and priority */
+	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
+		p = &dcb_config->tc_config[i].path[DCB_RX_CONFIG];
+		credit_refill = p->data_credits_refill;
+		credit_max    = p->data_credits_max;
+
+		reg = credit_refill | (credit_max << IXGBE_RT2CR_MCL_SHIFT);
+
+		if (p->prio_type == prio_link)
+			reg |= IXGBE_RT2CR_LSP;
+
+		IXGBE_WRITE_REG(hw, IXGBE_RT2CR(i), reg);
+	}
+
+	reg = IXGBE_READ_REG(hw, IXGBE_RDRXCTL);
+	reg |= IXGBE_RDRXCTL_RDMTS_1_2;
+	reg |= IXGBE_RDRXCTL_MPBEN;
+	reg |= IXGBE_RDRXCTL_MCEN;
+	IXGBE_WRITE_REG(hw, IXGBE_RDRXCTL, reg);
+
+	reg = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
+	/* Make sure there is enough descriptors before arbitration */
+	reg &= ~IXGBE_RXCTRL_DMBYPS;
+	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, reg);
+
+	return 0;
+}
+
+/**
+ * ixgbe_dcb_config_tx_desc_arbiter_82598 - Config Tx Desc. arbiter
+ * @hw: pointer to hardware structure
+ * @dcb_config: pointer to ixgbe_dcb_config structure
+ *
+ * Configure Tx Descriptor Arbiter and credits for each traffic class.
+ */
+s32 ixgbe_dcb_config_tx_desc_arbiter_82598(struct ixgbe_hw *hw,
+                                           struct ixgbe_dcb_config *dcb_config)
+{
+	struct tc_bw_alloc *p;
+	u32    reg, max_credits;
+	u8     i;
+
+	reg = IXGBE_READ_REG(hw, IXGBE_DPMCS);
+
+	/* Enable arbiter */
+	reg &= ~IXGBE_DPMCS_ARBDIS;
+	if (!(dcb_config->round_robin_enable)) {
+		/* Enable DFP and Recycle mode */
+		reg |= (IXGBE_DPMCS_TDPAC | IXGBE_DPMCS_TRM);
+	}
+	reg |= IXGBE_DPMCS_TSOEF;
+	/* Configure Max TSO packet size 34KB including payload and headers */
+	reg |= (0x4 << IXGBE_DPMCS_MTSOS_SHIFT);
+
+	IXGBE_WRITE_REG(hw, IXGBE_DPMCS, reg);
+
+	/* Configure traffic class credits and priority */
+	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
+		p = &dcb_config->tc_config[i].path[DCB_TX_CONFIG];
+		max_credits = dcb_config->tc_config[i].desc_credits_max;
+		reg = max_credits << IXGBE_TDTQ2TCCR_MCL_SHIFT;
+		reg |= p->data_credits_refill;
+		reg |= (u32)(p->bwg_id) << IXGBE_TDTQ2TCCR_BWG_SHIFT;
+
+		if (p->prio_type == prio_group)
+			reg |= IXGBE_TDTQ2TCCR_GSP;
+
+		if (p->prio_type == prio_link)
+			reg |= IXGBE_TDTQ2TCCR_LSP;
+
+		IXGBE_WRITE_REG(hw, IXGBE_TDTQ2TCCR(i), reg);
+	}
+
+	return 0;
+}
+
+/**
+ * ixgbe_dcb_config_tx_data_arbiter_82598 - Config Tx data arbiter
+ * @hw: pointer to hardware structure
+ * @dcb_config: pointer to ixgbe_dcb_config structure
+ *
+ * Configure Tx Data Arbiter and credits for each traffic class.
+ */
+s32 ixgbe_dcb_config_tx_data_arbiter_82598(struct ixgbe_hw *hw,
+                                           struct ixgbe_dcb_config *dcb_config)
+{
+	struct tc_bw_alloc *p;
+	u32 reg;
+	u8 i;
+
+	reg = IXGBE_READ_REG(hw, IXGBE_PDPMCS);
+	/* Enable Data Plane Arbiter */
+	reg &= ~IXGBE_PDPMCS_ARBDIS;
+	/* Enable DFP and Transmit Recycle Mode */
+	reg |= (IXGBE_PDPMCS_TPPAC | IXGBE_PDPMCS_TRM);
+
+	IXGBE_WRITE_REG(hw, IXGBE_PDPMCS, reg);
+
+	/* Configure traffic class credits and priority */
+	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
+		p = &dcb_config->tc_config[i].path[DCB_TX_CONFIG];
+		reg = p->data_credits_refill;
+		reg |= (u32)(p->data_credits_max) << IXGBE_TDPT2TCCR_MCL_SHIFT;
+		reg |= (u32)(p->bwg_id) << IXGBE_TDPT2TCCR_BWG_SHIFT;
+
+		if (p->prio_type == prio_group)
+			reg |= IXGBE_TDPT2TCCR_GSP;
+
+		if (p->prio_type == prio_link)
+			reg |= IXGBE_TDPT2TCCR_LSP;
+
+		IXGBE_WRITE_REG(hw, IXGBE_TDPT2TCCR(i), reg);
+	}
+
+	/* Enable Tx packet buffer division */
+	reg = IXGBE_READ_REG(hw, IXGBE_DTXCTL);
+	reg |= IXGBE_DTXCTL_ENDBUBD;
+	IXGBE_WRITE_REG(hw, IXGBE_DTXCTL, reg);
+
+	return 0;
+}
+
+/**
+ * ixgbe_dcb_config_pfc_82598 - Config priority flow control
+ * @hw: pointer to hardware structure
+ * @dcb_config: pointer to ixgbe_dcb_config structure
+ *
+ * Configure Priority Flow Control for each traffic class.
+ */
+s32 ixgbe_dcb_config_pfc_82598(struct ixgbe_hw *hw,
+                               struct ixgbe_dcb_config *dcb_config)
+{
+	u32 reg, rx_pba_size;
+	u8  i;
+
+	/* Enable Transmit Priority Flow Control */
+	reg = IXGBE_READ_REG(hw, IXGBE_RMCS);
+	reg &= ~IXGBE_RMCS_TFCE_802_3X;
+	/* correct the reporting of our flow control status */
+	hw->fc.type = ixgbe_fc_none;
+	reg |= IXGBE_RMCS_TFCE_PRIORITY;
+	IXGBE_WRITE_REG(hw, IXGBE_RMCS, reg);
+
+	/* Enable Receive Priority Flow Control */
+	reg = IXGBE_READ_REG(hw, IXGBE_FCTRL);
+	reg &= ~IXGBE_FCTRL_RFCE;
+	reg |= IXGBE_FCTRL_RPFCE;
+	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, reg);
+
+	/*
+	 * Configure flow control thresholds and enable priority flow control
+	 * for each traffic class.
+	 */
+	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
+		if (dcb_config->rx_pba_cfg == pba_equal) {
+			rx_pba_size = IXGBE_RXPBSIZE_64KB;
+		} else {
+			rx_pba_size = (i < 4) ? IXGBE_RXPBSIZE_80KB
+			                      : IXGBE_RXPBSIZE_48KB;
+		}
+
+		reg = ((rx_pba_size >> 5) &  0xFFF0);
+		if (dcb_config->tc_config[i].dcb_pfc == pfc_enabled_tx ||
+		    dcb_config->tc_config[i].dcb_pfc == pfc_enabled_full)
+			reg |= IXGBE_FCRTL_XONE;
+
+		IXGBE_WRITE_REG(hw, IXGBE_FCRTL(i), reg);
+
+		reg = ((rx_pba_size >> 2) & 0xFFF0);
+		if (dcb_config->tc_config[i].dcb_pfc == pfc_enabled_tx ||
+		    dcb_config->tc_config[i].dcb_pfc == pfc_enabled_full)
+			reg |= IXGBE_FCRTH_FCEN;
+
+		IXGBE_WRITE_REG(hw, IXGBE_FCRTH(i), reg);
+	}
+
+	/* Configure pause time */
+	for (i = 0; i < (MAX_TRAFFIC_CLASS >> 1); i++)
+		IXGBE_WRITE_REG(hw, IXGBE_FCTTV(i), 0x68006800);
+
+	/* Configure flow control refresh threshold value */
+	IXGBE_WRITE_REG(hw, IXGBE_FCRTV, 0x3400);
+
+	return 0;
+}
+
+/**
+ * ixgbe_dcb_config_tc_stats_82598 - Configure traffic class statistics
+ * @hw: pointer to hardware structure
+ *
+ * Configure queue statistics registers, all queues belonging to same traffic
+ * class uses a single set of queue statistics counters.
+ */
+s32 ixgbe_dcb_config_tc_stats_82598(struct ixgbe_hw *hw)
+{
+	u32 reg = 0;
+	u8  i   = 0;
+	u8  j   = 0;
+
+	/* Receive Queues stats setting -  8 queues per statistics reg */
+	for (i = 0, j = 0; i < 15 && j < 8; i = i + 2, j++) {
+		reg = IXGBE_READ_REG(hw, IXGBE_RQSMR(i));
+		reg |= ((0x1010101) * j);
+		IXGBE_WRITE_REG(hw, IXGBE_RQSMR(i), reg);
+		reg = IXGBE_READ_REG(hw, IXGBE_RQSMR(i + 1));
+		reg |= ((0x1010101) * j);
+		IXGBE_WRITE_REG(hw, IXGBE_RQSMR(i + 1), reg);
+	}
+	/* Transmit Queues stats setting -  4 queues per statistics reg */
+	for (i = 0; i < 8; i++) {
+		reg = IXGBE_READ_REG(hw, IXGBE_TQSMR(i));
+		reg |= ((0x1010101) * i);
+		IXGBE_WRITE_REG(hw, IXGBE_TQSMR(i), reg);
+	}
+
+	return 0;
+}
+
+/**
+ * ixgbe_dcb_hw_config_82598 - Config and enable DCB
+ * @hw: pointer to hardware structure
+ * @dcb_config: pointer to ixgbe_dcb_config structure
+ *
+ * Configure dcb settings and enable dcb mode.
+ */
+s32 ixgbe_dcb_hw_config_82598(struct ixgbe_hw *hw,
+                              struct ixgbe_dcb_config *dcb_config)
+{
+	ixgbe_dcb_config_packet_buffers_82598(hw, dcb_config);
+	ixgbe_dcb_config_rx_arbiter_82598(hw, dcb_config);
+	ixgbe_dcb_config_tx_desc_arbiter_82598(hw, dcb_config);
+	ixgbe_dcb_config_tx_data_arbiter_82598(hw, dcb_config);
+	ixgbe_dcb_config_pfc_82598(hw, dcb_config);
+	ixgbe_dcb_config_tc_stats_82598(hw);
+
+	return 0;
+}
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.h b/drivers/net/ixgbe/ixgbe_dcb_82598.h
new file mode 100644
index 0000000..d550944
--- /dev/null
+++ b/drivers/net/ixgbe/ixgbe_dcb_82598.h
@@ -0,0 +1,98 @@
+/*******************************************************************************
+
+  Intel 10 Gigabit PCI Express Linux driver
+  Copyright(c) 1999 - 2007 Intel Corporation.
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
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#ifndef _DCB_82598_CONFIG_H_
+#define _DCB_82598_CONFIG_H_
+
+/* DCB register definitions */
+
+#define IXGBE_DPMCS_MTSOS_SHIFT 16
+#define IXGBE_DPMCS_TDPAC       0x00000001 /* 0 Round Robin, 1 DFP - Deficit Fixed Priority */
+#define IXGBE_DPMCS_TRM         0x00000010 /* Transmit Recycle Mode */
+#define IXGBE_DPMCS_ARBDIS      0x00000040 /* DCB arbiter disable */
+#define IXGBE_DPMCS_TSOEF       0x00080000 /* TSO Expand Factor: 0=x4, 1=x2 */
+
+#define IXGBE_RUPPBMR_MQA       0x80000000 /* Enable UP to queue mapping */
+
+#define IXGBE_RT2CR_MCL_SHIFT   12 /* Offset to Max Credit Limit setting */
+#define IXGBE_RT2CR_LSP         0x80000000 /* LSP enable bit */
+
+#define IXGBE_RDRXCTL_MPBEN     0x00000010 /* DMA config for multiple packet buffers enable */
+#define IXGBE_RDRXCTL_MCEN      0x00000040 /* DMA config for multiple cores (RSS) enable */
+
+#define IXGBE_TDTQ2TCCR_MCL_SHIFT   12
+#define IXGBE_TDTQ2TCCR_BWG_SHIFT   9
+#define IXGBE_TDTQ2TCCR_GSP     0x40000000
+#define IXGBE_TDTQ2TCCR_LSP     0x80000000
+
+#define IXGBE_TDPT2TCCR_MCL_SHIFT   12
+#define IXGBE_TDPT2TCCR_BWG_SHIFT   9
+#define IXGBE_TDPT2TCCR_GSP     0x40000000
+#define IXGBE_TDPT2TCCR_LSP     0x80000000
+
+#define IXGBE_PDPMCS_TPPAC      0x00000020 /* 0 Round Robin, 1 for DFP - Deficit Fixed Priority */
+#define IXGBE_PDPMCS_ARBDIS     0x00000040 /* Arbiter disable */
+#define IXGBE_PDPMCS_TRM        0x00000100 /* Transmit Recycle Mode enable */
+
+#define IXGBE_DTXCTL_ENDBUBD    0x00000004 /* Enable DBU buffer division */
+
+#define IXGBE_TXPBSIZE_40KB     0x0000A000 /* 40KB Packet Buffer */
+#define IXGBE_RXPBSIZE_48KB     0x0000C000 /* 48KB Packet Buffer */
+#define IXGBE_RXPBSIZE_64KB     0x00010000 /* 64KB Packet Buffer */
+#define IXGBE_RXPBSIZE_80KB     0x00014000 /* 80KB Packet Buffer */
+
+#define IXGBE_RDRXCTL_RDMTS_1_2 0x00000000
+
+/* DCB hardware-specific driver APIs */
+
+/* DCB PFC functions */
+s32 ixgbe_dcb_config_pfc_82598(struct ixgbe_hw *hw,
+                               struct ixgbe_dcb_config *dcb_config);
+s32 ixgbe_dcb_get_pfc_stats_82598(struct ixgbe_hw *hw,
+                                  struct ixgbe_hw_stats *stats,
+                                  u8 tc_count);
+
+/* DCB traffic class stats */
+s32 ixgbe_dcb_config_tc_stats_82598(struct ixgbe_hw *hw);
+s32 ixgbe_dcb_get_tc_stats_82598(struct ixgbe_hw *hw,
+                                 struct ixgbe_hw_stats *stats,
+                                 u8 tc_count);
+
+/* DCB config arbiters */
+s32 ixgbe_dcb_config_tx_desc_arbiter_82598(struct ixgbe_hw *hw,
+                                           struct ixgbe_dcb_config *dcb_config);
+s32 ixgbe_dcb_config_tx_data_arbiter_82598(struct ixgbe_hw *hw,
+                                           struct ixgbe_dcb_config *dcb_config);
+s32 ixgbe_dcb_config_rx_arbiter_82598(struct ixgbe_hw *hw,
+                                      struct ixgbe_dcb_config *dcb_config);
+
+/* DCB hw initialization */
+s32 ixgbe_dcb_hw_config_82598(struct ixgbe_hw *hw,
+                              struct ixgbe_dcb_config *config);
+
+#endif /* _DCB_82598_CONFIG_H */

