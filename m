From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH v2] nohz: prevent tilegx network driver interrupts
Date: Sat, 11 Jul 2015 16:44:38 +0200
Message-ID: <20150711144436.GF10257@lerouge>
References: <55A0175E.2010200@ezchip.com>
 <1436557045-5392-1-git-send-email-cmetcalf@ezchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chris Metcalf <cmetcalf@ezchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1436557045-5392-1-git-send-email-cmetcalf@ezchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 10, 2015 at 03:37:25PM -0400, Chris Metcalf wrote:
> Normally the tilegx networking shim sends irqs to all the cores
> to distribute the load of processing incoming-packet interrupts,
> so that you can get to multiple Gb's of traffic inbound.
> 
> However, in nohz_full mode we don't want to interrupt the
> nohz_full cores by default, so we limit the set of cores we use
> to only the online housekeeping cores.
> 
> To make client code easier to read, we introduce a new nohz_full
> accessor, housekeeping_cpumask(), which returns a pointer to the
> housekeeping_mask if nohz_full is enabled, and otherwise returns
> the cpu_possible_mask.
> 
> Signed-off-by: Chris Metcalf <cmetcalf@ezchip.com>

Looks good. Since it modifies nohz core stuff, do you mind if I take it?

Thanks.

> ---
>  drivers/net/ethernet/tile/tilegx.c | 4 +++-
>  include/linux/tick.h               | 9 +++++++++
>  2 files changed, 12 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
> index a3f7610002aa..0a15acc075b3 100644
> --- a/drivers/net/ethernet/tile/tilegx.c
> +++ b/drivers/net/ethernet/tile/tilegx.c
> @@ -40,6 +40,7 @@
>  #include <linux/tcp.h>
>  #include <linux/net_tstamp.h>
>  #include <linux/ptp_clock_kernel.h>
> +#include <linux/tick.h>
>  
>  #include <asm/checksum.h>
>  #include <asm/homecache.h>
> @@ -2273,7 +2274,8 @@ static int __init tile_net_init_module(void)
>  		tile_net_dev_init(name, mac);
>  
>  	if (!network_cpus_init())
> -		network_cpus_map = *cpu_online_mask;
> +		cpumask_and(&network_cpus_map, housekeeping_cpumask(),
> +			    cpu_online_mask);
>  
>  	return 0;
>  }
> diff --git a/include/linux/tick.h b/include/linux/tick.h
> index 3741ba1a652c..d3b00f0b2221 100644
> --- a/include/linux/tick.h
> +++ b/include/linux/tick.h
> @@ -160,6 +160,15 @@ static inline void tick_nohz_full_kick_all(void) { }
>  static inline void __tick_nohz_task_switch(struct task_struct *tsk) { }
>  #endif
>  
> +static inline const struct cpumask *housekeeping_cpumask(void)
> +{
> +#ifdef CONFIG_NO_HZ_FULL
> +	if (tick_nohz_full_enabled())
> +		return housekeeping_mask;
> +#endif
> +	return cpu_possible_mask;
> +}
> +
>  static inline bool is_housekeeping_cpu(int cpu)
>  {
>  #ifdef CONFIG_NO_HZ_FULL
> -- 
> 2.1.2
> 
