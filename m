From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Sun, 04 Nov 2007 00:39:30 +0100
Message-ID: <472D06B2.9040402@o2.pl>
References: <1193939701.2987.82.camel@localhost.localdomain>	 <472B5EF1.4020206@o2.pl> <1194045830.4438.21.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Radu Rendec <radu.rendec@ines.ro>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:44276 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756676AbXKCXfF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Nov 2007 19:35:05 -0400
In-Reply-To: <1194045830.4438.21.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote, On 11/03/2007 12:23 AM:

> On Fri, 2007-02-11 at 18:31 +0100, Jarek Poplawski wrote:
>> Radu Rendec wrote:
>>
>>> Hi,
>>>
>>> While trying to implement u32 hashes in my shaping machine I ran into a
>>> possible bug in the u32 hash/bucket computing algorithm
>>> (net/sched/cls_u32.c).
>>>
>>> The problem occurs only with hash masks that extend over the octet
>>> boundary, on little endian machines (where htonl() actually does
>>> something).
>>>
>>> I'm not 100% sure this is a problem with u32 itself, but at least I'm
>>> sure u32 with the same configuration would behave differently on little
>>> endian and big endian machines. Detailed description of the problem and
>>> proposed patch follow.
>>
>> I think you are right about this different behavior, so it looks like a bug.
>> And since little endian way is uncontrollable in such a case, your proposal
>> should be right.
>>
>> But, since there is a maintainer for this, let's check what is he not payed
>> for?! (Cc: Jamal Hadi Salim)
>>
> 
> Thanks for the CC Jarek - and i promise to share the loot with you when
> i lay my hands on it;->
> 
> I see that given the mask described (the 0 bits bounding the two
> nibbles), the same packet in that network will hit two different buckets
> depending on endianness. In other words there is lack of consistency. So
> good catch.
> The patch would certainly resolve it.
> The only thing that bothers me with the patch approach is the extra
> conversion in the fast path. Radu, since this is not a show stopper -
> can you give me a short time to sip on it? I am thinking it is probably
> resolvable by using the right tuning at config time - one knob that
> looks usable is fshift and that all this can be done at config time; but
> i may need more than one coffee to get it right, but if you see it just
> send a patch. I will try to use the data you used to see if i am making
> any sense.
> 
> cheers,
> jamal
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


static __inline__ unsigned u32_hash_fold(u32 key, struct tc_u32_sel *sel, u8 fshift)
{
#ifdef __LITTLE_ENDIAN
	/*
	 * It's a hack/optimization to avoid ntohl(). Since
	 * it's only used in u32_classify(), and masked with
	 * divisor (1 byte), one, least signinificant byte
	 * of selection is enough.
	 */
	fshift = 32 - 8 - fshift;
#endif
	unsigned h = (key & sel->hmask) >> fshift;

	return h;
}




> --- linux-2.6.22.9/net/sched/cls_u32.c.orig	2007-10-30 17:08:03.000000000 +0200
> +++ linux-2.6.22.9/net/sched/cls_u32.c	2007-10-30 17:04:49.000000000 +0200
> @@ -198,7 +198,7 @@
>  		ht = n->ht_down;
>  		sel = 0;
>  		if (ht->divisor)
> -			sel = ht->divisor&u32_hash_fold(*(u32*)(ptr+n->sel.hoff), &n->sel,n->fshift);
> +			sel = ht->divisor&u32_hash_fold(ntohl(*(u32*)(ptr+n->sel.hoff)), &n->sel,n->fshift);
>  
>  		if (!(n->sel.flags&(TC_U32_VAROFFSET|TC_U32_OFFSET|TC_U32_EAT)))
>  			goto next_ht;
> @@ -626,6 +626,10 @@
>  	}
>  #endif
>  
> +	/* userspace tc tool sends us the hmask in network order, but we
> +	 * need host order, so change it here */
> +	s->hmask = ntohl(s->hmask);
> +
>  	memcpy(&n->sel, s, sizeof(*s) + s->nkeys*sizeof(struct tc_u32_key));
>  	n->ht_up = ht;
>  	n->handle = handle;
> @@ -735,9 +739,14 @@
>  		u32 divisor = ht->divisor+1;
>  		RTA_PUT(skb, TCA_U32_DIVISOR, 4, &divisor);
>  	} else {
> +		/* get the address where the selector will be put, then
> +		 * change the hmask after it is put there */
> +		struct tc_u32_sel *s =
> +			(struct tc_u32_sel *)RTA_DATA(skb_tail_pointer(skb));
>  		RTA_PUT(skb, TCA_U32_SEL,
>  			sizeof(n->sel) + n->sel.nkeys*sizeof(struct tc_u32_key),
>  			&n->sel);
> +		s->hmask = htonl(s->hmask);
>  		if (n->ht_up) {
>  			u32 htid = n->handle & 0xFFFFF000;
>  			RTA_PUT(skb, TCA_U32_HASH, 4, &htid);
> 
> 
> -
