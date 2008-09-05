From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 21/25] netns ct: per-netns event cache
Date: Fri, 5 Sep 2008 07:44:15 +0400
Message-ID: <20080905034415.GB2789@x200.localdomain>
References: <20080821220445.GU31136@x200.localdomain> <48C013BE.3060800@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <48C013BE.3060800@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 04, 2008 at 06:58:38PM +0200, Patrick McHardy wrote:
> adobriyan@gmail.com wrote:
>>  static inline void
>> -nf_conntrack_event_cache(enum ip_conntrack_events event,
>> +nf_conntrack_event_cache(struct net *net, enum ip_conntrack_events event,
>>  			 const struct sk_buff *skb)
>>  {
>
> Passing the conntrack instead of the struct net and the skb
> would probably keep the callers cleaner.

Dunno, passing netns explicitly like saying conntrack event happened in
netns A, which is reasonable. OTOH, s/skb/ct/ is indeed nicer.

I'll change it as you suggest and see what happens.

BTW, I asked earlier if untracked conntracks are ever supposed to drop into
event cache. If they're, trimming nf_conntrack_untracked is out of question.

>>  	struct nf_conn *ct = (struct nf_conn *)skb->nfct;
>>  	struct nf_conntrack_ecache *ecache;
>>   	local_bh_disable();
>> -	ecache = &__get_cpu_var(nf_conntrack_ecache);
>> +	ecache = per_cpu_ptr(net->ct.ecache, raw_smp_processor_id());
>>  	if (ct != ecache->ct)
>>  		__nf_ct_event_cache_init(ct);
>>  	ecache->events |= event;
>> @@ -60,16 +58,29 @@ nf_ct_expect_event(enum ip_conntrack_expect_events event,
>>  	atomic_notifier_call_chain(&nf_ct_expect_chain, event, exp);
>>  }
>>  

