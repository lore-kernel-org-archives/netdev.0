From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv4 net-next 01/13] net: mvpp2: fix DMA address calculation in mvpp2_txq_inc_put()
Date: Tue, 21 Feb 2017 11:28:01 +0100
Message-ID: <1487672893-5746-2-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1487672893-5746-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@arm.linux.org.uk>,
        Stefan Chulski <stefanc@marvell.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        stable@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1487672893-5746-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When TX descriptors are filled in, the buffer DMA address is split
between the tx_desc->buf_phys_addr field (high-order bits) and
tx_desc->packet_offset field (5 low-order bits).

However, when we re-calculate the DMA address from the TX descriptor in
mvpp2_txq_inc_put(), we do not take tx_desc->packet_offset into
account. This means that when the DMA address is not aligned on a 32
bytes boundary, we end up calling dma_unmap_single() with a DMA address
that was not the one returned by dma_map_single().

This inconsistency is detected by the kernel when DMA_API_DEBUG is
enabled. We fix this problem by properly calculating the DMA address in
mvpp2_txq_inc_put().

Cc: <stable@vger.kernel.org>
Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 4fe430c..5f1f23e 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -991,7 +991,7 @@ static void mvpp2_txq_inc_put(struct mvpp2_txq_pcpu *txq_pcpu,
 		txq_pcpu->buffs + txq_pcpu->txq_put_index;
 	tx_buf->skb = skb;
 	tx_buf->size = tx_desc->data_size;
-	tx_buf->phys = tx_desc->buf_phys_addr;
+	tx_buf->phys = tx_desc->buf_phys_addr + tx_desc->packet_offset;
 	txq_pcpu->txq_put_index++;
 	if (txq_pcpu->txq_put_index == txq_pcpu->size)
 		txq_pcpu->txq_put_index = 0;
-- 
2.7.4
