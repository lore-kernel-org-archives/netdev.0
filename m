From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: George's crazy full state idea (Re: HalfSipHash Acceptable Usage)
Date: 28 Dec 2016 05:04:43 -0500
Message-ID: <20161228100443.18935.qmail@ns.sciencehorizons.net>
References: <1482902602.2234.1.camel@stressinduktion.org>
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
        ebiggers3@gmail.com, eric.dumazet@gmail.com, Jason@zx2c4.com,
        kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, luto@kernel.org,
        netdev@vger.kernel.org, tom@herbertland.com, tytso@mit.edu,
        vegard.nossum@gmail.com
To: daniel@iogearbox.net, hannes@stressinduktion.org,
        linux@sciencehorizons.net
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1482902602.2234.1.camel@stressinduktion.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hannes Frederic Sowa wrote:
> We call extract_crng when we run out of batched entropy and reseed. How
> often we call down to extract_crng depends on how much entropy we
> extracted by calls to get_random_int/long, so the number of calls into
> those functions matter.
> 
> In extract_crng we have a timer which reseeds every 300s the CPRNG and
> either uses completely new entropy from the CRNG or calls down into the
> CPRNG while also doing backtracing protection (which feeds chacha's
> block size / 2 back into chacha, if I read the code correctly, thus
> 1024 bits, which should be enough).

In the current code, _extract_crng checks to see if more than 300 s
have elapsed since last time it was reseeded, and if so, reseeds with
fresh entropy.

In addition, on every read (or get_random_bytes), if the request leaves
enough ranfom bits in the last ChaCha block, it feeds back 256 bits
(the ChaCha block size is 16*32 = 512 bits) for anti-backtracking.

If the last read happened to not fit under that limit (size % 512 >
256), *and* there are no calls for RNG output for a long time, there is
no  upper limit to how long the old ChaCha key can hang around.

> On Fri, 2016-12-23 at 20:17 -0500, George Spelvin wrote:
>> For example, two mix-backs of 64 bits gives you 65 bit security, not 128.
>> (Because each mixback can be guessed and verified separately.)

> Exactly, but the full reseed after running out of entropy is strong
> enough to not be defeated by your argumentation. Neither the reseed
> from the CRNG.

Yes, I was just reacting to your original statement:

>>>>> couldn't we simply use 8 bytes of the 64 byte
>>>>> return block to feed it directly back into the state chacha?

It's not the idea that's bad, just the proposed quantity.


>> If you want that, I have a pile of patches to prandom I really
>> should push upstream.  Shall I refresh them and send them to you?

> I would like to have a look at them in the new year, certainly! I can
> also take care about the core prandom patches, but don't know if I have
> time to submit the others to the different subsystems.
>
> Maybe, if David would be okay with that, we can submit all patches
> through his tree, as he is also the dedicated maintainer for prandom.

Amazing, thank you very much!  They're just minor cleanups, nothing
too exciting.  I'll put it in the queue to make sure they're up to
date.
