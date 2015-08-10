From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 4/4] Added getsynctime64() callback
Date: Mon, 10 Aug 2015 10:49:49 +0200
Message-ID: <20150810084949.GA18566@localhost.localdomain>
References: <1438988495-9942-1-git-send-email-christopher.s.hall@intel.com>
 <1438988495-9942-5-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.stultz@linaro.org, tglx@linutronix.de, mingo@redhat.com,
	jeffrey.t.kirsher@intel.com, john.ronciak@intel.com, hpa@zytor.com,
	x86@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Christopher Hall <christopher.s.hall@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1438988495-9942-5-git-send-email-christopher.s.hall@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 07, 2015 at 04:01:35PM -0700, Christopher Hall wrote:
> --- a/drivers/net/ethernet/intel/e1000e/defines.h
> +++ b/drivers/net/ethernet/intel/e1000e/defines.h
> @@ -527,6 +527,13 @@
>  #define E1000_RXCW_C          0x20000000        /* Receive config */
>  #define E1000_RXCW_SYNCH      0x40000000        /* Receive config synch */
>  
> +/* HH Time Sync */
> +#define E1000_TSYNCTXCTL_MAX_ALLOWED_DLY_MASK   0x0000F000      /* max delay */
> +#define E1000_TSYNCTXCTL_SYNC_COMP              0x40000000      /* sync complete
> + */
> +#define E1000_TSYNCTXCTL_START_SYNC             0x80000000      /* initiate sync
> + */

Split comment looks bad.  Trim this leading space instead.   ^^^^^^

> @@ -98,6 +100,91 @@ static int e1000e_phc_adjtime(struct ptp_clock_info *ptp, s64 delta)
>  	return 0;
>  }
>  
> +#define HW_WAIT_COUNT (2)
> +#define HW_RETRY_COUNT (2)

A busy wait, plus a retry, ...

> +#define SYNCTIME_RETRY_COUNT (2)

plus another retry!

Seems a bit heavy handed to me.  Is the HW really that flakey?

I would expect that a reasonably long polling loop should be
sufficient.  If not, then the HW ignores certain requests, and that is
worth a comment.

In any case, I don't understand why you have two nested retry loops.

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
> +	int i, ret;
> +
> +	if (!cpu_has_art)
> +		return -EOPNOTSUPP;

Perform this check before registration, setting .getsynctime64
accordingly.

Thanks,
Richard
