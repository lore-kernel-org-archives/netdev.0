From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: Fri, 16 Dec 2016 19:00:26 +0100
Message-ID: <CAHmME9pe39s5FWxfKNiRKkHnEO-9v2yLcEQc8rnMC89P6roTmA@mail.gmail.com>
References: <CAHmME9rxCYfwyF6EADWqpAEt+yqCPgCLUVH0FPdAy7r-oPnrRg@mail.gmail.com>
 <20161216173624.21544.qmail@ns.sciencehorizons.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>, Andi Kleen <ak@linux.intel.com>,
	David Miller <davem@davemloft.net>, David Laight <David.Laight@aculab.com>,
	"Daniel J . Bernstein" <djb@cr.yp.to>, Eric Biggers <ebiggers3@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>, kernel-hardening@lists.openwall.com,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Andy Lutomirski <luto@amacapital.net>, Netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>, Linus Torvalds <torvalds@linux-foundation.org>,
	"Theodore Ts'o" <tytso@mit.edu>, Vegard Nossum <vegard.nossum@gmail.com>
To: George Spelvin <linux@sciencehorizons.net>
Return-path: <kernel-hardening-return-5644-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161216173624.21544.qmail@ns.sciencehorizons.net>
List-Id: netdev.vger.kernel.org

Hi George,

On Fri, Dec 16, 2016 at 6:36 PM, George Spelvin
<linux@sciencehorizons.net> wrote:
> A 128-bit output option was added to SipHash after the initial publication;
> this is just the equivalent in 32-bit.
> Personally, I'd put in a comment saying that "there's a 64-bit output
> variant that's not implemented" and punt until someone find a need.

That's a good way to think about it. Okay, I'll do precisely that.

> On a 64-bit machine, 64-bit SipHash is *always* faster than 32-bit, and
> should be used always.  Don't even compile the 32-bit code, to prevent
> anyone accidentally using it, and make hsiphash an alias for siphash.

Fascinating! Okay. So I'll alias hsiphash to siphash on 64-bit then. I
like this arrangement.


> Fortunately, the cost of brute-forcing hash functions can be fairly
> exactly quantified, thanks to bitcoin miners.  It currently takes 2^70
> hashes to create one bitcoin block, worth 25 bitcoins ($19,500).  Thus,
> 2^63 hashes cost $152.
>
> Now, there are two factors that must be considered:
> - That's a very very "wholesale" rate.  That's assuming you're doing
>   large numbers of these and can put in the up-front effort designing
>   silicon ASICs to do the attack.
> - That's for a more difficult hash (double sha-256) than SipHash.
>   That's a constant fator, but a pretty significant one.  If the wholesale
>   assumption holds, that might bring the cost down another 6 or 7 bits,
>   to $1-2 per break.
>
> If you're not the NSA and limited to general-purpose silicon, let's
> assume a state of the art GPU (Radeon HD 7970; AMD GPUs seem do to better
> than nVidia).  The bitcoin mining rate for those is about 700M/second,
> 29.4 bits.  So 63 bits is 152502 GPU-days, divided by some factor
> to account for SipHash's high speed compared to two rounds of SHA-2.
> Call it 1000 GPU-days.
>
> It's very doable, but also very non-trivial.  The question is, wouldn't
> it be cheaper and easier just to do a brute-force flooding DDoS?
>
> (This is why I wish the key size could be tweaked up to 80 bits.
> That would take all these numbers out of the reasonable range.)

That's a nice analysis. Might one conclude from that that hsiphash is
not useful for our purposes? Or does it still remain useful for
network facing code?

> Let me consider your second example above, "secure against local users".
> I should dig through your patchset and find the details, but what exactly
> are the consequences of such an attack?  Hasn't a local user already
> got much better ways to DoS the system?

For example, an unpriv'd user putting lots of entries in one hash
bucket for a shared resource that's used by root, like filesystems or
other lookup tables. If he can cause root to use more of root's cpu
schedule budget than otherwise in a directed way, then that's a bad
DoS.

> The thing to remember is that we're worried only about the combination
> of a *new* Linux kernel (new build or under active maintenance) and a
> 32-bit host.  You'd be hard-pressed to find a *single* machine fitting
> that description which is hosting multiple users or VMs and is not 64-bit.
>
> These days, 32-bit CPUs are for embedded applications: network appliances,
> TVs, etc.  That means basically single-user.  Even phones are 64 bit.
> Is this really a threat that needs to be defended against?

I interpret this to indicate all the more reason to alias hsiphash to
siphash on 64-bit, and then the problem space collapses in a clear
way.

> For your first case, network applications, the additional security
> is definitely attractive.  Syncookies are only a DoS, but sequence
> numbers are a real security issue; they can let you inject data into a
> TCP connection.
> With sequence numbers, large amounts (32 bits) the hash output is
> directly observable.

Right. Hence the need for always using full siphash and not hsiphash
for sequence numbers, per my earlier email to David.

>
> I wish we could get away with 64-bit security, but given that the
> modern internet involves attacks from NSA/Spetssvyaz/3PLA, I agree
> it's just not enough.

I take this comment to be relavent for the sequence number case.

For hashtables and hashtable flooding, is it still your opinion that
we will benefit from hsiphash? Or is this final conclusion a rejection
of hsiphash for that too? We're talking about two different use cases,
and your email kind of interleaved both into your analysis, so I'm not
certain so to precisely what your conclusion is for each use case. Can
you clear up the ambiguity?

Jason
