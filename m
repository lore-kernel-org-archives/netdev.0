From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v2 1/4] siphash: add cryptographically secure hashtable function
Date: Wed, 14 Dec 2016 14:10:33 +0100
Message-ID: <CAHmME9qA6qKdp+qoih2Je4fxU+4E6=Gp7CVfhYU7VbOr6HJ=0Q@mail.gmail.com>
References: <20161214035927.30004-1-Jason@zx2c4.com> <516c5633-14c2-ee18-90e4-84d73870ba2c@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        kernel-hardening@lists.openwall.com,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <516c5633-14c2-ee18-90e4-84d73870ba2c@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Hannes,

On Wed, Dec 14, 2016 at 12:21 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Can you show or cite benchmarks in comparison with jhash? Last time I
> looked, especially for short inputs, siphash didn't beat jhash (also on
> all the 32 bit devices etc.).

I assume that jhash is likely faster than siphash, but I wouldn't be
surprised if with optimization we can make siphash at least pretty
close on 64-bit platforms. (I'll do some tests though; maybe I'm wrong
and jhash is already slower.)

With that said, siphash is here to replace uses of jhash where
hashtable poisoning vulnerabilities make it necessary. Where there's
no significant security improvement, if there's no speed improvement
either, then of course nothing's going to change.

I should have mentioned md5_transform in this first message too, as
two other patches in this series actually replace md5_transform usage
with siphash. I think in this case, siphash is a clear performance
winner (and security winner) over md5_transform. So if the push back
against replacing jhash usages is just too high, at the very least it
remains useful already for the md5_transform usage.


> This pretty much depends on the linearity of the hash function? I don't
> think a crypto secure hash function is needed for a hash table. Albeit I
> agree that siphash certainly looks good to be used here.

In order to prevent the aforementioned poisoning attacks, a PRF with
perfect linearity is required, which is what's achieved when it's a
cryptographically secure one. Check out section 7 of
https://131002.net/siphash/siphash.pdf .

> I am pretty sure that SipHash still needs a random key per hash table
> also. So far it was only the choice of hash function you are questioning.

Siphash needs a random secret key, yes. The point is that the hash
function remains secure so long as the secret key is kept secret.
Other functions can't make the same guarantee, and so nervous periodic
key rotation is necessary, but in most cases nothing is done, and so
things just leak over time.


> Hmm, I tried to follow up with all the HashDoS work and so far didn't
> see any HashDoS attacks against the Jenkins/SpookyHash family.
>
> If this is an issue we might need to also put those changes into stable.

jhash just isn't secure; it's not a cryptographically secure PRF. If
there hasn't already been an academic paper put out there about it
this year, let's make this thread 1000 messages long to garner
attention, and next year perhaps we'll see one. No doubt that
motivated government organizations, defense contractors, criminals,
and other netizens have already done research in private. Replacing
insecure functions with secure functions is usually a good thing.

Jason
