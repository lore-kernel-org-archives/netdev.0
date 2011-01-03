From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH v2 3/3] net_sched: implement a root container
 qdisc sch_mclass
Date: Sun, 02 Jan 2011 21:43:27 -0800
Message-ID: <4D2161FF.4070804@intel.com>
References: <20101221192831.9703.56356.stgit@jf-dev1-dcblab> <20101221192930.9703.63791.stgit@jf-dev1-dcblab> <4D1D17C9.3040500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hadi@cyberus.ca" <hadi@cyberus.ca>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:50965 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751603Ab1ACFoe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jan 2011 00:44:34 -0500
In-Reply-To: <4D1D17C9.3040500@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/30/2010 3:37 PM, Jarek Poplawski wrote:
> John Fastabend wrote:
>> This implements a mclass 'multi-class' queueing discipline that by
>> default creates multiple mq qdisc's one for each traffic class. Each
>> mq qdisc then owns a range of queues per the netdev_tc_txq mappings.
> 
> Is it really necessary to add one more abstraction layer for this,
> probably not most often used (or even asked by users), functionality?
> Why mclass can't simply do these few things more instead of attaching
> (and changing) mq?
> 

The statistics work nicely when the mq qdisc is used. 

qdisc mclass 8002: root  tc 4 map 0 1 2 3 0 1 2 3 1 1 1 1 1 1 1 1
             queues:(0:1) (2:3) (4:5) (6:15)
 Sent 140 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc mq 8003: parent 8002:1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc mq 8004: parent 8002:2
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc mq 8005: parent 8002:3
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc mq 8006: parent 8002:4
 Sent 140 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc sfq 8007: parent 8005:1 limit 127p quantum 1514b
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc sfq 8008: parent 8005:2 limit 127p quantum 1514b
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0

The mclass gives the statistics for the interface and then statistics on the mq qdisc gives statistics for each traffic class. Also, when using the 'mq qdisc' with this abstraction other qdisc can be grafted onto the queue. For example the sch_sfq is used in the above example.

Although I am not too hung up on this use case it does seem to be a good abstraction to me. Is it strictly necessary though no and looking at the class statistics of mclass could be used to get stats per traffic class.

> ...
>> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
>> index 0af57eb..723ee52 100644
>> --- a/include/net/sch_generic.h
>> +++ b/include/net/sch_generic.h
>> @@ -50,6 +50,7 @@ struct Qdisc {
>>  #define TCQ_F_INGRESS		4
>>  #define TCQ_F_CAN_BYPASS	8
>>  #define TCQ_F_MQROOT		16
>> +#define TCQ_F_MQSAFE		32
> 
> If every other qdisc added a flag for qdiscs it likes...
> 

then we run out of bits and get unneeded complexity. I think I will drop the MQSAFE bit completely and let user space catch this. The worst that should happen is the noop qdisc is used.

>> @@ -709,7 +709,13 @@ static void attach_default_qdiscs(struct net_device *dev)
>>  		dev->qdisc = txq->qdisc_sleeping;
>>  		atomic_inc(&dev->qdisc->refcnt);
>>  	} else {
>> -		qdisc = qdisc_create_dflt(txq, &mq_qdisc_ops, TC_H_ROOT);
>> +		if (dev->num_tc)
> 
> Actually, where this num_tc is expected to be set? I can see it inside
> mclass only, with unsetting on destruction, but probably I miss something.

Either through mclass as you noted or a driver could set the num_tc. One of the RFC's I sent out has ixgbe setting the num_tc when DCB was enabled.

>> +			qdisc = qdisc_create_dflt(txq, &mclass_qdisc_ops,
>> +						  TC_H_ROOT);
>> +		else
>> +			qdisc = qdisc_create_dflt(txq, &mq_qdisc_ops,
>> +						  TC_H_ROOT);
>> +
>> +static int mclass_init(struct Qdisc *sch, struct nlattr *opt)
>> +{
>> +	struct net_device *dev = qdisc_dev(sch);
>> +	struct mclass_sched *priv = qdisc_priv(sch);
>> +	struct netdev_queue *dev_queue;
>> +	struct Qdisc *qdisc;
>> +	int i, err = -EOPNOTSUPP;
>> +	struct tc_mclass_qopt *qopt = NULL;
>> +
>> +	/* Unwind attributes on failure */
>> +	u8 unwnd_tc = dev->num_tc;
>> +	u8 unwnd_map[16];
> 
> [TC_MAX_QUEUE] ?

Actually TC_BITMASK+1 is probably more accurate. This array maps the skb priority to a traffic class after the priority is masked with TC_BITMASK.

> 
>> +	struct netdev_tc_txq unwnd_txq[16];
>> +

Although unwnd_txq should be TC_MAX_QUEUE.

>> +	if (sch->parent != TC_H_ROOT)
>> +		return -EOPNOTSUPP;
>> +
>> +	if (!netif_is_multiqueue(dev))
>> +		return -EOPNOTSUPP;
>> +
>> +	if (nla_len(opt) < sizeof(*qopt))
>> +		return -EINVAL;
>> +	qopt = nla_data(opt);
>> +
>> +	memcpy(unwnd_map, dev->prio_tc_map, sizeof(unwnd_map));
>> +	memcpy(unwnd_txq, dev->tc_to_txq, sizeof(unwnd_txq));
>> +
>> +	/* If the mclass options indicate that hardware should own
>> +	 * the queue mapping then run ndo_setup_tc if this can not
>> +	 * be done fail immediately.
>> +	 */
>> +	if (qopt->hw && dev->netdev_ops->ndo_setup_tc) {
>> +		priv->hw_owned = 1;
>> +		if (dev->netdev_ops->ndo_setup_tc(dev, qopt->num_tc))
>> +			return -EINVAL;
>> +	} else if (!qopt->hw) {
>> +		if (mclass_parse_opt(dev, qopt))
>> +			return -EINVAL;
>> +
>> +		if (netdev_set_num_tc(dev, qopt->num_tc))
>> +			return -ENOMEM;
>> +
>> +		for (i = 0; i < qopt->num_tc; i++)
>> +			netdev_set_tc_queue(dev, i,
>> +					    qopt->count[i], qopt->offset[i]);
>> +	} else {
>> +		return -EINVAL;
>> +	}
>> +
>> +	/* Always use supplied priority mappings */
>> +	for (i = 0; i < 16; i++) {
> 
> i < qopt->num_tc ?

Nope, TC_BITMASK+1 here. If we only have 4 tcs for example we still need to map all 16 priority values to a tc.

> 
>> +		if (netdev_set_prio_tc_map(dev, i, qopt->prio_tc_map[i])) {
>> +			err = -EINVAL;
>> +			goto tc_err;
>> +		}
>> +	}
>> +
>> +	/* pre-allocate qdisc, attachment can't fail */
>> +	priv->qdiscs = kcalloc(qopt->num_tc,
>> +			       sizeof(priv->qdiscs[0]), GFP_KERNEL);
>> +	if (priv->qdiscs == NULL) {
>> +		err = -ENOMEM;
>> +		goto tc_err;
>> +	}
>> +
>> +	for (i = 0; i < dev->num_tc; i++) {
>> +		dev_queue = netdev_get_tx_queue(dev, dev->tc_to_txq[i].offset);
> 
> Are these offsets etc. validated?

Yes, as your next email noted.

Thanks,
John
