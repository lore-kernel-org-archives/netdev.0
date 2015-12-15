From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC net-next] ravb: Add dma queue interrupt support
Date: Tue, 15 Dec 2015 22:00:00 +0300
Message-ID: <56706330.2060803@cogentembedded.com>
References: <1450182181-12575-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1450182181-12575-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/15/2015 03:23 PM, Yoshihiro Kaneko wrote:

> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>
> This patch supports the following interrupts.
>
> - One interrupt for multiple (descriptor, error, management)
> - One interrupt for emac
> - Four interrupts for dma queue (best effort rx/tx, network control rx/tx)

    You don't say why the current 2-interrupt scheme (implemented by Simon's 
patch) isn't enpough...

> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
[...]

> diff --git a/drivers/net/ethernet/renesas/ravb.h b/drivers/net/ethernet/renesas/ravb.h
> index 9fbe92a..eada5a1 100644
> --- a/drivers/net/ethernet/renesas/ravb.h
> +++ b/drivers/net/ethernet/renesas/ravb.h
> @@ -157,6 +157,7 @@ enum ravb_reg {
>   	TIC	= 0x0378,
>   	TIS	= 0x037C,
>   	ISS	= 0x0380,
> +	CIE	= 0x0384,

    I'd like to see some comment clarifying that this is R-Car gen3 only reg.

[./..]
> @@ -556,6 +566,16 @@ enum ISS_BIT {
>   	ISS_DPS15	= 0x80000000,
>   };
>
> +/* CIE */

    And here as well.

> +enum CIE_BIT {
> +	CIE_CRIE	= 0x00000001, /* Common Receive Interrupt Enable */
> +	CIE_CTIE	= 0x00000100, /* Common Transmit Interrupt Enable */
> +	CIE_RQFM	= 0x00010000, /* Reception Queue Full Mode */
> +	CIE_CL0M	= 0x00020000, /* Common Line 0 Mode */
> +	CIE_RFWL	= 0x00040000, /* Rx-FIFO Warning interrupt Line */

    You forgot "Select" at the end.

> +	CIE_RFFL	= 0x00080000, /* Rx-FIFO Full interrupt Line */

    Here as well.
    Well, generally we don't have such comments for the other registers, so 
this will look somewhat out of line...

[...]
> @@ -592,6 +612,18 @@ enum GIS_BIT {
>   	GIS_PTMF	= 0x00000004,
>   };
>
> +/* GIx */

    I'd prefer GIC/GIS.

> +#define RAVB_GIx_ALL	0xffff03ff

    No RAVB_ prefix please.

> +
> +/* RIx0 */

    RIE0/RID0.

> +#define RAVB_RIx0_ALL	0x0003ffff

    No prefix. And I'd rather call it RIx0_FRx. Or even RIE0_FRS and RID0_FRD.

> +
> +/* RIx2 */

    RIE2/RID2.

> +#define RAVB_RIx2_ALL	0x8003ffff

    No prefix. And there's bit 31 in this register, according to my gen3 
manual. So, your _ALL isn't really "all bits". I'd rather call it RIx2_QFx. Or 
even RIE2_QFS and RID2_QFD.

> +
> +/* TIx */

    TIE/TID.

> +#define RAVB_TIx_ALL	0x000fffff

    No prefix. And there's bit 31 in this register, according to my gen3 
manual. So, your _ALL isn't really "all bits".

[...]
> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> index 120cc25..753b67d 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
[...]
> @@ -376,6 +386,7 @@ static void ravb_emac_init(struct net_device *ndev)
>   static int ravb_dmac_init(struct net_device *ndev)
>   {
>   	int error;
> +	struct ravb_private *priv = netdev_priv(ndev);

    Please declare this variable before 'error' -- DaveM really prefers 
"reversed Christmas tree" declaration order.

[...]
> @@ -411,14 +422,28 @@ static int ravb_dmac_init(struct net_device *ndev)
>   	ravb_write(ndev, TCCR_TFEN, TCCR);
>
>   	/* Interrupt init: */
> -	/* Frame receive */
> -	ravb_write(ndev, RIC0_FRE0 | RIC0_FRE1, RIC0);
> -	/* Disable FIFO full warning */
> -	ravb_write(ndev, 0, RIC1);
> -	/* Receive FIFO full error, descriptor empty */
> -	ravb_write(ndev, RIC2_QFE0 | RIC2_QFE1 | RIC2_RFFE, RIC2);
> -	/* Frame transmitted, timestamp FIFO updated */
> -	ravb_write(ndev, TIC_FTE0 | TIC_FTE1 | TIC_TFUE, TIC);
> +	if (priv->chip_id == RCAR_GEN2) {
> +		/* Frame receive */
> +		ravb_write(ndev, RIC0_FRE0 | RIC0_FRE1, RIC0);
> +		/* Disable FIFO full warning */
> +		ravb_write(ndev, 0, RIC1);
> +		/* Receive FIFO full error, descriptor empty */
> +		ravb_write(ndev, RIC2_QFE0 | RIC2_QFE1 | RIC2_RFFE, RIC2);
> +		/* Frame transmitted, timestamp FIFO updated */
> +		ravb_write(ndev, TIC_FTE0 | TIC_FTE1 | TIC_TFUE, TIC);
> +	} else {
> +		/* Clear CIE.CTIE, CIE.CRIE, DIL.DPLx */
> +		ravb_write(ndev, 0, CIE);

    Why clear CIE if you immediately overwrite it?

> +		ravb_write(ndev, 0, DIL);
> +		/* Set queue specific interrupt */
> +		ravb_write(ndev, CIE_CRIE | CIE_CTIE | CIE_CL0M, CIE);
> +		/* Frame receive */
> +		ravb_write(ndev, RIC0_FRE0 | RIC0_FRE1, RIE0);

    Using RIC0 bits to write to RIE0?

> +		/* Receive FIFO full error, descriptor empty */
> +		ravb_write(ndev, RIC2_QFE0 | RIC2_QFE1 | RIC2_RFFE, RIE2);

    Using RIC2 bits to write to RIE2?

> +		/* Frame transmitted, timestamp FIFO updated */
> +		ravb_write(ndev, TIC_FTE0 | TIC_FTE1 | TIC_TFUE, TIE);

    Using TIC bits to write to TIE?
    No, that won't do.

> @@ -654,7 +679,7 @@ static int ravb_stop_dma(struct net_device *ndev)
>   }
>
>   /* E-MAC interrupt handler */
> -static void ravb_emac_interrupt(struct net_device *ndev)
> +static void _ravb_emac_interrupt(struct net_device *ndev)

    ravb_emac_interrupt_[un]locked() perhaps? Not sure which is more 
correct... :-)

[...]
> @@ -690,7 +727,10 @@ static void ravb_error_interrupt(struct net_device *ndev)
>   	ravb_write(ndev, ~EIS_QFS, EIS);
>   	if (eis & EIS_QFS) {
>   		ris2 = ravb_read(ndev, RIS2);
> -		ravb_write(ndev, ~(RIS2_QFF0 | RIS2_RFFF), RIS2);
> +		if (priv->chip_id == RCAR_GEN2)
> +			ravb_write(ndev, ~(RIS2_QFF0 | RIS2_RFFF), RIS2);
> +		else
> +			ravb_write(ndev, RIS2_QFF0 | RIS2_RFFF, RID2);

    Using RIS2 bits to write to RID2? That won't do.

[...]
> @@ -758,16 +798,43 @@ static irqreturn_t ravb_interrupt(int irq, void *dev_id)
[...]
> +/* Descriptor IRQ/ Error/ Management interrupt handler */

    No space after /.

> +static irqreturn_t ravb_multi_interrupt(int irq, void *dev_id)
> +{
> +	struct net_device *ndev = dev_id;
> +	struct ravb_private *priv = netdev_priv(ndev);
> +	irqreturn_t result = IRQ_NONE;
> +	u32 iss;
> +
> +	spin_lock(&priv->lock);
> +	/* Get interrupt status */
> +	iss = ravb_read(ndev, ISS);
> +
>   	/* Error status summary */
>   	if (iss & ISS_ES) {
>   		ravb_error_interrupt(ndev);
>   		result = IRQ_HANDLED;
>   	}
>
> +	/* Management */

    Really? I thought that's gPTP Interrupt...

>   	if (iss & ISS_CGIS)
>   		result = ravb_ptp_interrupt(ndev);
>
> @@ -776,6 +843,55 @@ static irqreturn_t ravb_interrupt(int irq, void *dev_id)
[...]
> @@ -815,8 +931,13 @@ static int ravb_poll(struct napi_struct *napi, int budget)
>
>   	/* Re-enable RX/TX interrupts */
>   	spin_lock_irqsave(&priv->lock, flags);
> -	ravb_write(ndev, ravb_read(ndev, RIC0) | mask, RIC0);
> -	ravb_write(ndev, ravb_read(ndev, TIC)  | mask,  TIC);
> +	if (priv->chip_id == RCAR_GEN2) {
> +		ravb_write(ndev, ravb_read(ndev, RIC0) | mask, RIC0);
> +		ravb_write(ndev, ravb_read(ndev, TIC)  | mask,  TIC);

    You can drop one space before TIC now, sorry for that. :-)

> +	} else {
> +		ravb_write(ndev, mask, RIE0);
> +		ravb_write(ndev, mask, TIE);
> +	}
>   	mmiowb();
>   	spin_unlock_irqrestore(&priv->lock, flags);
>
> @@ -1208,23 +1329,68 @@ static const struct ethtool_ops ravb_ethtool_ops = {
>   static int ravb_open(struct net_device *ndev)
>   {
>   	struct ravb_private *priv = netdev_priv(ndev);
> -	int error;
> +	int error, i;
> +	struct platform_device *pdev = priv->pdev;
> +	struct device *dev = &pdev->dev;
> +	char *name;

    Reverse Christmas tree, please. :-)

[...]
> diff --git a/drivers/net/ethernet/renesas/ravb_ptp.c b/drivers/net/ethernet/renesas/ravb_ptp.c
> index 7a8ce92..a789c7c 100644
> --- a/drivers/net/ethernet/renesas/ravb_ptp.c
> +++ b/drivers/net/ethernet/renesas/ravb_ptp.c
> @@ -196,11 +196,15 @@ static int ravb_ptp_extts(struct ptp_clock_info *ptp,
>
>   	spin_lock_irqsave(&priv->lock, flags);
>   	gic = ravb_read(ndev, GIC);
> -	if (on)
> -		gic |= GIC_PTCE;
> -	else
> -		gic &= ~GIC_PTCE;
> -	ravb_write(ndev, gic, GIC);
> +	if (priv->chip_id == RCAR_GEN2) {
> +		if (on)
> +			gic |= GIC_PTCE;
> +		else
> +			gic &= ~GIC_PTCE;
> +		ravb_write(ndev, gic, GIC);
> +	} else {
> +		ravb_write(ndev, GIC_PTCE, (on) ? GIE : GID);

    Using GIC bit to write GIE/GID? Won't do.

[...]
> @@ -248,9 +252,13 @@ static int ravb_ptp_perout(struct ptp_clock_info *ptp,
>   		error = ravb_ptp_update_compare(priv, (u32)start_ns);
>   		if (!error) {
>   			/* Unmask interrupt */
> -			gic = ravb_read(ndev, GIC);
> -			gic |= GIC_PTME;
> -			ravb_write(ndev, gic, GIC);
> +			if (priv->chip_id == RCAR_GEN2) {
> +				gic = ravb_read(ndev, GIC);
> +				gic |= GIC_PTME;
> +				ravb_write(ndev, gic, GIC);
> +			} else {
> +				ravb_write(ndev, GIC_PTME, GIE);
> +			}

    Again?

[...]
> @@ -259,9 +267,13 @@ static int ravb_ptp_perout(struct ptp_clock_info *ptp,
>   		perout->period = 0;
>
>   		/* Mask interrupt */
> -		gic = ravb_read(ndev, GIC);
> -		gic &= ~GIC_PTME;
> -		ravb_write(ndev, gic, GIC);
> +		if (priv->chip_id == RCAR_GEN2) {
> +			gic = ravb_read(ndev, GIC);
> +			gic &= ~GIC_PTME;
> +			ravb_write(ndev, gic, GIC);
> +		} else {
> +			ravb_write(ndev, GIC_PTME, GID);

    Again?
    No way.

[...]

MBR, Sergei

