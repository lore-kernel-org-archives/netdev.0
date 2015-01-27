From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH kernel 3/4] sh_eth: Check for DMA mapping errors on transmit
Date: Tue, 27 Jan 2015 00:49:47 +0000
Message-ID: <1422319787.3524.23.camel@xylophone.i.decadent.org.uk>
References: <1422319232.3524.14.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>
To: "David S.Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:50195 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754414AbbA0Atr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 19:49:47 -0500
In-Reply-To: <1422319232.3524.14.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dma_map_single() may fail if an IOMMU or swiotlb is in use, so
we need to check for this.

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 drivers/net/ethernet/renesas/sh_eth.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index e43c9ce..48610ed 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2174,6 +2174,10 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 				 skb->len + 2);
 	txdesc->addr = dma_map_single(&ndev->dev, skb->data, skb->len,
 				      DMA_TO_DEVICE);
+	if (dma_mapping_error(&ndev->dev, txdesc->addr)) {
+		kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
 	txdesc->buffer_length = skb->len;
 
 	if (entry >= mdp->num_tx_ring - 1)
-- 
1.7.10.4
