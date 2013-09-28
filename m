From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v1 net-next] net: pkt_sched: PIE AQM scheme
Date: Sat, 28 Sep 2013 10:06:37 -0700
Message-ID: <20130928100637.4c69571e@nehalam.linuxnetplumber.net>
References: <1902752B0C92F943AB7EA9EE13E2DEEC1272C74DD1@HQ1-EXCH02.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:59913 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754388Ab3I1RGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 13:06:41 -0400
Received: by mail-pb0-f42.google.com with SMTP id un15so3830577pbc.15
        for <netdev@vger.kernel.org>; Sat, 28 Sep 2013 10:06:41 -0700 (PDT)
In-Reply-To: <1902752B0C92F943AB7EA9EE13E2DEEC1272C74DD1@HQ1-EXCH02.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for submitting this, it is in ok shape, but I still
see several issues.

> diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
> index f2624b5..2fb6e6d 100644
> --- a/include/uapi/linux/pkt_sched.h
> +++ b/include/uapi/linux/pkt_sched.h
> @@ -787,4 +787,30 @@ struct tc_fq_qd_stats {
>         __u32   throttled_flows;
>         __u32   pad;
>  };
> +
> +/*PIE*/
> +enum {
> +       TCA_PIE_UNSPEC,
> +       TCA_PIE_TARGET,
> +       TCA_PIE_LIMIT,
> +       TCA_PIE_TUPDATE,
> +       TCA_PIE_ALPHA,
> +       TCA_PIE_BETA,
> +       TCA_PIE_ECN,
> +       TCA_PIE_BYTEMODE,
> +       __TCA_PIE_MAX
> +};
> +#define TCA_PIE_MAX   (__TCA_PIE_MAX - 1)
> +
> +struct tc_pie_xstats {
> +       __u32 prob;             /* current probability */
> +       __u32 delay;            /* current delay in ms */
> +       __u32 avg_dq_rate;      /* current average dq_rate in bits/pie_time */
> +       __u32 packets_in;       /* total number of packets enqueued */
> +       __u32 dropped;          /* packets dropped due to pie_action */
> +       __u32 overlimit;        /* dropped due to lack of space in queue */
> +       __u32 maxq;             /* maximum queue size */
> +       __u32 ecn_mark;         /* packets marked with ecn*/
> +};
> +
>  #endif
> diff --git a/net/sched/Kconfig b/net/sched/Kconfig
> index c03a32a..7b32e58 100644
> --- a/net/sched/Kconfig
> +++ b/net/sched/Kconfig
> @@ -286,6 +286,17 @@ config NET_SCH_FQ
> 
>           If unsure, say N.
> 
> +config NET_SCH_PIE
> +        tristate "Proportianal Enhanced Controller AQM (PIE)"

Spelling should be: Proportional 


> diff --git a/net/sched/sch_pie.c b/net/sched/sch_pie.c
> new file mode 100644
> index 0000000..cfcfde9
> --- /dev/null
> +++ b/net/sched/sch_pie.c
> @@ -0,0 +1,623 @@
> +/* Copyright (C) 2013 Cisco Systems, Inc, 2013.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * as published by the Free Software Foundation; either version 2
> + * of the License.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301,
> + * USA.
> + *
> + * Author: Vijay Subramanian <vijaynsu@cisco.com>
> + * Author: Mythili Prabhu <mysuryan@cisco.com>
> + *
> + * ECN support is added by Naeem Khademi <naeemk@ifi.uio.no>
> + * University of Oslo, Norway.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/slab.h>
> +#include <linux/types.h>
> +#include <linux/kernel.h>
> +#include <linux/errno.h>
> +#include <linux/skbuff.h>
> +#include <net/pkt_sched.h>
> +#include <net/inet_ecn.h>
> +
> +#define PIE_DEFAULT_QUEUE_LIMIT 200    /* in packets */
> +#define QUEUE_THRESHOLD (5000)
Useless paren's here

