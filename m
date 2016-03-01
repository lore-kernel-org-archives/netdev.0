From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH 2/4] net: can: ifi: Fix TX DLC configuration
Date: Tue, 1 Mar 2016 19:11:32 +0100
Message-ID: <56D5DB54.6000600@hartkopp.net>
References: <1456775971-4946-1-git-send-email-marex@denx.de>
 <1456775971-4946-3-git-send-email-marex@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>,
	Mark Rutland <mark.rutland@arm.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: Marek Vasut <marex@denx.de>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1456775971-4946-3-git-send-email-marex@denx.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 02/29/2016 08:59 PM, Marek Vasut wrote:
> The TX DLC, the transmission length information, was not written
> into the transmit configuration register. When using the CAN core
> with different CAN controller, the receiving CAN controller will
> receive only the ID part of the CAN frame, but no data at all.
> 
> This patch adds the TX DLC into the register to fix this issue.
> 
> Signed-off-by: Marek Vasut <marex@denx.de>
> Cc: Marc Kleine-Budde <mkl@pengutronix.de>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Oliver Hartkopp <socketcan@hartkopp.net>
> Cc: Wolfgang Grandegger <wg@grandegger.com>
> ---
>  drivers/net/can/ifi_canfd/ifi_canfd.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/drivers/net/can/ifi_canfd/ifi_canfd.c b/drivers/net/can/ifi_canfd/ifi_canfd.c
> index 72f5205..82a33bd 100644
> --- a/drivers/net/can/ifi_canfd/ifi_canfd.c
> +++ b/drivers/net/can/ifi_canfd/ifi_canfd.c
> @@ -774,10 +774,15 @@ static netdev_tx_t ifi_canfd_start_xmit(struct sk_buff *skb,
>  
>  	if (priv->can.ctrlmode & (CAN_CTRLMODE_FD | CAN_CTRLMODE_FD_NON_ISO)) {
>  		if (can_is_canfd_skb(skb)) {
> +			txdlc |= can_len2dlc(cf->len);
>  			txdlc |= IFI_CANFD_TXFIFO_DLC_EDL;
>  			if (cf->flags & CANFD_BRS)
>  				txdlc |= IFI_CANFD_TXFIFO_DLC_BRS;
> +		} else {
> +			txdlc |= cf->len;
>  		}
> +	} else {
> +		txdlc |= cf->len;
>  	}

Please use

	txdlc |= can_len2dlc(cf->len);

by default (it works for CAN and CAN FD).

So that it looks more like:

	txdlc |= can_len2dlc(cf->len);
	if ((priv->can.ctrlmode & CAN_CTRLMODE_FD) && can_is_canfd_skb(skb)) {
		txdlc |= IFI_CANFD_TXFIFO_DLC_EDL;
		if (cf->flags & CANFD_BRS)
			txdlc |= IFI_CANFD_TXFIFO_DLC_BRS;
	}

Testing against CAN_CTRLMODE_FD_NON_ISO is wrong!
This configuration bit is just for the protocol on the wire and is no
distinction for CAN / CAN FD.

Best regards,
Oliver

>  
>  	if (cf->can_id & CAN_RTR_FLAG)
> 
