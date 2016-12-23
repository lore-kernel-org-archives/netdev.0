From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: George's crazy full state idea (Re: HalfSipHash Acceptable Usage)
Date: 23 Dec 2016 13:26:26 -0500
Message-ID: <20161223182626.6290.qmail@ns.sciencehorizons.net>
References: <1482494724.3353.7.camel@stressinduktion.org>
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
        ebiggers3@gmail.com, eric.dumazet@gmail.com, Jason@zx2c4.com,
        kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, luto@kernel.org,
        netdev@vger.kernel.org, tom@herbertland.com, tytso@mit.edu,
        vegard.nossum@gmail.com
To: hannes@stressinduktion.org, linux@sciencehorizons.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482494724.3353.7.camel@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Cc: list trimmed slightly as the topic is wandering a bit.)

Hannes Frederic Sowa wrote:
> On Thu, 2016-12-22 at 19:07 -0500, George Spelvin wrote:
>> Adding might_lock() annotations will improve coverage a lot.
>
> Might be hard to find the correct lock we take later down the code
> path, but if that is possible, certainly.

The point of might_lock() is that you don't have to.  You find the
worst case (most global) lock that the code *might* take if all the
buffer-empty conditions are true, and tell lockdep "assume this lock is
taken all the time".

>> Hannes Frederic Sowa wrote:
>>> Yes, that does look nice indeed. Accounting for bits instead of bytes
>>> shouldn't be a huge problem either. Maybe it gets a bit more verbose in
>>> case you can't satisfy a request with one batched entropy block and have
>>> to consume randomness from two.

For example, here's a simple bit-buffer implementation that wraps around
a get_random_long.  The bitbuffer is of the form "00001xxxx", where the
x bits are valid, and the position of the msbit indicates how many bits
are valid.

extern unsigned long get_random_long();
static unsigned long bitbuffer = 1;	/* Holds 0..BITS_PER_LONG-1 bits */
unsigned long get_random_bits(unsigned char bits)
{
	/* We handle bits == BITS_PER_LONG,and not bits == 0 */
	unsigned long mask = -1ul >> (BITS_PER_LONG - bits);
	unsigned long val;

	if (bitbuffer > mask) {
		/* Request can be satisfied out of the bit buffer */
		val = bitbuffer;
		bitbuffer >>= bits;
	} else {
		/*
		 * Not enough bits, but enough room in bitbuffer for the
		 * leftovers.  avail < bits, so avail + 64 <= bits + 63.
		 */
		val = get_random_long();
		bitbuffer = bitbuffer << (BITS_PER_LONG - bits)
			| val >> 1 >> (bits-1);
	}
	return val & mask;
}

> When we hit the chacha20 without doing a reseed we only mutate the
> state of chacha, but being an invertible function in its own, a
> proposal would be to mix parts of the chacha20 output back into the
> state, which, as a result, would cause slowdown because we couldn't
> propagate the complete output of the cipher back to the caller (looking
> at the function _extract_crng).

Basically, yes.  Half of the output goes to rekeying itself.

But, I just realized I've been overlooking something glaringly obvious...
there's no reason you can't compute multple blocks in advance.

The standard assumption in antibacktracking is that you'll *notice* the
state capture and stop trusting the random numbers afterward; you just
want the output *before* to be secure.  In other words, cops busting
down the door can't find the session key used in the message you just sent.

So you can compute and store random numbers ahead of need.

This can amortize the antibacktracking as much as you'd like.

For example, suppose we gave each CPU a small pool to minimize locking.
When one runs out and calls the global refill, it could refill *all*
of the CPU pools.  (You don't even need locking; there may be a race to
determine *which* random numbers the reader sees, but they're equally
good either way.)

> Or are you referring that the anti-backtrack protection should happen
> in every call from get_random_int?

If you ask for anti-backtracking without qualification, that's the
goal, since you don't know how long will elapse until the next call.  

It's like fsync().  There are lots of more limited forms of "keep my
data safe in case of a crash", but the most basic one is "if we lost
power the very instant the call returned, the data would be safe."
