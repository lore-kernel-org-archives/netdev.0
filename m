From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/14] i40e/i40evf: remove mismatched type warnings
Date: Wed, 26 Jul 2017 03:31:17 -0700
Message-ID: <20170726103123.76743-9-jeffrey.t.kirsher@intel.com>
References: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:37205 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751471AbdGZKem (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 06:34:42 -0400
In-Reply-To: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Compiler reported several places where driver compared
signed and unsigned types.  Cast or change the types to remove
the warnings.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 6 +++---
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 2 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 6 +++---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 6 +++---
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 4 ++--
 5 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 9692a5294fa3..1d29152256fe 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1091,7 +1091,7 @@ static void i40e_get_regs(struct net_device *netdev, struct ethtool_regs *regs,
 	struct i40e_pf *pf = np->vsi->back;
 	struct i40e_hw *hw = &pf->hw;
 	u32 *reg_buf = p;
-	int i, j, ri;
+	unsigned int i, j, ri;
 	u32 reg;
 
 	/* Tell ethtool which driver-version-specific regs output we have.
@@ -1550,9 +1550,9 @@ static void i40e_get_ethtool_stats(struct net_device *netdev,
 	struct i40e_ring *tx_ring, *rx_ring;
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
+	unsigned int j;
 	int i = 0;
 	char *p;
-	int j;
 	struct rtnl_link_stats64 *net_stats = i40e_get_vsi_stats_struct(vsi);
 	unsigned int start;
 
@@ -1637,7 +1637,7 @@ static void i40e_get_strings(struct net_device *netdev, u32 stringset,
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
 	char *p = (char *)data;
-	int i;
+	unsigned int i;
 
 	switch (stringset) {
 	case ETH_SS_TEST:
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 22e60841cb22..a2d665161def 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4773,7 +4773,7 @@ static void i40e_detect_recover_hung(struct i40e_pf *pf)
 {
 	struct net_device *netdev;
 	struct i40e_vsi *vsi;
-	int i;
+	unsigned int i;
 
 	/* Only for LAN VSI */
 	vsi = pf->vsi[pf->lan_vsi];
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index c9a149678926..d464fceb300f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -860,7 +860,7 @@ static bool i40e_clean_tx_irq(struct i40e_vsi *vsi,
 	netdev_tx_completed_queue(txring_txq(tx_ring),
 				  total_packets, total_bytes);
 
-#define TX_WAKE_THRESHOLD (DESC_NEEDED * 2)
+#define TX_WAKE_THRESHOLD ((s16)(DESC_NEEDED * 2))
 	if (unlikely(total_packets && netif_carrier_ok(tx_ring->netdev) &&
 		     (I40E_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD))) {
 		/* Make sure that anybody stopping the queue after this
@@ -2063,7 +2063,7 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 	u16 cleaned_count = I40E_DESC_UNUSED(rx_ring);
 	bool failure = false, xdp_xmit = false;
 
-	while (likely(total_rx_packets < budget)) {
+	while (likely(total_rx_packets < (unsigned int)budget)) {
 		struct i40e_rx_buffer *rx_buffer;
 		union i40e_rx_desc *rx_desc;
 		struct xdp_buff xdp;
@@ -2196,7 +2196,7 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 	rx_ring->q_vector->rx.total_bytes += total_rx_bytes;
 
 	/* guarantee a trip back through this routine if there was a failure */
-	return failure ? budget : total_rx_packets;
+	return failure ? budget : (int)total_rx_packets;
 }
 
 static u32 i40e_buildreg_itr(const int type, const u16 itr)
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 12b02e530503..d91676ccf125 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -275,7 +275,7 @@ static bool i40e_clean_tx_irq(struct i40e_vsi *vsi,
 	netdev_tx_completed_queue(txring_txq(tx_ring),
 				  total_packets, total_bytes);
 
-#define TX_WAKE_THRESHOLD (DESC_NEEDED * 2)
+#define TX_WAKE_THRESHOLD ((s16)(DESC_NEEDED * 2))
 	if (unlikely(total_packets && netif_carrier_ok(tx_ring->netdev) &&
 		     (I40E_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD))) {
 		/* Make sure that anybody stopping the queue after this
@@ -1299,7 +1299,7 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 	u16 cleaned_count = I40E_DESC_UNUSED(rx_ring);
 	bool failure = false;
 
-	while (likely(total_rx_packets < budget)) {
+	while (likely(total_rx_packets < (unsigned int)budget)) {
 		struct i40e_rx_buffer *rx_buffer;
 		union i40e_rx_desc *rx_desc;
 		unsigned int size;
@@ -1406,7 +1406,7 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 	rx_ring->q_vector->rx.total_bytes += total_rx_bytes;
 
 	/* guarantee a trip back through this routine if there was a failure */
-	return failure ? budget : total_rx_packets;
+	return failure ? budget : (int)total_rx_packets;
 }
 
 static u32 i40e_buildreg_itr(const int type, const u16 itr)
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index 9bb2cc7dd4e4..76fd89c1dbb2 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -165,7 +165,7 @@ static void i40evf_get_ethtool_stats(struct net_device *netdev,
 				     struct ethtool_stats *stats, u64 *data)
 {
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
-	int i, j;
+	unsigned int i, j;
 	char *p;
 
 	for (i = 0; i < I40EVF_GLOBAL_STATS_LEN; i++) {
@@ -197,7 +197,7 @@ static void i40evf_get_strings(struct net_device *netdev, u32 sset, u8 *data)
 	int i;
 
 	if (sset == ETH_SS_STATS) {
-		for (i = 0; i < I40EVF_GLOBAL_STATS_LEN; i++) {
+		for (i = 0; i < (int)I40EVF_GLOBAL_STATS_LEN; i++) {
 			memcpy(p, i40evf_gstrings_stats[i].stat_string,
 			       ETH_GSTRING_LEN);
 			p += ETH_GSTRING_LEN;
-- 
2.13.3
