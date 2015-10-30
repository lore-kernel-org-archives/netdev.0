From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: kernel BUG in ipmr_queue_xmit()
Date: Fri, 30 Oct 2015 11:40:24 +0100
Message-ID: <1446201624.707140.424480297.4D8B55D6@webmail.messagingengine.com>
References: <alpine.OSX.2.00.1510291646320.59200@animac.local>
 <20151030001510.GG18062@breakpoint.cc>
 <alpine.OSX.2.00.1510291841480.68875@animac.local>
 <1446178542.6254.6.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151030103658.GA25931@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ani Sinha <ani@arista.com>, netdev@vger.kernel.org,
	ani@anirban.org, fruggeri@arista.com
To: Florian Westphal <fw@strlen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:40633 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758643AbbJ3Kk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 06:40:27 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 5B21220958
	for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 06:40:24 -0400 (EDT)
In-Reply-To: <20151030103658.GA25931@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 30, 2015, at 11:36, Florian Westphal wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > Signed-off-by: Ani Sinha <ani@arista.com>
> > > ---
> > >  net/ipv4/ipmr.c | 2 ++
> > >  1 file changed, 2 insertions(+)
> > > 
> > > diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
> > > index 866ee89..48df3cc 100644
> > > --- a/net/ipv4/ipmr.c
> > > +++ b/net/ipv4/ipmr.c
> > > @@ -936,7 +936,9 @@ static void ipmr_cache_resolve(struct net *net, struct mr_table *mrt,
> > >  
> > >  			rtnl_unicast(skb, net, NETLINK_CB(skb).portid);
> > >  		} else {
> > > +			preempt_disable();
> > >  			ip_mr_forward(net, mrt, skb, c, 0);
> > > +			preempt_enable();
> > >  		}
> > >  	}
> > >  }
> > 
> > I do not believe this fix is correct.
> 
> Yes, sorry.  I should have suggested local_bh_disable instead.
> 
> > Better replace the
> > IP_INC_STATS_BH() by IP_INC_STATS()
> >
> > and IP_ADD_STATS_BH() by IP_ADD_STATS()
> 
> Hmm, whats the rationale for this?
> 
> Note that IP_ADD_STATS_BH in question is unconditional (not in
> error path).  It seems that its virtually always called from softirq
> except in the setsockopt case.

The naming of the functions is bad if you compare them to e.g.
spin_lock_bh.

STATS_BH can only be used from bottom half and the normal ones (without
_BH) can be called from everywhere. It is a common pattern in the
kernel.

Eric's proposal is correct.

Bye,
Hannes
