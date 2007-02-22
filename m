From: linux@horizon.com
Subject: Re: Extensible hashing and RCU
Date: 22 Feb 2007 18:49:00 -0500
Message-ID: <20070222234900.27633.qmail@science.horizon.com>
References: <f2b55d220702200749l4fa2b14foa861cf37288cfb8d@mail.gmail.com>
Cc: akepner@sgi.com, bcrl@kvack.org, dada1@cosmosbay.com,
	davem@davemloft.net, linux@horizon.com, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru, medwards.linux@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([192.35.100.1]:16112 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752064AbXBWANG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 19:13:06 -0500
In-Reply-To: <f2b55d220702200749l4fa2b14foa861cf37288cfb8d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I think you misunderstood me.  If you are trying to DoS me from
> outside with a hash collision attack, you are trying to feed me
> packets that fall into the same hash bucket.  The Jenkins hash does
> not have to be artifact-free, and does not have to be
> cryptographically strong.  It just has to do a passable job of mixing
> a random salt into the tuple, so you don't know which string of
> packets to feed me in order to fill one (or a few) of my buckets.
> XORing salt into a folded tuple doesn't help; it just permutes the
> buckets.

If you want to understand this more formally, read up on "universal
families of hash functions," which is the name cryptologists give to
this concept.

When used according to directions, they are actually *more* secure than
standard cryptographic hashes such as MD5 and SHA.  The key difference
is that *the attacker doesn't get to see the hash output*.

The basic pattern is:
- Here's a family of hash functions, e.g. a salted hash function.
- I pick one at random.  (E.g. choose a salt.)
- Now your challenge is to generate a pair of inputs which will
  collide.
- Note that you never get to see sample input/output pairs of the
  hash function.  All you know is that it's a member of the family.
- It is surprisingly easy to find families of size N such that
  an attacker has on the order of a 1/N chance to construct a collision.
- This remains true even if you assume that the attacker has
  infinite computational power.

This pattern corresponds exactly to an attacker trying to force collisions
in a hash table they can't see.


As far as I know, nobody has proved salted jash a truly universal family,
but so many amazingly simple algorithms have been proved universal that
it wouldn't surprise me if it was.

For example, the family of all CRCs computed modulo n-bit primitive
polynomials is a universal family.  If you do know the polynomial, it's
ridiculously easy to build a collision.  If you don't, it's provably
impossible.

(Footnote: the chance isn't exactly 1/N, but also depends on the size
of the input relative to the size of the hash.  With bigger inputs, it's
easier to make them match according to more of the hashes.  Ultimately,
if you have N k-bit CRC polynomials, you can make them all collide with
an N*k-bit input.  But since N is proportional to 2^k, it's easy to make
k big enough that this is impractical.)

The rehash-every-10-minutes detail is theoretically unnecessary,
but does cover the case where a would-be attacker *does* get a chance
to look at a machine, such as by using routing delays to measure the
effectiveness of a collision attempt.


Now, as for flaming about how xor generates more uniform distributions
than jhash - that's to be expected from a weak hash.  By relying on
non-uniform properties of the input (particularly that hosts tend to walk
linearly through the source port space), you can make hash values walk
linearly through your hash table, and get a completely even distribution
rather than a *random* one.

This is great for efficiency, but depends on letting patterns in the hash
input through to the output, which is exactly the property that makes it
vulnerable to a deliberate DoS attempt.

If you want to test your distribution for randomness, go have a look
at Knuth volume 2 (seminumerical algorithms) and see the discussion of
the Kolmogorov-Smirnov test.  Some lumpiness is *expected* in a truly
random distribution.
