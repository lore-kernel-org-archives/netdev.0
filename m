From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [RFC/PATCH] kernel/irq: allow more precise irq affinity
 policies
Date: Thu, 9 Sep 2010 13:03:38 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.1009091056280.2477@localhost6.localdomain6>
References: <20100906233827.GB12956@sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Arthur Kepner <akepner@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:47166 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753840Ab0IILDv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Sep 2010 07:03:51 -0400
In-Reply-To: <20100906233827.GB12956@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 6 Sep 2010, Arthur Kepner wrote:
 
> SGI has encountered situations where particular CPUs run out of 
> interrupt vectors on systems with many (several hundred or more) 
> CPUs. This happens because some drivers (particularly the mlx4_core 
> driver) select the number of interrupts they allocate based on the 
> number of CPUS, and because of how the default irq affinity is used.
> 
> The following patch allows for a more precise policy about how irq 
> affinities are assigned by the kernel (though it doesn't implement 
> any new policy, except for a practically useless example).
> 
> This is a work in progress. I know that it needs several additional 
> things, including:
> 
> 	- redistribute interrupts when the 'current_irq_policy' is 
> 	  updated (for now it only affects irqs allocated after the 
> 	  policy is changed)

We implement mechanisms not policies in the kernel. And we already
have a mechanism to redistribute interrupts.

Let's look at the problem you're tyring to solve.

Your network driver wants to use one interrupt per cpu, which are now
assigned to a single core due to the way the default irq affinity
settings work. On a large system this exceeds the number of vectors
per cpu. Ok, that's bad.

But now you try to solve that problem with magic policies in the
generic irq code. That's wrong.

What you really want is a way to tell the generic code that your
driver would like to see a particular interrupt assigned to a
particular core, right ?

We already have the affinity_hint mechanism in place, which allows a
driver to give a hint to the user space irq balancer, which of course
does not help if your device comes up before user space runs.

So the obvious solution is to extend that mechanism and let the kernel
use the affinity hint as a first selection criteria as well - user
space can still override it.

That's a trivial change and does not impose any policies on the
kernel. 

> 	- a means to notify drivers about irq_policy changes (so 
> 	  they can adjust network queues, etc.)

I can understand that, but again it's not about policies. What you
want is a callback into the driver which is called _before_ a user
space irq affinity setting is applied. That way a driver could even
veto such a change if there are hard restrictions on which core or
node it can be placed.

OTOH, it's more straight forward to tell the driver to move a specific
queue to a specific core and handle it from there. That keeps the
magic confined to the driver and does not affect generic code.

Thanks,

	tglx
