From: Suresh Siddha <suresh.b.siddha@intel.com>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Sat, 9 Aug 2008 12:37:24 -0700
Message-ID: <20080809193724.GJ13158@linux-os.sc.intel.com>
References: <200807171653.59177.wolfgang.walter@stwm.de> <20080808231121.GA13158@linux-os.sc.intel.com> <20080809143727.GA30499@gondor.apana.org.au> <200808091757.32999.wolfgang.walter@stwm.de> <489DC15D.9070308@zytor.com> <20080809185224.GH13158@linux-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	Wolfgang Walter <wolfgang.walter@stwm.de>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	"viro@ZenIV.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"vegard.nossum@gmail.com" <vegard.nossum@gmail.com>
To: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:51841 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751892AbYHITh3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Aug 2008 15:37:29 -0400
Content-Disposition: inline
In-Reply-To: <20080809185224.GH13158@linux-os.sc.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 09, 2008 at 11:52:24AM -0700, Siddha, Suresh B wrote:
> Backing out lazy allocation is not just enough here. Let me think a little
> more on this.

Can we have something like irq_ts_save() and irq_ts_restore(), which will
do something like:

int irq_ts_save()
{
	if (!in_interrupt())
		return 0;

	if (read_cr0() & X86_CR0_TS) {
		clts();
		return 1;
	}
	return 0;
}

void irq_ts_restore(int TS_state)
{
	if (!in_interrupt())
		return 0;

	if (TS_state)
		stts();
}

and use this around padlock usage. Taking a spurious DNA fault in the process
context(even inside the kernel) should be ok. Main issue is with the interrupt
context and we can prevent the DNA fault in the irq context using above.

Either above, or we have to remove the lazy fpu allocation and make the
below code in kernel_fpu_begin() atomic by disabling interrupts(to fix
the security hole with padlock usage)

kernel_fpu_begin:
	...

	local_irq_disable();

        if (me->status & TS_USEDFPU)
                __save_init_fpu(me->task);
        else
                clts(); 

	local_irq_enable();
	...
