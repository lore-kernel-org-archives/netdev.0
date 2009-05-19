From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Fw: [Bug 13339] New: rtable leak in ipv4/route.c
Date: Tue, 19 May 2009 19:53:18 +0200
Message-ID: <20090519175318.GA2981@ami.dom.local>
References: <20090519123417.GA7376@ff.dom.local> <4A12D10D.3000504@cosmosbay.com> <20090519162330.GC28034@hmsreliant.think-freely.org> <20090519171703.GA2749@ami.dom.local> <20090519174504.GD28034@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, lav@yar.ru,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:60277 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753129AbZESRyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 13:54:49 -0400
Received: by fxm2 with SMTP id 2so4034115fxm.37
        for <netdev@vger.kernel.org>; Tue, 19 May 2009 10:54:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090519174504.GD28034@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2009 at 01:45:04PM -0400, Neil Horman wrote:
> On Tue, May 19, 2009 at 07:17:03PM +0200, Jarek Poplawski wrote:
...
> > > diff --git a/include/net/dst.h b/include/net/dst.h
> > > index 6be3b08..a39db6d 100644
> > > --- a/include/net/dst.h
> > > +++ b/include/net/dst.h
> > > @@ -47,6 +47,7 @@ struct dst_entry
> > >  #define DST_NOXFRM		2
> > >  #define DST_NOPOLICY		4
> > >  #define DST_NOHASH		8
> > > +#define DST_GRPLDR		16
> > >  	unsigned long		expires;
> > >  
> > >  	unsigned short		header_len;	/* more space at head required */
> > > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > > index c4c60e9..0120f0e 100644
> > > --- a/net/ipv4/route.c
> > > +++ b/net/ipv4/route.c
> > > @@ -610,6 +610,8 @@ static inline int ip_rt_proc_init(void)
> > >  
> > >  static inline void rt_free(struct rtable *rt)
> > >  {
> > > +	if (rt->u.dst.flags & DST_GRPLDR)
> > > +		rt->u.dst.rt_next->u.dst.flag |= DST_GRPLDR;
> > >  	call_rcu_bh(&rt->u.dst.rcu_head, dst_rcu_free);
> > >  }
> > >  
> > > @@ -1143,8 +1145,11 @@ restart:
> > >  		 * relvant to the hash function together, which we use to adjust
> > >  		 * our chain length
> > >  		 */
> > > -		if (*rthp && compare_hash_inputs(&(*rthp)->fl, &rt->fl))
> > > +		if (!*rthi && *rthp && 
> > > +		    compare_hash_inputs(&(*rthp)->fl, &rt->fl) &&
> > > +		    (cand != rth))
> > >  			rthi = rth;
> > 
> > Does it really prevent cand == rthi in the next loop?
> > 
> Yes, because cand and rthi are inspected during the same loop iteration, and
> both assigned from rth.  since I added a check which requires !rthi (which is
> actually a bug above that I need to fix), once rthi is set, it won't be moved,
> and on the next iteration, if cand is assigned, it is assigned to rth, which
> (being the next iteration), is a different rt cache entry
> 
> 
> > I didn't check Eric's patch yet, but I really don't know what's wrong
> > with something as simple as below for -stable, until "proper" fix is
> > analyzed and tested.
> > 
> Because the above fixes it without continuing to break the ordering.  You're
> change below prevents the leak, but still allows for disordered lists to form,
> which IMHO doesn't really make it a candidate for -stable.  I'd much rather fix
> both the leak and the ordering before pushing anything out
> 
> speaking of which, I'm going to ask again, I've been looking all morning, and
> I'm unable to find the move to front heuristic that you mentioned creates furthe
> list disordering.  If you can point it out to me, I can complete my patch and
> present something for you to test more throughly.

As I've written already, your patch looks OK to me.

Thanks,
Jarek P.
