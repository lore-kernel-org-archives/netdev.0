From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: Re: txqueuelen has wrong units; should be time
Date: Mon, 28 Feb 2011 13:23:41 +0200
Message-ID: <20110228132341.194975v6ojrudl18@hayate.sektori.org>
References: <AANLkTimd5GQwtUFP2fD_An=M8ajBD8DJpzxQJezv8fB8@mail.gmail.com>
 <alpine.DEB.1.10.1102270758580.11974@uplift.swm.pp.se>
 <1298793252.8726.45.camel@edumazet-laptop>
 <AANLkTinyE10wtM_xJsufT_3s3hvti7CN+9nyqScWa6SA@mail.gmail.com>
 <20110227125540.40754c5y78j9u2m8@hayate.sektori.org>
 <AANLkTimofhhH5omyk=HhkyaNG+MGqoac4rDf=dPuR7K-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=_51sxx3iz2kc"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Mikael Abrahamsson <swmike@swm.pp.se>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Albert Cahalan <acahalan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimofhhH5omyk=HhkyaNG+MGqoac4rDf=dPuR7K-@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This message is in MIME format.

--=_51sxx3iz2kc
Content-Type: text/plain;
 charset=ISO-8859-1;
 DelSp="Yes";
 format="flowed"
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

Quoting Albert Cahalan <acahalan@gmail.com>:

> On Sun, Feb 27, 2011 at 5:55 AM, Jussi Kivilinna
> <jussi.kivilinna@mbnet.fi> wrote:
>
>> I made simple hack on sch_fifo with per packet time limits (attachment) this
>> weekend and have been doing limited testing on wireless link. I think
>> hardlimit is fine, it's simple and does somewhat same as what
>> packet(-hard)limited buffer does, drops packets when buffer is 'full'. My
>> hack checks for timed out packets on enqueue, might be wrong approach (on
>> other hand might allow some more burstiness).
>
> Thanks!
>
> I think the default is too high. 1 ms may even be a bit high.

Well, with 10ms buffer timeout latency goes to 10-20ms on 54Mbit wifi  
link (zd1211rw driver) from >500ms (ping rtt when iperf running same  
time). So for that it's good enough.

>
> I suppose there is a need to allow at least 2 packets despite any
> time limits, so that it remains possible to use a traditional modem
> even if a huge packet takes several seconds to send.
>

I made EWMA version of my fifo hack (attached). I added minimum 2  
packet queue limit and  probabilistic 1% ECN marking/dropping for  
timeout/2.

-Jussi


--=_51sxx3iz2kc
Content-Type: text/x-csrc;
 charset=UTF-8;
 name="sch_fifo_ewma.c"
Content-Disposition: attachment;
 filename="sch_fifo_ewma.c"
Content-Transfer-Encoding: 7bit

/*
 * sch_fifo_ewma.c	Simple FIFO EWMA timelimit queue.
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

#include <linux/version.h>
#if LINUX_VERSION_CODE <= KERNEL_VERSION(2, 6, 37)
#include "average.h"
#else
#include <linux/average.h>
#endif

#define DEFAULT_PKT_TIMEOUT_MS		10
#define DEFAULT_PKT_TIMEOUT		PSCHED_NS2TICKS(NSEC_PER_MSEC * \
							DEFAULT_PKT_TIMEOUT_MS)
#define DEFAULT_PROB_HALF_DROP		10	/* 1% */

#define FIFO_EWMA_MIN_QDISC_LEN		2

struct tc_fifo_ewma_qopt {
	__u64	timeout;	/* Max time packet may stay in buffer */
	__u32   limit;		/* Queue length: bytes for bfifo, packets for pfifo */
};

struct fifo_ewma_skb_cb {
	psched_time_t	time_queued;
};

struct fifo_ewma_sched_data {
	psched_tdiff_t	timeout;
	u32		limit;
	struct ewma	ewma;
};

static inline
struct fifo_ewma_skb_cb *fifo_ewma_skb_cb(struct sk_buff *skb)
{
	BUILD_BUG_ON(sizeof(skb->cb) <
		sizeof(struct qdisc_skb_cb) +
			sizeof(struct fifo_ewma_skb_cb));
	return (struct fifo_ewma_skb_cb *)qdisc_skb_cb(skb)->data;
}

