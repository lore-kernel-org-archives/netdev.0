From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: 15 Dec 2016 17:42:24 -0500
Message-ID: <20161215224224.21447.qmail@ns.sciencehorizons.net>
References: <20161215203003.31989-2-Jason@zx2c4.com>
Reply-To: kernel-hardening@lists.openwall.com
Cc: djb@cr.yp.to, jeanphilippe.aumasson@gmail.com
To: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
  ebiggers3@gmail.com, hannes@stressinduktion.org, Jason@zx2c4.com,
  kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
  linux-kernel@vger.kernel.org, linux@sciencehorizons.net,
  luto@amacapital.net, netdev@vger.kernel.org, tom@herbertland.com,
  torvalds@linux-foundation.org, tytso@mit.edu, vegard.nossum@gmail.com
Return-path: <kernel-hardening-return-5609-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161215203003.31989-2-Jason@zx2c4.com>
List-Id: netdev.vger.kernel.org

> While SipHash is extremely fast for a cryptographically secure function,
> it is likely a tiny bit slower than the insecure jhash, and so replacements
> will be evaluated on a case-by-case basis based on whether or not the
> difference in speed is negligible and whether or not the current jhash usage
> poses a real security risk.

To quantify that, jhash is 27 instructions per 12 bytes of input, with a
dependency path length of 13 instructions.  (24/12 in __jash_mix, plus
3/1 for adding the input to the state.) The final add + __jhash_final
is 24 instructions with a path length of 15, which is close enough for
this handwaving.  Call it 18n instructions and 8n cycles for 8n bytes.

SipHash (on a 64-bit machine) is 14 instructions with a dependency path
length of 4 *per round*.  Two rounds per 8 bytes, plus plus two adds
and one cycle per input word, plus four rounds to finish makes 30n+46
instructions and 9n+16 cycles for 8n bytes.

So *if* you have a 64-bit 4-way superscalar machine, it's not that much
slower once it gets going, but the four-round finalization is quite
noticeable for short inputs.

For typical kernel input lengths "within a factor of 2" is
probably more accurate than "a tiny bit".

You lose a factor of 2 if you machine is 2-way or non-superscalar,
and a second factor of 2 if it's a 32-bit machine.

I mention this because there are a lot of home routers and other netwoek
appliances running Linux on 32-bit ARM and MIPS processors.  For those,
it's a factor of *eight*, which is a lot more than "a tiny bit".

The real killer is if you don't have enough registers; SipHash performs
horribly on i386 because it uses more state than i386 has registers.

(If i386 performance is desired, you might ask Jean-Philippe for some
rotate constants for a 32-bit variant with 64 bits of key.  Note that
SipHash's security proof requires that key length + input length is
strictly less than the state size, so for a 4x32-bit variant, while
you could stretch the key length a little, you'd have a hard limit at
95 bits.)


A second point, the final XOR in SipHash is either a (very minor) design
mistake, or an opportunity for optimization, depending on how you look
at it.  Look at the end of the function:

>+	SIPROUND;
>+	SIPROUND;
>+	return (v0 ^ v1) ^ (v2 ^ v3);

Expanding that out, you get:
+	v0 += v1; v1 = rol64(v1, 13); v1 ^= v0; v0 = rol64(v0, 32);
+	v2 += v3; v3 = rol64(v3, 16); v3 ^= v2;
+	v0 += v3; v3 = rol64(v3, 21); v3 ^= v0;
+	v2 += v1; v1 = rol64(v1, 17); v1 ^= v2; v2 = rol64(v2, 32);
+	return v0 ^ v1 ^ v2 ^ v3;

Since the final XOR includes both v0 and v3, it's undoing the "v3 ^= v0"
two lines earlier, so the value of v0 doesn't matter after its XOR into
v1 on line one.

The final SIPROUND and return can then be optimized to

+	v0 += v1; v1 = rol64(v1, 13); v1 ^= v0;
+	v2 += v3; v3 = rol64(v3, 16); v3 ^= v2;
+	v3 = rol64(v3, 21);
+	v2 += v1; v1 = rol64(v1, 17); v1 ^= v2; v2 = rol64(v2, 32);
+	return v1 ^ v2 ^ v3;

A 32-bit implementation could further tweak the 4 instructions of
	v1 ^= v2; v2 = rol64(v2, 32); v1 ^= v2;

gcc 6.2.1 -O3 compiles it to basically:
	v1.low ^= v2.low;
	v1.high ^= v2.high;
	v1.low ^= v2.high;
	v1.high ^= v2.low;
but it could be written as:
	v2.low ^= v2.high;
	v1.low ^= v2.low;
	v1.high ^= v2.low;

Alternatively, if it's for private use only (key not shared with other
systems), a slightly stronger variant would "return v1 ^ v3;".
(The final swap of v2 is dead code, but a compiler can spot that easily.)
