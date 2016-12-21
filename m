From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: HalfSipHash Acceptable Usage
Date: Wed, 21 Dec 2016 09:25:01 -0800
Message-ID: <CA+55aFy8fNOxw3bnwkX1S46jKnW6i26mueaiuOsScyN3kFJp+A@mail.gmail.com>
References: <CAHmME9oJDOLpPKRpX=N+DY9BuzTueWjTaWzeVtdVMBG7mcrqKA@mail.gmail.com>
 <20161221155540.29529.qmail@ns.sciencehorizons.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Andi Kleen <ak@linux.intel.com>,
        David Miller <davem@davemloft.net>,
        David Laight <David.Laight@aculab.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Eric Biggers <ebiggers3@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Network Development <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Vegard Nossum <vegard.nossum@gmail.com>
To: George Spelvin <linux@sciencehorizons.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161221155540.29529.qmail@ns.sciencehorizons.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 21, 2016 at 7:55 AM, George Spelvin
<linux@sciencehorizons.net> wrote:
>
> How much does kernel_fpu_begin()/kernel_fpu_end() cost?

It's now better than it used to be, but it's absolutely disastrous
still. We're talking easily many hundreds of cycles. Under some loads,
thousands.

And I warn you already: it will _benchmark_ a hell of a lot better
than it will work in reality. In benchmarks, you'll hit all the
optimizations ("oh, I've already saved away all the FP registers, no
need to do it again").

In contrast, in reality, especially with things like "do it once or
twice per incoming packet", you'll easily hit the absolute worst
cases, where not only does it take a few hundred cycles to save the FP
state, you'll then return to user space in between packets, which
triggers the slow-path return code and reloads the FP state, which is
another few hundred cycles plus.

Similarly, in benchmarks you'll hit the "modern CPU's power on the AVX
unit and keep it powered up for a while afterwards", while in real
life you would quite easily hit the "oh, AVX is powered down because
we were idle, now it powers up at half speed which is another latency
hit _and_ the AVX unit won't run full out anyway".

Don't do it. There are basically no real situations where the AVX
state optimizations help for the kernel. We just don't have the loop
counts to make up for the problems it causes.

The one exception is likely if you're doing things like
high-throughput disk IO encryption, and then you'd be much better off
using SHA256 instead (which often has hw encryption on modern CPU's -
both x86 and ARM).

(I'm sure that you could see it on some high-throughput network
benchmark too when the benchmark entirely saturates the CPU. And then
in real life it would suck horribly for all the reasons above).

                Linus
