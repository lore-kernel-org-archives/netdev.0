From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v3 net-next] net: Implement fast csum_partial for x86_64
Date: Thu, 4 Feb 2016 08:51:59 -0800
Message-ID: <CAKgT0UcuJWmpwO4hu34qBWhrhqQ5GQMU_dWHF-Dd10+Y9aCH=g@mail.gmail.com>
References: <1454527121-4007853-1-git-send-email-tom@herbertland.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CCD63C9@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>,
	"kernel-team@fb.com" <kernel-team@fb.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:36712 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093AbcBDQwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 11:52:00 -0500
Received: by mail-ig0-f180.google.com with SMTP id xg9so29768890igb.1
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 08:52:00 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCD63C9@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 4, 2016 at 3:08 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Tom Herbert
>> Sent: 03 February 2016 19:19
> ...
>> +     /* Main loop */
>> +50:  adcq    0*8(%rdi),%rax
>> +     adcq    1*8(%rdi),%rax
>> +     adcq    2*8(%rdi),%rax
>> +     adcq    3*8(%rdi),%rax
>> +     adcq    4*8(%rdi),%rax
>> +     adcq    5*8(%rdi),%rax
>> +     adcq    6*8(%rdi),%rax
>> +     adcq    7*8(%rdi),%rax
>> +     adcq    8*8(%rdi),%rax
>> +     adcq    9*8(%rdi),%rax
>> +     adcq    10*8(%rdi),%rax
>> +     adcq    11*8(%rdi),%rax
>> +     adcq    12*8(%rdi),%rax
>> +     adcq    13*8(%rdi),%rax
>> +     adcq    14*8(%rdi),%rax
>> +     adcq    15*8(%rdi),%rax
>> +     lea     128(%rdi), %rdi
>> +     loop    50b
>
> I'd need convincing that unrolling the loop like that gives any significant gain.
> You have a dependency chain on the carry flag so have delays between the 'adcq'
> instructions (these may be more significant than the memory reads from l1 cache).
>
> I also don't remember (might be wrong) the 'loop' instruction being executed quickly.
> If 'loop' is fast then you will probably find that:
>
> 10:     adcq 0(%rdi),%rax
>         lea  8(%rdi),%rdi
>         loop 10b
>
> is just as fast since the three instructions could all be executed in parallel.
> But I suspect that 'dec %cx; jnz 10b' is actually better (and might execute as
> a single micro-op).
> IIRC 'adc' and 'dec' will both have dependencies on the flags register
> so cannot execute together (which is a shame here).
>
> It is also possible that breaking the carry-chain dependency by doing 32bit
> adds (possibly after 64bit reads) can be made to be faster.

If nothing else reducing the size of this main loop may be desirable.
I know the newer x86 is supposed to have a loop buffer so that it can
basically loop on already decoded instructions.  Normally it is only
something like 64 or 128 bytes in size though.  You might find that
reducing this loop to that smaller size may improve the performance
for larger payloads.

- Alex