> +#define DQCOUNT_INVALID -1
> +#define THRESHOLD_PKT_SIZE     1500
> +#define MAX_INT_VALUE  0xffffffff
> +#define MAX_INT_VALUE_CAP  (0xffffffff >> 8)
> +
> +typedef u32 pie_time_t;
> +typedef s32 pie_tdiff_t;
> +#define PIE_SHIFT 10
> +#define MS2PIETIME(a) ((a * NSEC_PER_MSEC) >> PIE_SHIFT)
> +#define PIE_TIME_PER_SEC  ((NSEC_PER_SEC >> PIE_SHIFT))
> +

I would prefer that all packet schedulers use the same set of clock
routines (psched), rather than inventing own wrapper for high resolution
clock.

> +static inline pie_time_t pie_get_time(void)
> +{
> +       u64 ns = ktime_to_ns(ktime_get());
> +       return ns >> PIE_SHIFT;
> +}
> +
> +static inline u32 pie_time_to_ms(pie_time_t val)
> +{
> +       u64 valms = ((u64) val << PIE_SHIFT);
> +
> +       do_div(valms, NSEC_PER_MSEC);
> +       return (u32) valms;
> +}

Psched has all this.

> +/* parameters used*/
> +struct pie_params {
> +       pie_time_t target;      /* user specified target delay in pietime*/
> +       pie_time_t tupdate;     /* frequency with which the timer fires*/
                                                                         ^ space before end of comment
> +       u32 limit;              /* number of packets that can be enqueued */
> +       u32 alpha;              /* alpha and beta are between -4 and 4 */
> +       u32 beta;               /* and are used for shift relative to 1 */
> +       bool ecn;               /* true if ecn is enabled */
> +       bool bytemode;          /* to scale drop early prob based on pkt size */
> +};
> +
> +/* variables used*/
> +struct pie_vars {
> +       u32 prob;               /* probability but scaled by u32 limit. */
> +       pie_time_t burst_time;
> +       pie_time_t qdelay;
> +       pie_time_t qdelay_old;
> +       u32 dq_count;           /* measured in bytes */
> +       pie_time_t dq_tstamp;   /* drain rate */
> +       u32 avg_dq_rate;        /* bytes per pietime tick, scaled by 8 */
> +       u32 qlen_old;           /* in bytes */
> +};
> +
> +struct pie_stats {
> +       u32 packets_in;         /* total number of packets enqueued */
> +       u32 dropped;            /* packets dropped due to pie_action */
> +       u32 overlimit;          /* dropped due to lack of space in queue */
> +       u32 maxq;               /* maximum queue size */
> +       u32 ecn_mark;           /* packets marked with ECN */
> +};
> +
> +static void pie_params_init(struct pie_params *params)
> +{
> +       memset(params, 0, sizeof(*params));

Unnecessary, already zero'd when created by qdisc_alloc()
Call chain
      qdisc_create
	      qdisc_alloc
              ops->init => pie_init
                 pie_params_init
      
> +       params->alpha = 2;
> +       params->beta = 20;
> +       params->tupdate = MS2PIETIME(30);       /* 30 ms */
> +       params->limit = PIE_DEFAULT_QUEUE_LIMIT;
> +       params->target = MS2PIETIME(20);        /* 20 ms */
> +       params->ecn = false;
> +       params->bytemode = false;
> +}


> +
> +static void pie_vars_init(struct pie_vars *vars)
> +{
> +       memset(vars, 0, sizeof(*vars));
ditto, already zero'd

> +       vars->dq_count = DQCOUNT_INVALID;
> +       vars->avg_dq_rate = 0;
> +       /* default of 100 ms in pietime  */
> +       vars->burst_time = MS2PIETIME(100);
> +}
> +
> +static void pie_stats_init(struct pie_stats *stats)
> +{
> +       memset(stats, 0, sizeof(*stats));
> +}
> +
ditto, already zero'd

> +struct pie_sched_data {
> +       struct pie_params params;
> +       struct pie_vars vars;
> +       struct pie_stats stats;
> +       struct timer_list adapt_timer;
> +};

Standard practice is to put data structures before code.

> +
> +static inline bool drop_early(struct Qdisc *sch, u32 packet_size)

Inline is not needed if static. Let compiler decide.

