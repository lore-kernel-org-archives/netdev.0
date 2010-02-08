From: Anton Blanchard <anton@samba.org>
Subject: MAX_SKB_FRAGS and GRO
Date: Mon, 8 Feb 2010 21:03:07 +1100
Message-ID: <20100208100306.GQ32246@kryten>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="YZ5djTAD1cGYuMQK"
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>, divy@chelsio.com,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:45038 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751797Ab0BHKFx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2010 05:05:53 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


Hi Herbert,

I was looking through the hardware GRO support in various drivers and I think
we have a couple of issues with PAGE_SIZE > 4k. For example, if we have a 64kB
page size then MAX_SKB_FRAGS ends up as 3:

#define MAX_SKB_FRAGS (65536/PAGE_SIZE + 2)

This should be fine for hardware and software GSO, but we encounter issues
with hardware GRO (not sure about software GRO).

In the ixgbe case we use MAX_SKB_FRAGS to program the max number of GRO
descriptors, even though we assemble GRO packets using ->frag_list:

#if (MAX_SKB_FRAGS > 16)
                rscctrl |= IXGBE_RSCCTL_MAXDESC_16;
#elif (MAX_SKB_FRAGS > 8)
                rscctrl |= IXGBE_RSCCTL_MAXDESC_8;
#elif (MAX_SKB_FRAGS > 4)
                rscctrl |= IXGBE_RSCCTL_MAXDESC_4;
#else
                rscctrl |= IXGBE_RSCCTL_MAXDESC_1;
#endif

With MAX_SKB_FRAGS = 3 it looks like we only allow 1 GRO descriptor, and since
the card can only do DMAs of 16kB that will be our maximum GRO packet.

I don't have a hardware GRO capable ixgbe to try this out yet, but I think
we want to do something like the attached (completely untested) patch, dividing
GSO_MAX_SIZE by our per packet maximum.

In the cxgb3 case we build GRO packets via ->frags. (FYI I had a look through
the driver but I wasn't able to see where it caps GRO assembly to
MAX_SKB_FRAGS, probably missing something). cxgb3 may be able to do 64kB
DMAs (again not sure), but you could imagine a card with DMA restrictions,
perhaps as bad as 4kB per descriptor. In this case MAX_SKB_FRAGS is sized way
too small.

Thinking out aloud, would setting a pessimistic value for MAX_SKB_FRAGS
be one way to fix this? ie:

#define MAX_SKB_FRAGS (65536/4096 + 2)

I'm not sure if that would break the tx side of some adapters.

Anton

--YZ5djTAD1cGYuMQK
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="ixgbe_hw_gro.patch"

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index b5f64ad..283f6cc 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -644,6 +644,13 @@ static inline void ixgbe_release_rx_desc(struct ixgbe_hw *hw,
 	IXGBE_WRITE_REG(hw, IXGBE_RDT(rx_ring->reg_idx), val);
 }
 
+/* The maximum DMA the card can do is 16kB, so cap it if required */
+#if (PAGE_SIZE / 2) > IXGBE_MAX_RXBUFFER
+#define IXGBE_RXBUFFER_SIZE	IXGBE_MAX_RXBUFFER
+#else
+#define IXGBE_RXBUFFER_SIZE	(PAGE_SIZE / 2)
+#endif
+
 /**
  * ixgbe_alloc_rx_buffers - Replace used receive buffers; packet split
  * @adapter: address of board private structure
@@ -2032,11 +2039,7 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter,
 		  IXGBE_SRRCTL_BSIZEHDR_MASK;
 
 	if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED) {
-#if (PAGE_SIZE / 2) > IXGBE_MAX_RXBUFFER
-		srrctl |= IXGBE_MAX_RXBUFFER >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
-#else
-		srrctl |= (PAGE_SIZE / 2) >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
-#endif
+		srrctl |= IXGBE_RXBUFFER_SIZE >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
 		srrctl |= IXGBE_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS;
 	} else {
 		srrctl |= ALIGN(rx_ring->rx_buf_len, 1024) >>
@@ -2101,11 +2104,11 @@ static void ixgbe_configure_rscctl(struct ixgbe_adapter *adapter, int index)
 	 * than 65535
 	 */
 	if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED) {
-#if (MAX_SKB_FRAGS > 16)
+#if (GSO_MAX_SIZE / IXGBE_RXBUFFER_SIZE) >= 16
 		rscctrl |= IXGBE_RSCCTL_MAXDESC_16;
-#elif (MAX_SKB_FRAGS > 8)
+#elif (GSO_MAX_SIZE / IXGBE_RXBUFFER_SIZE) >= 8
 		rscctrl |= IXGBE_RSCCTL_MAXDESC_8;
-#elif (MAX_SKB_FRAGS > 4)
+#elif (GSO_MAX_SIZE / IXGBE_RXBUFFER_SIZE) >= 4
 		rscctrl |= IXGBE_RSCCTL_MAXDESC_4;
 #else
 		rscctrl |= IXGBE_RSCCTL_MAXDESC_1;

--YZ5djTAD1cGYuMQK--
