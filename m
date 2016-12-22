From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: HalfSipHash Acceptable Usage
Date: Wed, 21 Dec 2016 17:54:26 -0800
Message-ID: <CALCETrVxFDQGJeQX5k39pM3TvqH4q10SduPY=Os_RiJGEg_0Hg@mail.gmail.com>
References: <CAHmME9oJDOLpPKRpX=N+DY9BuzTueWjTaWzeVtdVMBG7mcrqKA@mail.gmail.com>
 <20161221155540.29529.qmail@ns.sciencehorizons.net> <CA+55aFy8fNOxw3bnwkX1S46jKnW6i26mueaiuOsScyN3kFJp+A@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: George Spelvin <linux@sciencehorizons.net>, "Jason A. Donenfeld" <Jason@zx2c4.com>,
	Andi Kleen <ak@linux.intel.com>, David Miller <davem@davemloft.net>,
	David Laight <David.Laight@aculab.com>, "Daniel J . Bernstein" <djb@cr.yp.to>,
	Eric Biggers <ebiggers3@gmail.com>, Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Network Development <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>, "Theodore Ts'o" <tytso@mit.edu>,
	Vegard Nossum <vegard.nossum@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <kernel-hardening-return-5761-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CA+55aFy8fNOxw3bnwkX1S46jKnW6i26mueaiuOsScyN3kFJp+A@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Wed, Dec 21, 2016 at 9:25 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Wed, Dec 21, 2016 at 7:55 AM, George Spelvin
> <linux@sciencehorizons.net> wrote:
>>
>> How much does kernel_fpu_begin()/kernel_fpu_end() cost?
>
> It's now better than it used to be, but it's absolutely disastrous
> still. We're talking easily many hundreds of cycles. Under some loads,
> thousands.
>
> And I warn you already: it will _benchmark_ a hell of a lot better
> than it will work in reality. In benchmarks, you'll hit all the
> optimizations ("oh, I've already saved away all the FP registers, no
> need to do it again").
>
> In contrast, in reality, especially with things like "do it once or
> twice per incoming packet", you'll easily hit the absolute worst
> cases, where not only does it take a few hundred cycles to save the FP
> state, you'll then return to user space in between packets, which
> triggers the slow-path return code and reloads the FP state, which is
> another few hundred cycles plus.

Hah, you're thinking that the x86 code works the way that Rik and I
want it to work, and you just made my day. :)  What actually happens
is that the state is saved in kernel_fpu_begin() and restored in
kernel_fpu_end(), and it'll take a few hundred cycles best case.  If
you do it a bunch of times in a loop, you *might* trigger a CPU
optimization that notices that the state being saved is the same state
that was just restored, but you're still going to pay the full restore
code each round trip no matter what.

The code is much clearer in 4.10 kernels now that I deleted the unused
"lazy" branches.

>
> Similarly, in benchmarks you'll hit the "modern CPU's power on the AVX
> unit and keep it powered up for a while afterwards", while in real
> life you would quite easily hit the "oh, AVX is powered down because
> we were idle, now it powers up at half speed which is another latency
> hit _and_ the AVX unit won't run full out anyway".

I *think* that was mostly fixed in Broadwell or thereabouts (in terms
of latency -- throughput and power consumption still suffers).
