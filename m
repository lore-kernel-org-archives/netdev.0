From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: 16 Dec 2016 12:36:24 -0500
Message-ID: <20161216173624.21544.qmail@ns.sciencehorizons.net>
References: <CAHmME9rxCYfwyF6EADWqpAEt+yqCPgCLUVH0FPdAy7r-oPnrRg@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Cc: ak@linux.intel.com, davem@davemloft.net, David.Laight@aculab.com,
  djb@cr.yp.to, ebiggers3@gmail.com, hannes@stressinduktion.org,
  kernel-hardening@lists.openwall.com, linux-crypto@vger.kernel.org,
  linux-kernel@vger.kernel.org, linux@sciencehorizons.net,
  luto@amacapital.net, netdev@vger.kernel.org, tom@herbertland.com,
  torvalds@linux-foundation.org, tytso@mit.edu, vegard.nossum@gmail.com
To: Jason@zx2c4.com, jeanphilippe.aumasson@gmail.com
Return-path: <kernel-hardening-return-5643-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAHmME9rxCYfwyF6EADWqpAEt+yqCPgCLUVH0FPdAy7r-oPnrRg@mail.gmail.com>
List-Id: netdev.vger.kernel.org

> It appears that hsiphash can produce either 32-bit output or 64-bit
> output, with the output length parameter as part of the hash algorithm
> in there. When I code this for my kernel patchset, I very likely will
> only implement one output length size. Right now I'm leaning toward
> 32-bit.

A 128-bit output option was added to SipHash after the initial publication;
this is just the equivalent in 32-bit.

> - Is this a reasonable choice?

Yes.

> - Are there reasons why hsiphash with 64-bit output would be
>   reasonable? Or will we be fine sticking with 32-bit output only?

Personally, I'd put in a comment saying that "there's a 64-bit output
variant that's not implemented" and punt until someone find a need.

> With both hsiphash and siphash, the division of usage will probably become:
> - Use 64-bit output 128-bit key siphash for keyed RNG-like things,
>   such as syncookies and sequence numbers
> - Use 64-bit output 128-bit key siphash for hashtables that must
>   absolutely be secure to an extremely high bandwidth attacker, such as
>   userspace directly DoSing a kernel hashtable
> - Use 32-bit output 64-bit key hsiphash for quick hashtable functions
>   that still must be secure but do not require as large of a security
>   margin.

On a 64-bit machine, 64-bit SipHash is *always* faster than 32-bit, and
should be used always.  Don't even compile the 32-bit code, to prevent
anyone accidentally using it, and make hsiphash an alias for siphash.

On a 32-bit machine, it's a much trickier case.  I'd be tempted to
use the 32-bit code always, but it needs examination.

Fortunately, the cost of brute-forcing hash functions can be fairly
exactly quantified, thanks to bitcoin miners.  It currently takes 2^70
hashes to create one bitcoin block, worth 25 bitcoins ($19,500).  Thus,
2^63 hashes cost $152.

Now, there are two factors that must be considered:
- That's a very very "wholesale" rate.  That's assuming you're doing
  large numbers of these and can put in the up-front effort designing
  silicon ASICs to do the attack.
- That's for a more difficult hash (double sha-256) than SipHash.
  That's a constant fator, but a pretty significant one.  If the wholesale
  assumption holds, that might bring the cost down another 6 or 7 bits,
  to $1-2 per break.

If you're not the NSA and limited to general-purpose silicon, let's
assume a state of the art GPU (Radeon HD 7970; AMD GPUs seem do to better
than nVidia).  The bitcoin mining rate for those is about 700M/second,
29.4 bits.  So 63 bits is 152502 GPU-days, divided by some factor
to account for SipHash's high speed compared to two rounds of SHA-2.
Call it 1000 GPU-days.

It's very doable, but also very non-trivial.  The question is, wouldn't
it be cheaper and easier just to do a brute-force flooding DDoS?

(This is why I wish the key size could be tweaked up to 80 bits.
That would take all these numbers out of the reasonable range.)


Let me consider your second example above, "secure against local users".
I should dig through your patchset and find the details, but what exactly
are the consequences of such an attack?  Hasn't a local user already
got much better ways to DoS the system?

The thing to remember is that we're worried only about the combination
of a *new* Linux kernel (new build or under active maintenance) and a
32-bit host.  You'd be hard-pressed to find a *single* machine fitting
that description which is hosting multiple users or VMs and is not 64-bit.

These days, 32-bit CPUs are for embedded applications: network appliances,
TVs, etc.  That means basically single-user.  Even phones are 64 bit.
Is this really a threat that needs to be defended against?


For your first case, network applications, the additional security
is definitely attractive.  Syncookies are only a DoS, but sequence
numbers are a real security issue; they can let you inject data into a
TCP connection.

Hash tables are much harder to attack.  The information you get back from
timing probes is statistical, and thus testing a key is more expensive.
With sequence numbers, large amounts (32 bits) the hash output is
directly observable.

I wish we could get away with 64-bit security, but given that the
modern internet involves attacks from NSA/Spetssvyaz/3PLA, I agree
it's just not enough.
