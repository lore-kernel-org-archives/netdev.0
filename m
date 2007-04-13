From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH v2 6/7] ucc_geth: fixes for ucc_geth_memclean
Date: Fri, 13 Apr 2007 01:26:29 -0500
Message-ID: <20070413012629.17873777.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:37307 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992AbXDMG1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2007 02:27:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicu Ioan Petru <ionut.nicu@freescale.com>

The ucc_geth_memclean function can be called before the Tx BD rings, Rx
BD rings and associated socket buffers are allocated (for example if
ucc_fast_init fails). The current code doesn't check if p_tx_bd_ring[i]
is null, generating a kernel panic when trying to free the associated
socket buffers.

The function can also fail when accessing the uninitialized list_head
structures ugeth->group_hash_q and ugeth->ind_hash_q. In the current
implementation the list heads are initialized only when
maxGroupAddrInHash and maxIndAddrInHash are positive values, although I
think it's better to always initialize them.

Signed-off-by: Ionut Nicu <ionut.nicu@freescale.com>
Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
 drivers/net/ucc_geth.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 60844a6..20bc105 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -2133,6 +2133,8 @@ static void ucc_geth_memclean(struct ucc_geth_private *ugeth)
 	}
 	for (i = 0; i < ugeth->ug_info->numQueuesTx; i++) {
 		bd = ugeth->p_tx_bd_ring[i];
+		if (!bd)
+			continue;
 		for (j = 0; j < ugeth->ug_info->bdRingLenTx[i]; j++) {
 			if (ugeth->tx_skbuff[i][j]) {
 				dma_unmap_single(NULL,
@@ -2300,6 +2302,10 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	ug_info = ugeth->ug_info;
 	uf_info = &ug_info->uf_info;
 
+	/* Create CQs for hash tables */
+	INIT_LIST_HEAD(&ugeth->group_hash_q);
+	INIT_LIST_HEAD(&ugeth->ind_hash_q);
+
 	if (!((uf_info->bd_mem_part == MEM_PART_SYSTEM) ||
 	      (uf_info->bd_mem_part == MEM_PART_MURAM))) {
 		ugeth_err("%s: Bad memory partition value.", __FUNCTION__);
@@ -3132,13 +3138,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		for (j = 0; j < NUM_OF_PADDRS; j++)
 			ugeth_82xx_filtering_clear_addr_in_paddr(ugeth, (u8) j);
 
-		/* Create CQs for hash tables */
-		if (ug_info->maxGroupAddrInHash > 0) {
-			INIT_LIST_HEAD(&ugeth->group_hash_q);
-		}
-		if (ug_info->maxIndAddrInHash > 0) {
-			INIT_LIST_HEAD(&ugeth->ind_hash_q);
-		}
 		p_82xx_addr_filt =
 		    (struct ucc_geth_82xx_address_filtering_pram *) ugeth->
 		    p_rx_glbl_pram->addressfiltering;
-- 
1.5.0.1

