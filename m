From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/14] fm10k: prefer READ_ONCE instead of ACCESS_ONCE
Date: Mon, 29 Aug 2016 02:13:37 -0700
Message-ID: <1472462026-42133-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1472462026-42133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:56356 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756848AbcH2JNu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 Aug 2016 05:13:50 -0400
In-Reply-To: <1472462026-42133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

While technically not needed, as all our uses of ACCESS_ONCE are scalar
types, we already use READ_ONCE in a few places, and for code
readability we can swap all the uses of the older ACCESS_ONCE into
READ_ONCE.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_common.h | 4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_iov.c    | 4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_main.c   | 2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 6 +++---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c    | 2 +-
 5 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_common.h b/drivers/net/ethernet/intel/fm10k/fm10k_common.h
index 50f71e9..d51f9c7 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_common.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_common.h
@@ -34,7 +34,7 @@ u32 fm10k_read_reg(struct fm10k_hw *hw, int reg);
 /* write operations, indexed using DWORDS */
 #define fm10k_write_reg(hw, reg, val) \
 do { \
-	u32 __iomem *hw_addr = ACCESS_ONCE((hw)->hw_addr); \
+	u32 __iomem *hw_addr = READ_ONCE((hw)->hw_addr); \
 	if (!FM10K_REMOVED(hw_addr)) \
 		writel((val), &hw_addr[(reg)]); \
 } while (0)
@@ -42,7 +42,7 @@ do { \
 /* Switch register write operations, index using DWORDS */
 #define fm10k_write_sw_reg(hw, reg, val) \
 do { \
-	u32 __iomem *sw_addr = ACCESS_ONCE((hw)->sw_addr); \
+	u32 __iomem *sw_addr = READ_ONCE((hw)->sw_addr); \
 	if (!FM10K_REMOVED(sw_addr)) \
 		writel((val), &sw_addr[(reg)]); \
 } while (0)
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
index 47f0743..d9dec81 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_iov.c
@@ -51,7 +51,7 @@ s32 fm10k_iov_event(struct fm10k_intfc *interface)
 	int i;
 
 	/* if there is no iov_data then there is no mailbox to process */
-	if (!ACCESS_ONCE(interface->iov_data))
+	if (!READ_ONCE(interface->iov_data))
 		return 0;
 
 	rcu_read_lock();
@@ -99,7 +99,7 @@ s32 fm10k_iov_mbx(struct fm10k_intfc *interface)
 	int i;
 
 	/* if there is no iov_data then there is no mailbox to process */
-	if (!ACCESS_ONCE(interface->iov_data))
+	if (!READ_ONCE(interface->iov_data))
 		return 0;
 
 	rcu_read_lock();
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 316f95b..4b65364 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1408,7 +1408,7 @@ static void fm10k_update_itr(struct fm10k_ring_container *ring_container)
 	 * that the calculation will never get below a 1. The bit shift
 	 * accounts for changes in the ITR due to PCIe link speed.
 	 */
-	itr_round = ACCESS_ONCE(ring_container->itr_scale) + 8;
+	itr_round = READ_ONCE(ring_container->itr_scale) + 8;
 	avg_wire_size += BIT(itr_round) - 1;
 	avg_wire_size >>= itr_round;
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 20a5bbe..855833e 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1098,7 +1098,7 @@ static struct rtnl_link_stats64 *fm10k_get_stats64(struct net_device *netdev,
 	rcu_read_lock();
 
 	for (i = 0; i < interface->num_rx_queues; i++) {
-		ring = ACCESS_ONCE(interface->rx_ring[i]);
+		ring = READ_ONCE(interface->rx_ring[i]);
 
 		if (!ring)
 			continue;
@@ -1114,7 +1114,7 @@ static struct rtnl_link_stats64 *fm10k_get_stats64(struct net_device *netdev,
 	}
 
 	for (i = 0; i < interface->num_tx_queues; i++) {
-		ring = ACCESS_ONCE(interface->tx_ring[i]);
+		ring = READ_ONCE(interface->tx_ring[i]);
 
 		if (!ring)
 			continue;
@@ -1299,7 +1299,7 @@ static void *fm10k_dfwd_add_station(struct net_device *dev,
 static void fm10k_dfwd_del_station(struct net_device *dev, void *priv)
 {
 	struct fm10k_intfc *interface = netdev_priv(dev);
-	struct fm10k_l2_accel *l2_accel = ACCESS_ONCE(interface->l2_accel);
+	struct fm10k_l2_accel *l2_accel = READ_ONCE(interface->l2_accel);
 	struct fm10k_dglort_cfg dglort = { 0 };
 	struct fm10k_hw *hw = &interface->hw;
 	struct net_device *sdev = priv;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 20c2a0c..11b2955 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -62,7 +62,7 @@ u16 fm10k_read_pci_cfg_word(struct fm10k_hw *hw, u32 reg)
 
 u32 fm10k_read_reg(struct fm10k_hw *hw, int reg)
 {
-	u32 __iomem *hw_addr = ACCESS_ONCE(hw->hw_addr);
+	u32 __iomem *hw_addr = READ_ONCE(hw->hw_addr);
 	u32 value = 0;
 
 	if (FM10K_REMOVED(hw_addr))
-- 
2.7.4
