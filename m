From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 07/13] net: sched: support qdisc_reset on NOLOCK qdisc
Date: Wed, 17 Aug 2016 15:59:32 -0700
Message-ID: <57B4EC54.4090500@gmail.com>
References: <20160817193120.27032.20918.stgit@john-Precision-Tower-5810>
 <20160817193622.27032.73296.stgit@john-Precision-Tower-5810>
 <1471474381.29842.51.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com,
	alexei.starovoitov@gmail.com, brouer@redhat.com,
	john.r.fastabend@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36476 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752435AbcHQW7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 18:59:49 -0400
Received: by mail-pf0-f194.google.com with SMTP id y134so209999pfg.3
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 15:59:48 -0700 (PDT)
In-Reply-To: <1471474381.29842.51.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-17 03:53 PM, Eric Dumazet wrote:
> On Wed, 2016-08-17 at 12:36 -0700, John Fastabend wrote:
>> The qdisc_reset operation depends on the qdisc lock at the moment
>> to halt any additions to gso_skb and statistics while the list is
>> free'd and the stats zeroed.
> 
> ...
> 
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>  net/sched/sch_generic.c |   45 +++++++++++++++++++++++++++++++++++----------
>>  1 file changed, 35 insertions(+), 10 deletions(-)
>>
>> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
>> index 3b9a21f..29238c4 100644
>> --- a/net/sched/sch_generic.c
>> +++ b/net/sched/sch_generic.c
>> @@ -737,6 +737,20 @@ void qdisc_reset(struct Qdisc *qdisc)
>>  	kfree_skb(qdisc->skb_bad_txq);
>>  	qdisc->skb_bad_txq = NULL;
>>  
>> +	if (qdisc->gso_cpu_skb) {
>> +		int i;
>> +
>> +		for_each_possible_cpu(i) {
>> +			struct gso_cell *cell;
>> +
>> +			cell = per_cpu_ptr(qdisc->gso_cpu_skb, i);
>> +			if (cell) {
>> +				kfree_skb_list(cell->skb);
>> +				cell = NULL;
> 
> 	You probably wanted :
> 			cell->skb = NULL;
> 

Yep thanks!

> 
>> +			}
>> +		}
>> +	}
>> +
>>  	if (qdisc->gso_skb) {
>>  		kfree_skb_list(qdisc->gso_skb);
>>  		qdisc->gso_skb = NULL;
>> @@ -812,10 +826,6 @@ struct Qdisc *dev_graft_qdisc(struct netdev_queue *dev_queue,
>>  	root_lock = qdisc_lock(oqdisc);
>>  	spin_lock_bh(root_lock);
>>  
>> -	/* Prune old scheduler */
>> -	if (oqdisc && atomic_read(&oqdisc->refcnt) <= 1)
>> -		qdisc_reset(oqdisc);
>> -
>>  
> 
> This probably belongs to a separate patch, before any per cpu / lockless
> qdisc changes ?
> 
> 
> 

Agreed will do for next rev thanks for reviewing.
