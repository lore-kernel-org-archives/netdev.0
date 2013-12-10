From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next] ipv6: router reachability probing
Date: Tue, 10 Dec 2013 22:01:44 +0100
Message-ID: <20131210220144.183982cd@griffin>
References: <ce8e9118b640b938048aaf18b59e998d46ab400e.1386692051.git.jbenc@redhat.com>
	<20131210205101.GA25505@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49752 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750712Ab3LJVBw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Dec 2013 16:01:52 -0500
In-Reply-To: <20131210205101.GA25505@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Dec 2013 21:51:01 +0100, Hannes Frederic Sowa wrote:
> The reason is that we don't send a neighbour advertisment in FAILED state
> and thus shouldn't accept one. RFC 4861 7.2.5. specifies that we should
> not add a new entry to the neighbour discovery table just because of a
> neighbour advertisment. Because NUD_FAILED is just an artifical state
> to the linux kernel we should treat it like the entry is not existent.

That was the missing piece, thanks!

> The canonical way would be to place this neighbor in the NUD_PROBE state
> in rt6_probe.

Okay, will respin the patch.

> > diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> > index ddb9d41c8eea..147c39f7f70d 100644
> > --- a/net/ipv6/route.c
> > +++ b/net/ipv6/route.c
> > @@ -66,8 +66,9 @@
> >  #endif
> >  
> >  enum rt6_nud_state {
> > -	RT6_NUD_FAIL_HARD = -2,
> > -	RT6_NUD_FAIL_SOFT = -1,
> > +	RT6_NUD_FAIL_HARD = -3,
> > +	RT6_NUD_FAIL_PROBE = -2,
> > +	RT6_NUD_FAIL_DO_RR = -1,
> >  	RT6_NUD_SUCCEED = 1
> >  };
> >  
> > @@ -577,11 +578,13 @@ static inline enum rt6_nud_state rt6_check_neigh(struct rt6_info *rt)
> >  #ifdef CONFIG_IPV6_ROUTER_PREF
> >  		else if (!(neigh->nud_state & NUD_FAILED))
> >  			ret = RT6_NUD_SUCCEED;
> > +		else
> > +			ret = RT6_NUD_FAIL_PROBE;
> >  #endif
> 
> Nit:
> We could now change the declaration of ret in rt6_check_neigh from
> "enum rt6_nud_state ret = RT6_NUD_FAIL_HARD"
> to
> "enum rt6_nud_state ret;" as all cases are covered now.

That's what I originally thought, too, but it's not the case when
CONFIG_IPV6_ROUTER_PREF is not defined and neigh->nud_state != NUD_VALID.

> Otherwise the patch is a nice improvment.

Thanks!

 Jiri

-- 
Jiri Benc
