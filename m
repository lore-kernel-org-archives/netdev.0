From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v5 net-next] net: Implement fast csum_partial for x86_64
Date: Mon, 7 Mar 2016 09:33:51 -0800
Message-ID: <CALx6S35h+oSCKsaEotah30tspZPdp3GZThrN8=cLbE2O7nhU2g@mail.gmail.com>
References: <1456957112-2702469-1-git-send-email-tom@herbertland.com>
	<063D6719AE5E284EB5DD2968C1650D6D41113AD4@AcuExch.aculab.com>
	<CA+55aFzz7xt+RwruV3GvWJzQ67925gkDYeOYqgbjMEAHxxztnQ@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D41114809@AcuExch.aculab.com>
	<CAKgT0UcQEkhbpBvT69tBKvmY1EVm91vMwVUHOdkE4RJ3hH+Q9g@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D41116831@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>,
	"kernel-team@fb.com" <kernel-team@fb.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f194.google.com ([209.85.213.194]:36580 "EHLO
	mail-ig0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427AbcCGRdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 12:33:53 -0500
Received: by mail-ig0-f194.google.com with SMTP id ir4so6086586igb.3
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 09:33:52 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D41116831@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 7, 2016 at 5:56 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Alexander Duyck
>  ...
>> Actually probably the easiest way to go on x86 is to just replace the
>> use of len with (len >> 6) and use decl or incl instead of addl or
>> subl, and lea instead of addq for the buff address.  None of those
>> instructions effect the carry flag as this is how such loops were
>> intended to be implemented.
>>
>> I've been doing a bit of testing and that seems to work without
>> needing the adcq until after you exit the loop, but doesn't give that
>> much of a gain in speed for dropping the instruction from the
>> hot-path.  I suspect we are probably memory bottle-necked already in
>> the loop so dropping an instruction or two doesn't gain you much.
>
> Right, any superscalar architecture gives you some instructions
> 'for free' if they can execute at the same time as those on the
> critical path (in this case the memory reads and the adc).
> This is why loop unrolling can be pointless.
>
> So the loop:
> 10:     addc %rax,(%rdx,%rcx,8)
>         inc %rcx
>         jnz 10b
> could easily be as fast as anything that doesn't use the 'new'
> instructions that use the overflow flag.
> That loop might be measurable faster for aligned buffers.

Tested by replacing the unrolled loop in my patch with just:

if (len >= 8) {
                asm("clc\n\t"
                    "0: adcq (%[src],%%rcx,8),%[res]\n\t"
                    "decl %%ecx\n\t"
                    "jge 0b\n\t"
                    "adcq $0, %[res]\n\t"
                            : [res] "=r" (result)
                            : [src] "r" (buff), "[res]" (result), "c"
((len >> 3) - 1));
}

This seems to be significantly slower:

1400 bytes: 797 nsecs vs. 202 nsecs
40 bytes: 6.5 nsecs vs. 26.8 nsecs

Tom

>
>         David
>
