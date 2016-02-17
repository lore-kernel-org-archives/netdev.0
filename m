From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] i40e: add priv flag for automatic rule eviction
Date: Wed, 17 Feb 2016 09:51:45 -0800
Message-ID: <1455731506-62165-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455731506-62165-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:28480 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161651AbcBQRvx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 12:51:53 -0500
In-Reply-To: <1455731506-62165-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

The X722 can support automatic rule eviction for automatically added
flow director rules.  Feature is (should be) disabled by default.

Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         | 1 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 9 +++++++++
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 3 +++
 drivers/net/ethernet/intel/i40e/i40e_txrx.c    | 6 ++++--
 drivers/net/ethernet/intel/i40e/i40e_type.h    | 4 ++++
 5 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 65cf344..05af33e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -104,6 +104,7 @@
 #define I40E_PRIV_FLAGS_FD_ATR		BIT(2)
 #define I40E_PRIV_FLAGS_VEB_STATS	BIT(3)
 #define I40E_PRIV_FLAGS_PS		BIT(4)
+#define I40E_PRIV_FLAGS_HW_ATR_EVICT	BIT(5)
 
 #define I40E_NVM_VERSION_LO_SHIFT  0
 #define I40E_NVM_VERSION_LO_MASK   (0xff << I40E_NVM_VERSION_LO_SHIFT)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 9dcdf34..89ad2f7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -235,6 +235,7 @@ static const char i40e_priv_flags_strings[][ETH_GSTRING_LEN] = {
 	"flow-director-atr",
 	"veb-stats",
 	"packet-split",
+	"hw-atr-eviction",
 };
 
 #define I40E_PRIV_FLAGS_STR_LEN ARRAY_SIZE(i40e_priv_flags_strings)
@@ -2731,6 +2732,8 @@ static u32 i40e_get_priv_flags(struct net_device *dev)
 		I40E_PRIV_FLAGS_VEB_STATS : 0;
 	ret_flags |= pf->flags & I40E_FLAG_RX_PS_ENABLED ?
 		I40E_PRIV_FLAGS_PS : 0;
+	ret_flags |= pf->auto_disable_flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE ?
+		0 : I40E_PRIV_FLAGS_HW_ATR_EVICT;
 
 	return ret_flags;
 }
@@ -2787,6 +2790,12 @@ static int i40e_set_priv_flags(struct net_device *dev, u32 flags)
 	else
 		pf->flags &= ~I40E_FLAG_VEB_STATS_ENABLED;
 
+	if ((flags & I40E_PRIV_FLAGS_HW_ATR_EVICT) &&
+	    (pf->flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE))
+		pf->auto_disable_flags &= ~I40E_FLAG_HW_ATR_EVICT_CAPABLE;
+	else
+		pf->auto_disable_flags |= I40E_FLAG_HW_ATR_EVICT_CAPABLE;
+
 	/* if needed, issue reset to cause things to take effect */
 	if (reset_required)
 		i40e_do_reset(pf, BIT(__I40E_PF_RESET_REQUESTED));
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 99d7a5c..f6d61cc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8464,6 +8464,9 @@ static int i40e_sw_init(struct i40e_pf *pf)
 		    (pf->hw.aq.api_min_ver > 4))) {
 		/* Supported in FW API version higher than 1.4 */
 		pf->flags |= I40E_FLAG_GENEVE_OFFLOAD_CAPABLE;
+		pf->auto_disable_flags = I40E_FLAG_HW_ATR_EVICT_CAPABLE;
+	} else {
+		pf->auto_disable_flags = I40E_FLAG_HW_ATR_EVICT_CAPABLE;
 	}
 
 	pf->eeprom_version = 0xDEAD;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 15130b5d..6d1dd60 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2047,7 +2047,8 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	/* Due to lack of space, no more new filters can be programmed */
 	if (th->syn && (pf->auto_disable_flags & I40E_FLAG_FD_ATR_ENABLED))
 		return;
-	if (pf->flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE) {
+	if ((pf->flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE) &&
+	    (!(pf->auto_disable_flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE))) {
 		/* HW ATR eviction will take care of removing filters on FIN
 		 * and RST packets.
 		 */
@@ -2109,7 +2110,8 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 			I40E_TXD_FLTR_QW1_CNTINDEX_SHIFT) &
 			I40E_TXD_FLTR_QW1_CNTINDEX_MASK;
 
-	if (pf->flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE)
+	if ((pf->flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE) &&
+	    (!(pf->auto_disable_flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE)))
 		dtype_cmd |= I40E_TXD_FLTR_QW1_ATR_MASK;
 
 	fdir_desc->qindex_flex_ptype_vsi = cpu_to_le32(flex_ptype);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index dd2da35..b59a021 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -1098,6 +1098,10 @@ enum i40e_filter_program_desc_pcmd {
 					 I40E_TXD_FLTR_QW1_CMD_SHIFT)
 #define I40E_TXD_FLTR_QW1_ATR_MASK	BIT_ULL(I40E_TXD_FLTR_QW1_ATR_SHIFT)
 
+#define I40E_TXD_FLTR_QW1_ATR_SHIFT	(0xEULL + \
+					 I40E_TXD_FLTR_QW1_CMD_SHIFT)
+#define I40E_TXD_FLTR_QW1_ATR_MASK	BIT_ULL(I40E_TXD_FLTR_QW1_ATR_SHIFT)
+
 #define I40E_TXD_FLTR_QW1_CNTINDEX_SHIFT 20
 #define I40E_TXD_FLTR_QW1_CNTINDEX_MASK	(0x1FFUL << \
 					 I40E_TXD_FLTR_QW1_CNTINDEX_SHIFT)
-- 
2.5.0
