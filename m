From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 v2 08/15] ixgbe: DCB, implement 802.1Qaz routines
Date: Fri, 11 Feb 2011 09:20:55 -0800
Message-ID: <1297444862-32091-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1297444862-32091-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:26609 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757873Ab1BKRVW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Feb 2011 12:21:22 -0500
In-Reply-To: <1297444862-32091-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Implements 802.1Qaz support for ixgbe driver. Additionally,
this adds IEEE_8021QAZ_TSA_{} defines to dcbnl.h this is to
avoid having to use cryptic numeric codes for the TSA type.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h           |    4 ++
 drivers/net/ixgbe/ixgbe_dcb.c       |  103 +++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_dcb.h       |    4 ++
 drivers/net/ixgbe/ixgbe_dcb_82598.c |    2 +-
 drivers/net/ixgbe/ixgbe_dcb_nl.c    |   91 +++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_main.c      |    4 ++
 include/linux/dcbnl.h               |    5 ++
 7 files changed, 212 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 3b8c924..d04afde 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -334,6 +334,10 @@ struct ixgbe_adapter {
 	u16 bd_number;
 	struct work_struct reset_task;
 	struct ixgbe_q_vector *q_vector[MAX_MSIX_Q_VECTORS];
+
+	/* DCB parameters */
+	struct ieee_pfc *ixgbe_ieee_pfc;
+	struct ieee_ets *ixgbe_ieee_ets;
 	struct ixgbe_dcb_config dcb_cfg;
 	struct ixgbe_dcb_config temp_dcb_cfg;
 	u8 dcb_set_bitmap;
diff --git a/drivers/net/ixgbe/ixgbe_dcb.c b/drivers/net/ixgbe/ixgbe_dcb.c
index d9bb670..13c962e 100644
--- a/drivers/net/ixgbe/ixgbe_dcb.c
+++ b/drivers/net/ixgbe/ixgbe_dcb.c
@@ -34,6 +34,42 @@
 #include "ixgbe_dcb_82599.h"
 
 /**
+ * ixgbe_ieee_credits - This calculates the ieee traffic class
+ * credits from the configured bandwidth percentages. Credits
+ * are the smallest unit programable into the underlying
+ * hardware. The IEEE 802.1Qaz specification do not use bandwidth
+ * groups so this is much simplified from the CEE case.
+ */
+s32 ixgbe_ieee_credits(__u8 *bw, __u16 *refill, __u16 *max, int max_frame)
+{
+	int min_percent = 100;
+	int min_credit, multiplier;
+	int i;
+
+	min_credit = ((max_frame / 2) + DCB_CREDIT_QUANTUM - 1) /
+			DCB_CREDIT_QUANTUM;
+
+	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
+		if (bw[i] < min_percent && bw[i])
+			min_percent = bw[i];
+	}
+
+	multiplier = (min_credit / min_percent) + 1;
+
+	/* Find out the hw credits for each TC */
+	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
+		int val = min(bw[i] * multiplier, MAX_CREDIT_REFILL);
+
+		if (val < min_credit)
+			val = min_credit;
+		refill[i] = val;
+
+		max[i] = (bw[i] * MAX_CREDIT)/100;
+	}
+	return 0;
+}
+
+/**
  * ixgbe_dcb_calculate_tc_credits - Calculates traffic class credits
  * @ixgbe_dcb_config: Struct containing DCB settings.
  * @direction: Configuring either Tx or Rx.
@@ -236,3 +272,70 @@ s32 ixgbe_dcb_hw_config(struct ixgbe_hw *hw,
 	return ret;
 }
 
+/* Helper routines to abstract HW specifics from DCB netlink ops */
+s32 ixgbe_dcb_hw_pfc_config(struct ixgbe_hw *hw, u8 pfc_en)
+{
+	int ret = -EINVAL;
+
+	switch (hw->mac.type) {
+	case ixgbe_mac_82598EB:
+		ret = ixgbe_dcb_config_pfc_82598(hw, pfc_en);
+		break;
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
+		ret = ixgbe_dcb_config_pfc_82599(hw, pfc_en);
+		break;
+	default:
+		break;
+	}
+	return ret;
+}
+
+s32 ixgbe_dcb_hw_ets_config(struct ixgbe_hw *hw,
+			    u16 *refill, u16 *max, u8 *bwg_id, u8 *tsa)
+{
+	int i;
+	u8 prio_type[IEEE_8021QAZ_MAX_TCS];
+
+	/* Map TSA onto CEE prio type */
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		switch (tsa[i]) {
+		case IEEE_8021QAZ_TSA_STRICT:
+			prio_type[i] = 2;
+			break;
+		case IEEE_8021QAZ_TSA_ETS:
+			prio_type[i] = 0;
+			break;
+		default:
+			/* Hardware only supports priority strict or
+			 * ETS transmission selection algorithms if
+			 * we receive some other value from dcbnl
+			 * throw an error
+			 */
+			return -EINVAL;
+		}
+	}
+
+	switch (hw->mac.type) {
+	case ixgbe_mac_82598EB:
+		ixgbe_dcb_config_rx_arbiter_82598(hw, refill, max,
+							prio_type);
+		ixgbe_dcb_config_tx_desc_arbiter_82598(hw, refill, max,
+							     bwg_id, prio_type);
+		ixgbe_dcb_config_tx_data_arbiter_82598(hw, refill, max,
+							     bwg_id, prio_type);
+		break;
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
+		ixgbe_dcb_config_rx_arbiter_82599(hw, refill, max,
+						  bwg_id, prio_type);
+		ixgbe_dcb_config_tx_desc_arbiter_82599(hw, refill, max,
+						       bwg_id, prio_type);
+		ixgbe_dcb_config_tx_data_arbiter_82599(hw, refill, max,
+						       bwg_id, prio_type);
+		break;
+	default:
+		break;
+	}
+	return 0;
+}
diff --git a/drivers/net/ixgbe/ixgbe_dcb.h b/drivers/net/ixgbe/ixgbe_dcb.h
index aa6cb5f..4e4a641 100644
--- a/drivers/net/ixgbe/ixgbe_dcb.h
+++ b/drivers/net/ixgbe/ixgbe_dcb.h
@@ -150,10 +150,14 @@ struct ixgbe_dcb_config {
 void ixgbe_dcb_unpack_pfc(struct ixgbe_dcb_config *cfg, u8 *pfc_en);
 
 /* DCB credits calculation */
+s32 ixgbe_ieee_credits(__u8 *bw, __u16 *refill, __u16 *max, int max_frame);
 s32 ixgbe_dcb_calculate_tc_credits(struct ixgbe_hw *,
 				   struct ixgbe_dcb_config *, int, u8);
 
 /* DCB hw initialization */
+s32 ixgbe_dcb_hw_ets_config(struct ixgbe_hw *hw,
+			    u16 *refill, u16 *max, u8 *bwg_id, u8 *prio_type);
+s32 ixgbe_dcb_hw_pfc_config(struct ixgbe_hw *hw, u8 pfc_en);
 s32 ixgbe_dcb_hw_config(struct ixgbe_hw *, struct ixgbe_dcb_config *);
 
 /* DCB definitions for credit calculation */
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.c b/drivers/net/ixgbe/ixgbe_dcb_82598.c
index d128806..2965edc 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82598.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82598.c
@@ -291,7 +291,7 @@ out:
  * Configure queue statistics registers, all queues belonging to same traffic
  * class uses a single set of queue statistics counters.
  */
-static s32 ixgbe_dcb_config_tc_stats_82598(struct ixgbe_hw *hw)
+s32 ixgbe_dcb_config_tc_stats_82598(struct ixgbe_hw *hw)
 {
 	u32 reg = 0;
 	u8  i   = 0;
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 6ab1f1a..e75a3c9 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -606,7 +606,98 @@ static u8 ixgbe_dcbnl_setapp(struct net_device *netdev,
 	return rval;
 }
 
+static int ixgbe_dcbnl_ieee_getets(struct net_device *dev,
+				   struct ieee_ets *ets)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	struct ieee_ets *my_ets = adapter->ixgbe_ieee_ets;
+
+	/* No IEEE PFC settings available */
+	if (!my_ets)
+		return -EINVAL;
+
+	ets->ets_cap = MAX_TRAFFIC_CLASS;
+	ets->cbs = my_ets->cbs;
+	memcpy(ets->tc_tx_bw, my_ets->tc_tx_bw, sizeof(ets->tc_tx_bw));
+	memcpy(ets->tc_rx_bw, my_ets->tc_rx_bw, sizeof(ets->tc_rx_bw));
+	memcpy(ets->tc_tsa, my_ets->tc_tsa, sizeof(ets->tc_tsa));
+	memcpy(ets->prio_tc, my_ets->prio_tc, sizeof(ets->prio_tc));
+	return 0;
+}
+
+static int ixgbe_dcbnl_ieee_setets(struct net_device *dev,
+				   struct ieee_ets *ets)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	__u16 refill[IEEE_8021QAZ_MAX_TCS], max[IEEE_8021QAZ_MAX_TCS];
+	int max_frame = dev->mtu + ETH_HLEN + ETH_FCS_LEN;
+	int err;
+	/* naively give each TC a bwg to map onto CEE hardware */
+	__u8 bwg_id[IEEE_8021QAZ_MAX_TCS] = {0, 1, 2, 3, 4, 5, 6, 7};
+
+	if (!adapter->ixgbe_ieee_ets) {
+		adapter->ixgbe_ieee_ets = kmalloc(sizeof(struct ieee_ets),
+						  GFP_KERNEL);
+		if (!adapter->ixgbe_ieee_ets)
+			return -ENOMEM;
+	}
+
+
+	memcpy(adapter->ixgbe_ieee_ets, ets, sizeof(*adapter->ixgbe_ieee_ets));
+
+	ixgbe_ieee_credits(ets->tc_tx_bw, refill, max, max_frame);
+	err = ixgbe_dcb_hw_ets_config(&adapter->hw, refill, max,
+				      bwg_id, ets->tc_tsa);
+	return err;
+}
+
+static int ixgbe_dcbnl_ieee_getpfc(struct net_device *dev,
+				   struct ieee_pfc *pfc)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	struct ieee_pfc *my_pfc = adapter->ixgbe_ieee_pfc;
+	int i;
+
+	/* No IEEE PFC settings available */
+	if (!my_pfc)
+		return -EINVAL;
+
+	pfc->pfc_cap = MAX_TRAFFIC_CLASS;
+	pfc->pfc_en = my_pfc->pfc_en;
+	pfc->mbc = my_pfc->mbc;
+	pfc->delay = my_pfc->delay;
+
+	for (i = 0; i < MAX_TRAFFIC_CLASS; i++) {
+		pfc->requests[i] = adapter->stats.pxoffrxc[i];
+		pfc->indications[i] = adapter->stats.pxofftxc[i];
+	}
+
+	return 0;
+}
+
+static int ixgbe_dcbnl_ieee_setpfc(struct net_device *dev,
+				   struct ieee_pfc *pfc)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	int err;
+
+	if (!adapter->ixgbe_ieee_pfc) {
+		adapter->ixgbe_ieee_pfc = kmalloc(sizeof(struct ieee_pfc),
+						  GFP_KERNEL);
+		if (!adapter->ixgbe_ieee_pfc)
+			return -ENOMEM;
+	}
+
+	memcpy(adapter->ixgbe_ieee_pfc, pfc, sizeof(*adapter->ixgbe_ieee_pfc));
+	err = ixgbe_dcb_hw_pfc_config(&adapter->hw, pfc->pfc_en);
+	return err;
+}
+
 const struct dcbnl_rtnl_ops dcbnl_ops = {
+	.ieee_getets	= ixgbe_dcbnl_ieee_getets,
+	.ieee_setets	= ixgbe_dcbnl_ieee_setets,
+	.ieee_getpfc	= ixgbe_dcbnl_ieee_getpfc,
+	.ieee_setpfc	= ixgbe_dcbnl_ieee_setpfc,
 	.getstate	= ixgbe_dcbnl_get_state,
 	.setstate	= ixgbe_dcbnl_set_state,
 	.getpermhwaddr	= ixgbe_dcbnl_get_perm_hw_addr,
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 1e48148..c2e09b9 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5609,6 +5609,10 @@ static int __ixgbe_shutdown(struct pci_dev *pdev, bool *enable_wake)
 	}
 
 	ixgbe_clear_interrupt_scheme(adapter);
+#ifdef CONFIG_DCB
+	kfree(adapter->ixgbe_ieee_pfc);
+	kfree(adapter->ixgbe_ieee_ets);
+#endif
 
 #ifdef CONFIG_PM
 	retval = pci_save_state(pdev);
diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
index 68cd248..cd8d518 100644
--- a/include/linux/dcbnl.h
+++ b/include/linux/dcbnl.h
@@ -25,6 +25,11 @@
 /* IEEE 802.1Qaz std supported values */
 #define IEEE_8021QAZ_MAX_TCS	8
 
+#define IEEE_8021QAZ_TSA_STRICT		0
+#define IEEE_8021QAZ_TSA_CB_SHABER	1
+#define IEEE_8021QAZ_TSA_ETS		2
+#define IEEE_8021QAZ_TSA_VENDOR		255
+
 /* This structure contains the IEEE 802.1Qaz ETS managed object
  *
  * @willing: willing bit in ETS configuratin TLV
-- 
1.7.4

