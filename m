From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/2] ixgbe: Limit use of 2K buffers on architectures with 256B or larger cache lines
Date: Thu,  2 Mar 2017 18:24:48 -0800
Message-ID: <20170303022448.79638-3-jeffrey.t.kirsher@intel.com>
References: <20170303022448.79638-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34339 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751475AbdCCCZL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Mar 2017 21:25:11 -0500
In-Reply-To: <20170303022448.79638-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

On architectures that have a cache line size larger than 64 Bytes we start
running into issues where the amount of headroom for the frame starts
shrinking.

The size of skb_shared_info on a system with a 64B L1 cache line size is
320.  This increases to 384 with a 128B cache line, and 512 with a 256B
cache line.

In addition the NET_SKB_PAD value increases as well consistent with the
cache line size.  As a result when we get to a 256B cache line as seen on
the s390 we end up 768 bytes used by padding and shared info leaving us
with only 1280 bytes to use for data storage.  On architectures such as
this we should default to using 3K Rx buffers out of a 8K page instead of
trying to do 1.5K buffers out of a 4K page.

To take all of this into account I have added one small check so that we
compare the max_frame to the amount of actual data we can store.  This was
already occurring for igb, but I had overlooked it for ixgbe as it doesn't
have strict limits for 82599 once we enable jumbo frames.  By adding this
check we will automatically enable 3K Rx buffers as soon as the maximum
frame size we can handle drops below the standard Ethernet MTU.

I also went through and fixed one small typo that I found where I had left
an IGB in a variable name due to a copy/paste error.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 7a951b116821..b1ecc2627a5a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -96,7 +96,7 @@
 #define IXGBE_MAX_FRAME_BUILD_SKB \
 	(SKB_WITH_OVERHEAD(IXGBE_RXBUFFER_2K) - IXGBE_SKB_PAD)
 #else
-#define IGB_MAX_FRAME_BUILD_SKB IXGBE_RXBUFFER_2K
+#define IXGBE_MAX_FRAME_BUILD_SKB IXGBE_RXBUFFER_2K
 #endif
 
 /*
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 67ab13fd163c..a7a430a7be2c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3972,7 +3972,8 @@ static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
 		if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)
 			set_bit(__IXGBE_RX_3K_BUFFER, &rx_ring->state);
 
-		if (max_frame > (ETH_FRAME_LEN + ETH_FCS_LEN))
+		if ((max_frame > (ETH_FRAME_LEN + ETH_FCS_LEN)) ||
+		    (max_frame > IXGBE_MAX_FRAME_BUILD_SKB))
 			set_bit(__IXGBE_RX_3K_BUFFER, &rx_ring->state);
 #endif
 	}
-- 
2.12.0
