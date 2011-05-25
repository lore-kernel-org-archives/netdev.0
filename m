From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT PULL] Namespace file descriptors for 2.6.40
Date: Wed, 25 May 2011 10:25:14 +0200
Message-ID: <20110525082514.GE21552@elte.hu>
References: <m11uzrvd26.fsf@fess.ebiederm.org>
 <BANLkTim4q5dK6nOb=pVKbk1c8b-Nh_hBfA@mail.gmail.com>
 <m1boyvpo9r.fsf@fess.ebiederm.org>
 <1306048393.4092.8.camel@mulgrave.site>
 <20110522084224.GA12279@elte.hu>
 <m1k4dgr35i.fsf@fess.ebiederm.org>
 <20110524071628.GA31612@elte.hu>
 <4508.1306283693@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4508.1306283693@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Valdis.Kletnieks@vt.edu <Valdis.Kletnieks@vt.edu> wrote:

> On Tue, 24 May 2011 09:16:28 +0200, Ingo Molnar said:
> > * Eric W. Biederman <ebiederm@xmission.com> wrote:
> > > My gut feel says we should really implement an
> > > include/asm-generic/unistd-common.h to include all new system calls.
> > >
> > > That way there would be only one file to touch instead of 50. Certainly it
> > > works for include/asm-generic/unistd.h for the architectures that use it. 
> > > And all we really need is just a little abstraction on that concept.
> >
> > I suppose that could be tried, although in practice it would probably be
> > somewhat complex due to the various compat syscall handling differences.
> 
> Can somebody fill us newcomers in on the arch-aeology of why some syscalls have
> different numbers on different archs? I know it's partially because some simply
> didn't implement some syscalls so there were numbering mismatches, but would it
> have been *that* hard to wire all of those skipped syscalls up to one stub
> 'return -ENOSYS'?

It was done so for hysterical raisons mostly, and once a bad ABI is done it's 
very hard to undo it: beyond pushing the 'good ABI' you'd also still have to 
deal with the bad ABI for a decade or more.

So the background is that most architectures start out as quick concept 
prototypes, doing:

	cp -a arch/existingarch arch/newarch

where 'existingarch' used to be arch/i386/ in the early days. Now i386 had a 
fair amount of x86 specific syscalls that were naturally removed from 
'newarch'. Those created 'holes' in the numbers, which were then filled in with 
new syscalls - a nice idea in itself!

Also sometimes 'newarch' did a 'clean', compressed list of syscall numbers 
straight away, reordering syscalls. Once the 'quick prototype' hack starts 
working on real hardware, once the syscall numbers get into the C library and 
binutils it's very hard to ever transition away: you'd break the world!

An added source of noise that architectures tend to add new syscalls in a 
different order: some are more interesting to them - some less.

So these syscall table hacks done very early during an arch's lifetime stick 
around and create wild numbering noise in 20+ syscall tables:

                                       [ slightly edited for readability ]

 arch/alpha/include/asm/unistd.h:      #define __NR_perf_event_open 493
 arch/arm/include/asm/unistd.h:        #define __NR_perf_event_open 364
 arch/blackfin/include/asm/unistd.h:   #define __NR_perf_event_open 369
 arch/frv/include/asm/unistd.h:        #define __NR_perf_event_open 336
 arch/m68k/include/asm/unistd.h:       #define __NR_perf_event_open 332
 arch/microblaze/include/asm/unistd.h: #define __NR_perf_event_open 366
 arch/mips/include/asm/unistd.h:       #define __NR_perf_event_open 333
 arch/mips/include/asm/unistd.h:       #define __NR_perf_event_open 292
 arch/mips/include/asm/unistd.h:       #define __NR_perf_event_open 296
 arch/mn10300/include/asm/unistd.h:    #define __NR_perf_event_open 337
 arch/parisc/include/asm/unistd.h:     #define __NR_perf_event_open 318
 arch/powerpc/include/asm/unistd.h:    #define __NR_perf_event_open 319
 arch/s390/include/asm/unistd.h:       #define __NR_perf_event_open 331
 arch/sh/include/asm/unistd_32.h:      #define __NR_perf_event_open 336
 arch/sh/include/asm/unistd_64.h:      #define __NR_perf_event_open 364
 arch/sparc/include/asm/unistd.h:      #define __NR_perf_event_open 327
 arch/x86/include/asm/unistd_32.h:     #define __NR_perf_event_open 336
 arch/x86/include/asm/unistd_64.h:     #define __NR_perf_event_open 298

To fix this we'd create a new, clean offset defined by each architecture, and a 
generic enumeration of new syscalls.

This would make it much easier to add new, generic syscalls to all 
architectures indeed.

It would still leave compat syscall wrappers unaddressed though: those are 
often numbered differently and sometimes need arch specific wrapper entry 
functions, which then call the real generic syscall.

But at least the primary, 'native' syscall table of every arch could be kept 
rather fresh via generic enumeration.

Thanks,

	Ingo
