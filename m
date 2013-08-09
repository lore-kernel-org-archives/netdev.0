From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH][net-next v1] gianfar: Add flow control support
Date: Fri, 09 Aug 2013 12:09:56 -0700
Message-ID: <1376075396.2087.148.camel@joe-AO722>
References: <1376036790-18238-2-git-send-email-ljaenicke@innominate.com>
	 <1376068786-29868-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Lutz Jaenicke <ljaenicke@innominate.com>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:34622 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030717Ab3HITJ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Aug 2013 15:09:57 -0400
In-Reply-To: <1376068786-29868-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-09 at 20:19 +0300, Claudiu Manoil wrote:
> eTSEC has Rx and Tx flow control capabilities that may be enabled
> through MACCFG1[Rx_Flow, Tx_Flow] bits.

Trivial note:

> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
[]
> @@ -3043,6 +3050,7 @@ static void adjust_link(struct net_device *dev)
[]
> +		u32 tempval1 = gfar_read(&regs->maccfg1);
[]
> @@ -3091,6 +3099,32 @@ static void adjust_link(struct net_device *dev)
>  			priv->oldspeed = phydev->speed;
>  		}
>  
> +		tempval1 &= ~(MACCFG1_TX_FLOW | MACCFG1_RX_FLOW);
> +		if (phydev->duplex) {
> +			if (!priv->pause_aneg_en) {
> +				if (priv->tx_pause_en)
> +					tempval1 |= MACCFG1_TX_FLOW;
> +				if (priv->rx_pause_en)
> +					tempval1 |= MACCFG1_RX_FLOW;
> +			} else {
> +				u8 flowctrl;
> +				u16 lcl_adv = mii_advertise_flowctrl(
> +						phydev->advertising);
> +				u16 rmt_adv = 0;
> +				if (phydev->pause)
> +					rmt_adv = LPA_PAUSE_CAP;
> +				if (phydev->asym_pause)
> +					rmt_adv |= LPA_PAUSE_ASYM;
> +				flowctrl = mii_resolve_flowctrl_fdx(
> +						lcl_adv, rmt_adv);
> +				if (flowctrl & FLOW_CTRL_TX)
> +					tempval1 |= MACCFG1_TX_FLOW;
> +				if (flowctrl & FLOW_CTRL_RX)
> +					tempval1 |= MACCFG1_RX_FLOW;
> +			}
> +		}

I think this bit would be nicer as a static function.

Something like: (uncompiled/untested)

static int gfar_get_cfg1(struct net_device *dev)
{
	struct gfar_private *priv = netdev_priv(dev);
	struct gfar __iomem *regs = priv->gfargrp[0].regs;
	struct phy_device *phydev = priv->phydev;
	int val;

	val = gfar_read(&regs->maccfg1);
	val &= ~(MACCFG1_TX_FLOW | MACCFG1_RX_FLOW);

	if (!phydev->duplex)
		return val;

	if (!priv->pause_aneg_en) {
		if (priv->tx_pause_en)
			val |= MACCFG1_TX_FLOW;
		if (priv->rx_pause_en)
			val |= MACCFG1_RX_FLOW;
	} else {
		u8 flowctrl;
		u16 lcl_adv = mii_advertise_flowctrl(phydev->advertising);
		u16 rmt_adv = 0;
		if (phydev->pause)
			rmt_adv = LPA_PAUSE_CAP;
		if (phydev->asym_pause)
			rmt_adv |= LPA_PAUSE_ASYM;
		flowctrl = mii_resolve_flowctrl_fdx(lcl_adv, rmt_adv);
		if (flowctrl & FLOW_CTRL_TX)
			val |= MACCFG1_TX_FLOW;
		if (flowctrl & FLOW_CTRL_RX)
			val |= MACCFG1_RX_FLOW;
	}

	return val;
}
