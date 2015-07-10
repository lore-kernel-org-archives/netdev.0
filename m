From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH] nohz: prevent tilegx network driver interrupts
Date: Fri, 10 Jul 2015 20:24:07 +0200
Message-ID: <20150710182406.GC26428@lerouge>
References: <1436549624-16104-1-git-send-email-cmetcalf@ezchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chris Metcalf <cmetcalf@ezchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:36101 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932290AbbGJSYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 14:24:11 -0400
Content-Disposition: inline
In-Reply-To: <1436549624-16104-1-git-send-email-cmetcalf@ezchip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 10, 2015 at 01:33:44PM -0400, Chris Metcalf wrote:
> In nohz_full mode, by default distribute networking shim
> interrupts across the housekeeping cores, not all the cores.

I can't really tell, I have no idea what this driver does. It seems
to be about networking CPUs but I have no idea what we are affining
here. Whether it is task, interrupt, ... And what those affine things do,
if it is safe to do that reduce affinity etc..

I looked at the driver but I can't make my way there. I think you
need a more detailed changelog :-)

> Signed-off-by: Chris Metcalf <cmetcalf@ezchip.com>
> ---
> The alternate approaches to this might be:
> 
> 1. "#define housekeeping_mask cpu_online_mask" in the non-nohz_full
>    arm in <linux/tick.h>, then just unconditionally use
>    "housekeeping_mask".

Indeed we are doing more and more references on housekeeping_mask, so
we should probably think about an off-case.

Now the nohz-full off-case should rather be cpu_possible_mask than
cpu_online_mask. housekeeping_mask doesn't take into account onlining
at all.

> 
> 2. Provide an accessor that returns the cpumask to use for housekeeping
>    chores and implement it in the obvious ways for both nohz_full
>    and non-nohz_full.
> 
> The latter seems like arguably the most satisfying approach, but
> the patch below is, if nothing else, suitable to push for 4.3
> without any further API development work.

I don't know. 1) looks easier.

> 
> Frederic (or others), comments?
> 
>  drivers/net/ethernet/tile/tilegx.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
> index a3f7610002aa..7687c62e7d75 100644
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
> @@ -2272,8 +2273,13 @@ static int __init tile_net_init_module(void)
>  	for (i = 0; gxio_mpipe_link_enumerate_mac(i, name, mac) >= 0; i++)
>  		tile_net_dev_init(name, mac);
>  
> -	if (!network_cpus_init())
> +	if (!network_cpus_init()) {
> +#ifdef CONFIG_NO_HZ_FULL
> +		network_cpus_map = *housekeeping_mask;
> +#else
>  		network_cpus_map = *cpu_online_mask;
> +#endif
> +	}
>  
>  	return 0;
>  }
> -- 
> 2.1.2
> 
