From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] i40e: fix handling of HW ATR eviction
Date: Mon, 12 Jun 2017 15:38:36 -0700
Message-ID: <20170612223837.38940-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:59187 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752383AbdFLWim (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Jun 2017 18:38:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

A recent commit to refactor the driver and remove the hw_disabled_flags
field accidentally introduced two regressions. First, we overwrote
pf->flags which removed various key flags including the MSI-X settings.

Additionally, it was intended that we have now two flags,
HW_ATR_EVICT_CAPABLe and HW_ATR_EVICT_ENABLED, but this was not done,
and we accidentally were mis-using HW_ATR_EVICT_CAPABLE everywhere.

This patch adds the missing piece, HW_ATR_EVICT_ENABLED, and safely
updates pf->flags instead of overwriting it.

Without this patch we will have many problems including disabling MSI-X
support, and we'll attempt to use HW ATR eviction on devices which do
not support it.

Fixes: 47994c119a36 ("i40e: remove hw_disabled_flags in favor of using separate flag bits", 2017-04-19)
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         | 1 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 4 ++--
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 7 ++++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c    | 4 ++--
 4 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index cdde3cc28fb5..44d9610f7a15 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -399,6 +399,7 @@ struct i40e_pf {
 #define I40E_FLAG_RX_CSUM_ENABLED		BIT_ULL(1)
 #define I40E_FLAG_MSI_ENABLED			BIT_ULL(2)
 #define I40E_FLAG_MSIX_ENABLED			BIT_ULL(3)
+#define I40E_FLAG_HW_ATR_EVICT_ENABLED		BIT_ULL(4)
 #define I40E_FLAG_RSS_ENABLED			BIT_ULL(6)
 #define I40E_FLAG_VMDQ_ENABLED			BIT_ULL(7)
 #define I40E_FLAG_IWARP_ENABLED			BIT_ULL(10)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 7a8eb486b9ea..894c8e57ba00 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -224,7 +224,7 @@ static const struct i40e_priv_flags i40e_gstrings_priv_flags[] = {
 	I40E_PRIV_FLAG("LinkPolling", I40E_FLAG_LINK_POLLING_ENABLED, 0),
 	I40E_PRIV_FLAG("flow-director-atr", I40E_FLAG_FD_ATR_ENABLED, 0),
 	I40E_PRIV_FLAG("veb-stats", I40E_FLAG_VEB_STATS_ENABLED, 0),
-	I40E_PRIV_FLAG("hw-atr-eviction", I40E_FLAG_HW_ATR_EVICT_CAPABLE, 0),
+	I40E_PRIV_FLAG("hw-atr-eviction", I40E_FLAG_HW_ATR_EVICT_ENABLED, 0),
 	I40E_PRIV_FLAG("legacy-rx", I40E_FLAG_LEGACY_RX, 0),
 };
 
@@ -4092,7 +4092,7 @@ static int i40e_set_priv_flags(struct net_device *dev, u32 flags)
 
 	/* Only allow ATR evict on hardware that is capable of handling it */
 	if (pf->flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE)
-		pf->flags &= ~I40E_FLAG_HW_ATR_EVICT_CAPABLE;
+		pf->flags &= ~I40E_FLAG_HW_ATR_EVICT_ENABLED;
 
 	if (changed_flags & I40E_FLAG_TRUE_PROMISC_SUPPORT) {
 		u16 sw_flags = 0, valid_flags = 0;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 150caf6ca2b4..a7a4b28b4144 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8821,11 +8821,12 @@ static int i40e_sw_init(struct i40e_pf *pf)
 		    (pf->hw.aq.api_min_ver > 4))) {
 		/* Supported in FW API version higher than 1.4 */
 		pf->flags |= I40E_FLAG_GENEVE_OFFLOAD_CAPABLE;
-		pf->flags = I40E_FLAG_HW_ATR_EVICT_CAPABLE;
-	} else {
-		pf->flags = I40E_FLAG_HW_ATR_EVICT_CAPABLE;
 	}
 
+	/* Enable HW ATR eviction if possible */
+	if (pf->flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE)
+		pf->flags |= I40E_FLAG_HW_ATR_EVICT_ENABLED;
+
 	pf->eeprom_version = 0xDEAD;
 	pf->lan_veb = I40E_NO_VEB;
 	pf->lan_vsi = I40E_NO_VSI;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index cd894f4023b1..77115c25d96f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2341,7 +2341,7 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	/* Due to lack of space, no more new filters can be programmed */
 	if (th->syn && (pf->flags & I40E_FLAG_FD_ATR_AUTO_DISABLED))
 		return;
-	if (pf->flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE) {
+	if (pf->flags & I40E_FLAG_HW_ATR_EVICT_ENABLED) {
 		/* HW ATR eviction will take care of removing filters on FIN
 		 * and RST packets.
 		 */
@@ -2403,7 +2403,7 @@ static void i40e_atr(struct i40e_ring *tx_ring, struct sk_buff *skb,
 			I40E_TXD_FLTR_QW1_CNTINDEX_SHIFT) &
 			I40E_TXD_FLTR_QW1_CNTINDEX_MASK;
 
-	if (pf->flags & I40E_FLAG_HW_ATR_EVICT_CAPABLE)
+	if (pf->flags & I40E_FLAG_HW_ATR_EVICT_ENABLED)
 		dtype_cmd |= I40E_TXD_FLTR_QW1_ATR_MASK;
 
 	fdir_desc->qindex_flex_ptype_vsi = cpu_to_le32(flex_ptype);
-- 
2.12.2
