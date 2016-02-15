From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: bcmgenet: Add MDIO_INTR in GENETv2
Date: Mon, 15 Feb 2016 10:18:34 -0800
Message-ID: <56C2167A.1050109@gmail.com>
References: <1455525733-11736-1-git-send-email-jaedon.shin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Petri Gynther <pgynther@google.com>, opendmb@gmail.com
To: Jaedon Shin <jaedon.shin@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:36505 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193AbcBOSSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 13:18:37 -0500
Received: by mail-ob0-f169.google.com with SMTP id gc3so122322498obb.3
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 10:18:37 -0800 (PST)
In-Reply-To: <1455525733-11736-1-git-send-email-jaedon.shin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jaedon,

On 15/02/2016 00:42, Jaedon Shin wrote:
> The GENETv2 chipsets has MDIO interrupt like the GENETv3+ chipsets.
> 
> The previous commit d5c3d84657db ("net: phy: Avoid polling PHY with
> PHY_IGNORE_INTERRUPTS") and commit 49f7a471e4d1 ("net: bcmgenet: Properly
> configure PHY to ignore interrupt") cause link-down PHY always in some
> 40nm generation chipsets.

Humm, these are two different things here:

- GENET_HAS_MDIO_INTR is about telling the driver whether the hardware
supports MDIO_INTR_DONE and MDIO_INTR_ERROR
- eliminating PHY polling is about utilizing LINK_UP and LINK_DOWN to
avoid polling the PHY

So the original problem is actually here:

bcmgenet_irq_task():

	/* Link UP/DOWN event */
	if ((priv->hw_params->flags & GENET_HAS_MDIO_INTR) &&
	    (priv->irq0_stat & UMAC_IRQ_LINK_EVENT)) {

These two checks are actually orthogonal, so we should remove the first
check on GENET_HAS_MDIO_INTR.

Your patch remains valid though, just the explanation needs a bit
tweaking, thanks!

> 
> Signed-off-by: Jaedon Shin <jaedon.shin@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 4 ++--
>  drivers/net/ethernet/broadcom/genet/bcmgenet.h | 2 +-
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index b15a60d787c7..8e9aa8f6390d 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -1904,7 +1904,7 @@ static int init_umac(struct bcmgenet_priv *priv)
>  		bcmgenet_bp_mc_set(priv, reg);
>  	}
>  
> -	/* Enable MDIO interrupts on GENET v3+ */
> +	/* Enable MDIO interrupts on GENET v2+ */
>  	if (priv->hw_params->flags & GENET_HAS_MDIO_INTR)
>  		int0_enable |= (UMAC_IRQ_MDIO_DONE | UMAC_IRQ_MDIO_ERROR);
>  
> @@ -3168,7 +3168,7 @@ static struct bcmgenet_hw_params bcmgenet_hw_params[] = {
>  		.rdma_offset = 0x3000,
>  		.tdma_offset = 0x4000,
>  		.words_per_bd = 2,
> -		.flags = GENET_HAS_EXT,
> +		.flags = GENET_HAS_EXT | GENET_HAS_MDIO_INTR,
>  	},
>  	[GENET_V3] = {
>  		.tx_queues = 4,
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
> index 967367557309..c14bfbfbe06a 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
> @@ -310,7 +310,7 @@ struct bcmgenet_mib_counters {
>  #define UMAC_IRQ_TXDMA_BDONE		(1 << 18)
>  #define UMAC_IRQ_TXDMA_DONE		UMAC_IRQ_TXDMA_MBDONE
>  
> -/* Only valid for GENETv3+ */
> +/* Only valid for GENETv2+ */
>  #define UMAC_IRQ_MDIO_DONE		(1 << 23)
>  #define UMAC_IRQ_MDIO_ERROR		(1 << 24)
>  
> 
