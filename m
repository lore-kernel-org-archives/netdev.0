From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3 net-next] net: Implement fast csum_partial for x86_64
Date: Wed, 10 Feb 2016 11:39:50 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCDCC8D@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1CCDBCA5@AcuExch.aculab.com>
 <20160210005346.21908.qmail@ns.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "mingo@kernel.org" <mingo@kernel.org>
To: 'George Spelvin' <linux@horizon.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tom@herbertland.com" <tom@herbertland.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160210005346.21908.qmail@ns.horizon.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: George Spelvin
> Sent: 10 February 2016 00:54
> To: David Laight; linux-kernel@vger.kernel.org; linux@horizon.com; netdev@vger.kernel.org;
> David Laight wrote:
> > Since adcx and adox must execute in parallel I clearly need to re-remember
> > how dependencies against the flags register work. I'm sure I remember
> > issues with 'false dependencies' against the flags.
> 
> The issue is with flags register bits that are *not* modified by
> an instruction.  If the register is treated as a monolithic entity,
> then the previous values of those bits must be considered an *input*
> to the instruction, forcing serialization.
> 
> The first step in avoiding this problem is to consider the rarely-modified
> bits (interrupt, direction, trap, etc.) to be a separate logical register
> from the arithmetic flags (carry, overflow, zero, sign, aux carry and parity)
> which are updated by almost every instruction.
> 
> An arithmetic instruction overwrites the arithmetic flags (so it's only
> a WAW dependency which can be broken by renaming) and doesn't touch the
> status flags (so no dependency).
> 
> However, on x86 even the arithmetic flags aren't updated consistently.
> The biggest offender are the (very common!) INC/DEC instructions,
> which update all of the arithmetic flags *except* the carry flag.
> 
> Thus, the carry flag is also renamed separately on every superscalar
> x86 implementation I've ever heard of.

Ah, that is the little fact I'd forgotten.
...
> Anyway, I'm sure that when Intel defined ADCX and ADOX they felt that
> it was reasonable to commit to always renaming CF and OF separately.

Separate renaming allows:
1) The value to tested without waiting for pending updates to complete.
   Useful for IE and DIR.
2) Instructions that modify almost all the flags to execute without
   waiting for a previous instruction to complete.
   So separating 'carry' allows inc/dec to execute without waiting
   for previous arithmetic to complete.

The latter should remove the dependency (both ways) between 'adc' and
'dec, jnz' in a checksum loop.

I can't see any obvious gain from separating out O or Z (even with
adcx and adox). You'd need some other instructions that don't set O (or Z)
but set some other useful flags.
(A decrement that only set Z for instance.)

> > However you still need a loop construct that doesn't modify 'o' or 'c'.
> > Using leal, jcxz, jmp might work.
> > (Unless broadwell actually has a fast 'loop' instruction.)
> 
> According to Agner Fog (http://agner.org/optimize/instruction_tables.pdf),
> JCXZ is reasonably fast (2 uops) on almost all 64-bit CPUs, right back
> to K8 and Merom.  The one exception is Precott.  JCXZ and LOOP are 4
> uops on those processors.  But 64 bit in general sucked on Precott,
> so how much do we care?
> 
> AMD:	LOOP is slow (7 uops) on K8, K10, Bobcat and Jaguar.
> 	JCXZ is acceptable on all of them.
> 	LOOP and JCXZ are 1 uop on Bulldozer, Piledriver and Steamroller.
> Intel:	LOOP is slow (7+ uops) on all processors up to and including Skylake.
> 	JCXZ is 2 upos on everything from P6 to Skylake exacpt for:
> 	- Prescott (JCXZ & loop both 4 uops)
> 	- 1st gen Atom (JCXZ 3 uops, LOOP 8 uops)
> 	I can't find any that it's fast on.

While LOOP could be used on Bulldozer+ an equivalently fast loop
can be done with inc/dec and jnz.
So you only care about LOOP/JCXZ when ADOX is supported.

I think the fastest loop is:
10:	adc	%rax,0(%rdi,%rcx,8)
	inc	%rcx
	jnz	10b
but check if any cpu add an extra clock for the 'scaled' offset
(they might be faster if %rdi is incremented).
That loop looks like it will have no overhead on recent cpu.

	David
