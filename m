From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/3] net: lpc_eth: Replace WARN() trace with simple
 pr_warn()
Date: Mon, 11 Jun 2012 10:39:16 +0200
Message-ID: <1339403956.6001.1731.camel@edumazet-glaptop>
References: <1339401793-12258-1-git-send-email-stigge@antcom.de>
	 <1339403108.6001.1697.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kevin.wells@nxp.com,
	srinivas.bakki@nxp.com, aletes.xgr@gmail.com,
	linux-arm-kernel@lists.infradead.org
To: Roland Stigge <stigge@antcom.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1339403108.6001.1697.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-06-11 at 10:25 +0200, Eric Dumazet wrote:
> On Mon, 2012-06-11 at 10:03 +0200, Roland Stigge wrote:
> > A WARN() trace indicating a "BUG!" was identified as a "normal" case in the
> > xmit function in case all TX descriptors are occupied already. In this case,
> > NETDEV_TX_BUSY is returned, nothing buggy at all.
> > 
> > Signed-off-by: Roland Stigge <stigge@antcom.de>
> > Tested-by: Alexandre Pereira da Silva <aletes.xgr@gmail.com>
> > 
> > ---
> >  drivers/net/ethernet/nxp/lpc_eth.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > --- linux-2.6.orig/drivers/net/ethernet/nxp/lpc_eth.c
> > +++ linux-2.6/drivers/net/ethernet/nxp/lpc_eth.c
> > @@ -1114,7 +1114,7 @@ static int lpc_eth_hard_start_xmit(struc
> >  		   buffers */
> >  		netif_stop_queue(ndev);
> >  		spin_unlock_irq(&pldat->lock);
> > -		WARN(1, "BUG! TX request when no free TX buffers!\n");
> > +		pr_warn("Note: TX request when no free TX buffers.\n");
> >  		return NETDEV_TX_BUSY;
> >  	}
> >  
> 
> Entering this path is a bug, don't hide it...
> 
> Please share with us how this bug was identified as a "normal case" ?
> 
> 


There is an skb leak in this driver, maybe it's the real problem.

diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index 8d2666f..0d0f4cb 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -946,10 +946,8 @@ static void __lpc_handle_xmit(struct net_device *ndev)
 			/* Update stats */
 			ndev->stats.tx_packets++;
 			ndev->stats.tx_bytes += skb->len;
-
-			/* Free buffer */
-			dev_kfree_skb_irq(skb);
 		}
+		dev_kfree_skb_irq(skb);
 
 		txcidx = readl(LPC_ENET_TXCONSUMEINDEX(pldat->net_base));
 	}
