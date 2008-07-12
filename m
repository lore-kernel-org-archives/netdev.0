From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: bnx2_poll panicking kernel
Date: Sat, 12 Jul 2008 15:21:28 +0200
Message-ID: <4878AFD8.1000307@gmail.com>
References: <20080710223141.GA2519@orion.carnet.hr>	<20080710.162007.04790623.davem@davemloft.net>	<20080711092416.GA26515@orion.carnet.hr> <20080711.025656.261409874.davem@davemloft.net> <48787E1A.3030804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, joy@entuzijast.net,
	mchan@broadcom.com, billfink@mindspring.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	mirrors@debian.org, kaber@trash.net, devik@cdi.cz
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.187]:21784 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752573AbYGLNTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jul 2008 09:19:42 -0400
Received: by gv-out-0910.google.com with SMTP id e6so774336gvc.37
        for <netdev@vger.kernel.org>; Sat, 12 Jul 2008 06:19:40 -0700 (PDT)
In-Reply-To: <48787E1A.3030804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 07/12/2008 11:49 AM:

> David Miller wrote, On 07/11/2008 11:56 AM:
> ...
> 
>> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
>> index 3fb58f4..aa20b47 100644
>> --- a/net/sched/sch_htb.c
>> +++ b/net/sched/sch_htb.c
>> @@ -583,6 +583,7 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>>  		if (q->direct_queue.qlen < q->direct_qlen) {
>>  			__skb_queue_tail(&q->direct_queue, skb);
>>  			q->direct_pkts++;
>> +			ret = NET_XMIT_SUCCESS;
>>  		} else {
>>  			kfree_skb(skb);
>>  			sch->qstats.drops++;
>> @@ -595,22 +596,26 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>>  		kfree_skb(skb);
>>  		return ret;
>>  #endif
>> -	} else if (cl->un.leaf.q->enqueue(skb, cl->un.leaf.q) !=
>> -		   NET_XMIT_SUCCESS) {
>> -		sch->qstats.drops++;
>> -		cl->qstats.drops++;
>> -		return NET_XMIT_DROP;
>>  	} else {
>> -		cl->bstats.packets +=
>> -			skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
>> -		cl->bstats.bytes += skb->len;
>> -		htb_activate(q, cl);
>> +		ret = cl->un.leaf.q->enqueue(skb, cl->un.leaf.q);
>> +		if (ret == NET_XMIT_DROP) {
>> +			sch->qstats.drops++;
>> +			cl->qstats.drops++;
>> +		} else {
>> +			cl->bstats.packets +=
>> +				skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
>> +			cl->bstats.bytes += skb->len;
>> +			htb_activate(q, cl);
> 
> 
> This isn't correct: htb_activate() needs cl->un.leaf.q->q.qlen > 0, and
> only NET_XMIT_SUCCESS can guarantee this.


...Actually, it looks like even NET_XMIT_SUCCESS can't guarantee this
(when returned after TC_ACT_QUEUED or TC_ACT_STOLEN), so additional qlen
test is needed here.

Jarek P.
