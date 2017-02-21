From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv4 net-next 05/13] net: mvpp2: release reference to txq_cpu[] entry after unmapping
Date: Tue, 21 Feb 2017 11:28:05 +0100
Message-ID: <1487672893-5746-6-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1487672893-5746-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@arm.linux.org.uk>,
        Stefan Chulski <stefanc@marvell.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:49553 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751951AbdBUK3F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 05:29:05 -0500
In-Reply-To: <1487672893-5746-1-git-send-email-thomas.petazzoni@free-electrons.com>
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
Acked-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/ethernet/marvell/mvpp2.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 6fe1520..b98c668d 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -4437,13 +4437,12 @@ static void mvpp2_txq_bufs_free(struct mvpp2_port *port,
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
