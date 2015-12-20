From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V1 3/4] net/mlx5e: Add HW timestamping (TS) support
Date: Sun, 20 Dec 2015 15:08:18 +0200
Message-ID: <CALzJLG_PdkDNnHVfV5XsD0pGJ5MXx7Tb-4kuLSFq3o4P2dG8KA@mail.gmail.com>
References: <1450355735-30846-1-git-send-email-saeedm@mellanox.com>
	<1450355735-30846-4-git-send-email-saeedm@mellanox.com>
	<20151217201154.GA5975@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:36663 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754422AbbLTNIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Dec 2015 08:08:19 -0500
Received: by mail-yk0-f171.google.com with SMTP id x184so107670628yka.3
        for <netdev@vger.kernel.org>; Sun, 20 Dec 2015 05:08:18 -0800 (PST)
In-Reply-To: <20151217201154.GA5975@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2015 at 10:11 PM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Thu, Dec 17, 2015 at 02:35:34PM +0200, Saeed Mahameed wrote:
>> @@ -63,6 +65,7 @@
>>  #define MLX5E_TX_CQ_POLL_BUDGET        128
>>  #define MLX5E_UPDATE_STATS_INTERVAL    200 /* msecs */
>>  #define MLX5E_SQ_BF_BUDGET             16
>> +#define MLX5E_SERVICE_TASK_DELAY       (HZ / 4)
>
> Hm...
>
>> +void mlx5e_timestamp_overflow_check(struct mlx5e_priv *priv)
>> +{
>> +     bool timeout = time_is_before_jiffies(priv->tstamp.last_overflow_check +
>> +                                           priv->tstamp.overflow_period);
>> +     unsigned long flags;
>> +
>> +     if (timeout) {
>> +             write_lock_irqsave(&priv->tstamp.lock, flags);
>> +             timecounter_read(&priv->tstamp.clock);
>> +             write_unlock_irqrestore(&priv->tstamp.lock, flags);
>> +             priv->tstamp.last_overflow_check = jiffies;
>
> Here you have extra book keeping, because the rate of the work
> callbacks is not the same as the rate of the overflow checks.
>
>> +     }
>> +}
>
>> +void mlx5e_timestamp_init(struct mlx5e_priv *priv)
>> +{
>> +     struct mlx5e_tstamp *tstamp = &priv->tstamp;
>> +     u64 ns;
>> +     u64 frac = 0;
>> +     u32 dev_freq;
>> +
>> +     mlx5e_timestamp_init_config(tstamp);
>> +     dev_freq = MLX5_CAP_GEN(priv->mdev, device_frequency_khz);
>> +     if (!dev_freq) {
>> +             mlx5_core_warn(priv->mdev, "invalid device_frequency_khz. %s failed\n",
>> +                            __func__);
>> +             return;
>> +     }
>> +     rwlock_init(&tstamp->lock);
>> +     memset(&tstamp->cycles, 0, sizeof(tstamp->cycles));
>> +     tstamp->cycles.read = mlx5e_read_clock;
>> +     tstamp->cycles.shift = MLX5E_CYCLES_SHIFT;
>> +     tstamp->cycles.mult = clocksource_khz2mult(dev_freq,
>> +                                                tstamp->cycles.shift);
>> +     tstamp->nominal_c_mult = tstamp->cycles.mult;
>> +     tstamp->cycles.mask = CLOCKSOURCE_MASK(41);
>> +
>> +     timecounter_init(&tstamp->clock, &tstamp->cycles,
>> +                      ktime_to_ns(ktime_get_real()));
>> +
>> +     /* Calculate period in seconds to call the overflow watchdog - to make
>> +      * sure counter is checked at least once every wrap around.
>> +      */
>> +     ns = cyclecounter_cyc2ns(&tstamp->cycles, tstamp->cycles.mask, frac,
>> +                              &frac);
>> +     do_div(ns, NSEC_PER_SEC / 2 / HZ);
>> +     tstamp->overflow_period = ns;
>> +}
>
> And here you take great pains to calculate the rate of overflow checks...
>
>> +/* mlx5e_service_task - Run service task for tasks that needed to be done
>> + * periodically
>> + */
>> +static void mlx5e_service_task(struct work_struct *work)
>> +{
>> +     struct delayed_work *dwork = to_delayed_work(work);
>> +     struct mlx5e_priv *priv = container_of(dwork, struct mlx5e_priv,
>> +                                            service_task);
>> +
>> +     mutex_lock(&priv->state_lock);
>> +     if (test_bit(MLX5E_STATE_OPENED, &priv->state) &&
>> +         !test_bit(MLX5E_STATE_DESTROYING, &priv->state)) {
>> +             if (MLX5_CAP_GEN(priv->mdev, device_frequency_khz)) {
>> +                     mlx5e_timestamp_overflow_check(priv);
>> +                     /* Only mlx5e_timestamp_overflow_check is called from
>> +                      * this service task. schedule a new task only if clock
>> +                      * is initialized. if changed, move the scheduler.
>> +                      */
>> +                     schedule_delayed_work(dwork, MLX5E_SERVICE_TASK_DELAY);
>
> Why not simply use the rate you calculated, rather than some hard
> coded value?
>

This task was made to serve several kinds of tasks, currently its only
purpose is to serve the overflow check,
We will make it specific to overflow check for now and will use a more
accurate delay.

> Consider What happens if MLX5E_SERVICE_TASK_DELAY is too long or way
> too short.
>

Agree, but what will happen if the calculated period is too rapid ?
shouldn't we have some kind of minimum ?


>> +             }
>> +     }
>> +     mutex_unlock(&priv->state_lock);
>> +}
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
