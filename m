From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] davinci_emac: Add cpu_freq support
Date: Mon, 9 Apr 2012 16:56:18 +0100
Message-ID: <1333986978.7150.261.camel@deadeye>
References: <1333968549-3282-1-git-send-email-prakash.pm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>,
	<davinci-linux-open-source@linux.davincidsp.com>
To: "Manjunathappa, Prakash" <prakash.pm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:23920 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S932104Ab2DIP4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2012 11:56:24 -0400
In-Reply-To: <1333968549-3282-1-git-send-email-prakash.pm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-09 at 16:19 +0530, Manjunathappa, Prakash wrote:
> Reconfigure interrupt coalesce parameter for changed emac bus_freq
> due to DVFS.
> 
> Signed-off-by: Manjunathappa, Prakash <prakash.pm@ti.com>
> ---
>  drivers/net/ethernet/ti/davinci_emac.c |   60 ++++++++++++++++++++++++++++++++
>  1 files changed, 60 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
> index 174a334..11d3bd7 100644
> --- a/drivers/net/ethernet/ti/davinci_emac.c
> +++ b/drivers/net/ethernet/ti/davinci_emac.c
> @@ -50,6 +50,7 @@
>  #include <linux/ctype.h>
>  #include <linux/spinlock.h>
>  #include <linux/dma-mapping.h>
> +#include <linux/cpufreq.h>
>  #include <linux/clk.h>
>  #include <linux/platform_device.h>
>  #include <linux/semaphore.h>
> @@ -344,6 +345,9 @@ struct emac_priv {
>  	/*platform specific members*/
>  	void (*int_enable) (void);
>  	void (*int_disable) (void);
> +#ifdef CONFIG_CPU_FREQ
> +	struct notifier_block	freq_transition;
> +#endif
>  };
>  
>  /* clock frequency for EMAC */
> @@ -1761,6 +1765,46 @@ static const struct net_device_ops emac_netdev_ops = {
>  #endif
>  };
>  
> +#ifdef CONFIG_CPU_FREQ
> +static int davinci_emac_cpufreq_transition(struct notifier_block *nb,
> +				     unsigned long val, void *data)
> +{
> +	int ret = 0;
> +	struct emac_priv *priv;
> +
> +	priv = container_of(nb, struct emac_priv, freq_transition);
> +	if (priv->coal_intvl != 0) {
> +		if (val == CPUFREQ_POSTCHANGE) {
> +			if (emac_bus_frequency != clk_get_rate(emac_clk)) {
> +				struct ethtool_coalesce coal;
> +
> +				emac_bus_frequency = clk_get_rate(emac_clk);
> +
> +				priv->bus_freq_mhz = (u32)(emac_bus_frequency /
> +						1000000);
> +				coal.rx_coalesce_usecs = (priv->coal_intvl
> +						<< 4);
> +				ret = emac_set_coalesce(priv->ndev, &coal);
[...]

Ick.  Why don't you break up emac_set_coalesce() so that you can push
this one value to the hardware without faking up a struct
ethtool_coalesce?  Don't you need to push it on reset/resume anyway?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