> +{
> +       struct pie_sched_data *q = qdisc_priv(sch);
> +       u32 rnd;
> +       u32 local_prob = q->vars.prob;
> +
> +
> +       /* If there is still burst allowance left or delay is much below target
> +        * not due to heavy dropping, skip random early drop
> +        */
> +       if (q->vars.burst_time > 0)
> +               return false;
> +
> +       /* If current delay is less than half of target, and
> +        * if drop prob is low already, disable early_drop
> +        */
> +       if ((q->vars.qdelay < q->params.target / 2)
> +           && (q->vars.prob < MAX_INT_VALUE / 5))
> +               return false;
> +
> +       /* If we have fewer than 2 packets, disable drop_early,
> +        * similar to min_th in RED
> +        */
> +       if (sch->qstats.backlog < 2 * 1500)
> +               return false;
> +
> +       /* If bytemode is turned on, use packet size to compute new
> +        * probablity. Smaller packets will have lower drop prob in this case
> +        */
> +       if (q->params.bytemode) {
> +               /* If packet_size is greater than THRESHOLD_PKT_SIZE,
> +                * we cap the probability to the maximum value
> +                */
> +               if (packet_size <= THRESHOLD_PKT_SIZE) {
> +                       local_prob =
> +                           (local_prob / THRESHOLD_PKT_SIZE) * packet_size;
> +               } else {
> +                       local_prob = MAX_INT_VALUE_CAP;
> +               }
> +
> +       } else {
> +               local_prob = q->vars.prob;
> +       }
> +
> +       rnd = net_random() % MAX_INT_VALUE_CAP;
> +       if (rnd < local_prob)
> +               return true;
> +
> +       return false;
> +}
> +
> +static int pie_qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> +{
> +       struct pie_sched_data *q = qdisc_priv(sch);
> +
> +       if (unlikely(qdisc_qlen(sch) >= sch->limit))
> +               goto out;
> +
> +       if (!drop_early(sch, skb->len)) {
> +               /* we can enqueue the packet */
> +               q->stats.packets_in++;
> +
> +               if (qdisc_qlen(sch) > q->stats.maxq)
> +                       q->stats.maxq = qdisc_qlen(sch);
> +
> +               return qdisc_enqueue_tail(skb, sch);
> +       } else if (q->params.ecn && INET_ECN_set_ce(skb) &&
> +                  (q->vars.prob <= MAX_INT_VALUE / 10)) {
> +                       /* If packet is ecn capable, mark it if drop probability
> +                        * is lower than 10%, else drop it.
> +                        */
> +                       q->stats.ecn_mark++;
> +                       return qdisc_enqueue_tail(skb, sch);
> +       }
> +out:
> +       q->stats.overlimit++;
> +       qdisc_drop(skb, sch);
> +       return NET_XMIT_CN;  /*indicate congestion*/
> +}
> +
> +static const struct nla_policy pie_policy[TCA_PIE_MAX + 1] = {
> +       [TCA_PIE_TARGET] = {.type = NLA_U32},
                                             ^ space before }
> +       [TCA_PIE_LIMIT] = {.type = NLA_U32},
> +       [TCA_PIE_TUPDATE] = {.type = NLA_U32},
> +       [TCA_PIE_ALPHA] = {.type = NLA_U32},
> +       [TCA_PIE_BETA] = {.type = NLA_U32},
> +       [TCA_PIE_ECN] = {.type = NLA_U32},
> +       [TCA_PIE_BYTEMODE] = {.type = NLA_U32},
              Looks prettier if all = are aligned

