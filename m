From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8] New driver "sfc" for Solarstorm SFC4000 controller
 (try #8)
Date: Sun, 23 Mar 2008 22:32:38 -0700 (PDT)
Message-ID: <20080323.223238.86781188.davem@davemloft.net>
References: <20080312012102.GB24160@solarflare.com>
	<20080312012246.GC24160@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	jgarzik@pobox.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54684
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752107AbYCXFcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 01:32:39 -0400
In-Reply-To: <20080312012246.GC24160@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 12 Mar 2008 01:22:48 +0000

> +static void efx_link_status_changed(struct efx_nic *efx)
> +{
> +	unsigned long flags __attribute__ ((unused));

Please just delete this variable, it really is never
used not matter what the build configuration.

> +
> +		if (rss_cpus == 0) {
> +#ifdef topology_core_siblings
> +			cpumask_t core_mask;
> +			int cpu;
> +
> +			cpus_clear(core_mask);
> +			efx->rss_queues = 0;
> +			for_each_online_cpu(cpu) {
> +				if (!cpu_isset(cpu, core_mask)) {
> +					++efx->rss_queues;
> +					cpus_or(core_mask, core_mask,
> +						topology_core_siblings(cpu));
> +				}
> +			}
> +#else
> +			efx->rss_queues = num_online_cpus();
> +#endif

Please don't test feature availability this way.

Either use the proper CONFIG_* option ifdef.

Or if this is some feature which is not merged yet, remove
this code and add it back once that necessary feature is
added upstream.

> +/* Allocate the NAPI dev's.
> + * Called after we know how many channels there are.
> + */
> +static int efx_init_napi(struct efx_nic *efx)
> +{
> +	struct efx_channel *channel;
> +	int rc;
> +
> +	/* Allocate the NAPI dev for the port */
> +	efx->net_dev = alloc_etherdev(0);
> +	if (!efx->net_dev) {
> +		rc = -ENOMEM;
> +		goto err;
> +	}
> +	efx->net_dev->priv = efx;
> +	efx->mii.dev = efx->net_dev;

Please use alloc_etherdev() how is was designed, by
specifying sizeof(struct efx_nic) as the size argument
and that way your private area gets setup transparently
and none of these explicit assignments are necessary.

> +static int efx_reset(struct efx_nic *efx)
> +{
> +	struct ethtool_cmd ecmd;
> +	unsigned long flags __attribute__ ((unused));
> +	enum reset_type method = efx->reset_pending;
> +	int rc;

Like the other case, remove this truly unused
"flags" thing.

If you are doing this because some macro references
this local variable without an explicit reference in
the code or the calls to it, you need to fix that.

Otherwise the rest of this part looks OK.
