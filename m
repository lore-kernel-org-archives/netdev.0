From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 4/4] ravb: Add support for r8a7795 SoC
Date: Wed, 18 Nov 2015 16:29:18 +0300
Message-ID: <564C7D2E.4030608@cogentembedded.com>
References: <1443593755-20991-1-git-send-email-horms+renesas@verge.net.au>
 <1443593755-20991-5-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Magnus Damm <magnus.damm@gmail.com>
To: Simon Horman <horms+renesas@verge.net.au>,
	David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1443593755-20991-5-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 9/30/2015 9:15 AM, Simon Horman wrote:

> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>
> This patch supports the r8a7795 SoC by:
> - Using two interrupts
>    + One for E-MAC
>    + One for everything else
>    + Both can be handled by the existing common interrupt handler, which
>      affords a simpler update to support the new SoC. In future some
>      consideration may be given to implementing multiple interrupt handlers
> - Limiting the phy speed to 100Mbit/s for the new SoC;
>    at this time it is not clear how this restriction may be lifted
>    but I hope it will be possible as more information comes to light
>
> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> [horms: reworked]
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
>
> ---
> v0 [Kazuya Mizuguchi]
>
> v1 [Simon Horman]
> * Updated patch subject
>
> v2 [Simon Horman]
> * Reworked based on extensive feedback from
>    Geert Uytterhoeven and Sergei Shtylyov.
> * Broke binding update out into separate patch
>
> v3 [Simon Horman]
> * Check new return value of phy_set_max_speed()
>
> v4
> * No change
> ---
>   drivers/net/ethernet/renesas/ravb.h      |  7 ++++
>   drivers/net/ethernet/renesas/ravb_main.c | 63 ++++++++++++++++++++++++++++----
>   2 files changed, 62 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/ethernet/renesas/ravb.h b/drivers/net/ethernet/renesas/ravb.h
> index a157aaaaff6a..0623fff932e4 100644
> --- a/drivers/net/ethernet/renesas/ravb.h
> +++ b/drivers/net/ethernet/renesas/ravb.h
> @@ -766,6 +766,11 @@ struct ravb_ptp {
>   	struct ravb_ptp_perout perout[N_PER_OUT];
>   };
>
> +enum ravb_chip_id {
> +	RCAR_GEN2,
> +	RCAR_GEN3,
> +};
> +
>   struct ravb_private {
>   	struct net_device *ndev;
>   	struct platform_device *pdev;
> @@ -806,6 +811,8 @@ struct ravb_private {
>   	int msg_enable;
>   	int speed;
>   	int duplex;
> +	int emac_irq;
> +	enum ravb_chip_id chip_id;
>
>   	unsigned no_avb_link:1;
>   	unsigned avb_link_active_low:1;
> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> index 4ca093d033f8..8cc5ec5ed19a 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
[...]
> @@ -1197,6 +1213,15 @@ static int ravb_open(struct net_device *ndev)
>   		goto out_napi_off;
>   	}
>
> +	if (priv->chip_id == RCAR_GEN3) {
> +		error = request_irq(priv->emac_irq, ravb_interrupt,
> +				    IRQF_SHARED, ndev->name, ndev);
> +		if (error) {
> +			netdev_err(ndev, "cannot request IRQ\n");
> +			goto out_free_irq;
> +		}
> +	}
> +
>   	/* Device init */
>   	error = ravb_dmac_init(ndev);
>   	if (error)
> @@ -1220,6 +1245,7 @@ out_ptp_stop:
>   	ravb_ptp_stop(ndev);
>   out_free_irq:
>   	free_irq(ndev->irq, ndev);
> +	free_irq(priv->emac_irq, ndev);

    Grr, this sloppy code causes WARNING in __free_irq() on gen2 SoCs. I'll 
deal with it...

>   out_napi_off:
>   	napi_disable(&priv->napi[RAVB_NC]);
>   	napi_disable(&priv->napi[RAVB_BE]);
[...]

MBR, Sergei

