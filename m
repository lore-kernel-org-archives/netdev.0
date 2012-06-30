From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH 06/10] ixgbe: Define FCoE and Flow director limits much
	sooner to allow for changes
Date: Fri, 29 Jun 2012 17:16:44 -0700
Message-ID: <20120630001644.29939.9474.stgit@gitlad.jf.intel.com>
References: <20120630000652.29939.11108.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	edumazet@google.com, bhutchings@solarflare.com,
	therbert@google.com, alexander.duyck@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:32308 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755999Ab2F3AQZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2012 20:16:25 -0400
In-Reply-To: <20120630000652.29939.11108.stgit@gitlad.jf.intel.com>
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
index 24acd53..72386fb 100644
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
index 5217b6d..dedb412 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4433,7 +4433,7 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
-	unsigned int rss;
+	unsigned int rss, fdir;
 #ifdef CONFIG_IXGBE_DCB
 	int j;
 	struct tc_configuration *tc;
@@ -4466,8 +4466,8 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
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
@@ -7324,13 +7324,17 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
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
