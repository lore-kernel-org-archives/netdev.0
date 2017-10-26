From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/6] igb: Fix TX map failure path
Date: Thu, 26 Oct 2017 09:19:52 -0700
Message-ID: <20171026161955.4407-4-jeffrey.t.kirsher@intel.com>
References: <20171026161955.4407-1-jeffrey.t.kirsher@intel.com>
Cc: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:17177 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932348AbdJZQUT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 12:20:19 -0400
In-Reply-To: <20171026161955.4407-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>

When the driver cannot map a TX buffer, instead of rolling back
gracefully and retrying later, we currently get a panic:

[  159.885994] igb 0000:00:00.0: TX DMA map failed
[  159.886588] Unable to handle kernel paging request at virtual address ffff00000a08c7a8
               ...
[  159.897031] PC is at igb_xmit_frame_ring+0x9c8/0xcb8

Fix the erroneous test that leads to this situation.

Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index fd4a46b03cc8..ea69af267d63 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5326,7 +5326,7 @@ static int igb_tx_map(struct igb_ring *tx_ring,
 				       DMA_TO_DEVICE);
 		dma_unmap_len_set(tx_buffer, len, 0);
 
-		if (i--)
+		if (i-- == 0)
 			i += tx_ring->count;
 		tx_buffer = &tx_ring->tx_buffer_info[i];
 	}
-- 
2.14.2
