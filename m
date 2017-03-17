From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/13] igb: Limit maximum frame Rx based on MTU
Date: Fri, 17 Mar 2017 12:58:10 -0700
Message-ID: <20170317195818.74912-6-jeffrey.t.kirsher@intel.com>
References: <20170317195818.74912-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:21553 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751221AbdCQT60 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Mar 2017 15:58:26 -0400
In-Reply-To: <20170317195818.74912-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

In order to support the use of build_skb going forward it will be necessary
to place a maximum limit on the amount of data we can receive when jumbo
frames is not enabled.  In order to do this I am adding a new upper limit
for receive based on the size of a 2K buffer minus padding.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      | 10 +++++++++-
 drivers/net/ethernet/intel/igb/igb_main.c | 21 +++++++++++++++++----
 2 files changed, 26 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index a638254f4e06..a74928cc0e58 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -143,8 +143,17 @@ struct vf_data_storage {
 #define IGB_RXBUFFER_256	256
 #define IGB_RXBUFFER_2048	2048
 #define IGB_RX_HDR_LEN		IGB_RXBUFFER_256
+#define IGB_TS_HDR_LEN		16
 #define IGB_RX_BUFSZ		IGB_RXBUFFER_2048
 
+#define IGB_SKB_PAD		(NET_SKB_PAD + NET_IP_ALIGN)
+#if (PAGE_SIZE < 8192)
+#define IGB_MAX_FRAME_BUILD_SKB \
+	(SKB_WITH_OVERHEAD(IGB_RXBUFFER_2048) - IGB_SKB_PAD - IGB_TS_HDR_LEN)
+#else
+#define IGB_MAX_FRAME_BUILD_SKB (IGB_RXBUFFER_2048 - IGB_TS_HDR_LEN)
+#endif
+
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
 #define IGB_RX_BUFFER_WRITE	16 /* Must be power of 2 */
 
@@ -561,7 +570,6 @@ struct igb_adapter {
 #define IGB_DMCTLX_DCFLUSH_DIS	0x80000000  /* Disable DMA Coal Flush */
 
 #define IGB_82576_TSYNC_SHIFT	19
-#define IGB_TS_HDR_LEN		16
 enum e1000_state_t {
 	__IGB_TESTING,
 	__IGB_RESETTING,
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index e541cccaae1b..1bf31224dfac 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4250,7 +4250,7 @@ static void igb_set_rx_mode(struct net_device *netdev)
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	unsigned int vfn = adapter->vfs_allocated_count;
-	u32 rctl = 0, vmolr = 0;
+	u32 rctl = 0, vmolr = 0, rlpml = MAX_JUMBO_FRAME_SIZE;
 	int count;
 
 	/* Check for Promiscuous and All Multicast modes */
@@ -4308,6 +4308,14 @@ static void igb_set_rx_mode(struct net_device *netdev)
 				     E1000_RCTL_VFE);
 	wr32(E1000_RCTL, rctl);
 
+#if (PAGE_SIZE < 8192)
+	if (!adapter->vfs_allocated_count) {
+		if (adapter->max_frame_size <= IGB_MAX_FRAME_BUILD_SKB)
+			rlpml = IGB_MAX_FRAME_BUILD_SKB;
+	}
+#endif
+	wr32(E1000_RLPML, rlpml);
+
 	/* In order to support SR-IOV and eventually VMDq it is necessary to set
 	 * the VMOLR to enable the appropriate modes.  Without this workaround
 	 * we will have issues with VLAN tag stripping not being done for frames
@@ -4322,12 +4330,17 @@ static void igb_set_rx_mode(struct net_device *netdev)
 	vmolr |= rd32(E1000_VMOLR(vfn)) &
 		 ~(E1000_VMOLR_ROPE | E1000_VMOLR_MPME | E1000_VMOLR_ROMPE);
 
-	/* enable Rx jumbo frames, no need for restriction */
+	/* enable Rx jumbo frames, restrict as needed to support build_skb */
 	vmolr &= ~E1000_VMOLR_RLPML_MASK;
-	vmolr |= MAX_JUMBO_FRAME_SIZE | E1000_VMOLR_LPE;
+#if (PAGE_SIZE < 8192)
+	if (adapter->max_frame_size <= IGB_MAX_FRAME_BUILD_SKB)
+		vmolr |= IGB_MAX_FRAME_BUILD_SKB;
+	else
+#endif
+		vmolr |= MAX_JUMBO_FRAME_SIZE;
+	vmolr |= E1000_VMOLR_LPE;
 
 	wr32(E1000_VMOLR(vfn), vmolr);
-	wr32(E1000_RLPML, MAX_JUMBO_FRAME_SIZE);
 
 	igb_restore_vf_multicasts(adapter);
 }
-- 
2.12.0
