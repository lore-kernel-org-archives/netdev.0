From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v6 3/5] random: use SipHash in place of MD5
Date: Fri, 16 Dec 2016 13:31:25 -0800
Message-ID: <CALCETrUtjq=rcXiBhmtJtL3=9i2fhUUjFsuHoPOzNvU26bY+JA@mail.gmail.com>
References: <20161215203003.31989-1-Jason@zx2c4.com> <20161216030328.11602-1-Jason@zx2c4.com>
 <20161216030328.11602-4-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-crypto@vger.kernel.org,
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
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20161216030328.11602-4-Jason@zx2c4.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 15, 2016 at 7:03 PM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
> -static DEFINE_PER_CPU(__u32 [MD5_DIGEST_WORDS], get_random_int_hash)
> -               __aligned(sizeof(unsigned long));
> +static DEFINE_PER_CPU(u64, get_random_int_chaining);
>

[...]

>  unsigned long get_random_long(void)
>  {
> -       __u32 *hash;
>         unsigned long ret;
> +       u64 *chaining;
>
>         if (arch_get_random_long(&ret))
>                 return ret;
>
> -       hash = get_cpu_var(get_random_int_hash);
> -
> -       hash[0] += current->pid + jiffies + random_get_entropy();
> -       md5_transform(hash, random_int_secret);
> -       ret = *(unsigned long *)hash;
> -       put_cpu_var(get_random_int_hash);
> -
> +       chaining = &get_cpu_var(get_random_int_chaining);
> +       ret = *chaining = siphash_3u64(*chaining, jiffies, random_get_entropy() +
> +                                      current->pid, random_int_secret);
> +       put_cpu_var(get_random_int_chaining);
>         return ret;
>  }

I think it would be nice to try to strenghen the PRNG construction.
FWIW, I'm not an expert in PRNGs, and there's fairly extensive
literature, but I can at least try.  Here are some properties I'd
like:

1. A one-time leak of memory contents doesn't ruin security until
reboot.  This is especially value across suspend and/or hibernation.

2. An attack with a low work factor (2^64?) shouldn't break the scheme
until reboot.


This is effectively doing:

output = H(prev_output, weak "entropy", per-boot secret);

One unfortunately downside is that, if used in a context where an
attacker can see a single output, the attacker learns the chaining
value.  If the attacker can guess the entropy, then, with 2^64 work,
they learn the secret, and they can predict future outputs.

I would advocate adding two types of improvements.  First, re-seed it
every now and then (every 128 calls?) by just replacing both the
chaining value and the percpu secret with fresh CSPRNG output.
Second, change the mode so that an attacker doesn't learn so much
internal state.  For example:

output = H(old_chain, entropy, secret);
new_chain = old_chain + entropy + output;

This increases the effort needed to brute-force the internal state
from 2^64 to 2^128 (barring any weaknesses in the scheme).

Also, can we not call this get_random_int()?  get_random_int() sounds
too much like get_random_bytes(), and the latter is intended to be a
real CSPRNG.  Can we call it get_weak_random_int() or similar?

--Andy
