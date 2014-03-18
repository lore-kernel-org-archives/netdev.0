From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 6/6] net: Free skbs from irqs when possible.
Date: Tue, 18 Mar 2014 10:51:46 -0700
Message-ID: <87pplj75u5.fsf@xmission.com>
References: <20140314.225923.61318448733570839.davem@davemloft.net>
	<87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com>
	<20140317.154916.2276987764507311378.davem@davemloft.net>
	<87iorcgh5d.fsf_-_@xmission.com> <87fvmgf2c7.fsf_-_@xmission.com>
	<1395148956.9114.31.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:60881 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756707AbaCRRvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 13:51:53 -0400
In-Reply-To: <1395148956.9114.31.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Tue, 18 Mar 2014 06:22:36 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Mon, 2014-03-17 at 23:27 -0700, Eric W. Biederman wrote:
>> Add a test skb_irq_freeable to report when it is safe to free a skb
>> from irq context.
>> 
>> It is not safe to free an skb from irq context when:
>> - The skb has a destructor as some skb destructors call local_bh_disable
>>   or spin_lock_bh.
>> - There is xfrm state as __xfrm_state_destroy calls spin_lock_bh.
>> - There is netfilter conntrack state as destroy_conntrack calls
>>   spin_lock_bh.
>> - If there is a refcounted dst entry on the skb, as __dst_free
>>   calls spin_lock_bh.
>> - If there is a frag_list, which could be a list of any skbs.
>> Otherwise it appears safe to free a skb from interrupt context.
>> 
>> - Update the warning in skb_releae_head_state to warn about freeing
>>   skb's in the wrong context.
>> 
>> - Update __dev_kfree_skb_irq to free all skbs that it can immediately
>> 
>> - Kill zap_completion_queue because there is no point going through
>>   a queue of packets that are not safe to free and looking for packets
>>   that are safe to free.
>> 
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> ---
>>  include/linux/skbuff.h |   13 +++++++++++++
>>  net/core/dev.c         |   14 +++++++++-----
>>  net/core/netpoll.c     |   32 --------------------------------
>>  net/core/skbuff.c      |   13 ++++++++++---
>>  4 files changed, 32 insertions(+), 40 deletions(-)
>> 
>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> index 03db95ab8a8c..53f72b53fd47 100644
>> --- a/include/linux/skbuff.h
>> +++ b/include/linux/skbuff.h
>> @@ -2833,6 +2833,19 @@ static inline void skb_init_secmark(struct sk_buff *skb)
>>  { }
>>  #endif
>>  
>> +static inline bool skb_irq_freeable(struct sk_buff *skb)
>> +{
>> +	return !skb->destructor &&
>> +#if IS_ENABLED(CONFIG_XFRM)
>> +		!skb->sp &&
>> +#endif
>> +#if IS_ENABLED(CONFIG_NF_CONNTRACK)
>> +		!skb->nfct &&
>> +#endif
>> +		(!skb->_skb_refdst || (skb->_skb_refdst & SKB_DST_NOREF)) &&
>> +		!skb_has_frag_list(skb);
>> +}
>> +
>
> It would be a serious bug having (skb->_skb_refdst & SKB_DST_NOREF) at
> this point. dst would be RCU protected, but this can not be true as the
> packet was queued in TX ring buffer for a possibly long period. And even
> before reaching the driver, skb might have been queued in qdisc layer
> and escape rcu protection section anyway.
>
> Thats why we use skb_dst_force() from __dev_xmit_skb()

Interesting point.  I hadn't dug far enough to see that.  I have no
problems simplifying this check.

Eric
