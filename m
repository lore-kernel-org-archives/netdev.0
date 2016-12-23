From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: George's crazy full state idea (Re: HalfSipHash Acceptable
 Usage)
Date: Fri, 23 Dec 2016 13:05:24 +0100
Message-ID: <1482494724.3353.7.camel@stressinduktion.org>
References: <20161223000716.5768.qmail@ns.sciencehorizons.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
        djb@cr.yp.to, ebiggers3@gmail.com, eric.dumazet@gmail.com,
        Jason@zx2c4.com, jeanphilippe.aumasson@gmail.com,
        kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        tom@herbertland.com, torvalds@linux-foundation.org, tytso@mit.edu,
        vegard.nossum@gmail.com
To: George Spelvin <linux@sciencehorizons.net>, luto@kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20161223000716.5768.qmail@ns.sciencehorizons.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-12-22 at 19:07 -0500, George Spelvin wrote:
> Hannes Frederic Sowa wrote:
> > A lockdep test should still be done. ;)
> 
> Adding might_lock() annotations will improve coverage a lot.

Might be hard to find the correct lock we take later down the code
path, but if that is possible, certainly.

> > Yes, that does look nice indeed. Accounting for bits instead of bytes
> > shouldn't be a huge problem either. Maybe it gets a bit more verbose in
> > case you can't satisfy a request with one batched entropy block and have
> > to consume randomness from two.
> 
> The bit granularity is also for the callers' convenience, so they don't
> have to mask again.  Whether get_random_bits rounds up to byte boundaries
> internally or not is something else.
> 
> When the current batch runs low, I was actually thinking of throwing
> away the remaining bits and computing a new batch of 512.  But it's
> whatever works best at implementation time.
> 
> > > > It could only mix the output back in every two calls, in which case
> > > > you can backtrack up to one call but you need to do 2^128 work to
> > > > backtrack farther.  But yes, this is getting excessively complicated.
> > > No, if you're willing to accept limited backtrack, this is a perfectly
> > > acceptable solution, and not too complicated.  You could do it phase-less
> > > if you like; store the previous output, then after generating the new
> > > one, mix in both.  Then overwrite the previous output.  (But doing two
> > > rounds of a crypto primtive to avoid one conditional jump is stupid,
> > > so forget that.)
> > Can you quickly explain why we lose the backtracking capability?
> 
> Sure.  An RNG is (state[i], output[i]) = f(state[i-1]).  The goal of
> backtracking is to compute output[i], or better yet state[i-1], given
> state[i].
> 
> For example, consider an OFB or CTR mode generator.  The state is a key
> and and IV, and you encrypt the IV with the key to produce output, then
> either replace the IV with the output, or increment it.  Either way,
> since you still have the key, you can invert the transformation and
> recover the previous IV.
> 
> The standard way around this is to use the Davies-Meyer construction:
> 
> IV[i] = IV[i-1] + E(IV[i-1], key)
> 
> This is the standard way to make a non-invertible random function
> out of an invertible random permutation.
> 
> From the sum, there's no easy way to find the ciphertext *or* the
> plaintext that was encrypted.  Assuming the encryption is secure,
> the only way to reverse it is brute force: guess IV[i-1] and run the
> operation forward to see if the resultant IV[i] matches.
> 
> There are a variety of ways to organize this computation, since the
> guess gives toy both IV[i-1] and E(IV[i-1], key) = IV[i] - IV[i-1], including
> running E forward, backward, or starting from both ends to see if you
> meet in the middle.
> 
> The way you add the encryption output to the IV is not very important.
> It can be addition, xor, or some more complex invertible transformation.
> In the case of SipHash, the "encryption" output is smaller than the
> input, so we have to get a bit more creative, but it's still basically
> the same thing.
> 
> The problem is that the output which is combined with the IV is too small.
> With only 64 bits, trying all possible values is practical.  (The world's
> Bitcoin miners are collectively computing SHA-256(SHA-256(input)) 1.7 * 2^64
> times per second.)
> 
> By basically doing two iterations at once and mixing in 128 bits of
> output, the guessing attack is rendered impractical.  The only downside
> is that you need to remember and store one result between when it's
> computed and last used.  This is part of the state, so an attack can
> find output[i-1], but not anything farther back.

Thanks a lot for the explanation!

> > ChaCha as a block cipher gives a "perfect" permutation from the output
> > of either the CRNG or the CPRNG, which actually itself has backtracking
> > protection.
> 
> I'm not quite understanding.  The /dev/random implementation uses some
> of the ChaCha output as a new ChaCha key (that's another way to mix output
> back into the state) to prevent backtracking.  But this slows it down, and
> again if you want to be efficient, you're generating and storing large batches
> of entropy and storing it in the RNG state.

I was actually referring to the anti-backtrack protection in
/dev/random and also /dev/urandom, from where we reseed every 300
seconds and if our batched entropy runs low with Ted's/Jason's current
patch for get_random_int.

As far as I can understand it, backtracking is not a problem in case of
a reseed event inside extract_crng.

When we hit the chacha20 without doing a reseed we only mutate the
state of chacha, but being an invertible function in its own, a
proposal would be to mix parts of the chacha20 output back into the
state, which, as a result, would cause slowdown because we couldn't
propagate the complete output of the cipher back to the caller (looking
at the function _extract_crng).

Or are you referring that the anti-backtrack protection should happen
in every call from get_random_int?

Thanks,
Hannes
