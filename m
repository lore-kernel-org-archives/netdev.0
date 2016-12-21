From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: HalfSipHash Acceptable Usage
Date: 21 Dec 2016 01:34:12 -0500
Message-ID: <20161221063412.6425.qmail@ns.sciencehorizons.net>
References: <1482298164.8944.8.camel@edumazet-glaptop3.roam.corp.google.com>
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
        djb@cr.yp.to, ebiggers3@gmail.com, hannes@stressinduktion.org,
        Jason@zx2c4.com, jeanphilippe.aumasson@gmail.com,
        kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, luto@amacapital.net,
        netdev@vger.kernel.org, tom@herbertland.com,
        torvalds@linux-foundation.org, tytso@mit.edu,
        vegard.nossum@gmail.com
To: eric.dumazet@gmail.com, linux@sciencehorizons.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482298164.8944.8.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> On Tue, 2016-12-20 at 22:28 -0500, George Spelvin wrote:
>> Cycles per byte on 1024 bytes of data:
>> 			Pentium	Core 2	Ivy
>> 			4	Duo	Bridge
>> SipHash-2-4		38.9	 8.3	 5.8
>> HalfSipHash-2-4	12.7	 4.5	 3.2
>> MD5			 8.3	 5.7	 4.7
>
> So definitely not faster.
> 
> 38 cycles per byte is a problem, considering IPV6 is ramping up.

As I said earlier, SipHash performance on 32-bit x86 really sucks,
because it wants an absolute minimum of 9 32-bit registers (8 for the
state plus one temporary for the rotates), and x86 has 7.

> What about SHA performance (syncookies) on P4 ?

I recompiled with -mtune=pentium4 and re-ran.  MD5 time went *up* by
0.3 cycles/byte, HalfSipHash went down by 1 cycle, and SipHash didn't
change:

Cycles per byte on 1024 bytes of data:
		Pentium	Core 2	Ivy
		4	Duo	Bridge
SipHash-2-4	38.9	 8.3	 5.8
HalfSipHash-2-4	11.5	 4.5	 3.2
MD5		 8.6	 5.7	 4.7
SHA-1		19.0	 8.0	 6.8

(This is with a verbatim copy of the lib/sha1.c code; I might be
able to optimize it with some asm hackery.)

Anyway, you see why we were looking longingly at HalfSipHash.


In fact, I have an idea.  Allow me to make the following concrete
suggestion for using HalfSipHash with 128 bits of key material:

- 64 bits are used as the key.
- The other 64 bits are used as an IV which is prepended to
  the message to be hashed.

As a matter of practical implementation, we precompute the effect
of hashing the IV and store the 128-bit HalfSipHash state, which
is used just like a 128-bit key.

Because of the way it is constructed, it is obviously no weaker than
standard HalfSipHash's 64-bit security claim.

I don't know the security of this, and it's almost certainly weaker than
128 bits, but I *hope* it's at least a few bits stronger than 64 bits.
80 would be enough to dissuade any attacker without a six-figure budget
(that's per attack, not a one-time capital investment).  96 would be
ample for our purposes.

What I do know is that it makes a brute-force attack without
significant cryptanalytic effort impossible.

To match the spec exactly, we'd need to add the 8-byte IV length to
the length byte which pads the final block, but from a security point
of view, it does not matter.  As long as we are consistent within any
single key, any unique mapping between padding byte and message length
(mod 256) is equally good.

We may choose based on implementation convenience.

(Also note my earlier comments about when it is okay to omit the padding
length byte entirely: any time all the data to be hashed with a given
key is fixed in format or self-delimiting (e.g. null-terminated).
This applies to many of the networking uses.)
