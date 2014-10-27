From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: Fw: [Bug 86851] New: Reproducible panic on heavy UDP traffic
Date: Mon, 27 Oct 2014 10:12:57 +0100
Message-ID: <544E0C99.6070100@redhat.com>
References: <20141025141038.26fa5ac2@uryu.home.lan>	 <20141025214448.GB28407@breakpoint.cc> <544D8386.9030609@redhat.com> <1414370826.16231.1.camel@edumazet-glaptop2.roam.corp.google.com> <544E06CF.30709@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, chutzpah@gentoo.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46537 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751954AbaJ0JNJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2014 05:13:09 -0400
In-Reply-To: <544E06CF.30709@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/2014 09:48 AM, Nikolay Aleksandrov wrote:
> On 10/27/2014 01:47 AM, Eric Dumazet wrote:
>> On Mon, 2014-10-27 at 00:28 +0100, Nikolay Aleksandrov wrote:
>>
>>>
>>> Thanks for CCing me.
>>> I'll dig in the code tomorrow but my first thought when I saw this was
>>> could it be possible that we have a race condition between
>>> ip_frag_queue() and inet_frag_evict(), more precisely between the
>>> ipq_kill() calls from ip_frag_queue and inet_frag_evict since the frag
>>> could be found before we have entered the evictor which then can add it to
>>> its expire list but the ipq_kill() from ip_frag_queue() can do a list_del
>>> after we release the chain lock in the evictor so we may end up like this ?
>>
>> Yes, either we use hlist_del_init() but loose poison aid, or test if
>> frag was evicted :
>>
>> Not sure about refcount.
>>
>> diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
>> index 9eb89f3f0ee4..894ec30c5896 100644
>> --- a/net/ipv4/inet_fragment.c
>> +++ b/net/ipv4/inet_fragment.c
>> @@ -285,7 +285,8 @@ static inline void fq_unlink(struct inet_frag_queue *fq, struct inet_frags *f)
>>  	struct inet_frag_bucket *hb;
>>  
>>  	hb = get_frag_bucket_locked(fq, f);
>> -	hlist_del(&fq->list);
>> +	if (!(fq->flags & INET_FRAG_EVICTED))
>> +		hlist_del(&fq->list);
>>  	spin_unlock(&hb->chain_lock);
>>  }
>>  
>>
>>
> 
> Exactly, I was thinking about a similar fix since the evict flag is only
> set with the chain lock. IMO the refcount should be fine.
> CCing the reporter.
> Patrick could you please try Eric's patch ?

Actually there might be a refcnt problem. What if the following happens:
refcnt = 2 (1 for timer, 1 init)
	A			B
inet_frag_find() +1 (3)
ipq_kill() -2 (1)          inet_frag_evict() (sees it before fq_unlink)
spin_unlock(q.lock)
			   ->frag_expire() -1 (0 -> frag_destroy())
*ipq_put(freed frag)*

Or the other way around, last ipq_put() is executed before frag_expire
so we have a freed frag on the expire list.
