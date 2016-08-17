From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 01/13] net: sched: allow qdiscs to handle locking
Date: Wed, 17 Aug 2016 15:48:50 -0700
Message-ID: <57B4E9D2.1090302@gmail.com>
References: <20160817193120.27032.20918.stgit@john-Precision-Tower-5810>
 <20160817193338.27032.71493.stgit@john-Precision-Tower-5810>
 <1471473242.29842.45.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com,
	alexei.starovoitov@gmail.com, brouer@redhat.com,
	john.r.fastabend@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36432 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752837AbcHQWtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 18:49:06 -0400
Received: by mail-pf0-f195.google.com with SMTP id y134so189126pfg.3
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 15:49:05 -0700 (PDT)
In-Reply-To: <1471473242.29842.45.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-17 03:34 PM, Eric Dumazet wrote:
> On Wed, 2016-08-17 at 12:33 -0700, John Fastabend wrote:
> 
> 
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 4ce07dc..5db395d 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -3076,6 +3076,26 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
>>  	int rc;
>>  
>>  	qdisc_calculate_pkt_len(skb, q);
>> +
>> +	if (q->flags & TCQ_F_NOLOCK) {
>> +		if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
>> +			__qdisc_drop(skb, &to_free);
>> +			rc = NET_XMIT_DROP;
>> +		} else if ((q->flags & TCQ_F_CAN_BYPASS) && !qdisc_qlen(q)) {
> 
> For a lockless qdisc, do you believe TCQ_F_CAN_BYPASS is still a gain ?
> 

For the benchmarks from pktgen it appears to be a win or mute to just
drop the TCQ_F_CAN_BYPASS (just taking a look at one sample below)

    nolock & nobypass   locked (current master)
----------------------------------------------
1:  1435796 		1471479
2:  1880642		1746231
4:  1922935		1119626
8:  1585055		1001471
12: 1479273		989269

The only thing would be to test a bunch of netperf RR sessions to be
sure.

> Also !qdisc_qlen(q) looks racy anyway ?

Yep its racy unless you make it an atomic but this hurts performance
metrics. There is a patch further in the stack here that adds the
atomic variants but I tend to think we can just drop the bypass logic
in the lockless case assuming the netperf tests look good.

> 
>> +			qdisc_bstats_cpu_update(q, skb);
>> +			if (sch_direct_xmit(skb, q, dev, txq, root_lock, true))
>> +				__qdisc_run(q);
>> +			rc = NET_XMIT_SUCCESS;
>> +		} else {
>> +			rc = q->enqueue(skb, q, &to_free) & NET_XMIT_MASK;
>> +			__qdisc_run(q);
>> +		}
>> +
>> +		if (unlikely(to_free))
>> +			kfree_skb_list(to_free);
>> +		return rc;
>> +	}
>> +
> 
> 
