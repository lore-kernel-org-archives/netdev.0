From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH 0/2] Improve sequence number generation.
Date: 20 Aug 2011 19:39:51 -0400
Message-ID: <20110820233951.6428.qmail@science.horizon.com>
References: <20110816103028.1360.qmail@science.horizon.com>
Cc: dan@doxpara.com, gerrit@erg.abdn.ac.uk,
	herbert@gondor.hengli.com.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, w@1wt.eu
To: davem@davemloft.net, linux@horizon.com, mpm@selenic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110816103028.1360.qmail@science.horizon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Apologies if I'm obverbroad on the Cc: list.)

I've beeen concerned by the recent change to initial sequence number
generation, from a time-varying 24-bit hash of the endpoint addresses
to a fixed 32-bit hash.

First of all, my apologies that I didn't see this when it was posted
for comment August 7; I only noticed when I tried to merge some local
experiments with -stable and found a conflict in drivers/random.c.

My concern primarily is that the local secret used to compute the hashes
is generated very early in the boot sequence, before any significant
amount of entropy is accumulated.  And since it's constant for the uptime
of the machine, an attacker has a considerable length of time to find
and explot the secret value.

While the increase to 32 bits is definitely desirable, and defends
against a much less sophisticated attack, I'm concerned that this is a
case of robbing Peter to pay Paul.

Trying to improve this, I'm working in a few directions:
1) Postpone the seeding as late in the boot process as possible.
   It's quite low-overhead to generate it only when the first TCP
   connection is made, which hopefully is preceded by running
   init and at least a little bit of device driver activity.

2) Do *both*: Use a fixed 32-bit offset *plus* a time-varing one.
   They can be added together and provide the security advantages of
   both.  The only cost is having to compute two hashes per SYN.

   The main problem here is coming up with a hash function fast enough
   that computing both hashes is no slower than one MD5 invocation.

3) Extend the 24-bit time-varying hash to a 28-bit one.
   This can cause the sequence numbers to wrap in 7/8 of the time
   they would with a fixed offset, but that doesn't seem too bad.
   (That's worst case; it's a triangular distribution centered
   on 15/16.)

It's relatively easy to hash quickly with 15 64-bit registers, but doing
it with 7 32-bit registers is decidedly trickier.

I'm currently playing with a 36-round 6x32-bit variant of the SHA-3
candidate Skein.  I haven't run the genetic algorithm to select optimal
rotation constants, but they shouldn't affect the timing.
(I'm also going to ask the Skein team to look over my work.)

So far, it is notably faster than MD5 (89 ns/hash vs. 148 on a 2.5 GHz
Phenom), as well as being much smaller (383 bytes as opposed to 1951 for
the core transform).  One limitation is that it only hashes 6 32-bit
words per transform.  Thus, IPv6 would need to use two iterations,
or go back to MD5.

As mentioned, we can use a different algorithm for 64-bit processors.
Or even 32-bit ones with more registers.  So the speed problem only
exists for IPv6 on 32-bit x86.

(For example, on a 64-bit processor, two parallel MD5 tranforms
can be computed in barely more time than one.)

A few questions, all related to performance requirements:
* Should I worry about 32-bit x86 performance at all, since it's
  pretty unlikely that a 32-bit machine will be running traffic levels
  (1000+ connections/sec) where it matters?
* Should I worry about 32-bit IPv6 performance, since that's even more
  unlikely to be running heavy loads on 32-bit hardware?
* If yes, is this fast enough to be acceptable, or do I need to work
  harder to find more speed?

Willy, apparently you did some benchmarking of various hash functions.
Is that data available somewhere?  Even if not, just a brief description
of the methodology and assumptions would help to make sure I'm measuring
in a reasonable way.
