From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 5/8] ixgbe: Fix broken dependency on MAX_SKB_FRAGS being related to page size
Date: Wed,  8 Feb 2012 01:36:35 -0800
Message-ID: <1328693798-27323-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328693798-27323-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:45540 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751902Ab2BHJgq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Feb 2012 04:36:46 -0500
In-Reply-To: <1328693798-27323-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch fixes an issue in which RSC will generate corrupted frames when
PAGE_SIZE is larger than 8K.  Specifically it looks like that in 2.6.39 a
change was made so that GRO would always have at least 16 frags available
for coalescing, but the ixgbe RSC logic was not updated.  As such the RSC
feature would generate a frame larger than 64K and then overflow the value
in the IP length field.

To correct that I am now basing things on the PAGE_SIZE.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 819b5c0..0688704 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2633,22 +2633,22 @@ static void ixgbe_configure_rscctl(struct ixgbe_adapter *adapter,
 	/*
 	 * we must limit the number of descriptors so that the
 	 * total size of max desc * buf_len is not greater
-	 * than 65535
+	 * than 65536
 	 */
 	if (ring_is_ps_enabled(ring)) {
-#if (MAX_SKB_FRAGS > 16)
+#if (PAGE_SIZE < 8192)
 		rscctrl |= IXGBE_RSCCTL_MAXDESC_16;
-#elif (MAX_SKB_FRAGS > 8)
+#elif (PAGE_SIZE < 16384)
 		rscctrl |= IXGBE_RSCCTL_MAXDESC_8;
-#elif (MAX_SKB_FRAGS > 4)
+#elif (PAGE_SIZE < 32768)
 		rscctrl |= IXGBE_RSCCTL_MAXDESC_4;
 #else
 		rscctrl |= IXGBE_RSCCTL_MAXDESC_1;
 #endif
 	} else {
-		if (rx_buf_len < IXGBE_RXBUFFER_4K)
+		if (rx_buf_len <= IXGBE_RXBUFFER_4K)
 			rscctrl |= IXGBE_RSCCTL_MAXDESC_16;
-		else if (rx_buf_len < IXGBE_RXBUFFER_8K)
+		else if (rx_buf_len <= IXGBE_RXBUFFER_8K)
 			rscctrl |= IXGBE_RSCCTL_MAXDESC_8;
 		else
 			rscctrl |= IXGBE_RSCCTL_MAXDESC_4;
-- 
1.7.7.6
