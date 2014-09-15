From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next 4/4] net: fec: Workaround for imx6sx enet tx
 hang when enable three queues
Date: Mon, 15 Sep 2014 17:35:09 -0400 (EDT)
Message-ID: <20140915.173509.929057672166230893.davem@davemloft.net>
References: <1410801177-15872-1-git-send-email-Frank.Li@freescale.com>
	<1410801177-15872-5-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b38611@freescale.com, netdev@vger.kernel.org, lznuaa@gmail.com,
	shawn.guo@linaro.org, linux-arm-kernel@lists.infradead.org
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40034 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755540AbaIOVfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 17:35:12 -0400
In-Reply-To: <1410801177-15872-5-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Frank.Li@freescale.com>
Date: Tue, 16 Sep 2014 01:12:57 +0800

> @@ -111,6 +111,13 @@ static void fec_enet_itr_coal_init(struct net_device *ndev);
>   *   independent rings
>   */
>  #define FEC_QUIRK_HAS_AVB		(1 << 8)
> +/*
> + * There is a TDAR race condition for mutliQ when the software sets TDAR
> + * and the UDMA clears TDAR simultaneously or in a small window (2-4 cycles).
> + * This will cause the udma_tx and udma_tx_arbiter state machines to hang.
> + * The issue exist at i.MX6SX enet IP.
> + */
> +#define FEC_QUIRK_TKT210582		(1 << 9)

Networking comments should be of the form:

	/* Like
	 * this.
	 */

>  	/* Trigger transmission start */
> -	writel(0, fep->hwp + FEC_X_DES_ACTIVE(queue));
> +	if (!(id_entry->driver_data & FEC_QUIRK_TKT210582) ||
> +		!readl(fep->hwp + FEC_X_DES_ACTIVE(queue)) ||
> +		!readl(fep->hwp + FEC_X_DES_ACTIVE(queue)) ||
> +		!readl(fep->hwp + FEC_X_DES_ACTIVE(queue)) ||
> +		!readl(fep->hwp + FEC_X_DES_ACTIVE(queue)))
> +		writel(0, fep->hwp + FEC_X_DES_ACTIVE(queue));

This conditional is not indented properly, see my feedback for patch #2.
