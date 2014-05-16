From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH net-next] net_sched: increase drop count when packets
 are dropped
Date: Fri, 16 May 2014 17:07:24 +0800
Message-ID: <5375D54C.4040108@huawei.com>
References: <1399974163-8788-1-git-send-email-yangyingliang@huawei.com> <1399988959.7973.46.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <vtlam@google.com>,
	<nanditad@google.com>, <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [119.145.14.66] ([119.145.14.66]:29762 "EHLO
	szxga03-in.huawei.com" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1754258AbaEPJIN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 05:08:13 -0400
In-Reply-To: <1399988959.7973.46.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/5/13 21:49, Eric Dumazet wrote:
> On Tue, 2014-05-13 at 17:42 +0800, Yang Yingliang wrote:
>> When packets are dropped because of overlimit, the drop count
>> should be increased. Replace kfree_skb() with qdisc_drop() for
>> increasing drop count.
>>
>> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
>> ---
>>  net/sched/sch_fq.c       | 2 +-
>>  net/sched/sch_fq_codel.c | 3 ++-
>>  net/sched/sch_hhf.c      | 3 ++-
>>  3 files changed, 5 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
>> index 23c682b42f99..958ef7d4b825 100644
>> --- a/net/sched/sch_fq.c
>> +++ b/net/sched/sch_fq.c
>> @@ -714,7 +714,7 @@ static int fq_change(struct Qdisc *sch, struct nlattr *opt)
>>  
>>  		if (!skb)
>>  			break;
>> -		kfree_skb(skb);
>> +		qdisc_drop(skb, sch);
>>  		drop_count++;
>>  	}
>>  	qdisc_tree_decrease_qlen(sch, drop_count);
>> diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
>> index 0bf432c782c1..bcfe4594470f 100644
>> --- a/net/sched/sch_fq_codel.c
>> +++ b/net/sched/sch_fq_codel.c
>> @@ -344,7 +344,8 @@ static int fq_codel_change(struct Qdisc *sch, struct nlattr *opt)
>>  	while (sch->q.qlen > sch->limit) {
>>  		struct sk_buff *skb = fq_codel_dequeue(sch);
>>  
>> -		kfree_skb(skb);
>> +		qdisc_drop(skb, sch);
>> +		q->drop_overlimit++;
>>  		q->cstats.drop_count++;
>>  	}
> 
> Could you please refrain from adding random stuff in packet schedulers ?
OK :)

> 
> overlimit has a special meaning for HTB like qdisc, having a shapers.
I don't really catch up with you here. What's special meaning ?

> 
> fq_codel or hhf do not shape, there is no reason to increment
> 'overlimit' when they _drop_ a packet.

Do you mean 'drop_overlimit' or 'overlimit' ?

fq_codel has both 'overlimits' and 'drop_overlimit' :

qdisc fq_codel 1: dev eth4 root refcnt 2 limit 10240p flows 1024 quantum 1514 target 5.0ms interval 100.0ms ecn 
 Sent 834 bytes 5 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  maxpacket 256 drop_overlimit 0 new_flow_count 0 ecn_mark 0
  new_flows_len 0 old_flows_len 0

Could you please explain more explicitly ?

Thanks very much!
