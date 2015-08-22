From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v3 4/4] Enabling hardware supported PTP system/device
 crosstimestamping
Date: Sat, 22 Aug 2015 22:46:19 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1508222233580.3873@nanos>
References: <1440183128-1384-1-git-send-email-christopher.s.hall@intel.com> <1440183128-1384-5-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jeffrey.t.kirsher@intel.com, hpa@zytor.com, mingo@redhat.com,
	john.stultz@linaro.org, richardcochran@gmail.com, x86@kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, peterz@infradead.org
To: "Christopher S. Hall" <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440183128-1384-5-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 21 Aug 2015, Christopher S. Hall wrote:
> From: Christopher Hall <christopher.s.hall@intel.com>
> 
> Add getsynctime() PTP device callback to cross timestamp system device
> 	clock using ART	translation depends on platform being >= SPT
> 	and having ART
> 
> getsynctime() reads ART (TSC-derived)/device cross timestamp and
> 	converts to realtime/device time reporting cross timestamp to
> 	PTP driver

See patch 1/4
 
> index 25a0ad5..228f3f3 100644
> --- a/drivers/net/ethernet/intel/e1000e/ptp.c
> +++ b/drivers/net/ethernet/intel/e1000e/ptp.c
> @@ -25,6 +25,8 @@
>   */
>  
>  #include "e1000.h"
> +#include <asm/tsc.h>
> +#include <linux/timekeeping.h>

The usual way to order includes is:

#include <linux/timekeeping.h>

#include <asm/tsc.h>

#include "e1000.h"

> +/**
> + * e1000e_phc_getsynctime - Reads the current time from the hardware clock and
> + * correlated system time
> + * @ptp: ptp clock structure
> + * @devts: timespec structure to hold the current device time value
> + * @systs: timespec structure to hold the current system time value
> + *
> + * Read device and system (ART) clock simultaneously and return the correct
> + * clock values in ns after converting into a struct timespec.
> + **/
> +static int e1000e_phc_getsynctime(struct ptp_clock_info *ptp,
> +				  struct timespec64 *devts,
> +				  struct timespec64 *systs)
> +{
> +	struct e1000_adapter *adapter = container_of(ptp, struct e1000_adapter,
> +						     ptp_clock_info);
> +	unsigned long flags;
> +	u32 remainder;
> +	struct correlated_ts art_correlated_ts;
> +	u64 device_time;
> +	int ret;
> +
> +	art_correlated_ts.get_ts = e1000e_phc_get_ts;
> +	art_correlated_ts.private = adapter;
> +	ret = get_correlated_timestamp(&art_correlated_ts,
> +				       &art_timestamper);

Pointless line break

> +	if (ret != 0)
> +		goto bail;

What's the purpose of this goto?

       if (ret)
		return ret;

is completely sufficient.

> +
> +	systs->tv_sec =
> +		div_u64_rem(art_correlated_ts.system_real.tv64,
> +			    NSEC_PER_SEC, &remainder);
> +	systs->tv_nsec = remainder;

ktime_to_timespec64() perhaps?

And please move that conversion to the ptp ioctl

> +	spin_lock_irqsave(&adapter->systim_lock, flags);
> +	device_time = timecounter_cyc2time(&adapter->tc,
> +					   art_correlated_ts.device_ts);

....

> +	/* CPU must have ART and GBe must be from Sunrise Point or greater */
> +	if (hw->mac.type < e1000_pch_spt || !cpu_has_art)
> +		adapter->ptp_clock_info.getsynctime64 = NULL;

We do it the other way round. We leave the default NULL and update it
if we detect the feature.

Thanks,

	tglx
