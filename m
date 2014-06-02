From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH-next v2] drivers/net: fix broadcom/bcmsysport.c compile
 fail on SPARC
Date: Mon, 2 Jun 2014 15:01:56 -0700
Message-ID: <CAGVrzcaJdEBc0qjpGp5LHd_tug33SiLEMh14f+AyYGyeHoeEwA@mail.gmail.com>
References: <1401458527-26513-1-git-send-email-paul.gortmaker@windriver.com> <1401478770-20792-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:64602 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941AbaFBWCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 18:02:37 -0400
Received: by mail-qg0-f45.google.com with SMTP id z60so11566590qgd.4
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2014 15:02:36 -0700 (PDT)
In-Reply-To: <1401478770-20792-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-05-30 12:39 GMT-07:00 Paul Gortmaker <paul.gortmaker@windriver.com>:
> To fix:
>
>   CC      drivers/net/ethernet/broadcom/bcmsysport.o
> In file included from drivers/net/ethernet/broadcom/bcmsysport.c:28:0:
> drivers/net/ethernet/broadcom/bcmsysport.h:41:8: error: redefinition of 'struct tsb'
> arch/sparc/include/asm/mmu_64.h:65:8: note: originally defined here
> make[1]: *** [drivers/net/ethernet/broadcom/bcmsysport.o] Error 1
>
> we change struct tsb to struct bcm_tsb in the broadcom driver in
> order to avoid the namespace collision.  For consistency, we also
> change struct rsb to struct bcm_rsb, so the Rx/Tx symmetry is
> maintained.
>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>
> [v2: also change rsb --> bcm_rsb for Rx/Tx consistency]
>
>  drivers/net/ethernet/broadcom/bcmsysport.c | 12 ++++++------
>  drivers/net/ethernet/broadcom/bcmsysport.h |  4 ++--
>  2 files changed, 8 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
> index dc708a888f80..25982b02f0ea 100644
> --- a/drivers/net/ethernet/broadcom/bcmsysport.c
> +++ b/drivers/net/ethernet/broadcom/bcmsysport.c
> @@ -457,7 +457,7 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
>         struct sk_buff *skb;
>         unsigned int p_index;
>         u16 len, status;
> -       struct rsb *rsb;
> +       struct bcm_rsb *rsb;
>
>         /* Determine how much we should process since last call */
>         p_index = rdma_readl(priv, RDMA_PROD_INDEX);
> @@ -482,7 +482,7 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
>                                 RX_BUF_LENGTH, DMA_FROM_DEVICE);
>
>                 /* Extract the Receive Status Block prepended */
> -               rsb = (struct rsb *)skb->data;
> +               rsb = (struct bcm_rsb *)skb->data;
>                 len = (rsb->rx_status_len >> DESC_LEN_SHIFT) & DESC_LEN_MASK;
>                 status = (rsb->rx_status_len >> DESC_STATUS_SHIFT) &
>                         DESC_STATUS_MASK;
> @@ -759,7 +759,7 @@ static irqreturn_t bcm_sysport_tx_isr(int irq, void *dev_id)
>  static int bcm_sysport_insert_tsb(struct sk_buff *skb, struct net_device *dev)
>  {
>         struct sk_buff *nskb;
> -       struct tsb *tsb;
> +       struct bcm_tsb *tsb;
>         u32 csum_info;
>         u8 ip_proto;
>         u16 csum_start;
> @@ -777,7 +777,7 @@ static int bcm_sysport_insert_tsb(struct sk_buff *skb, struct net_device *dev)
>                 skb = nskb;
>         }
>
> -       tsb = (struct tsb *)skb_push(skb, sizeof(*tsb));
> +       tsb = (struct bcm_tsb *)skb_push(skb, sizeof(*tsb));
>         /* Zero-out TSB by default */
>         memset(tsb, 0, sizeof(*tsb));
>
> @@ -1584,8 +1584,8 @@ static int bcm_sysport_probe(struct platform_device *pdev)
>                                 NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
>
>         /* Set the needed headroom once and for all */
> -       BUILD_BUG_ON(sizeof(struct tsb) != 8);
> -       dev->needed_headroom += sizeof(struct tsb);
> +       BUILD_BUG_ON(sizeof(struct bcm_tsb) != 8);
> +       dev->needed_headroom += sizeof(struct bcm_tsb);
>
>         /* We are interfaced to a switch which handles the multicast
>          * filtering for us, so we do not support programming any
> diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h b/drivers/net/ethernet/broadcom/bcmsysport.h
> index 73fd04a94797..281c08246037 100644
> --- a/drivers/net/ethernet/broadcom/bcmsysport.h
> +++ b/drivers/net/ethernet/broadcom/bcmsysport.h
> @@ -38,7 +38,7 @@
>                                  ENET_BRCM_TAG_LEN + ETH_FCS_LEN + ENET_PAD)
>
>  /* Transmit status block */
> -struct tsb {
> +struct bcm_tsb {
>         u32 pcp_dei_vid;
>  #define PCP_DEI_MASK           0xf
>  #define VID_SHIFT              4
> @@ -56,7 +56,7 @@ struct tsb {
>  /* Receive status block uses the same
>   * definitions as the DMA descriptor
>   */
> -struct rsb {
> +struct bcm_rsb {
>         u32 rx_status_len;
>         u32 brcm_egress_tag;
>  };
> --
> 1.9.3
>



-- 
Florian
