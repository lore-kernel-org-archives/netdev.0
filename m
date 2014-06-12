From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [PATCH] net/cadence/macb: clear interrupts simply and correctly
Date: Thu, 12 Jun 2014 08:44:38 -0700
Message-ID: <9f5be687-d127-49a4-90ea-c1033505452d@BN1BFFO11FD019.protection.gbl>
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

Hi Jongsung,

On Thu, 2014-06-12 at 05:50PM +0900, Jongsung Kim wrote:
> The "Rx used bit read" interrupt is enabled but not cleared for some
> systems with the ISR (Interrupt Status Register) configured as clear-
> on-write.
Does this interrupt need to be enabled? There is nothing checking
that bit and handling this IRQ in the handler, AFAICT. And you solve
this by simply clearing the bit. So, I wonder whether not enabling this
IRQ in the first place would solve things too.

> This interrupt may be asserted when the CPU does not handle
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
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
> index e9daa07..21cc022 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -98,6 +98,16 @@ static void *macb_rx_buffer(struct macb *bp, unsig=
ned int index)
>  	return bp->rx_buffers + bp->rx_buffer_size * macb_rx_ring_wrap(inde=
x);
>  }
> =20
> +static u32 macb_read_isr(struct macb *bp)
> +{
> +	u32 status =3D macb_readl(bp, ISR);
> +
> +	if (bp->caps & MACB_CAPS_ISR_CLEAR_ON_WRITE)
> +		macb_writel(bp, ISR, status);
> +
> +	return status;
> +}
> +
>  void macb_set_hwaddr(struct macb *bp)
>  {
>  	u32 bottom;
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
This is now clearing all IRQ flags which is probably not what we want
here. This is handling RX only. We still want the non-RX interrupts to =
go to
the actual interrupt service routing.

	S=C3=B6ren
