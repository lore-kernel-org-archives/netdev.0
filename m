From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net-next 3/4] net: bcmgenet: reclaim transmitted buffers
 in NAPI context
Date: Fri, 24 Oct 2014 15:30:14 -0700
Message-ID: <CAGXr9JHD3MDHsyRgfiH_bHnzp3QawJyEfw_VpZD96xv5iAJRiA@mail.gmail.com>
References: <1414180942-2132-1-git-send-email-f.fainelli@gmail.com>
	<1414180942-2132-4-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:48785 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755101AbaJXWaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 18:30:15 -0400
Received: by mail-qc0-f170.google.com with SMTP id l6so1508948qcy.15
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 15:30:14 -0700 (PDT)
In-Reply-To: <1414180942-2132-4-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Fri, Oct 24, 2014 at 1:02 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> The GENET driver is currently reclaiming transmitted buffers from hard
> interrupt context in bcmgenet_isr0 as well as NAPI context in
> bcmgenet_poll, which is not consistent and not ideal. Instead, update
> the driver to reclaim transmitted buffers in NAPI context only and
> properly switch the TX path to use interrupt mitigation based on NAPI.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 29 +++++++++-----------------
>  1 file changed, 10 insertions(+), 19 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index 70f2fb366375..d6f4a7ace05e 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -934,9 +934,6 @@ static unsigned int __bcmgenet_tx_reclaim(struct net_device *dev,
>                 last_c_index &= (num_tx_bds - 1);
>         }
>
> -       if (ring->free_bds > (MAX_SKB_FRAGS + 1))
> -               ring->int_disable(priv, ring);
> -
>         if (netif_tx_queue_stopped(txq) && pkts_compl)
>                 netif_tx_wake_queue(txq);
>
> @@ -1211,10 +1208,8 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
>         bcmgenet_tdma_ring_writel(priv, ring->index,
>                                   ring->prod_index, TDMA_PROD_INDEX);
>
> -       if (ring->free_bds <= (MAX_SKB_FRAGS + 1)) {
> +       if (ring->free_bds <= (MAX_SKB_FRAGS + 1))

Like I mentioned in patch 2/4 comments, I feel that bcmgenet_xmit()
stops the Tx queue too early.
Too many TxBDs sit unused that non-fragmented frames could use.
I think this should be: if (ring->free_bds <= 1)


>                 netif_tx_stop_queue(txq);
> -               ring->int_enable(priv, ring);
> -       }
>
>  out:
>         spin_unlock_irqrestore(&ring->lock, flags);
> @@ -1553,9 +1548,9 @@ static int init_umac(struct bcmgenet_priv *priv)
>
>         bcmgenet_intr_disable(priv);
>
> -       cpu_mask_clear = UMAC_IRQ_RXDMA_MASK;
> +       cpu_mask_clear = UMAC_IRQ_RX_TX_MASK;
>
> -       dev_dbg(kdev, "%s:Enabling RXDMA interrupts\n", __func__);
> +       dev_dbg(kdev, "%s:Enabling RXDMA & TXDMA interrupts\n", __func__);
>
>         /* Monitor cable plug/unplugged event for internal PHY */
>         if (phy_is_internal(priv->phydev)) {
> @@ -1879,10 +1874,10 @@ static int bcmgenet_poll(struct napi_struct *napi, int budget)
>  {
>         struct bcmgenet_priv *priv = container_of(napi,
>                         struct bcmgenet_priv, napi);
> -       unsigned int work_done;
> +       unsigned int work_done, tx_work;
>
>         /* tx reclaim */
> -       bcmgenet_tx_reclaim(priv->dev, &priv->tx_rings[DESC_INDEX]);
> +       tx_work = bcmgenet_tx_reclaim(priv->dev, &priv->tx_rings[DESC_INDEX]);
>
>         work_done = bcmgenet_desc_rx(priv, budget);
>
> @@ -1891,9 +1886,9 @@ static int bcmgenet_poll(struct napi_struct *napi, int budget)
>         priv->rx_c_index &= DMA_C_INDEX_MASK;
>         bcmgenet_rdma_ring_writel(priv, DESC_INDEX,
>                                   priv->rx_c_index, RDMA_CONS_INDEX);
> -       if (work_done < budget) {
> +       if (work_done < budget || tx_work == 0) {

Imagine interface with a lot of Rx traffic but no Tx (e.g. UDP receiver).
For that case, work_done == budget and tx_work == 0.

Your change ends up completing NAPI when it shouldn't.

>                 napi_complete(napi);
> -               bcmgenet_intrl2_0_writel(priv, UMAC_IRQ_RXDMA_MASK,
> +               bcmgenet_intrl2_0_writel(priv, UMAC_IRQ_RX_TX_MASK,
>                                          INTRL2_CPU_MASK_CLEAR);
>         }
>
> @@ -1968,22 +1963,18 @@ static irqreturn_t bcmgenet_isr0(int irq, void *dev_id)
>         netif_dbg(priv, intr, priv->dev,
>                   "IRQ=0x%x\n", priv->irq0_stat);
>
> -       if (priv->irq0_stat & UMAC_IRQ_RXDMA_MASK) {
> +       if (priv->irq0_stat & UMAC_IRQ_RX_TX_MASK) {
>                 /* We use NAPI(software interrupt throttling, if
>                  * Rx Descriptor throttling is not used.
>                  * Disable interrupt, will be enabled in the poll method.
>                  */
>                 if (likely(napi_schedule_prep(&priv->napi))) {
> -                       bcmgenet_intrl2_0_writel(priv, UMAC_IRQ_RXDMA_MASK,
> +                       bcmgenet_intrl2_0_writel(priv, UMAC_IRQ_RX_TX_MASK,
>                                                  INTRL2_CPU_MASK_SET);
>                         __napi_schedule(&priv->napi);
>                 }
>         }
> -       if (priv->irq0_stat &
> -                       (UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE)) {
> -               /* Tx reclaim */
> -               bcmgenet_tx_reclaim(priv->dev, &priv->tx_rings[DESC_INDEX]);
> -       }
> +
>         if (priv->irq0_stat & (UMAC_IRQ_PHY_DET_R |
>                                 UMAC_IRQ_PHY_DET_F |
>                                 UMAC_IRQ_LINK_UP |
> --
> 1.9.1
>
