From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH] net/ucc_geth: some fix in current kernel
Date: Tue, 27 Dec 2011 11:56:56 +0100
Message-ID: <OFE977DF81.E05CFE1D-ONC1257973.003BC833-C1257973.003C2506@transmode.se>
References: <y> <1324979328-32081-1-git-send-email-X.Xie@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: leoli@freescale.com, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
To: Xie Xiaobo <X.Xie@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:53540 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751422Ab1L0LDP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Dec 2011 06:03:15 -0500
In-Reply-To: <1324979328-32081-1-git-send-email-X.Xie@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> * Revert commit "ucc_geth: Fix hangs after switching from full to half duplex"
>   This commit impacted the driver in all link state change more than
>   duplex change.

hmm, so what will happen now when switching from full to half duplex? Will it just hang? If so
that doesn't seem like an improvement.

> * Change some parameters.
>   Increased the BD ring length.

Increasing both TX and RX from 16 to 64 seems a bit much. I got away with
just increasing RX to 32. What memory are the BD ring using, the internal or external RAM?

 Jocke

>
> Signed-off-by: Haiying Wang <Haiying.Wang@freescale.com>
> Signed-off-by: Xie Xiaobo <X.Xie@freescale.com>
> ---
>  drivers/net/ethernet/freescale/ucc_geth.c |   41 ++++------------------------
>  drivers/net/ethernet/freescale/ucc_geth.h |    6 ++--
>  2 files changed, 9 insertions(+), 38 deletions(-)
>
> diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
> index b5dc027..3e18902 100644
> --- a/drivers/net/ethernet/freescale/ucc_geth.c
> +++ b/drivers/net/ethernet/freescale/ucc_geth.c
> @@ -1,5 +1,5 @@
>  /*
> - * Copyright (C) 2006-2009 Freescale Semicondutor, Inc. All rights reserved.
> + * Copyright (C) 2006-2010 Freescale Semiconductor, Inc. All rights reserved.
>   *
>   * Author: Shlomi Gridish <gridish@freescale.com>
>   *      Li Yang <leoli@freescale.com>
> @@ -1570,28 +1570,6 @@ static int ugeth_disable(struct ucc_geth_private *ugeth, enum comm_dir mode)
>     return 0;
>  }
>
> -static void ugeth_quiesce(struct ucc_geth_private *ugeth)
> -{
> -   /* Prevent any further xmits, plus detach the device. */
> -   netif_device_detach(ugeth->ndev);
> -
> -   /* Wait for any current xmits to finish. */
> -   netif_tx_disable(ugeth->ndev);
> -
> -   /* Disable the interrupt to avoid NAPI rescheduling. */
> -   disable_irq(ugeth->ug_info->uf_info.irq);
> -
> -   /* Stop NAPI, and possibly wait for its completion. */
> -   napi_disable(&ugeth->napi);
> -}
> -
> -static void ugeth_activate(struct ucc_geth_private *ugeth)
> -{
> -   napi_enable(&ugeth->napi);
> -   enable_irq(ugeth->ug_info->uf_info.irq);
> -   netif_device_attach(ugeth->ndev);
> -}
> -
>  /* Called every time the controller might need to be made
>   * aware of new link state.  The PHY code conveys this
>   * information through variables in the ugeth structure, and this
> @@ -1605,11 +1583,14 @@ static void adjust_link(struct net_device *dev)
>     struct ucc_geth __iomem *ug_regs;
>     struct ucc_fast __iomem *uf_regs;
>     struct phy_device *phydev = ugeth->phydev;
> +   unsigned long flags;
>     int new_state = 0;
>
>     ug_regs = ugeth->ug_regs;
>     uf_regs = ugeth->uccf->uf_regs;
>
> +   spin_lock_irqsave(&ugeth->lock, flags);
> +
>     if (phydev->link) {
>        u32 tempval = in_be32(&ug_regs->maccfg2);
>        u32 upsmr = in_be32(&uf_regs->upsmr);
> @@ -1666,21 +1647,9 @@ static void adjust_link(struct net_device *dev)
>        }
>
>        if (new_state) {
> -         /*
> -          * To change the MAC configuration we need to disable
> -          * the controller. To do so, we have to either grab
> -          * ugeth->lock, which is a bad idea since 'graceful
> -          * stop' commands might take quite a while, or we can
> -          * quiesce driver's activity.
> -          */
> -         ugeth_quiesce(ugeth);
> -         ugeth_disable(ugeth, COMM_DIR_RX_AND_TX);
> -
>           out_be32(&ug_regs->maccfg2, tempval);
>           out_be32(&uf_regs->upsmr, upsmr);
>
> -         ugeth_enable(ugeth, COMM_DIR_RX_AND_TX);
> -         ugeth_activate(ugeth);
>        }
>     } else if (ugeth->oldlink) {
>           new_state = 1;
> @@ -1691,6 +1660,8 @@ static void adjust_link(struct net_device *dev)
>
>     if (new_state && netif_msg_link(ugeth))
>        phy_print_status(phydev);
> +
> +   spin_unlock_irqrestore(&ugeth->lock, flags);
>  }
>
>  /* Initialize TBI PHY interface for communicating with the
> diff --git a/drivers/net/ethernet/freescale/ucc_geth.h b/drivers/net/ethernet/freescale/ucc_geth.h
> index d12fcad..b0b42b4 100644
> --- a/drivers/net/ethernet/freescale/ucc_geth.h
> +++ b/drivers/net/ethernet/freescale/ucc_geth.h
> @@ -1,5 +1,5 @@
>  /*
> - * Copyright (C) Freescale Semicondutor, Inc. 2006-2009. All rights reserved.
> + * Copyright (C) 2006-2010 Freescale Semiconductor, Inc. All rights reserved.
>   *
>   * Author: Shlomi Gridish <gridish@freescale.com>
>   *
> @@ -875,8 +875,8 @@ struct ucc_geth_hardware_statistics {
>  #define UCC_GETH_SIZE_OF_BD                     QE_SIZEOF_BD
>
>  /* Driver definitions */
> -#define TX_BD_RING_LEN                          0x10
> -#define RX_BD_RING_LEN                          0x10
> +#define TX_BD_RING_LEN                          64
> +#define RX_BD_RING_LEN                          64
>
>  #define TX_RING_MOD_MASK(size)                  (size-1)
>  #define RX_RING_MOD_MASK(size)                  (size-1)
> --
> 1.7.5.1
>
>
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev
