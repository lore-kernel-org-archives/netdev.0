From: Andy Lutomirski <luto@kernel.org>
Subject: Re: BPF hash algo (Re: [kernel-hardening] Re: [PATCH v7 3/6] random:
 use SipHash in place of MD5)
Date: Thu, 22 Dec 2016 11:56:34 -0800
Message-ID: <CALCETrUWw2m8k3b8ibOeN-7o9b+8MrnX4btUWqS188WSsLzDjg@mail.gmail.com>
References: <CALCETrUATPeaCJTQZN2h=ct6HH-xLt4V8T0PfPHNFGFN2HWtTA@mail.gmail.com>
 <1482425969.2673.5.camel@stressinduktion.org> <CALCETrW_T1v4qKPJDs5dXwAnAit3M52AWMH-K+GJLb1WoLMuRQ@mail.gmail.com>
 <CAADnVQ+memUT2zcc-wunP0QgWSLWpmnSJNRJZmfDdc+FBb=gEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
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
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CAADnVQ+memUT2zcc-wunP0QgWSLWpmnSJNRJZmfDdc+FBb=gEg@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 22, 2016 at 11:34 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Thu, Dec 22, 2016 at 9:25 AM, Andy Lutomirski <luto@amacapital.net> wrote:
>> On Thu, Dec 22, 2016 at 8:59 AM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>>> On Thu, 2016-12-22 at 08:07 -0800, Andy Lutomirski wrote:
>>>
>>> We don't prevent ebpf programs being loaded based on the digest but
>>> just to uniquely identify loaded programs from user space and match up
>>> with their source.
>>
>> The commit log talks about using the hash to see if the program has
>> already been compiled and JITted.  If that's done, then a collision
>> will directly cause the kernel to malfunction.
>
> Andy, please read the code.
> we could have used jhash there just as well.
> Collisions are fine.

There's relevant in the code to read yet AFAICS.  The code exports it
via fdinfo, and userspace is expected to do something with it.  The
commit message says:

    When programs are pinned and retrieved by an ELF loader, the loader
    can check the program's digest through fdinfo and compare it against
    one that was generated over the ELF file's program section to see
    if the program needs to be reloaded.

I assume this means that a userspace component is expected to compare
the digest of a loaded program to a digest of a program it wants to
load and to use the result of the comparison to decide whether the
programs are the same.  If that's indeed the case (and it sure sounds
like it, and I fully expect CRIU to do very similar things when
support is added), then malicious collisions do matter.

It's also not quite clear to me why userspace needs to be able to
calculate the digest on its own.  A bpf(BPF_CALC_PROGRAM_DIGEST)
command that takes a BPF program as input and hashes it would seem to
serve the same purpose, and that would allow the kernel to key the
digest and change the algorithm down the road without breaking things.

Regardless, adding a new hash algorithm that is almost-but-not-quite
SHA-1 and making it a stable interface to userspace is not a good
thing.

--Andy
