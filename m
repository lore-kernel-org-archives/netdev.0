From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/24] make atomic_read() behave consistently on alpha
Date: Thu, 9 Aug 2007 10:41:50 -0700
Message-ID: <20070809174150.GE8424@linux.vnet.ibm.com>
References: <20070809132442.GA13042@shell.boston.redhat.com> <20070809143255.GA8424@linux.vnet.ibm.com> <46BB2A5A.5090006@redhat.com> <20070809150445.GB8424@linux.vnet.ibm.com> <46BB31A6.4080507@redhat.com> <20070809161024.GC8424@linux.vnet.ibm.com> <46BB4281.7010803@redhat.com> <20070809165853.GD8424@linux.vnet.ibm.com> <46BB4B7B.4070007@redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:58525 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757232AbXHIRly (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 13:41:54 -0400
Content-Disposition: inline
In-Reply-To: <46BB4B7B.4070007@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 09, 2007 at 01:14:35PM -0400, Chris Snook wrote:
> Paul E. McKenney wrote:
> >On Thu, Aug 09, 2007 at 12:36:17PM -0400, Chris Snook wrote:
> >>Paul E. McKenney wrote:
> >>>The compiler is within its rights to read a 32-bit quantity 16 bits at
> >>>at time, even on a 32-bit machine.  I would be glad to help pummel any
> >>>compiler writer that pulls such a dirty trick, but the C standard really
> >>>does permit this.
> >>Yes, but we don't write code for these compilers.  There are countless 
> >>pieces of kernel code which would break in this condition, and there 
> >>doesn't seem to be any interest in fixing this.
> >>
> >>>Use of volatile does in fact save you from the compiler pushing stores 
> >>>out
> >>>of loops regardless of whether you are also doing reads.  The C standard
> >>>has the notion of sequence points, which occur at various places 
> >>>including
> >>>the ends of statements and the control expressions for "if" and "while"
> >>>statements.  The compiler is not permitted to move volatile references
> >>>across a sequence point.  Therefore, the compiler is not allowed to
> >>>push a volatile store out of a loop.  Now the CPU might well do such a
> >>>reordering, but that is a separate issue to be dealt with via memory
> >>>barriers.  Note that it is the CPU and I/O system, not the compiler,
> >>>that is forcing you to use reads to flush writes to MMIO registers.
> >>Sequence points enforce read-after-write ordering, not write-after-write. 
> >>We flush writes with reads for MMIO because of this effect as well as the 
> >>CPU/bus effects.
> >
> >Neither volatile reads nor volatile writes may be moved across sequence
> >points.
> 
> By the compiler, or by the CPU?

As mentioned in earlier emails, by the compiler.  The CPU knows nothing
of C sequence points.

>                                 If you're depending on volatile writes 
> being visible to other CPUs, you're screwed either way, because the CPU can 
> hold that data in cache as long as it wants before it writes it to memory.  
> When this finally does happen, it will happen atomically, which is all that 
> atomic_set guarantees.  If you need to guarantee that the value is written 
> to memory at a particular time in your execution sequence, you either have 
> to read it from memory to force the compiler to store it first (and a 
> volatile cast in atomic_read will suffice for this) or you have to use 
> LOCK_PREFIX instructions which will invalidate remote cache lines 
> containing the same variable.  This patch doesn't change either of these 
> cases.

The case that it -can- change is interactions with interrupt handlers.
And NMI/SMI handlers, for that matter.

> >>>And you would be amazed at what compiler writers will do in order to
> >>>get an additional fraction of a percent out of SpecCPU...
> >>Probably not :)
> >>
> >>>In short, please retain atomic_set()'s volatility, especially on those
> >>>architectures that declared the atomic_t's counter to be volatile.
> >>Like i386 and x86_64?  These used to have volatile in the atomic_t 
> >>declaration. We removed it, and the sky did not fall.
> >
> >Interesting.  You tested all possible configs on all possible hardware?
> 
> No, but I can reason about it and be confident that this won't break 
> anything that isn't already broken.  At worst, this patch will make any 
> existing subtly incorrect uses of atomic_t much more obvious and easier to 
> track down.

You took interrupt and NMI/SMI handlers into account?

							Thanx, Paul
