From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: 16 Dec 2016 15:41:28 -0500
Message-ID: <20161216204128.25034.qmail@ns.sciencehorizons.net>
References: <CALx6S351VFRZmEQphRQy6YtmZYPnOtTN7=XiNrJmhWJGv4HUBg@mail.gmail.com>
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
        djb@cr.yp.to, ebiggers3@gmail.com, hannes@stressinduktion.org,
        jeanphilippe.aumasson@gmail.com,
        kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux@sciencehorizons.net,
        luto@amacapital.net, netdev@vger.kernel.org,
        torvalds@linux-foundation.org, tytso@mit.edu,
        vegard.nossum@gmail.com
To: Jason@zx2c4.com, tom@herbertland.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CALx6S351VFRZmEQphRQy6YtmZYPnOtTN7=XiNrJmhWJGv4HUBg@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tom Herbert wrote:
> Tested this. Distribution and avalanche effect are still good. Speed
> wise I see about a 33% improvement over siphash (20 nsecs/op versus 32
> nsecs). That's about 3x of jhash speed (7 nsecs). So that might closer
> to a more palatable replacement for jhash. Do we lose any security
> advantages with halfsiphash?

What are you testing on?  And what input size?  And does "33% improvement"
mean 4/3 the rate and 3/4 the time?  Or 2/3 the time and 3/2 the rate?

These are very odd results.  On a 64-bit machine, SipHash should be the
same speed per round, and faster because it hashes more data per round.
(Unless you're hitting some unexpected cache/decode effect due to REX
prefixes.)

On a 32-bit machine (other than ARM, where your results might make sense,
or maybe if you're hashing large amounts of data), the difference should
be larger.

And yes, there is a *significant* security loss.  SipHash is 128 bits
("don't worry about it").  hsiphash is 64 bits, which is known breakable
("worry about it"), so we have to do a careful analysis of the cost of
a successful attack.

As mentioned in the e-mails that just flew by, hsiphash is intended
*only* for 32-bit machines which bog down on full SipHash.  On all 64-bit
machines, it will be implemented as an alias for SipHash and the security
concerns will Just Go Away.

The place where hsiphash is expected to make a big difference is 32-bit
x86.  If you only see 33% difference with "gcc -m32", I'm going to be
very confused.
