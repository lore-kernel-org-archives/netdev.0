From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: George's crazy full state idea (Re: HalfSipHash Acceptable Usage)
Date: 22 Dec 2016 00:01:38 -0500
Message-ID: <20161222050138.12011.qmail@ns.sciencehorizons.net>
References: <CALCETrVn1tWBQx-RCSqCQ2ZcB6hPdioaV52q8vY+Mz1fRKsUXA@mail.gmail.com>
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
        djb@cr.yp.to, ebiggers3@gmail.com, eric.dumazet@gmail.com,
        hannes@stressinduktion.org, Jason@zx2c4.com,
        jeanphilippe.aumasson@gmail.com,
        kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        tom@herbertland.com, torvalds@linux-foundation.org, tytso@mit.edu,
        vegard.nossum@gmail.com
To: linux@sciencehorizons.net, luto@kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CALCETrVn1tWBQx-RCSqCQ2ZcB6hPdioaV52q8vY+Mz1fRKsUXA@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Lutomirski wrote:
> I don't even think it needs that.  This is just adding a
> non-destructive final operation, right?

It is, but the problem is that SipHash is intended for *small* inputs,
so the standard implementations aren't broken into init/update/final
functions.

There's just one big function that keeps the state variables in
registers and never stores them anywhere.

If we *had* init/update/final functions, then it would be trivial.

> Just to clarify, if we replace SipHash with a black box, I think this
> effectively means, where "entropy" is random_get_entropy() || jiffies
> || current->pid:

> The first call returns H(random seed || entropy_0 || secret).  The
> second call returns H(random seed || entropy_0 || secret || entropy_1
> || secret).  Etc.

Basically, yes.  I was skipping the padding byte and keying the
finalization rounds on the grounds of "can't hurt and might help",
but we could do it a more standard way.

> If not, then I have a fairly strong preference to keep whatever
> construction we come up with consistent with something that could
> actually happen with invocations of unmodified SipHash -- then all the
> security analysis on SipHash goes through.

Okay.  I don't think it makes a difference, but it's not a *big* waste
of time.  If we have finalization rounds, we can reduce the secret
to 128 bits.

If we include the padding byte, we can do one of two things:
1) Make the secret 184 bits, to fill up the final partial word as
   much as possible, or
2) Make the entropy 1 byte smaller and conceptually misalign the
   secret.  What we'd actually do is remove the last byte of
   the secret and include it in the entropy words, but that's
   just a rotation of the secret between storage and hashing.

Also, I assume you'd like SipHash-2-4, since you want to rely
on a security analysis.

(Regarding the padding byte, getting it right might be annoying
to do exactly.  All of the security analysis depends *only* on
its low 3 bits indicating how much of the final block is used.
As it says in the SipHash paper, they included 8 bits just because
it was easy.  But if you want it exact, it's just one more byte of
state.)

> The one thing I don't like is
> that I don't see how to prove that you can't run it backwards if you
> manage to acquire a memory dump.  In fact, I that that there exist, at
> least in theory, hash functions that are secure in the random oracle
> model but that *can* be run backwards given the full state.  From
> memory, SHA-3 has exactly that property, and it would be a bit sad for
> a CSPRNG to be reversible.

Er...  get_random_int() is specifically *not* designed to be resistant
to state capture, and I didn't try.  Remember, what it's used for
is ASLR, what we're worried about is somene learning the layouts
of still-running processes, and and if you get a memory dump, you have
the memory layout!

If you want anti-backtracking, though, it's easy to add.  What we
hash is:

entropy_0 || secret || output_0 || entropy_1 || secret || output_1 || ...

You mix the output word right back in to the (unfinalized) state after
generating it.  This is still equivalent to unmodified back-box SipHash,
you're just using a (conceptually independent) SipHash invocation to
produce some of its input.

Each output is produced by copying the state, padding & finalizing after the
secret.


In fact, to make our lives easier, let's define the secret to end with
a counter byte that happens to be equal to the padding byte.  The input
stream will be:

Previous output: 8 (or 4 for HalfSipHash) bytes
Entropy: 15 bytes (8 bytes timer, 4 bytes jiffies, 3 bytes pid)
Secret: 16 bytes
Counter: 1 byte
...repeat...

> We could also periodically mix in a big (128-bit?) chunk of fresh
> urandom output to keep the bad guys guessing.

Simpler and faster to just update the global master secret.
The state is per-CPU, so mixing in has to be repeated per CPU.


With these changes, I'm satisifed that it's secure, cheap, has a
sufficiently wide state size, *and* all standard SipHash analysis applies.

The only remaining issues are:
1) How many rounds, and
2) May we use HalfSipHash?

I'd *like* to persuade you that skipping the padding byte wouldn't
invalidate any security proofs, because it's true and would simplify
the code.  But if you want 100% stock, I'm willing to cater to that.

Ted, what do you think?
