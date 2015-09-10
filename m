From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: fix race on protocol/netns initialization
Date: Thu, 10 Sep 2015 13:24:54 -0300
Message-ID: <20150910162454.GB4496@localhost.localdomain>
References: <27f20cc781cac28bc2ce7229719748a2f6824bd8.1441827818.git.marcelo.leitner@gmail.com>
 <55F096EB.7000204@gmail.com>
 <55F09F57.6080602@gmail.com>
 <55F1847A.9010801@gmail.com>
 <55F19243.3010006@gmail.com>
 <55F1A6AE.2010804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	linux-sctp@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59410 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751598AbbIJQY6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Sep 2015 12:24:58 -0400
Content-Disposition: inline
In-Reply-To: <55F1A6AE.2010804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 10, 2015 at 11:50:06AM -0400, Vlad Yasevich wrote:
> On 09/10/2015 10:22 AM, Marcelo Ricardo Leitner wrote:
> > Em 10-09-2015 10:24, Vlad Yasevich escreveu:
...
> >> Then you can order sctp_net_init() such that it happens first, then protosw registration
> >> happens, then control socket initialization happens, then inet protocol registration
> >> happens.
> >>
> >> This way, we are always guaranteed that by the time user calls socket(), protocol
> >> defaults are fully initialized.
> > 
> > Okay, that works for module loading stage, but then how would we handle new netns's? We
> > have to create the control socket per netns and AFAICT sctp_net_init() is the only hook
> > called when a new netns is being created.
> > 
> > Then if we move it a workqueue that is scheduled by sctp_net_init(), we loose the ability
> > to handle its errors by propagating through sctp_net_init() return value, not good.
> 
> Here is kind of what I had in mind.  It's incomplete and completely untested (not even
> compiled), but good enough to describe the idea:
...

Ohh, ok now I get it, thanks. If having two pernet_subsys for a given
module is fine, that works for me. It's clearer and has no moment of
temporary failure.

I can finish this patch if everybody agrees with it.

> >>> I used the list pointer because that's null as that memory is entirely zeroed when alloced
> >>> and, after initialization, it's never null again. Works like a lock/condition without
> >>> using an extra field.
> >>>
> >>
> >> I understand this a well.  What I don't particularly like is that we are re-using
> >> a list without really stating why it's now done this way.  Additionally, it's not really
> >> the last that happens so it's seems kind of hacky...  If we need to add new
> >> per-net initializers, we now need to make sure that the code is put in the right
> >> place.  I'd just really like to have a cleaner solution...
> > 
> > Ok, got you. We could add a dedicated flag/bit for that then, if reusing the list is not
> > clear enough. Or, as we are discussing on the other part of thread, we could make it block
> > and wait for the initialization, probably using some wait_queue. I'm still thinking on
> > something this way, likely something more below than sctp then.
> > 
> 
> I think if we don the above, the second process calling socket() will either find the
> the protosw or will try to load the module also.  I think either is ok after
> request_module returns we'll look at the protosw and will find find things.

Seems so, yes. Nice.

  Marcelo
