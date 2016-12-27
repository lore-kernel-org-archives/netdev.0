From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH v2 03/11] net: mvpp2: release reference to txq_cpu[] entry after unmapping
Date: Tue, 27 Dec 2016 17:54:12 +0100
Message-ID: <1482857660-16092-4-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1482857660-16092-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:36621 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754079AbcL0Qyb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 11:54:31 -0500
In-Reply-To: <1482857660-16092-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mvpp2_txq_bufs_free() function is called upon TX completion to DMA
unmap TX buffers, and free the corresponding SKBs. It gets the
references to the SKB to free and the DMA buffer to unmap from a per-CPU
txq_pcpu data structure.

However, the code currently increments the pointer to the next entry
before doing the DMA unmap and freeing the SKB. It does not cause any
visible problem because for a given SKB the TX completion is guaranteed
to take place on the CPU where the TX was started. However, it is much
more logical to increment the pointer to the next entry once the current
entry has been completely unmapped/released.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index a1ba89f..d098c7b 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -4420,13 +4420,12 @@ static void mvpp2_txq_bufs_free(struct mvpp2_port *port,
 		struct mvpp2_txq_pcpu_buf *tx_buf =
 			txq_pcpu->buffs + txq_pcpu->txq_get_index;
 
-		mvpp2_txq_inc_get(txq_pcpu);
-
 		dma_unmap_single(port->dev->dev.parent, tx_buf->phys,
 				 tx_buf->size, DMA_TO_DEVICE);
-		if (!tx_buf->skb)
-			continue;
-		dev_kfree_skb_any(tx_buf->skb);
+		if (tx_buf->skb)
+			dev_kfree_skb_any(tx_buf->skb);
+
+		mvpp2_txq_inc_get(txq_pcpu);
 	}
 }
 
-- 
2.7.4
