From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: George's crazy full state idea (Re: HalfSipHash Acceptable Usage)
Date: Wed, 21 Dec 2016 21:42:45 -0800
Message-ID: <CALCETrU84-EeU91AkoAZLWrhK=FSrBgV139oSSM-Vw5Mc0mdAg@mail.gmail.com>
References: <CALCETrVn1tWBQx-RCSqCQ2ZcB6hPdioaV52q8vY+Mz1fRKsUXA@mail.gmail.com>
 <20161222050138.12011.qmail@ns.sciencehorizons.net>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161222050138.12011.qmail@ns.sciencehorizons.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 21, 2016 at 9:01 PM, George Spelvin
<linux@sciencehorizons.net> wrote:
> Andy Lutomirski wrote:
>> I don't even think it needs that.  This is just adding a
>> non-destructive final operation, right?
>
> It is, but the problem is that SipHash is intended for *small* inputs,
> so the standard implementations aren't broken into init/update/final
> functions.
>
> There's just one big function that keeps the state variables in
> registers and never stores them anywhere.
>
> If we *had* init/update/final functions, then it would be trivial.
>
>> Just to clarify, if we replace SipHash with a black box, I think this
>> effectively means, where "entropy" is random_get_entropy() || jiffies
>> || current->pid:
>
>> The first call returns H(random seed || entropy_0 || secret).  The
>> second call returns H(random seed || entropy_0 || secret || entropy_1
>> || secret).  Etc.
>
> Basically, yes.  I was skipping the padding byte and keying the
> finalization rounds on the grounds of "can't hurt and might help",
> but we could do it a more standard way.
>
>> If not, then I have a fairly strong preference to keep whatever
>> construction we come up with consistent with something that could
>> actually happen with invocations of unmodified SipHash -- then all the
>> security analysis on SipHash goes through.
>
> Okay.  I don't think it makes a difference, but it's not a *big* waste
> of time.  If we have finalization rounds, we can reduce the secret
> to 128 bits.
>
> If we include the padding byte, we can do one of two things:
> 1) Make the secret 184 bits, to fill up the final partial word as
>    much as possible, or
> 2) Make the entropy 1 byte smaller and conceptually misalign the
>    secret.  What we'd actually do is remove the last byte of
>    the secret and include it in the entropy words, but that's
>    just a rotation of the secret between storage and hashing.
>
> Also, I assume you'd like SipHash-2-4, since you want to rely
> on a security analysis.

I haven't looked, but I assume that the analysis at least thought
about reduced rounds, so maybe other variants are okay.

>> The one thing I don't like is
>> that I don't see how to prove that you can't run it backwards if you
>> manage to acquire a memory dump.  In fact, I that that there exist, at
>> least in theory, hash functions that are secure in the random oracle
>> model but that *can* be run backwards given the full state.  From
>> memory, SHA-3 has exactly that property, and it would be a bit sad for
>> a CSPRNG to be reversible.
>
> Er...  get_random_int() is specifically *not* designed to be resistant
> to state capture, and I didn't try.  Remember, what it's used for
> is ASLR, what we're worried about is somene learning the layouts
> of still-running processes, and and if you get a memory dump, you have
> the memory layout!

True, but it's called get_random_int(), and it seems like making it
stronger, especially if the performance cost is low to zero, is a good
thing.

>
> If you want anti-backtracking, though, it's easy to add.  What we
> hash is:
>
> entropy_0 || secret || output_0 || entropy_1 || secret || output_1 || ...
>
> You mix the output word right back in to the (unfinalized) state after
> generating it.  This is still equivalent to unmodified back-box SipHash,
> you're just using a (conceptually independent) SipHash invocation to
> produce some of its input.

Ah, cute.  This could probably be sped up by doing something like:

entropy_0 || secret || output_0 ^ entropy_1 || secret || ...

It's a little weak because the output is only 64 bits, so you could
plausibly backtrack it on a GPU or FPGA cluster or on an ASIC if the
old entropy is guessable.  I suspect there are sneaky ways around it
like using output_n-1 ^ output_n-2 or similar.  I'll sleep on it.

>
> The only remaining issues are:
> 1) How many rounds, and
> 2) May we use HalfSipHash?

I haven't looked closely enough to have a real opinion here.  I don't
know what the security margin is believed to be.

>
> I'd *like* to persuade you that skipping the padding byte wouldn't
> invalidate any security proofs, because it's true and would simplify
> the code.  But if you want 100% stock, I'm willing to cater to that.

I lean toward stock in the absence of a particularly good reason.  At
the very least I'd want to read that paper carefully.

>
> Ted, what do you think?



-- 
Andy Lutomirski
AMA Capital Management, LLC
