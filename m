From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH v2 1/9] dql: Dynamic queue limits
Date: Tue, 16 Aug 2011 18:15:34 +0100
Message-ID: <1313514934.2725.20.camel@bwh-desktop>
References: <alpine.DEB.2.00.1108072130380.13721@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:38649 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426Ab1HPRPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2011 13:15:38 -0400
In-Reply-To: <alpine.DEB.2.00.1108072130380.13721@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-08-07 at 21:43 -0700, Tom Herbert wrote: 
> Implementation of dynamic queue limits (dql).  This is a libary which
> allows a queue limit to be dynamically managed.  The goal of dql is
> to set the queue limit, number of ojects to the queue, to be minimized
> without allowing the queue to be starved.
> 
> dql would be used with a queue whose use has these properties:
> 
> 1) Objects are queued up to some limit which can be expressed as a
>    count of objects.
> 2) Periodically a completion process executes which retires consumed
>    objects.
> 3) Starvation occurs when limit has been reached, all queued data has
>    actually been consumed but completion processing has not yet run,
>    so queuing new data is blocked.
> 4) Minimizing the amount of queued data is desirable.
> 
> A canonical example of such a queue would be a NIC HW transmit queue.
> 
> The queue limit is dynamic, it will increase or decrease over time
> depending on the workload.  The queue limit is recalculated each time
> completion processing is done.  Increases occur when the queue is
> starved and can exponentially increase over successive intervals.
> Decreases occur when more data is being maintained in the queue than
> needed to prevent starvation.  The number of extra objects, or "slack",
> is measured over successive intervals, and to avoid hysteresis the
> limit is only reduced by the miminum slack seen over a configurable
> time period.

How does this or could this interact with adaptive TX interrupt
coalescing?

> dql API provides routines to manage the queue:
> - dql_init is called to intialize the dql structure
> - dql_reset is called to reset dynamic structures
> - dql_queued when objects are being enqueued
> - dql_avail returns availability in the queue
> - dql_completed is called when objects have be consumed in the queue

These explanations should go in kernel-doc comments above the functions.

> Configuration consists of:
> - max_limit, maximum limit
> - min_limt, minimum limit
> - slack_hold_time, time to measure instances of slack before reducing
>   queue limit.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/linux/dynamic_queue_limits.h |   80 ++++++++++++++++++++
>  lib/Makefile                         |    2 +-
>  lib/dynamic_queue_limits.c           |  132 ++++++++++++++++++++++++++++++++++
>  3 files changed, 213 insertions(+), 1 deletions(-)
>  create mode 100644 include/linux/dynamic_queue_limits.h
>  create mode 100644 lib/dynamic_queue_limits.c
> 
> diff --git a/include/linux/dynamic_queue_limits.h b/include/linux/dynamic_queue_limits.h
> new file mode 100644
> index 0000000..3ffc591
> --- /dev/null
> +++ b/include/linux/dynamic_queue_limits.h
[...] 
> +struct dql {
> +	unsigned long	limit;			/* Current limit */
> +	unsigned long	prev_ovlimit;		/* Previous over limit */
> +
> +	unsigned long	num_queued;		/* Total ever queued */
> +	unsigned long	prev_num_queued;	/* Previous queue total */
> +	unsigned long	num_completed;		/* Total ever completed */
> +
> +	unsigned long	last_obj_cnt;		/* Count at last queuing */
> +	unsigned long	prev_last_obj_cnt;	/* Previous queuing cnt */
> +
> +	unsigned long	lowest_slack;		/* Lowest slack found */
> +	unsigned long	slack_start_time;	/* Time slacks seen */
> +
> +	unsigned long	max_limit;		/* Maximum limit */
> +	unsigned long	min_limit;		/* Minimum limit */
> +	unsigned	slack_hold_time;	/* Time to measure slack */
> +};

Please put the descriptions in kernel-doc format.  That would also make
it easy to expand them a little - for example, to say that 'limit' is
not a hard limit but the threshold above which the queue should be
stopped.

> +/* Set some static maximums */
> +#define	DQL_MAX_OBJECT (-1UL / 16)
> +#define	DQL_MAX_LIMIT ((-1UL / 2) - DQL_MAX_OBJECT)

ULONG_MAX would be clearer than -1UL.

