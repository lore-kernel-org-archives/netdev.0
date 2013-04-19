From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH 0/3] URGENT for 3.9: net: fec: revert NAPI introduction
Date: Fri, 19 Apr 2013 17:05:56 -0300
Message-ID: <CAOMZO5D5+bZ9NvF7HvVsne1ktZDDYPqZgomHkSaydrn2UEvBcQ@mail.gmail.com>
References: <1366382164-10968-1-git-send-email-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: Lucas Stach <l.stach@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f182.google.com ([209.85.220.182]:35152 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753980Ab3DSUF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 16:05:57 -0400
Received: by mail-vc0-f182.google.com with SMTP id ht11so2079766vcb.13
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 13:05:57 -0700 (PDT)
In-Reply-To: <1366382164-10968-1-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lucas,

On Fri, Apr 19, 2013 at 11:36 AM, Lucas Stach <l.stach@pengutronix.de> wrote:
> Those patches introduce instability to the point of kernel OOPSes with
> NULL-ptr dereferences.
>
> The patches drop locks from the code without justifying why this would
> be safe at all. In fact it isn't safe as now the controller restart can
> happily free the RX and TX ring buffers while the NAPI poll function is
> still accessing them. So with a heavily loaded but slightly instable
> link we regularly end up with OOPSes because link change restarts
> the FEC and bombs away buffers still in use.
>
> Also the NAPI enabled interrupt handler ACKs the INT and only later
> masks it, this way introducing a window where new interrupts could sneak
> in while we are already in polling mode.
>
> As it's way too late in the cycle to try and fix this up just revert the
> relevant patches for now.

What about restoring the spinlocks and masking the int first?

--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -247,12 +247,14 @@ fec_enet_start_xmit(struct sk_buff *skb, struct
net_device *ndev)
        void *bufaddr;
        unsigned short  status;
        unsigned int index;
+       unsigned long flags;

        if (!fep->link) {
                /* Link is down or autonegotiation is in progress. */
                return NETDEV_TX_BUSY;
        }

+       spin_lock_irqsave(&fep->hw_lock, flags);
        /* Fill in a Tx ring entry */
        bdp = fep->cur_tx;

@@ -263,6 +265,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct
net_device *ndev)
                 * This should not happen, since ndev->tbusy should be set.
                 */
                printk("%s: tx queue full!.\n", ndev->name);
+               spin_unlock_irqrestore(&fep->hw_lock, flags);
                return NETDEV_TX_BUSY;
        }

@@ -342,6 +345,8 @@ fec_enet_start_xmit(struct sk_buff *skb, struct
net_device *ndev)

        skb_tx_timestamp(skb);

+       spin_unlock_irqrestore(&fep->hw_lock, flags);
+
        return NETDEV_TX_OK;
 }

@@ -612,6 +617,7 @@ fec_enet_tx(struct net_device *ndev)
        int     index = 0;

        fep = netdev_priv(ndev);
+       spin_lock(&fep->hw_lock);
        bdp = fep->dirty_tx;

        /* get next bdp of dirty_tx */
@@ -699,6 +705,7 @@ fec_enet_tx(struct net_device *ndev)
                                netif_wake_queue(ndev);
                }
        }
+       spin_unlock(&fep->hw_lock);
        return;
 }

@@ -892,12 +899,12 @@ static int fec_enet_rx_napi(struct napi_struct
*napi, int budget)
        int pkts = fec_enet_rx(ndev, budget);
        struct fec_enet_private *fep = netdev_priv(ndev);

-       fec_enet_tx(ndev);
-
        if (pkts < budget) {
                napi_complete(napi);
                writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
        }
+
+       fec_enet_tx(ndev);
        return pkts;
 }
