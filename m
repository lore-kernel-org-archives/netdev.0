From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [1/4] kevent: core files.
Date: Fri, 23 Jun 2006 17:53:14 -0400
Message-ID: <20060623215314.GG14126@kvack.org>
References: <20060623192422.GA11508@2ka.mipt.ru> <20060623.131940.48806210.davem@davemloft.net> <20060623203114.GD14126@kvack.org> <20060623.135423.115910361.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johnpol@2ka.mipt.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:14001 "EHLO kanga.kvack.org")
	by vger.kernel.org with ESMTP id S1752100AbWFWVx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 17:53:27 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060623.135423.115910361.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 23, 2006 at 01:54:23PM -0700, David Miller wrote:
> From: Benjamin LaHaise <bcrl@kvack.org>
> Date: Fri, 23 Jun 2006 16:31:14 -0400
> 
> > Eh?  Nobody has posted any numbers comparing the approaches yet, so this 
> > is pure handwaving, unless you have real concrete results?
> 
> Evgeniy posts numbers and performance graphs on his kevent work all
> the time.

But you're argueing that the performance of something that hasn't been 
tested is worse simply by nature of it not having been tested.  That's a 
fallacy of omission, iiuc.

> Van Jacobson did in his LCA2006 net channel slides too, perhaps you
> missed that.

I have yet to be convinced that the layering violation known as net channels 
is the right way to go, mostly because it breaks horribly in a few cases -- 
think what happens during periods of CPU overcommit, in which case doing too 
much in interrupt context will kill a system (which is why softirqs are 
needed).  The effect of doing all processing in user context creates issues 
with delayed acks (due to context switching to other tasks in the system), 
which will cause excess retransmits.  The hard problems associated with 
packet filtering and security are also still unresolved, which is okay for 
a paper, but a concern in real life.

There are also a number of performance flaws in the current stack that 
show up under profiling, some of which I posted fixes for, some of which 
have yet to be fixed.  The pushf/popf pipeline stall was one of the bigger 
instances of CPU wastage that Van Jacobson noticed (it shows up as bottom 
halves using lots of CPU).  Iirc, Ingo's real time patches may avoid that 
by way of reworking the irq disable/enable mechanism, which would mean the 
results need retesting.  Using the cr8 register to enable/disable 
interrupts on x86-64 might also improve things, as that would eliminate the 
flags dependancy of cli/sti...

In short, there's a lot of work that still has to be done.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.
