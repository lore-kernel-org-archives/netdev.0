From: Roland Stigge <stigge@antcom.de>
Subject: Re: [PATCH v4] lpc32xx: Added ethernet driver
Date: Tue, 06 Mar 2012 09:53:45 +0100
Message-ID: <4F55D099.5070006@antcom.de>
References: <1330983641-32622-1-git-send-email-stigge@antcom.de> <1330987524.2538.61.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	alexander.h.duyck@intel.com, eilong@broadcom.com,
	ian.campbell@citrix.com, netdev@vger.kernel.org,
	w.sang@pengutronix.de, linux-kernel@vger.kernel.org,
	kevin.wells@nxp.com, linux-arm-kernel@lists.infradead.org,
	arnd@arndb.de, baruch@tkos.co.il, joe@perches.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from antcom.de ([188.40.178.216]:34086 "EHLO chuck.antcom.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758649Ab2CFIxt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2012 03:53:49 -0500
In-Reply-To: <1330987524.2538.61.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

thank you for your review!

On 03/05/2012 11:45 PM, Ben Hutchings wrote:
> [...]
>> +static int lpc_eth_poll(struct napi_struct *napi, int budget)
>> +{
>> +	struct netdata_local *pldat = container_of(napi,
>> +			struct netdata_local, napi);
>> +	struct net_device *ndev = pldat->ndev;
>> +	unsigned long flags;
>> +	int rx_done = 0;
>> +
>> +	spin_lock_irqsave(&pldat->lock, flags);
>> +
>> +	__lpc_handle_xmit(ndev);
>> +	rx_done = __lpc_handle_recv(ndev, budget);
>> +
>> +	if (rx_done < budget) {
>> +		napi_complete(napi);
>> +		lpc_eth_enable_int(pldat->net_base);
>> +	}
>> +
>> +	spin_unlock_irqrestore(&pldat->lock, flags);
>
> This is really sad.  You implement NAPI but then take away most of the
> benefits of that by disabling interrupts.
>
> It looks like you could safely unlock pldat->lock before calling
> __lpc_handle_recv - nothing else manipulates RX queue state so no lock
> is required.
>
> As for the TX side, you can probably use the TX queue lock
> (__netif_tx_lock, __netif_tx_unlock) to serialise with
> lpc_eth_hard_start_xmit() and avoid taking pldat->lock in either
> __lpc_handle_xmit() or here.

Sounds reasonable, and will do it.

However, I implemented it from the example of
drivers/net/ethernet/via/via-velocity.c:velocity_poll() - is there a
good reason for doing it that way in the velocity driver or is it done
incorrectly there, also?

Thanks,

Roland
