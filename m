From: "George Spelvin" <linux@horizon.com>
Subject: RE: [PATCH v3 net-next] net: Implement fast csum_partial for x86_64
Date: 9 Feb 2016 19:53:46 -0500
Message-ID: <20160210005346.21908.qmail@ns.horizon.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1CCDBCA5@AcuExch.aculab.com>
Cc: mingo@kernel.org
To: David.Laight@ACULAB.COM, linux-kernel@vger.kernel.org,
	linux@horizon.com, netdev@vger.kernel.org, tom@herbertland.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCDBCA5@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Laight wrote:
> Since adcx and adox must execute in parallel I clearly need to re-remember
> how dependencies against the flags register work. I'm sure I remember
> issues with 'false dependencies' against the flags.

The issue is with flags register bits that are *not* modified by
an instruction.  If the register is treated as a monolithic entity,
then the previous values of those bits must be considered an *input*
to the instruction, forcing serialization.

The first step in avoiding this problem is to consider the rarely-modified
bits (interrupt, direction, trap, etc.) to be a separate logical register
from the arithmetic flags (carry, overflow, zero, sign, aux carry and parity)
which are updated by almost every instruction.

An arithmetic instruction overwrites the arithmetic flags (so it's only
a WAW dependency which can be broken by renaming) and doesn't touch the
status flags (so no dependency).

However, on x86 even the arithmetic flags aren't updated consistently.
The biggest offender are the (very common!) INC/DEC instructions,
which update all of the arithmetic flags *except* the carry flag.

Thus, the carry flag is also renamed separately on every superscalar
x86 implementation I've ever heard of.

The bit test instructions (BT, BTC, BTR, BTS) also affect *only*
the carry flag, leaving other flags unmodified.  This is also
handled properly by renaming the carry flag separately.


Here's a brief summary chart of flags updated by common instructions:
http://www.logix.cz/michal/doc/i386/app-c.htm
and the full list with all the corner cases:
http://www.logix.cz/michal/doc/i386/app-b.htm

The other two flags that can be worth separating are the overflow
and zero flags.

The rotate instructions modify *only* the carry and overflow flags.
While overflow is undefined for multi-bit rotates (and thus leaving it
unmodified is a valid implementation), it's defined for single-bit rotates,
so must be written.

There are several less common instructions, notably BSF, BSR, CMPXCHG8B,
and a bunch of 80286 segment instructions that nobody cares about,
which retort the result of a test in the zero flag and are defined to
not affect the other flags.


So an aggressive x86 implementation breaks the flags register into five
separately renamed registers:
- CF (carry)
- OF (overflow)
- ZF (zero)
- SF, AF, PF (sign, aux carry, and parity)
- DF, IF, TF, IOPL, etc.

Anyway, I'm sure that when Intel defined ADCX and ADOX they felt that
it was reasonable to commit to always renaming CF and OF separately.

> However you still need a loop construct that doesn't modify 'o' or 'c'.
> Using leal, jcxz, jmp might work.
> (Unless broadwell actually has a fast 'loop' instruction.)

According to Agner Fog (http://agner.org/optimize/instruction_tables.pdf),
JCXZ is reasonably fast (2 uops) on almost all 64-bit CPUs, right back
to K8 and Merom.  The one exception is Precott.  JCXZ and LOOP are 4
uops on those processors.  But 64 bit in general sucked on Precott,
so how much do we care?

AMD:	LOOP is slow (7 uops) on K8, K10, Bobcat and Jaguar.
	JCXZ is acceptable on all of them.
	LOOP and JCXZ are 1 uop on Bulldozer, Piledriver and Steamroller.
Intel:	LOOP is slow (7+ uops) on all processors up to and including Skylake.
	JCXZ is 2 upos on everything from P6 to Skylake exacpt for:
	- Prescott (JCXZ & loop both 4 uops)
	- 1st gen Atom (JCXZ 3 uops, LOOP 8 uops)
	I can't find any that it's fast on.
