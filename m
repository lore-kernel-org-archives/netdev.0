From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: remove/replace invalid code
Date: Mon, 13 Mar 2017 12:07:32 -0700
Message-ID: <20170313190731.GA1756@felix2.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0047.outbound.protection.outlook.com ([104.47.36.47]:50785
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753240AbdCMTHj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Mar 2017 15:07:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

Remove invalid call to dma_sync_single_for_cpu() because previous DMA
allocation was coherent--not streaming.  Remove code that references fields
in struct list_head; replace it with calls to list_empty() and
list_first_entry().  Also, add comment to clarify complicated if statement.

Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
---
 .../ethernet/cavium/liquidio/response_manager.c    | 26 +++++++++-------------
 1 file changed, 10 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/response_manager.c b/drivers/net/ethernet/cavium/liquidio/response_manager.c
index 2fbaae9..1d987d7 100644
--- a/drivers/net/ethernet/cavium/liquidio/response_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/response_manager.c
@@ -69,41 +69,35 @@ int lio_process_ordered_list(struct octeon_device *octeon_dev,
 	int resp_to_process = MAX_ORD_REQS_TO_PROCESS;
 	u32 status;
 	u64 status64;
-	struct octeon_instr_rdp *rdp;
-	u64 rptr;
 
 	ordered_sc_list = &octeon_dev->response_list[OCTEON_ORDERED_SC_LIST];
 
 	do {
 		spin_lock_bh(&ordered_sc_list->lock);
 
-		if (ordered_sc_list->head.next == &ordered_sc_list->head) {
+		if (list_empty(&ordered_sc_list->head)) {
 			spin_unlock_bh(&ordered_sc_list->lock);
 			return 1;
 		}
 
-		sc = (struct octeon_soft_command *)ordered_sc_list->
-		    head.next;
-		if (OCTEON_CN23XX_PF(octeon_dev) ||
-		    OCTEON_CN23XX_VF(octeon_dev)) {
-			rdp = (struct octeon_instr_rdp *)&sc->cmd.cmd3.rdp;
-			rptr = sc->cmd.cmd3.rptr;
-		} else {
-			rdp = (struct octeon_instr_rdp *)&sc->cmd.cmd2.rdp;
-			rptr = sc->cmd.cmd2.rptr;
-		}
+		sc = list_first_entry(&ordered_sc_list->head,
+				      struct octeon_soft_command, node);
 
 		status = OCTEON_REQUEST_PENDING;
 
 		/* check if octeon has finished DMA'ing a response
 		 * to where rptr is pointing to
 		 */
-		dma_sync_single_for_cpu(&octeon_dev->pci_dev->dev,
-					rptr, rdp->rlen,
-					DMA_FROM_DEVICE);
 		status64 = *sc->status_word;
 
 		if (status64 != COMPLETION_WORD_INIT) {
+			/* This logic ensures that all 64b have been written.
+			 * 1. check byte 0 for non-FF
+			 * 2. if non-FF, then swap result from BE to host order
+			 * 3. check byte 7 (swapped to 0) for non-FF
+			 * 4. if non-FF, use the low 32-bit status code
+			 * 5. if either byte 0 or byte 7 is FF, don't use status
+			 */
 			if ((status64 & 0xff) != 0xff) {
 				octeon_swap_8B_data(&status64, 1);
 				if (((status64 & 0xff) != 0xff)) {
