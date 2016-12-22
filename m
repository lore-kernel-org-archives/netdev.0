From: Andy Lutomirski <luto@kernel.org>
Subject: George's crazy full state idea (Re: HalfSipHash Acceptable Usage)
Date: Wed, 21 Dec 2016 18:07:56 -0800
Message-ID: <CALCETrVn1tWBQx-RCSqCQ2ZcB6hPdioaV52q8vY+Mz1fRKsUXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Ted Ts'o" <tytso@mit.edu>, Andi Kleen <ak@linux.intel.com>,
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
        Vegard Nossum <vegard.nossum@gmail.com>
To: George Spelvin <linux@sciencehorizons.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 21, 2016 at 5:13 PM, George Spelvin
<linux@sciencehorizons.net> wrote:
> As a separate message, to disentangle the threads, I'd like to
> talk about get_random_long().
>
> After some thinking, I still like the "state-preserving" construct
> that's equivalent to the current MD5 code.  Yes, we could just do
> siphash(current_cpu || per_cpu_counter, global_key), but it's nice to
> preserve a bit more.
>
> It requires library support from the SipHash code to return the full
> SipHash state, but I hope that's a fair thing to ask for.

I don't even think it needs that.  This is just adding a
non-destructive final operation, right?

>
> Here's my current straw man design for comment.  It's very similar to
> the current MD5-based design, but feeds all the seed material in the
> "correct" way, as opposed to Xring directly into the MD5 state.
>
> * Each CPU has a (Half)SipHash state vector,
>   "unsigned long get_random_int_hash[4]".  Unlike the current
>   MD5 code, we take care to initialize it to an asymmetric state.
>
> * There's a global 256-bit random_int_secret (which we could
>   reseed periodically).
>
> To generate a random number:
> * If get_random_int_hash is all-zero, seed it with fresh a half-sized
>   SipHash key and the appropriate XOR constants.
> * Generate three words of random_get_entropy(), jiffies, and current->pid.
>   (This is arbitary seed material, copied from the current code.)
> * Crank through that with (Half)SipHash-1-0.
> * Crank through the random_int_secret with (Half)SipHash-1-0.
> * Return v1 ^ v3.

Just to clarify, if we replace SipHash with a black box, I think this
effectively means, where "entropy" is random_get_entropy() || jiffies
|| current->pid:

The first call returns H(random seed || entropy_0 || secret).  The
second call returns H(random seed || entropy_0 || secret || entropy_1
|| secret).  Etc.

If not, then I have a fairly strong preference to keep whatever
construction we come up with consistent with something that could
actually happen with invocations of unmodified SipHash -- then all the
security analysis on SipHash goes through.

Anyway, I have mixed thoughts about the construction.  It manages to
have a wide state at essentially no cost, which buys us quite a bit of
work factor to break it.  Even with full knowledge of the state, an
output doesn't reveal the entropy except to the extent that it can be
brute-force (this is just whatever the appropriate extended version of
first preimage resistance gives us).  The one thing I don't like is
that I don't see how to prove that you can't run it backwards if you
manage to acquire a memory dump.  In fact, I that that there exist, at
least in theory, hash functions that are secure in the random oracle
model but that *can* be run backwards given the full state.  From
memory, SHA-3 has exactly that property, and it would be a bit sad for
a CSPRNG to be reversible.

We could also periodically mix in a big (128-bit?) chunk of fresh
urandom output to keep the bad guys guessing.

(P.S.  This kind of resembles the duplex sponge construction.  If
hardware SHA-3 ever shows up, a duplex sponge RNG might nice indeed.)
