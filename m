From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 01/10] dql: Dynamic queue limits
Date: Wed, 23 Nov 2011 15:58:08 +0100
Message-ID: <1322060288.17693.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <alpine.DEB.2.00.1111222138280.13686@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:64023 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756101Ab1KWO6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 09:58:12 -0500
Received: by qyd20 with SMTP id 20so446433qyd.19
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 06:58:12 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1111222138280.13686@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 22 novembre 2011 =C3=A0 21:52 -0800, Tom Herbert a =C3=A9crit =
:
> Implementation of dynamic queue limits (dql).  This is a libary which
> allows a queue limit to be dynamically managed.  The goal of dql is
> to set the queue limit, number of objects to the queue, to be minimiz=
ed
> without allowing the queue to be starved.
>=20
> dql would be used with a queue which has these properties:
>=20
> 1) Objects are queued up to some limit which can be expressed as a
>    count of objects.
> 2) Periodically a completion process executes which retires consumed
>    objects.
> 3) Starvation occurs when limit has been reached, all queued data has
>    actually been consumed but completion processing has not yet run,
>    so queuing new data is blocked.
> 4) Minimizing the amount of queued data is desirable.
>=20
> A canonical example of such a queue would be a NIC HW transmit queue.
>=20
> The queue limit is dynamic, it will increase or decrease over time
> depending on the workload.  The queue limit is recalculated each time
> completion processing is done.  Increases occur when the queue is
> starved and can exponentially increase over successive intervals.
> Decreases occur when more data is being maintained in the queue than
> needed to prevent starvation.  The number of extra objects, or "slack=
",
> is measured over successive intervals, and to avoid hysteresis the
> limit is only reduced by the miminum slack seen over a configurable
> time period.
>=20
> dql API provides routines to manage the queue:
> - dql_init is called to intialize the dql structure
> - dql_reset is called to reset dynamic values
> - dql_queued called when objects are being enqueued
> - dql_avail returns availability in the queue
> - dql_completed is called when objects have be consumed in the queue
>=20
> Configuration consists of:
> - max_limit, maximum limit
> - min_limit, minimum limit
> - slack_hold_time, time to measure instances of slack before reducing
>   queue limit
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/linux/dynamic_queue_limits.h |   81 +++++++++++++++++++++
>  lib/Kconfig                          |    3 +
>  lib/Makefile                         |    2 +
>  lib/dynamic_queue_limits.c           |  132 ++++++++++++++++++++++++=
++++++++++
>  4 files changed, 218 insertions(+), 0 deletions(-)
>  create mode 100644 include/linux/dynamic_queue_limits.h
>  create mode 100644 lib/dynamic_queue_limits.c
>=20
> diff --git a/include/linux/dynamic_queue_limits.h b/include/linux/dyn=
amic_queue_limits.h
> new file mode 100644
> index 0000000..8953187
> --- /dev/null
> +++ b/include/linux/dynamic_queue_limits.h
> @@ -0,0 +1,81 @@
> +/*
> + * Dynamic queue limits (dql) - Definitions
> + *
> + * Copyright (c) 2011, Tom Herbert <therbert@google.com>
> + *
> + * This header file contains the definitions for dynamic queue limit=
s (dql).
> + * dql would be used in conjunction with a producer/consumer type qu=
eue
> + * (possibly a HW queue).  Such a queue would have these general pro=
perties:
> + *
> + *   1) Objects are queued up to some limit specified as number of o=
bjects.
> + *   2) Periodically a completion process executes which retires con=
sumed
> + *      objects.
> + *   3) Starvation occurs when limit has been reached, all queued da=
ta has
> + *      actually been consumed, but completion processing has not ye=
t run
> + *      so queuing new data is blocked.
> + *   4) Minimizing the amount of queued data is desirable.
> + *
> + * The goal of dql is to calculate the limit as the minimum number o=
f objects
> + * needed to prevent starvation.
> + *
> + * The dql implementation does not implement any locking for the dql=
 data
> + * structures, the higher layer should provide this.
> + */


Maybe give a hint on the fact that all dql_queued() must be serialized,
all dql_completed() must be serialized, but can use a different lock

(a dql_completed() can be run while a dql_queued() is run)

> +
> +#ifndef _LINUX_DQL_H
> +#define _LINUX_DQL_H
> +
> +#ifdef __KERNEL__
> +
> +struct dql {
> +	unsigned long	num_queued;		/* Total ever queued */
> +	unsigned long	last_obj_cnt;		/* Count at last queuing */
> +
> +	unsigned long	limit ____cacheline_aligned_in_smp; /* Current limit =
*/
> +	unsigned long	prev_ovlimit;		/* Previous over limit */
> +
> +	unsigned long	prev_num_queued;	/* Previous queue total */
> +	unsigned long	num_completed;		/* Total ever completed */
> +
> +	unsigned long	prev_last_obj_cnt;	/* Previous queuing cnt */
> +
> +	unsigned long	lowest_slack;		/* Lowest slack found */
> +	unsigned long	slack_start_time;	/* Time slacks seen */
> +
> +	unsigned long	max_limit ____cacheline_aligned_in_smp; /* Max limit =
*/
> +	unsigned long	min_limit;		/* Minimum limit */
> +	unsigned	slack_hold_time;	/* Time to measure slack */
> +};
> +

Hmm, please dont do that, it will add two cache lines in transmit path,
and a third one for very seldom used data.

What is needed tx fast path are : num_queued, last_obj_cnt, limit and
num_completed.

So I suggest :

struct dql {
/* part used in dql_queued() */
	unsigned long	num_queued;		/* Total ever queued */
	unsigned long	last_obj_cnt;		/* Count at last queuing */
	unsigned long	limit;			/* Current limit */
	unsigned long	num_completed;		/* Total ever completed */

/* part used in dql_completed() */
	unsigned long	prev_ovlimit;		/* Previous over limit */

	unsigned long	prev_num_queued;	/* Previous queue total */

	unsigned long	prev_last_obj_cnt;	/* Previous queuing cnt */

	unsigned long	lowest_slack;		/* Lowest slack found */
	unsigned long	slack_start_time;	/* Time slacks seen */

	unsigned long	max_limit;		/* Max limit */
	unsigned long	min_limit;		/* Minimum limit */
	unsigned int	slack_hold_time;	/* Time to measure slack */
};



Another question is : Is DQL planned to work on 32bit arch ?

A fast interface can probably send more than 2^32 bytes for large
slack_hold_time values, and wrap around.

If yes : We can use "unsigned int" instead of "unsigned long" to lower
memory need on 64bit arch.

If no, "unsigned long" type is not enough on 32bit, or we need to limit
slack_hold_time to small intervals...
