From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2] sh_eth: use DMA barriers
Date: Tue, 03 Nov 2015 22:36:04 +0300
Message-ID: <1753153.kv41W3qdJQ@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit  7d7355f58ba4 ("sh_eth: Ensure proper ordering of descriptor active
bit write/read") did the right thing  but used too "heavy" barriers while
there were already "lighter" DMA barriers exactly  for this case...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against DaveM's 'net-next.git' repo.

Changes in version 2:
- fixed the subject.

 drivers/net/ethernet/renesas/sh_eth.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -1416,7 +1416,7 @@ static int sh_eth_txfree(struct net_devi
 		if (txdesc->status & cpu_to_edmac(mdp, TD_TACT))
 			break;
 		/* TACT bit must be checked before all the following reads */
-		rmb();
+		dma_rmb();
 		netif_info(mdp, tx_done, ndev,
 			   "tx entry %d status 0x%08x\n",
 			   entry, edmac_to_cpu(mdp, txdesc->status));
@@ -1458,7 +1458,7 @@ static int sh_eth_rx(struct net_device *
 	rxdesc = &mdp->rx_ring[entry];
 	while (!(rxdesc->status & cpu_to_edmac(mdp, RD_RACT))) {
 		/* RACT bit must be checked before all the following reads */
-		rmb();
+		dma_rmb();
 		desc_status = edmac_to_cpu(mdp, rxdesc->status);
 		pkt_len = rxdesc->frame_length;
 
@@ -1544,7 +1544,7 @@ static int sh_eth_rx(struct net_device *
 			skb_checksum_none_assert(skb);
 			rxdesc->addr = dma_addr;
 		}
-		wmb(); /* RACT bit must be set after all the above writes */
+		dma_wmb(); /* RACT bit must be set after all the above writes */
 		if (entry >= mdp->num_rx_ring - 1)
 			rxdesc->status |=
 				cpu_to_edmac(mdp, RD_RACT | RD_RFP | RD_RDLE);
@@ -2403,7 +2403,7 @@ static int sh_eth_start_xmit(struct sk_b
 	}
 	txdesc->buffer_length = skb->len;
 
-	wmb(); /* TACT bit must be set after all the above writes */
+	dma_wmb(); /* TACT bit must be set after all the above writes */
 	if (entry >= mdp->num_tx_ring - 1)
 		txdesc->status |= cpu_to_edmac(mdp, TD_TACT | TD_TDLE);
 	else
