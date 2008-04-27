From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][NET_SCHED] sch_sfq: fix queue limiting while enqueuing
Date: Sun, 27 Apr 2008 22:36:30 +0200
Message-ID: <20080427203630.GA9648@ami.dom.local>
References: <20080427142216.GB7480@ami.dom.local> <4814C618.3050506@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:10579 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023AbYD0Uim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 16:38:42 -0400
Received: by ug-out-1314.google.com with SMTP id z38so619889ugc.16
        for <netdev@vger.kernel.org>; Sun, 27 Apr 2008 13:38:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4814C618.3050506@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 27, 2008 at 08:29:44PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> [NET_SCHED] sch_sfq: fix queue limiting while enqueuing
>>
>> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
>> index a20e2ef..b4fd592 100644
>> --- a/net/sched/sch_sfq.c
>> +++ b/net/sched/sch_sfq.c
>> @@ -283,6 +283,9 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>>  	sfq_index x;
>>  	int ret;
>>  +	if (unlikely(sch->q.qlen >= max_t(__u32, sch->dev->tx_queue_len, 
>> 1)))
>> +		return qdisc_drop(skb, sch);
>> +
>>   
>
> I don't think we should do this. The tx_queue_len is only used for
> initialization in case no parameter is specified by other qdiscs.
>
> Besides this *will* break for example my configuration, I use SFQ
> as inner qdisc on virtual devices with either tx_queue_len == 0
> or 3 in case of ppp.

OK, you are right: it would break some scripts... But IMHO this way
of treating tx_queue_len isn't right: it can be changed after
initialization too, and looks like perfect way to control the queue
size globally. Anyway, current use of "limit" parameter in sfq warps
its idea. Another possibility would be like this:

sch->q.qlen >= max_t(__u32, sch->dev->tx_queue_len, q->limit)

or removing this global sch->q.qlen check at all. Or maybe we need to
add one more tc parameter for sfq?

Thanks,
Jarek P.
