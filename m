From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [net-next-2.6 PATCH v2 3/3] net_sched: implement a root container
 qdisc sch_mclass
Date: Fri, 31 Dec 2010 00:37:45 +0100
Message-ID: <4D1D17C9.3040500@gmail.com>
References: <20101221192831.9703.56356.stgit@jf-dev1-dcblab> <20101221192930.9703.63791.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, hadi@cyberus.ca,
	shemminger@vyatta.com, tgraf@infradead.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, nhorman@tuxdriver.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:51789 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752386Ab0L3Xhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Dec 2010 18:37:52 -0500
Received: by bwz15 with SMTP id 15so12076278bwz.19
        for <netdev@vger.kernel.org>; Thu, 30 Dec 2010 15:37:51 -0800 (PST)
In-Reply-To: <20101221192930.9703.63791.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Fastabend wrote:
> This implements a mclass 'multi-class' queueing discipline that by
> default creates multiple mq qdisc's one for each traffic class. Each
> mq qdisc then owns a range of queues per the netdev_tc_txq mappings.

Is it really necessary to add one more abstraction layer for this,
probably not most often used (or even asked by users), functionality?
Why mclass can't simply do these few things more instead of attaching
(and changing) mq?

...
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index 0af57eb..723ee52 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -50,6 +50,7 @@ struct Qdisc {
>  #define TCQ_F_INGRESS		4
>  #define TCQ_F_CAN_BYPASS	8
>  #define TCQ_F_MQROOT		16
> +#define TCQ_F_MQSAFE		32

If every other qdisc added a flag for qdiscs it likes...

> @@ -709,7 +709,13 @@ static void attach_default_qdiscs(struct net_device *dev)
>  		dev->qdisc = txq->qdisc_sleeping;
>  		atomic_inc(&dev->qdisc->refcnt);
>  	} else {
> -		qdisc = qdisc_create_dflt(txq, &mq_qdisc_ops, TC_H_ROOT);
> +		if (dev->num_tc)

Actually, where this num_tc is expected to be set? I can see it inside
mclass only, with unsetting on destruction, but probably I miss something.

> +			qdisc = qdisc_create_dflt(txq, &mclass_qdisc_ops,
> +						  TC_H_ROOT);
> +		else
> +			qdisc = qdisc_create_dflt(txq, &mq_qdisc_ops,
> +						  TC_H_ROOT);
> +
> +static int mclass_init(struct Qdisc *sch, struct nlattr *opt)
> +{
> +	struct net_device *dev = qdisc_dev(sch);
> +	struct mclass_sched *priv = qdisc_priv(sch);
> +	struct netdev_queue *dev_queue;
> +	struct Qdisc *qdisc;
> +	int i, err = -EOPNOTSUPP;
> +	struct tc_mclass_qopt *qopt = NULL;
> +
> +	/* Unwind attributes on failure */
> +	u8 unwnd_tc = dev->num_tc;
> +	u8 unwnd_map[16];

[TC_MAX_QUEUE] ?

> +	struct netdev_tc_txq unwnd_txq[16];
> +
> +	if (sch->parent != TC_H_ROOT)
> +		return -EOPNOTSUPP;
> +
> +	if (!netif_is_multiqueue(dev))
> +		return -EOPNOTSUPP;
> +
> +	if (nla_len(opt) < sizeof(*qopt))
> +		return -EINVAL;
> +	qopt = nla_data(opt);
> +
> +	memcpy(unwnd_map, dev->prio_tc_map, sizeof(unwnd_map));
> +	memcpy(unwnd_txq, dev->tc_to_txq, sizeof(unwnd_txq));
> +
> +	/* If the mclass options indicate that hardware should own
> +	 * the queue mapping then run ndo_setup_tc if this can not
> +	 * be done fail immediately.
> +	 */
> +	if (qopt->hw && dev->netdev_ops->ndo_setup_tc) {
> +		priv->hw_owned = 1;
> +		if (dev->netdev_ops->ndo_setup_tc(dev, qopt->num_tc))
> +			return -EINVAL;
> +	} else if (!qopt->hw) {
> +		if (mclass_parse_opt(dev, qopt))
> +			return -EINVAL;
> +
> +		if (netdev_set_num_tc(dev, qopt->num_tc))
> +			return -ENOMEM;
> +
> +		for (i = 0; i < qopt->num_tc; i++)
> +			netdev_set_tc_queue(dev, i,
> +					    qopt->count[i], qopt->offset[i]);
> +	} else {
> +		return -EINVAL;
> +	}
> +
> +	/* Always use supplied priority mappings */
> +	for (i = 0; i < 16; i++) {

i < qopt->num_tc ?

> +		if (netdev_set_prio_tc_map(dev, i, qopt->prio_tc_map[i])) {
> +			err = -EINVAL;
> +			goto tc_err;
> +		}
> +	}
> +
> +	/* pre-allocate qdisc, attachment can't fail */
> +	priv->qdiscs = kcalloc(qopt->num_tc,
> +			       sizeof(priv->qdiscs[0]), GFP_KERNEL);
> +	if (priv->qdiscs == NULL) {
> +		err = -ENOMEM;
> +		goto tc_err;
> +	}
> +
> +	for (i = 0; i < dev->num_tc; i++) {
> +		dev_queue = netdev_get_tx_queue(dev, dev->tc_to_txq[i].offset);

Are these offsets etc. validated?

Jarek P.
