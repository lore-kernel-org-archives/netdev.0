From: Matt Mackall <mpm@selenic.com>
Subject: Re: 2.6.23 WARNING: at kernel/softirq.c:139 local_bh_enable()
Date: Fri, 23 Nov 2007 13:41:39 -0600
Message-ID: <20071123194139.GC19691@waste.org>
References: <4745DCD7.8070805@simon.arlott.org.uk> <20071123002157.cb27f4a1.akpm@linux-foundation.org> <20071123105518.GA22062@2ka.mipt.ru> <20071123170756.GV19691@waste.org> <20071123175757.GA23991@2ka.mipt.ru> <20071123184851.GA14415@2ka.mipt.ru> <20071123185101.GA17582@2ka.mipt.ru> <20071123185906.GA23710@2ka.mipt.ru> <20071123191120.GA19691@waste.org> <20071123193222.GA22168@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Simon Arlott <simon@fire.lp0.eu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Ingo Molnar <mingo@redhat.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757727AbXKWTqf@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071123193222.GA22168@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 23, 2007 at 10:32:22PM +0300, Evgeniy Polyakov wrote:
> On Fri, Nov 23, 2007 at 01:11:20PM -0600, Matt Mackall (mpm@selenic.com) wrote:
> > On Fri, Nov 23, 2007 at 09:59:06PM +0300, Evgeniy Polyakov wrote:
> > > On Fri, Nov 23, 2007 at 09:51:01PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > > > On Fri, Nov 23, 2007 at 09:48:51PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > > > > Stop, we are trying to free skb without destructor and catch connection
> > > > > tracking, so it is not a solution. To fix the problem we need to check
> > > > > if it is not netfilter related, kind of this (not tested), Simon please
> > > > > give it a try:
> > > > 
> > > > And to be really cool we need to bypass skbs with xfrm attached, since
> > > > its freeing also assumes BH context.
> > > 
> > > What about compile options?
> > 
> > What about my original suggestion that we mark skbs owned by netpoll
> > and free only those. Much safer, no? Untested:
> 
> This should work if there are netpoll's skbs, but if we are under memory
> pressure we want to free not only netpoll skbs, but at least one, and 
> what if there are no netpoll skbs in the queue?

Yeah, that's a concern (but note that we do have a private reserve and
we only really need the zap when our reserve is depleted). But I worry
that it's too fragile and if we add a new unsafe case, it won't be
noticed for a long time. This is the first report I've seen of this
particular problem, so this has been a latent bug for three or four
years now.

Here's another thought: move all this logic into the networking core,
unify it with current softirq zapper, then allow it to be called from
various other places (like atomic allocators). Then it'll all be in
central maintained place with more users.

-- 
Mathematics is the supreme nostalgia of our time.
