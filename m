From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] net: Validate frames going through the direct_xmit path
Date: Tue, 02 Sep 2014 19:46:34 -0700
Message-ID: <5406810A.9070900@gmail.com>
References: <20140902225548.885.79277.stgit@ahduyck-bv4.jf.intel.com> <1409700648.26422.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:47738 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871AbaICCqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 22:46:34 -0400
Received: by mail-pd0-f172.google.com with SMTP id z10so10110880pdj.3
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 19:46:34 -0700 (PDT)
In-Reply-To: <1409700648.26422.21.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/2014 04:30 PM, Eric Dumazet wrote:
> On Tue, 2014-09-02 at 18:55 -0400, Alexander Duyck wrote:
>> In commit 50cbe9ab5f8d92d2d4a327b56e96559d8f63a1fa "net: Validate xmit SKBs
>> right when we pull them out of the qdisc" the validation code was moved out
>> of dev_hard_start_xmit and into dequeue_skb.  However this overlooked the
>> fact that we do not always enqueue the skb onto a qdisc.
>>
>> As a result I was seeing issues trying to connect to a vhost_net interface
>> after this patch was applied.  To resolve the issue I have added a call to
>> validate_xmit_skb in sched_direct_xmit and this seems to have resolved the
>> issue by restoring the validation to this xmit path.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> ---
>>  net/sched/sch_generic.c |    9 +++++++--
>>  1 file changed, 7 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
>> index a8bf9f9..203ee65 100644
>> --- a/net/sched/sch_generic.c
>> +++ b/net/sched/sch_generic.c
>> @@ -128,8 +128,13 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
>>  	spin_unlock(root_lock);
>>  
>>  	HARD_TX_LOCK(dev, txq, smp_processor_id());
>> -	if (!netif_xmit_frozen_or_stopped(txq))
>> -		skb = dev_hard_start_xmit(skb, dev, txq, &ret);
>> +	if (!netif_xmit_frozen_or_stopped(txq)) {
>> +		skb = validate_xmit_skb(skb, dev);
>> +		if (!skb)
>> +			ret = NETDEV_TX_OK;
>> +		else
>> +			skb = dev_hard_start_xmit(skb, dev, txq, &ret);
>> +	}
>>  
>>  	HARD_TX_UNLOCK(dev, txq);
>>  
> 
> This looks very weird.

It's ugly, I will admit it.  It was a quick hack to fix the issue I had
been seeing as it was in my way.

> Calling validate_xmit_skb() twice per packet is not needed in the case
> sch_direct_xmit() is called from qdisc_restart()

My bad, I overlooked that sch_direct_xmit is called by qdisc_restart.

> This will add bad branch prediction at very minimum.
> 
> This is a TCQ_F_CAN_BYPASS issue that should be fixed there.

Actually it looks like there are several issues.  One is the bypass
problem which is the major issue. Another side effect of the original
patch is that a bad frame will cause us to exit __qdisc_run prematurely
even if other frames are still in the qdisc.

Alternative patches always welcome. :-)  My goal at this point is to
just have my vhost_net interface work so I can get back to my other
development work.  I will submit a v2 in the morning if I don't see
anything.

Alex
