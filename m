From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v3 01/10] dql: Dynamic queue limits
Date: Wed, 23 Nov 2011 08:37:12 -0800
Message-ID: <20111123083712.69a2ac6e@nehalam.linuxnetplumber.net>
References: <alpine.DEB.2.00.1111222138280.13686@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36476 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753773Ab1KWQhO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Nov 2011 11:37:14 -0500
In-Reply-To: <alpine.DEB.2.00.1111222138280.13686@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Nov 2011 21:52:21 -0800 (PST)
Tom Herbert <therbert@google.com> wrote:

> Implementation of dynamic queue limits (dql).  This is a libary which
> allows a queue limit to be dynamically managed.  The goal of dql is
> to set the queue limit, number of objects to the queue, to be minimized
> without allowing the queue to be starved.
> 
> dql would be used with a queue which has these properties:
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
> 
> dql API provides routines to manage the queue:
> - dql_init is called to intialize the dql structure
> - dql_reset is called to reset dynamic values
> - dql_queued called when objects are being enqueued
> - dql_avail returns availability in the queue
> - dql_completed is called when objects have be consumed in the queue
> 
> Configuration consists of:
> - max_limit, maximum limit
> - min_limit, minimum limit
> - slack_hold_time, time to measure instances of slack before reducing
>   queue limit
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Some minor stuff:

1. Since linux/dql.h is only kernel components (not API), it should
   be net/dql.h

2. Don't make it a config option. "Do or do not, there is no try"
   Config options are useless for distributions. I assume the plan
   is that devices using DQL will enable it in their config.
   Therefore adding device with DQL should modify the Kconfig for that
   device.

3. Rather using -1ul in DQL_MAX_ why not use ULONG_MAX?

4. dql_avail should be:
static inline long dql_avail(const struct dql *dql)
{
	return dql->limit - (dql->num_queued - dql->num_completed);
}

5. dql_init should be: 
void dql_init(struct dql *dql, unsigned hold_time)


For clarity, IMHO would be better to change dql_completed()
so  the code read like the comments.

Rather than:
	completed = dql->num_completed + count;
	limit = dql->limit;
	ovlimit = POSDIFF(dql->num_queued - dql->num_completed, limit);
	inprogress = dql->num_queued - completed;
	prev_inprogress = dql->prev_num_queued - dql->num_completed;
	all_prev_completed = POSDIFF(completed, dql->prev_num_queued);

	if ((ovlimit && !inprogress) ||
	    (dql->prev_ovlimit && all_prev_completed)) {
Instead:
	if (dql_queue_starved(dql)) {
		...
        } else if (dql_queue_busy(dql)) {
		...

Where dql_queue_starved and dql_queue_busy are inline's
