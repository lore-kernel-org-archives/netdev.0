From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/13] igb: Update max_frame_size to account for an optional VLAN tag if present
Date: Sat, 17 Sep 2011 01:04:27 -0700
Message-ID: <1316246677-8830-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316246677-8830-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:59863 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752404Ab1IQIEm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Sep 2011 04:04:42 -0400
In-Reply-To: <1316246677-8830-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch modifies the max_frame_size in order account for an optional
VLAN tag.  In order to support this we must also increase the
MAX_STD_JUMBO_FRAME_SIZE to account for the 4 extra bytes.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      |    2 --
 drivers/net/ethernet/intel/igb/igb_main.c |   19 ++++++++++++-------
 2 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 577fd3e..8e90b85 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -117,8 +117,6 @@ struct vf_data_storage {
 #define IGB_RXBUFFER_2048  2048
 #define IGB_RXBUFFER_16384 16384
 
-#define MAX_STD_JUMBO_FRAME_SIZE 9234
-
 /* How many Tx Descriptors do we need to call netif_wake_queue ? */
 #define IGB_TX_QUEUE_WAKE	16
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index aa78c10..6156275 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2396,7 +2396,8 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
 	adapter->rx_itr_setting = IGB_DEFAULT_ITR;
 	adapter->tx_itr_setting = IGB_DEFAULT_ITR;
 
-	adapter->max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
+	adapter->max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN +
+				  VLAN_HLEN;
 	adapter->min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
 
 	spin_lock_init(&adapter->stats64_lock);
@@ -2962,16 +2963,19 @@ static inline int igb_set_vf_rlpml(struct igb_adapter *adapter, int size,
  **/
 static void igb_rlpml_set(struct igb_adapter *adapter)
 {
-	u32 max_frame_size;
+	u32 max_frame_size = adapter->max_frame_size;
 	struct e1000_hw *hw = &adapter->hw;
 	u16 pf_id = adapter->vfs_allocated_count;
 
-	max_frame_size = adapter->max_frame_size + VLAN_TAG_SIZE;
-
-	/* if vfs are enabled we set RLPML to the largest possible request
-	 * size and set the VMOLR RLPML to the size we need */
 	if (pf_id) {
 		igb_set_vf_rlpml(adapter, max_frame_size, pf_id);
+		/*
+		 * If we're in VMDQ or SR-IOV mode, then set global RLPML
+		 * to our max jumbo frame size, in case we need to enable
+		 * jumbo frames on one of the rings later.
+		 * This will not pass over-length frames into the default
+		 * queue because it's gated by the VMOLR.RLPML.
+		 */
 		max_frame_size = MAX_JUMBO_FRAME_SIZE;
 	}
 
@@ -4461,7 +4465,7 @@ static int igb_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct pci_dev *pdev = adapter->pdev;
-	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
+	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
 	u32 rx_buffer_len, i;
 
 	if ((new_mtu < 68) || (max_frame > MAX_JUMBO_FRAME_SIZE)) {
@@ -4469,6 +4473,7 @@ static int igb_change_mtu(struct net_device *netdev, int new_mtu)
 		return -EINVAL;
 	}
 
+#define MAX_STD_JUMBO_FRAME_SIZE 9238
 	if (max_frame > MAX_STD_JUMBO_FRAME_SIZE) {
 		dev_err(&pdev->dev, "MTU > 9216 not supported.\n");
 		return -EINVAL;
-- 
1.7.6
