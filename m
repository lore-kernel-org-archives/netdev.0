From: "liujian (CE)" <liujian56@huawei.com>
Subject: RE: Question about ip_defrag
Date: Tue, 29 Aug 2017 07:40:43 +0000
Message-ID: <4F88C5DDA1E80143B232E89585ACE27D018F41D1@DGGEMA502-MBX.china.huawei.com>
References: <4F88C5DDA1E80143B232E89585ACE27D018F07E2@DGGEMA502-MBX.china.huawei.com>
 <20170824155300.1e577dae@redhat.com>
 <4F88C5DDA1E80143B232E89585ACE27D018F0AE1@DGGEMA502-MBX.china.huawei.com>
 <20170824205926.2c45e3a1@redhat.com>
 <4F88C5DDA1E80143B232E89585ACE27D018F3157@DGGEMA502-MBX.china.huawei.com>
 <20170828140032.GB12926@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
        "yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
        "elena.reshetova@intel.com" <elena.reshetova@intel.com>,
        "edumazet@google.com" <edumazet@google.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Wangkefeng (Kevin)" <wangkefeng.wang@huawei.com>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([45.249.212.187]:11755 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750909AbdH2HlT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 03:41:19 -0400
In-Reply-To: <20170828140032.GB12926@breakpoint.cc>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Florian Westphal
> Sent: Monday, August 28, 2017 10:01 PM
> To: liujian (CE)
> Cc: Jesper Dangaard Brouer; davem@davemloft.net; kuznet@ms2.inr.ac.ru;
> yoshfuji@linux-ipv6.org; elena.reshetova@intel.com; edumazet@google.com;
> netdev@vger.kernel.org; Wangkefeng (Kevin); weiyongjun (A)
> Subject: Re: Question about ip_defrag
> 
> liujian (CE) <liujian56@huawei.com> wrote:
> > Hi
> >
> > I checked our 3.10 kernel, we had backported all percpu_counter bug fix in
> lib/percpu_counter.c and include/linux/percpu_counter.h.
> > And I check 4.13-rc6, also has the issue if NIC's rx cpu num big enough.
> >
> > > > > > the issue:
> > > > > > Ip_defrag fail caused by frag_mem_limit reached
> 4M(frags.high_thresh).
> > > > > > At this moment,sum_frag_mem_limit is about 10K.
> >
> > So should we change ipfrag high/low thresh to a reasonable value ?
> > And if it is, is there a standard to change the value?
> 
> Each cpu can have frag_percpu_counter_batch bytes rest doesn't know about
> so with 64 cpus that is ~8 mbyte.
> 
> possible solutions:
> 1. reduce frag_percpu_counter_batch to 16k or so 2. make both low and high
> thresh depend on NR_CPUS
> 
Thank you for your reply.
 
> liujian, does this change help in any way?

I will have a try.

> diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
> --- a/net/ipv4/inet_fragment.c
> +++ b/net/ipv4/inet_fragment.c
> @@ -123,6 +123,17 @@ static bool inet_fragq_should_evict(const struct
> inet_frag_queue *q)
>  	       frag_mem_limit(q->net) >= q->net->low_thresh;  }
> 
> +/* ->mem batch size is huge, this can cause severe discrepancies
> + * between actual value (sum of pcpu values) and the global estimate.
> + *
> + * Use a smaller batch to give an opportunity for the global estimate
> + * to more accurately reflect current state.
> + */
> +static void update_frag_mem_limit(struct netns_frags *nf, unsigned int
> +batch) {
> +	 percpu_counter_add_batch(&nf->mem, 0, batch); }
> +
>  static unsigned int
>  inet_evict_bucket(struct inet_frags *f, struct inet_frag_bucket *hb)  { @@
> -146,8 +157,12 @@ inet_evict_bucket(struct inet_frags *f, struct
> inet_frag_bucket *hb)
> 
>  	spin_unlock(&hb->chain_lock);
> 
> -	hlist_for_each_entry_safe(fq, n, &expired, list_evictor)
> +	hlist_for_each_entry_safe(fq, n, &expired, list_evictor) {
> +		struct netns_frags *nf = fq->net;
> +
>  		f->frag_expire((unsigned long) fq);
> +		update_frag_mem_limit(nf, 1);

> +	}
> 
>  	return evicted;
>  }
> @@ -396,8 +411,10 @@ struct inet_frag_queue *inet_frag_find(struct
> netns_frags *nf,
>  	struct inet_frag_queue *q;
>  	int depth = 0;
> 
> -	if (frag_mem_limit(nf) > nf->low_thresh)
> +	if (frag_mem_limit(nf) > nf->low_thresh) {
>  		inet_frag_schedule_worker(f);
> +		update_frag_mem_limit(nf, SKB_TRUESIZE(1500) * 16); 
> +	}
> 
>  	hash &= (INETFRAGS_HASHSZ - 1);
>  	hb = &f->hash[hash];
> @@ -416,6 +433,8 @@ struct inet_frag_queue *inet_frag_find(struct
> netns_frags *nf,
>  	if (depth <= INETFRAGS_MAXDEPTH)
>  		return inet_frag_create(nf, f, key);
> 
> +	update_frag_mem_limit(nf, 1);
> +
>  	if (inet_frag_may_rebuild(f)) {
>  		if (!f->rebuild)
>  			f->rebuild = true;
