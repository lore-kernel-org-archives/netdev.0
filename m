From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: BPF hash algo (Re: [kernel-hardening] Re: [PATCH v7 3/6] random:
 use SipHash in place of MD5)
Date: Thu, 22 Dec 2016 17:28:43 +0100
Message-ID: <CAHmME9pvPXiBu5TUYJL7gED7b=iXKrkXu45fXstnBFe77Esv5Q@mail.gmail.com>
References: <CALCETrUATPeaCJTQZN2h=ct6HH-xLt4V8T0PfPHNFGFN2HWtTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        "Theodore Ts'o" <tytso@mit.edu>, Netdev <netdev@vger.kernel.org>,
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrUATPeaCJTQZN2h=ct6HH-xLt4V8T0PfPHNFGFN2HWtTA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I don't know what your design requirements are for this. It looks like
you're generating some kind of crypto digest of a program, and you
need to avoid collisions. If you'd like to go with a PRF (keyed hash
function) that uses some kernel secret key, then I'd strongly suggest
using Keyed-Blake2. Alternatively, if you need for userspace to be
able to calculate the same hash, and don't want to use some kernel
secret, then I'd still suggest using Blake2, which will be fast and
secure.

If you can wait until January, I'll work on a commit adding the
primitive to the tree. I've already written it and I just need to get
things cleaned up.

> Blake2 is both less stable (didn't they slightly change it recently?)

No, Blake2 is very stable. It's also extremely secure and has been
extensively studied. Not to mention it's faster than SHA2. And if you
want to use it as a PRF, it's obvious better suited and faster to use
Blake2's keyed PRF mode than HMAC-SHA2.

If you don't care about performance, and you don't want to use a PRF,
then just use SHA2-256. If you're particularly concerned about certain
types of attacks, you could go with SHA2-512 truncated to 256 bytes,
but somehow I doubt you need this.

Anyway, the take away is: stop using SHA1. It's time has come.

> Everyone, please, please, please don't open-code crypto primitives.
> Is this and the code above it even correct?  It might be but on a very

I shuttered looking at this too. How did this possibly make it past
review? The attitude toward crypto here is generally *terrifying*.
Unless you're a professional cryptographer, the only correct attitude
to have is a careful and conservative one.

> At the very least, there should be a separate function that calculates
> the hash of a buffer and that function should explicitly run itself
> against test vectors of various lengths to make sure that it's
> calculating what it claims to be calculating.  And it doesn't look
> like the userspace code has landed, so, if this thing isn't
> calculating SHA1 correctly, it's plausible that no one has noticed.

If userspace hasn't landed, can we get away with changing this code
after 4.10? Or should we just fix it before 4.10? Or should we revert
it before 4.10? Development-policy-things like this I have zero clue
about, so I heed to your guidance.

Jason
