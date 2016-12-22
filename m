From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: George's crazy full state idea (Re: HalfSipHash Acceptable Usage)
Date: 22 Dec 2016 03:02:16 -0500
Message-ID: <20161222080216.15157.qmail@ns.sciencehorizons.net>
References: <CALCETrU84-EeU91AkoAZLWrhK=FSrBgV139oSSM-Vw5Mc0mdAg@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
  djb@cr.yp.to, ebiggers3@gmail.com, eric.dumazet@gmail.com,
  hannes@stressinduktion.org, Jason@zx2c4.com,
  jeanphilippe.aumasson@gmail.com, kernel-hardening@lists.openwall.com,
  linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, luto@kernel.org,
  netdev@vger.kernel.org, tom@herbertland.com, torvalds@linux-foundation.org,
  tytso@mit.edu, vegard.nossum@gmail.com
To: linux@sciencehorizons.net, luto@amacapital.net
Return-path: <kernel-hardening-return-5775-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CALCETrU84-EeU91AkoAZLWrhK=FSrBgV139oSSM-Vw5Mc0mdAg@mail.gmail.com>
List-Id: netdev.vger.kernel.org

> True, but it's called get_random_int(), and it seems like making it
> stronger, especially if the performance cost is low to zero, is a good
> thing.

If it's cheap enough, I don't mind.  But it's documented as being
marginal-quality, used where speed is more important.

In particular, it's *not* used for key material; only values that matter
only as long as they are in use.  Whule they're in use, they can't be
concealed from an attacker with kernel access, and when they're dne
being used, they're worthless.

>> If you want anti-backtracking, though, it's easy to add.  What we
>> hash is:
>>
>> entropy_0 || secret || output_0 || entropy_1 || secret || output_1 || ...
>>
>> You mix the output word right back in to the (unfinalized) state after
>> generating it.  This is still equivalent to unmodified back-box SipHash,
>> you're just using a (conceptually independent) SipHash invocation to
>> produce some of its input.

> Ah, cute.  This could probably be sped up by doing something like:
>
> entropy_0 || secret || output_0 ^ entropy_1 || secret || ...

I'm disinclined to do that because that requires deferring the mixing
until the *next* time you generate something.  Storing the value you
don't want revealed by a state capture defeats the purpose.

I'd rather mix it in immediately, so you have anti-backtracking from
the moment of creation.

Also, I don't think it's particularly "cute" or clever; mixing output back
in is the standard way all antibacktracking is accomplished.  It's how
the Davies-Meyer hash construction makes a reversible function one-way.

(There is a second way to do it by throwing away state, but that's
expensive in seed entropy.)

> It's a little weak because the output is only 64 bits, so you could
> plausibly backtrack it on a GPU or FPGA cluster or on an ASIC if the
> old entropy is guessable.  I suspect there are sneaky ways around it
> like using output_n-1 ^ output_n-2 or similar.  I'll sleep on it.

Ah, yes, I see.  Given the final state, you guess the output word, go
back one round, then forward the finalization rounds.   Is the output
equal to the guessed output?  You'll find the true value, plus
Poisson(1 - 2^-64) additional.  (Since you have 2^64-1 chances at
something with probability 1 in 2^64.)

And this can be iterated as often as you like to get earlier output words,
as long as you can guess the entropy.  *That's* the part that hurts;
you'd like something that peters out.

You could use the double-length-output SipHash variant (which requires
a second set of finalization rounds) and mix more output back, but
that's expensive.

The challenge is coming up with more unpredictable data to mix in than one
invocation of SipHash returns.  And without storing previous output
anywhere, because that is exactly wrong.

A running sum or xor or whatever of the outputs doesn't help, because
once you've guessed the last output, you can backtrack that for no
additional effort.

State capture is incredibly difficult, our application doesn't require
resistance anyway... unless you can think of something cheap, I think
we can just live with this.

>> I'd *like* to persuade you that skipping the padding byte wouldn't
>> invalidate any security proofs, because it's true and would simplify
>> the code.  But if you want 100% stock, I'm willing to cater to that.

> I lean toward stock in the absence of a particularly good reason.  At
> the very least I'd want to read that paper carefully.

Er... adding the length is standard Merkle-Damgaard strengthening.
Why you do this is described in the original papers by Merkle and Damgaard.

The lay summary is at
https://en.wikipedia.org/wiki/Merkle-Damgard_construction

The original sources are:
http://www.merkle.com/papers/Thesis1979.pdf
http://saluc.engr.uconn.edu/refs/algorithms/hashalg/damgard89adesign.pdf

Merkle describes the construction; Damgaard proves it secure.  Basically,
appending the length is required to handle variable-length input if the
input is not itself self-delimiting.

The proof of security is theorem 3.1 in the latter.  (The first, more
detailed explanation involves the use of an extra bit, which the second
then explains how todo without.)

In particular, see the top of page 420, which notes that the security
proof only requires encoding *how much padding is added* in the final
block, not the overall length of the message, and the second remark on
p. 421 which notes that no such suffix is required if it's not necessary
to distinguish messages with different numbers of trailing null bytes.

The rules are alluded to in the "Choice of padding rule" part of the
"Rationale" section of the SipHash paper (p. 7), but the description is
very brief because it assumes the reader has the background.

That's why they say "We could have chosen a slightly simpler padding rule,
such as appending a <tt>80</tt> byte followed by zeroes."

The thing is, if the amount of the last block that is used is fixed
(within the domain of a particular key), you don't need to encode this
information at all.
