From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [GIT PULL] Namespace file descriptors for 2.6.40
Date: Wed, 25 May 2011 10:35:59 +0200
Message-ID: <BANLkTikVDrU7Nx6143gPuB=1vwqkMFiRiQ@mail.gmail.com>
References: <m11uzrvd26.fsf@fess.ebiederm.org>
	<BANLkTim4q5dK6nOb=pVKbk1c8b-Nh_hBfA@mail.gmail.com>
	<m1boyvpo9r.fsf@fess.ebiederm.org>
	<1306048393.4092.8.camel@mulgrave.site>
	<20110522084224.GA12279@elte.hu>
	<m1k4dgr35i.fsf@fess.ebiederm.org>
	<20110524071628.GA31612@elte.hu>
	<4508.1306283693@localhost>
	<20110525082514.GE21552@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Valdis.Kletnieks@vt.edu,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110525082514.GE21552@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 25, 2011 at 10:25, Ingo Molnar <mingo@elte.hu> wrote:
> * Valdis.Kletnieks@vt.edu <Valdis.Kletnieks@vt.edu> wrote:
>
>> On Tue, 24 May 2011 09:16:28 +0200, Ingo Molnar said:
>> > * Eric W. Biederman <ebiederm@xmission.com> wrote:
>> > > My gut feel says we should really implement an
>> > > include/asm-generic/unistd-common.h to include all new system ca=
lls.
>> > >
>> > > That way there would be only one file to touch instead of 50. Ce=
rtainly it
>> > > works for include/asm-generic/unistd.h for the architectures tha=
t use it.
>> > > And all we really need is just a little abstraction on that conc=
ept.
>> >
>> > I suppose that could be tried, although in practice it would proba=
bly be
>> > somewhat complex due to the various compat syscall handling differ=
ences.
>>
>> Can somebody fill us newcomers in on the arch-aeology of why some sy=
scalls have
>> different numbers on different archs? I know it's partially because =
some simply
>> didn't implement some syscalls so there were numbering mismatches, b=
ut would it
>> have been *that* hard to wire all of those skipped syscalls up to on=
e stub
>> 'return -ENOSYS'?
>
> It was done so for hysterical raisons mostly, and once a bad ABI is d=
one it's
> very hard to undo it: beyond pushing the 'good ABI' you'd also still =
have to
> deal with the bad ABI for a decade or more.
>
> So the background is that most architectures start out as quick conce=
pt
> prototypes, doing:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0cp -a arch/existingarch arch/newarch
>
> where 'existingarch' used to be arch/i386/ in the early days. Now i38=
6 had a
> fair amount of x86 specific syscalls that were naturally removed from
> 'newarch'. Those created 'holes' in the numbers, which were then fill=
ed in with
> new syscalls - a nice idea in itself!
>
> Also sometimes 'newarch' did a 'clean', compressed list of syscall nu=
mbers
> straight away, reordering syscalls. Once the 'quick prototype' hack s=
tarts
> working on real hardware, once the syscall numbers get into the C lib=
rary and
> binutils it's very hard to ever transition away: you'd break the worl=
d!
>
> An added source of noise that architectures tend to add new syscalls =
in a
> different order: some are more interesting to them - some less.
>
> So these syscall table hacks done very early during an arch's lifetim=
e stick
> around and create wild numbering noise in 20+ syscall tables:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 [ sligh=
tly edited for readability ]
>
> =C2=A0arch/alpha/include/asm/unistd.h: =C2=A0 =C2=A0 =C2=A0#define __=
NR_perf_event_open 493
> =C2=A0arch/arm/include/asm/unistd.h: =C2=A0 =C2=A0 =C2=A0 =C2=A0#defi=
ne __NR_perf_event_open 364
> =C2=A0arch/blackfin/include/asm/unistd.h: =C2=A0 #define __NR_perf_ev=
ent_open 369
> =C2=A0arch/frv/include/asm/unistd.h: =C2=A0 =C2=A0 =C2=A0 =C2=A0#defi=
ne __NR_perf_event_open 336
> =C2=A0arch/m68k/include/asm/unistd.h: =C2=A0 =C2=A0 =C2=A0 #define __=
NR_perf_event_open 332
> =C2=A0arch/microblaze/include/asm/unistd.h: #define __NR_perf_event_o=
pen 366
> =C2=A0arch/mips/include/asm/unistd.h: =C2=A0 =C2=A0 =C2=A0 #define __=
NR_perf_event_open 333
> =C2=A0arch/mips/include/asm/unistd.h: =C2=A0 =C2=A0 =C2=A0 #define __=
NR_perf_event_open 292
> =C2=A0arch/mips/include/asm/unistd.h: =C2=A0 =C2=A0 =C2=A0 #define __=
NR_perf_event_open 296
> =C2=A0arch/mn10300/include/asm/unistd.h: =C2=A0 =C2=A0#define __NR_pe=
rf_event_open 337
> =C2=A0arch/parisc/include/asm/unistd.h: =C2=A0 =C2=A0 #define __NR_pe=
rf_event_open 318
> =C2=A0arch/powerpc/include/asm/unistd.h: =C2=A0 =C2=A0#define __NR_pe=
rf_event_open 319
> =C2=A0arch/s390/include/asm/unistd.h: =C2=A0 =C2=A0 =C2=A0 #define __=
NR_perf_event_open 331
> =C2=A0arch/sh/include/asm/unistd_32.h: =C2=A0 =C2=A0 =C2=A0#define __=
NR_perf_event_open 336
> =C2=A0arch/sh/include/asm/unistd_64.h: =C2=A0 =C2=A0 =C2=A0#define __=
NR_perf_event_open 364
> =C2=A0arch/sparc/include/asm/unistd.h: =C2=A0 =C2=A0 =C2=A0#define __=
NR_perf_event_open 327
> =C2=A0arch/x86/include/asm/unistd_32.h: =C2=A0 =C2=A0 #define __NR_pe=
rf_event_open 336
> =C2=A0arch/x86/include/asm/unistd_64.h: =C2=A0 =C2=A0 #define __NR_pe=
rf_event_open 298
>
> To fix this we'd create a new, clean offset defined by each architect=
ure, and a
> generic enumeration of new syscalls.
>
> This would make it much easier to add new, generic syscalls to all
> architectures indeed.
>
> It would still leave compat syscall wrappers unaddressed though: thos=
e are
> often numbered differently and sometimes need arch specific wrapper e=
ntry
> functions, which then call the real generic syscall.
>
> But at least the primary, 'native' syscall table of every arch could =
be kept
> rather fresh via generic enumeration.

So we can start all over at offset 501 (alpha just started using 500)
with a unified,
clean, and compressed list of syscalls? Or do we have some more other-o=
s-compat
syscalls around in this range?

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds
