From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH v2 06/10] ixgbe: Define FCoE and Flow director limits
 much sooner to allow for changes
Date: Thu, 10 Jan 2013 10:57:59 -0800
Message-ID: <20130110185751.29578.52072.stgit@ahduyck-cp1.jf.intel.com>
References: <20130110184115.29578.85768.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, therbert@google.com, ycai@google.com,
	eric.dumazet@gmail.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:62739 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754756Ab3AJS7e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2013 13:59:34 -0500
In-Reply-To: <20130110184115.29578.85768.stgit@ahduyck-cp1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of adjusting the FCoE and Flow director limits based on the number
of CPUs we can define them much sooner.  This allows the user to come
through later and adjust them once we have updated the code to support the
set_channels ethtool operation.

I am still allowing for FCoE and RSS queues to be separated if the number
queues is less than the number of CPUs.  This essentially treats the two
groupings like they are two separate traffic classes.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c  |    7 +------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   12 ++++++++----
 2 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 8c74f73..4b1eeb6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -386,7 +386,6 @@ static bool ixgbe_set_dcb_sriov_queues(struct ixgbe_adapter *adapter)
 		fcoe = &adapter->ring_feature[RING_F_FCOE];
 
 		/* limit ourselves based on feature limits */
-		fcoe_i = min_t(u16, fcoe_i, num_online_cpus());
 		fcoe_i = min_t(u16, fcoe_i, fcoe->limit);
 
 		if (fcoe_i) {
@@ -562,9 +561,6 @@ static bool ixgbe_set_sriov_queues(struct ixgbe_adapter *adapter)
 		fcoe_i = min_t(u16, fcoe_i, fcoe->limit);
 
 		if (vmdq_i > 1 && fcoe_i) {
-			/* reserve no more than number of CPUs */
-			fcoe_i = min_t(u16, fcoe_i, num_online_cpus());
-
 			/* alloc queues for FCoE separately */
 			fcoe->indices = fcoe_i;
 			fcoe->offset = vmdq_i * rss_i;
@@ -623,8 +619,7 @@ static bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
 	if (rss_i > 1 && adapter->atr_sample_rate) {
 		f = &adapter->ring_feature[RING_F_FDIR];
 
-		f->indices = min_t(u16, num_online_cpus(), f->limit);
-		rss_i = max_t(u16, rss_i, f->indices);
+		rss_i = f->indices = f->limit;
 
 		if (!(adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
 			adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 20d6764..810f2b8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4466,7 +4466,7 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
-	unsigned int rss;
+	unsigned int rss, fdir;
 	u32 fwsm;
 #ifdef CONFIG_IXGBE_DCB
 	int j;
@@ -4502,8 +4502,8 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 			adapter->flags2 |= IXGBE_FLAG2_TEMP_SENSOR_CAPABLE;
 		/* Flow Director hash filters enabled */
 		adapter->atr_sample_rate = 20;
-		adapter->ring_feature[RING_F_FDIR].limit =
-							 IXGBE_MAX_FDIR_INDICES;
+		fdir = min_t(int, IXGBE_MAX_FDIR_INDICES, num_online_cpus());
+		adapter->ring_feature[RING_F_FDIR].limit = fdir;
 		adapter->fdir_pballoc = IXGBE_FDIR_PBALLOC_64K;
 #ifdef IXGBE_FCOE
 		adapter->flags |= IXGBE_FLAG_FCOE_CAPABLE;
@@ -7410,13 +7410,17 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 #ifdef IXGBE_FCOE
 	if (adapter->flags & IXGBE_FLAG_FCOE_CAPABLE) {
+		unsigned int fcoe_l;
+
 		if (hw->mac.ops.get_device_caps) {
 			hw->mac.ops.get_device_caps(hw, &device_caps);
 			if (device_caps & IXGBE_DEVICE_CAPS_FCOE_OFFLOADS)
 				adapter->flags &= ~IXGBE_FLAG_FCOE_CAPABLE;
 		}
 
-		adapter->ring_feature[RING_F_FCOE].limit = IXGBE_FCRETA_SIZE;
+
+		fcoe_l = min_t(int, IXGBE_FCRETA_SIZE, num_online_cpus());
+		adapter->ring_feature[RING_F_FCOE].limit = fcoe_l;
 
 		netdev->features |= NETIF_F_FSO |
 				    NETIF_F_FCOE_CRC;
