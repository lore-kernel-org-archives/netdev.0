From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 08/16] ixgbe: DCB, abstract out dcb_config from DCB hardware configuration
Date: Tue,  8 Feb 2011 04:29:19 -0800
Message-ID: <1297168167-15755-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1297168167-15755-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:30096 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753887Ab1BHM3h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Feb 2011 07:29:37 -0500
In-Reply-To: <1297168167-15755-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Currently the routines that configure the HW for DCB require a
ixgbe_dcb_config structure. This structure was designed to support
the CEE standard and does not match the IEEE standard well.

This patch changes the HW routines in ixgbe_dcb_8259x.{ch} to use
raw pfc and bandwidth values. This requires some parsing of the DCB
configuration but makes the HW routines independent of the data
structure that contains the DCB configuration.

The primary advantage to doing this is we can do HW setup directly
from the 802.1Qaz ops without having to arbitrarily encapsulate this
data into the CEE structure.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_dcb.c       |   74 ++++++++++++++++++++++-
 drivers/net/ixgbe/ixgbe_dcb.h       |    1 +
 drivers/net/ixgbe/ixgbe_dcb_82598.c |   86 ++++++++++++++------------
 drivers/net/ixgbe/ixgbe_dcb_82598.h |   23 ++++++-
 drivers/net/ixgbe/ixgbe_dcb_82599.c |  115 ++++++++++++++++++++---------------
 drivers/net/ixgbe/ixgbe_dcb_82599.h |   24 ++++++-
 drivers/net/ixgbe/ixgbe_dcb_nl.c    |    9 ++-
 7 files changed, 230 insertions(+), 102 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb.c b/drivers/net/ixgbe/ixgbe_dcb.c
index d16c260..d9bb670 100644
--- a/drivers/net/ixgbe/ixgbe_dcb.c
+++ b/drivers/net/ixgbe/ixgbe_dcb.c
@@ -141,6 +141,59 @@ out:
 	return ret_val;
 }
 
