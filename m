From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Fw: [Bug 13339] New: rtable leak in ipv4/route.c
Date: Tue, 19 May 2009 19:47:40 +0200
Message-ID: <20090519174740.GC2749@ami.dom.local>
References: <20090519123417.GA7376@ff.dom.local> <4A12D10D.3000504@cosmosbay.com> <20090519162330.GC28034@hmsreliant.think-freely.org> <20090519171703.GA2749@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, lav@yar.ru,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:46693 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250AbZESRs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 13:48:58 -0400
Received: by fxm2 with SMTP id 2so4030983fxm.37
        for <netdev@vger.kernel.org>; Tue, 19 May 2009 10:48:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090519171703.GA2749@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2009 at 07:17:03PM +0200, Jarek Poplawski wrote:
> On Tue, May 19, 2009 at 12:23:30PM -0400, Neil Horman wrote:
...
> > Of course, it helps if I attach the patch :)
> > 
> > 
> > diff --git a/include/net/dst.h b/include/net/dst.h
> > index 6be3b08..a39db6d 100644
> > --- a/include/net/dst.h
> > +++ b/include/net/dst.h
> > @@ -47,6 +47,7 @@ struct dst_entry
> >  #define DST_NOXFRM		2
> >  #define DST_NOPOLICY		4
> >  #define DST_NOHASH		8
> > +#define DST_GRPLDR		16
> >  	unsigned long		expires;
> >  
> >  	unsigned short		header_len;	/* more space at head required */
> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > index c4c60e9..0120f0e 100644
> > --- a/net/ipv4/route.c
> > +++ b/net/ipv4/route.c
> > @@ -610,6 +610,8 @@ static inline int ip_rt_proc_init(void)
> >  
> >  static inline void rt_free(struct rtable *rt)
> >  {
> > +	if (rt->u.dst.flags & DST_GRPLDR)
> > +		rt->u.dst.rt_next->u.dst.flag |= DST_GRPLDR;
> >  	call_rcu_bh(&rt->u.dst.rcu_head, dst_rcu_free);
> >  }
> >  
> > @@ -1143,8 +1145,11 @@ restart:
> >  		 * relvant to the hash function together, which we use to adjust
> >  		 * our chain length
> >  		 */
> > -		if (*rthp && compare_hash_inputs(&(*rthp)->fl, &rt->fl))
> > +		if (!*rthi && *rthp && 
> > +		    compare_hash_inputs(&(*rthp)->fl, &rt->fl) &&
> > +		    (cand != rth))
> >  			rthi = rth;
> 
> Does it really prevent cand == rthi in the next loop?

Hmm.. It looks OK yet!

Sorry,
Jarek P.
