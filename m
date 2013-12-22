From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: Re: [PATCH net-next 1/2] mlx4_en: Add PTP hardware clock
Date: Sun, 22 Dec 2013 15:13:12 +0200
Message-ID: <52B6E568.4030400@mellanox.com>
References: <1387312359-9476-1-git-send-email-shawn.bohrer@gmail.com> <1387312359-9476-2-git-send-email-shawn.bohrer@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Richard Cochran <richardcochran@gmail.com>,
	<netdev@vger.kernel.org>, <tomk@rgmadvisors.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Shawn Bohrer <shawn.bohrer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:47237 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752290Ab3LVNO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 08:14:28 -0500
In-Reply-To: <1387312359-9476-2-git-send-email-shawn.bohrer@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/2013 10:32 PM, Shawn Bohrer wrote:
> From: Shawn Bohrer <sbohrer@rgmadvisors.com>
>
> This adds a PHC to the mlx4_en driver.  The code is largely based off of
> the e1000e driver (drivers/net/ethernet/intel/e1000e/ptp.c) which seemed
> very similar.
>
> This driver has been tested with both Documentation/ptp/testptp and the
> linuxptp project (http://linuxptp.sourceforge.net/) and appears to work
> on a Mellanox ConnectX-3 card.
>
> Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_clock.c   |  192 ++++++++++++++++++++++-
>   drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |    3 +
>   drivers/net/ethernet/mellanox/mlx4/en_main.c    |    3 +
>   drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    6 +
>   4 files changed, 196 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
> index fd64410..9b0d515 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
> @@ -103,17 +103,187 @@ void mlx4_en_fill_hwtstamps(struct mlx4_en_dev *mdev,
>   			    struct skb_shared_hwtstamps *hwts,
>   			    u64 timestamp)
>   {
> +	unsigned long flags;
>   	u64 nsec;
>
> +	spin_lock_irqsave(&mdev->clock_lock, flags);

1. Missing initialization for clock_lock
2. Adding spin lock in the data path reduce performance by 15% when HW 
timestamping is enabled. I did some testing and replacing 
spin_lock_irqsave with read/write_lock_irqsave prevents the  performance 
decrease.

Thanks,
Hadar

>   	nsec = timecounter_cyc2time(&mdev->clock, timestamp);
> +	spin_unlock_irqrestore(&mdev->clock_lock, flags);
>
>   	memset(hwts, 0, sizeof(struct skb_shared_hwtstamps));
>   	hwts->hwtstamp = ns_to_ktime(nsec);
>   }
>
> +/**
> + * mlx4_en_remove_timestamp - disable PTP device
> + * @mdev: board private structure
> + *
> + * Stop the PTP support.
> + **/
> +void mlx4_en_remove_timestamp(struct mlx4_en_dev *mdev)
> +{
> +	if (mdev->ptp_clock) {
> +		ptp_clock_unregister(mdev->ptp_clock);
> +		mdev->ptp_clock = NULL;
> +		mlx4_info(mdev, "removed PHC\n");
> +	}
> +}
> +
> +void mlx4_en_ptp_overflow_check(struct mlx4_en_dev *mdev)
> +{
> +	bool timeout = time_is_before_jiffies(mdev->last_overflow_check +
> +					      mdev->overflow_period);
> +	unsigned long flags;
> +
> +	if (timeout) {
> +		spin_lock_irqsave(&mdev->clock_lock, flags);
> +		timecounter_read(&mdev->clock);
> +		spin_unlock_irqrestore(&mdev->clock_lock, flags);
> +		mdev->last_overflow_check = jiffies;
> +	}
> +}
> +
> +/**
> + * mlx4_en_phc_adjfreq - adjust the frequency of the hardware clock
> + * @ptp: ptp clock structure
> + * @delta: Desired frequency change in parts per billion
> + *
> + * Adjust the frequency of the PHC cycle counter by the indicated delta from
> + * the base frequency.
> + **/
> +static int mlx4_en_phc_adjfreq(struct ptp_clock_info *ptp, s32 delta)
> +{
> +	u64 adj;
> +	u32 diff, mult;
> +	int neg_adj = 0;
> +	unsigned long flags;
> +	struct mlx4_en_dev *mdev = container_of(ptp, struct mlx4_en_dev,
> +						ptp_clock_info);
> +
> +	if (delta < 0) {
> +		neg_adj = 1;
> +		delta = -delta;
> +	}
> +	mult = mdev->nominal_c_mult;
> +	adj = mult;
> +	adj *= delta;
> +	diff = div_u64(adj, 1000000000ULL);
> +
> +	spin_lock_irqsave(&mdev->clock_lock, flags);
> +	timecounter_read(&mdev->clock);
> +	mdev->cycles.mult = neg_adj ? mult - diff : mult + diff;
> +	spin_unlock_irqrestore(&mdev->clock_lock, flags);
> +
> +	return 0;
> +}
> +
> +/**
> + * mlx4_en_phc_adjtime - Shift the time of the hardware clock
> + * @ptp: ptp clock structure
> + * @delta: Desired change in nanoseconds
> + *
> + * Adjust the timer by resetting the timecounter structure.
> + **/
> +static int mlx4_en_phc_adjtime(struct ptp_clock_info *ptp, s64 delta)
> +{
> +	struct mlx4_en_dev *mdev = container_of(ptp, struct mlx4_en_dev,
> +						ptp_clock_info);
> +	unsigned long flags;
> +	s64 now;
> +
> +	spin_lock_irqsave(&mdev->clock_lock, flags);
> +	now = timecounter_read(&mdev->clock);
> +	now += delta;
> +	timecounter_init(&mdev->clock, &mdev->cycles, now);
> +	spin_unlock_irqrestore(&mdev->clock_lock, flags);
> +
> +	return 0;
> +}
> +
> +/**
> + * mlx4_en_phc_gettime - Reads the current time from the hardware clock
> + * @ptp: ptp clock structure
> + * @ts: timespec structure to hold the current time value
> + *
> + * Read the timecounter and return the correct value in ns after converting
> + * it into a struct timespec.
> + **/
> +static int mlx4_en_phc_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
> +{
> +	struct mlx4_en_dev *mdev = container_of(ptp, struct mlx4_en_dev,
> +						ptp_clock_info);
> +	unsigned long flags;
> +	u32 remainder;
> +	u64 ns;
> +
> +	spin_lock_irqsave(&mdev->clock_lock, flags);
> +	ns = timecounter_read(&mdev->clock);
> +	spin_unlock_irqrestore(&mdev->clock_lock, flags);
> +
> +	ts->tv_sec = div_u64_rem(ns, NSEC_PER_SEC, &remainder);
> +	ts->tv_nsec = remainder;
> +
> +	return 0;
> +}
> +
> +/**
> + * mlx4_en_phc_settime - Set the current time on the hardware clock
> + * @ptp: ptp clock structure
> + * @ts: timespec containing the new time for the cycle counter
> + *
> + * Reset the timecounter to use a new base value instead of the kernel
> + * wall timer value.
> + **/
> +static int mlx4_en_phc_settime(struct ptp_clock_info *ptp,
> +			       const struct timespec *ts)
> +{
> +	struct mlx4_en_dev *mdev = container_of(ptp, struct mlx4_en_dev,
> +						ptp_clock_info);
> +	u64 ns = timespec_to_ns(ts);
> +	unsigned long flags;
> +
> +	/* reset the timecounter */
> +	spin_lock_irqsave(&mdev->clock_lock, flags);
> +	timecounter_init(&mdev->clock, &mdev->cycles, ns);
> +	spin_unlock_irqrestore(&mdev->clock_lock, flags);
> +
> +	return 0;
> +}
> +
> +/**
> + * mlx4_en_phc_enable - enable or disable an ancillary feature
> + * @ptp: ptp clock structure
> + * @request: Desired resource to enable or disable
> + * @on: Caller passes one to enable or zero to disable
> + *
> + * Enable (or disable) ancillary features of the PHC subsystem.
> + * Currently, no ancillary features are supported.
> + **/
> +static int mlx4_en_phc_enable(struct ptp_clock_info __always_unused *ptp,
> +			      struct ptp_clock_request __always_unused *request,
> +			      int __always_unused on)
> +{
> +	return -EOPNOTSUPP;
> +}
> +
> +static const struct ptp_clock_info mlx4_en_ptp_clock_info = {
> +	.owner		= THIS_MODULE,
> +	.max_adj	= 100000000,
> +	.n_alarm	= 0,
> +	.n_ext_ts	= 0,
> +	.n_per_out	= 0,
> +	.pps		= 0,
> +	.adjfreq	= mlx4_en_phc_adjfreq,
> +	.adjtime	= mlx4_en_phc_adjtime,
> +	.gettime	= mlx4_en_phc_gettime,
> +	.settime	= mlx4_en_phc_settime,
> +	.enable		= mlx4_en_phc_enable,
> +};
> +
>   void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev)
>   {
>   	struct mlx4_dev *dev = mdev->dev;
> +	unsigned long flags;
>   	u64 ns;
>
>   	memset(&mdev->cycles, 0, sizeof(mdev->cycles));
> @@ -127,9 +297,12 @@ void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev)
>   	mdev->cycles.shift = 14;
>   	mdev->cycles.mult =
>   		clocksource_khz2mult(1000 * dev->caps.hca_core_clock, mdev->cycles.shift);
> +	mdev->nominal_c_mult = mdev->cycles.mult;
>
> +	spin_lock_irqsave(&mdev->clock_lock, flags);
>   	timecounter_init(&mdev->clock, &mdev->cycles,
>   			 ktime_to_ns(ktime_get_real()));
> +	spin_unlock_irqrestore(&mdev->clock_lock, flags);
>
>   	/* Calculate period in seconds to call the overflow watchdog - to make
>   	 * sure counter is checked at least once every wrap around.
> @@ -137,15 +310,18 @@ void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev)
>   	ns = cyclecounter_cyc2ns(&mdev->cycles, mdev->cycles.mask);
>   	do_div(ns, NSEC_PER_SEC / 2 / HZ);
>   	mdev->overflow_period = ns;
> -}
>
> -void mlx4_en_ptp_overflow_check(struct mlx4_en_dev *mdev)
> -{
> -	bool timeout = time_is_before_jiffies(mdev->last_overflow_check +
> -					      mdev->overflow_period);
> +	/* Configure the PHC */
> +	mdev->ptp_clock_info = mlx4_en_ptp_clock_info;
> +	snprintf(mdev->ptp_clock_info.name, 16, "mlx4 ptp");
>
> -	if (timeout) {
> -		timecounter_read(&mdev->clock);
> -		mdev->last_overflow_check = jiffies;
> +	mdev->ptp_clock = ptp_clock_register(&mdev->ptp_clock_info,
> +					     &mdev->pdev->dev);
> +	if (IS_ERR(mdev->ptp_clock)) {
> +		mdev->ptp_clock = NULL;
> +		mlx4_err(mdev, "ptp_clock_register failed\n");
> +	} else {
> +		mlx4_info(mdev, "registered PHC clock\n");
>   	}
> +
>   }
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> index 0596f9f..3e8d336 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> @@ -1193,6 +1193,9 @@ static int mlx4_en_get_ts_info(struct net_device *dev,
>   		info->rx_filters =
>   			(1 << HWTSTAMP_FILTER_NONE) |
>   			(1 << HWTSTAMP_FILTER_ALL);
> +
> +		if (mdev->ptp_clock)
> +			info->phc_index = ptp_clock_index(mdev->ptp_clock);
>   	}
>
>   	return ret;
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
> index 0d087b0..6268057 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
> @@ -196,6 +196,9 @@ static void mlx4_en_remove(struct mlx4_dev *dev, void *endev_ptr)
>   		if (mdev->pndev[i])
>   			mlx4_en_destroy_netdev(mdev->pndev[i]);
>
> +	if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_TS)
> +		mlx4_en_remove_timestamp(mdev);
> +
>   	flush_workqueue(mdev->workqueue);
>   	destroy_workqueue(mdev->workqueue);
>   	(void) mlx4_mr_free(dev, &mdev->mr);
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> index f3758de..2b4083f 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> @@ -45,6 +45,7 @@
>   #include <linux/dcbnl.h>
>   #endif
>   #include <linux/cpu_rmap.h>
> +#include <linux/ptp_clock_kernel.h>
>
>   #include <linux/mlx4/device.h>
>   #include <linux/mlx4/qp.h>
> @@ -373,10 +374,14 @@ struct mlx4_en_dev {
>   	u32                     priv_pdn;
>   	spinlock_t              uar_lock;
>   	u8			mac_removed[MLX4_MAX_PORTS + 1];
> +	spinlock_t		clock_lock;
> +	u32			nominal_c_mult;
>   	struct cyclecounter	cycles;
>   	struct timecounter	clock;
>   	unsigned long		last_overflow_check;
>   	unsigned long		overflow_period;
> +	struct ptp_clock	*ptp_clock;
> +	struct ptp_clock_info	ptp_clock_info;
>   };
>
>
> @@ -786,6 +791,7 @@ void mlx4_en_fill_hwtstamps(struct mlx4_en_dev *mdev,
>   			    struct skb_shared_hwtstamps *hwts,
>   			    u64 timestamp);
>   void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev);
> +void mlx4_en_remove_timestamp(struct mlx4_en_dev *mdev);
>   int mlx4_en_timestamp_config(struct net_device *dev,
>   			     int tx_type,
>   			     int rx_filter);
>
