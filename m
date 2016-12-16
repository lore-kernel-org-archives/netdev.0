From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: Re: [PATCH v5 1/4] siphash: add
 cryptographically secure PRF
Date: Fri, 16 Dec 2016 22:01:10 +0100
Message-ID: <CAHmME9pz=syTiLXUsbXFyGdbGK6pxbnU+TVLDkbYiTa-9+sckQ@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: kernel-hardening@lists.openwall.com, "Theodore Ts'o" <tytso@mit.edu>,
	George Spelvin <linux@sciencehorizons.net>, Jason <Jason@zx2c4.com>,
	Andi Kleen <ak@linux.intel.com>, David Miller <davem@davemloft.net>,
	David Laight <David.Laight@aculab.com>, "Daniel J . Bernstein" <djb@cr.yp.to>,
	Eric Biggers <ebiggers3@gmail.com>, Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Andy Lutomirski <luto@amacapital.net>, Netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>, Linus Torvalds <torvalds@linux-foundation.org>,
	Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <kernel-hardening-return-5660-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
List-Id: netdev.vger.kernel.org

Hi Ted,

On Fri, Dec 16, 2016 at 9:43 PM, Theodore Ts'o <tytso@mit.edu> wrote:
> What should we do with get_random_int() and get_random_long()?  In
> some cases it's being used in performance sensitive areas, and where
> anti-DoS protection might be enough.  In others, maybe not so much.
>
> If we rekeyed the secret used by get_random_int() and
> get_random_long() frequently (say, every minute or every 5 minutes),
> would that be sufficient for current and future users of these
> interfaces?

get_random_int() and get_random_long() should quite clearly use
SipHash with its secure 128-bit key and not HalfSipHash with its
64-bit key. HalfSipHash is absolutely insufficient for this use case.
Remember, we're already an order of magnitude or more faster than
md5...

With regard to periodic rekeying... since the secret is 128-bits, I
believe this is likely sufficient for _not_ rekeying. There's also the
chaining variable, to tie together invocations of the function. If
you'd prefer, instead of the chaining variable, we could use some
siphash output to mutate the original key, but I don't think this
approach is actually better and might introduce vulnerabilities. In my
opinion chaining+128bitkey is sufficient. On the other hand, rekeying
every X minutes is 3 or 4 lines of code. If you want (just say so),
I'll add this to my next revision.

You asked about the security requirements of these functions. The
comment says they're not cryptographically secure. And right now with
MD5 they're not. So the expectations are pretty low. Moving to siphash
adds some cryptographic security, certainly. Moving to siphash plus
rekeying adds a bit more. Of course, on recent x86, RDRAND is used
instead, so the cryptographic strength then depends on the thickness
of your tinfoil hat. So probably we shouldn't change what we advertise
these functions provide, even though we're certainly improving them
performance-wise and security-wise.

> P.S.  I'll note that my performance figures when testing changes to
> get_random_int() were done on a 32-bit x86; Jason, I'm guessing your
> figures were using a 64-bit x86 system?.  I haven't tried 32-bit ARM
> or smaller CPU's (e.g., mips, et. al.) that might be more likely to be
> used on IoT devices, but I'm worried about those too, of course.

Yes, on x86-64. But on i386 chacha20 incurs nearly the same kind of
slowdown as siphash, so I expect the comparison to be more or less
equal. There's another thing I really didn't like about your chacha20
approach which is that it uses the /dev/urandom pool, which means
various things need to kick in in the background to refill this.
Additionally, having to refill the buffered chacha output every 32 or
so longs isn't nice. These things together make for inconsistent and
hard to understand general operating system performance, because
get_random_long is called at every process startup for ASLR. So, in
the end, I believe there's another reason for going with the siphash
approach: deterministic performance.

Jason
