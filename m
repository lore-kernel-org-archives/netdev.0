From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH V3] CAN: Add Flexcan CAN controller driver
Date: Wed, 29 Jul 2009 11:09:14 +0200
Message-ID: <4A7011BA.7040906@grandegger.com>
References: <20090729082010.GZ2714@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Socketcan-core@lists.berlios.de
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:42562 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635AbZG2JJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 05:09:16 -0400
In-Reply-To: <20090729082010.GZ2714@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sascha Hauer wrote:
> And another go...
> 
> Sascha
> 
> 
>>From 9f6f6fb67d57d082e056dec8121f1423c1b4fa0b Mon Sep 17 00:00:00 2001
> From: Sascha Hauer <s.hauer@pengutronix.de>
> Date: Tue, 21 Jul 2009 10:47:19 +0200
> Subject: [PATCH] CAN: Add Flexcan CAN driver
> 
> This core is found on some Freescale SoCs and also some Coldfire
> SoCs. Support for Coldfire is missing though at the moment as
> they have an older revision of the core which does not have RX FIFO
> support.
> 
> V3: integrated comments from Oliver Hartkopp
> V2: integrated comments from Wolfgang Grandegger
> 
> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
> ---
>  drivers/net/can/Kconfig   |    6 +
>  drivers/net/can/Makefile  |    1 +
>  drivers/net/can/flexcan.c |  719 +++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 726 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/can/flexcan.c
> 
> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index 33821a8..99c6da4 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -74,6 +74,12 @@ config CAN_KVASER_PCI
>  	  This driver is for the the PCIcanx and PCIcan cards (1, 2 or
>  	  4 channel) from Kvaser (http://www.kvaser.com).
>  
> +config CAN_FLEXCAN
> +	tristate "Support for Freescale FLEXCAN based chips"
> +	depends on CAN_DEV
> +	---help---
> +	  Say Y here if you want to support for Freescale FlexCAN.
> +
>  config CAN_DEBUG_DEVICES
>  	bool "CAN devices debugging messages"
>  	depends on CAN
> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
> index 523a941..25f2032 100644
> --- a/drivers/net/can/Makefile
> +++ b/drivers/net/can/Makefile
> @@ -8,5 +8,6 @@ obj-$(CONFIG_CAN_DEV)		+= can-dev.o
>  can-dev-y			:= dev.o
>  
>  obj-$(CONFIG_CAN_SJA1000)	+= sja1000/
> +obj-$(CONFIG_CAN_FLEXCAN)	+= flexcan.o
>  
>  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
> diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
> new file mode 100644
> index 0000000..77661b3
> --- /dev/null
> +++ b/drivers/net/can/flexcan.c
[...]
> +static void flexcan_error(struct net_device *ndev, u32 stat)
> +{
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +	struct flexcan_priv *priv = netdev_priv(ndev);
> +	struct net_device_stats *stats = &ndev->stats;
> +	enum can_state state = priv->can.state;
> +	int error_warning = 0, rx_errors = 0, tx_errors = 0;
> +
> +	skb = dev_alloc_skb(sizeof(struct can_frame));
> +	if (!skb)
> +		return;
> +
> +	skb->dev = ndev;
> +	skb->protocol = __constant_htons(ETH_P_CAN);
> +	skb->ip_summed = CHECKSUM_UNNECESSARY;
> +
> +	cf = (struct can_frame *)skb_put(skb, sizeof(*cf));
> +	memset(cf, 0, sizeof(*cf));
> +
> +	cf->can_id = CAN_ERR_FLAG;
> +	cf->can_dlc = CAN_ERR_DLC;
> +
> +	if (stat & ERRSTAT_RWRNINT) {
> +		error_warning = 1;
> +		cf->data[1] |= CAN_ERR_CRTL_RX_WARNING;
> +	}
> +
> +	if (stat & ERRSTAT_TWRNINT) {
> +		error_warning = 1;
> +		cf->data[1] |= CAN_ERR_CRTL_TX_WARNING;
> +	}

What is the meaning of this error warning interrupt? It does *not*
change the state.

> +	switch ((stat >> 4) & 0x3) {
> +	case 0:
> +		state = CAN_STATE_ERROR_ACTIVE;
> +		break;
> +	case 1:
> +		state = CAN_STATE_ERROR_PASSIVE;
> +		break;
> +	default:
> +		state = CAN_STATE_BUS_OFF;
> +		break;
> +	}

I'm still not happy with the error message generation. If a state change
to error passive happens, it should be signaled to the user. Here my ideas:

	if (state != priv->can.state) {
		if (state == CAN_STATE_ERROR_WARNING) {
			cf->data[1] |= CAN_ERR_CRTL_RX_WARNING;
			priv->can.can_stats.error_warning++;
		} else if (state == CAN_STATE_ERROR_PASSIVE) {
			cf->data[1] |= CAN_ERR_CRTL_RX_PASSIVE;
			priv->can.can_stats.error_passive++;
		}

It might have missed something, though.

Wolfgang.
