From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/4] igb: support RX flow classification by ethertype
Date: Thu, 18 Aug 2016 22:30:48 -0700
Message-ID: <1471584650-14645-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471584650-14645-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Gangfeng Huang <gangfeng.huang@ni.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com, Ruhao Gao <ruhao.gao@ni.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26431 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754510AbcHSFay (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 Aug 2016 01:30:54 -0400
In-Reply-To: <1471584650-14645-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gangfeng Huang <gangfeng.huang@ni.com>

This patch is meant to allow for RX network flow classification to insert
and remove ethertype filter by ethtool

Example:
Add an ethertype filter:
$ ethtool -N eth0 flow-type ether proto 0x88F8 action 2

Show all filters:
$ ethtool -n eth0
4 RX rings available
Total 1 rules

Filter: 15
	Flow Type: Raw Ethernet
	Src MAC addr: 00:00:00:00:00:00 mask: FF:FF:FF:FF:FF:FF
	Dest MAC addr: 00:00:00:00:00:00 mask: FF:FF:FF:FF:FF:FF
	Ethertype: 0x88F8 mask: 0x0
	Action: Direct to queue 2

Delete the filter by location:
$ ethtool -N delete 15

Signed-off-by: Ruhao Gao <ruhao.gao@ni.com>
Signed-off-by: Gangfeng Huang <gangfeng.huang@ni.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.h |  5 ++
 drivers/net/ethernet/intel/igb/igb.h         | 21 ++++++--
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 77 +++++++++++++++++++++++++++-
 drivers/net/ethernet/intel/igb/igb_ptp.c     |  4 +-
 4 files changed, 101 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.h b/drivers/net/ethernet/intel/igb/e1000_82575.h
index 199ff98..acf0605 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.h
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.h
@@ -188,6 +188,11 @@ struct e1000_adv_tx_context_desc {
 /* ETQF register bit definitions */
 #define E1000_ETQF_FILTER_ENABLE   BIT(26)
 #define E1000_ETQF_1588            BIT(30)
+#define E1000_ETQF_IMM_INT         BIT(29)
+#define E1000_ETQF_QUEUE_ENABLE    BIT(31)
+#define E1000_ETQF_QUEUE_SHIFT     16
+#define E1000_ETQF_QUEUE_MASK      0x00070000
+#define E1000_ETQF_ETYPE_MASK      0x0000FFFF
 
 /* FTQF register bit definitions */
 #define E1000_FTQF_VF_BP               0x00008000
diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 37f82ca..5c50758 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -350,13 +350,24 @@ struct hwmon_buff {
 	};
 #endif
 
+/* The number of L2 ether-type filter registers, Index 3 is reserved
+ * for PTP 1588 timestamp
+ */
+#define MAX_ETYPE_FILTER	(4 - 1)
+/* ETQF filter list: one static filter per filter consumer. This is
+ * to avoid filter collisions later. Add new filters here!!
+ *
+ * Current filters:		Filter 3
+ */
+#define IGB_ETQF_FILTER_1588	3
+
 #define IGB_N_EXTTS	2
 #define IGB_N_PEROUT	2
 #define IGB_N_SDP	4
 #define IGB_RETA_SIZE	128
 
 enum igb_filter_match_flags {
-	IGB_FILTER_FLAG_NONE = 0x0,
+	IGB_FILTER_FLAG_ETHER_TYPE = 0x1,
 };
 
 #define IGB_MAX_RXNFC_FILTERS 16
@@ -364,14 +375,17 @@ enum igb_filter_match_flags {
 /* RX network flow classification data structure */
 struct igb_nfc_input {
 	/* Byte layout in order, all values with MSB first:
-	* match_flags - 1 byte
-	*/
+	 * match_flags - 1 byte
+	 * etype - 2 bytes
+	 */
 	u8 match_flags;
+	__be16 etype;
 };
 
 struct igb_nfc_filter {
 	struct hlist_node nfc_node;
 	struct igb_nfc_input filter;
+	u16 etype_reg_index;
 	u16 sw_idx;
 	u16 action;
 };
@@ -500,6 +514,7 @@ struct igb_adapter {
 	unsigned int nfc_filter_count;
 	/* lock for RX network flow classification filter */
 	spinlock_t nfc_lock;
+	bool etype_bitmap[MAX_ETYPE_FILTER];
 };
 
 /* flags controlling PTP/1588 function */
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 2599826..00e3387 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2431,6 +2431,7 @@ static int igb_get_ts_info(struct net_device *dev,
 	}
 }
 
+#define ETHER_TYPE_FULL_MASK ((__force __be16)~0)
 static int igb_get_ethtool_nfc_entry(struct igb_adapter *adapter,
 				     struct ethtool_rxnfc *cmd)
 {
@@ -2448,6 +2449,13 @@ static int igb_get_ethtool_nfc_entry(struct igb_adapter *adapter,
 	if (!rule || fsp->location != rule->sw_idx)
 		return -EINVAL;
 
+	if (rule->filter.match_flags & IGB_FILTER_FLAG_ETHER_TYPE) {
+		fsp->flow_type = ETHER_FLOW;
+		fsp->ring_cookie = rule->action;
+		fsp->h_u.ether_spec.h_proto = rule->filter.etype;
+		fsp->m_u.ether_spec.h_proto = ETHER_TYPE_FULL_MASK;
+		return 0;
+	}
 	return -EINVAL;
 }
 
@@ -2650,13 +2658,75 @@ static int igb_set_rss_hash_opt(struct igb_adapter *adapter,
 	return 0;
 }
 
+static int igb_rxnfc_write_etype_filter(struct igb_adapter *adapter,
+					struct igb_nfc_filter *input)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u8 i;
+	u32 etqf;
+	u16 etype;
+
+	/* find an empty etype filter register */
+	for (i = 0; i < MAX_ETYPE_FILTER; ++i) {
+		if (!adapter->etype_bitmap[i])
+			break;
+	}
+	if (i == MAX_ETYPE_FILTER) {
+		dev_err(&adapter->pdev->dev, "ethtool -N: etype filters are all used.\n");
+		return -EINVAL;
+	}
+
+	adapter->etype_bitmap[i] = true;
+
+	etqf = rd32(E1000_ETQF(i));
+	etype = ntohs(input->filter.etype & ETHER_TYPE_FULL_MASK);
+
+	etqf |= E1000_ETQF_FILTER_ENABLE;
+	etqf &= ~E1000_ETQF_ETYPE_MASK;
+	etqf |= (etype & E1000_ETQF_ETYPE_MASK);
+
+	etqf &= ~E1000_ETQF_QUEUE_MASK;
+	etqf |= ((input->action << E1000_ETQF_QUEUE_SHIFT)
+		& E1000_ETQF_QUEUE_MASK);
+	etqf |= E1000_ETQF_QUEUE_ENABLE;
+
+	wr32(E1000_ETQF(i), etqf);
+
+	input->etype_reg_index = i;
+
+	return 0;
+}
+
 int igb_add_filter(struct igb_adapter *adapter, struct igb_nfc_filter *input)
 {
-	return -EINVAL;
+	int err = -EINVAL;
+
+	if (input->filter.match_flags & IGB_FILTER_FLAG_ETHER_TYPE)
+		err = igb_rxnfc_write_etype_filter(adapter, input);
+
+	return err;
+}
+
+static void igb_clear_etype_filter_regs(struct igb_adapter *adapter,
+					u16 reg_index)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 etqf = rd32(E1000_ETQF(reg_index));
+
+	etqf &= ~E1000_ETQF_QUEUE_ENABLE;
+	etqf &= ~E1000_ETQF_QUEUE_MASK;
+	etqf &= ~E1000_ETQF_FILTER_ENABLE;
+
+	wr32(E1000_ETQF(reg_index), etqf);
+
+	adapter->etype_bitmap[reg_index] = false;
 }
 
 int igb_erase_filter(struct igb_adapter *adapter, struct igb_nfc_filter *input)
 {
+	if (input->filter.match_flags & IGB_FILTER_FLAG_ETHER_TYPE)
+		igb_clear_etype_filter_regs(adapter,
+					    input->etype_reg_index);
 	return 0;
 }
 
@@ -2738,10 +2808,15 @@ static int igb_add_ethtool_nfc_entry(struct igb_adapter *adapter,
 	if ((fsp->flow_type & ~FLOW_EXT) != ETHER_FLOW)
 		return -EINVAL;
 
+	if (fsp->m_u.ether_spec.h_proto != ETHER_TYPE_FULL_MASK)
+		return -EINVAL;
+
 	input = kzalloc(sizeof(*input), GFP_KERNEL);
 	if (!input)
 		return -ENOMEM;
 
+	input->filter.etype = fsp->h_u.ether_spec.h_proto;
+	input->filter.match_flags = IGB_FILTER_FLAG_ETHER_TYPE;
 	input->action = fsp->ring_cookie;
 	input->sw_idx = fsp->location;
 
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 336c103..66dfa20 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -998,12 +998,12 @@ static int igb_ptp_set_timestamp_mode(struct igb_adapter *adapter,
 
 	/* define ethertype filter for timestamped packets */
 	if (is_l2)
-		wr32(E1000_ETQF(3),
+		wr32(E1000_ETQF(IGB_ETQF_FILTER_1588),
 		     (E1000_ETQF_FILTER_ENABLE | /* enable filter */
 		      E1000_ETQF_1588 | /* enable timestamping */
 		      ETH_P_1588));     /* 1588 eth protocol type */
 	else
-		wr32(E1000_ETQF(3), 0);
+		wr32(E1000_ETQF(IGB_ETQF_FILTER_1588), 0);
 
 	/* L4 Queue Filter[3]: filter by destination port and protocol */
 	if (is_l4) {
-- 
2.7.4
