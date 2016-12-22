From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: BPF hash algo (Re: [kernel-hardening] Re: [PATCH v7 3/6]
 random: use SipHash in place of MD5)
Date: Thu, 22 Dec 2016 18:49:56 +0100
Message-ID: <1482428996.2673.7.camel@stressinduktion.org>
References: <CALCETrUATPeaCJTQZN2h=ct6HH-xLt4V8T0PfPHNFGFN2HWtTA@mail.gmail.com>
         <1482425969.2673.5.camel@stressinduktion.org>
         <CALCETrW_T1v4qKPJDs5dXwAnAit3M52AWMH-K+GJLb1WoLMuRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
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
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CALCETrW_T1v4qKPJDs5dXwAnAit3M52AWMH-K+GJLb1WoLMuRQ@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-12-22 at 09:25 -0800, Andy Lutomirski wrote:
> On Thu, Dec 22, 2016 at 8:59 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > On Thu, 2016-12-22 at 08:07 -0800, Andy Lutomirski wrote:
> > > 
> > > You mean:
> > > 
> > > commit 7bd509e311f408f7a5132fcdde2069af65fa05ae
> > > Author: Daniel Borkmann <daniel@iogearbox.net>
> > > Date:   Sun Dec 4 23:19:41 2016 +0100
> > > 
> > >     bpf: add prog_digest and expose it via fdinfo/netlink
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
> 
> The commit log talks about using the hash to see if the program has
> already been compiled and JITted.  If that's done, then a collision
> will directly cause the kernel to malfunction.

Yeah, it still shouldn't crash the kernel but it could cause
malfunctions because assumptions are not met from user space thus it
could act in a strange way:

My personal biggest concern is that users of this API will at some
point in time assume this digist is unique (as a key itself for a
hashtables f.e.), while it is actually not (and not enforced so by the
kernel). If you can get an unpriv ebpf program inserted to the kernel
with the same weak hash, a controller daemon could pick it up and bind
it to another ebpf hook, probably outside of the unpriv realm the user
was in before. Only the sorting matters, which might be unstable and is
not guaranteed by anything in most hash table based data structures.

The API seems flawed to me.

> > > My inclination would have been to seed them with something that isn't
> > > exposed to userspace for the precise reason that it would prevent user
> > > code from making assumptions about what's in the hash.  But if there's
> > > a use case for why user code needs to be able to calculate the hash on
> > > its own, then that's fine.  But perhaps the actual fdinfo string
> > > should be "sha256:abcd1234..." to give some flexibility down the road.

To add to this, I am very much in favor of that. Right now it doesn't
have a name because it is a custom algorithm. ;)

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
> Putting on crypto hat:
> 
> NAK NAK NAK NAK NAK.  "The Linux kernel invented a new primitive in
> 2016 when people know better and is going to handle it by porting that
> new primitive to userspace" is not a particularly good argument.
> 
> Okay, crypto hack back off.
> 
> > 
> > I wondered if bpf program loading should have used the module loading
> > infrastructure from the beginning...
> 
> That would be way too complicated and would be nasty for the unprivileged cases.

I was more or less just thinking about using the syscalls and user
space representation not the generic infrastructure, as it is anyway
too much concerned with real kernel modules (would probably also solve
your cgroup-ebpf thread, as it can be passed by unique name or name and
hash ;) ). Anyway...

> > > At the very least, there should be a separate function that calculates
> > > the hash of a buffer and that function should explicitly run itself
> > > against test vectors of various lengths to make sure that it's
> > > calculating what it claims to be calculating.  And it doesn't look
> > > like the userspace code has landed, so, if this thing isn't
> > > calculating SHA1 correctly, it's plausible that no one has noticed.
> > 
> > I hope this was known from the beginning, this is not sha1 unfortunately.
> > 
> > But ebpf elf programs also need preprocessing to get rid of some
> > embedded load-depending data, so maybe it was considered to be just
> > enough?
> 
> I suspect it was actually an accident.

Maybe, I don't know.

Bye,
Hannes
