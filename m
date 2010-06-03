From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 16083] New: swapper: Page allocation failure
Date: Thu, 3 Jun 2010 14:39:15 -0700
Message-ID: <20100603143915.f1b0ba2b.akpm@linux-foundation.org>
References: <bug-16083-10286@https.bugzilla.kernel.org/>
	<20100603130235.c372b38f.akpm@linux-foundation.org>
	<1275599603.2533.58.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44953 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753486Ab0FCVjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 17:39:19 -0400
In-Reply-To: <1275599603.2533.58.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 03 Jun 2010 23:13:23 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le jeudi 03 juin 2010 __ 13:02 -0700, Andrew Morton a __crit :
> > On Mon, 31 May 2010 15:55:12 GMT
> > bugzilla-daemon@bugzilla.kernel.org wrote:
> > 
> > > https://bugzilla.kernel.org/show_bug.cgi?id=16083
> > > 
> > >            Summary: swapper: Page allocation failure
> > >            Product: Memory Management
> > >            Version: 2.5
> > >     Kernel Version: 2.6.34
> > >           Platform: All
> > >         OS/Version: Linux
> > >               Tree: Mainline
> > >             Status: NEW
> > >           Severity: normal
> > >           Priority: P1
> > >          Component: Other
> > >         AssignedTo: akpm@linux-foundation.org
> > >         ReportedBy: sgunderson@bigfoot.com
> > >         Regression: No
> > > 
> > > 
> > > Hi,
> > > 
> > > Since upgrading from a Q9450 to 2xE5520 (and upgrading from 2.6.34-rc-something
> > > to 2.6.34), I've started seeing these:
> > > 
> > > [605882.372418] swapper: page allocation failure. order:2, mode:0x4020
> > > [605882.378981] Pid: 0, comm: swapper Not tainted 2.6.34 #1
> > > [605882.384617] Call Trace:
> > > [605882.387499]  <IRQ>  [<ffffffff81096d5a>] __alloc_pages_nodemask+0x5b0/0x629
> > > [605882.395068]  [<ffffffff81096de5>] __get_free_pages+0x12/0x4f
> > > [605882.401103]  [<ffffffff810bdeb4>] __kmalloc_track_caller+0x4c/0x156
> > > [605882.407817]  [<ffffffff81245986>] ? sock_alloc_send_pskb+0xdd/0x32d
> > > [605882.414556]  [<ffffffff8124a515>] __alloc_skb+0x66/0x15b
> > 
> > I wonder if we should switch __alloc_skb() over to __GFP_NOWARN. 
> > People keep on reporting events such as the above, and nobody's
> > getting any value from this.
> > 
> 
> Then we could make __GFP_NOWARN for all allocations in kernel, why
> network is so special ?

Because this failure is known and is expected to occur sometimes and we
know that networking knows how to recover from it.

This removes most of the value from the warning.  The warning's there
to tell us about potentially buggy code, and to tell us why an
immediately-following oops happened.  Not applicable with alloc_skb()!

I mean, it's just not telling us anything very useful and it's alarming
users and is consuming effort.

> > Downsides:
> > 
> > - the change would tend to deprive MM developers of prompt "hey you
> >   broke it again" notifications.
> > 
> > - if a system is getting enough allocation failures to impact
> >   throughput, the operators won't *know* that it's happening, and so
> >   they won't make the changes necessary to reduce the frequency of
> >   memory allocation failures.
> > 
> 
> We should have SNMP counter increments 

I was thinking maybe a rate-limited printk every minute or so "12 skb
allocation failures since ...".  Dunno.

One of the problem with the current warning is that it looks like an oops.
In fact reporters regularly _call_ it "an oops".  Something less alarming
and more specific would be more helpful here.

> > If these are likely to be a problem, perhaps networking could provide
> > some other form of "hey, you keep on running out of memory"
> > notification, if it doesn't already do so.
> > 
> > Thoughts?
> > 
> 
> order-2 ATOMIC allocations ?
> 
> skb = mld_newpack(dev, dev->mtu);
> 
> Let's face it : It can not work in the long term.
> 
> MTU=9000 on a system with 4K pages... Oh well...
> 
> maybe net/ipv6/mcast.c should cap dev->mtu to PAGE_SIZE-128 or
> something, so that order-0 allocations are done.

Well.  The presence of this warning does serve to remind us how sucky
e1000[e] is :(

I'm not particularly fussed either way - I'm just wondering if you guys
think this thing meets the noise-to-benefit test...

