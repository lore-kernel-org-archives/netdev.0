From: Radu Rendec <radu.rendec@ines.ro>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Mon, 05 Nov 2007 14:59:21 +0200
Message-ID: <1194267561.2987.141.camel@localhost.localdomain>
References: <1193939701.2987.82.camel@localhost.localdomain>
	 <472B5EF1.4020206@o2.pl> <1194045830.4438.21.camel@localhost>
	 <472D06B2.9040402@o2.pl> <472D0B1C.7000209@o2.pl> <472D128B.8030704@o2.pl>
	 <472D1DC2.9000106@o2.pl> <1194220693.4438.75.camel@localhost>
	 <20071105091231.GA1933@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from NAT-173-Unkn.Local.iNES.RO ([80.86.100.173]:44758 "EHLO
	blade.ines.ro" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750887AbXKENC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 08:02:58 -0500
In-Reply-To: <20071105091231.GA1933@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek, thanks for replying my message on the list and pointing it to the
right direction.

Your example with "1" bits laying on exact nibble boundary is much
easier to analyze than my original example. And your computation seems
to be right: u32_hash_fold() would return 00.f0.00.0f (and would be cut
off to 0f after applying the divisor mask).

When I ran into this issue and figured out what was happening in
u32_classify(), at first I thought it could be fixed without any change
at all (in either kernel or tc). For a moment, computing the mask and
resulting bucket by taking into account the host<->net conversions and
supplying them "correctly" to tc seemed to be the best/easiest approach.

Then I figured out what the real problem is: if you look at network
ordered bytes and treat them as a host ordered u32, logically adjacent
bits from different bytes (in network order) will no longer be adjacent
in the host ordered u32. And this has nothing to with bitwise anding
(masking) or shifting. In other words, whatever mask or fshift values
you choose, those bits will still not be adjacent.

Jamal, I am aware that any computation on the fast path involves some
performance loss. However, I don't see any speed gain with your patch,
because you just moved the ntohl() call inside u32_hash_fold(). Since
u32_hash_fold() is called unconditionally and the only call is that one
in u32_classify(), htohl() will be called exactly the same number of
times.

After almost a week of dealing with this, I still don't think it can be
solved without byte re-ordering. If you guys think my patch is good, I
would be more than glad to send it properly (change the comments as
Jarek suggested and use git). Since I'm quite a newbie with git and
haven't worked with kernel maintainers before, please be patient if it's
not perfect at the first attempt :) What tree/branch should I make the
patch against?

Thanks,

Radu Rendec

On Mon, 2007-11-05 at 10:12 +0100, Jarek Poplawski wrote:
> On Sun, Nov 04, 2007 at 06:58:13PM -0500, jamal wrote:
> > On Sun, 2007-04-11 at 02:17 +0100, Jarek Poplawski wrote:
...
> > diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
> > index 9e98c6e..6dd569b 100644
> > --- a/net/sched/cls_u32.c
> > +++ b/net/sched/cls_u32.c
> > @@ -93,7 +93,7 @@ static __inline__ unsigned u32_hash_fold(u32 key, struct tc_u32_sel *sel, u8 fsh
> >  {
> >  	unsigned h = (key & sel->hmask)>>fshift;
> >  
> > -	return h;
> > +	return ntohl(h);
> >  }
> 
> Seems not good or I miss something:
> 
> host order:
> address: xx.xx.xf.fx
> hmask  : 00.00.0f.f0
> 
> net order:
> address: fx.xf.xx.xx
> hmask  : f0.0f.00.00
> 
> fshift after ntohl(s->hmask): 4
> so, above:
> h = (fx.xf.xx.xx & f0.0f.00.00) >> 4;
> h == 0f.00.f0.00
> return 00.f0.00.0f (?)
> 
> But, I hope, maybe Radu could check this better - after his analyze
> it looks like his coffee is the best!
> 
> Currently I think this should be possible to get this one important
> byte with 2 shifts, but it needs much more coffee on my slow path...
> But, this wouldn't be very readable and I'm not sure the gain would
> be really visible with current cpus, so maybe this first proposal is
> quite reasonable. Then, I'd only suggest to Radu to change the '*'
> style a bit in the comment and to sign this off, if you agree?
> 
> Cheers,
> Jarek P.
> 
> BTW: when looking around this I think, maybe, in u32_change():
> 
> 1) if (--divisor > 0x100) should be probably ">=", but is it really
> needed to check this 2 times (including tc)?
> 2) this while() loop for n->fshift could be replaced with ffs()?


