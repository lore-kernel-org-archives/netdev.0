From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v7 3/6] random: use SipHash in place of MD5
Date: Thu, 22 Dec 2016 03:49:39 +0100
Message-ID: <CAHmME9phg=GuhEUaMxxv_=RexffPDqrOEhmaKffy_ZSt7bfC7g@mail.gmail.com>
References: <20161216030328.11602-1-Jason@zx2c4.com> <20161221230216.25341-1-Jason@zx2c4.com>
 <20161221230216.25341-4-Jason@zx2c4.com> <CALCETrVttVoZMvCYZcrAqM1c=YQP_nCfdfO1MsrSHjvjTFxH+A@mail.gmail.com>
 <17bd0c70-d2c1-165b-f5b2-252dfca404e8@stressinduktion.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@amacapital.net>, Netdev <netdev@vger.kernel.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, LKML <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, David Laight <David.Laight@aculab.com>,
	Ted Tso <tytso@mit.edu>, Eric Dumazet <edumazet@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>, Eric Biggers <ebiggers3@gmail.com>,
	Tom Herbert <tom@herbertland.com>, Andi Kleen <ak@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <kernel-hardening-return-5767-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <17bd0c70-d2c1-165b-f5b2-252dfca404e8@stressinduktion.org>
List-Id: netdev.vger.kernel.org

Hi Andy & Hannes,

On Thu, Dec 22, 2016 at 3:07 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> I wonder if Ted's proposal was analyzed further in terms of performance
> if get_random_int should provide cprng alike properties?
>
> For reference: https://lkml.org/lkml/2016/12/14/351
>
> The proposal made sense to me and would completely solve the above
> mentioned problem on the cost of repeatedly reseeding from the crng.

On Thu, Dec 22, 2016 at 3:09 AM, Andy Lutomirski <luto@amacapital.net> wrote:
> Unless I've misunderstood it, Ted's proposal causes get_random_int()
> to return bytes straight from urandom (effectively), which should make
> it very strong.  And if urandom is competitively fast now, I don't see
> the problem.  ChaCha20 is designed for speed, after all.

Funny -- while you guys were sending this back & forth, I was writing
my reply to Andy which essentially arrives at the same conclusion.
Given that we're all arriving to the same thing, and that Ted shot in
this direction long before we all did, I'm leaning toward abandoning
SipHash for the de-MD5-ification of get_random_int/long, and working
on polishing Ted's idea into something shiny for this patchset.

I did have two objections to this. The first was that my SipHash
construction is faster. But in any case, they're both faster than the
current MD5, so it's just extra rice. The second, and the more
important one, was that batching entropy up like this means that 32
calls will be really fast, and then the 33rd will be slow, since it
has to do a whole ChaCha round, because get_random_bytes must be
called to refill the batch. Since get_random_long is called for every
process startup, I didn't really like there being inconsistent
performance on process startup. And I'm pretty sure that one ChaCha
whole block is slower than computing MD5, even though it lasts 32
times as long, though I need to measure this. But maybe that's dumb in
the end? Are these concerns that should point us toward the
determinism (and speed) of SipHash? Are these concerns that don't
matter and so we should roll with the simplicity of reusing ChaCha?

Jason
