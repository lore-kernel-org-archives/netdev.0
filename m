From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net 1/4] sh_eth: Fix padding of short frames on TX
Date: Thu, 22 Jan 2015 12:40:13 +0000
Message-ID: <1421930413.1222.286.camel@xylophone.i.decadent.org.uk>
References: <1421930284.1222.285.camel@xylophone.i.decadent.org.uk>
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
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:40575 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752061AbbAVMkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 07:40:14 -0500
In-Reply-To: <1421930284.1222.285.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an skb to be transmitted is shorter than the minimum Ethernet frame
length, we currently set the DMA descriptor length to the minimum but
do not add zero-padding.  This could result in leaking sensitive
data.  We also pass different lengths to dma_map_single() and
dma_unmap_single().

Use skb_padto() to pad properly, before calling dma_map_single().

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 drivers/net/ethernet/renesas/sh_eth.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 28e3822..69f9fff 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2117,6 +2117,9 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	}
 	spin_unlock_irqrestore(&mdp->lock, flags);
 
+	if (skb_padto(skb, ETH_ZLEN))
+		return NETDEV_TX_OK;
+
 	entry = mdp->cur_tx % mdp->num_tx_ring;
 	mdp->tx_skbuff[entry] = skb;
 	txdesc = &mdp->tx_ring[entry];
@@ -2126,10 +2129,7 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 				 skb->len + 2);
 	txdesc->addr = dma_map_single(&ndev->dev, skb->data, skb->len,
 				      DMA_TO_DEVICE);
-	if (skb->len < ETH_ZLEN)
-		txdesc->buffer_length = ETH_ZLEN;
-	else
-		txdesc->buffer_length = skb->len;
+	txdesc->buffer_length = skb->len;
 
 	if (entry >= mdp->num_tx_ring - 1)
 		txdesc->status |= cpu_to_edmac(mdp, TD_TACT | TD_TDLE);
-- 
1.7.10.4
