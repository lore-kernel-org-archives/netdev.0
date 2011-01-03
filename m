From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH v2 3/3] net_sched: implement a root	container
 qdisc sch_mclass
Date: Sun, 02 Jan 2011 21:46:16 -0800
Message-ID: <4D2162A8.60305@intel.com>
References: <20101231092543.GA7809@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
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
Received: from mga01.intel.com ([192.55.52.88]:33861 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751119Ab1ACFqR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jan 2011 00:46:17 -0500
In-Reply-To: <20101231092543.GA7809@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/31/2010 1:25 AM, Jarek Poplawski wrote:
> On 2010-12-21 20:29, John Fastabend wrote:
>> This implements a mclass 'multi-class' queueing discipline that by
>> default creates multiple mq qdisc's one for each traffic class. Each
>> mq qdisc then owns a range of queues per the netdev_tc_txq mappings.
> 
> Btw, you could also consider better name (mqprio?) because there're
> many 'multi-class' queueing disciplines around.
> 

OK.

>> +static int mclass_parse_opt(struct net_device *dev, struct tc_mclass_qopt *qopt)
>> +{
>> +	int i, j;
>> +
>> +	/* Verify TC offset and count are sane */
> 
> if (qopt->num_tc > TC_MAX_QUEUE) ?
> 	return -EINVAL;

This would be caught later when netdev_set_num_tc() fails although probably best to catch all failures in this function as early as possible.

> 
>> +	for (i = 0; i < qopt->num_tc; i++) {
>> +		int last = qopt->offset[i] + qopt->count[i];
>> +		if (last > dev->num_tx_queues)
> 
> if (last >= dev->num_tx_queues) ?
> 
>> +			return -EINVAL;
>> +		for (j = i + 1; j < qopt->num_tc; j++) {
>> +			if (last > qopt->offset[j])
> 
> if (last >= qopt->offset[j]) ?
	
I believe the below works as expected. The offset needs to be verified (this I missed) but offset+count can be equal to num_tx_queue indicating the last queue is in use. With 8 tx queues and num_tc=2 a valid configuration is, tc1 offset of 0 and a count of 7 with tc2 offset of 7 and count of 1.


        /* Verify num_tc is in max range */
        if (qopt->num_tc > TC_MAX_QUEUE)
                return -EINVAL;

        for (i = 0; i < qopt->num_tc; i++) {
                /* Verify the queue offset is in the num tx range */
                if (qopt->offset[i] >= dev->num_tx_queues)
                        return -EINVAL;
                /* Verify the queue count is in tx range being equal to the
                 * num_tx_queues indicates the last queue is in use.
                 */
                else if (qopt->offset[i] + qopt->count[i] > dev->num_tx_queues)
                        return -EINVAL;

                /* Verify that the offset and counts do not overlap */
                for (j = i + 1; j < qopt->num_tc; j++) {
                        if (last > qopt->offset[j])
                                return -EINVAL;
                }
        }


Thanks for the review!

John.

> 
> Jarek P.

