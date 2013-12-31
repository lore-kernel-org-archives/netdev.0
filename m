From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND v4 net-next] net: pkt_sched: PIE AQM scheme
Date: Tue, 31 Dec 2013 00:03:01 -0500 (EST)
Message-ID: <20131231.000301.890578431556006541.davem@davemloft.net>
References: <52b4c162.06d8440a.4580.7da8@mx.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	eric.dumazet@gmail.com, mysuryan@cisco.com,
	dave.taht@bufferbloat.net
To: subramanian.vijay@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58784 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750746Ab3LaFFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 00:05:35 -0500
In-Reply-To: <52b4c162.06d8440a.4580.7da8@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: subramanian.vijay@gmail.com
Date: Fri, 20 Dec 2013 14:10:12 -0800

> --- a/include/uapi/linux/pkt_sched.h
> +++ b/include/uapi/linux/pkt_sched.h
> @@ -815,4 +815,29 @@ struct tc_hhf_xstats {
>  	__u32	hh_tot_count;   /* number of captured heavy-hitters so far */
>  	__u32	hh_cur_count;   /* number of current heavy-hitters */
>  };
> +
> +/*PIE*/

Please, a space before and after PIE.

> diff --git a/net/sched/sch_pie.c b/net/sched/sch_pie.c
> new file mode 100644
> index 0000000..1658b65
> --- /dev/null
> +++ b/net/sched/sch_pie.c
 ...
> +/* statistics gathering*/

Space after "gathering"

> +	/* default of 100 ms in pschedtime  */

Please delete the extra space at the end of that comment.

> +	/* tupdate is in us */
> +	if (tb[TCA_PIE_TUPDATE])
> +		q->params.tupdate = nla_get_u32(tb[TCA_PIE_TUPDATE]);
> +
 ...
> +	/* reset the timer to fire after 'tupdate'. Convert from us to jiffies.
> +	 */
> +	if (q->params.tupdate)
> +		mod_timer(&q->adapt_timer, jiffies +
> +			  usecs_to_jiffies(q->params.tupdate));

Timers run more often than configuration changes, please precompute the
jiffies from the user given usecs so you don't have to continually
recompute it over and over every time the timer gets rescheduled.

> +	/* convert from microseconds to pschedtime */
> +	if (tb[TCA_PIE_TARGET]) {
> +		/* target is in us */
> +		u32 target = nla_get_u32(tb[TCA_PIE_TARGET]);
> +		/* convert to pschedtime */
> +		q->params.target = PSCHED_NS2TICKS((u64)target * NSEC_PER_USEC);

Please put an empty line after variable declarations.

> +	if (tb[TCA_PIE_LIMIT]) {
> +		u32 limit = nla_get_u32(tb[TCA_PIE_LIMIT]);
> +		q->params.limit = limit;
> +		sch->limit = limit;

Likewise.

> +	/* If current queue is about 10 packets or more and dq_count is unset
> +	 *  we have enough packets to calculate the drain rate. Save
> +	 *  current time as dq_tstamp and start measurement cycle.
> +	 */
 ...
> +	/*  Calculate the average drain rate from this value.  If queue length
> +	 *  has receded to a small value viz., <= QUEUE_THRESHOLD bytes,reset
> +	 *  the dq_count to -1 as we don't have enough packets to calculate the
> +	 *  drain rate anymore The following if block is entered only when we
> +	 *  have a substantial queue built up (QUEUE_THRESHOLD bytes or more)
> +	 *  and we calculate the drain rate for the threshold here.  dq_count is
> +	 *  in bytes, time difference in psched_time, hence rate is in
> +	 *  bytes/psched_time.
> +	 */
 ...
> +	/* addition to ensure we increase probability in steps of no
> +	 *  more than 2%
> +	 */
 ...
> +	/*  Non-linear drop
> +	 *  Tune drop probability to increase quickly for high delays
> +	 *  (250ms and above)
> +	 *  250ms is derived through experiments and provides error protection
> +	 */

Please format your comments consistently, one space after the "*" on each
line.

> +	if (q->vars.dq_count != DQCOUNT_INVALID) {
> +
> +		q->vars.dq_count += skb->len;

Please delete that extraneous empty line.

> +	if (delta > (s32) (MAX_PROB / (100 / 2))
> +	    && q->vars.prob >= MAX_PROB / 10)
> +		delta = (MAX_PROB / 100) * 2;
> +
> +

Likewise.

> +	/* Non-linear drop in probability */
> +	/* Reduce drop probability quickly if delay is 0 for 2 consecutive
> +	 * Tupdate periods
> +	 */

Just make this all one comment.

> +	if ((q->vars.qdelay < q->params.target / 2)
> +	    && (q->vars.qdelay_old < q->params.target / 2)
> +	    && (q->vars.prob == 0)
> +	    && q->vars.avg_dq_rate > 0)
> +		pie_vars_init(&q->vars);

Please format this as:

	if (A &&
	    B &&

Do not place the "&&" or similar operator at the beginning of the
line.