+void ixgbe_dcb_unpack_pfc(struct ixgbe_dcb_config *cfg, u8 *pfc_en)
+{
+	int i;
+
+	*pfc_en = 0;
+	for (i = 0; i < MAX_TRAFFIC_CLASS; i++)
+		*pfc_en |= (cfg->tc_config[i].dcb_pfc & 0xF) << i;
+}
+
+void ixgbe_dcb_unpack_refill(struct ixgbe_dcb_config *cfg, int direction,
+			     u16 *refill)
+{
+	struct tc_bw_alloc *p;
+	int i;
+
+	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
+		p = &cfg->tc_config[i].path[direction];
+		refill[i] = p->data_credits_refill;
+	}
+}
+
+void ixgbe_dcb_unpack_max(struct ixgbe_dcb_config *cfg, u16 *max)
+{
+	int i;
+
+	for (i = 0; i < MAX_TRAFFIC_CLASS; i++)
+		max[i] = cfg->tc_config[i].desc_credits_max;
+}
+
+void ixgbe_dcb_unpack_bwgid(struct ixgbe_dcb_config *cfg, int direction,
+			    u8 *bwgid)
+{
+	struct tc_bw_alloc *p;
+	int i;
+
+	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
+		p = &cfg->tc_config[i].path[direction];
+		bwgid[i] = p->bwg_id;
+	}
+}
+
+void ixgbe_dcb_unpack_prio(struct ixgbe_dcb_config *cfg, int direction,
+			    u8 *ptype)
+{
+	struct tc_bw_alloc *p;
+	int i;
+
+	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
+		p = &cfg->tc_config[i].path[direction];
+		ptype[i] = p->prio_type;
+	}
+}
+
 /**
  * ixgbe_dcb_hw_config - Config and enable DCB
  * @hw: pointer to hardware structure
@@ -152,13 +205,30 @@ s32 ixgbe_dcb_hw_config(struct ixgbe_hw *hw,
                         struct ixgbe_dcb_config *dcb_config)
 {
 	s32 ret = 0;
+	u8 pfc_en;
+	u8 ptype[MAX_TRAFFIC_CLASS];
+	u8 bwgid[MAX_TRAFFIC_CLASS];
+	u16 refill[MAX_TRAFFIC_CLASS];
+	u16 max[MAX_TRAFFIC_CLASS];
+
+	/* Unpack CEE standard containers */
+	ixgbe_dcb_unpack_pfc(dcb_config, &pfc_en);
+	ixgbe_dcb_unpack_refill(dcb_config, DCB_TX_CONFIG, refill);
+	ixgbe_dcb_unpack_max(dcb_config, max);
+	ixgbe_dcb_unpack_bwgid(dcb_config, DCB_TX_CONFIG, bwgid);
+	ixgbe_dcb_unpack_prio(dcb_config, DCB_TX_CONFIG, ptype);
+
 	switch (hw->mac.type) {
 	case ixgbe_mac_82598EB:
-		ret = ixgbe_dcb_hw_config_82598(hw, dcb_config);
+		ret = ixgbe_dcb_hw_config_82598(hw, dcb_config->rx_pba_cfg,
+						pfc_en, refill, max, bwgid,
+						ptype);
 		break;
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
-		ret = ixgbe_dcb_hw_config_82599(hw, dcb_config);
+		ret = ixgbe_dcb_hw_config_82599(hw, dcb_config->rx_pba_cfg,
+						pfc_en, refill, max, bwgid,
+						ptype);
 		break;
 	default:
 		break;
diff --git a/drivers/net/ixgbe/ixgbe_dcb.h b/drivers/net/ixgbe/ixgbe_dcb.h
index d0b2450..aa6cb5f 100644
--- a/drivers/net/ixgbe/ixgbe_dcb.h
+++ b/drivers/net/ixgbe/ixgbe_dcb.h
@@ -147,6 +147,7 @@ struct ixgbe_dcb_config {
 };
 
 /* DCB driver APIs */
+void ixgbe_dcb_unpack_pfc(struct ixgbe_dcb_config *cfg, u8 *pfc_en);
 
 /* DCB credits calculation */
 s32 ixgbe_dcb_calculate_tc_credits(struct ixgbe_hw *,
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.c b/drivers/net/ixgbe/ixgbe_dcb_82598.c
index 19aa806..d128806 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82598.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82598.c
@@ -38,15 +38,14 @@
  *
  * Configure packet buffers for DCB mode.
  */
-static s32 ixgbe_dcb_config_packet_buffers_82598(struct ixgbe_hw *hw,
-						 struct ixgbe_dcb_config *dcb_config)
+static s32 ixgbe_dcb_config_packet_buffers_82598(struct ixgbe_hw *hw, u8 rx_pba)
 {
 	s32 ret_val = 0;
 	u32 value = IXGBE_RXPBSIZE_64KB;
 	u8  i = 0;
 
 	/* Setup Rx packet buffer sizes */
-	switch (dcb_config->rx_pba_cfg) {
+	switch (rx_pba) {
 	case pba_80_48:
 		/* Setup the first four at 80KB */
 		value = IXGBE_RXPBSIZE_80KB;
@@ -78,10 +77,11 @@ static s32 ixgbe_dcb_config_packet_buffers_82598(struct ixgbe_hw *hw,
  *
  * Configure Rx Data Arbiter and credits for each traffic class.
  */
-static s32 ixgbe_dcb_config_rx_arbiter_82598(struct ixgbe_hw *hw,
-                                      struct ixgbe_dcb_config *dcb_config)
+s32 ixgbe_dcb_config_rx_arbiter_82598(struct ixgbe_hw *hw,
+					u16 *refill,
+					u16 *max,
+					u8 *prio_type)
 {
-	struct tc_bw_alloc    *p;
 	u32    reg           = 0;
 	u32    credit_refill = 0;
 	u32    credit_max    = 0;
@@ -102,13 +102,12 @@ static s32 ixgbe_dcb_config_rx_arbiter_82598(struct ixgbe_hw *hw,
 
 	/* Configure traffic class credits and priority */
 	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
-		p = &dcb_config->tc_config[i].path[DCB_RX_CONFIG];
-		credit_refill = p->data_credits_refill;
-		credit_max    = p->data_credits_max;
+		credit_refill = refill[i];
+		credit_max    = max[i];
 
 		reg = credit_refill | (credit_max << IXGBE_RT2CR_MCL_SHIFT);
 
-		if (p->prio_type == prio_link)
+		if (prio_type[i] == prio_link)
 			reg |= IXGBE_RT2CR_LSP;
 
 		IXGBE_WRITE_REG(hw, IXGBE_RT2CR(i), reg);
@@ -135,10 +134,12 @@ static s32 ixgbe_dcb_config_rx_arbiter_82598(struct ixgbe_hw *hw,
  *
  * Configure Tx Descriptor Arbiter and credits for each traffic class.
  */
-static s32 ixgbe_dcb_config_tx_desc_arbiter_82598(struct ixgbe_hw *hw,
-                                           struct ixgbe_dcb_config *dcb_config)
+s32 ixgbe_dcb_config_tx_desc_arbiter_82598(struct ixgbe_hw *hw,
+						u16 *refill,
+						u16 *max,
+						u8 *bwg_id,
+						u8 *prio_type)
 {
-	struct tc_bw_alloc *p;
 	u32    reg, max_credits;
 	u8     i;
 
@@ -156,16 +157,15 @@ static s32 ixgbe_dcb_config_tx_desc_arbiter_82598(struct ixgbe_hw *hw,
 
 	/* Configure traffic class credits and priority */
 	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
-		p = &dcb_config->tc_config[i].path[DCB_TX_CONFIG];
-		max_credits = dcb_config->tc_config[i].desc_credits_max;
+		max_credits = max[i];
 		reg = max_credits << IXGBE_TDTQ2TCCR_MCL_SHIFT;
-		reg |= p->data_credits_refill;
-		reg |= (u32)(p->bwg_id) << IXGBE_TDTQ2TCCR_BWG_SHIFT;
+		reg |= refill[i];
+		reg |= (u32)(bwg_id[i]) << IXGBE_TDTQ2TCCR_BWG_SHIFT;
 
-		if (p->prio_type == prio_group)
+		if (prio_type[i] == prio_group)
 			reg |= IXGBE_TDTQ2TCCR_GSP;
 
-		if (p->prio_type == prio_link)
+		if (prio_type[i] == prio_link)
 			reg |= IXGBE_TDTQ2TCCR_LSP;
 
 		IXGBE_WRITE_REG(hw, IXGBE_TDTQ2TCCR(i), reg);
@@ -181,10 +181,12 @@ static s32 ixgbe_dcb_config_tx_desc_arbiter_82598(struct ixgbe_hw *hw,
  *
  * Configure Tx Data Arbiter and credits for each traffic class.
  */
-static s32 ixgbe_dcb_config_tx_data_arbiter_82598(struct ixgbe_hw *hw,
-                                           struct ixgbe_dcb_config *dcb_config)
+s32 ixgbe_dcb_config_tx_data_arbiter_82598(struct ixgbe_hw *hw,
+						u16 *refill,
+						u16 *max,
+						u8 *bwg_id,
+						u8 *prio_type)
 {
-	struct tc_bw_alloc *p;
 	u32 reg;
 	u8 i;
 
@@ -198,15 +200,14 @@ static s32 ixgbe_dcb_config_tx_data_arbiter_82598(struct ixgbe_hw *hw,
 
 	/* Configure traffic class credits and priority */
 	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
-		p = &dcb_config->tc_config[i].path[DCB_TX_CONFIG];
-		reg = p->data_credits_refill;
-		reg |= (u32)(p->data_credits_max) << IXGBE_TDPT2TCCR_MCL_SHIFT;
-		reg |= (u32)(p->bwg_id) << IXGBE_TDPT2TCCR_BWG_SHIFT;
+		reg = refill[i];
+		reg |= (u32)(max[i]) << IXGBE_TDPT2TCCR_MCL_SHIFT;
+		reg |= (u32)(bwg_id[i]) << IXGBE_TDPT2TCCR_BWG_SHIFT;
 
-		if (p->prio_type == prio_group)
+		if (prio_type[i] == prio_group)
 			reg |= IXGBE_TDPT2TCCR_GSP;
 
-		if (p->prio_type == prio_link)
+		if (prio_type[i] == prio_link)
 			reg |= IXGBE_TDPT2TCCR_LSP;
 
 		IXGBE_WRITE_REG(hw, IXGBE_TDPT2TCCR(i), reg);
@@ -227,13 +228,12 @@ static s32 ixgbe_dcb_config_tx_data_arbiter_82598(struct ixgbe_hw *hw,
  *
  * Configure Priority Flow Control for each traffic class.
  */
-s32 ixgbe_dcb_config_pfc_82598(struct ixgbe_hw *hw,
-                               struct ixgbe_dcb_config *dcb_config)
+s32 ixgbe_dcb_config_pfc_82598(struct ixgbe_hw *hw, u8 pfc_en)
 {
 	u32 reg, rx_pba_size;
 	u8  i;
 
-	if (!dcb_config->pfc_mode_enable)
+	if (!pfc_en)
 		goto out;
 
 	/* Enable Transmit Priority Flow Control */
@@ -254,19 +254,20 @@ s32 ixgbe_dcb_config_pfc_82598(struct ixgbe_hw *hw,
 	 * for each traffic class.
 	 */
 	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
+		int enabled = pfc_en & (1 << i);
 		rx_pba_size = IXGBE_READ_REG(hw, IXGBE_RXPBSIZE(i));
 		rx_pba_size >>= IXGBE_RXPBSIZE_SHIFT;
 		reg = (rx_pba_size - hw->fc.low_water) << 10;
 
-		if (dcb_config->tc_config[i].dcb_pfc == pfc_enabled_tx ||
-		    dcb_config->tc_config[i].dcb_pfc == pfc_enabled_full)
+		if (enabled == pfc_enabled_tx ||
+		    enabled == pfc_enabled_full)
 			reg |= IXGBE_FCRTL_XONE;
 
 		IXGBE_WRITE_REG(hw, IXGBE_FCRTL(i), reg);
 
 		reg = (rx_pba_size - hw->fc.high_water) << 10;
-		if (dcb_config->tc_config[i].dcb_pfc == pfc_enabled_tx ||
-		    dcb_config->tc_config[i].dcb_pfc == pfc_enabled_full)
+		if (enabled == pfc_enabled_tx ||
+		    enabled == pfc_enabled_full)
 			reg |= IXGBE_FCRTH_FCEN;
 
 		IXGBE_WRITE_REG(hw, IXGBE_FCRTH(i), reg);
@@ -323,13 +324,16 @@ static s32 ixgbe_dcb_config_tc_stats_82598(struct ixgbe_hw *hw)
  * Configure dcb settings and enable dcb mode.
  */
 s32 ixgbe_dcb_hw_config_82598(struct ixgbe_hw *hw,
-                              struct ixgbe_dcb_config *dcb_config)
+			      u8 rx_pba, u8 pfc_en, u16 *refill,
+			      u16 *max, u8 *bwg_id, u8 *prio_type)
 {
-	ixgbe_dcb_config_packet_buffers_82598(hw, dcb_config);
-	ixgbe_dcb_config_rx_arbiter_82598(hw, dcb_config);
-	ixgbe_dcb_config_tx_desc_arbiter_82598(hw, dcb_config);
-	ixgbe_dcb_config_tx_data_arbiter_82598(hw, dcb_config);
-	ixgbe_dcb_config_pfc_82598(hw, dcb_config);
+	ixgbe_dcb_config_packet_buffers_82598(hw, rx_pba);
+	ixgbe_dcb_config_rx_arbiter_82598(hw, refill, max, prio_type);
+	ixgbe_dcb_config_tx_desc_arbiter_82598(hw, refill, max,
+					       bwg_id, prio_type);
+	ixgbe_dcb_config_tx_data_arbiter_82598(hw, refill, max,
+					       bwg_id, prio_type);
+	ixgbe_dcb_config_pfc_82598(hw, pfc_en);
 	ixgbe_dcb_config_tc_stats_82598(hw);
 
 	return 0;
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.h b/drivers/net/ixgbe/ixgbe_dcb_82598.h
index abc03cc..0d2a758 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82598.h
+++ b/drivers/net/ixgbe/ixgbe_dcb_82598.h
@@ -71,9 +71,28 @@
 /* DCB hardware-specific driver APIs */
 
 /* DCB PFC functions */
-s32 ixgbe_dcb_config_pfc_82598(struct ixgbe_hw *, struct ixgbe_dcb_config *);
+s32 ixgbe_dcb_config_pfc_82598(struct ixgbe_hw *, u8 pfc_en);
 
 /* DCB hw initialization */
-s32 ixgbe_dcb_hw_config_82598(struct ixgbe_hw *, struct ixgbe_dcb_config *);
+s32 ixgbe_dcb_config_rx_arbiter_82598(struct ixgbe_hw *hw,
+					u16 *refill,
+					u16 *max,
+					u8 *prio_type);
+
+s32 ixgbe_dcb_config_tx_desc_arbiter_82598(struct ixgbe_hw *hw,
+						u16 *refill,
+						u16 *max,
+						u8 *bwg_id,
+						u8 *prio_type);
+
+s32 ixgbe_dcb_config_tx_data_arbiter_82598(struct ixgbe_hw *hw,
+						u16 *refill,
+						u16 *max,
+						u8 *bwg_id,
+						u8 *prio_type);
+
+s32 ixgbe_dcb_hw_config_82598(struct ixgbe_hw *hw,
+			      u8 rx_pba, u8 pfc_en, u16 *refill,
+			      u16 *max, u8 *bwg_id, u8 *prio_type);
 
 #endif /* _DCB_82598_CONFIG_H */
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ixgbe/ixgbe_dcb_82599.c
index 374e1f7..b0d97a9 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.c
@@ -33,19 +33,18 @@
 /**
  * ixgbe_dcb_config_packet_buffers_82599 - Configure DCB packet buffers
  * @hw: pointer to hardware structure
- * @dcb_config: pointer to ixgbe_dcb_config structure
+ * @rx_pba: method to distribute packet buffer
  *
  * Configure packet buffers for DCB mode.
  */
-static s32 ixgbe_dcb_config_packet_buffers_82599(struct ixgbe_hw *hw,
-                                          struct ixgbe_dcb_config *dcb_config)
+static s32 ixgbe_dcb_config_packet_buffers_82599(struct ixgbe_hw *hw, u8 rx_pba)
 {
 	s32 ret_val = 0;
 	u32 value = IXGBE_RXPBSIZE_64KB;
 	u8  i = 0;
 
 	/* Setup Rx packet buffer sizes */
-	switch (dcb_config->rx_pba_cfg) {
+	switch (rx_pba) {
 	case pba_80_48:
 		/* Setup the first four at 80KB */
 		value = IXGBE_RXPBSIZE_80KB;
@@ -75,14 +74,19 @@ static s32 ixgbe_dcb_config_packet_buffers_82599(struct ixgbe_hw *hw,
 /**
  * ixgbe_dcb_config_rx_arbiter_82599 - Config Rx Data arbiter
  * @hw: pointer to hardware structure
- * @dcb_config: pointer to ixgbe_dcb_config structure
+ * @refill: refill credits index by traffic class
+ * @max: max credits index by traffic class
+ * @bwg_id: bandwidth grouping indexed by traffic class
+ * @prio_type: priority type indexed by traffic class
  *
  * Configure Rx Packet Arbiter and credits for each traffic class.
  */
-static s32 ixgbe_dcb_config_rx_arbiter_82599(struct ixgbe_hw *hw,
-                                      struct ixgbe_dcb_config *dcb_config)
+s32 ixgbe_dcb_config_rx_arbiter_82599(struct ixgbe_hw *hw,
+				      u16 *refill,
+				      u16 *max,
+				      u8 *bwg_id,
+				      u8 *prio_type)
 {
-	struct tc_bw_alloc    *p;
 	u32    reg           = 0;
 	u32    credit_refill = 0;
 	u32    credit_max    = 0;
@@ -103,15 +107,13 @@ static s32 ixgbe_dcb_config_rx_arbiter_82599(struct ixgbe_hw *hw,
 
 	/* Configure traffic class credits and priority */
 	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
-		p = &dcb_config->tc_config[i].path[DCB_RX_CONFIG];
-
-		credit_refill = p->data_credits_refill;
-		credit_max    = p->data_credits_max;
+		credit_refill = refill[i];
+		credit_max    = max[i];
 		reg = credit_refill | (credit_max << IXGBE_RTRPT4C_MCL_SHIFT);
 
-		reg |= (u32)(p->bwg_id) << IXGBE_RTRPT4C_BWG_SHIFT;
+		reg |= (u32)(bwg_id[i]) << IXGBE_RTRPT4C_BWG_SHIFT;
 
-		if (p->prio_type == prio_link)
+		if (prio_type[i] == prio_link)
 			reg |= IXGBE_RTRPT4C_LSP;
 
 		IXGBE_WRITE_REG(hw, IXGBE_RTRPT4C(i), reg);
@@ -130,14 +132,19 @@ static s32 ixgbe_dcb_config_rx_arbiter_82599(struct ixgbe_hw *hw,
 /**
  * ixgbe_dcb_config_tx_desc_arbiter_82599 - Config Tx Desc. arbiter
  * @hw: pointer to hardware structure
- * @dcb_config: pointer to ixgbe_dcb_config structure
+ * @refill: refill credits index by traffic class
+ * @max: max credits index by traffic class
+ * @bwg_id: bandwidth grouping indexed by traffic class
+ * @prio_type: priority type indexed by traffic class
  *
  * Configure Tx Descriptor Arbiter and credits for each traffic class.
  */
-static s32 ixgbe_dcb_config_tx_desc_arbiter_82599(struct ixgbe_hw *hw,
-                                           struct ixgbe_dcb_config *dcb_config)
+s32 ixgbe_dcb_config_tx_desc_arbiter_82599(struct ixgbe_hw *hw,
+					   u16 *refill,
+					   u16 *max,
+					   u8 *bwg_id,
+					   u8 *prio_type)
 {
-	struct tc_bw_alloc *p;
 	u32    reg, max_credits;
 	u8     i;
 
@@ -149,16 +156,15 @@ static s32 ixgbe_dcb_config_tx_desc_arbiter_82599(struct ixgbe_hw *hw,
 
 	/* Configure traffic class credits and priority */
 	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
-		p = &dcb_config->tc_config[i].path[DCB_TX_CONFIG];
-		max_credits = dcb_config->tc_config[i].desc_credits_max;
+		max_credits = max[i];
 		reg = max_credits << IXGBE_RTTDT2C_MCL_SHIFT;
-		reg |= p->data_credits_refill;
-		reg |= (u32)(p->bwg_id) << IXGBE_RTTDT2C_BWG_SHIFT;
+		reg |= refill[i];
+		reg |= (u32)(bwg_id[i]) << IXGBE_RTTDT2C_BWG_SHIFT;
 
-		if (p->prio_type == prio_group)
+		if (prio_type[i] == prio_group)
 			reg |= IXGBE_RTTDT2C_GSP;
 
-		if (p->prio_type == prio_link)
+		if (prio_type[i] == prio_link)
 			reg |= IXGBE_RTTDT2C_LSP;
 
 		IXGBE_WRITE_REG(hw, IXGBE_RTTDT2C(i), reg);
@@ -177,14 +183,19 @@ static s32 ixgbe_dcb_config_tx_desc_arbiter_82599(struct ixgbe_hw *hw,
 /**
  * ixgbe_dcb_config_tx_data_arbiter_82599 - Config Tx Data arbiter
  * @hw: pointer to hardware structure
- * @dcb_config: pointer to ixgbe_dcb_config structure
+ * @refill: refill credits index by traffic class
+ * @max: max credits index by traffic class
+ * @bwg_id: bandwidth grouping indexed by traffic class
+ * @prio_type: priority type indexed by traffic class
  *
  * Configure Tx Packet Arbiter and credits for each traffic class.
  */
-static s32 ixgbe_dcb_config_tx_data_arbiter_82599(struct ixgbe_hw *hw,
-                                           struct ixgbe_dcb_config *dcb_config)
+s32 ixgbe_dcb_config_tx_data_arbiter_82599(struct ixgbe_hw *hw,
+					   u16 *refill,
+					   u16 *max,
+					   u8 *bwg_id,
+					   u8 *prio_type)
 {
-	struct tc_bw_alloc *p;
 	u32 reg;
 	u8 i;
 
@@ -205,15 +216,14 @@ static s32 ixgbe_dcb_config_tx_data_arbiter_82599(struct ixgbe_hw *hw,
 
 	/* Configure traffic class credits and priority */
 	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
-		p = &dcb_config->tc_config[i].path[DCB_TX_CONFIG];
-		reg = p->data_credits_refill;
-		reg |= (u32)(p->data_credits_max) << IXGBE_RTTPT2C_MCL_SHIFT;
-		reg |= (u32)(p->bwg_id) << IXGBE_RTTPT2C_BWG_SHIFT;
+		reg = refill[i];
+		reg |= (u32)(max[i]) << IXGBE_RTTPT2C_MCL_SHIFT;
+		reg |= (u32)(bwg_id[i]) << IXGBE_RTTPT2C_BWG_SHIFT;
 
-		if (p->prio_type == prio_group)
+		if (prio_type[i] == prio_group)
 			reg |= IXGBE_RTTPT2C_GSP;
 
-		if (p->prio_type == prio_link)
+		if (prio_type[i] == prio_link)
 			reg |= IXGBE_RTTPT2C_LSP;
 
 		IXGBE_WRITE_REG(hw, IXGBE_RTTPT2C(i), reg);
@@ -233,17 +243,16 @@ static s32 ixgbe_dcb_config_tx_data_arbiter_82599(struct ixgbe_hw *hw,
 /**
  * ixgbe_dcb_config_pfc_82599 - Configure priority flow control
  * @hw: pointer to hardware structure
- * @dcb_config: pointer to ixgbe_dcb_config structure
+ * @pfc_en: enabled pfc bitmask
  *
  * Configure Priority Flow Control (PFC) for each traffic class.
  */
-s32 ixgbe_dcb_config_pfc_82599(struct ixgbe_hw *hw,
-                               struct ixgbe_dcb_config *dcb_config)
+s32 ixgbe_dcb_config_pfc_82599(struct ixgbe_hw *hw, u8 pfc_en)
 {
 	u32 i, reg, rx_pba_size;
 
 	/* If PFC is disabled globally then fall back to LFC. */
-	if (!dcb_config->pfc_mode_enable) {
+	if (!pfc_en) {
 		for (i = 0; i < MAX_TRAFFIC_CLASS; i++)
 			hw->mac.ops.fc_enable(hw, i);
 		goto out;
@@ -251,19 +260,18 @@ s32 ixgbe_dcb_config_pfc_82599(struct ixgbe_hw *hw,
 
 	/* Configure PFC Tx thresholds per TC */
 	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
+		int enabled = pfc_en & (1 << i);
 		rx_pba_size = IXGBE_READ_REG(hw, IXGBE_RXPBSIZE(i));
 		rx_pba_size >>= IXGBE_RXPBSIZE_SHIFT;
 
 		reg = (rx_pba_size - hw->fc.low_water) << 10;
 
-		if (dcb_config->tc_config[i].dcb_pfc == pfc_enabled_full ||
-		    dcb_config->tc_config[i].dcb_pfc == pfc_enabled_tx)
+		if (enabled)
 			reg |= IXGBE_FCRTL_XONE;
 		IXGBE_WRITE_REG(hw, IXGBE_FCRTL_82599(i), reg);
 
 		reg = (rx_pba_size - hw->fc.high_water) << 10;
-		if (dcb_config->tc_config[i].dcb_pfc == pfc_enabled_full ||
-		    dcb_config->tc_config[i].dcb_pfc == pfc_enabled_tx)
+		if (enabled)
 			reg |= IXGBE_FCRTH_FCEN;
 		IXGBE_WRITE_REG(hw, IXGBE_FCRTH_82599(i), reg);
 	}
@@ -349,7 +357,6 @@ static s32 ixgbe_dcb_config_tc_stats_82599(struct ixgbe_hw *hw)
 /**
  * ixgbe_dcb_config_82599 - Configure general DCB parameters
  * @hw: pointer to hardware structure
- * @dcb_config: pointer to ixgbe_dcb_config structure
  *
  * Configure general DCB parameters.
  */
@@ -406,19 +413,27 @@ static s32 ixgbe_dcb_config_82599(struct ixgbe_hw *hw)
 /**
  * ixgbe_dcb_hw_config_82599 - Configure and enable DCB
  * @hw: pointer to hardware structure
- * @dcb_config: pointer to ixgbe_dcb_config structure
+ * @rx_pba: method to distribute packet buffer
+ * @refill: refill credits index by traffic class
+ * @max: max credits index by traffic class
+ * @bwg_id: bandwidth grouping indexed by traffic class
+ * @prio_type: priority type indexed by traffic class
+ * @pfc_en: enabled pfc bitmask
  *
  * Configure dcb settings and enable dcb mode.
  */
 s32 ixgbe_dcb_hw_config_82599(struct ixgbe_hw *hw,
-                              struct ixgbe_dcb_config *dcb_config)
+			      u8 rx_pba, u8 pfc_en, u16 *refill,
+			      u16 *max, u8 *bwg_id, u8 *prio_type)
 {
-	ixgbe_dcb_config_packet_buffers_82599(hw, dcb_config);
+	ixgbe_dcb_config_packet_buffers_82599(hw, rx_pba);
 	ixgbe_dcb_config_82599(hw);
-	ixgbe_dcb_config_rx_arbiter_82599(hw, dcb_config);
-	ixgbe_dcb_config_tx_desc_arbiter_82599(hw, dcb_config);
-	ixgbe_dcb_config_tx_data_arbiter_82599(hw, dcb_config);
-	ixgbe_dcb_config_pfc_82599(hw, dcb_config);
+	ixgbe_dcb_config_rx_arbiter_82599(hw, refill, max, bwg_id, prio_type);
+	ixgbe_dcb_config_tx_desc_arbiter_82599(hw, refill, max,
+					       bwg_id, prio_type);
+	ixgbe_dcb_config_tx_data_arbiter_82599(hw, refill, max,
+					       bwg_id, prio_type);
+	ixgbe_dcb_config_pfc_82599(hw, pfc_en);
 	ixgbe_dcb_config_tc_stats_82599(hw);
 
 	return 0;
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.h b/drivers/net/ixgbe/ixgbe_dcb_82599.h
index 3841649..5b0ca85 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82599.h
+++ b/drivers/net/ixgbe/ixgbe_dcb_82599.h
@@ -102,11 +102,29 @@
 /* DCB hardware-specific driver APIs */
 
 /* DCB PFC functions */
-s32 ixgbe_dcb_config_pfc_82599(struct ixgbe_hw *hw,
-                               struct ixgbe_dcb_config *dcb_config);
+s32 ixgbe_dcb_config_pfc_82599(struct ixgbe_hw *hw, u8 pfc_en);
 
 /* DCB hw initialization */
+s32 ixgbe_dcb_config_rx_arbiter_82599(struct ixgbe_hw *hw,
+					u16 *refill,
+					u16 *max,
+					u8 *bwg_id,
+					u8 *prio_type);
+
+s32 ixgbe_dcb_config_tx_desc_arbiter_82599(struct ixgbe_hw *hw,
+						u16 *refill,
+						u16 *max,
+						u8 *bwg_id,
+						u8 *prio_type);
+
+s32 ixgbe_dcb_config_tx_data_arbiter_82599(struct ixgbe_hw *hw,
+						u16 *refill,
+						u16 *max,
+						u8 *bwg_id,
+						u8 *prio_type);
+
 s32 ixgbe_dcb_hw_config_82599(struct ixgbe_hw *hw,
-                              struct ixgbe_dcb_config *config);
+			      u8 rx_pba, u8 pfc_en, u16 *refill,
+			      u16 *max, u8 *bwg_id, u8 *prio_type);
 
 #endif /* _DCB_82599_CONFIG_H */
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 4805835..6ab1f1a 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -422,12 +422,13 @@ static u8 ixgbe_dcbnl_set_all(struct net_device *netdev)
 		}
 		ret = DCB_HW_CHG_RST;
 	} else if (adapter->dcb_set_bitmap & BIT_PFC) {
+		u8 pfc_en;
+		ixgbe_dcb_unpack_pfc(&adapter->dcb_cfg, &pfc_en);
+
 		if (adapter->hw.mac.type == ixgbe_mac_82598EB)
-			ixgbe_dcb_config_pfc_82598(&adapter->hw,
-			                           &adapter->dcb_cfg);
+			ixgbe_dcb_config_pfc_82598(&adapter->hw, pfc_en);
 		else if (adapter->hw.mac.type == ixgbe_mac_82599EB)
-			ixgbe_dcb_config_pfc_82599(&adapter->hw,
-			                           &adapter->dcb_cfg);
+			ixgbe_dcb_config_pfc_82599(&adapter->hw, pfc_en);
 		ret = DCB_HW_CHG;
 	}
 	if (adapter->dcb_cfg.pfc_mode_enable)
-- 
1.7.4

