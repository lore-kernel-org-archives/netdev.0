From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] benet: use do_div() for 64 bit divide
Date: Thu, 26 Mar 2009 13:10:11 -0700
Message-ID: <49CBE123.5030204@oracle.com>
References: <20090326190130.54fc6fde.sfr@canb.auug.org.au>	<49CBA351.2000007@oracle.com> <20090326123005.34acd9fe@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Sathya Perla <sathyap@serverengines.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, netdev@vger.kernel.org,
	linux-drivers@serverengines.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090326123005.34acd9fe@s6510>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> The benet driver is doing a 64 bit divide, which is not supported in Linux kernel
> on 32 bit architectures. The correct way to do this is to use do_div().
> Compile tested on i386 only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Acked-by: Randy Dunlap <randy.dunlap@oracle.com> # and Tested-by: (built)

Thanks.

> --- a/drivers/net/benet/be_main.c	2009-03-25 15:31:35.000000000 -0700
> +++ b/drivers/net/benet/be_main.c	2009-03-26 12:28:21.645388379 -0700
> @@ -16,6 +16,7 @@
>   */
>  
>  #include "be.h"
> +#include <asm/div64.h>
>  
>  MODULE_VERSION(DRV_VER);
>  MODULE_DEVICE_TABLE(pci, be_dev_ids);
> @@ -290,6 +291,17 @@ static struct net_device_stats *be_get_s
>  	return &adapter->stats.net_stats;
>  }
>  
> +static u32 be_calc_rate(u64 bytes, unsigned long ticks)
> +{
> +	u64 rate = bytes;
> +
> +	do_div(rate, ticks / HZ);
> +	rate <<= 3;			/* bytes/sec -> bits/sec */
> +	do_div(rate, 1000000ul);	/* MB/Sec */
> +
> +	return rate;
> +}
> +
>  static void be_tx_rate_update(struct be_adapter *adapter)
>  {
>  	struct be_drvr_stats *stats = drvr_stats(adapter);
> @@ -303,11 +315,9 @@ static void be_tx_rate_update(struct be_
>  
>  	/* Update tx rate once in two seconds */
>  	if ((now - stats->be_tx_jiffies) > 2 * HZ) {
> -		u32 r;
> -		r = (stats->be_tx_bytes - stats->be_tx_bytes_prev) /
> -			((now - stats->be_tx_jiffies) / HZ);
> -		r = r / 1000000;			/* M bytes/s */
> -		stats->be_tx_rate = r * 8;	/* M bits/s */
> +		stats->be_tx_rate = be_calc_rate(stats->be_tx_bytes
> +						  - stats->be_tx_bytes_prev,
> +						 now - stats->be_tx_jiffies);
>  		stats->be_tx_jiffies = now;
>  		stats->be_tx_bytes_prev = stats->be_tx_bytes;
>  	}
> @@ -599,7 +609,6 @@ static void be_rx_rate_update(struct be_
>  {
>  	struct be_drvr_stats *stats = drvr_stats(adapter);
>  	ulong now = jiffies;
> -	u32 rate;
>  
>  	/* Wrapped around */
>  	if (time_before(now, stats->be_rx_jiffies)) {
> @@ -610,11 +619,10 @@ static void be_rx_rate_update(struct be_
>  	/* Update the rate once in two seconds */
>  	if ((now - stats->be_rx_jiffies) < 2 * HZ)
>  		return;
> -
> -	rate = (stats->be_rx_bytes - stats->be_rx_bytes_prev) /
> -		((now - stats->be_rx_jiffies) / HZ);
> -	rate = rate / 1000000;	/* MB/Sec */
> -	stats->be_rx_rate = rate * 8; 	/* Mega Bits/Sec */
> +
> +	stats->be_rx_rate = be_calc_rate(stats->be_rx_bytes
> +					  - stats->be_rx_bytes_prev,
> +					 now - stats->be_rx_jiffies);
>  	stats->be_rx_jiffies = now;
>  	stats->be_rx_bytes_prev = stats->be_rx_bytes;
>  }
> 


-- 
~Randy
