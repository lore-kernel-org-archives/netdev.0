From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: HalfSipHash Acceptable Usage
Date: 20 Dec 2016 22:28:29 -0500
Message-ID: <20161221032829.3031.qmail@ns.sciencehorizons.net>
References: <1482278145.1521.46.camel@edumazet-glaptop3.roam.corp.google.com>
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
        djb@cr.yp.to, ebiggers3@gmail.com, hannes@stressinduktion.org,
        Jason@zx2c4.com, jeanphilippe.aumasson@gmail.com,
        kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux@sciencehorizons.net,
        luto@amacapital.net, netdev@vger.kernel.org, tom@herbertland.com,
        torvalds@linux-foundation.org, vegard.nossum@gmail.com
To: eric.dumazet@gmail.com, tytso@mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.sciencehorizons.net ([71.41.210.147]:44945 "HELO
        ns.sciencehorizons.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1756942AbcLUD2b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 22:28:31 -0500
In-Reply-To: <1482278145.1521.46.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I do not see why SipHash, if faster than MD5 and more secure, would be a
> problem.

Because on 32-bit x86, it's slower.

Cycles per byte on 1024 bytes of data:
			Pentium	Core 2	Ivy
			4	Duo	Bridge
SipHash-2-4		38.9	 8.3	 5.8
HalfSipHash-2-4		12.7	 4.5	 3.2
MD5			 8.3	 5.7	 4.7

SipHash is more parallelizable and runs faster on superscalar processors,
but MD5 is optimized for 2000-era processors, and is faster on them than
HalfSipHash even.

Now, in the applications we care about, we're hashing short blocks, and
SipHash has the advantage that it can hash less than 64 bytes.  But it
also pays a penalty on short blocks for the finalization, equivalent to
two words (16 bytes) of input.

It turns out that on both Ivy Bridge and Core 2 Duo, the crossover happens
between 23 (SipHash is faster) and 24 (MD5 is faster) bytes of input.

This is assuming you're adding the 1 byte of length padding to SipHash's
input, so 24 bytes pads to 4 64-bit words, which makes 2*4+4 = 12 rounds,
vs. one block for MD5.  (MD5 takes a similar jump between 55 and 56 bytes.)

On a P4, SipHash is *never* faster; it takes 2.5x longer than MD5 on a
12-byte block (an IPv4 address/port pair).

This is why there was discussion of using HalfSipHash on these machines.
(On a P4, the HalfSipHash/MD5 crossover is somewhere between 24 and 31
bytes; I haven't benchmarked every possible size.)
