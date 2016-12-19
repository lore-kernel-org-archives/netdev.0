From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [kernel-hardening] Re: [PATCH v5 1/4] siphash: add
 cryptographically secure PRF
Date: Mon, 19 Dec 2016 18:21:43 +0100
Message-ID: <CAHmME9o1yLfFY66joO3Vjb6Z7BZfG+VJV4yuydBJe7YgcD3tgA@mail.gmail.com>
References: <CAHmME9r4YNqNSZ-KXAHtJN_vm+eL1tSoC-6muHaFUN6fWhkO2g@mail.gmail.com>
 <20161217021503.32767.qmail@ns.sciencehorizons.net> <20161217154152.5oug7mzb4tmfknwv@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "Theodore Ts'o" <tytso@mit.edu>,
        kernel-hardening@lists.openwall.com, Jason <Jason@zx2c4.com>,
        George Spelvin <linux@sciencehorizons.net>,
        Andi Kleen <ak@linux.intel.com>,
        David Miller <davem@davemloft.net>,
        David Laight <David.Laight@aculab.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Eric Biggers <ebiggers3@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Netdev <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:50329 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758298AbcLSRVu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Dec 2016 12:21:50 -0500
In-Reply-To: <20161217154152.5oug7mzb4tmfknwv@thunk.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ted,

On Sat, Dec 17, 2016 at 4:41 PM, Theodore Ts'o <tytso@mit.edu> wrote:
> On Fri, Dec 16, 2016 at 09:15:03PM -0500, George Spelvin wrote:
>> >> - Ted, Andy Lutorminski and I will try to figure out a construction of
>> >>   get_random_long() that we all like.
>
> We don't have to find the most optimal solution right away; we can
> approach this incrementally, after all.

Thanks to your call for moderation. This is the impression I have too.
And with all the back and forth of these threads, I fear nothing will
get done. I'm going to collect the best ideas amongst all of these,
and try to get it merged. Then after that we can incrementally improve
on it.

David Miller -- would you merge something into your 4.11 tree? Seems
like you might be the guy for this, since the changes primarily affect
net/*.

Latest patches are here:
https://git.zx2c4.com/linux-dev/log/?h=siphash


> So long as we replace get_random_{long,int}() with something which is
> (a) strictly better in terms of security given today's use of MD5, and
> (b) which is strictly *faster* than the current construction on 32-bit
> and 64-bit systems, we can do that, and can try to make it be faster
> while maintaining some minimum level of security which is sufficient
> for all current users of get_random_{long,int}() and which can be
> clearly artificulated for future users of get_random_{long,int}().
>
> The main worry at this point I have is benchmarking siphash on a
> 32-bit system.  It may be that simply batching the chacha20 output so
> that we're using the urandom construction more efficiently is the
> better way to go, since that *does* meet the criteron of strictly more
> secure and strictly faster than the current MD5 solution.  I'm open to
> using siphash, but I want to see the the 32-bit numbers first.

Sure, I'll run some benchmarks and report back.

> As far as half-siphash is concerned, it occurs to me that the main
> problem will be those users who need to guarantee that output can't be
> guessed over a long period of time.  For example, if you have a
> long-running process, then the output needs to remain unguessable over
> potentially months or years, or else you might be weakening the ASLR
> protections.  If on the other hand, the hash table or the process will
> be going away in a matter of seconds or minutes, the requirements with
> respect to cryptographic strength go down significantly.
>
> Now, maybe this doesn't matter that much if we can guarantee (or make
> assumptions) that the attacker doesn't have unlimited access the
> output stream of get_random_{long,int}(), or if it's being used in an
> anti-DOS use case where it ultimately only needs to be harder than
> alternate ways of attacking the system.

The only acceptable usage of HalfSipHash is for hash table lookups
where top security isn't actually a goal. I'm still a bit queasy about
going with it, but George S has very aggressively been pursuing a
"save every last cycle" agenda, which makes sense given how
performance sensitive certain hash tables are, and so I suspect this
could be an okay compromise between performance and security. But,
only for hash tables. Certainly not for the RNG.

>
> Rekeying every five minutes doesn't necessarily help the with respect
> to ASLR, but it might reduce the amount of the output stream that
> would be available to the attacker in order to be able to attack the
> get_random_{long,int}() generator, and it also reduces the value of
> doing that attack to only compromising the ASLR for those processes
> started within that five minute window.

The current implemention of get_random_int/long in my branch uses
128-bit key siphash, so the chances of compromising the key are pretty
much nil. The periodic rekeying is to protect against direct-ram
attacks or other kernel exploits -- a concern brought up by Andy.

With siphash, which takes a 128-bit key, if you got an RNG output once
every picosecond, I believe it would take approximately 10^19 years...

Jason
