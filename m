From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: George's crazy full state idea (Re: HalfSipHash Acceptable Usage)
Date: Thu, 22 Dec 2016 08:09:54 -0800
Message-ID: <CALCETrUSM7KDNuVqh169241PNumJVOF5hrNQUq=k5Fnet6nSgA@mail.gmail.com>
References: <CALCETrVn1tWBQx-RCSqCQ2ZcB6hPdioaV52q8vY+Mz1fRKsUXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: George Spelvin <linux@sciencehorizons.net>,
        "Ted Ts'o" <tytso@mit.edu>, Andi Kleen <ak@linux.intel.com>,
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
        Linus Torvalds <torvalds@linux-foundation.or
To: Andy Lutomirski <luto@kernel.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CALCETrVn1tWBQx-RCSqCQ2ZcB6hPdioaV52q8vY+Mz1fRKsUXA@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 21, 2016 at 6:07 PM, Andy Lutomirski <luto@kernel.org> wrote:
> On Wed, Dec 21, 2016 at 5:13 PM, George Spelvin
> <linux@sciencehorizons.net> wrote:
>> As a separate message, to disentangle the threads, I'd like to
>> talk about get_random_long().
>>
>> After some thinking, I still like the "state-preserving" construct
>> that's equivalent to the current MD5 code.  Yes, we could just do
>> siphash(current_cpu || per_cpu_counter, global_key), but it's nice to
>> preserve a bit more.
>>
>> It requires library support from the SipHash code to return the full
>> SipHash state, but I hope that's a fair thing to ask for.
>
> I don't even think it needs that.  This is just adding a
> non-destructive final operation, right?
>
>>
>> Here's my current straw man design for comment.  It's very similar to
>> the current MD5-based design, but feeds all the seed material in the
>> "correct" way, as opposed to Xring directly into the MD5 state.
>>
>> * Each CPU has a (Half)SipHash state vector,
>>   "unsigned long get_random_int_hash[4]".  Unlike the current
>>   MD5 code, we take care to initialize it to an asymmetric state.
>>
>> * There's a global 256-bit random_int_secret (which we could
>>   reseed periodically).
>>
>> To generate a random number:
>> * If get_random_int_hash is all-zero, seed it with fresh a half-sized
>>   SipHash key and the appropriate XOR constants.
>> * Generate three words of random_get_entropy(), jiffies, and current->pid.
>>   (This is arbitary seed material, copied from the current code.)
>> * Crank through that with (Half)SipHash-1-0.
>> * Crank through the random_int_secret with (Half)SipHash-1-0.
>> * Return v1 ^ v3.
>
> Just to clarify, if we replace SipHash with a black box, I think this
> effectively means, where "entropy" is random_get_entropy() || jiffies
> || current->pid:
>
> The first call returns H(random seed || entropy_0 || secret).  The
> second call returns H(random seed || entropy_0 || secret || entropy_1
> || secret).  Etc.

Having slept on this, I like it less.  The problem is that a
backtracking attacker doesn't just learn H(random seed || entropy_0 ||
secret || ...) -- they learn the internal state of the hash function
that generates that value.  This probably breaks any attempt to apply
security properties of the hash function.  For example, the internal
state could easily contain a whole bunch of prior outputs it in
verbatim.

--Andy
