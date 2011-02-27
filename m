From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: Re: txqueuelen has wrong units; should be time
Date: Sun, 27 Feb 2011 12:55:40 +0200
Message-ID: <20110227125540.40754c5y78j9u2m8@hayate.sektori.org>
References: <AANLkTimd5GQwtUFP2fD_An=M8ajBD8DJpzxQJezv8fB8@mail.gmail.com>
 <alpine.DEB.1.10.1102270758580.11974@uplift.swm.pp.se>
 <1298793252.8726.45.camel@edumazet-laptop>
 <AANLkTinyE10wtM_xJsufT_3s3hvti7CN+9nyqScWa6SA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_4apxj7u8upq8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Mikael Abrahamsson <swmike@swm.pp.se>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Albert Cahalan <acahalan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sirokuusama.dnainternet.net ([83.102.40.133]:54253 "EHLO
	sirokuusama.dnainternet.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751925Ab1B0LC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Feb 2011 06:02:28 -0500
In-Reply-To: <AANLkTinyE10wtM_xJsufT_3s3hvti7CN+9nyqScWa6SA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This message is in MIME format.

--=_4apxj7u8upq8
Content-Type: text/plain;
 charset=ISO-8859-1;
 DelSp="Yes";
 format="flowed"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Quoting Albert Cahalan <acahalan@gmail.com>:

> On Sun, Feb 27, 2011 at 2:54 AM, Eric Dumazet <eric.dumazet@gmail.com> wr=
ote:
>> Le dimanche 27 f=E9vrier 2011 =E0 08:02 +0100, Mikael Abrahamsson a =E9c=
rit :
>>> On Sun, 27 Feb 2011, Albert Cahalan wrote:
>>>
>>> > Nanoseconds seems fine; it's unlikely you'd ever want
>>> > more than 4.2 seconds (32-bit unsigned) of queue.
> ...
>> Problem is some machines have slow High Resolution timing services.
>>
>> _If_ we have a time limit, it will probably use the low resolution (aka
>> jiffies), unless high resolution services are cheap.
>
> As long as that is totally internal to the kernel and never
> getting exposed by some API for setting the amount, sure.
>
>> I was thinking not having an absolute hard limit, but an EWMA based one.
>
> The whole point is to prevent stale packets, especially to prevent
> them from messing with TCP, so I really don't think so. I suppose
> you do get this to some extent via early drop.

I made simple hack on sch_fifo with per packet time limits =20
(attachment) this weekend and have been doing limited testing on =20
wireless link. I think hardlimit is fine, it's simple and does =20
somewhat same as what packet(-hard)limited buffer does, drops packets =20
when buffer is 'full'. My hack checks for timed out packets on =20
enqueue, might be wrong approach (on other hand might allow some more =20
burstiness).

-Jussi
--=_4apxj7u8upq8
Content-Type: text/x-csrc;
 charset=UTF-8;
 name="sch_fifo_to.c"
Content-Disposition: attachment;
 filename="sch_fifo_to.c"
Content-Transfer-Encoding: 7bit

/*
 * sch_fifo_timeout.c	Simple FIFO queue with per packet timeout.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation; either version 2 of the License, or (at your option) any later
 * version.
 *
 */

#include <linux/module.h>
#include <linux/slab.h>
#include <linux/types.h>
#include <linux/kernel.h>
#include <linux/errno.h>
#include <linux/skbuff.h>
#include <net/pkt_sched.h>
#include <net/inet_ecn.h>

#define DEFAULT_TIMEOUT_PKT_MS 10
#define DEFAULT_TIMEOUT_PKT PSCHED_NS2TICKS((u64)NSEC_PER_SEC * \
						DEFAULT_TIMEOUT_PKT_MS / 1000)

struct tc_fifo_timeout_qopt {
	__u64	timeout;	/* Max time packet may stay in buffer */
	__u32   limit;		/* Queue length: bytes for bfifo, packets for pfifo */
};

struct fifo_timeout_skb_cb {
	psched_time_t	time_queued;
};

struct fifo_timeout_sched_data {
	psched_tdiff_t	timeout;
	u32		limit;
};

static inline
struct fifo_timeout_skb_cb *fifo_timeout_skb_cb(struct sk_buff *skb)
{
	BUILD_BUG_ON(sizeof(skb->cb) <
		sizeof(struct qdisc_skb_cb) +
			sizeof(struct fifo_timeout_skb_cb));
	return (struct fifo_timeout_skb_cb *)qdisc_skb_cb(skb)->data;
}

static void pfifo_timeout_drop_timedout_packets(struct Qdisc *sch,
						psched_time_t now)
{
	struct fifo_timeout_sched_data *q = qdisc_priv(sch);
	struct sk_buff *skb;

check_next:
	skb = qdisc_peek_head(sch);
	if (likely(!skb))
		return;

	if (likely(fifo_timeout_skb_cb(skb)->time_queued + q->timeout > now))
		return;

	__qdisc_queue_drop_head(sch, &sch->q);
	sch->qstats.drops++;

	goto check_next;
}

static int pfifo_tail_enqueue(struct sk_buff *skb, struct Qdisc* sch)
{
	struct fifo_timeout_sched_data *q = qdisc_priv(sch);

	if (likely(skb_queue_len(&sch->q) < q->limit))
		return qdisc_enqueue_tail(skb, sch);

	/* queue full, remove one skb to fulfill the limit */
	__qdisc_queue_drop_head(sch, &sch->q);
	sch->qstats.drops++;
	qdisc_enqueue_tail(skb, sch);

	return NET_XMIT_CN;
}

