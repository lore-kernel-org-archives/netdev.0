From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH v2] net: fec: Fix the disabling of RX interrupt
Date: Tue, 19 Feb 2013 10:47:57 +0800
Message-ID: <CAHrpEqQ-hoR1W2w8QXP4zF=9C6dDv2juWzq9dzHjKZ+emdbK1g@mail.gmail.com>
References: <1361217895-17143-1-git-send-email-fabio.estevam@freescale.com>
	<CAHrpEqRpjQuADCzXyF4+Q359TjovXDdNJaurGKin0-0Ta2+kZg@mail.gmail.com>
	<CAOMZO5CRQeuF_ERZ0v2uocuADXRWscKLN0KqdDHfu+0Ub2MEhw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Fabio Estevam <fabio.estevam@freescale.com>, davem@davemloft.net,
	Frank.Li@freescale.com, shawn.guo@linaro.org, marex@denx.de,
	s.hauer@pengutronix.de, netdev@vger.kernel.org
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:51224 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757557Ab3BSCr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 21:47:59 -0500
Received: by mail-wi0-f177.google.com with SMTP id hm14so4268140wib.16
        for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 18:47:58 -0800 (PST)
In-Reply-To: <CAOMZO5CRQeuF_ERZ0v2uocuADXRWscKLN0KqdDHfu+0Ub2MEhw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/2/19 Fabio Estevam <festevam@gmail.com>:
> On Mon, Feb 18, 2013 at 10:54 PM, Frank Li <lznuaa@gmail.com> wrote:
>
>> This is not correct fix.
>> Read, OR and write is not atomic. Need lock.
>> But if use hw_lock, it cause dead lock.
>> I spend some time to remove such lock.
>
> Ok, could you please try the patch below? It avoids the kernel crash
> on my mx53qsb:

This is similar with my first implement.
It just protect irq and init function. Many place write FEC_IMASK directly.

>
>  drivers/net/ethernet/freescale/fec.c |   23 ++++++++++++++++++++---
>  1 file changed, 20 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/freescale/fec.c
> b/drivers/net/ethernet/freescale/fec.c
> index 0fe68c4..4df6518 100644
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -804,6 +804,24 @@ rx_processing_done:
>         return pkt_received;
>  }
>
> +static void fec_control_rx(struct net_device *ndev, bool enable)
> +{
> +       struct fec_enet_private *fep = netdev_priv(ndev);
> +       int reg;
> +       unsigned long flags;
> +
> +       spin_lock_irqsave(&fep->hw_lock, flags);
> +       reg = readl(fep->hwp + FEC_IMASK);
> +       if (enable)
> +               reg |= FEC_ENET_RXF;
> +       else
> +               reg &= ~FEC_ENET_RXF;
> +
> +       writel(reg, fep->hwp + FEC_IMASK);
> +
> +       spin_unlock_irqrestore(&fep->hw_lock, flags);
> +}
> +
>  static irqreturn_t
>  fec_enet_interrupt(int irq, void *dev_id)
>  {
> @@ -821,8 +839,7 @@ fec_enet_interrupt(int irq, void *dev_id)
>
>                         /* Disable the RX interrupt */
>                         if (napi_schedule_prep(&fep->napi)) {
> -                               writel(FEC_RX_DISABLED_IMASK,
> -                                       fep->hwp + FEC_IMASK);
> +                               fec_control_rx(ndev, false);
>                                 __napi_schedule(&fep->napi);
>                         }
>                 }
> @@ -1628,7 +1645,7 @@ static int fec_enet_init(struct net_device *ndev)
>         ndev->netdev_ops = &fec_netdev_ops;
>         ndev->ethtool_ops = &fec_enet_ethtool_ops;
>
> -       writel(FEC_RX_DISABLED_IMASK, fep->hwp + FEC_IMASK);
> +       fec_control_rx(ndev, false);

I think this issue was caused by enable irq before register irq handler.
writel(0, fep->hwp + FEC_IMASK) should fix mx53's problem.

best regards
Frank Li

>         netif_napi_add(ndev, &fep->napi, fec_enet_rx_napi, FEC_NAPI_WEIGHT);
>
>         /* Initialize the receive buffer descriptors. */
> --
> 1.7.9.5
