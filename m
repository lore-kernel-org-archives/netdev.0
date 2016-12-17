From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: Re: [PATCH v5 1/4] siphash: add
 cryptographically secure PRF
Date: Sat, 17 Dec 2016 10:41:52 -0500
Message-ID: <20161217154152.5oug7mzb4tmfknwv@thunk.org>
References: <CAHmME9r4YNqNSZ-KXAHtJN_vm+eL1tSoC-6muHaFUN6fWhkO2g@mail.gmail.com>
 <20161217021503.32767.qmail@ns.sciencehorizons.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason@zx2c4.com, linux@sciencehorizons.net, ak@linux.intel.com,
	davem@davemloft.net, David.Laight@aculab.com, djb@cr.yp.to,
	ebiggers3@gmail.com, hannes@stressinduktion.org,
	jeanphilippe.aumasson@gmail.com, linux-crypto@vger.kernel.org,
	linux-kernel@vger.kernel.org, luto@amacapital.net,
	netdev@vger.kernel.org, tom@herbertland.com,
	torvalds@linux-foundation.org, vegard.nossum@gmail.com
To: kernel-hardening@lists.openwall.com
Return-path: <kernel-hardening-return-5692-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Content-Disposition: inline
In-Reply-To: <20161217021503.32767.qmail@ns.sciencehorizons.net>
List-Id: netdev.vger.kernel.org

On Fri, Dec 16, 2016 at 09:15:03PM -0500, George Spelvin wrote:
> >> - Ted, Andy Lutorminski and I will try to figure out a construction of
> >>   get_random_long() that we all like.

We don't have to find the most optimal solution right away; we can
approach this incrementally, after all.

So long as we replace get_random_{long,int}() with something which is
(a) strictly better in terms of security given today's use of MD5, and
(b) which is strictly *faster* than the current construction on 32-bit
and 64-bit systems, we can do that, and can try to make it be faster
while maintaining some minimum level of security which is sufficient
for all current users of get_random_{long,int}() and which can be
clearly artificulated for future users of get_random_{long,int}().

The main worry at this point I have is benchmarking siphash on a
32-bit system.  It may be that simply batching the chacha20 output so
that we're using the urandom construction more efficiently is the
better way to go, since that *does* meet the criteron of strictly more
secure and strictly faster than the current MD5 solution.  I'm open to
using siphash, but I want to see the the 32-bit numbers first.

As far as half-siphash is concerned, it occurs to me that the main
problem will be those users who need to guarantee that output can't be
guessed over a long period of time.  For example, if you have a
long-running process, then the output needs to remain unguessable over
potentially months or years, or else you might be weakening the ASLR
protections.  If on the other hand, the hash table or the process will
be going away in a matter of seconds or minutes, the requirements with
respect to cryptographic strength go down significantly.

Now, maybe this doesn't matter that much if we can guarantee (or make
assumptions) that the attacker doesn't have unlimited access the
output stream of get_random_{long,int}(), or if it's being used in an
anti-DOS use case where it ultimately only needs to be harder than
alternate ways of attacking the system.

Rekeying every five minutes doesn't necessarily help the with respect
to ASLR, but it might reduce the amount of the output stream that
would be available to the attacker in order to be able to attack the
get_random_{long,int}() generator, and it also reduces the value of
doing that attack to only compromising the ASLR for those processes
started within that five minute window.

Cheers,

						- Ted

P.S.  I'm using ASLR as an example use case, above; of course we will
need to make similar eximainations of the other uses of
get_random_{long,int}().

P.P.S.  We might also want to think about potentially defining
get_random_{long,int}() to be unambiguously strong, and then creating
a get_weak_random_{long,int}() which on platforms where performance
might be a consideration, it uses a weaker algorithm perhaps with some
kind of rekeying interval.
