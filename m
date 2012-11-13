From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/11] ixgbevf: Reduce size of maximum rx buffer
Date: Tue, 13 Nov 2012 06:03:19 -0800
Message-ID: <1352815405-751-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1352815405-751-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35423 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754765Ab2KMODb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 09:03:31 -0500
In-Reply-To: <1352815405-751-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

There's no need to support up to 15k buffers since the HW is limited to
9.5k in SR-IOV mode.  Instead, allocate buffers that fit and align inside
of a 32K memory buffer.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  8 ++++----
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 18 +++++++++---------
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 9faaf54..1211fa0 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -101,10 +101,10 @@ struct ixgbevf_ring {
 
 /* Supported Rx Buffer Sizes */
 #define IXGBEVF_RXBUFFER_256   256    /* Used for packet split */
-#define IXGBEVF_RXBUFFER_3K    3072
-#define IXGBEVF_RXBUFFER_7K    7168
-#define IXGBEVF_RXBUFFER_15K   15360
-#define IXGBEVF_MAX_RXBUFFER   16384  /* largest size for single descriptor */
+#define IXGBEVF_RXBUFFER_2K    2048
+#define IXGBEVF_RXBUFFER_4K    4096
+#define IXGBEVF_RXBUFFER_8K    8192
+#define IXGBEVF_RXBUFFER_10K   10240
 
 #define IXGBEVF_RX_HDR_SIZE IXGBEVF_RXBUFFER_256
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 00f9698..9d88153 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1087,20 +1087,20 @@ static void ixgbevf_set_rx_buffer_len(struct ixgbevf_adapter *adapter)
 	max_frame += VLAN_HLEN;
 
 	/*
-	 * Make best use of allocation by using all but 1K of a
-	 * power of 2 allocation that will be used for skb->head.
+	 * Allocate buffer sizes that fit well into 32K and
+	 * take into account max frame size of 9.5K
 	 */
 	if ((hw->mac.type == ixgbe_mac_X540_vf) &&
 	    (max_frame <= MAXIMUM_ETHERNET_VLAN_SIZE))
 		rx_buf_len = MAXIMUM_ETHERNET_VLAN_SIZE;
-	else if (max_frame <= IXGBEVF_RXBUFFER_3K)
-		rx_buf_len = IXGBEVF_RXBUFFER_3K;
-	else if (max_frame <= IXGBEVF_RXBUFFER_7K)
-		rx_buf_len = IXGBEVF_RXBUFFER_7K;
-	else if (max_frame <= IXGBEVF_RXBUFFER_15K)
-		rx_buf_len = IXGBEVF_RXBUFFER_15K;
+	else if (max_frame <= IXGBEVF_RXBUFFER_2K)
+		rx_buf_len = IXGBEVF_RXBUFFER_2K;
+	else if (max_frame <= IXGBEVF_RXBUFFER_4K)
+		rx_buf_len = IXGBEVF_RXBUFFER_4K;
+	else if (max_frame <= IXGBEVF_RXBUFFER_8K)
+		rx_buf_len = IXGBEVF_RXBUFFER_8K;
 	else
-		rx_buf_len = IXGBEVF_MAX_RXBUFFER;
+		rx_buf_len = IXGBEVF_RXBUFFER_10K;
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
 		adapter->rx_ring[i].rx_buf_len = rx_buf_len;
-- 
1.7.11.7
