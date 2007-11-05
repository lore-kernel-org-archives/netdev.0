From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Mon, 5 Nov 2007 10:12:31 +0100
Message-ID: <20071105091231.GA1933@ff.dom.local>
References: <1193939701.2987.82.camel@localhost.localdomain> <472B5EF1.4020206@o2.pl> <1194045830.4438.21.camel@localhost> <472D06B2.9040402@o2.pl> <472D0B1C.7000209@o2.pl> <472D128B.8030704@o2.pl> <472D1DC2.9000106@o2.pl> <1194220693.4438.75.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Radu Rendec <radu.rendec@ines.ro>, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:52792 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752892AbXKEJIq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2007 04:08:46 -0500
Content-Disposition: inline
In-Reply-To: <1194220693.4438.75.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 04, 2007 at 06:58:13PM -0500, jamal wrote:
> On Sun, 2007-04-11 at 02:17 +0100, Jarek Poplawski wrote:
> 
> > So, even if not full ntohl(), some byte moving seems to be
> > necessary here.
> 
> I thinking you were close. I am afraid my brain is congested, even the
> esspresso didnt help my thinking. 
> It could be done with just fshift on the slow path (config time) of one
> was to think hard;-> I am not too happy with the extra conversion on the
> fast path, but how about the untested attached patch?
> 
> cheers,
> jamal
>  
> diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
> index 9e98c6e..6dd569b 100644
> --- a/net/sched/cls_u32.c
> +++ b/net/sched/cls_u32.c
> @@ -93,7 +93,7 @@ static __inline__ unsigned u32_hash_fold(u32 key, struct tc_u32_sel *sel, u8 fsh
>  {
>  	unsigned h = (key & sel->hmask)>>fshift;
>  
> -	return h;
> +	return ntohl(h);
>  }

Seems not good or I miss something:

host order:
address: xx.xx.xf.fx
hmask  : 00.00.0f.f0

net order:
address: fx.xf.xx.xx
hmask  : f0.0f.00.00

fshift after ntohl(s->hmask): 4
so, above:
h = (fx.xf.xx.xx & f0.0f.00.00) >> 4;
h == 0f.00.f0.00
return 00.f0.00.0f (?)

But, I hope, maybe Radu could check this better - after his analyze
it looks like his coffee is the best!

Currently I think this should be possible to get this one important
byte with 2 shifts, but it needs much more coffee on my slow path...
But, this wouldn't be very readable and I'm not sure the gain would
be really visible with current cpus, so maybe this first proposal is
quite reasonable. Then, I'd only suggest to Radu to change the '*'
style a bit in the comment and to sign this off, if you agree?

Cheers,
Jarek P.

BTW: when looking around this I think, maybe, in u32_change():

1) if (--divisor > 0x100) should be probably ">=", but is it really
needed to check this 2 times (including tc)?
2) this while() loop for n->fshift could be replaced with ffs()?

>  
>  static int u32_classify(struct sk_buff *skb, struct tcf_proto *tp, struct tcf_result *res)
> @@ -615,7 +615,7 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
>  	n->handle = handle;
>  {
>  	u8 i = 0;
> -	u32 mask = s->hmask;
> +	u32 mask = ntohl(s->hmask);
>  	if (mask) {
>  		while (!(mask & 1)) {
>  			i++;
