From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v2 1/4] siphash: add cryptographically secure hashtable function
Date: Thu, 15 Dec 2016 22:25:57 +0100
Message-ID: <CAHmME9p9cf1W3vhbu=YTRY1Xt=fmE1sVqY1XPt5iQwxfCfQUOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>,
        Netdev <netdev@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 15, 2016 at 10:17 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> And I was exactly questioning this.
>
> static unsigned int inet6_hash_frag(__be32 id, const struct in6_addr *saddr,
>                                     const struct in6_addr *daddr)
> {
>         net_get_random_once(&ip6_frags.rnd, sizeof(ip6_frags.rnd));
>         return jhash_3words(ipv6_addr_hash(saddr), ipv6_addr_hash(daddr),
>                             (__force u32)id, ip6_frags.rnd);
> }

For this example, the replacement is the function entitled siphash_4u32:

 static unsigned int inet6_hash_frag(__be32 id, const struct in6_addr *saddr,
                                     const struct in6_addr *daddr)
 {
         net_get_random_once(&ip6_frags.rnd, sizeof(ip6_frags.rnd));
         return siphash_4u32(ipv6_addr_hash(saddr), ipv6_addr_hash(daddr),
                 (__force u32)id, 0, ip6_frags.rnd);
 }

And then you make ip6_frags.rnd be of type siphash_key_t. Then
everything is taken care of and works beautifully. Please see v5 of
this patchset.

> I would be interested if the compiler can actually constant-fold the
> address of the stack allocation with an simple if () or some
> __builtin_constant_p fiddeling, so we don't have this constant review
> overhead to which function we pass which data. This would also make
> this whole discussion moot.

I'll play with it to see if the compiler is capable of doing that.
Does anybody know off hand if it is or if there are other examples of
the compiler doing that?

In any case, for all current replacement of jhash_1word, jhash_2words,
jhash_3words, there's the siphash_2u32 or siphash_4u32 functions. This
covers the majority of cases.

For replacements of md5_transform, either the data is small and can
fit in siphash_Nu{32,64}, or it can be put into a struct explicitly
aligned on the stack.

For the remaining use of jhash_nwords, either siphash() can be used or
siphash_unaligned() can be used if the source is of unknown alignment.
Both functions have their alignment requirements (or lack thereof)
documented in a docbook comment.

I'll look into the constant folding to see if it actually works. If it
does, I'll use it. If not, I believe the current solution works.

How's that sound?

Jason
