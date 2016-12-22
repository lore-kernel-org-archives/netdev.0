From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v7 3/6] random: use SipHash in place of MD5
Date: Thu, 22 Dec 2016 04:12:23 +0100
Message-ID: <CAHmME9oM-96LsS2U3KA0Ys7SrXh9qZJ91ORe1Yd9-bmG5uee2g@mail.gmail.com>
References: <20161216030328.11602-1-Jason@zx2c4.com> <20161221230216.25341-1-Jason@zx2c4.com>
 <20161221230216.25341-4-Jason@zx2c4.com> <CALCETrVttVoZMvCYZcrAqM1c=YQP_nCfdfO1MsrSHjvjTFxH+A@mail.gmail.com>
 <17bd0c70-d2c1-165b-f5b2-252dfca404e8@stressinduktion.org> <CAHmME9phg=GuhEUaMxxv_=RexffPDqrOEhmaKffy_ZSt7bfC7g@mail.gmail.com>
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
Return-path: <kernel-hardening-return-5768-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAHmME9phg=GuhEUaMxxv_=RexffPDqrOEhmaKffy_ZSt7bfC7g@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Thu, Dec 22, 2016 at 3:49 AM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
> I did have two objections to this. The first was that my SipHash
> construction is faster. But in any case, they're both faster than the
> current MD5, so it's just extra rice. The second, and the more
> important one, was that batching entropy up like this means that 32
> calls will be really fast, and then the 33rd will be slow, since it
> has to do a whole ChaCha round, because get_random_bytes must be
> called to refill the batch. Since get_random_long is called for every
> process startup, I didn't really like there being inconsistent
> performance on process startup. And I'm pretty sure that one ChaCha
> whole block is slower than computing MD5, even though it lasts 32
> times as long, though I need to measure this. But maybe that's dumb in
> the end? Are these concerns that should point us toward the
> determinism (and speed) of SipHash? Are these concerns that don't
> matter and so we should roll with the simplicity of reusing ChaCha?

I ran some measurements in order to quantify what I'm talking about.
Repeatedly running md5_transform is about 2.3 times faster than
repeatedly running extract_crng. What does this mean?

One call to extract_crng gives us 32 times as many longs as one call
to md5_transform. This means that spread over 32 process creations,
chacha will be 13.9 times faster. However, every 32nd process will
take 2.3 times as long to generate its ASLR value as it would with the
old md5_transform code.

Personally, I don't think that 2.3 is a big deal. And I really like
how much this simplifies the analysis.
But if it's a big deal to you, then we can continue to discuss my
SipHash construction, which gives faster and more consistent
performance, at the cost of a more complicated and probably less
impressive security analysis.

Jason
