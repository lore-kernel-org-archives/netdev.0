From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: Re: [PATCH] net_sched/sfq: update hierarchical backlog when drop
 packet
Date: Tue, 15 Aug 2017 17:33:06 +0300
Message-ID: <9d01e66a-5855-ea9a-ff63-c029ceb46c98@yandex-team.ru>
References: <150280422406.717624.15125218636935056461.stgit@buzz>
 <1502806179.4936.76.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forwardcorp1o.cmail.yandex.net ([37.9.109.47]:53647 "EHLO
        forwardcorp1o.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751427AbdHOOdJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 10:33:09 -0400
In-Reply-To: <1502806179.4936.76.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: ru-RU
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.08.2017 17:09, Eric Dumazet wrote:
> On Tue, 2017-08-15 at 16:37 +0300, Konstantin Khlebnikov wrote:
>> When sfq_enqueue() drops head packet or packet from another queue it
>> have to update backlog at upper qdiscs too.
>>
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>> Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
>> ---
>>   net/sched/sch_sfq.c |    5 ++++-
>>   1 file changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
>> index f80ea2cc5f1f..82469ef9655e 100644
>> --- a/net/sched/sch_sfq.c
>> +++ b/net/sched/sch_sfq.c
>> @@ -437,6 +437,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch, struct sk_buff **to_free)
>>   		qdisc_drop(head, sch, to_free);
>>   
>>   		slot_queue_add(slot, skb);
>> +		qdisc_tree_reduce_backlog(sch, 0, delta);
>>   		return NET_XMIT_CN;
>>   	}
>>   
>> @@ -468,8 +469,10 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch, struct sk_buff **to_free)
>>   	/* Return Congestion Notification only if we dropped a packet
>>   	 * from this flow.
>>   	 */
>> -	if (qlen != slot->qlen)
>> +	if (qlen != slot->qlen) {
>> +		qdisc_tree_reduce_backlog(sch, 0, dropped - qdisc_pkt_len(skb));
>>   		return NET_XMIT_CN;
>> +	}
>>   
>>   	/* As we dropped a packet, better let upper stack know this */
>>   	qdisc_tree_reduce_backlog(sch, 1, dropped);
>>
> 
> Are you sure you have tested this patch ?
> 

Nope. I'm not sure. But we have something similar in our 4.4 kernel for a while.

Also fq_codel and pfifo_head_drop do something similar tho this.

Probably this might crash without "[PATCH 1/2] net_sched: call qlen_notify only if child qdisc is empty".
I hadn't tested them separately.