> +};
> +
> +static int pie_change(struct Qdisc *sch, struct nlattr *opt)
> +{
> +       struct pie_sched_data *q = qdisc_priv(sch);
> +       struct nlattr *tb[TCA_PIE_MAX + 1];
> +       unsigned int qlen;
> +       int err;
> +
> +       if (!opt)
> +               return -EINVAL;
> +
> +       err = nla_parse_nested(tb, TCA_PIE_MAX, opt, pie_policy);
> +       if (err < 0)
> +               return err;
> +
> +       sch_tree_lock(sch);
> +
> +       /* convert from microseconds to pietime */
> +       if (tb[TCA_PIE_TARGET]) {
> +               /* target is in us */
> +               u32 target = nla_get_u32(tb[TCA_PIE_TARGET]);
> +               /* convert to pietime */
> +               q->params.target = ((u64) target * NSEC_PER_USEC) >> PIE_SHIFT;
> +       }
> +
> +       if (tb[TCA_PIE_TUPDATE]) {
> +               /* tupdate is in us */
> +               u32 tupdate = nla_get_u32(tb[TCA_PIE_TUPDATE]);
> +               /* convert to pietime */
> +               q->params.tupdate =
> +                   ((u64) tupdate * NSEC_PER_USEC) >> PIE_SHIFT;
> +       }
> +
> +       if (tb[TCA_PIE_LIMIT]) {
> +               u32 limit = nla_get_u32(tb[TCA_PIE_LIMIT]);
> +               q->params.limit = limit;
> +               sch->limit = limit;
> +       }
> +
> +       if (tb[TCA_PIE_ALPHA])
> +               q->params.alpha = nla_get_u32(tb[TCA_PIE_ALPHA]);
> +
> +       if (tb[TCA_PIE_BETA])
> +               q->params.beta = nla_get_u32(tb[TCA_PIE_BETA]);
> +
> +       if (tb[TCA_PIE_ECN])
> +               q->params.ecn = nla_get_u32(tb[TCA_PIE_ECN]);
> +
> +       if (tb[TCA_PIE_BYTEMODE])
> +               q->params.bytemode = nla_get_u32(tb[TCA_PIE_BYTEMODE]);
> +
> +       /* Drop excess packets if new limit is lower */
> +       qlen = sch->q.qlen;
> +       while (sch->q.qlen > sch->limit) {
> +               struct sk_buff *skb = __skb_dequeue(&sch->q);
> +
> +               sch->qstats.backlog -= qdisc_pkt_len(skb);
> +               qdisc_drop(skb, sch);
> +       }
> +       qdisc_tree_decrease_qlen(sch, qlen - sch->q.qlen);
> +
> +       sch_tree_unlock(sch);
> +       return 0;
> +}
> +
> +static int pie_process_dequeue(struct Qdisc *sch, struct sk_buff *skb)
> +{
> +
> +       struct pie_sched_data *q = qdisc_priv(sch);
> +       int qlen = sch->qstats.backlog; /* current queue size in bytes */
> +
> +       /* If current queue is about 10 packets or more and dq_count is unset
> +        *  we have enough packets to calculate the drain rate. Save
> +        *  current time as dq_tstamp and start measurement cycle.
> +        */
> +
> +       if (qlen >= QUEUE_THRESHOLD && q->vars.dq_count == DQCOUNT_INVALID) {
> +               q->vars.dq_tstamp = pie_get_time();
> +               q->vars.dq_count = 0;
> +       }
> +
> +       /*  Calculate the average drain rate from this value.  If queue length
> +        *  has receded to a small value viz., <= QUEUE_THRESHOLD bytes,reset
> +        *  the dq_count to -1 as we don't have enough packets to calculate the
> +        *  drain rate anymore The following if block is entered only when we
> +        *  have a substantial queue built up (QUEUE_THRESHOLD bytes or more)
> +        *  and we calculate the drain rate for the threshold here.  dq_count is
> +        *  in bytes, time difference in pie_time, hence rate is in
> +        *  bytes/pie_time.
> +        */
> +
> +       if (q->vars.dq_count != DQCOUNT_INVALID) {

I prefer not having blank line after each block comment when it refers
directly to the code below (save screen space when reading).

> +
> +               q->vars.dq_count += skb->len;
> +
> +               if (q->vars.dq_count >= QUEUE_THRESHOLD) {
> +                       pie_time_t now = pie_get_time();
> +                       pie_tdiff_t dtime = now - q->vars.dq_tstamp;
> +                       u64 count = q->vars.dq_count << 3;  /* scale by 8*/

This shift doesn't do what you expect. Since dq_count is 32 bit,
the compiler does a 32 bit shift and then assigns it to count.
So either just make count 32 bit and skip all the expensive 64 bit divide,
or cast q->vars.dq_count to 64 bit first.

> +
> +                       if (dtime == 0)
> +                               return 0;
> +
> +                       /* dtime has overflowed */
> +                       if (dtime < 0)
> +                               dtime = -dtime;
> +
> +                       do_div(count, dtime);
> +
> +                       if (q->vars.avg_dq_rate == 0)
> +                               q->vars.avg_dq_rate = count;
> +                       else
> +                               q->vars.avg_dq_rate =
> +                                   (q->vars.avg_dq_rate -
> +                                    (q->vars.avg_dq_rate >> 3)) + (count >> 3);
> +
> +                       /* If the queue has receded below the threshold, we hold
> +                        * on to the last drain rate calculated, else we reset
> +                        * dq_count to 0 to re-enter the if block when the next
> +                        * packet is dequeued
> +                        */
> +
> +                       if (qlen < QUEUE_THRESHOLD)
> +                               q->vars.dq_count = DQCOUNT_INVALID;
> +                       else {
> +                               q->vars.dq_count = 0;
> +                               q->vars.dq_tstamp = pie_get_time();
> +                       }
> +
> +                       if (q->vars.burst_time > 0) {
> +                               if (q->vars.burst_time > dtime)
> +                                       q->vars.burst_time -= dtime;
> +                               else
> +                                       q->vars.burst_time = 0;
> +                       }
> +               }
> +
> +       }
> +       return 0;
> +}
> +
> +static void calculate_probability(struct Qdisc *sch)
> +{
> +       struct pie_sched_data *q = qdisc_priv(sch);
> +       int qlen = sch->qstats.backlog; /* queue size in bytes */
> +       pie_time_t qdelay = 0;  /* in pietime */
> +       pie_time_t qdelay_old = q->vars.qdelay; /* in pietime */
> +       s32 delta = 0;          /* signed difference */
> +       u32 oldprob;
> +       u32 alpha, beta;
> +       bool update_prob = true;        /* Should probability be updated? */
> +

Big problem, this is called without locks??
timer -> pie_timer -> calculate_probability

When you add locks you also have to worry about deadlock
on shutdown.

> +       q->vars.qdelay_old = q->vars.qdelay;
> +
> +       if (q->vars.avg_dq_rate > 0)
> +               qdelay = (qlen << 3) / q->vars.avg_dq_rate;
> +       else
> +               qdelay = 0;
> +
> +       /* If qdelay is zero and qlen is not, it means qlen is very small, less
> +        * than dequeue_rate, so we do not update probabilty in this round
> +        */
> +       if (qdelay == 0 && qlen != 0)
> +               update_prob = false;
> +
> +       /* Add ranges for alpha and beta, more aggressive for high dropping
> +        * mode and gentle steps for light dropping mode
> +        * In light dropping mode, take gentle steps; in medium dropping mode,
> +        * take medium steps; in high dropping mode, take big steps.
> +        */
> +       if (q->vars.prob < MAX_INT_VALUE / 100) {
> +               alpha =
> +                   (q->params.alpha * (MAX_INT_VALUE / PIE_TIME_PER_SEC)) >> 7;
> +               beta =
> +                   (q->params.beta * (MAX_INT_VALUE / PIE_TIME_PER_SEC)) >> 7;
> +       } else if (q->vars.prob < MAX_INT_VALUE / 10) {
> +               alpha =
> +                   (q->params.alpha * (MAX_INT_VALUE / PIE_TIME_PER_SEC)) >> 5;
> +               beta =
> +                   (q->params.beta * (MAX_INT_VALUE / PIE_TIME_PER_SEC)) >> 5;
> +       } else {
> +               alpha =
> +                   (q->params.alpha * (MAX_INT_VALUE / PIE_TIME_PER_SEC)) >> 4;
> +               beta =
> +                   (q->params.beta * (MAX_INT_VALUE / PIE_TIME_PER_SEC)) >> 4;
> +       }
> +
> +       /* alpha and beta should be between 0 and 32, in multiples of 1/16
> +        */
> +       delta += alpha * ((qdelay - q->params.target));
> +       delta += beta * ((qdelay - qdelay_old));
> +
> +       oldprob = q->vars.prob;
> +
> +       /* addition to ensure we increase probability in steps of no
> +        *  more than 2%
> +        */
> +
> +       if (delta > (s32) (MAX_INT_VALUE * 2 / 100)
> +           && q->vars.prob >= MAX_INT_VALUE / 10) {
> +               delta = MAX_INT_VALUE * 2 / 100;
> +       }
> +
> +       /*  Non-linear drop
> +        *  Tune drop probability to increase quickly for high delays
> +        *  (250ms and above)
> +        *  250ms is derived through experiments and provides error protection
> +        */
> +
> +       if (qdelay > (MS2PIETIME(250)))
> +               delta += (2 * MAX_INT_VALUE) / 100;
> +
> +       q->vars.prob += delta;
> +
> +       if (delta > 0) {
> +               /* prevent overflow */
> +               if (q->vars.prob < oldprob) {
> +                       q->vars.prob = MAX_INT_VALUE;
> +                       /* Prevent normalization error
> +                        * If probability is the maximum value already,
> +                        * we normalize it here, and skip the
> +                        * check to do a non-linear drop in the next section
> +                        */
> +                       update_prob = false;
> +               }
> +       } else {
> +               /* prevent underflow */
> +               if (q->vars.prob > oldprob)
> +                       q->vars.prob = 0;
> +       }
> +
> +       /* Non-linear drop in probability */
> +       /* Reduce drop probability quickly if delay is 0 for 2 consecutive
> +        * Tupdate periods
> +        */
> +       if ((qdelay == 0) && (qdelay_old == 0) && update_prob)
> +               q->vars.prob = (q->vars.prob * 98) / 100;
> +
> +       q->vars.qdelay = qdelay;
> +       q->vars.qlen_old = qlen;
> +
> +       /* we restart the measurement cycle if the following conditions are met
> +        *  1. If the delay has been low for 2 consecutive Tupdate periods
> +        *  2. Calculated drop probability is zero
> +        *  3. We have atleast one estimate for the avg_dq_rate ie.,
> +        *     is a non-zero value
> +        */
> +       if ((q->vars.qdelay < q->params.target / 2)
> +           && (q->vars.qdelay_old < q->params.target / 2)
> +           && (q->vars.prob == 0)
> +           && q->vars.avg_dq_rate > 0)
> +               pie_vars_init(&q->vars);
> +
> +       return;
> +}

