From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 3/8] net: mvneta: Fix missing DMA region unmap
Date: Fri, 30 May 2014 13:40:06 -0300
Message-ID: <1401468011-10609-4-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1401468011-10609-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>, fugang.duan@freescale.com,
	Willy Tarreau <w@1wt.eu>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:58428 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933415AbaE3QlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 12:41:14 -0400
In-Reply-To: <1401468011-10609-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Tx descriptor release code currently calls dma_unmap_single() and
dev_kfree_skb_any() if the descriptor is associated with a non-NULL skb.
This is true only for the last fragment of the packet.

This is wrong, however, since every descriptor buffer is DMA mapped and needs
to be unmapped.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 57a2e76..f95e7ca 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1291,11 +1291,10 @@ static void mvneta_txq_bufs_free(struct mvneta_port *pp,
 
 		mvneta_txq_inc_get(txq);
 
-		if (!skb)
-			continue;
-
 		dma_unmap_single(pp->dev->dev.parent, tx_desc->buf_phys_addr,
 				 tx_desc->data_size, DMA_TO_DEVICE);
+		if (!skb)
+			continue;
 		dev_kfree_skb_any(skb);
 	}
 }
-- 
1.9.1
