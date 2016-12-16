From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: 15 Dec 2016 22:46:18 -0500
Message-ID: <20161216034618.28276.qmail@ns.sciencehorizons.net>
References: <CAGiyFdfmiCMyHvAg=5sGh8KjBBrF0Wb4Qf=JLzJqUAx4yFSS3Q@mail.gmail.com>
Cc: djb@cr.yp.to
To: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
        ebiggers3@gmail.com, hannes@stressinduktion.org, Jason@zx2c4.com,
        jeanphilippe.aumasson@gmail.com,
        kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux@sciencehorizons.net,
        luto@amacapital.net, netdev@vger.kernel.org, tom@herbertland.com,
        torvalds@linux-foundation.org, tytso@mit.edu,
        vegard.nossum@gmail.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CAGiyFdfmiCMyHvAg=5sGh8KjBBrF0Wb4Qf=JLzJqUAx4yFSS3Q@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jean-Philippe Aumasson wrote:
> If a halved version of SipHash can bring significant performance boost
> (with 32b words instead of 64b words) with an acceptable security level
> (64-bit enough?) then we may design such a version.

It would be fairly significant, a 2x speed benefit on a lot of 32-bit
machines.

First is the fact that a 64-bit SipHash round on a generic 32-bit machine
requires not twice as many instructions, but more than three.

Consider the core SipHash quarter-round operation:
	a += b;
	b = rotate_left(b, k)
	b ^= a

The add and xor are equivalent between 32- and 64-bit rounds; twice the
instructions do twice the work.  (There's a dependency via the carry
bit between the two halves of the add, but it ends up not being on the
critical path even in a superscalar implementation.)

The problem is the rotates.  Although some particularly nice code is
possible on 32-bit ARM due to its support for shift-and-xor operations,
on a generic 32-bit CPU the rotate grows to 6 instructions with a 2-cycle
dependency chain (more in practice because barrel shifters are large and
even quad-issue CPUs can't do 4 shifts per cycle):

	temp_lo = b_lo >> (32-k)
	temp_hi = b_hi >> (32-k)
	b_lo <<= k
	b_hi <<= k
	b_lo ^= temp_hi
	b_hi ^= temp_lo

The resultant instruction counts and (assuming wide issue)
latencies are:

	64-bit SipHash	"Half" SipHash
	Inst.	Latency	Inst.	Latency
	 10	 3	  3	 2	Quarter round
	 40	 6	 12	 4	Full round
	 80	12	 24	 8	Two rounds
	 82	13	 26	 9	Mix in one word
	 82	13	 52	18	Mix in 64 bits
	166	26	 61	18	Four round finalization + final XOR
	248	39	113	36	Hash 64 bits
	330	52	165	54	Hash 128 bits
	412	65	217	72	Hash 192 bits

While the ideal latencies are actually better for the 64-bit algorithm,
that requires an unrealistic 6+-wide superscalar implementation that's
more than twice as wide as the 64-bit code requires (which is already
optimized for quad-issue).  For a 1- or 2-wide processor, the instruction
counts dominate, and not only does the 64-bit algorithm take 60% more
time to mix in the same number of bytes, but the finalization rounds
bring the ratio to 2:1 for small inputs.

(And I haven't included the possible savings if the input size is an odd
number of 32-bit words, such as networking applications which include
the source/dest port numbers.)


Notes on particular processors:
- x86 can do a 64-bit rotate in 3 instructions and 2 cycles using
  the SHLD/SHRD instructions instead:
	movl	%b_hi, %temp
	shldl	$k, %b_lo, %b_hi
	shldl	$k, %temp, %b_lo
  ... but as I mentioned the problem is registers.  SipHash needs 8 32-bit
  words plus at least one temporary, and 32-bit x86 has only 7 available.
  (And compilers can rarely manage to keep more than 6 of them busy.)
- 64-bit SipHash is particularly efficient on 32-bit ARM due to its
  support for shift-and-op instructions.  The 64-bit shift and following
  xor can be done in 4 instructions.  So the only benefit is from the
  reduced finalization.
- Double-width adds cost a little more on CPUs like MIPS and RISC-V without
  condition codes.
- Certain particularly crappy uClinux processors with slow shifts
  (68000, anyone?) really suffer from extra shifts.

One *weakly* requested feature: It might simplify some programming
interfaces if we could use the same key for multiple hash tables with a
1-word "tweak" (e.g. pointer to the hash table, so it could be assumed
non-zero if that helped) to make distinct functions.  That would let us
more safely use a global key for multiple small hash tables without the
need to add code to generate and store key material for each place that
an unkeyed hash is replaced.
