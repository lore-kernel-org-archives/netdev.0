From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: 16 Dec 2016 15:17:39 -0500
Message-ID: <20161216201739.24567.qmail@ns.sciencehorizons.net>
References: <CAHmME9pe39s5FWxfKNiRKkHnEO-9v2yLcEQc8rnMC89P6roTmA@mail.gmail.com>
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
        djb@cr.yp.to, ebiggers3@gmail.com, hannes@stressinduktion.org,
        jeanphilippe.aumasson@gmail.com,
        kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
        linux-kernel@vger.kernel.org, luto@amacapital.net,
        netdev@vger.kernel.org, tom@herbertland.com,
        torvalds@linux-foundation.org, tytso@mit.edu,
        vegard.nossum@gmail.com
To: Jason@zx2c4.com, linux@sciencehorizons.net
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CAHmME9pe39s5FWxfKNiRKkHnEO-9v2yLcEQc8rnMC89P6roTmA@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> On a 64-bit machine, 64-bit SipHash is *always* faster than 32-bit, and
>> should be used always.  Don't even compile the 32-bit code, to prevent
>> anyone accidentally using it, and make hsiphash an alias for siphash.

> Fascinating! Okay. So I'll alias hsiphash to siphash on 64-bit then. I
> like this arrangement.

This is a basic assumption I make in the security analysis below:
on most machines, it's 128-bit-key SipHash everywhere and we can
consider security solved.

Our analysis *only* has to consider 32-bit machines.  My big concern
is home routers, with IoT appliances coming second.  The routers have
severe hardware cost constraints (so limited CPU power), but see a lot
of traffic and need to process (NAT) it.

> That's a nice analysis. Might one conclude from that that hsiphash is
> not useful for our purposes? Or does it still remain useful for
> network facing code?

I think for attacks where the threat is a DoS, it's usable.  The point
is you only have to raise the cost to equal that of a packet flood.
(Just like in electronic warfare, the best you can possibly do is force
the enemy to use broadband jamming.)

Hash collision attacks just aren't that powerful.  The original PoC
was against an application that implemented a hard limit on hash chain
length as a DoS defense, which the attack then exploited to turn it into
a hard DoS.

>> Let me consider your second example above, "secure against local users".
>> I should dig through your patchset and find the details, but what exactly
>> are the consequences of such an attack?  Hasn't a local user already
>> got much better ways to DoS the system?

> For example, an unpriv'd user putting lots of entries in one hash
> bucket for a shared resource that's used by root, like filesystems or
> other lookup tables. If he can cause root to use more of root's cpu
> schedule budget than otherwise in a directed way, then that's a bad
> DoS.

This issue was recently discussed when we redesigned the dcache hash.
Even a successful attack doesn't slow things down all *that* much.

Before you overkill every hash table in the kernel, think about whether
it's a bigger problem than the dcache.  (Hint: it's probably not.)
There's no point armor-plating the side door when the front door was
just upgraded from screen to wood.

>> These days, 32-bit CPUs are for embedded applications: network appliances,
>> TVs, etc.  That means basically single-user.  Even phones are 64 bit.
>> Is this really a threat that needs to be defended against?

> I interpret this to indicate all the more reason to alias hsiphash to
> siphash on 64-bit, and then the problem space collapses in a clear
> way.

Yes, exactly.  

> Right. Hence the need for always using full siphash and not hsiphash
> for sequence numbers, per my earlier email to David.
>
>> I wish we could get away with 64-bit security, but given that the
>> modern internet involves attacks from NSA/Spetssvyaz/3PLA, I agree
>> it's just not enough.
>
> I take this comment to be relavent for the sequence number case.

Yes.

> For hashtables and hashtable flooding, is it still your opinion that
> we will benefit from hsiphash? Or is this final conclusion a rejection
> of hsiphash for that too? We're talking about two different use cases,
> and your email kind of interleaved both into your analysis, so I'm not
> certain so to precisely what your conclusion is for each use case. Can
> you clear up the ambiguity?

My (speaking enerally; I should walk through every hash table you've
converted) opinion is that:

- Hash tables, even network-facing ones, can all use hsiphash as long
  as an attacker can only see collisions, i.e. ((H(x) ^ H(y)) & bits) ==
  0, and the consequences of a successful attack is only more collisions
  (timing).  While the attack is only 2x the cost (two hashes rather than
  one to test a key), the knowledge of the collision is statistical,
  especially for network attackers, which raises the cost of guessing
  beyond an even more brute-force attack.
- When the hash value directly visible (e.g. included in a network
  packet), full SipHash should be the default.
- Syncookies *could* use hsiphash, especially as there are
  two keys in there.  Not sure if we need the performance.
- For TCP ISNs, I'd prefer to use full SipHash.  I know this is
  a very hot path, and if that's a performance bottleneck,
  we can work harder on it.

In particular, TCP ISNs *used* to rotate the key periodically,
limiting the time available to an attacker to perform an
attack before the secret goes stale and is useless.  commit
6e5714eaf77d79ae1c8b47e3e040ff5411b717ec upgraded to md5 and dropped
the key rotation.

If 2x hsiphash is faster than siphash, we could use a double-hashing
system like syncookies.  One 32-bit hash with a permanent key, summed
with a k-bit counter and a (32-k)-bit hash, where the key is rotated
(and the counter incremented) periodically.

The requirement is that the increment rate of the counter hash doesn't
shorten the sequence number wraparound too much.  The old code used an
8-bit counter and 24-bit hash, with the counter bumped every 5 minutes.

Current code uses a 64 ns tick for the ISN, so it counts 2^24 per second.
(32 bits wraps every 4.6 minutes.)  A 4-bit counter and 28-bit hash
(or even 3+29) would work as long as the key is regenerated no more
than once per minute.  (Just using the 4.6-minute ISN wrap time is the
obvious simple implementation.)

(Of course, I defer to DaveM's judgement on all network-related issues.)
