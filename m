From: Andy Lutomirski <luto@amacapital.net>
Subject: BPF hash algo (Re: [kernel-hardening] Re: [PATCH v7 3/6] random: use
 SipHash in place of MD5)
Date: Thu, 22 Dec 2016 08:07:07 -0800
Message-ID: <CALCETrUATPeaCJTQZN2h=ct6HH-xLt4V8T0PfPHNFGFN2HWtTA@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Theodore Ts'o" <tytso@mit.edu>,
	Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, David Laight <David.Laight@aculab.com>,
	Eric Dumazet <edumazet@google.com>, Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Biggers <ebiggers3@gmail.com>, Tom Herbert <tom@herbertland.com>,
	Andi Kleen <ak@linux.intel.com>, "David S. Miller" <davem@davemloft.net>,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>, Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <kernel-hardening-return-5787-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
List-Id: netdev.vger.kernel.org

On Thu, Dec 22, 2016 at 7:51 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Thu, 2016-12-22 at 16:41 +0100, Jason A. Donenfeld wrote:
>> Hi Hannes,
>>
>> On Thu, Dec 22, 2016 at 4:33 PM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>> > IPv6 you cannot touch anymore. The hashing algorithm is part of uAPI.
>> > You don't want to give people new IPv6 addresses with the same stable
>> > secret (across reboots) after a kernel upgrade. Maybe they lose
>> > connectivity then and it is extra work?
>>
>> Ahh, too bad. So it goes.
>
> If no other users survive we can put it into the ipv6 module.
>
>> > The bpf hash stuff can be changed during this merge window, as it is
>> > not yet in a released kernel. Albeit I would probably have preferred
>> > something like sha256 here, which can be easily replicated by user
>> > space tools (minus the problem of patching out references to not
>> > hashable data, which must be zeroed).
>>
>> Oh, interesting, so time is of the essence then. Do you want to handle
>> changing the new eBPF code to something not-SHA1 before it's too late,
>> as part of a ne
w patchset that can fast track itself to David? And
>> then I can preserve my large series for the next merge window.
>
> This algorithm should be a non-seeded algorithm, because the hashes
> should be stable and verifiable by user space tooling. Thus this would
> need a hashing algorithm that is hardened against pre-image
> attacks/collision resistance, which siphash is not. I would prefer some
> higher order SHA algorithm for that actually.
>

You mean:

commit 7bd509e311f408f7a5132fcdde2069af65fa05ae
Author: Daniel Borkmann <daniel@iogearbox.net>
Date:   Sun Dec 4 23:19:41 2016 +0100

    bpf: add prog_digest and expose it via fdinfo/netlink


Yes, please!  This actually matters for security -- imagine a
malicious program brute-forcing a collision so that it gets loaded
wrong.  And this is IMO a use case for SHA-256 or SHA-512/256
(preferably the latter).  Speed basically doesn't matter here and
Blake2 is both less stable (didn't they slightly change it recently?)
and much less well studied.

My inclination would have been to seed them with something that isn't
exposed to userspace for the precise reason that it would prevent user
code from making assumptions about what's in the hash.  But if there's
a use case for why user code needs to be able to calculate the hash on
its own, then that's fine.  But perhaps the actual fdinfo string
should be "sha256:abcd1234..." to give some flexibility down the road.

Also:

+       result = (__force __be32 *)fp->digest;
+       for (i = 0; i < SHA_DIGEST_WORDS; i++)
+               result[i] = cpu_to_be32(fp->digest[i]);

Everyone, please, please, please don't open-code crypto primitives.
Is this and the code above it even correct?  It might be but on a very
brief glance it looks wrong to me.  If you're doing this to avoid
depending on crypto, then fix crypto so you can pull in the algorithm
without pulling in the whole crypto core.

At the very least, there should be a separate function that calculates
the hash of a buffer and that function should explicitly run itself
against test vectors of various lengths to make sure that it's
calculating what it claims to be calculating.  And it doesn't look
like the userspace code has landed, so, if this thing isn't
calculating SHA1 correctly, it's plausible that no one has noticed.

--Andy
