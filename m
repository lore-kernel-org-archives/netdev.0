From: Lucas Stach <l.stach@pengutronix.de>
Subject: Re: [PATCH 0/3] URGENT for 3.9: net: fec: revert NAPI introduction
Date: Thu, 25 Apr 2013 14:37:05 +0200
Message-ID: <1366893425.4139.10.camel@weser.hi.pengutronix.de>
References: <1366382164-10968-1-git-send-email-l.stach@pengutronix.de>
	 <CAOMZO5D5+bZ9NvF7HvVsne1ktZDDYPqZgomHkSaydrn2UEvBcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34444 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756257Ab3DYMiM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 08:38:12 -0400
In-Reply-To: <CAOMZO5D5+bZ9NvF7HvVsne1ktZDDYPqZgomHkSaydrn2UEvBcQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, den 19.04.2013, 17:05 -0300 schrieb Fabio Estevam:
> Lucas,
> 
> On Fri, Apr 19, 2013 at 11:36 AM, Lucas Stach <l.stach@pengutronix.de> wrote:
> > Those patches introduce instability to the point of kernel OOPSes with
> > NULL-ptr dereferences.
> >
> > The patches drop locks from the code without justifying why this would
> > be safe at all. In fact it isn't safe as now the controller restart can
> > happily free the RX and TX ring buffers while the NAPI poll function is
> > still accessing them. So with a heavily loaded but slightly instable
> > link we regularly end up with OOPSes because link change restarts
> > the FEC and bombs away buffers still in use.
> >
> > Also the NAPI enabled interrupt handler ACKs the INT and only later
> > masks it, this way introducing a window where new interrupts could sneak
> > in while we are already in polling mode.
> >
> > As it's way too late in the cycle to try and fix this up just revert the
> > relevant patches for now.
> 
> What about restoring the spinlocks and masking the int first?
> 
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -247,12 +247,14 @@ fec_enet_start_xmit(struct sk_buff *skb, struct
> net_device *ndev)
>         void *bufaddr;
>         unsigned short  status;
>         unsigned int index;
> +       unsigned long flags;
> 
>         if (!fep->link) {
>                 /* Link is down or autonegotiation is in progress. */
>                 return NETDEV_TX_BUSY;
>         }
> 
> +       spin_lock_irqsave(&fep->hw_lock, flags);
>         /* Fill in a Tx ring entry */
>         bdp = fep->cur_tx;
> 
> @@ -263,6 +265,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct
> net_device *ndev)
>                  * This should not happen, since ndev->tbusy should be set.
>                  */
>                 printk("%s: tx queue full!.\n", ndev->name);
> +               spin_unlock_irqrestore(&fep->hw_lock, flags);
>                 return NETDEV_TX_BUSY;
>         }
> 
> @@ -342,6 +345,8 @@ fec_enet_start_xmit(struct sk_buff *skb, struct
> net_device *ndev)
> 
>         skb_tx_timestamp(skb);
> 
> +       spin_unlock_irqrestore(&fep->hw_lock, flags);
> +
>         return NETDEV_TX_OK;
>  }
> 
> @@ -612,6 +617,7 @@ fec_enet_tx(struct net_device *ndev)
>         int     index = 0;
> 
>         fep = netdev_priv(ndev);
> +       spin_lock(&fep->hw_lock);
>         bdp = fep->dirty_tx;
> 
>         /* get next bdp of dirty_tx */
> @@ -699,6 +705,7 @@ fec_enet_tx(struct net_device *ndev)
>                                 netif_wake_queue(ndev);
>                 }
>         }
> +       spin_unlock(&fep->hw_lock);
>         return;
>  }
> 
> @@ -892,12 +899,12 @@ static int fec_enet_rx_napi(struct napi_struct
> *napi, int budget)
>         int pkts = fec_enet_rx(ndev, budget);
>         struct fec_enet_private *fep = netdev_priv(ndev);
> 
> -       fec_enet_tx(ndev);
> -
>         if (pkts < budget) {
>                 napi_complete(napi);
>                 writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
>         }
> +
> +       fec_enet_tx(ndev);
>         return pkts;
>  }

This change isn't enough to fix the kernel OOPSes. The RX function is
also operating on the same buffers, but simply adding back the locks
there doesn't fix all the failures I'm seeing.

Regards,
Lucas
-- 
Pengutronix e.K.                           | Lucas Stach                 |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-5076 |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
