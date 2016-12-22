From: Andy Lutomirski <luto@kernel.org>
Subject: Re: George's crazy full state idea (Re: HalfSipHash Acceptable Usage)
Date: Thu, 22 Dec 2016 11:32:03 -0800
Message-ID: <CALCETrW63gL1821jCMvxnm8gR+o5ifdOXKnWHsLnqoFK77-epw@mail.gmail.com>
References: <CALCETrUSM7KDNuVqh169241PNumJVOF5hrNQUq=k5Fnet6nSgA@mail.gmail.com>
 <20161222192445.963.qmail@ns.sciencehorizons.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Lutomirski <luto@kernel.org>,
        Andi Kleen <ak@linux.intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        David Laight <David.Laight@aculab.com>,
        "D. J. Bernstein" <djb@cr.yp.to>,
        Eric Biggers <ebiggers3@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "Ted Ts'o" <tytso@mit.e
To: George Spelvin <linux@sciencehorizons.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20161222192445.963.qmail@ns.sciencehorizons.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 22, 2016 at 11:24 AM, George Spelvin
<linux@sciencehorizons.net> wrote:
>> Having slept on this, I like it less.  The problem is that a
>> backtracking attacker doesn't just learn H(random seed || entropy_0 ||
>> secret || ...) -- they learn the internal state of the hash function
>> that generates that value.  This probably breaks any attempt to apply
>> security properties of the hash function.  For example, the internal
>> state could easily contain a whole bunch of prior outputs it in
>> verbatim.
>
> The problem is, anti-backtracing is in severe tension with your desire
> to use unmodified SipHash.
>
> First of all, I'd like to repeat that it isn't a design goal of the current
> generator and isn't necessary.

Agreed.

> Now, the main point:  it's not likely to be solvable.
>
> The problem with unmodified SipHash is that is has only 64 bits of
> output.  No mix-back mechanism can get around the fundamental problem
> that that's too small to prevent a brute-force guessing attack.  You need
> wider mix-back.  And getting more output from unmodified SipHash requires
> more finalization rounds, which is expensive.

It could only mix the output back in every two calls, in which case
you can backtrack up to one call but you need to do 2^128 work to
backtrack farther.  But yes, this is getting excessively complicated.

> Finally, your discomfort about an attacker learning the internal state...
> if an attacker knows the key and the input, they can construct the
> internal state.  Yes, we could discard the internal state and construct
> a fresh one on the next call to get_random_int, but what are you going
> to key it with?  What are you going to feed it?  What keeps *that*
> internal state any more secret from an attacker than one that's explicitly
> stored?

I do tend to like Ted's version in which we use batched
get_random_bytes() output.  If it's fast enough, it's simpler and lets
us get the full strength of a CSPRNG.

(Aside: some day I want to move all that code from drivers/ to lib/
and teach it to be buildable in userspace, too, so it's easy to play
with it, feed it test vectors, confirm that it's equivalent to a
reference implementation, write up the actual design and try to get
real cryptographers to analyze it, etc.)

> For example, clearly stating the concern over starting new processes
> with predictable layout, and the limits on the fresh entropy supply,
> has made me realize that there *is* a possible source: each exec()
> is passed 128 bits from get_random_bytes in the AT_RANDOM element of
> its auxv.  Since get_random_int() accesses "current" anyway, we could
> store some seed material there rather than using "pid".  While this is
> not fresh for each call to get_random_int, it *is* fresh for each new
> address space whose layout is being randomized.

Hmm, interesting.  Although, for ASLR, we could use get_random_bytes()
directly and be done with it.  It won't be a bottleneck.