static int pfifo_tail_enqueue(struct sk_buff *skb, struct Qdisc* sch)
{
	struct fifo_ewma_sched_data *q = qdisc_priv(sch);

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
	struct fifo_ewma_sched_data *q = qdisc_priv(sch);

	if (likely(sch->qstats.backlog + qdisc_pkt_len(skb) <= q->limit))
		return qdisc_enqueue_tail(skb, sch);

	return qdisc_reshape_fail(skb, sch);
}

static int pfifo_enqueue(struct sk_buff *skb, struct Qdisc* sch)
{
	struct fifo_ewma_sched_data *q = qdisc_priv(sch);

	if (likely(skb_queue_len(&sch->q) < q->limit))
		return qdisc_enqueue_tail(skb, sch);

	return qdisc_reshape_fail(skb, sch);
}

static inline int fifo_get_prob(void)
{
	return (net_random() & 0xffff) * 1000 / 0xffff;
}

static struct sk_buff *fifo_ewma_dequeue(struct Qdisc* sch)
{
	struct fifo_ewma_sched_data *q = qdisc_priv(sch);
	struct sk_buff *skb;
	psched_tdiff_t tdiff;

	if (likely(!q->timeout))
		goto no_ewma;

	skb = qdisc_peek_head(sch);
	if (!skb)
		return NULL;

	/* update EWMA */
	tdiff = psched_get_time() - fifo_ewma_skb_cb(skb)->time_queued;
	ewma_add(&q->ewma, tdiff);

no_ewma:
	return qdisc_dequeue_head(sch);
}

#define FIFO_EWMA_OK	0
#define FIFO_EWMA_DROP	1
#define FIFO_EWMA_CN	2

static int fifo_check_ewma_drop(struct sk_buff *skb, struct Qdisc *sch)
{
	struct fifo_ewma_sched_data *q = qdisc_priv(sch);
	unsigned long fifo_latency_avg;
	int ret = FIFO_EWMA_OK;

	if (likely(!q->timeout))
		goto no_ewma;

	/* lower limit */
	if (skb_queue_len(&sch->q) <= FIFO_EWMA_MIN_QDISC_LEN)
		goto no_drop;

	fifo_latency_avg = ewma_read(&q->ewma);

	/* hard drop */
	if (fifo_latency_avg > q->timeout) {
		/*printk(KERN_WARNING "fifo_ewma: hard drop\n");*/
		return FIFO_EWMA_DROP;
	}

	/* probabilistic drop */
	if (fifo_latency_avg > q->timeout / 2 &&
				fifo_get_prob() < DEFAULT_PROB_HALF_DROP) {
		if (!INET_ECN_set_ce(skb)) {
			/*printk(KERN_WARNING "fifo_ewma: prob drop\n");*/
			return FIFO_EWMA_DROP;
		}

		/*printk(KERN_WARNING "fifo_ewma: prob mark\n");*/
		ret = FIFO_EWMA_CN;
	}

no_drop:
	fifo_ewma_skb_cb(skb)->time_queued = psched_get_time();
no_ewma:
	return ret;
}

static int pfifo_ewma_tail_enqueue(struct sk_buff *skb, struct Qdisc* sch)
{
	int ewma_action, ret;

	ewma_action = fifo_check_ewma_drop(skb, sch);
	if (unlikely(ewma_action == FIFO_EWMA_DROP))
		return qdisc_drop(skb, sch);

	ret = pfifo_tail_enqueue(skb, sch);
	if (unlikely(ret != NET_XMIT_SUCCESS))
		return ret;

	return unlikely(ewma_action == FIFO_EWMA_CN) ? NET_XMIT_CN : ret;
}

static int bfifo_ewma_enqueue(struct sk_buff *skb, struct Qdisc* sch)
{
	int ewma_action, ret;

	ewma_action = fifo_check_ewma_drop(skb, sch);
	if (unlikely(ewma_action == FIFO_EWMA_DROP))
		return qdisc_drop(skb, sch);

	ret = bfifo_enqueue(skb, sch);
	if (unlikely(ret != NET_XMIT_SUCCESS))
		return ret;

	return unlikely(ewma_action == FIFO_EWMA_CN) ? NET_XMIT_CN : ret;
}

static int pfifo_ewma_enqueue(struct sk_buff *skb, struct Qdisc* sch)
{
	int ewma_action, ret;

	ewma_action = fifo_check_ewma_drop(skb, sch);
	if (unlikely(ewma_action == FIFO_EWMA_DROP))
		return qdisc_drop(skb, sch);

	ret = pfifo_enqueue(skb, sch);
	if (unlikely(ret != NET_XMIT_SUCCESS))
		return ret;

	return unlikely(ewma_action == FIFO_EWMA_CN) ? NET_XMIT_CN : ret;
}

