From: Patrick McHardy <kaber@trash.net>
Subject: Re: net_sched 07/07: add classful multiqueue dummy scheduler
Date: Mon, 07 Sep 2009 15:27:37 +0200
Message-ID: <4AA50A49.7010905@trash.net>
References: <20090906200409.GB8833@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34043 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbZIGN1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 09:27:39 -0400
In-Reply-To: <20090906200409.GB8833@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
>>  struct Qdisc_class_ops
>>  {
>>  	/* Child qdisc manipulation */
>> +	unsigned int		(*select_queue)(struct Qdisc *, struct tcmsg *);
>>  	int			(*graft)(struct Qdisc *, unsigned long cl,
>>  					struct Qdisc *, struct Qdisc **);
>>  	struct Qdisc *		(*leaf)(struct Qdisc *, unsigned long cl);
>> @@ -122,6 +123,7 @@ struct Qdisc_ops
>>  	void			(*reset)(struct Qdisc *);
>>  	void			(*destroy)(struct Qdisc *);
>>  	int			(*change)(struct Qdisc *, struct nlattr *arg);
>> +	void			(*attach)(struct Qdisc *);
> 
> Probably it's a matter of taste, but I wonder why these two methods
> used only by one qdisc in max 2 places can't be functions instead
> (maybe even static in case of select_queue)? (And this mq sched could
> be tested with some flag instead of ->attach, I guess.)

Yes, we could also use normal functions. Either way is fine with me.

>> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
>> index d71f12b..2a78d54 100644
>> --- a/net/sched/sch_api.c
>> +++ b/net/sched/sch_api.c
>> @@ -678,6 +678,11 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
>>  		if (dev->flags & IFF_UP)
>>  			dev_deactivate(dev);
>>  
>> +		if (new && new->ops->attach) {
>> +			new->ops->attach(new);
>> +			num_q = 0;
>> +		}
>> +
> 
> Actually, I wonder if it's not cleaner to let replace all qdiscs with
> noops below like in qdisc delete case, and do this attaching in one
> place only (dev_activate).

I don't think that would work since dev_activate() allocates its own
qdiscs, which use different handles than those specified by userspace.
We also need the new qdisc for notifications. It would be a nice
cleanup however if you can make it work.

>> @@ -1095,10 +1100,16 @@ create_n_graft:
>>  		q = qdisc_create(dev, &dev->rx_queue,
>>  				 tcm->tcm_parent, tcm->tcm_parent,
>>  				 tca, &err);
>> -	else
>> -		q = qdisc_create(dev, netdev_get_tx_queue(dev, 0),
>> +	else {
>> +		unsigned int ntx = 0;
>> +
>> +		if (p && p->ops->cl_ops && p->ops->cl_ops->select_queue)
>> +			ntx = p->ops->cl_ops->select_queue(p, tcm);
> 
> So, this if could be probably made shorter with a common function, but
> the main point is: this probably works only for qdiscs having mq as a
> parent, and not below.

Yes. mq can only be attached to the root however, so its not
possible to use it as a child qdisc.

>> +static int mq_init(struct Qdisc *sch, struct nlattr *opt)
>> +{
>> +	struct net_device *dev = qdisc_dev(sch);
>> +	struct mq_sched *priv = qdisc_priv(sch);
>> +	struct netdev_queue *dev_queue;
>> +	struct Qdisc *qdisc;
>> +	unsigned int ntx;
>> +
>> +	if (sch->parent != TC_H_ROOT)
>> +		return -EOPNOTSUPP;
>> +
>> +	if (!netif_is_multiqueue(dev))
>> +		return -EOPNOTSUPP;
>> +
>> +	/* pre-allocate qdiscs, attachment can't fail */
>> +	priv->qdiscs = kcalloc(dev->num_tx_queues, sizeof(priv->qdiscs[0]),
>> +			       GFP_KERNEL);
> 
> I guess we could avoid this at all or at least to do it in one step with
> current ->attach.

It seemed easier this way, but I don't care much where its done exactly.

>> +	if (priv->qdiscs == NULL)
>> +		return -ENOMEM;
>> +
>> +	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
>> +		dev_queue = netdev_get_tx_queue(dev, ntx);
>> +		qdisc = qdisc_create_dflt(dev, dev_queue, &pfifo_fast_ops,
>> +					  TC_H_MAKE(TC_H_MAJ(sch->handle),
>> +						    TC_H_MIN(ntx + 1)));
> 
> As I wrote in 05/07 comment, I wonder if we really can't achieve this
> with old TC_H_ROOT parentid, and maybe some mapping while dumping to
> the userspace only.

I don't see the advantage.

> Another possibility would be considering a new
> kind of root (mqroot?) to tell precisely, where a new qdisc should be
> added.

That's what mq is doing.

>> +static int mq_dump(struct Qdisc *sch, struct sk_buff *skb)
>> +{
>> +	struct net_device *dev = qdisc_dev(sch);
>> +	struct Qdisc *qdisc;
>> +	unsigned int ntx;
>> +
>> +	sch->q.qlen = 0;
>> +	memset(&sch->bstats, 0, sizeof(sch->bstats));
>> +	memset(&sch->qstats, 0, sizeof(sch->qstats));
>> +
>> +	for (ntx = 0; ntx < dev->num_tx_queues; ntx++) {
>> +		qdisc = netdev_get_tx_queue(dev, ntx)->qdisc_sleeping;
>> +		spin_lock_bh(qdisc_lock(qdisc));
>> +		sch->q.qlen		+= qdisc->q.qlen;
>> +		sch->bstats.bytes	+= qdisc->bstats.bytes;
>> +		sch->bstats.packets	+= qdisc->bstats.packets;
>> +		sch->qstats.qlen	+= qdisc->qstats.qlen;
> 
> Like in Christoph's case, we should probably use q.qlen instead.

Its done a few lines above. This simply sums up all members of qstats.
