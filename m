From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] hfsc: ensure class is added to eltree exactly once
Date: Wed, 1 Jun 2016 01:49:55 +0200
Message-ID: <20160531234955.GB26552@breakpoint.cc>
References: <1464689539-15162-1-git-send-email-fw@strlen.de>
 <1464706554.5939.105.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160531230048.GA26552@breakpoint.cc>
 <1464737614.5939.142.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Miroslav Kratochvil <exa.exa@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:41937 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750750AbcEaXt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 19:49:59 -0400
Content-Disposition: inline
In-Reply-To: <1464737614.5939.142.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-06-01 at 01:00 +0200, Florian Westphal wrote:
> Generally speaking, a non work conserving qdisc could return NULL if it
> decides to drop all packet(s) that were sitting in the queue.
> 
> Say we add a 'max sojourn time' on skbs, as yet another anti-bloat
> features, in a Codel variant/extension.
>
> HFSC does check this and eventually complains ( qdisc_warn_nonwc()),
> but all its precise computations are probably wrong.

Right, this is already a problem when using hfsc with silly fq_codel config
(we can end up with underflow on sch->q.qlen, i.e. hfsc
ends up thinking it has 0xffffffff packets in class while fq_codel has 0).

> > > If you want to make HFSC generic, you would need a lot more changes.
> > 
> > Could you elaborate?
> 
> HFSC is based on packet lengths and realtime/deadline constraints.
> 
> With lazy packet lengths (if the attached children qdisc reorder
> packets), this all becomes fuzzy. Which might be OK or not.
> 
> We are not helping users by silently making such decisions.
> Maybe they prefer to be warned so that they can fix their setup.

Seems that limits us to pfifo or prio+pfifo only...

> > I'm not interested in e.g. tbf leaves (makes no sense to me), but I
> > think it should play nice with netem, sfq, codel, fq_codel, fq, ...
> > 
> > I don't see any problems with fq_codel + hfsc unless I deliberately
> > misconfigure fq_codel (setting extremely low mem limit, e.g. 32kbyte).
> 
> That is pure luck, then. I would not be surprised that HTB + nonwc qdisc
> would actually crash in some cases.

Ugh.  I think that using codel, sfq, fq_codel etc. should just work
when used with htb or hfsc.

Using tbf and friends should at least not crash kernel (it would
be nice if we could complain and/or reject at config time though).

Thanks for your input, I see this isn't easy to resolve.
