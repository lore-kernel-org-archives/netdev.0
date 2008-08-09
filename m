From: Suresh Siddha <suresh.b.siddha@intel.com>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Sat, 9 Aug 2008 10:59:40 -0700
Message-ID: <20080809175940.GE13158@linux-os.sc.intel.com>
References: <200807171653.59177.wolfgang.walter@stwm.de> <20080806201401.GA607@linux-os.sc.intel.com> <200808071823.02364.wolfgang.walter@stwm.de> <200808081236.55172.wolfgang.walter@stwm.de> <20080808185356.GC607@linux-os.sc.intel.com> <489C97FB.2030408@zytor.com> <20080808231121.GA13158@linux-os.sc.intel.com> <20080809143727.GA30499@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Siddha, Suresh B" <suresh.b.siddha@intel.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Wolfgang Walter <wolfgang.walter@stwm.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	"viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
	"vegard.nossum@gmail.com" <vegard.nossum@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:2205 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750707AbYHIR7l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Aug 2008 13:59:41 -0400
Content-Disposition: inline
In-Reply-To: <20080809143727.GA30499@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 09, 2008 at 07:37:27AM -0700, Herbert Xu wrote:
> On Fri, Aug 08, 2008 at 04:11:21PM -0700, Suresh Siddha wrote:
> >
> > With out the recent dynamic fpu allocation changes, while we don't see oops,
> > there is a possible race still present in older kernels(for example,
> > while kernel is using kernel_fpu_begin() in some optimized clear/copy
> > page and an interrupt/softirq happens which uses these padlock
> > instructions generating DNA fault).
> 
> No this wasn't a problem because kernel_fpu_begin clears TS and
> therefore we don't get faults on SSE instructions.
> 
> However, with your patch it will become a problem due to the
> fact that it wasn't designed to be nested.

No. Here is the case that can fail on 2.6.25 aswell.

0. CPU's TS flag is set

1. kernel using FPU in some optimized copy  routine and while doing
kernel_fpu_begin() takes an interrupt just before doing clts()

2. Takes an interrupt and ipsec uses padlock instruction. And we
take a DNA fault as TS flag is still set.

3. We handle the DNA fault and set TS_USEDFPU and clear cr0.ts

4. We complete the padlock routine

5. Go back to step-1, which resumes clts() in kernel_fpu_begin(), finishes
the optimized copy routine and does kernel_fpu_end(). At this point,
we have cr0.ts again set to '1' but the task's TS_USEFPU is stilll
set and not cleared.

6. Now kernel resumes its user operation. And at the next context
switch, kernel sees it has do a FP save as TS_USEDFPU is still set
and then will do a unlazy_fpu() in __switch_to(). unlazy_fpu()
will take a DNA fault, as cr0.ts is '1' and now, because we are
in __switch_to(), math_state_restore() will get confused and will
restore the next task's FP state and will save it in prev tasks's FP state.
Remember, in __switch_to() we are already on the stack of the next task
but take a DNA fault for the prev task.

This causes the fpu leakage. We didn't encounter this so far on via
platforms because we don't have any optimized routines that use FP/SSE
in the kernel?

thanks,
suresh
