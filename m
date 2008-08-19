From: Ingo Molnar <mingo@elte.hu>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- connection between
	HPET and lockups found
Date: Tue, 19 Aug 2008 11:23:52 +0200
Message-ID: <20080819092352.GC28713@elte.hu>
References: <310212.64521.qm@web82103.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yinghai Lu <yhlu.kernel@gmail.com>, linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: David Witbrodt <dawitbro@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:57583 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753302AbYHSJYd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2008 05:24:33 -0400
Content-Disposition: inline
In-Reply-To: <310212.64521.qm@web82103.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Witbrodt <dawitbro@sbcglobal.net> wrote:

> > the address you printed out (0xffff88000100f000), does look 
> > _somewhat_ suspicious. It corresponds to the physical address of 
> > 0x100f000. That is _just_ above the 16MB boundary. It should not be 
> > relevant normally - but it's still somewhat suspicious.
> 
> I guess I was hitting around about the upper 32 bits -- I take it that 
> these pointers are virtualized, and the upper half is some sort of 
> descriptor?  In that pointer was in a flat memory model, then it would 
> be pointing _way_ past the end of my 2 GB of RAM, which would end 
> around 0x0000000080000000.

correct, the 64-bit "flat" physical addresses are mapped with a shift: 
they are shifted down into negative addresses, starting at:

earth4:~/tip> grep PAGE_OFFSET include/asm-x86/page_64.h
#define __PAGE_OFFSET           _AC(0xffff880000000000, UL)

i.e. physical address zero is mapped to "minus 120 terabytes". [we do 
this on the 64-bit kernel to get out of the way of the application 
address space, which goes from the usual zero.]

All in one, 0xffff88000100f000 is a regular kernel address that 
corresponds to the physical address of 0x100f000 - i.e. 16 MB plus 
15*4KB.

> I am not used to looking at raw pointer addresses, just pointer variable 
> names.  I think I was recalling the /proc/iomem data that Yinghai asked 
> for, but this stuff is just offsets stripped of descriptors, huh?:
> 
> $ cat /proc/iomem
> fed00000-fed003ff : HPET 0
>   fed00000-fed003ff : 0000:00:14.0

correct - these resource descriptors are in the "physical address" space 
(system RAM, chipset decoded addresses, device decoded addresses, etc.).

fed00000-fed003ff means that your HPET hardware sits at physical address 
4275044352, or just below 4GB. That is the usual place for such non-RAM 
device memory - it does not get in the way of normal RAM.

> It's like the change to alloc_bootmem_low made no difference at all!
> 
> The Aug. 12 messages I saw about alloc_bootmem() had to do with 
> alignment issues on 1 GB boundaries on x86_64 NUMA machines.  I 
> certainly do have x86_64 NUMA machines, but the behavior above seems 
> to have nothing to do with alignment issues.

the resource descriptor is really a kernel internal abstraction - it's 
just a memory buffer we put the hpet address into. It's in essence used 
for /proc/iomem output, not much else. So it _should_ not have any 
effects.

the real difference is likely that the hpet hardware is activated on 
your box - and apparently is causing problems.

> Results: locked up

:-/

Just to make sure: on a working kernel, do you get the HPET messages? 
I.e. does the hpet truly work in that case?

	Ingo
