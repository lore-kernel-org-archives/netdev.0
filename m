From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v5 net-next] net: Implement fast csum_partial for x86_64
Date: Fri, 4 Mar 2016 16:15:00 -0800
Message-ID: <CAKgT0UcQEkhbpBvT69tBKvmY1EVm91vMwVUHOdkE4RJ3hH+Q9g@mail.gmail.com>
References: <1456957112-2702469-1-git-send-email-tom@herbertland.com>
	<063D6719AE5E284EB5DD2968C1650D6D41113AD4@AcuExch.aculab.com>
	<CA+55aFzz7xt+RwruV3GvWJzQ67925gkDYeOYqgbjMEAHxxztnQ@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D41114809@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Tom Herbert <tom@herbertland.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>,
	"kernel-team@fb.com" <kernel-team@fb.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:35520 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760128AbcCEAPC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 19:15:02 -0500
Received: by mail-io0-f177.google.com with SMTP id g203so79248171iof.2
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2016 16:15:01 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D41114809@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 4, 2016 at 2:38 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Linus Torvalds
>> Sent: 03 March 2016 18:44
>>
>> On Thu, Mar 3, 2016 at 8:12 AM, David Laight <David.Laight@aculab.com> wrote:
>> >
>> > Did you try the asm loop that used 'leax %rcx..., jcxz... jmps..'
>> > without any unrolling?
>>
>> Is that actually supposed to work ok these days? jcxz used to be quite
>> slow, and is historically *never* used.
>>
>> Now, in theory, loop constructs can actually do better on branch
>> prediction etc, but Intel seems to have never really tried to push
>> them, and has instead pretty much discouraged them in favor of making
>> the normal jumps go faster (including all the instruction fusion etc)
>
> Yes, they've even added the 'adc using the overflow flag' but not made
> it possible to put that into a loop.
>
>> From what I have seen, the whole "don't use LOOP or JRCXZ" has not changed.
>
> LOOP is still slow on intel cpus (but is single clock on recentish amd ones).
>
> JCXZ is reasonable on most cpus, certainly all the ones we care about these days.
> On intel cpus JCXZ is still 2 clocks, but it removes the dependency on any
> flags (which all other conditional instructions have).
> The difficulty is using it for a loop (you need JCXNZ or a fast LOOP).
> An alternative to the 'JCXZ, JMPS' pair would be to move the high bits
> of the counter into the low bits of cx so that cx would become non-zero
> on the last iteration.

Actually probably the easiest way to go on x86 is to just replace the
use of len with (len >> 6) and use decl or incl instead of addl or
subl, and lea instead of addq for the buff address.  None of those
instructions effect the carry flag as this is how such loops were
intended to be implemented.

I've been doing a bit of testing and that seems to work without
needing the adcq until after you exit the loop, but doesn't give that
much of a gain in speed for dropping the instruction from the
hot-path.  I suspect we are probably memory bottle-necked already in
the loop so dropping an instruction or two doesn't gain you much.

- Alex
