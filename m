From: Suresh Siddha <suresh.b.siddha@intel.com>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Sat, 9 Aug 2008 11:12:19 -0700
Message-ID: <20080809181219.GF13158@linux-os.sc.intel.com>
References: <200807171653.59177.wolfgang.walter@stwm.de> <20080808231121.GA13158@linux-os.sc.intel.com> <20080809143727.GA30499@gondor.apana.org.au> <200808091757.32999.wolfgang.walter@stwm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"Siddha, Suresh B" <suresh.b.siddha@intel.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	"viro@ZenIV.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"vegard.nossum@gmail.com" <vegard.nossum@gmail.com>
To: Wolfgang Walter <wolfgang.walter@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:62132 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751147AbYHISMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Aug 2008 14:12:37 -0400
Content-Disposition: inline
In-Reply-To: <200808091757.32999.wolfgang.walter@stwm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 09, 2008 at 08:57:32AM -0700, Wolfgang Walter wrote:
> On Saturday 09 August 2008, Herbert Xu wrote:
> > On Fri, Aug 08, 2008 at 04:11:21PM -0700, Suresh Siddha wrote:
> > >
> > > With out the recent dynamic fpu allocation changes, while we don't see
> oops,
> > > there is a possible race still present in older kernels(for example,
> > > while kernel is using kernel_fpu_begin() in some optimized clear/copy
> > > page and an interrupt/softirq happens which uses these padlock
> > > instructions generating DNA fault).
> >
> > No this wasn't a problem because kernel_fpu_begin clears TS and
> > therefore we don't get faults on SSE instructions.
> >
> > However, with your patch it will become a problem due to the
> > fact that it wasn't designed to be nested.
> >
> I don't exactly understand this. You think that
> 
> kernel_fpu_begin();
> XCRYPT....
> kernel_fpu_end();
> 
> is a problem and wasn't before?

Wolf, kernel_fpu_begin() and kernel_fpu_end() only saves the user
state from getting corrupted with the kernel state. But it doesn't
help if kernel has nesting fpu usage.

In this padlock case with the patch, we may encounter a nested
kernel_fpu_begin() and end()
but this is ok, as the padlock is not actually touching fpu/sse registers.

Yes, we do have a problem when the interrupt handlers also use SSE
registers and if there is a nesting inside the kernel. Today we don't
have any such usage.

> If XCRYPT may be interrupted and the interrupt code again uses this optimized
> memcpy implementation and so nesting kernel_fpu_begin then why should this
> not happen with the other alg.
> 
> How could any kernel code use MMX/SSE/FPU when the interrupt case isn't
> handled?

Today we don't have any nesting, for example, fast memcpy, if in interrupt
will use the slow version and doesnt use the optimized version.

thanks,
suresh
