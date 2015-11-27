From: Marcin Wojtas <mw@semihalf.com>
Subject: [PATCH v3 net 4/6] net: mvneta: fix error path for building skb
Date: Fri, 27 Nov 2015 16:44:24 +0100
Message-ID: <1448639066-13074-5-git-send-email-mw@semihalf.com>
References: <1448639066-13074-1-git-send-email-mw@semihalf.com>
Cc: davem@davemloft.net, linux@arm.linux.org.uk,
	sebastian.hesselbarth@gmail.com, andrew@lunn.ch,
	jason@lakedaemon.net, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, simon.guinot@sequanux.org,
	nadavh@marvell.com, alior@marvell.com, xswang@marvell.com,
	myair@marvell.com, nitroshift@yahoo.com, mw@semihalf.com,
	jaz@semihalf.com, tn@semihalf.com, <stable@vger.kernel.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448639066-13074-1-git-send-email-mw@semihalf.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the actual RX processing, there is same error path for both descriptor
ring refilling and building skb fails. This is not correct, because after
successful refill, the ring is already updated with newly allocated
buffer. Then, in case of build_skb() fail, hitherto code left the original
buffer unmapped.

This patch fixes above situation by swapping error check of skb build with
DMA-unmap of original buffer.

Signed-off-by: Marcin Wojtas <mw@semihalf.com>
Acked-by: Simon Guinot <simon.guinot@sequanux.org>
Cc: <stable@vger.kernel.org> # v4.2+
Fixes a84e32894191 ("net: mvneta: fix refilling for Rx DMA buffers")
---
 drivers/net/ethernet/marvell/mvneta.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 5dffb68..5a98c5d 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1580,12 +1580,16 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 		}
 
 		skb = build_skb(data, pp->frag_size > PAGE_SIZE ? 0 : pp->frag_size);
-		if (!skb)
-			goto err_drop_frame;
 
+		/* After refill old buffer has to be unmapped regardless
+		 * the skb is successfully built or not.
+		 */
 		dma_unmap_single(dev->dev.parent, phys_addr,
 				 MVNETA_RX_BUF_SIZE(pp->pkt_size), DMA_FROM_DEVICE);
 
+		if (!skb)
+			goto err_drop_frame;
+
 		rcvd_pkts++;
 		rcvd_bytes += rx_bytes;
 
-- 
1.8.3.1
