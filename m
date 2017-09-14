From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: Re: [RFC net-next 2/5] net/sched: Introduce Credit Based Shaper (CBS) qdisc
Date: Wed, 13 Sep 2017 17:39:23 -0700
Message-ID: <871snajepw.fsf@intel.com>
References: <20170901012625.14838-1-vinicius.gomes@intel.com> <20170901012625.14838-3-vinicius.gomes@intel.com> <20170908134332.GD9064@sisyphus.home.austad.us>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, intel-wired-lan@lists.osuosl.org,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com,
        richardcochran@gmail.com
To: Henrik Austad <henrik@austad.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:55420 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751173AbdINAjY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 13 Sep 2017 20:39:24 -0400
In-Reply-To: <20170908134332.GD9064@sisyphus.home.austad.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Henrik,

Henrik Austad <henrik@austad.us> writes:

> On Thu, Aug 31, 2017 at 06:26:22PM -0700, Vinicius Costa Gomes wrote:
>> This queueing discipline implements the shaper algorithm defined by
>> the 802.1Q-2014 Section 8.6.8.2 and detailed in Annex L.
>>
>> It's primary usage is to apply some bandwidth reservation to user
>> defined traffic classes, which are mapped to different queues via the
>> mqprio qdisc.
>>
>> Initially, it only supports offloading the traffic shaping work to
>> supporting controllers.
>>
>> Later, when a software implementation is added, the current dependency
>> on being installed "under" mqprio can be lifted.
>>
>> Signed-off-by: Vinicius Costa Gomes <vinicius.gomes@intel.com>
>> Signed-off-by: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
>
> So, I started testing this in my VM to make sure I didn't do anything silly
> and it exploded spectacularly as it used the underlying e1000 driver which
> does not have a ndo_setup_tc present.
>
> I commented inline below, but as a tl;dr
>
> The cbs_init() would call into cbs_change() that would correctly detect
> that ndo_setup_tc is missing and abort. However, at this stage it would try
> to desroy the qdisc and in cbs_destroy() there's no such guard leading to a
>
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000010
>
> Fixing that, another NULL would be found when the code walks into
> qdisc_destroy(q->qdisc).
>
> Apart from this, it loaded fine after some wrestling with tc :)
>
> Awesome! :D
>
>> ---
>>  include/linux/netdevice.h |   1 +
>>  net/sched/Kconfig         |  11 ++
>>  net/sched/Makefile        |   1 +
>>  net/sched/sch_cbs.c       | 286 ++++++++++++++++++++++++++++++++++++++++++++++
>>  4 files changed, 299 insertions(+)
>>  create mode 100644 net/sched/sch_cbs.c
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 35de8312e0b5..dd9a2ecd0c03 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -775,6 +775,7 @@ enum tc_setup_type {
>>  	TC_SETUP_CLSFLOWER,
>>  	TC_SETUP_CLSMATCHALL,
>>  	TC_SETUP_CLSBPF,
>> +	TC_SETUP_CBS,
>>  };
>>
>>  /* These structures hold the attributes of xdp state that are being passed
>> diff --git a/net/sched/Kconfig b/net/sched/Kconfig
>> index e70ed26485a2..c03d86a7775e 100644
>> --- a/net/sched/Kconfig
>> +++ b/net/sched/Kconfig
>> @@ -172,6 +172,17 @@ config NET_SCH_TBF
>>  	  To compile this code as a module, choose M here: the
>>  	  module will be called sch_tbf.
>>
>> +config NET_SCH_CBS
>
> Shouldn't this depend on NET_SCH_MQPRIO as it is supposed to hook into
> that?

Right now, the CBS shaper only makes sense with mqprio, later it may use
some other qdisc (like "taprio" mentioned in the cover letter) to hook
into, so, yes, you are right, there's a dependency here, better make it
clear. Will fix.

>
> @@ -173,6 +173,7 @@ config NET_SCH_TBF
>           module will be called sch_tbf.
>
>  config NET_SCH_CBS
> +       depends on NET_SCH_MQPRIO
>         tristate "Credit Based Shaper (CBS)"
>         ---help---
>           Say Y here if you want to use the Credit Based Shaper (CBS) packet
>
>> +	tristate "Credit Based Shaper (CBS)"
>> +	---help---
>> +	  Say Y here if you want to use the Credit Based Shaper (CBS) packet
>> +	  scheduling algorithm.
>> +
>> +	  See the top of <file:net/sched/sch_cbs.c> for more details.
>> +
>> +	  To compile this code as a module, choose M here: the
>> +	  module will be called sch_cbs.
>> +
>>  config NET_SCH_GRED
>>  	tristate "Generic Random Early Detection (GRED)"
>>  	---help---
>> diff --git a/net/sched/Makefile b/net/sched/Makefile
>> index 7b915d226de7..80c8f92d162d 100644
>> --- a/net/sched/Makefile
>> +++ b/net/sched/Makefile
>> @@ -52,6 +52,7 @@ obj-$(CONFIG_NET_SCH_FQ_CODEL)	+= sch_fq_codel.o
>>  obj-$(CONFIG_NET_SCH_FQ)	+= sch_fq.o
>>  obj-$(CONFIG_NET_SCH_HHF)	+= sch_hhf.o
>>  obj-$(CONFIG_NET_SCH_PIE)	+= sch_pie.o
>> +obj-$(CONFIG_NET_SCH_CBS)	+= sch_cbs.o
>>
>>  obj-$(CONFIG_NET_CLS_U32)	+= cls_u32.o
>>  obj-$(CONFIG_NET_CLS_ROUTE4)	+= cls_route.o
>> diff --git a/net/sched/sch_cbs.c b/net/sched/sch_cbs.c
>> new file mode 100644
>> index 000000000000..1c86a9e14150
>> --- /dev/null
>> +++ b/net/sched/sch_cbs.c
>> @@ -0,0 +1,286 @@
>> +/*
>> + * net/sched/sch_cbs.c	Credit Based Shaper
>> + *
>> + *		This program is free software; you can redistribute it and/or
>> + *		modify it under the terms of the GNU General Public License
>> + *		as published by the Free Software Foundation; either version
>> + *		2 of the License, or (at your option) any later version.
>> + *
>> + * Authors:	Vininicius Costa Gomes <vinicius.gomes@intel.com>
>> + *
>> + */
>> +
>> +#include <linux/module.h>
>> +#include <linux/types.h>
>> +#include <linux/kernel.h>
>> +#include <linux/string.h>
>> +#include <linux/errno.h>
>> +#include <linux/skbuff.h>
>> +#include <net/netlink.h>
>> +#include <net/sch_generic.h>
>> +#include <net/pkt_sched.h>
>> +
>> +struct cbs_sched_data {
>> +	struct Qdisc *qdisc; /* Inner qdisc, default - pfifo queue */
>> +	s32 queue;
>> +	s32 locredit;
>> +	s32 hicredit;
>> +	s32 sendslope;
>> +	s32 idleslope;
>> +};
>> +
>> +static int cbs_enqueue(struct sk_buff *skb, struct Qdisc *sch,
>> +		       struct sk_buff **to_free)
>> +{
>> +	struct cbs_sched_data *q = qdisc_priv(sch);
>> +	int ret;
>> +
>> +	ret = qdisc_enqueue(skb, q->qdisc, to_free);
>> +	if (ret != NET_XMIT_SUCCESS) {
>> +		if (net_xmit_drop_count(ret))
>> +			qdisc_qstats_drop(sch);
>> +		return ret;
>> +	}
>> +
>> +	qdisc_qstats_backlog_inc(sch, skb);
>> +	sch->q.qlen++;
>> +	return NET_XMIT_SUCCESS;
>> +}
>> +
>> +static struct sk_buff *cbs_dequeue(struct Qdisc *sch)
>> +{
>> +	struct cbs_sched_data *q = qdisc_priv(sch);
>> +	struct sk_buff *skb;
>> +
>> +	skb = q->qdisc->ops->peek(q->qdisc);
>> +	if (skb) {
>> +		skb = qdisc_dequeue_peeked(q->qdisc);
>> +		if (unlikely(!skb))
>> +			return NULL;
>> +
>> +		qdisc_qstats_backlog_dec(sch, skb);
>> +		sch->q.qlen--;
>> +		qdisc_bstats_update(sch, skb);
>> +
>> +		return skb;
>> +	}
>> +	return NULL;
>> +}
>> +
>> +static void cbs_reset(struct Qdisc *sch)
>> +{
>> +	struct cbs_sched_data *q = qdisc_priv(sch);
>> +
>> +	qdisc_reset(q->qdisc);
>> +}
>> +
>> +static const struct nla_policy cbs_policy[TCA_CBS_MAX + 1] = {
>> +	[TCA_CBS_PARMS]	= { .len = sizeof(struct tc_cbs_qopt) },
>> +};
>> +
>> +static int cbs_change(struct Qdisc *sch, struct nlattr *opt)
>> +{
>> +	struct cbs_sched_data *q = qdisc_priv(sch);
>> +	struct tc_cbs_qopt_offload cbs = { };
>> +	struct nlattr *tb[TCA_CBS_MAX + 1];
>> +	const struct net_device_ops *ops;
>> +	struct tc_cbs_qopt *qopt;
>> +	struct net_device *dev;
>> +	int err;
>> +
>> +	err = nla_parse_nested(tb, TCA_CBS_MAX, opt, cbs_policy, NULL);
>> +	if (err < 0)
>> +		return err;
>> +
>> +	err = -EINVAL;
>> +	if (!tb[TCA_CBS_PARMS])
>> +		goto done;
>> +
>> +	qopt = nla_data(tb[TCA_CBS_PARMS]);
>> +
>> +	dev = qdisc_dev(sch);
>> +	ops = dev->netdev_ops;
>> +
>> +	/* FIXME: this means that we can only install this qdisc
>> +	 * "under" mqprio. Do we need a more generic way to retrieve
>> +	 * the queue, or do we pass the netdev_queue to the driver?
>> +	 */
>> +	cbs.queue = TC_H_MIN(sch->parent) - 1 - netdev_get_num_tc(dev);
>> +
>> +	cbs.enable = 1;
>> +	cbs.hicredit = qopt->hicredit;
>> +	cbs.locredit = qopt->locredit;
>> +	cbs.idleslope = qopt->idleslope;
>> +	cbs.sendslope = qopt->sendslope;
>> +
>> +	err = -ENOTSUPP;
>> +	if (!ops->ndo_setup_tc)
>> +		goto done;
>
> This confuses tc a bit, and looking at other qdisc schedulers, it seems
> like EOPNOTSUPP is an alternative, this changes the output from
>
> RTNETLINK answers: Unknown error 524
>  - to
> RTNETLINK answers: Operation not supported
>

Yeah, I missed this. Thanks for catching this.

> which perhaps is more informative.
>
>> +
>> +	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CBS, &cbs);
>> +	if (err < 0)
>> +		goto done;
>> +
>> +	q->queue = cbs.queue;
>> +	q->hicredit = cbs.hicredit;
>> +	q->locredit = cbs.locredit;
>> +	q->idleslope = cbs.idleslope;
>> +	q->sendslope = cbs.sendslope;
>> +
>> +done:
>> +	return err;
>> +}
>> +
>> +static int cbs_init(struct Qdisc *sch, struct nlattr *opt)
>> +{
>> +	struct cbs_sched_data *q = qdisc_priv(sch);
>> +
>> +	if (!opt)
>> +		return -EINVAL;
>> +
>> +	q->qdisc = fifo_create_dflt(sch, &pfifo_qdisc_ops, 1024);
>> +	qdisc_hash_add(q->qdisc, true);
>> +
>> +	return cbs_change(sch, opt);
>> +}
>> +
>> +static void cbs_destroy(struct Qdisc *sch)
>> +{
>> +	struct cbs_sched_data *q = qdisc_priv(sch);
>> +	struct tc_cbs_qopt_offload cbs = { };
>> +	struct net_device *dev;
>> +	int err;
>> +
>> +	q->hicredit = 0;
>> +	q->locredit = 0;
>> +	q->idleslope = 0;
>> +	q->sendslope = 0;
>> +
>> +	dev = qdisc_dev(sch);
>> +
>> +	cbs.queue = q->queue;
>> +	cbs.enable = 0;
>> +
>> +	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CBS, &cbs);
>
> This can lead to NULL pointer deref if it is not set (tested for in
> cbs_change and error there leads us here, which then explodes).

Fixed.

>
>> +	if (err < 0)
>> +		pr_warn("Couldn't reset queue %d to default values\n",
>> +			cbs.queue);
>> +
>> +	qdisc_destroy(q->qdisc);
>
> Same, q->qdisc was NULL when cbs_init() failed.
>

Fixed the error path, thanks.


Cheers,
