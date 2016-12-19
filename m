From: "George Spelvin" <linux@sciencehorizons.net>
Subject: RE: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: 19 Dec 2016 13:10:40 -0500
Message-ID: <20161219181040.25441.qmail@ns.sciencehorizons.net>
References: <063D6719AE5E284EB5DD2968C1650D6DB0242669@AcuExch.aculab.com>
Cc: ak@linux.intel.com, davem@davemloft.net, djb@cr.yp.to,
        ebiggers3@gmail.com, hannes@stressinduktion.org, Jason@zx2c4.com,
        jeanphilippe.aumasson@gmail.com,
        kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, luto@amacapital.net,
        netdev@vger.kernel.org, torvalds@linux-foundation.org,
        tytso@mit.edu, vegard.nossum@gmail.com
To: David.Laight@ACULAB.COM, linux@sciencehorizons.net,
        tom@herbertland.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0242669@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Laight wrote:
> From: George Spelvin
...
>> uint32_t
>> hsiphash24(char const *in, size_t len, uint32_t const key[2])
>> {
>> 	uint32_t c = key[0];
>> 	uint32_t d = key[1];
>> 	uint32_t a =     0x6c796765 ^ 0x736f6d65;
>> 	uint32_t b = d ^ 0x74656462 ^ 0x646f7261;

> I've not looked closely, but is that (in some sense) duplicating
> the key length?
> So you could set a = key[2] and b = key[3] and still have an
> working hash - albeit not exactly the one specified.

That's tempting, but not necessarily effective.  (A similar unsuccesful
idea can be found in discussions of "DES with independent round keys".
Or see the design discussion of Salsa20 and the constants in its input.)

You can increase the key size, but that might not increase the *security*
any.

The big issue is that there are a *lot* of square root attack in
cryptanalysis.  Because SipHash's state is twice the size of the key,
such an attack will have the same complexity as key exhaustion and need
not be considered.  To make a stronger security claim, you need to start
working through them all and show that they don't apply.

For SipHash in particular, an important property is asymmetry of the
internal state.  That's what duplicating the key with XORs guarantees.
If the two halves of the state end up identical, the mixing is much
weaker.

Now the probability of ending up in a "mirror state" is the square
root of the state size (1 in 2^64 for HalfSipHash's 128-bit state),
which is the same probability as guessing a key, so it's not a
problem that has to be considered when making a 64-bit security claim.

But if you want a higher security level, you have to think about
what can happen.

That said, I have been thinking very hard about

	a = c ^ 0x48536970;	/* 'HSip' */
	d = key[2];

By guaranteeing that a and c are different, we get the desired
asymmetry, and the XOR of b and d is determined by the first word of
the message anyway, so this isn't weakening anything.

96 bits is far beyond the reach of any brute-force attack, and if a
more sophisticated 64-bit attack exists, it's at least out of the reach
of the script kiddies, and will almost certainly have a non-negligible
constant factor and more limits in when it can be applied.

> Is it worth using the 32bit hash for IP addresses on 64bit systems that
> can't do misaligned accessed?

Not a good idea.  To hash 64 bits of input:

* Full SipHash has to do two loads, a shift, an or, and two rounds of mixing.
* HalfSipHash has to do a load, two rounds, another load, and two more rounds.

In other words, in addition to being less secure, it's half the speed.  

Also, what systems are you thinking about?  x86, ARMv8, PowerPC, and
S390 (and ia64, if anyone cares) all handle unaligned loads.  MIPS has
efficient support.  Alpha and HPPA are for retrocomputing fans, not
people who care about performance.

So you're down to SPARC.  Which conveniently has the same maintainer as
the networking code, so I figure DaveM can take care of that himself. :-)
