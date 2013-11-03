From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v3] can: c_can: Speed up rx_poll function
Date: Sun, 03 Nov 2013 20:20:30 +0100
Message-ID: <5276A1FE.7040804@grandegger.com>
References: <1383298596-18385-1-git-send-email-mpa@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: Markus Pargmann <mpa@pengutronix.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1383298596-18385-1-git-send-email-mpa@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/01/2013 10:36 AM, Markus Pargmann wrote:
> This patch speeds up the rx_poll function by reducing the number of
> register reads.
> 
> Replace the 32bit register read by a 16bit register read. Currently
> the 32bit register read is implemented by using 2 16bit reads. This is
> inefficient as we only use the lower 16bit in rx_poll.
> 
> The for loop reads the pending interrupts in every iteration. This
> leads up to 16 reads of pending interrupts. The patch introduces a new
> outer loop to read the pending interrupts as long as 'quota' is above 0.
> This reduces the total number of reads.
> 
> The third change is to replace the for-loop by a ffs loop.
> 
> Tested on AM335x. I removed all 'static' and 'inline' from c_can.c to
> see the timings for all functions. I used the function tracer with
> trace_stats.
> 
> 125kbit:
>   Function                               Hit    Time            Avg             s^2
>   --------                               ---    ----            ---             ---
>   c_can_do_rx_poll                     63960    10168178 us     158.977 us      1493056 us
> With patch:
>   c_can_do_rx_poll                     63941    3764057 us      58.867 us       776162.2 us
> 
> 1Mbit:
>   Function                               Hit    Time            Avg             s^2
>   --------                               ---    ----            ---             ---
>   c_can_do_rx_poll                     69489    30049498 us     432.435 us      9271851 us
> With patch:
>   c_can_do_rx_poll                    207109    24322185 us     117.436 us      171469047 us
> 
> Signed-off-by: Markus Pargmann <mpa@pengutronix.de>
> ---
> 
> Notes:
>     Changes in v3:
>      - Update commit message (measurements and ffs)
>     
>     Changes in v2:
>      - Small changes, find_next_bit -> ffs and other
> 
>  drivers/net/can/c_can/c_can.c | 22 ++++++++++++----------
>  1 file changed, 12 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
> index a668cd4..428681e 100644
> --- a/drivers/net/can/c_can/c_can.c
> +++ b/drivers/net/can/c_can/c_can.c
> @@ -798,17 +798,19 @@ static int c_can_do_rx_poll(struct net_device *dev, int quota)
>  	u32 num_rx_pkts = 0;
>  	unsigned int msg_obj, msg_ctrl_save;
>  	struct c_can_priv *priv = netdev_priv(dev);
> -	u32 val = c_can_read_reg32(priv, C_CAN_INTPND1_REG);
> +	u16 val;
> +
> +	/*
> +	 * It is faster to read only one 16bit register. This is only possible
> +	 * for a maximum number of 16 objects.
> +	 */
> +	BUILD_BUG_ON_MSG(C_CAN_MSG_OBJ_RX_LAST > 16,
> +			"Implementation does not support more message objects than 16");
> +
> +	while (quota > 0 && (val = priv->read_reg(priv, C_CAN_INTPND1_REG))) {
> +		while ((msg_obj = ffs(val)) && quota > 0) {
> +			val &= ~BIT(msg_obj - 1);

IIRC, we should avoid assignment in if/while statements.

Wolfgang.

