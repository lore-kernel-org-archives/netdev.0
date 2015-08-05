From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] i40e/i40evf: Add ATR HW eviction support for X722
Date: Wed,  5 Aug 2015 16:52:09 -0700
Message-ID: <1438818735-38115-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1438818735-38115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55534 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753808AbbHEXwU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2015 19:52:20 -0400
In-Reply-To: <1438818735-38115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

X722 supports evicting ATR filters in the HW. With this patch, we enable
the feature in the driver and avoid filter deletion by the driver.

Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 10 ++++++++++
 drivers/net/ethernet/intel/i40e/i40e_type.h |  4 ++++
 2 files changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 57dc5d2..738aca6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2040,6 +2040,13 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	/* Due to lack of space, no more new filters can be programmed */
 	if (th->syn && (pf->auto_disable_flags & I40E_FLAG_FD_ATR_ENABLED))
 		return;
+	if (pf->flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE) {
+		/* HW ATR eviction will take care of removing filters on FIN
+		 * and RST packets.
+		 */
+		if (th->fin || th->rst)
+			return;
+	}
 
 	tx_ring->atr_count++;
 
@@ -2095,6 +2102,9 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 			I40E_TXD_FLTR_QW1_CNTINDEX_SHIFT) &
 			I40E_TXD_FLTR_QW1_CNTINDEX_MASK;
 
+	if (pf->flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE)
+		dtype_cmd |= I40E_TXD_FLTR_QW1_ATR_MASK;
+
 	fdir_desc->qindex_flex_ptype_vsi = cpu_to_le32(flex_ptype);
 	fdir_desc->rsvd = cpu_to_le32(0);
 	fdir_desc->dtype_cmd_cntindex = cpu_to_le32(dtype_cmd);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index b93357d..61b6b11 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -1049,6 +1049,10 @@ enum i40e_filter_program_desc_pcmd {
 #define I40E_TXD_FLTR_QW1_FD_STATUS_MASK (0x3ULL << \
 					  I40E_TXD_FLTR_QW1_FD_STATUS_SHIFT)
 
+#define I40E_TXD_FLTR_QW1_ATR_SHIFT	(0xEULL + \
+					 I40E_TXD_FLTR_QW1_CMD_SHIFT)
+#define I40E_TXD_FLTR_QW1_ATR_MASK	BIT_ULL(I40E_TXD_FLTR_QW1_ATR_SHIFT)
+
 #define I40E_TXD_FLTR_QW1_CNTINDEX_SHIFT 20
 #define I40E_TXD_FLTR_QW1_CNTINDEX_MASK	(0x1FFUL << \
 					 I40E_TXD_FLTR_QW1_CNTINDEX_SHIFT)
-- 
2.4.3
