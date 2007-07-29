From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 4/7] Add "depth".
Date: Sun, 29 Jul 2007 22:54:15 +0200
Message-ID: <200707292254.15514.mb@bu3sch.de>
References: <11856929352537-git-send-email-bugfood-ml@fatooh.org> <200707292041.45495.mb@bu3sch.de> <46ACF6BB.7010703@fatooh.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Corey Hickey <bugfood-ml@fatooh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:49885
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765395AbXG2Uy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2007 16:54:26 -0400
In-Reply-To: <46ACF6BB.7010703@fatooh.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 29 July 2007 22:21, Corey Hickey wrote:
> > Compare depth against (~0U/2)-1? What's that doing? Should probably add a comment.
> 
> ~0U/2 - 1 is the maximum value depth can be, based on how it is used in 
> indexing q->dep. I agree, though, that deserves a comment. Actually, 
> I'll also change it to '#define SFQ_DEPTH_MAX (~0U/2 - 1)' and put it 
> near the top of the file next to the 'typedef unsigned int sfq_index;'.
> 
> I could also include limits.h and use UINT_MAX instead of ~0U; would 
> that be preferable?

Seems like a good idea.

> >>  
> >>  		if (ctl->limit)
> >> -			q->limit = min_t(u32, ctl->limit, SFQ_DEPTH);
> >> +			q->limit = min_t(u32, ctl->limit, q->depth);
> >>  	}
> >>  
> >> +	q->dep = kmalloc((1+q->depth*2)*sizeof(struct sfq_head), GFP_KERNEL);
> >> +	if (!q->dep)
> >> +		goto err_case;
> >> +	q->next = kmalloc(q->depth*sizeof(sfq_index), GFP_KERNEL);
> >> +	if (!q->next)
> >> +		goto err_case;
> >> +	q->allot = kmalloc(q->depth*sizeof(short), GFP_KERNEL);
> >> +	if (!q->allot)
> >> +		goto err_case;
> >> +	q->hash = kmalloc(q->depth*sizeof(unsigned short), GFP_KERNEL);
> >> +	if (!q->hash)
> >> +		goto err_case;
> >> +	q->qs = kmalloc(q->depth*sizeof(struct sk_buff_head), GFP_KERNEL);
> >> +	if (!q->qs)
> >> +		goto err_case;
> > 
> > You may chose to use kcalloc for array allocations.
> 
> The arrays in the original code don't get zeroed either, so that 
> shouldn't be necessary (and I haven't heard of any problems so far). Do 
> you suggest I use kcalloc() anyway, just as a good practice?

Well, I think we don't have strict rules on that, so it depends
on the developer's taste. The advantage of kcalloc is, that it might
catch errors in the args better than this opencoded multiplication.
(There's some BUG_ON logic in kcalloc)

> >>  	for (i=0; i<SFQ_HASH_DIVISOR; i++)
> >> -		q->ht[i] = SFQ_DEPTH;
> >> -	for (i=0; i<SFQ_DEPTH; i++) {
> >> +		q->ht[i] = q->depth;
> >> +	for (i=0; i<q->depth; i++) {
> >>  		skb_queue_head_init(&q->qs[i]);
> >> -		q->dep[i+SFQ_DEPTH].next = i+SFQ_DEPTH;
> >> -		q->dep[i+SFQ_DEPTH].prev = i+SFQ_DEPTH;
> >> +		q->dep[i+q->depth].next = i+q->depth;
> >> +		q->dep[i+q->depth].prev = i+q->depth;
> >>  	}
> >>  
> >> -	for (i=0; i<SFQ_DEPTH; i++)
> >> +	for (i=0; i<q->depth; i++)
> >>  		sfq_link(q, i);
> >>  	return 0;
> >> +err_case:
> > 
> > This leaks a few kmallocs.
> 
> Are you saying that the 'err_case:' leaks kmallocs? It calls 
> sfq_q_destroy(q), which kfrees each of the arrays: dep, next, allot, 
> hash, and qs. Is that sufficient, or am I missing something or 
> misunderstanding you?

Ok, I didn't see that. So this should be ok.

> >> +	sfq_q_destroy(q);
> >> +	return -ENOBUFS;
> >>  }
