From: Shradha Shah <sshah@solarflare.com>
Subject: Re: [PATCH net v2] sfc: check for NULL efx->ptp_data in efx_ptp_event
Date: Wed, 26 Feb 2014 16:17:41 +0000
Message-ID: <530E13A5.8040202@solarflare.com>
References: <alpine.LFD.2.03.1402251306530.16190@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Ben Hutchings <ben@decadent.org.uk>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:20346 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752799AbaBZQRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 11:17:48 -0500
In-Reply-To: <alpine.LFD.2.03.1402251306530.16190@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/25/2014 01:17 PM, Edward Cree wrote:
> If we receive a PTP event from the NIC when we haven't set up PTP state
> in the driver, we attempt to read through a NULL pointer efx->ptp_data,
> triggering a panic.
> 
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Acked-by: Shradha Shah <sshah@solarflare.com>

> ---
> v2: resent using alpine, because Thunderbird mangled v1
> 
> While this shouldn't happen with existing released firmware, future
> sfn7322f firmware is planned to enable PPS irrespective of whether
> timestamping (and thus PTP) is enabled.  We are considering workarounds,
> but this defensive patch seemed like a good idea anyway in case the
> firmware gets in a muddle.
> Also, in principle this shouldn't happen on 3.14+ kernels as the driver
> should always set up PTP state at probe time (though there might still
> be a race against the firmware sending its first PPS), however 3.12 and
> 3.13 both supported EF10 but not PTP-on-EF10 and thus they never set up
> the PTP state; hence this fix should also be backported to those series.
> 
> --- linux-3.13/drivers/net/ethernet/sfc/ptp.c.orig	2014-01-20 02:40:07.000000000 +0000
> +++ linux-3.13/drivers/net/ethernet/sfc/ptp.c	2014-02-24 17:46:31.753497000 +0000
> @@ -1360,6 +1360,13 @@ void efx_ptp_event(struct efx_nic *efx,
>  	struct efx_ptp_data *ptp = efx->ptp_data;
>  	int code = EFX_QWORD_FIELD(*ev, MCDI_EVENT_CODE);
>  
> +	if (!ptp) {
> +		if (net_ratelimit())
> +			netif_warn(efx, drv, efx->net_dev,
> +				   "Received PTP event but PTP not set up\n");
> +		return;
> +	}
> +
>  	if (!ptp->enabled)
>  		return;
>  
> 
