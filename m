From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [PATCH] net/cadence/macb: clear interrupts simply and correctly
Date: Mon, 16 Jun 2014 14:28:47 -0700
Message-ID: <7e888b59-d27b-49dc-9ffc-1c7d56f11773@BN1AFFO11FD007.protection.gbl>
References: <1402563054-8546-1-git-send-email-neidhard.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hayun Hwang <hwang.hayun@lge.com>,
	Youngkyu Choi <youngkyu7.choi@lge.com>
To: Jongsung Kim <neidhard.kim@lge.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1402563054-8546-1-git-send-email-neidhard.kim@lge.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-06-12 at 05:50PM +0900, Jongsung Kim wrote:
> The "Rx used bit read" interrupt is enabled but not cleared for some
> systems with the ISR (Interrupt Status Register) configured as clear-
> on-write. This interrupt may be asserted when the CPU does not handle
> Rx-complete interrupts for a long time. (e.g., if the CPU is stopped
> by debugger) Once asserted, it'll not be cleared, and the CPU will
> loop infinitly in the interrupt handler.
>=20
> This patch forces to use a dedicated function for reading the ISR,
> and the function clears it if clear-on-write. So the ISR is always
> cleared after read, regardless of clear-on-write configuration.
>=20
> Reported-by: Hayun Hwang <hwang.hayun@lge.com>
> Signed-off-by: Youngkyu Choi <youngkyu7.choi@lge.com>
> Signed-off-by: Jongsung Kim <neidhard.kim@lge.com>
> Tested-by: Hayun Hwang <hwang.hayun@lge.com>
> ---
>  drivers/net/ethernet/cadence/macb.c |   37 ++++++++++++++-----------=
---------
>  1 files changed, 15 insertions(+), 22 deletions(-)
>=20
[...]
> @@ -552,9 +562,6 @@ static void macb_tx_interrupt(struct macb *bp)
>  	status =3D macb_readl(bp, TSR);
>  	macb_writel(bp, TSR, status);
> =20
> -	if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
> -		macb_writel(bp, ISR, MACB_BIT(TCOMP));
> -
>  	netdev_vdbg(bp->dev, "macb_tx_interrupt status =3D 0x%03lx\n",
>  		(unsigned long)status);
> =20
> @@ -883,13 +890,10 @@ static int macb_poll(struct napi_struct *napi, =
int budget)
> =20
>  		/* Packets received while interrupts were disabled */
>  		status =3D macb_readl(bp, RSR);
> -		if (status) {
> -			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
> -				macb_writel(bp, ISR, MACB_BIT(RCOMP));
> +		if (status)
>  			napi_reschedule(napi);
> -		} else {
> +		else
>  			macb_writel(bp, IER, MACB_RX_INT_FLAGS);
> -		}
>  	}
> =20
>  	/* TODO: Handle errors */
> @@ -903,7 +907,7 @@ static irqreturn_t macb_interrupt(int irq, void *=
dev_id)
>  	struct macb *bp =3D netdev_priv(dev);
>  	u32 status;
> =20
> -	status =3D macb_readl(bp, ISR);
> +	status =3D macb_read_isr(bp);
> =20
>  	if (unlikely(!status))
>  		return IRQ_NONE;
> @@ -928,8 +932,6 @@ static irqreturn_t macb_interrupt(int irq, void *=
dev_id)
>  			 * now.
>  			 */
>  			macb_writel(bp, IDR, MACB_RX_INT_FLAGS);
> -			if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
> -				macb_writel(bp, ISR, MACB_BIT(RCOMP));
Shouldn't it be sufficient to replace 'MACB_BIT(RCOMP) with 'MACB_RX_IN=
T_FLAGS'
to clear all the RX IRQ flags.

	S=C3=B6ren
