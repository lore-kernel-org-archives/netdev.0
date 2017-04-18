From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] ixgbe: Add support for maximum headroom when using build_skb
Date: Tue, 18 Apr 2017 16:02:04 -0700
Message-ID: <20170418230205.37223-15-jeffrey.t.kirsher@intel.com>
References: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:61886 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757759AbdDRXCQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 19:02:16 -0400
In-Reply-To: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch increases the headroom allocated when using build_skb on a
system with 4K pages.  Specifically the breakdown of headroom versus cache
size is as follows:
    L1 Cache Size           Headroom
    64                      192
    64, NET_IP_ALIGN == 2   194
    128                     128
    128, NET_IP_ALIGN == 2  130
    256                     512
    256, NET_IP_ALIGN == 2  258

I stopped at supporting only a cache line size of 256 as that was the
largest cache size I could find supported in the kernel.

With this we are guaranteeing at least 128 bytes of headroom to spare in
the frame.  This should be enough for us to insert a couple of IPv6 headers
if needed which is likely enough room for anything XDP should need.

I'm leaving the padding for systems with pages larger than 4K unmodified
for now.  XDP currently isn't really setup to work on those types of
systems so we can cross that bridge when we get there.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      | 55 ++++++++++++++++++++++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  6 +--
 2 files changed, 53 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index b1ecc2627a5a..656ca8f69768 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -86,17 +86,62 @@
 
 /* Supported Rx Buffer Sizes */
 #define IXGBE_RXBUFFER_256    256  /* Used for skb receive header */
+#define IXGBE_RXBUFFER_1536  1536
 #define IXGBE_RXBUFFER_2K    2048
 #define IXGBE_RXBUFFER_3K    3072
 #define IXGBE_RXBUFFER_4K    4096
 #define IXGBE_MAX_RXBUFFER  16384  /* largest size for a single descriptor */
 
-#define IXGBE_SKB_PAD		(NET_SKB_PAD + NET_IP_ALIGN)
+/* Attempt to maximize the headroom available for incoming frames.  We
+ * use a 2K buffer for receives and need 1536/1534 to store the data for
+ * the frame.  This leaves us with 512 bytes of room.  From that we need
+ * to deduct the space needed for the shared info and the padding needed
+ * to IP align the frame.
+ *
+ * Note: For cache line sizes 256 or larger this value is going to end
+ *	 up negative.  In these cases we should fall back to the 3K
+ *	 buffers.
+ */
 #if (PAGE_SIZE < 8192)
-#define IXGBE_MAX_FRAME_BUILD_SKB \
-	(SKB_WITH_OVERHEAD(IXGBE_RXBUFFER_2K) - IXGBE_SKB_PAD)
+#define IXGBE_MAX_2K_FRAME_BUILD_SKB (IXGBE_RXBUFFER_1536 - NET_IP_ALIGN)
+#define IXGBE_2K_TOO_SMALL_WITH_PADDING \
+((NET_SKB_PAD + IXGBE_RXBUFFER_1536) > SKB_WITH_OVERHEAD(IXGBE_RXBUFFER_2K))
+
+static inline int ixgbe_compute_pad(int rx_buf_len)
+{
+	int page_size, pad_size;
+
+	page_size = ALIGN(rx_buf_len, PAGE_SIZE / 2);
+	pad_size = SKB_WITH_OVERHEAD(page_size) - rx_buf_len;
+
+	return pad_size;
+}
+
+static inline int ixgbe_skb_pad(void)
+{
+	int rx_buf_len;
+
+	/* If a 2K buffer cannot handle a standard Ethernet frame then
+	 * optimize padding for a 3K buffer instead of a 1.5K buffer.
+	 *
+	 * For a 3K buffer we need to add enough padding to allow for
+	 * tailroom due to NET_IP_ALIGN possibly shifting us out of
+	 * cache-line alignment.
+	 */
+	if (IXGBE_2K_TOO_SMALL_WITH_PADDING)
+		rx_buf_len = IXGBE_RXBUFFER_3K + SKB_DATA_ALIGN(NET_IP_ALIGN);
+	else
+		rx_buf_len = IXGBE_RXBUFFER_1536;
+
+	/* if needed make room for NET_IP_ALIGN */
+	rx_buf_len -= NET_IP_ALIGN;
+
+	return ixgbe_compute_pad(rx_buf_len);
+}
+
+#define IXGBE_SKB_PAD	ixgbe_skb_pad()
 #else
-#define IXGBE_MAX_FRAME_BUILD_SKB IXGBE_RXBUFFER_2K
+#define IXGBE_SKB_PAD	(NET_SKB_PAD + NET_IP_ALIGN)
 #endif
 
 /*
@@ -361,7 +406,7 @@ static inline unsigned int ixgbe_rx_bufsz(struct ixgbe_ring *ring)
 		return IXGBE_RXBUFFER_3K;
 #if (PAGE_SIZE < 8192)
 	if (ring_uses_build_skb(ring))
-		return IXGBE_MAX_FRAME_BUILD_SKB;
+		return IXGBE_MAX_2K_FRAME_BUILD_SKB;
 #endif
 	return IXGBE_RXBUFFER_2K;
 }
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index dcc8a5c26276..536dd9b1ad97 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3813,7 +3813,7 @@ void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
 		/* Limit the maximum frame size so we don't overrun the skb */
 		if (ring_uses_build_skb(ring) &&
 		    !test_bit(__IXGBE_RX_3K_BUFFER, &ring->state))
-			rxdctl |= IXGBE_MAX_FRAME_BUILD_SKB |
+			rxdctl |= IXGBE_MAX_2K_FRAME_BUILD_SKB |
 				  IXGBE_RXDCTL_RLPML_EN;
 #endif
 	}
@@ -3983,8 +3983,8 @@ static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
 		if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)
 			set_bit(__IXGBE_RX_3K_BUFFER, &rx_ring->state);
 
-		if ((max_frame > (ETH_FRAME_LEN + ETH_FCS_LEN)) ||
-		    (max_frame > IXGBE_MAX_FRAME_BUILD_SKB))
+		if (IXGBE_2K_TOO_SMALL_WITH_PADDING ||
+		    (max_frame > (ETH_FRAME_LEN + ETH_FCS_LEN)))
 			set_bit(__IXGBE_RX_3K_BUFFER, &rx_ring->state);
 #endif
 	}
-- 
2.12.2
