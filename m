From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: Fri, 16 Dec 2016 21:49:49 +0100
Message-ID: <CAHmME9q0LaxQ3uinzWyD1mDCpyeLw_2TEAN33T6dDrTKCuHs7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andi Kleen <ak@linux.intel.com>,
        David Miller <davem@davemloft.net>,
        David Laight <David.Laight@aculab.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Eric Biggers <ebiggers3@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        kernel-hardening@lists.openwall.com,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Netdev <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Vegard Nossum <vegard.nossum@gmail.com>
To: George Spelvin <linux@sciencehorizons.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 16, 2016 at 9:17 PM, George Spelvin
<linux@sciencehorizons.net> wrote:
> My (speaking enerally; I should walk through every hash table you've
> converted) opinion is that:
>
> - Hash tables, even network-facing ones, can all use hsiphash as long
>   as an attacker can only see collisions, i.e. ((H(x) ^ H(y)) & bits) ==
>   0, and the consequences of a successful attack is only more collisions
>   (timing).  While the attack is only 2x the cost (two hashes rather than
>   one to test a key), the knowledge of the collision is statistical,
>   especially for network attackers, which raises the cost of guessing
>   beyond an even more brute-force attack.
> - When the hash value directly visible (e.g. included in a network
>   packet), full SipHash should be the default.
> - Syncookies *could* use hsiphash, especially as there are
>   two keys in there.  Not sure if we need the performance.
> - For TCP ISNs, I'd prefer to use full SipHash.  I know this is
>   a very hot path, and if that's a performance bottleneck,
>   we can work harder on it.
>
> In particular, TCP ISNs *used* to rotate the key periodically,
> limiting the time available to an attacker to perform an
> attack before the secret goes stale and is useless.  commit
> 6e5714eaf77d79ae1c8b47e3e040ff5411b717ec upgraded to md5 and dropped
> the key rotation.

While I generally agree with this analysis for the most part, I do
think we should use SipHash and not HalfSipHash for syncookies.
Although the security risk is lower than with sequence numbers, it
previously used full MD5 for this, which means performance is not
generally a bottleneck and we'll get massive speedups no matter what,
whether using SipHash or HalfSipHash. In addition, using SipHash means
that the 128-bit key gives a larger margin and can be safe longterm.
So, I think we should err on the side of caution and stick with
SipHash in all cases in which we're upgrading from MD5.

In other words, only current jhash users should be potentially
eligible for hsiphash.


> Current code uses a 64 ns tick for the ISN, so it counts 2^24 per second.
> (32 bits wraps every 4.6 minutes.)  A 4-bit counter and 28-bit hash
> (or even 3+29) would work as long as the key is regenerated no more
> than once per minute.  (Just using the 4.6-minute ISN wrap time is the
> obvious simple implementation.)
>
> (Of course, I defer to DaveM's judgement on all network-related issues.)

I saw that jiffies addition in there and was wondering what it was all
about. It's currently added _after_ the siphash input, not before, to
keep with how the old algorithm worked. I'm not sure if this is
correct or if there's something wrong with that, as I haven't studied
how it works. If that jiffies should be part of the siphash input and
not added to the result, please tell me. Otherwise I'll keep things
how they are to avoid breaking something that seems to be working.