static int bfifo_enqueue(struct sk_buff *skb, struct Qdisc* sch)
{
	struct fifo_timeout_sched_data *q = qdisc_priv(sch);

	if (likely(sch->qstats.backlog + qdisc_pkt_len(skb) <= q->limit))
		return qdisc_enqueue_tail(skb, sch);

	return qdisc_reshape_fail(skb, sch);
}

static int pfifo_enqueue(struct sk_buff *skb, struct Qdisc* sch)
{
	struct fifo_timeout_sched_data *q = qdisc_priv(sch);

	if (likely(skb_queue_len(&sch->q) < q->limit))
		return qdisc_enqueue_tail(skb, sch);

	return qdisc_reshape_fail(skb, sch);
}

static int pfifo_timeout_tail_enqueue(struct sk_buff *skb, struct Qdisc* sch)
{
	psched_time_t now = psched_get_time();

	fifo_timeout_skb_cb(skb)->time_queued = now;
	pfifo_timeout_drop_timedout_packets(sch, now);

	return pfifo_tail_enqueue(skb, sch);
}

static int bfifo_timeout_enqueue(struct sk_buff *skb, struct Qdisc* sch)
{
	psched_time_t now = psched_get_time();

	fifo_timeout_skb_cb(skb)->time_queued = now;
	pfifo_timeout_drop_timedout_packets(sch, now);

	return bfifo_enqueue(skb, sch);
}

static int pfifo_timeout_enqueue(struct sk_buff *skb, struct Qdisc* sch)
{
	psched_time_t now = psched_get_time();

	fifo_timeout_skb_cb(skb)->time_queued = now;
	pfifo_timeout_drop_timedout_packets(sch, now);

	return pfifo_enqueue(skb, sch);
}

static int fifo_timeout_init(struct Qdisc *sch, struct nlattr *opt)
{
	struct fifo_timeout_sched_data *q = qdisc_priv(sch);

	if (opt == NULL) {
		u32 limit = qdisc_dev(sch)->tx_queue_len ? : 1;

		q->limit = limit;
		q->timeout = DEFAULT_TIMEOUT_PKT;
	} else {
		struct tc_fifo_timeout_qopt *ctl = nla_data(opt);

		if (nla_len(opt) < sizeof(*ctl))
			return -EINVAL;

		q->limit = ctl->limit;
		q->timeout = ctl->timeout ? : DEFAULT_TIMEOUT_PKT;
	}

	return 0;
}

static int fifo_timeout_dump(struct Qdisc *sch, struct sk_buff *skb)
{
	struct fifo_timeout_sched_data *q = qdisc_priv(sch);
	struct tc_fifo_timeout_qopt opt = {
		.limit = q->limit,
		.timeout = q->timeout
	};

	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
	return skb->len;

nla_put_failure:
	return -1;
}

static struct Qdisc_ops pfifo_timeout_qdisc_ops __read_mostly = {
	.id		=	"pfifo_timeout",
	.priv_size	=	sizeof(struct fifo_timeout_sched_data),
	.enqueue	=	pfifo_timeout_enqueue,
	.dequeue	=	qdisc_dequeue_head,
	.peek		=	qdisc_peek_head,
	.drop		=	qdisc_queue_drop,
	.init		=	fifo_timeout_init,
	.reset		=	qdisc_reset_queue,
	.change		=	fifo_timeout_init,
	.dump		=	fifo_timeout_dump,
	.owner		=	THIS_MODULE,
};

static struct Qdisc_ops bfifo_timeout_qdisc_ops __read_mostly = {
	.id		=	"bfifo_timeout",
	.priv_size	=	sizeof(struct fifo_timeout_sched_data),
	.enqueue	=	bfifo_timeout_enqueue,
	.dequeue	=	qdisc_dequeue_head,
	.peek		=	qdisc_peek_head,
	.drop		=	qdisc_queue_drop,
	.init		=	fifo_timeout_init,
	.reset		=	qdisc_reset_queue,
	.change		=	fifo_timeout_init,
	.dump		=	fifo_timeout_dump,
	.owner		=	THIS_MODULE,
};

static struct Qdisc_ops pfifo_head_drop_timeout_qdisc_ops __read_mostly = {
	.id		=	"pfifo_hd_tout",
	.priv_size	=	sizeof(struct fifo_timeout_sched_data),
	.enqueue	=	pfifo_timeout_tail_enqueue,
	.dequeue	=	qdisc_dequeue_head,
	.peek		=	qdisc_peek_head,
	.drop		=	qdisc_queue_drop_head,
	.init		=	fifo_timeout_init,
	.reset		=	qdisc_reset_queue,
	.change		=	fifo_timeout_init,
	.dump		=	fifo_timeout_dump,
	.owner		=	THIS_MODULE,
};

static int __init fifo_timeout_module_init(void)
{
	int retval;

	retval = register_qdisc(&pfifo_timeout_qdisc_ops);
	if (retval)
		goto cleanup;
	retval = register_qdisc(&bfifo_timeout_qdisc_ops);
	if (retval)
		goto cleanup;
	retval = register_qdisc(&pfifo_head_drop_timeout_qdisc_ops);
	if (retval)
		goto cleanup;

	return 0;

cleanup:
	unregister_qdisc(&pfifo_timeout_qdisc_ops);
	unregister_qdisc(&bfifo_timeout_qdisc_ops);
	unregister_qdisc(&pfifo_head_drop_timeout_qdisc_ops);
	return retval;
}
static void __exit fifo_timeout_module_exit(void)
{
	unregister_qdisc(&pfifo_timeout_qdisc_ops);
	unregister_qdisc(&bfifo_timeout_qdisc_ops);
	unregister_qdisc(&pfifo_head_drop_timeout_qdisc_ops);
}

module_init(fifo_timeout_module_init)
module_exit(fifo_timeout_module_exit)
MODULE_LICENSE("GPL");


--=_4apxj7u8upq8--

