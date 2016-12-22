From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v7 3/6] random: use SipHash in place of MD5
Date: Thu, 22 Dec 2016 03:31:56 +0100
Message-ID: <CAHmME9pVKWkGxAj3=g59D=-z=03O6UMrkxYeyjQGXigc0r9Kag@mail.gmail.com>
References: <20161216030328.11602-1-Jason@zx2c4.com> <20161221230216.25341-1-Jason@zx2c4.com>
 <20161221230216.25341-4-Jason@zx2c4.com> <CALCETrVttVoZMvCYZcrAqM1c=YQP_nCfdfO1MsrSHjvjTFxH+A@mail.gmail.com>
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
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <kernel-hardening-return-5765-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CALCETrVttVoZMvCYZcrAqM1c=YQP_nCfdfO1MsrSHjvjTFxH+A@mail.gmail.com>
List-Id: netdev.vger.kernel.org

Hi Andy,

On Thu, Dec 22, 2016 at 12:42 AM, Andy Lutomirski <luto@amacapital.net> wrote:
> So this is probably good enough, and making it better is hard.  Changing it to:
>
> u64 entropy = (u64)random_get_entropy() + current->pid;
> result = siphash(..., entropy, ...);
> secret->chaining += result + entropy;
>
> would reduce this problem by forcing an attacker to brute-force the
> entropy on each iteration, which is probably an improvement.

Ahh, so that's the reasoning behind a similar suggestion of yours in a
previous email. Makes sense to me. I'll include this in the next merge
if we don't come up with a different idea before then. Your reasoning
seems good for it.

Part of what makes this process a bit goofy is that it's not all
together clear what the design goals are. Right now we're going for
"not worse than before", which we've nearly achieved. How good of an
RNG do we want? I'm willing to examine and analyze the security and
performance of all constructions we can come up with. One thing I
don't want to do, however, is start tweaking the primitives themselves
in ways not endorsed by the designers. So, I believe that precludes
things like carrying over SipHash's internal state (like what was done
with MD5), because there hasn't been a formal security analysis of
this like there has with other uses of SipHash. I also don't want to
change any internals of how SipHash actually works. I mention that
because of some of the suggestions on other threads, which make me
rather uneasy.

So with that said, while writing this reply to you, I was
simultaneously reading some other crypto code and was reminded that
there's a variant of SipHash which outputs an additional 64-bits; it's
part of the siphash reference code, which they call the "128-bit
mode". It has the benefit that we can return 64-bits to the caller and
save 64-bits for the chaining key. That way there's no correlation
between the returned secret and the chaining key, which I think would
completely alleviate all of your concerns, and simplify the analysis a
bit.

Here's what it looks like:
https://git.zx2c4.com/linux-dev/commit/?h=siphash&id=46fbe5b408e66b2d16b4447860f8083480e1c08d

The downside is that it takes 4 extra Sip rounds. This puts the
performance still better than MD5, though, and likely still better
than the other batched entropy solution. We could optimize this, I
suppose, by giving it only two parameters -- chaining,
jiffies+entropy+pid -- instead of the current three -- chaining,
jiffies, entropy+pid -- which would then shave off 2 Sip rounds. But I
liked the idea of having a bit more spread in the entropy input field.

Anyway, with this in mind, we now have three possibilities:

1. result = siphash(chaining, entropy, key); chaining += result + entropy
2. result = siphash_extra_output(chaining, entropy, key, &chaining);
3. Ted's batched entropy idea using chacha20

The more I think about this, the more I suspect that we should just
use chacha20. It will still be faster than MD5. I don't like the
non-determinism of it (some processes will start slower than others,
if the batched entropy has run out and ASLR demands more), but I guess
I can live with that. But, most importantly, it greatly simplifies
both the security analysis and what we can promise to callers about
the function. Right now in the comment documentation, we're coy with
callers about the security of the RNG. If we moved to a known
construction like chacha20/get_random_bytes_batched, then we could
just be straight up with a promise that the numbers it returns are
high quality.

Thoughts on 2 and 3, and on 1 vs 2 vs 3?

Jason
