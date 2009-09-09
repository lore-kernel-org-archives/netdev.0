From: Patrick McHardy <kaber@trash.net>
Subject: Re: net_sched 07/07: add classful multiqueue dummy scheduler
Date: Wed, 09 Sep 2009 18:01:26 +0200
Message-ID: <4AA7D156.60801@trash.net>
References: <20090906200409.GB8833@ami.dom.local> <4AA50A49.7010905@trash.net> <20090907192429.GC4451@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40675 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752724AbZIIQBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 12:01:32 -0400
In-Reply-To: <20090907192429.GC4451@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Mon, Sep 07, 2009 at 03:27:37PM +0200, Patrick McHardy wrote:
>> Jarek Poplawski wrote:
> ...
>>>> +static int mq_dump(struct Qdisc *sch, struct sk_buff *skb)
>>>> +{
>>>> +	struct net_device *dev = qdisc_dev(sch);
>>>> +	struct Qdisc *qdisc;
>>>> +	unsigned int ntx;
>>>> +
>>>> +	sch->q.qlen = 0;
>>>> +	memset(&sch->bstats, 0, sizeof(sch->bstats));
>>>> +	memset(&sch->qstats, 0, sizeof(sch->qstats));
>>>> +
>>>> +	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
>>>> +		qdisc = netdev_get_tx_queue(dev, ntx)->qdisc_sleeping;
>>>> +		spin_lock_bh(qdisc_lock(qdisc));
>>>> +		sch->q.qlen		+= qdisc->q.qlen;
>>>> +		sch->bstats.bytes	+= qdisc->bstats.bytes;
>>>> +		sch->bstats.packets	+= qdisc->bstats.packets;
>>>> +		sch->qstats.qlen	+= qdisc->qstats.qlen;
>>> Like in Christoph's case, we should probably use q.qlen instead.
>> Its done a few lines above. This simply sums up all members of qstats.
> 
> AFAICS these members are updated only in tc_fill_qdisc, starting from
> the root, so they might be not up-to-date at the moment, unless I miss
> something.

Right. Its overwritten again in tc_fill_qdisc with the proper
value contained in sch->q.qlen however, so the final value
dumped to userspace is correct. So we can simply remove the
qstats.qlen handling in mq_dump().

