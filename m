From: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Subject: Re: [patch 2.6.24-git] net/enc28j60: oops fix, low power mode
Date: Wed, 06 Feb 2008 18:11:30 +0100
Message-ID: <47A9EA42.3080800@eptar.com>
References: <20080205190124.E72F48E45F@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Brownell <david-b@pacbell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fe-relay03.albacom.net ([217.220.57.137]:60361 "EHLO
	fe-relay03.albacom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753642AbYBFRKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 12:10:39 -0500
In-Reply-To: <20080205190124.E72F48E45F@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Brownell wrote:
> From: David Brownell <dbrownell@users.sourceforge.net>
>
> Prevent unaligned packet oops on enc28j60 packet RX.
>   
How can I reproduce the unaligned packet oops? Did you use any utilities 
to force this condition?
> Keep enc28j60 chips in low-power mode when they're not in use.
> At typically 120 mA, these chips run hot even when idle.  Low
> power mode cuts that power usage by a factor of around 100.
>   
Good idea, but with your patch applied, after some ifconfig down - 
ifconfig up cycle, the
enc28j60 is left in an unknown state and it doesn' Rx/Tx anything.
In such cases If I dump the counters with ifconfig I got rx error 
counter > 0 and the RX and TX packets counters are freezed.
Actually I don't know what causes the freeze, it needs investigation. 
The cause can be the rx error condition or the power down/up commands.
May be receiving packets while it's going to wakeup causes problems.

Can you split the patch in 2 parts, unaligned rx and power save?

> +/*
> + * Low power mode shrinks power consumption about 100x, so we'd like
> + * the chip to be in that mode whenever it's inactive.
> + */
> +static void enc28j60_lowpower(struct enc28j60_net *priv, bool is_low)
> +{
> +	int	tmp;
> +
> +	dev_dbg(&priv->spi->dev, "%s power...\n", is_low ? "low" : "high");
>   
use
if(netif_msg_drv(priv)) printk(...
instead of dev_dbg(), please.
Doing so we can switch on/off messages runtime using ethtool.

> +
> +	mutex_lock(&priv->lock);
> +	if (is_low) {
> +		nolock_reg_bfclr(priv, ECON1, ECON1_RXEN);
> +		for (;;) {
> +			tmp = nolock_regb_read(priv, ESTAT);
> +			if (!(tmp & ESTAT_RXBUSY))
> +				break;
> +		}
>   
Avoid infinite waiting loops, please.
Look at enc28j60_phy_read() for example.
> +		for (;;) {
> +			tmp = nolock_regb_read(priv, ECON1);
> +			if (!(tmp & ECON1_TXRTS))
> +				break;
> +		}
>   
idem
> +		/* ECON2_VRPS was set during initialization */
> +		nolock_reg_bfset(priv, ECON2, ECON2_PWRSV);
> +	} else {
> +		nolock_reg_bfclr(priv, ECON2, ECON2_PWRSV);
> +		for (;;) {
> +			tmp = nolock_regb_read(priv, ESTAT);
> +			if (tmp & ESTAT_CLKRDY)
> +				break;
> +		}
>   
idem

