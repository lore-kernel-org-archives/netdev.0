From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH v4 2/2] can: spi: hi311x: Add Holt HI-311x CAN driver
Date: Sun, 19 Mar 2017 17:17:37 +0100
Message-ID: <78bf099d-32ad-9981-6ba9-fe56fbcabc3e@grandegger.com>
References: <1489785040-26477-1-git-send-email-akshay.bhat@timesys.com>
 <1489785040-26477-2-git-send-email-akshay.bhat@timesys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Akshay Bhat <nodeax-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Akshay Bhat <akshay.bhat-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>, mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1489785040-26477-2-git-send-email-akshay.bhat-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Akshay,

I still see some improvements...

Am 17.03.2017 um 22:10 schrieb Akshay Bhat:
> This patch adds support for the Holt HI-311x CAN controller. The HI311x
> CAN controller is capable of transmitting and receiving standard data
> frames, extended data frames and remote frames. The HI311x interfaces
> with the host over SPI.
>
> Datasheet: www.holtic.com/documents/371-hi-3110_v-rev-jpdf.do
>
> Signed-off-by: Akshay Bhat <nodeax-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>
> v3 -> v4:
> Address comments from Wolfgang Grandegger:
> - Add support for CAN warning state reporting
> - Add support for reporting tx/rx error counts in bus error messages
> - Keep bus error interrupts enabled to detect CAN state changes
> - Fix bug in restart code after BUSOFF state
> - Clean up error handling code
>
>  drivers/net/can/spi/Kconfig  |    6 +
>  drivers/net/can/spi/Makefile |    1 +
>  drivers/net/can/spi/hi311x.c | 1072 ++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 1079 insertions(+)
>  create mode 100644 drivers/net/can/spi/hi311x.c
>
> diff --git a/drivers/net/can/spi/Kconfig b/drivers/net/can/spi/Kconfig
> index 148cae5..8f2e0dd 100644
> --- a/drivers/net/can/spi/Kconfig
> +++ b/drivers/net/can/spi/Kconfig
> @@ -1,6 +1,12 @@
>  menu "CAN SPI interfaces"
>  	depends on SPI
>
> +config CAN_HI311X
> +	tristate "Holt HI311x SPI CAN controllers"
> +	depends on CAN_DEV && SPI && HAS_DMA
> +	---help---
> +	  Driver for the Holt HI311x SPI CAN controllers.
> +
>  config CAN_MCP251X
>  	tristate "Microchip MCP251x SPI CAN controllers"
>  	depends on HAS_DMA
> diff --git a/drivers/net/can/spi/Makefile b/drivers/net/can/spi/Makefile
> index 0e86040..f59fa37 100644
> --- a/drivers/net/can/spi/Makefile
> +++ b/drivers/net/can/spi/Makefile
> @@ -3,4 +3,5 @@
>  #
>
>
> +obj-$(CONFIG_CAN_HI311X)	+= hi311x.o
>  obj-$(CONFIG_CAN_MCP251X)	+= mcp251x.o
> diff --git a/drivers/net/can/spi/hi311x.c b/drivers/net/can/spi/hi311x.c
> new file mode 100644
> index 0000000..2a3d794
> --- /dev/null
> +++ b/drivers/net/can/spi/hi311x.c
> @@ -0,0 +1,1072 @@
> +/* CAN bus driver for Holt HI3110 CAN Controller with SPI Interface
> + *
> + * Copyright(C) Timesys Corporation 2016
> + *
> + * Based on Microchip 251x CAN Controller (mcp251x) Linux kernel driver
> + * Copyright 2009 Christian Pellegrin EVOL S.r.l.
> + * Copyright 2007 Raymarine UK, Ltd. All Rights Reserved.
> + * Copyright 2006 Arcom Control Systems Ltd.
> + *
> + * Based on CAN bus driver for the CCAN controller written by
> + * - Sascha Hauer, Marc Kleine-Budde, Pengutronix
> + * - Simon Kallweit, intefo AG
> + * Copyright 2007
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + */

... snip...

