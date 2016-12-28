From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: George's crazy full state idea (Re: HalfSipHash Acceptable
 Usage)
Date: Wed, 28 Dec 2016 06:23:22 +0100
Message-ID: <1482902602.2234.1.camel@stressinduktion.org>
References: <20161224011754.14207.qmail@ns.sciencehorizons.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
	ebiggers3@gmail.com, eric.dumazet@gmail.com, Jason@zx2c4.com,
	kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
	linux-kernel@vger.kernel.org, luto@kernel.org, netdev@vger.kernel.org,
	tom@herbertland.com, tytso@mit.edu, vegard.nossum@gmail.com
To: George Spelvin <linux@sciencehorizons.net>, daniel@iogearbox.net
Return-path: <kernel-hardening-return-5825-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161224011754.14207.qmail@ns.sciencehorizons.net>
List-Id: netdev.vger.kernel.org

Hello,

On Fri, 2016-12-23 at 20:17 -0500, George Spelvin wrote:
> Hannes Frederic Sowa wrote:
> > On 24.12.2016 00:39, George Spelvin wrote:
> > > We just finished discussing why 8 bytes isn't enough.  If you only
> > > feed back 8 bytes, an attacker who can do 2^64 computation can find it
> > > (by guessing and computing forward to verify the guess) and recover the
> > > previous state.  You need to feed back at least as much output as your
> > > security targete.  For /dev/urandom's ChaCha20, that's 256 bits.
> > I followed the discussion but it appeared to me that this has the
> > additional constraint of time until the next reseeding event happenes,
> > which is 300s (under the assumption that calls to get_random_int happen
> > regularly, which I expect right now). After that the existing reseeding
> > mechansim will ensure enough backtracking protection. The number of
> > bytes can easily be increased here, given that reseeding was shown to be
> > quite fast already and we produce enough output. But I am not sure if
> > this is a bit overengineered in the end?
> 
> I'm not following your description of how the time-based and call-based
> mechanisms interact, but for any mix-back, you should either do enough
> or none at all.  (Also called "catastrophic reseeding".)

We call extract_crng when we run out of batched entropy and reseed. How
often we call down to extract_crng depends on how much entropy we
extracted by calls to get_random_int/long, so the number of calls into
those functions matter.

In extract_crng we have a timer which reseeds every 300s the CPRNG and
either uses completely new entropy from the CRNG or calls down into the
CPRNG while also doing backtracing protection (which feeds chacha's
block size / 2 back into chacha, if I read the code correctly, thus
1024 bits, which should be enough).

> For example, two mix-backs of 64 bits gives you 65 bit security, not 128.
> (Because each mixback can be guessed and verified separately.)

Exactly, but the full reseed after running out of entropy is strong
enough to not be defeated by your argumentation. Neither the reseed
from the CRNG.

> > Also agreed. Given your solution below to prandom_u32, I do think it
> > might also work without the seqlock now.
> 
> It's not technically a seqlock; in particular the reader doesn't
> spin.  But the write side, and general logic is so similar it's
> a good mental model.
> 
> Basically, assume a 64-byte buffer.  The reader has gone through
> 32 bytes of it, and has 32 left, and when he reads another 8 bytes,
> has to distinguish three cases:
> 
> 1) No update; we read the old bytes and there are now 32 - 24 bytes left.
> 2) Update completed while we weren't looking.  There are now new
>    bytes in the buffer, and we took 8 leaving 64 - 8 = 56.
> 3) Update in progress at the time of the read.  We don't know if we
>    are seeing old bytes or new bytes, so we have to assume the worst
>    and not proceeed unless 32 >= 8, but assume at the end there are
>    64 - 8 = 56 new bytes left.
> 
> > I wouldn't have added a disable irqs, but given that I really like your
> > proposal, I would take it in my todo branch and submit it when net-next
> > window opens.
> 
> If you want that, I have a pile of patches to prandom I really
> should push upstream.  Shall I refresh them and send them to you?

I would like to have a look at them in the new year, certainly! I can
also take care about the core prandom patches, but don't know if I have
time to submit the others to the different subsystems.

Maybe, if David would be okay with that, we can submit all patches
through his tree, as he is also the dedicated maintainer for prandom.

> [... patch descriptions ...]

Thanks,
Hannes
