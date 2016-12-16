From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v6 3/5] random: use SipHash in place of MD5
Date: Fri, 16 Dec 2016 22:45:16 +0100
Message-ID: <CAHmME9rbKi3O1SS89LRMEUeMdKyrdutXAfjb9QmW3KNoCuE-wg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        David Laight <David.Laight@aculab.com>,
        Ted Tso <tytso@mit.edu>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        George Spelvin <linux@sciencehorizons.net>,
        Vegard Nossum <vegard.nossum@gmail.com>,
        Andi Kleen <ak@linux.intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andy,

On Fri, Dec 16, 2016 at 10:31 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> I think it would be nice to try to strenghen the PRNG construction.
> FWIW, I'm not an expert in PRNGs, and there's fairly extensive
> literature, but I can at least try.

In an effort to keep this patchset as initially as uncontroversial as
possible, I kept the same same construction as before and just swapped
out slow MD5 for fast Siphash. Additionally, the function
documentation says that it isn't cryptographically secure. But in the
end I certainly agree with you; we should most definitely improve
things, and seeing the eyeballs now on this series, I think we now
might have a mandate to do so.

> 1. A one-time leak of memory contents doesn't ruin security until
> reboot.  This is especially value across suspend and/or hibernation.

Ted and I were discussing this in another thread, and it sounds like
he wants the same thing. I'll add re-generation of the secret every
once in a while. Perhaps time-based makes more sense than
counter-based for rekeying frequency?

> 2. An attack with a low work factor (2^64?) shouldn't break the scheme
> until reboot.

It won't. The key is 128-bits.

> This is effectively doing:
>
> output = H(prev_output, weak "entropy", per-boot secret);
>
> One unfortunately downside is that, if used in a context where an
> attacker can see a single output, the attacker learns the chaining
> value.  If the attacker can guess the entropy, then, with 2^64 work,
> they learn the secret, and they can predict future outputs.

No, the secret is 128-bits, which isn't feasibly guessable. The secret
also isn't part of the hash, but rather is the generator of the hash
function. A keyed hash (a PRF) is a bit of a different construction
than just hashing a secret value into a hash function.

> Second, change the mode so that an attacker doesn't learn so much
> internal state.  For example:
>
> output = H(old_chain, entropy, secret);
> new_chain = old_chain + entropy + output;

Happy to make this change, with making the chaining value additive
rather than a replacement.

However, I'm not sure adding entropy to the new_chain makes a
different. That entropy is basically just the cycle count plus the
jiffies count. If an attacker can already guess them, then adding them
again to the chaining value doesn't really add much.

Jason
