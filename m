From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/7] ixgbe: Add function for obtaining FCoE TC based on FCoE user priority
Date: Sat, 14 Jul 2012 16:07:04 -0700
Message-ID: <1342307225-28917-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342307225-28917-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:23399 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754307Ab2GNXHs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jul 2012 19:07:48 -0400
In-Reply-To: <1342307225-28917-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

In upcoming patches it will become increasingly common to need to determine
the FCoE traffic class in order to determine the correct queues for FCoE.
In order to make this easier I am adding a function for obtaining the FCoE
traffic class based on the user priority.

Cc: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c |   15 +++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c  |    7 ++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   14 ++++----------
 4 files changed, 22 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 2ffdc8f..5a75a9c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -707,6 +707,7 @@ extern u8 ixgbe_fcoe_setapp(struct ixgbe_adapter *adapter, u8 up);
 extern int ixgbe_fcoe_get_wwn(struct net_device *netdev, u64 *wwn, int type);
 extern int ixgbe_fcoe_get_hbainfo(struct net_device *netdev,
 				  struct netdev_fcoe_hbainfo *info);
+extern u8 ixgbe_fcoe_get_tc(struct ixgbe_adapter *adapter);
 #endif /* IXGBE_FCOE */
 
 static inline struct netdev_queue *txring_txq(const struct ixgbe_ring *ring)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
index 0922ece..cc28c44 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
@@ -960,3 +960,18 @@ int ixgbe_fcoe_get_hbainfo(struct net_device *netdev,
 
 	return 0;
 }
+
+/**
+ * ixgbe_fcoe_get_tc - get the current TC that fcoe is mapped to
+ * @adapter - pointer to the device adapter structure
+ *
+ * Return : TC that FCoE is mapped to
+ */
+u8 ixgbe_fcoe_get_tc(struct ixgbe_adapter *adapter)
+{
+#ifdef CONFIG_IXGBE_DCB
+	return netdev_get_prio_tc_map(adapter->netdev, adapter->fcoe.up);
+#else
+	return 0;
+#endif
+}
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 83eadd0..c0ff31e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -49,8 +49,8 @@ static inline bool ixgbe_cache_ring_rss(struct ixgbe_adapter *adapter)
 
 	return true;
 }
-#ifdef CONFIG_IXGBE_DCB
 
+#ifdef CONFIG_IXGBE_DCB
 /* ixgbe_get_first_reg_idx - Return first register index associated with ring */
 static void ixgbe_get_first_reg_idx(struct ixgbe_adapter *adapter, u8 tc,
 				    unsigned int *tx, unsigned int *rx)
@@ -343,13 +343,10 @@ static inline bool ixgbe_set_dcb_queues(struct ixgbe_adapter *adapter)
 	 * configuration later.
 	 */
 	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
-		u8 prio_tc[MAX_USER_PRIORITY] = {0};
-		int tc;
+		u8 tc = ixgbe_fcoe_get_tc(adapter);
 		struct ixgbe_ring_feature *f =
 					&adapter->ring_feature[RING_F_FCOE];
 
-		ixgbe_dcb_unpack_map(&adapter->dcb_cfg, DCB_TX_CONFIG, prio_tc);
-		tc = prio_tc[adapter->fcoe.up];
 		f->indices = dev->tc_to_txq[tc].count;
 		f->offset = dev->tc_to_txq[tc].offset;
 	}
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 91bc60f..3d7ce7e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3646,18 +3646,12 @@ static int ixgbe_hpbthresh(struct ixgbe_adapter *adapter, int pb)
 
 #ifdef IXGBE_FCOE
 	/* FCoE traffic class uses FCOE jumbo frames */
-	if (dev->features & NETIF_F_FCOE_MTU) {
-		int fcoe_pb = 0;
-
-#ifdef CONFIG_IXGBE_DCB
-		fcoe_pb = netdev_get_prio_tc_map(dev, adapter->fcoe.up);
+	if ((dev->features & NETIF_F_FCOE_MTU) &&
+	    (tc < IXGBE_FCOE_JUMBO_FRAME_SIZE) &&
+	    (pb == ixgbe_fcoe_get_tc(adapter)))
+		tc = IXGBE_FCOE_JUMBO_FRAME_SIZE;
 
 #endif
-		if (fcoe_pb == pb && tc < IXGBE_FCOE_JUMBO_FRAME_SIZE)
-			tc = IXGBE_FCOE_JUMBO_FRAME_SIZE;
-	}
-#endif
-
 	/* Calculate delay value for device */
 	switch (hw->mac.type) {
 	case ixgbe_mac_X540:
-- 
1.7.10.4
