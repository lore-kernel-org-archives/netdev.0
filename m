From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH] igb: Fix TX map failure path
Date: Thu, 19 Oct 2017 20:07:36 +0100
Message-ID: <20171019190736.2770-1-jean-philippe.brucker@arm.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from usa-sjc-mx-foss1.foss.arm.com ([217.140.101.70]:59390 "EHLO
        foss.arm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753051AbdJSTDq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 15:03:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the driver cannot map a TX buffer, instead of rolling back
gracefully and retrying later, we currently get a panic:

[  159.885994] igb 0000:00:00.0: TX DMA map failed
[  159.886588] Unable to handle kernel paging request at virtual address ffff00000a08c7a8
               ...
[  159.897031] PC is at igb_xmit_frame_ring+0x9c8/0xcb8

Fix the erroneous test that leads to this situation.

Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
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
2.13.3