[...] 
> --- /dev/null
> +++ b/lib/dynamic_queue_limits.c
> @@ -0,0 +1,132 @@
> +/*
> + * Dynamic byte queue limits.  See include/linux/dynamic_queue_limits.h
> + *
> + * Author: Tom Herbert (therbert@google.com)
> + */
> +#include <linux/module.h>
> +#include <linux/types.h>
> +#include <linux/ctype.h>
> +#include <linux/kernel.h>
> +#include <linux/dynamic_queue_limits.h>
> +
> +#define POSDIFF(A, B) ((A) > (B) ? (A) - (B) : 0)
> +
> +/* Records completed count and recalculates the queue limit */
> +void dql_completed(struct dql *dql, unsigned long count)
> +{
> +	unsigned long inprogress, prev_inprogress, limit;
> +	unsigned long ovlimit, all_prev_completed, completed;
> +
> +	/* Can't complete more than what's in queue */
> +	BUG_ON(count > dql->num_queued - dql->num_completed);
> +
> +	completed = dql->num_completed + count;
> +	limit = dql->limit;
> +	ovlimit = POSDIFF(dql->num_queued - dql->num_completed, limit);
> +	inprogress = dql->num_queued - completed;
> +	prev_inprogress = dql->prev_num_queued - dql->num_completed;
> +	all_prev_completed = POSDIFF(completed, dql->prev_num_queued);

all_prev_completed is named and used as a boolean, but initialised as a
count.  Since the count is actually useful, it should be renamed to,
e.g. completed_newly_queued.

> +	if ((ovlimit && !inprogress) ||
> +	    (dql->prev_ovlimit && all_prev_completed)) {
> +		/*
> +		 * Queue considered starved if:
> +		 *   - The queue was over-limit in the last interval,
> +		 *     and there is no more data in the queue.
> +		 *  OR
> +		 *   - The queue was over-limit in the previous interval and
> +		 *     when enqueuing it was possible that all queued data
> +		 *     had been consumed.  This covers the case when queue
> +		 *     may have becomes starved between completion processing
> +		 *     running and next time enqueue was scheduled.
> +		 *
> +		 *     When queue is starved increase the limit by the amount
> +		 *     of bytes both sent and completed in the last interval,

For consistency, this should say 'number of objects' not 'amount of
bytes'.

> +		 *     plus any previous over-limit.
> +		 */
> +		limit += POSDIFF(completed, dql->prev_num_queued) +
> +		     dql->prev_ovlimit;

limit += completed_newly_queued + dql->prev_ovlimit;

> +		dql->slack_start_time = jiffies;
> +		dql->lowest_slack = -1UL;

ULONG_MAX

> +	} else if (inprogress && prev_inprogress && !all_prev_completed) {
> +		/*
> +		 * Queue was not starved, check if the limit can be decreased.
> +		 * A decrease is only considered if the queue has been busy in
> +		 * the whole interval (the check above).
> +		 *
> +		 * If there is slack, the amount execess data queued above the
> +		 * the amount needed to prevent starvation, the queue limit can
> +		 * be decreased.  To avoid hysteresis we consider the
> +		 * minimum amount of slack found over several iterations of the
> +		 * completion routine.
> +		 */

This is *adding* hysteresis (resistance to changing state).

> +		unsigned long slack, slack_last_objs;
> +
> +		/*
> +		 * Slack is the maximum of
> +		 *   - The queue limit plus previous over-limit minus twice
> +		 *     the number of objects completed.  Note that two times
> +		 *     number of completed bytes is basis for upper bound

'objects' not 'bytes'

> +		 *     of the limit.
> +		 *   - Portion of objects in the last queuing operation that
> +		 *     was not part of non-zero previous over-limit.  That is
> +		 *     "round down" by non-overlimit portion of the last
> +		 *     queueing operation.

I don't follow either the explanation or the calculation of this second
value (slack_last_objs).

If the queue was filled over the 'limit', doesn't that mean there was
less slack?  Yet slack_last_objs can only be positive (and therefore
influence slack) if dql->prev_ovlimit is true.

> +		 */
> +		slack = POSDIFF(limit + dql->prev_ovlimit,
> +		    2 * (completed - dql->num_completed));
> +		slack_last_objs = dql->prev_ovlimit ?
> +		    POSDIFF(dql->prev_last_obj_cnt, dql->prev_ovlimit) : 0;
> +
> +		slack = max(slack, slack_last_objs);
> +
> +		if (slack < dql->lowest_slack)
> +			dql->lowest_slack = slack;
> +
> +		if (time_after(jiffies,
> +			       dql->slack_start_time + dql->slack_hold_time)) {
> +			limit = POSDIFF(limit, dql->lowest_slack);
> +			dql->slack_start_time = jiffies;
> +			dql->lowest_slack = -1UL;
[...]

ULONG_MAX

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


