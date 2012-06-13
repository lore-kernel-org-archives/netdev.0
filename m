From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: lpc_eth: free skbs in start_xmit
Date: Wed, 13 Jun 2012 11:58:16 +0200
Message-ID: <1339581496.22704.346.camel@edumazet-glaptop>
References: <1339401793-12258-1-git-send-email-stigge@antcom.de>
	 <1339403108.6001.1697.camel@edumazet-glaptop> <4FD5AE1D.9030807@antcom.de>
	 <20120611.020352.1962768244524496467.davem@davemloft.net>
	 <4FD5B9C8.4020800@antcom.de> <1339442328.6001.2602.camel@edumazet-glaptop>
	 <1339568172.22704.312.camel@edumazet-glaptop>  <4FD85D27.5090509@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kevin.wells@nxp.com, srinivas.bakki@nxp.com, aletes.xgr@gmail.com,
	linux-arm-kernel@lists.infradead.org
To: Roland Stigge <stigge@antcom.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:63123 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730Ab2FMJ6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 05:58:25 -0400
Received: by eaak11 with SMTP id k11so119220eaa.19
        for <netdev@vger.kernel.org>; Wed, 13 Jun 2012 02:58:24 -0700 (PDT)
In-Reply-To: <4FD85D27.5090509@antcom.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Transmitted skbs can be freed immediately in lpc_eth_hard_start_xmit()
instead of at TX completion, since driver copies the frames in DMA area.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Tested-by: Roland Stigge <stigge@antcom.de>
---
 drivers/net/ethernet/nxp/lpc_eth.c |   11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index 083d671..028dde4 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -440,7 +440,7 @@ struct netdata_local {
 	spinlock_t		lock;
 	void __iomem		*net_base;
 	u32			msg_enable;
-	struct sk_buff		*skb[ENET_TX_DESC];
+	unsigned int		skblen[ENET_TX_DESC];
 	unsigned int		last_tx_idx;
 	unsigned int		num_used_tx_buffs;
 	struct mii_bus		*mii_bus;
@@ -903,12 +903,11 @@ err_out:
 static void __lpc_handle_xmit(struct net_device *ndev)
 {
 	struct netdata_local *pldat = netdev_priv(ndev);
-	struct sk_buff *skb;
 	u32 txcidx, *ptxstat, txstat;
 
 	txcidx = readl(LPC_ENET_TXCONSUMEINDEX(pldat->net_base));
 	while (pldat->last_tx_idx != txcidx) {
-		skb = pldat->skb[pldat->last_tx_idx];
+		unsigned int skblen = pldat->skblen[pldat->last_tx_idx];
 
 		/* A buffer is available, get buffer status */
 		ptxstat = &pldat->tx_stat_v[pldat->last_tx_idx];
@@ -945,9 +944,8 @@ static void __lpc_handle_xmit(struct net_device *ndev)
 		} else {
 			/* Update stats */
 			ndev->stats.tx_packets++;
-			ndev->stats.tx_bytes += skb->len;
+			ndev->stats.tx_bytes += skblen;
 		}
-		dev_kfree_skb_irq(skb);
 
 		txcidx = readl(LPC_ENET_TXCONSUMEINDEX(pldat->net_base));
 	}
@@ -1132,7 +1130,7 @@ static int lpc_eth_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	memcpy(pldat->tx_buff_v + txidx * ENET_MAXF_SIZE, skb->data, len);
 
 	/* Save the buffer and increment the buffer counter */
-	pldat->skb[txidx] = skb;
+	pldat->skblen[txidx] = len;
 	pldat->num_used_tx_buffs++;
 
 	/* Start transmit */
@@ -1147,6 +1145,7 @@ static int lpc_eth_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	spin_unlock_irq(&pldat->lock);
 
+	dev_kfree_skb(skb);
 	return NETDEV_TX_OK;
 }
 
