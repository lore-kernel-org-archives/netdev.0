From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel BUG in ipmr_queue_xmit()
Date: Fri, 30 Oct 2015 04:00:28 -0700
Message-ID: <1446202828.6254.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.OSX.2.00.1510291646320.59200@animac.local>
	 <20151030001510.GG18062@breakpoint.cc>
	 <alpine.OSX.2.00.1510291841480.68875@animac.local>
	 <1446178542.6254.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151030103658.GA25931@breakpoint.cc>
	 <1446201624.707140.424480297.4D8B55D6@webmail.messagingengine.com>
	 <20151030104846.GA3461@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Ani Sinha <ani@arista.com>, netdev@vger.kernel.org,
	ani@anirban.org, fruggeri@arista.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34145 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966231AbbJ3LAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 07:00:31 -0400
Received: by padhk11 with SMTP id hk11so71869312pad.1
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 04:00:30 -0700 (PDT)
In-Reply-To: <20151030104846.GA3461@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-10-30 at 11:48 +0100, Florian Westphal wrote:
> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> > > > > @@ -936,7 +936,9 @@ static void ipmr_cache_resolve(struct net *net, struct mr_table *mrt,
> > > > >  
> > > > >  			rtnl_unicast(skb, net, NETLINK_CB(skb).portid);
> > > > >  		} else {
> > > > > +			preempt_disable();
> > > > >  			ip_mr_forward(net, mrt, skb, c, 0);
> > > > > +			preempt_enable();
> > > > >  		}
> > > > >  	}
> > > > >  }
> > > > 
> > > > I do not believe this fix is correct.
> > > 
> > > Yes, sorry.  I should have suggested local_bh_disable instead.
> > > 
> > > > Better replace the
> > > > IP_INC_STATS_BH() by IP_INC_STATS()
> > > >
> > > > and IP_ADD_STATS_BH() by IP_ADD_STATS()
> > > 
> > > Hmm, whats the rationale for this?
> > > 
> > > Note that IP_ADD_STATS_BH in question is unconditional (not in
> > > error path).  It seems that its virtually always called from softirq
> > > except in the setsockopt case.
> > 
> > The naming of the functions is bad if you compare them to e.g.
> > spin_lock_bh.
> > 
> > STATS_BH can only be used from bottom half and the normal ones (without
> > _BH) can be called from everywhere. It is a common pattern in the
> > kernel.
> > 
> > Eric's proposal is correct.
> 
> Yes, its correct but it results in 4 additonal bh on/off calls
> for the common case, hence my question.
> 
> Moving the one ip_mr_forward into bh-off keeps the bh-disable thing
> in the setsockopt path.

I have no idea how long is the ip_mr_forward(net, mrt, skb, c, 0)
section, and if GFP_KERNEL allocations were attempted in this path.

The proposed fix might add other regressions.

I do not want to spend time auditing this code that nobody uses.

While on x86, IP_INC_STATS() does not use additional bh on/off calls

In general, we should disable interrupts (even if soft) for limited
amount of times.
