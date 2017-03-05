From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] can: m_can: support transmit frame in CAN FD format
Date: Sun, 5 Mar 2017 20:34:15 +0100
Message-ID: <12c3ae1d-65f7-8ba2-61e7-eed5291ebd21@hartkopp.net>
References: <20170303053331.20883-1-wenyou.yang@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexandre Belloni <alexandre.belloni@free-electrons.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Quentin Schulz <quentin.schulz@free-electrons.com>,
        Wenyou Yang <wenyou.yang@microchip.com>,
        Nicolas Ferre <nicolas.ferre@atmel.com>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Wenyou Yang <wenyou.yang@atmel.com>,
        Wolfgang Grandegger <wg@grandegger.com>,
        Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.161]:25395 "EHLO
        mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750770AbdCETgq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Mar 2017 14:36:46 -0500
In-Reply-To: <20170303053331.20883-1-wenyou.yang@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch has some issues:

On 03/03/2017 06:33 AM, Wenyou Yang wrote:
> Add support to transmit the frame in the CAN FD format and with
> the bit rate switching.

This is a misleading comment.

"can: m_can: support transmit frame in CAN FD format"
is misleading too. You were able to send CAN FD frames before.

This patch enables the transmission of CAN FD frames on M_CAN IP cores 
 >= v3.1.x, right?

So this should be mentioned properly.

> Tested on SAMA5D2 Xplained board.

Tested on which M_CAN IP core revision would be useful here.

> Signed-off-by: Wenyou Yang <wenyou.yang@atmel.com>
> ---
> The testing is based on
> [RESEND PATCH 1/1] can: m_can: fix bitrate setup on latest silicon
> http://lkml.iu.edu/hypermail/linux/kernel/1702.1/05347.html
>
>  drivers/net/can/m_can/m_can.c | 21 +++++++++++++++++----
>  1 file changed, 17 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
> index 195f15edb32e..9ef9b337d25b 100644
> --- a/drivers/net/can/m_can/m_can.c
> +++ b/drivers/net/can/m_can/m_can.c
> @@ -266,8 +266,12 @@ enum m_can_mram_cfg {
>
>  /* Tx Buffer Element */
>  /* R0 */
> +#define TX_BUF_ESI		BIT(31)
>  #define TX_BUF_XTD		BIT(30)
>  #define TX_BUF_RTR		BIT(29)
> +#define TX_BUF_EFC		BIT(23)
> +#define TX_BUF_EDL		BIT(21)

This bit is named FDF (FD Format bit).

It has to be:

#define TX_BUF_FDF		BIT(21)

> +#define TX_BUF_BRS		BIT(20)
>
>  /* address offset and element number for each FIFO/Buffer in the Message RAM */
>  struct mram_cfg {
> @@ -884,7 +888,7 @@ static void m_can_chip_config(struct net_device *dev)
>  	}
>
>  	if (priv->can.ctrlmode & CAN_CTRLMODE_FD)
> -		cccr |= CCCR_CME_CANFD_BRS << CCCR_CME_SHIFT;
> +		cccr |= (CCCR_CME_CANFD_BRS | CCCR_CME_CANFD) << CCCR_CME_SHIFT;
>
>  	m_can_write(priv, M_CAN_CCCR, cccr);
>  	m_can_write(priv, M_CAN_TEST, test);
> @@ -1047,6 +1051,7 @@ static netdev_tx_t m_can_start_xmit(struct sk_buff *skb,
>  	struct canfd_frame *cf = (struct canfd_frame *)skb->data;
>  	u32 id, cccr;
>  	int i;
> +	u32 dlc;
>
>  	if (can_dropped_invalid_skb(dev, skb))
>  		return NETDEV_TX_OK;
> @@ -1065,7 +1070,6 @@ static netdev_tx_t m_can_start_xmit(struct sk_buff *skb,
>
>  	/* message ram configuration */
>  	m_can_fifo_write(priv, 0, M_CAN_FIFO_ID, id);
> -	m_can_fifo_write(priv, 0, M_CAN_FIFO_DLC, can_len2dlc(cf->len) << 16);
>
>  	for (i = 0; i < cf->len; i += 4)
>  		m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(i / 4),
> @@ -1073,20 +1077,29 @@ static netdev_tx_t m_can_start_xmit(struct sk_buff *skb,
>
>  	can_put_echo_skb(skb, dev, 0);
>
> +	dlc = can_len2dlc(cf->len) << 16;
> +
>  	if (priv->can.ctrlmode & CAN_CTRLMODE_FD) {
>  		cccr = m_can_read(priv, M_CAN_CCCR);
>  		cccr &= ~(CCCR_CMR_MASK << CCCR_CMR_SHIFT);
>  		if (can_is_canfd_skb(skb)) {
> -			if (cf->flags & CANFD_BRS)
> +			dlc |= TX_BUF_EDL;

dito FDF

> +			if (cf->flags & CANFD_ESI)
> +				dlc |= TX_BUF_ESI;
> +			if (cf->flags & CANFD_BRS) {
> +				dlc |= TX_BUF_BRS;
>  				cccr |= CCCR_CMR_CANFD_BRS << CCCR_CMR_SHIFT;
> -			else
> +			} else {
>  				cccr |= CCCR_CMR_CANFD << CCCR_CMR_SHIFT;
> +			}
>  		} else {
>  			cccr |= CCCR_CMR_CAN << CCCR_CMR_SHIFT;
>  		}
>  		m_can_write(priv, M_CAN_CCCR, cccr);
>  	}
>
> +	m_can_fifo_write(priv, 0, M_CAN_FIFO_DLC, dlc);
> +
>  	/* enable first TX buffer to start transfer  */
>  	m_can_write(priv, M_CAN_TXBTIE, 0x1);
>  	m_can_write(priv, M_CAN_TXBAR, 0x1);
>

Beside the documentation and the wrong bit naming the patch looks ok.
Please resend.

Regards,
Oliver
