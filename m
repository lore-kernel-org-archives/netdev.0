From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v3 net-next] net: Implement fast csum_partial for x86_64
Date: Thu, 4 Feb 2016 14:57:17 -0800
Message-ID: <CA+55aFx7iCeRNBK3QrFBWiSWK8OU8ZsUMwg0-4tP3F0PhDdxuQ@mail.gmail.com>
References: <1454527121-4007853-1-git-send-email-tom@herbertland.com>
	<20160204093021.GB1553@gmail.com>
	<CA+55aFxqs+mE=s4UkNQXJA8JjAKKb6vk1JO672jdEuWtsJ=hVg@mail.gmail.com>
	<CALx6S37+F9UnyDuOgXHKqhNQvBXoQe8G2GCWPbhZE8QBdmz3vg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ingo Molnar <mingo@kernel.org>, David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Peter Anvin <hpa@zytor.com>,
	"the arch/x86 maintainers" <x86@kernel.org>,
	kernel-team <kernel-team@fb.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Tom Herbert <tom@herbertland.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALx6S37+F9UnyDuOgXHKqhNQvBXoQe8G2GCWPbhZE8QBdmz3vg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 4, 2016 at 2:43 PM, Tom Herbert <tom@herbertland.com> wrote:
>
> The reason I did this in assembly is precisely about the your point of
> having to close the carry chains with adcq $0. I do have a first
> implementation in C which using switch() to handle alignment, excess
> length less than 8 bytes, and the odd number of quads to sum in the
> main loop. gcc turns these switch statements into jump tables (not
> function tables which is what Ingo's example code was using). The
> problem I hit was that for each case I needed to close the carry chain
> in the inline asm so fall through wouldn't have much value and each
> case is expanded. The C version using switch gave a nice performance
> gain, moving to all assembly was somewhat better.

Yeah,. so I _think_ that if my approach works, the code generated for
the 0-8 byte case looks just something like

    movq %rsi, %rax
    andl $1, %eax
    subq %rax, %rdi
    movq %rdx, %rax
    movq (%rdi), %rcx
    andq mask(,%rsi,8), %rcx
    addq %rcx,%rax
    adcq $0,%rax

which is pretty close to optimal (that's with my hopefully fixed version).

That's not with the final narrowing from 64-bit to 32-bit, but it
looks like it should perform well on most x86 cores, and then the only
remaining branches end up being the actual size checking ones.

And yes, you could avoid a few "adc $0" instructions in asm, but quite
frankly, I think that's a tradeoff that is worth it.

My guess is that you can get to within a percent of optimal with the C
approach, and I really think it makes it easier to try different
things (ie things like the above that avoids the switch table
entirely)

> There is also question of alignment. I f we really don't need to worry
> about alignment at all on x86, then we should be able to eliminate the
> complexity of dealing with it.

So most x86 alignment issues are about crossing the cache bank size,
which is usually 16 or 32 bytes. Unaligned accesses *within* one of
those banks should be basically free (there's a whoppign big byte lane
shifter, so there's lots of hardware support for that).

Also, even when you do cross a cache bank, it's usually pretty cheap.
It extra cycles, but it's generally *less* extra cycles than it would
be to try to align things in software and doing two accesses.

The rule of thumb is that you should never worry about _individual_
unaligned accesses. It's only really worth it aligning things before
biggish loops. So aligning to an 8-byte boundary before you then do a
lot of "adcq" instructions makes sense, but worrying about unaligned
accesses for the beginning/end does generally not.

>>> For example, for the actual "8 bytes or shorter" case, I think
>> something like this might just work fine: [ snip ]
>
> I will look at doing that.

So I already found and fixed one bug in that approach, but I still
think it's a viable model.

But you will almost certainly have to fix a few more of my bugs before
it really works ;)

                   Linus
