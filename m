From: David Jander <david.jander-/Q/L1SwJa3aEVqv0pETR8A@public.gmane.org>
Subject: Re: [PATCH 1/2] can: mcp251x: fix endless loop in interrupt handler
	if CANINTF_MERRF is set
Date: Thu, 21 Oct 2010 14:08:08 +0200
Message-ID: <201010211408.08467.david.jander@protonic.nl>
References: <1287568946-32727-1-git-send-email-mkl@pengutronix.de>
	<1287568946-32727-2-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1287568946-32727-2-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 20 October 2010 12:02:25 pm Marc Kleine-Budde wrote:
> Commit d3cd15657516141adce387810be8cb377baf020e introduced a bug, the
> interrupt handler would loop endlessly if the CANINTF_MERRF bit is set,
> because it's not cleared.
> 
> This patch fixes the problem by masking out the CANINTF_MERRF and all other
> non interesting bits.
> 
> Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> ---
>  drivers/net/can/mcp251x.c |   14 +++++++++-----
>  1 files changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
> index c664be2..59f40bc 100644
> --- a/drivers/net/can/mcp251x.c
> +++ b/drivers/net/can/mcp251x.c
> @@ -125,8 +125,9 @@
>  #  define CANINTF_TX0IF 0x04
>  #  define CANINTF_RX1IF 0x02
>  #  define CANINTF_RX0IF 0x01
> -#  define CANINTF_ERR_TX \
> -	(CANINTF_ERRIF | CANINTF_TX2IF | CANINTF_TX1IF | CANINTF_TX0IF)
> +#  define CANINTF_RX (CANINTF_RX0IF | CANINTF_RX1IF)
> +#  define CANINTF_TX (CANINTF_TX2IF | CANINTF_TX1IF | CANINTF_TX0IF)
> +#  define CANINTF_ERR (CANINTF_ERRIF)

Is it just me, or do you still miss MERRF?

>  #define EFLG	      0x2d
>  #  define EFLG_EWARN	0x01
>  #  define EFLG_RXWAR	0x02
> @@ -790,6 +791,9 @@ static irqreturn_t mcp251x_can_ist(int irq, void
>  *dev_id)
> 
>  		mcp251x_read_2regs(spi, CANINTF, &intf, &eflag);
> 
> +		/* mask out flags we don't care about */
> +		intf &= CANINTF_RX | CANINTF_TX | CANINTF_ERR;
> +
>  		/* receive buffer 0 */
>  		if (intf & CANINTF_RX0IF) {
>  			mcp251x_hw_rx(spi, 0);
> @@ -810,8 +814,8 @@ static irqreturn_t mcp251x_can_ist(int irq, void
>  *dev_id) }
> 
>  		/* any error or tx interrupt we need to clear? */
> -		if (intf & CANINTF_ERR_TX)
> -			clear_intf |= intf & CANINTF_ERR_TX;
> +		if (intf & (CANINTF_ERR | CANINTF_TX))
> +			clear_intf |= intf & (CANINTF_ERR | CANINTF_TX);
>  		if (clear_intf)
>  			mcp251x_write_bits(spi, CANINTF, clear_intf, 0x00);
> 
> @@ -887,7 +891,7 @@ static irqreturn_t mcp251x_can_ist(int irq, void
>  *dev_id) if (intf == 0)
>  			break;
> 
> -		if (intf & (CANINTF_TX2IF | CANINTF_TX1IF | CANINTF_TX0IF)) {
> +		if (intf & CANINTF_TX) {
>  			net->stats.tx_packets++;
>  			net->stats.tx_bytes += priv->tx_len - 1;
>  			if (priv->tx_len) {

I've been staring at the changes for quite some time now, but I still don't 
understand how an "CANINTF" value of "0x80" is ever cleared (MERRF set).
Granted, you don't loop anymore, but shouldn't that flag be handled properly?

Best regards,

-- 
David Jander
Protonic Holland.
