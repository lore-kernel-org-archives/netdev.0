From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: [kernel-hardening] Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: 16 Dec 2016 17:41:33 -0500
Message-ID: <20161216224133.27460.qmail@ns.sciencehorizons.net>
References: <CAHmME9qPx3WUHF3__3wNOXr-AUti4WPO1qDiFus3Zr133FyV1g@mail.gmail.com>
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
        djb@cr.yp.to, ebiggers3@gmail.com, hannes@stressinduktion.org,
        jeanphilippe.aumasson@gmail.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux@sciencehorizons.net,
        luto@amacapital.net, netdev@vger.kernel.org, tom@herbertland.com,
        torvalds@linux-foundation.org, tytso@mit.edu,
        vegard.nossum@gmail.com
To: Jason@zx2c4.com, kernel-hardening@lists.openwall.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CAHmME9qPx3WUHF3__3wNOXr-AUti4WPO1qDiFus3Zr133FyV1g@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

An idea I had which mght be useful:

You could perhaps save two rounds in siphash_*u64.

The final word with the length (called "b" in your implementation)
only needs to be there if the input is variable-sized.

If every use of a given key is of a fixed-size input, you don't need
a length suffix.  When the input is an even number of words, that can
save you two rounds.

This requires an audit of callers (e.g. you have to use different
keys for IPv4 and IPv6 ISNs), but can save time.

(This is crypto 101; search "MD-strengthening" or see the remark on
p. 101 on Damgaard's 1989 paper "A design principle for hash functions" at
http://saluc.engr.uconn.edu/refs/algorithms/hashalg/damgard89adesign.pdf
but I'm sure that Ted, Jean-Philippe, and/or DJB will confirm if you'd
like.)

Jason A. Donenfeld wrote:
> Oh, okay, that is exactly what I thought was going on. I just thought
> you were implying that jiffies could be moved inside the hash, which
> then confused my understanding of how things should be. In any case,
> thanks for the explanation.

No, the rekeying procedure is cleverer.

The thing is, all that matters is that the ISN increments fast enough,
but not wrap too soon.

It *is* permitted to change the random base, as long as it only
increases, and slower than the timestamp does.

So what you do is every few minutes, you increment the high 4 bits of the
random base and change the key used to generate the low 28 bits.

The base used for any particular host might change from 0x10000000
to 0x2fffffff, or from 0x1fffffff to 0x20000000, but either way, it's
increasing, and not too fast.

This has the downside that an attacker can see 4 bits of the base,
so only needs to send send 2^28 = 256 MB to flood the connection,
but the upside that the key used to generate the low bits changes
faster than it can be broken.
