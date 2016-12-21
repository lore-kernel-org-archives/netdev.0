From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v7 3/6] random: use SipHash in place of MD5
Date: Wed, 21 Dec 2016 15:42:38 -0800
Message-ID: <CALCETrVttVoZMvCYZcrAqM1c=YQP_nCfdfO1MsrSHjvjTFxH+A@mail.gmail.com>
References: <20161216030328.11602-1-Jason@zx2c4.com> <20161221230216.25341-1-Jason@zx2c4.com>
 <20161221230216.25341-4-Jason@zx2c4.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, LKML <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, David Laight <David.Laight@aculab.com>,
	Ted Tso <tytso@mit.edu>, Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>, Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Biggers <ebiggers3@gmail.com>, Tom Herbert <tom@herbertland.com>,
	Andi Kleen <ak@linux.intel.com>, "David S. Miller" <davem@davemloft.net>,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <kernel-hardening-return-5755-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161221230216.25341-4-Jason@zx2c4.com>
List-Id: netdev.vger.kernel.org

On Wed, Dec 21, 2016 at 3:02 PM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
>  unsigned int get_random_int(void)
>  {
> -       __u32 *hash;
> -       unsigned int ret;
> -
> -       if (arch_get_random_int(&ret))
> -               return ret;
> -
> -       hash = get_cpu_var(get_random_int_hash);
> -
> -       hash[0] += current->pid + jiffies + random_get_entropy();
> -       md5_transform(hash, random_int_secret);
> -       ret = hash[0];
> -       put_cpu_var(get_random_int_hash);
> -
> -       return ret;
> +       unsigned int arch_result;
> +       u64 result;
> +       struct random_int_secret *secret;
> +
> +       if (arch_get_random_int(&arch_result))
> +               return arch_result;
> +
> +       secret = get_random_int_secret();
> +       result = siphash_3u64(secret->chaining, jiffies,
> +                             (u64)random_get_entropy() + current->pid,
> +                             secret->secret);
> +       secret->chaining += result;
> +       put_cpu_var(secret);
> +       return result;
>  }
>  EXPORT_SYMBOL(get_random_int);

Hmm.  I haven't tried to prove anything for real.  But here goes (in
the random oracle model):

Suppose I'm an attacker and I don't know the secret or the chaining
value.  Then, regardless of what the entropy is, I can't predict the
numbers.

Now suppose I do know the secret and the chaining value due to some
leak.  If I want to deduce prior outputs, I think I'm stuck: I'd need
to find a value "result" such that prev_chaining + result = chaining
and result = H(prev_chaining, ..., secret);.  I don't think this can
be done efficiently in the random oracle model regardless of what the
"..." is.

But, if I know the secret and chaining value, I can predict the next
output assuming I can guess the entropy.  What's worse is that, even
if I can't guess the entropy, if I *observe* the next output then I
can calculate the next chaining value.

So this is probably good enough, and making it better is hard.  Changing it to:

u64 entropy = (u64)random_get_entropy() + current->pid;
result = siphash(..., entropy, ...);
secret->chaining += result + entropy;

would reduce this problem by forcing an attacker to brute-force the
entropy on each iteration, which is probably an improvement.

To fully fix it, something like "catastrophic reseeding" would be
needed, but that's hard to get right.

(An aside: on x86 at least, using two percpu variables is faster
because directly percpu access is essentially free, whereas getting
the address of a percpu variable is not free.)