Don't do empty return at end of function. It is unnecessary.


> +
> +static inline void pie_timer(unsigned long arg)

Since this is a callback it can't be inlined anyway

> +{
> +       struct Qdisc *sch = (struct Qdisc *)arg;
> +       struct pie_sched_data *q = qdisc_priv(sch);
> +       u64 tup;
Does this really have to be 64 bit?

> +
> +       calculate_probability(sch);
> +       /* reset the timer to fire after 'tupdate' us,
> +        * tupdate is currently in pie_time
> +        * mod_timer expects time to be in jiffies
> +        */
> +       /* convert from pietime to nsecs to ms*/
> +       tup = pie_time_to_ms(q->params.tupdate);
> +       tup = (tup * HZ) / (1000);      /* and then to  jiffies */

Useless paren around (1000)

> +
> +       mod_timer(&q->adapt_timer, jiffies + tup);
> +
> +       return;
> +
> +}
> +
> +static int pie_init(struct Qdisc *sch, struct nlattr *opt)
> +{
> +       struct pie_sched_data *q = qdisc_priv(sch);
> +
> +       pie_params_init(&q->params);
> +       pie_vars_init(&q->vars);
> +       pie_stats_init(&q->stats);
> +       sch->limit = q->params.limit;
> +       setup_timer(&q->adapt_timer, pie_timer, (unsigned long)sch);
> +       add_timer(&q->adapt_timer);

This is wrong, you haven't set expiration timer (will be 0), so timer
will fire.

> +
> +       if (opt) {
> +               int err = pie_change(sch, opt);
> +
> +               if (err)
> +                       return err;
> +       }
> +
> +       return 0;
> +}
> +
> +static int pie_dump(struct Qdisc *sch, struct sk_buff *skb)
> +{
> +       struct pie_sched_data *q = qdisc_priv(sch);
> +       struct nlattr *opts;
> +
> +       opts = nla_nest_start(skb, TCA_OPTIONS);
> +       if (opts == NULL)
> +               goto nla_put_failure;
> +
> +       /* convert target and tupdate from pietime to us */
> +       if (nla_put_u32(skb, TCA_PIE_TARGET,
> +                       pie_time_to_ms(q->params.target) * 1000L) ||
> +           nla_put_u32(skb, TCA_PIE_LIMIT,
> +                       sch->limit) ||
> +           nla_put_u32(skb, TCA_PIE_TUPDATE,
> +                       pie_time_to_ms(q->params.tupdate) * 1000L) ||
> +           nla_put_u32(skb, TCA_PIE_ALPHA,
> +                       q->params.alpha) ||
> +           nla_put_u32(skb, TCA_PIE_BETA, q->params.beta) ||
> +           nla_put_u32(skb, TCA_PIE_ECN, q->params.ecn) ||
> +           nla_put_u32(skb, TCA_PIE_BYTEMODE, q->params.bytemode))
> +               goto nla_put_failure;
> +
> +       return nla_nest_end(skb, opts);
> +
> +nla_put_failure:
> +       nla_nest_cancel(skb, opts);
> +       return -1;
> +
> +}
> +
> +static int pie_dump_stats(struct Qdisc *sch, struct gnet_dump *d)
> +{
> +       struct pie_sched_data *q = qdisc_priv(sch);
> +       struct tc_pie_xstats st = {
> +               .prob = q->vars.prob,
> +               .delay = pie_time_to_ms(q->vars.qdelay) * 1000, /* in us*/
> +               /* unscale and return dq_rate in bytes per sec*/
> +               .avg_dq_rate = q->vars.avg_dq_rate * (PIE_TIME_PER_SEC/8),
> +               .packets_in = q->stats.packets_in,
> +               .overlimit = q->stats.overlimit,
> +               .maxq = q->stats.maxq,
> +               .dropped = q->stats.dropped,
> +               .ecn_mark = q->stats.ecn_mark,
> +       };
Personal preference, I prefer a aligned initialization style.

> +
> +       return gnet_stats_copy_app(d, &st, sizeof(st));
> +}
> +
> +static inline struct sk_buff *pie_qdisc_dequeue(struct Qdisc *sch)
> +{
> +       struct sk_buff *skb;
> +       skb = __qdisc_dequeue_head(sch, &sch->q);
> +
> +       if (!skb)
> +               return NULL;
> +
> +       pie_process_dequeue(sch, skb);
> +
> +       return skb;
> +}
> +
> +static void pie_reset(struct Qdisc *sch)
> +{
> +       struct pie_sched_data *q = qdisc_priv(sch);
> +       qdisc_reset_queue(sch);
> +       pie_vars_init(&q->vars);
> +
> +       return;
> +}
> +
> +static void pie_destroy(struct Qdisc *sch)
> +{
> +       struct pie_sched_data *q = qdisc_priv(sch);
> +
> +       del_timer_sync(&q->adapt_timer);
> +}
> +
> +static struct Qdisc_ops pie_qdisc_ops __read_mostly = {
> +       .id = "pie",
> +       .priv_size = sizeof(struct pie_sched_data),
> +
> +       .enqueue = pie_qdisc_enqueue,
> +       .dequeue = pie_qdisc_dequeue,
> +       .peek = qdisc_peek_dequeued,
> +       .init = pie_init,
> +       .destroy = pie_destroy,
> +       .reset = pie_reset,
> +       .change = pie_change,
> +       .dump = pie_dump,
> +       .dump_stats = pie_dump_stats,
> +       .owner = THIS_MODULE,
> +};
> +
> +static int __init pie_module_init(void)
> +{
> +       return register_qdisc(&pie_qdisc_ops);
> +}
> +
> +static void __exit pie_module_exit(void)
> +{
> +       unregister_qdisc(&pie_qdisc_ops);
> +}
> +
> +module_init(pie_module_init);
> +module_exit(pie_module_exit);
> +
> +MODULE_DESCRIPTION
> +       ("PIE (Proportional Intergal controller Enhanced) scheduler");
Keep this on one line, ignore any complaints from checkpatch about it.

> +MODULE_AUTHOR("Vijay Subramanian");
> +MODULE_AUTHOR("Mythili Prabhu");
> +MODULE_LICENSE("GPL");

Please fix and resubmit. This is just a first pass review, there are
probably more detailed issues that others will see.
