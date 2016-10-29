From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/17] i40e: Rewrite Flow Director busy wait loop
Date: Sat, 29 Oct 2016 00:30:43 -0700
Message-ID: <1477726258-111563-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1477726258-111563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10260 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751028AbcJ2HbG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 29 Oct 2016 03:31:06 -0400
In-Reply-To: <1477726258-111563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

We can reorder the busy wait loop at the start of the Flow Director
transmit function to reduce the overall code size while still retaining the
same functionality.  As such I am taking advantage of the opportunity to do
so.

Change-ID: I34c403ca001953c6ac9816e65d5305e73d869026
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 6287bf6..af36c44 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -122,7 +122,6 @@ static int i40e_program_fdir_filter(struct i40e_fdir_filter *fdir_data,
 	struct device *dev;
 	dma_addr_t dma;
 	u32 td_cmd = 0;
-	u16 delay = 0;
 	u16 i;
 
 	/* find existing FDIR VSI */
@@ -137,15 +136,11 @@ static int i40e_program_fdir_filter(struct i40e_fdir_filter *fdir_data,
 	dev = tx_ring->dev;
 
 	/* we need two descriptors to add/del a filter and we can wait */
-	do {
-		if (I40E_DESC_UNUSED(tx_ring) > 1)
-			break;
+	for (i = I40E_FD_CLEAN_DELAY; I40E_DESC_UNUSED(tx_ring) < 2; i--) {
+		if (!i)
+			return -EAGAIN;
 		msleep_interruptible(1);
-		delay++;
-	} while (delay < I40E_FD_CLEAN_DELAY);
-
-	if (!(I40E_DESC_UNUSED(tx_ring) > 1))
-		return -EAGAIN;
+	}
 
 	dma = dma_map_single(dev, raw_packet,
 			     I40E_FDIR_MAX_RAW_PACKET_SIZE, DMA_TO_DEVICE);
-- 
2.7.4