> +
> +static irqreturn_t hi3110_can_ist(int irq, void *dev_id)
> +{
> +	struct hi3110_priv *priv = dev_id;
> +	struct spi_device *spi = priv->spi;
> +	struct net_device *net = priv->net;
> +
> +	mutex_lock(&priv->hi3110_lock);
> +
> +	while (!priv->force_quit) {
> +		enum can_state new_state;
> +		u8 intf, eflag, statf;
> +
> +		while (!(HI3110_STAT_RXFMTY &
> +		       (statf = hi3110_read(spi, HI3110_READ_STATF)))) {
> +			hi3110_hw_rx(spi);
> +		}
> +
> +		intf = hi3110_read(spi, HI3110_READ_INTF);

I think HI3110_READ_ERR is only valid if HI3110_INT_BUSERR is set! 
Therefore:

                 if ((intf & HI3110_INT_BUSERR) {

It saves reading one SPI register in the message processing path. Please 
check if back-to-error-active still comes.

> +		eflag = hi3110_read(spi, HI3110_READ_ERR);
> +		/* Update can state */
> +		if (eflag & HI3110_ERR_BUSOFF)
> +			new_state = CAN_STATE_BUS_OFF;
> +		else if (eflag & HI3110_ERR_PASSIVE_MASK)
> +			new_state = CAN_STATE_ERROR_PASSIVE;
> +		else if (statf & HI3110_STAT_ERRW)
> +			new_state = CAN_STATE_ERROR_WARNING;
> +		else
> +			new_state = CAN_STATE_ERROR_ACTIVE;
> +
> +		if (new_state != priv->can.state) {
> +			struct can_frame *cf;
> +			struct sk_buff *skb;
> +			enum can_state rx_state, tx_state;
> +			u8 rxerr, txerr;
> +
> +			skb = alloc_can_err_skb(net, &cf);
> +			if (!skb)
> +				break;
> +
> +			txerr = hi3110_read(spi, HI3110_READ_TEC);
> +			rxerr = hi3110_read(spi, HI3110_READ_REC);
> +			cf->data[6] = txerr;
> +			cf->data[7] = rxerr;
> +			tx_state = txerr >= rxerr ? new_state : 0;
> +			rx_state = txerr <= rxerr ? new_state : 0;
> +			can_change_state(net, cf, tx_state, rx_state);
> +			netif_rx_ni(skb);
> +
> +			if (new_state == CAN_STATE_BUS_OFF) {
> +				can_bus_off(net);
> +				if (priv->can.restart_ms == 0) {
> +					priv->force_quit = 1;
> +					hi3110_hw_sleep(spi);
> +					break;
> +				}
> +			}
> +		}
> +
> +		/* Update bus errors */
> +		if ((intf & HI3110_INT_BUSERR) &&
> +		    (priv->can.ctrlmode & CAN_CTRLMODE_BERR_REPORTING)) {
> +			struct can_frame *cf;
> +			struct sk_buff *skb;
> +
> +			/* Check for protocol errors */
> +			if (eflag & HI3110_ERR_PROTOCOL_MASK) {
> +				skb = alloc_can_err_skb(net, &cf);
> +				if (!skb)
> +					break;
> +
> +				cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
> +				priv->can.can_stats.bus_error++;
> +				priv->net->stats.rx_errors++;
> +				if (eflag & HI3110_ERR_BITERR)
> +					cf->data[2] |= CAN_ERR_PROT_BIT;
> +				else if (eflag & HI3110_ERR_FRMERR)
> +					cf->data[2] |= CAN_ERR_PROT_FORM;
> +				else if (eflag & HI3110_ERR_STUFERR)
> +					cf->data[2] |= CAN_ERR_PROT_STUFF;
> +				else if (eflag & HI3110_ERR_CRCERR)
> +					cf->data[3] |= CAN_ERR_PROT_LOC_CRC_SEQ;
> +				else if (eflag & HI3110_ERR_ACKERR)
> +					cf->data[3] |= CAN_ERR_PROT_LOC_ACK;
> +
> +				cf->data[6] = hi3110_read(spi, HI3110_READ_TEC);
> +				cf->data[7] = hi3110_read(spi, HI3110_READ_REC);
> +				netdev_dbg(priv->net, "Bus Error\n");
> +				netif_rx_ni(skb);
> +			}
> +		}
> +
> +		if (intf == 0)
> +			break;

I do not see a real benefit of the check above. Just more code.

> +		if (intf & HI3110_INT_TXCPLT) {
> +			net->stats.tx_packets++;
> +			net->stats.tx_bytes += priv->tx_len - 1;
> +			can_led_event(net, CAN_LED_EVENT_TX);
> +			if (priv->tx_len) {
> +				can_get_echo_skb(net, 0);
> +				priv->tx_len = 0;
> +			}
> +			netif_wake_queue(net);
> +		}
> +	}
> +	mutex_unlock(&priv->hi3110_lock);
> +	return IRQ_HANDLED;
> +}

Apart from that, it looks good now and you can add my:

Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>

Thanks,

Wolfgang.


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
