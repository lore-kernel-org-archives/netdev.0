From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net-next 1/4] net: bcmgenet: consistently use UMAC_IRQ_RXDMA_MASK
Date: Fri, 24 Oct 2014 14:39:03 -0700
Message-ID: <CAGXr9JFy7pE4kkRCCstGcmUJ0FdojYoh1XDTXtFj7-9UfAuO4g@mail.gmail.com>
References: <1414180942-2132-1-git-send-email-f.fainelli@gmail.com>
	<1414180942-2132-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:54948 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615AbaJXVjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 17:39:05 -0400
Received: by mail-qg0-f48.google.com with SMTP id i50so1660018qgf.21
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 14:39:04 -0700 (PDT)
In-Reply-To: <1414180942-2132-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Fri, Oct 24, 2014 at 1:02 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> Define a constant which sets all RXDMA interrupts bits, and use it
> consistently throughout the driver to check for RX DMA interrupt bits.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 14 +++++++++-----
>  1 file changed, 9 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index fdc9ec09e453..ee4d5baf09b6 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -47,6 +47,10 @@
>
>  #include "bcmgenet.h"
>
> +#define UMAC_IRQ_RXDMA_MASK    (UMAC_IRQ_RXDMA_BDONE | UMAC_IRQ_RXDMA_PDONE)
> +#define UMAC_IRQ_TXDMA_MASK    (UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE)
> +#define UMAC_IRQ_RX_TX_MASK    (UMAC_IRQ_RXDMA_MASK | UMAC_IRQ_TXDMA_MASK)
> +

How about putting these in bcmgenet.h, just below the other UMAC_IRQ_*
definitions?

>  /* Maximum number of hardware queues, downsized if needed */
>  #define GENET_MAX_MQ_CNT       4
>
> @@ -1543,9 +1547,9 @@ static int init_umac(struct bcmgenet_priv *priv)
>
>         bcmgenet_intr_disable(priv);
>
> -       cpu_mask_clear = UMAC_IRQ_RXDMA_BDONE;
> +       cpu_mask_clear = UMAC_IRQ_RXDMA_MASK;
>
> -       dev_dbg(kdev, "%s:Enabling RXDMA_BDONE interrupt\n", __func__);
> +       dev_dbg(kdev, "%s:Enabling RXDMA interrupts\n", __func__);
>
>         /* Monitor cable plug/unplugged event for internal PHY */
>         if (phy_is_internal(priv->phydev)) {
> @@ -1883,7 +1887,7 @@ static int bcmgenet_poll(struct napi_struct *napi, int budget)
>                                   priv->rx_c_index, RDMA_CONS_INDEX);
>         if (work_done < budget) {
>                 napi_complete(napi);
> -               bcmgenet_intrl2_0_writel(priv, UMAC_IRQ_RXDMA_BDONE,
> +               bcmgenet_intrl2_0_writel(priv, UMAC_IRQ_RXDMA_MASK,
>                                          INTRL2_CPU_MASK_CLEAR);
>         }
>
> @@ -1958,13 +1962,13 @@ static irqreturn_t bcmgenet_isr0(int irq, void *dev_id)
>         netif_dbg(priv, intr, priv->dev,
>                   "IRQ=0x%x\n", priv->irq0_stat);
>
> -       if (priv->irq0_stat & (UMAC_IRQ_RXDMA_BDONE | UMAC_IRQ_RXDMA_PDONE)) {
> +       if (priv->irq0_stat & UMAC_IRQ_RXDMA_MASK) {
>                 /* We use NAPI(software interrupt throttling, if
>                  * Rx Descriptor throttling is not used.
>                  * Disable interrupt, will be enabled in the poll method.
>                  */
>                 if (likely(napi_schedule_prep(&priv->napi))) {
> -                       bcmgenet_intrl2_0_writel(priv, UMAC_IRQ_RXDMA_BDONE,
> +                       bcmgenet_intrl2_0_writel(priv, UMAC_IRQ_RXDMA_MASK,
>                                                  INTRL2_CPU_MASK_SET);
>                         __napi_schedule(&priv->napi);
>                 }
> --
> 1.9.1
>
