From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: HalfSipHash Acceptable Usage
Date: 20 Dec 2016 18:07:52 -0500
Message-ID: <20161220230752.31049.qmail@ns.sciencehorizons.net>
References: <20161220213636.tiqj2o4uupasr4aj@thunk.org>
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
        djb@cr.yp.to, ebiggers3@gmail.com, hannes@stressinduktion.org,
        jeanphilippe.aumasson@gmail.com,
        kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux@sciencehorizons.net,
        luto@amacapital.net, netdev@vger.kernel.org, tom@herbertland.com,
        torvalds@linux-foundation.org, vegard.nossum@gmail.com
To: Jason@zx2c4.com, tytso@mit.edu
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20161220213636.tiqj2o4uupasr4aj@thunk.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Theodore Ts'o wrote:
> On Mon, Dec 19, 2016 at 06:32:44PM +0100, Jason A. Donenfeld wrote:
>> 1) Anything that requires actual long-term security will use
>> SipHash2-4, with the 64-bit output and the 128-bit key. This includes
>> things like TCP sequence numbers. This seems pretty uncontroversial to
>> me. Seem okay to you?

> Um, why do TCP sequence numbers need long-term security?  So long as
> you rekey every 5 minutes or so, TCP sequence numbers don't need any
> more security than that, since even if you break the key used to
> generate initial sequence numbers seven a minute or two later, any
> pending TCP connections will have timed out long before.
> 
> See the security analysis done in RFC 6528[1], where among other
> things, it points out why MD5 is acceptable with periodic rekeying,
> although there is the concern that this could break certain hueristics
> used when establishing new connections during the TIME-WAIT state.

Because we don't rekey TCP sequence numbers, ever.  See commit
6e5714eaf77d79ae1c8b47e3e040ff5411b717ec

To rekey them requires dividing the sequence number base into a "random"
part and some "generation" msbits.  While we can do better than the
previous 8+24 split (I'd suggest 4+28 or 3+29), only 2 is tricks, and
1 generation bit isn't enough.

So while it helps in the long term, it reduces the security offered by
the random part in the short term.  (If I know 4 bits of your ISN,
I only need to send 256 MB to hit your TCP window.)

At the time, I objected, and suggested doing two hashes, with a fixed
32-bit base plus a split rekeyed portion, but that was vetoed on the
grounds of performance.

On further consideration, the fixed base doesn't help much.
(Details below for anyone that cares.)



Suppose we let the TCP initial sequence number be:

(Hash(<srcIP,dstIP,srcPort,dstPort>, fixed_key) & 0xffffffff) +
(i << 28) + (Hash(<srcIP,dstIP,srcPort,dstPort>, key[i]) & 0x0fffffff) +
(current_time_in_nanoseconds / 64)

It's not hugely difficult to mount an effective attack against a
64-bit fixed_key.

As an attacker, I can ask the target to send me these numbers for dstPort
values i control and other values I know.  I can (with high probability)
detect the large jumps when the generation changes, so I can make a
significant number of queries with the same generation.  After 23-ish
queries, I have enough information to identify a 64-bit fixed_key.

I don't know the current generation counter "i", but I know it's the
same for all my queries, so for any two queries, the maximum difference
between the 28-bit hash values is 29 bits.  (We can also add a small
margin to allow for timeing uncertainty, but that's even less.)

So if I guess a fixed key, hash my known plaintexts with that guess,
subtract the ciphertexts from the observed sequence numbers, and the
difference between the remaining (unknown) 28-bit hash values plus
timestamps exceeds what's possible, my guess is wrong.

I can then repeat with additional known plaintexts, reducing the space
of admissible keys by about 3 bits each time.

Assuming I can rent GPU horsepower from a bitcoin miner to do this in a
reasonable period of time, after 22 known plaintext differences, I have
uniquely identified the key.

Of course, in practice I'd do is a first pass with maybe 6 plaintexts
on the GPU, and then deal with the candidates found in a second pass.
But either way, it's about 2.3 SipHash evaluations per key tested.
As I noted earlier, a bitcoin blockchain block, worth 25 bitcoins,
currently costs 2^71 evaluations of SHA-2 (2^70 evaluations of double
SHA-2), and that's accomplished every 10 minutes, this is definitely
practical.
