From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH v2] net: fec: Fix the disabling of RX interrupt
Date: Tue, 19 Feb 2013 09:54:16 +0800
Message-ID: <CAHrpEqRpjQuADCzXyF4+Q359TjovXDdNJaurGKin0-0Ta2+kZg@mail.gmail.com>
References: <1361217895-17143-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, Frank.Li@freescale.com, shawn.guo@linaro.org,
	marex@denx.de, s.hauer@pengutronix.de, netdev@vger.kernel.org
To: Fabio Estevam <fabio.estevam@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:39871 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757869Ab3BSByS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 20:54:18 -0500
Received: by mail-we0-f169.google.com with SMTP id t11so5493322wey.28
        for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 17:54:16 -0800 (PST)
In-Reply-To: <1361217895-17143-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/2/19 Fabio Estevam <fabio.estevam@freescale.com>:
> The correct way to disable FEC RX interrupt is to clean only the FEC_ENET_RXF
> bit.
>
> Since commit dc975382d2e (net: fec: add napi support to improve proformance)
> FEC_RX_DISABLED_IMASK is being written to the FEC_IMASK register, which also
> incorrectly sets other bits as per the definitions below:
>
> #define FEC_DEFAULT_IMASK (FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MII)
> #define FEC_RX_DISABLED_IMASK (FEC_DEFAULT_IMASK & (~FEC_ENET_RXF))
>
> This fixes the following kernel crash:
>
> Unable to handle kernel NULL pointer dereference at virtual address 00000002
> pgd = 80004000
> [00000002] *pgd=00000000
> Internal error: Oops: 5 [#1] SMP ARM
> Modules linked in:
> CPU: 0    Not tainted  (3.8.0-rc7-next-20130218+ #1192)
> PC is at fec_enet_interrupt+0xd0/0x354
> LR is at fec_enet_interrupt+0xb8/0x354
> pc : [<8034592c>]    lr : [<80345914>]    psr: 60000193
>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
> ---
> Changes since v1:
> - Fix it also inside fec_enet_init and fix the kernel crash.
>
>  drivers/net/ethernet/freescale/fec.c |   13 +++++++++----
>  1 file changed, 9 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
> index 0fe68c4..4eb0201 100644
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -811,6 +811,7 @@ fec_enet_interrupt(int irq, void *dev_id)
>         struct fec_enet_private *fep = netdev_priv(ndev);
>         uint int_events;
>         irqreturn_t ret = IRQ_NONE;
> +       int reg;
>
>         do {
>                 int_events = readl(fep->hwp + FEC_IEVENT);
> @@ -821,8 +822,9 @@ fec_enet_interrupt(int irq, void *dev_id)
>
>                         /* Disable the RX interrupt */
>                         if (napi_schedule_prep(&fep->napi)) {
> -                               writel(FEC_RX_DISABLED_IMASK,
> -                                       fep->hwp + FEC_IMASK);
> +                               reg = readl(fep->hwp + FEC_IMASK);
> +                               reg &= ~FEC_ENET_RXF;
> +                               writel(reg, fep->hwp + FEC_IMASK);


This is not correct fix.
Read, OR and write is not atomic. Need lock.
But if use hw_lock, it cause dead lock.
I spend some time to remove such lock.

Can you tell which bit cause crash?

>                                 __napi_schedule(&fep->napi);
>                         }
>                 }
> @@ -1598,7 +1600,7 @@ static int fec_enet_init(struct net_device *ndev)
>         struct fec_enet_private *fep = netdev_priv(ndev);
>         struct bufdesc *cbd_base;
>         struct bufdesc *bdp;
> -       int i;
> +       int i, reg;
>
>         /* Allocate memory for buffer descriptors. */
>         cbd_base = dma_alloc_coherent(NULL, PAGE_SIZE, &fep->bd_dma,
> @@ -1628,7 +1630,10 @@ static int fec_enet_init(struct net_device *ndev)
>         ndev->netdev_ops = &fec_netdev_ops;
>         ndev->ethtool_ops = &fec_enet_ethtool_ops;
>
> -       writel(FEC_RX_DISABLED_IMASK, fep->hwp + FEC_IMASK);
> +       reg = readl(fep->hwp + FEC_IMASK);
> +       reg &= ~FEC_ENET_RXF;
> +       writel(reg, fep->hwp + FEC_IMASK);
> +
>         netif_napi_add(ndev, &fep->napi, fec_enet_rx_napi, FEC_NAPI_WEIGHT);
>
>         /* Initialize the receive buffer descriptors. */
> --
> 1.7.9.5
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
