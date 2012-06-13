From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/3] net: lpc_eth: Replace WARN() trace with simple
 pr_warn()
Date: Wed, 13 Jun 2012 08:16:12 +0200
Message-ID: <1339568172.22704.312.camel@edumazet-glaptop>
References: <1339401793-12258-1-git-send-email-stigge@antcom.de>
	 <1339403108.6001.1697.camel@edumazet-glaptop> <4FD5AE1D.9030807@antcom.de>
	 <20120611.020352.1962768244524496467.davem@davemloft.net>
	 <4FD5B9C8.4020800@antcom.de>  <1339442328.6001.2602.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kevin.wells@nxp.com,
	srinivas.bakki@nxp.com, aletes.xgr@gmail.com,
	linux-arm-kernel@lists.infradead.org
To: Roland Stigge <stigge@antcom.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1339442328.6001.2602.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-06-11 at 21:18 +0200, Eric Dumazet wrote:
> On Mon, 2012-06-11 at 11:26 +0200, Roland Stigge wrote:
> 
> > Is it sensible at this point to increase the TX buffers anyway? For
> > different reasons of course: We have enough SRAM available and TX
> > buffers (16->32) are still more than RX buffers (48).
> 
> I doubt it has any impact on performance for a 100Mbit link ?
> 
> One thing that could be done would be to free skbs in
> lpc_eth_hard_start_xmit() instead of __lpc_handle_xmit()
> 

Here is the patch I was thinking about

(on top of latest net-next)

Could you please test it ?

 drivers/net/ethernet/nxp/lpc_eth.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index 083d671..426f14c 100644
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
@@ -908,7 +908,7 @@ static void __lpc_handle_xmit(struct net_device *ndev)
 
 	txcidx = readl(LPC_ENET_TXCONSUMEINDEX(pldat->net_base));
 	while (pldat->last_tx_idx != txcidx) {
-		skb = pldat->skb[pldat->last_tx_idx];
+		unsigned int skblen = pldat->skblen[pldat->last_tx_idx];
 
 		/* A buffer is available, get buffer status */
 		ptxstat = &pldat->tx_stat_v[pldat->last_tx_idx];
@@ -945,9 +945,8 @@ static void __lpc_handle_xmit(struct net_device *ndev)
 		} else {
 			/* Update stats */
 			ndev->stats.tx_packets++;
-			ndev->stats.tx_bytes += skb->len;
+			ndev->stats.tx_bytes += skblen;
 		}
-		dev_kfree_skb_irq(skb);
 
 		txcidx = readl(LPC_ENET_TXCONSUMEINDEX(pldat->net_base));
 	}
@@ -1132,7 +1131,7 @@ static int lpc_eth_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	memcpy(pldat->tx_buff_v + txidx * ENET_MAXF_SIZE, skb->data, len);
 
 	/* Save the buffer and increment the buffer counter */
-	pldat->skb[txidx] = skb;
+	pldat->skblen[txidx] = len;
 	pldat->num_used_tx_buffs++;
 
 	/* Start transmit */
@@ -1147,6 +1146,7 @@ static int lpc_eth_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	spin_unlock_irq(&pldat->lock);
 
+	dev_kfree_skb(skb);
 	return NETDEV_TX_OK;
 }
 
