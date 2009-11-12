From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v2] Documentation: rw_lock lessons learned
Date: Thu, 12 Nov 2009 07:40:30 -0800 (PST)
Message-ID: <alpine.LFD.2.01.0911120726430.31845@localhost.localdomain>
References: <4AF9C540.5090403@gmail.com> <20091110180646.2e5859a8@nehalam> <4AFAEF78.4080807@gmail.com> <20091111093724.4f40a48d@nehalam> <4AFBEC44.9030409@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52752 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753145AbZKLPki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 10:40:38 -0500
In-Reply-To: <4AFBEC44.9030409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 12 Nov 2009, William Allen Simpson wrote:
>
> In recent weeks, two different network projects erroneously
> strayed down the rw_lock path.  Update the Documentation
> based upon comments by Eric Dumazet and Paul E. McKenney in
> those threads.

This still retains some pretty old and bogus language. For example, that 
file still talks about spinlocks being "faster than a global interrupt 
lock", which is kind of amusing - because we've not done that global 
interrupt lock thing for the last ten years or so. 

So I certainly agree with discouraging rwlocks - I don't think we've ever 
really found a situation where they are useful except for some really 
special cases - but I suspect the thing needs a bigger overhaul.

I also suspect somebody should actually take a look at our _users_ of 
rwlocks. We have a few fairly central ones like 'tasklist_lock', and it 
may be an example of a _good_ case of rwlocks, but for a very non-obvious 
reason.

In the case of 'tasklist_lock', the magic subtle reason that makes it a 
good idea is that that lock is commonly taken for reading in _interrupts_. 
And the way rwlocks are defined, that means that you can take it for 
reading without doing the *_irq() or *_irqsave() versions, because rwlocks 
are not fair, so an active reader will never block a new reader even if 
there is a blocked writer pending.

So for tasklist_lock, raw rwlocks are still slower than raw spinlocks, but 
because of the rwlock semantics the common case doesn't need to disable 
and enable interrupts, so for the common case the comparison is not "raw 
rwlock vs raw spinlock", but "raw rwlock vs interrupt-disabling spinlock", 
and then it turns out rwlocks tend to win again.

(Of course, lock_write() needs to disable interrupts for tasklist_lock, 
but that tends to be the uncommon case).

Ho humm..

		Linus