static int fifo_ewma_init(struct Qdisc *sch, struct nlattr *opt)
{
	struct fifo_ewma_sched_data *q = qdisc_priv(sch);

	if (opt == NULL) {
		u32 limit = qdisc_dev(sch)->tx_queue_len ? : 1;

		q->limit = limit;
		q->timeout = DEFAULT_PKT_TIMEOUT;
	} else {
		struct tc_fifo_ewma_qopt *ctl = nla_data(opt);

		if (nla_len(opt) < sizeof(*ctl))
			return -EINVAL;

		q->limit = ctl->limit;
		q->timeout = ctl->timeout ? : DEFAULT_PKT_TIMEOUT;
	}

	ewma_init(&q->ewma, 1, 64);

	return 0;
}

static int fifo_ewma_dump(struct Qdisc *sch, struct sk_buff *skb)
{
	struct fifo_ewma_sched_data *q = qdisc_priv(sch);
	struct tc_fifo_ewma_qopt opt = {
		.limit = q->limit,
		.timeout = q->timeout
	};

	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
	return skb->len;

nla_put_failure:
	return -1;
}

static struct Qdisc_ops pfifo_ewma_qdisc_ops __read_mostly = {
	.id		=	"pfifo_ewma",
	.priv_size	=	sizeof(struct fifo_ewma_sched_data),
	.enqueue	=	pfifo_ewma_enqueue,
	.dequeue	=	fifo_ewma_dequeue,
	.peek		=	qdisc_peek_head,
	.drop		=	qdisc_queue_drop,
	.init		=	fifo_ewma_init,
	.reset		=	qdisc_reset_queue,
	.change		=	fifo_ewma_init,
	.dump		=	fifo_ewma_dump,
	.owner		=	THIS_MODULE,
};

static struct Qdisc_ops bfifo_ewma_qdisc_ops __read_mostly = {
	.id		=	"bfifo_ewma",
	.priv_size	=	sizeof(struct fifo_ewma_sched_data),
	.enqueue	=	bfifo_ewma_enqueue,
	.dequeue	=	fifo_ewma_dequeue,
	.peek		=	qdisc_peek_head,
	.drop		=	qdisc_queue_drop,
	.init		=	fifo_ewma_init,
	.reset		=	qdisc_reset_queue,
	.change		=	fifo_ewma_init,
	.dump		=	fifo_ewma_dump,
	.owner		=	THIS_MODULE,
};

static struct Qdisc_ops pfifo_head_drop_ewma_qdisc_ops __read_mostly = {
	.id		=	"pfifo_hd_ewma",
	.priv_size	=	sizeof(struct fifo_ewma_sched_data),
	.enqueue	=	pfifo_ewma_tail_enqueue,
	.dequeue	=	fifo_ewma_dequeue,
	.peek		=	qdisc_peek_head,
	.drop		=	qdisc_queue_drop_head,
	.init		=	fifo_ewma_init,
	.reset		=	qdisc_reset_queue,
	.change		=	fifo_ewma_init,
	.dump		=	fifo_ewma_dump,
	.owner		=	THIS_MODULE,
};

static int __init fifo_ewma_module_init(void)
{
	int retval;

	retval = register_qdisc(&pfifo_ewma_qdisc_ops);
	if (retval)
		goto cleanup;
	retval = register_qdisc(&bfifo_ewma_qdisc_ops);
	if (retval)
		goto cleanup;
	retval = register_qdisc(&pfifo_head_drop_ewma_qdisc_ops);
	if (retval)
		goto cleanup;

	return 0;

cleanup:
	unregister_qdisc(&pfifo_ewma_qdisc_ops);
	unregister_qdisc(&bfifo_ewma_qdisc_ops);
	unregister_qdisc(&pfifo_head_drop_ewma_qdisc_ops);
	return retval;
}
static void __exit fifo_ewma_module_exit(void)
{
	unregister_qdisc(&pfifo_ewma_qdisc_ops);
	unregister_qdisc(&bfifo_ewma_qdisc_ops);
	unregister_qdisc(&pfifo_head_drop_ewma_qdisc_ops);
}

module_init(fifo_ewma_module_init)
module_exit(fifo_ewma_module_exit)
MODULE_LICENSE("GPL");

#include <linux/version.h>
#if LINUX_VERSION_CODE <= KERNEL_VERSION(2, 6, 37)
#include "average.c"
#endif


--=_51sxx3iz2kc--
