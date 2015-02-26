From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net 1/4] sh_eth: Ensure proper ordering of descriptor active
 bit write/read
Date: Thu, 26 Feb 2015 14:13:30 +0000
Message-ID: <1424960010.4444.13.camel@xylophone.i.decadent.org.uk>
References: <1424959937.4444.12.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:34630 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932386AbbBZONh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 09:13:37 -0500
In-Reply-To: <1424959937.4444.12.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When submitting a DMA descriptor, the active bit must be written last.
When reading a completed DMA descriptor, the active bit must be read
first.

Add memory barriers to ensure that this ordering is maintained.

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
This is based on review only - I don't have a test case to show
problematic reordering.

Ben.

 drivers/net/ethernet/renesas/sh_eth.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 4da8bd263997..2bc0be45c751 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1407,6 +1407,8 @@ static int sh_eth_txfree(struct net_device *ndev)
 		txdesc = &mdp->tx_ring[entry];
 		if (txdesc->status & cpu_to_edmac(mdp, TD_TACT))
 			break;
+		/* TACT bit must be checked before all the following reads */
+		rmb();
 		/* Free the original skb. */
 		if (mdp->tx_skbuff[entry]) {
 			dma_unmap_single(&ndev->dev, txdesc->addr,
@@ -1444,6 +1446,8 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
 	limit = boguscnt;
 	rxdesc = &mdp->rx_ring[entry];
 	while (!(rxdesc->status & cpu_to_edmac(mdp, RD_RACT))) {
+		/* RACT bit must be checked before all the following reads */
+		rmb();
 		desc_status = edmac_to_cpu(mdp, rxdesc->status);
 		pkt_len = rxdesc->frame_length;
 
@@ -1523,6 +1527,7 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
 			skb_checksum_none_assert(skb);
 			rxdesc->addr = dma_addr;
 		}
+		wmb(); /* RACT bit must be set after all the above writes */
 		if (entry >= mdp->num_rx_ring - 1)
 			rxdesc->status |=
 				cpu_to_edmac(mdp, RD_RACT | RD_RFP | RD_RDEL);
@@ -2192,6 +2197,7 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	}
 	txdesc->buffer_length = skb->len;
 
+	wmb(); /* TACT bit must be set after all the above writes */
 	if (entry >= mdp->num_tx_ring - 1)
 		txdesc->status |= cpu_to_edmac(mdp, TD_TACT | TD_TDLE);
 	else
-- 
1.7.10.4
