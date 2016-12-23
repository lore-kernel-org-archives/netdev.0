From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: BPF hash algo (Re: [kernel-hardening] Re: [PATCH v7 3/6]
 random: use SipHash in place of MD5)
Date: Fri, 23 Dec 2016 11:59:22 +0100
Message-ID: <1482490762.3353.2.camel@stressinduktion.org>
References: <CALCETrUATPeaCJTQZN2h=ct6HH-xLt4V8T0PfPHNFGFN2HWtTA@mail.gmail.com>
         <1482425969.2673.5.camel@stressinduktion.org>
         <585CF6A3.1050107@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Theodore Ts'o <tytso@mit.edu>, Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        David Laight <David.Laight@aculab.com>,
        Eric Dumazet <edumazet@google.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Andi Kleen <ak@linux.intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Andy Lutomirski <luto@amacapital.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <585CF6A3.1050107@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-12-23 at 11:04 +0100, Daniel Borkmann wrote:
> On 12/22/2016 05:59 PM, Hannes Frederic Sowa wrote:
> > On Thu, 2016-12-22 at 08:07 -0800, Andy Lutomirski wrote:
> > > On Thu, Dec 22, 2016 at 7:51 AM, Hannes Frederic Sowa
> > > <hannes@stressinduktion.org> wrote:
> > > > On Thu, 2016-12-22 at 16:41 +0100, Jason A. Donenfeld wrote:
> > > > > On Thu, Dec 22, 2016 at 4:33 PM, Hannes Frederic Sowa
> > > > > <hannes@stressinduktion.org> wrote:
> > > > > > IPv6 you cannot touch anymore. The hashing algorithm is part of uAPI.
> > > > > > You don't want to give people new IPv6 addresses with the same stable
> > > > > > secret (across reboots) after a kernel upgrade. Maybe they lose
> > > > > > connectivity then and it is extra work?
> > > > > 
> > > > > Ahh, too bad. So it goes.
> > > > 
> > > > If no other users survive we can put it into the ipv6 module.
> > > > 
> > > > > > The bpf hash stuff can be changed during this merge window, as it is
> > > > > > not yet in a released kernel. Albeit I would probably have preferred
> > > > > > something like sha256 here, which can be easily replicated by user
> > > > > > space tools (minus the problem of patching out references to not
> > > > > > hashable data, which must be zeroed).
> > > > > 
> > > > > Oh, interesting, so time is of the essence then. Do you want to handle
> > > > > changing the new eBPF code to something not-SHA1 before it's too late,
> > > > > as part of a ne
> > > 
> > > w patchset that can fast track itself to David? And
> > > > > then I can preserve my large series for the next merge window.
> > > > 
> > > > This algorithm should be a non-seeded algorithm, because the hashes
> > > > should be stable and verifiable by user space tooling. Thus this would
> > > > need a hashing algorithm that is hardened against pre-image
> > > > attacks/collision resistance, which siphash is not. I would prefer some
> > > > higher order SHA algorithm for that actually.
> > > > 
> > > 
> > > You mean:
> > > 
> > > commit 7bd509e311f408f7a5132fcdde2069af65fa05ae
> > > Author: Daniel Borkmann <daniel@iogearbox.net>
> > > Date:   Sun Dec 4 23:19:41 2016 +0100
> > > 
> > >      bpf: add prog_digest and expose it via fdinfo/netlink
> > > 
> > > 
> > > Yes, please!  This actually matters for security -- imagine a
> > > malicious program brute-forcing a collision so that it gets loaded
> > > wrong.  And this is IMO a use case for SHA-256 or SHA-512/256
> > > (preferably the latter).  Speed basically doesn't matter here and
> > > Blake2 is both less stable (didn't they slightly change it recently?)
> > > and much less well studied.
> > 
> > We don't prevent ebpf programs being loaded based on the digest but
> > just to uniquely identify loaded programs from user space and match up
> > with their source.
> > 
> > There have been talks about signing bpf programs, thus this would
> > probably need another digest algorithm additionally to that one,
> > wasting probably instructions. Probably going somewhere in direction of
> > PKCS#7 might be the thing to do (which leads to the problem to make
> > PKCS#7 attackable by ordinary unpriv users, hmpf).
> > 
> > > My inclination would have been to seed them with something that isn't
> > > exposed to userspace for the precise reason that it would prevent user
> > > code from making assumptions about what's in the hash.  But if there's
> > > a use case for why user code needs to be able to calculate the hash on
> > > its own, then that's fine.  But perhaps the actual fdinfo string
> > > should be "sha256:abcd1234..." to give some flexibility down the road.
> > > 
> > > Also:
> > > 
> > > +       result = (__force __be32 *)fp->digest;
> > > +       for (i = 0; i < SHA_DIGEST_WORDS; i++)
> > > +               result[i] = cpu_to_be32(fp->digest[i]);
> > > 
> > > Everyone, please, please, please don't open-code crypto primitives.
> > > Is this and the code above it even correct?  It might be but on a very
> > > brief glance it looks wrong to me.  If you're doing this to avoid
> > > depending on crypto, then fix crypto so you can pull in the algorithm
> > > without pulling in the whole crypto core.
> > 
> > The hashing is not a proper sha1 neither, unfortunately. I think that
> > is why it will have a custom implementation in iproute2?
> 
> Still trying to catch up on this admittedly bit confusing thread. I
> did run automated tests over couple of days comparing the data I got
> from fdinfo with the one from af_alg and found no mismatch on the test
> cases varying from min to max possible program sizes. In the process
> of testing, as you might have seen on netdev, I found couple of other
> bugs in bpf code along the way and fixed them up as well. So my question,
> do you or Andy or anyone participating in claiming this have any
> concrete data or test cases that suggests something different? If yes,
> I'm very curious to hear about it and willing fix it up, of course.
> When I'm back from pto I'll prep and cook up my test suite to be
> included into the selftests/bpf/, should have done this initially,
> sorry about that. I'll also post something to expose the alg, that
> sounds fine to me.

Looking into your code closer, I noticed that you indeed seem to do the
finalization of sha-1 by hand by aligning and padding the buffer
accordingly and also patching in the necessary payload length.

Apologies for my side for claiming that this is not correct sha1
output, I was only looking at sha_transform and its implementation and
couldn't see the padding and finalization round with embedding the data
length in there and hadn't thought of it being done manually.

Anyway, is it difficult to get the sha finalization into some common
code library? It is not very bpf specific and crypto code reviewers
won't find it there at all.

Thanks,
Hannes
