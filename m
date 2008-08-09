From: Suresh Siddha <suresh.b.siddha@intel.com>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Sat, 9 Aug 2008 11:52:24 -0700
Message-ID: <20080809185224.GH13158@linux-os.sc.intel.com>
References: <200807171653.59177.wolfgang.walter@stwm.de> <20080808231121.GA13158@linux-os.sc.intel.com> <20080809143727.GA30499@gondor.apana.org.au> <200808091757.32999.wolfgang.walter@stwm.de> <489DC15D.9070308@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wolfgang Walter <wolfgang.walter@stwm.de>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Siddha, Suresh B" <suresh.b.siddha@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	"viro@ZenIV.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"vegard.nossum@gmail.com" <vegard.nossum@gmail.com>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:60781 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750984AbYHISwg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Aug 2008 14:52:36 -0400
Content-Disposition: inline
In-Reply-To: <489DC15D.9070308@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 09, 2008 at 09:10:05AM -0700, H. Peter Anvin wrote:
> Wolfgang Walter wrote:
> > How could any kernel code use MMX/SSE/FPU when the interrupt case isn't
> > handled?
> 
> I don't think we have ever allowed MMX/SSE/FPU code in interrupt
> handlers.  kernel_fpu_begin()..end() lock out preemption, and so could
> only be interrupted, not preempted.

Yes, fast handlers fall back to slow handlers in the interrupt context
and don't touch FP/SSE and thus avoid the kernel nesting.

hmm, in the padlock interrupt usage scenario(even though it doesn't touch FP/SSE
registers), kernel_fpu_begin/end() will not solve the problem,
as nesting of kernel_fpu_begin() is not ok, as we unconditionally
do stts() in kernel_fpu_end(). So the proposed patch is not ok,
as we end up corrupting first kernel FP usage.

> > Or is your argument that its lazy allocation itself is the problem: this
> > nesting could always happen and was a bug but only with lazy allocation it is
> > dangerous (as it may cause a spurious math fault in the race window).
> >
> > If this were right than any kernel code executing SSE may trigger now a oops
> > in __switch_to() under some special circumstances.
> 
> If lazy allocation can cause the RAID code, for example (which executes
> SSE instructions in the kernel, but not at interrupt time) to start
> randomly oopsing, then lazy allocations have to be pulled.

While the lazy allocation is not a big thing and can be pulled(with a
very small patch), this has brought two existing security issues to light
so far. one in lguest code(fixed now) and now in padlock usage. I think even
in 2.6.25, padlock usage can easily can cause the FPU leakage as I mentioned
in another response.

Backing out lazy allocation is not just enough here. Let me think a little
more on this.

thanks,
suresh
