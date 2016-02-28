From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v4 net-next] net: Implement fast csum_partial for x86_64
Date: Sun, 28 Feb 2016 10:56:38 -0800
Message-ID: <CAKgT0UfDWXbXSX45XRZjTc6SXz+XqaYa1bHGzOUV_RXSPh=U=A@mail.gmail.com>
References: <1456516995-3471163-1-git-send-email-tom@herbertland.com>
	<CAKgT0UdxdY5VF5OzC+W0Y31CcK0T3ffkcRMQrZqJ==L9SdtNuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Peter Anvin <hpa@zytor.com>,
	"the arch/x86 maintainers" <x86@kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:34321 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754624AbcB1S4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2016 13:56:40 -0500
Received: by mail-ig0-f180.google.com with SMTP id g6so70180307igt.1
        for <netdev@vger.kernel.org>; Sun, 28 Feb 2016 10:56:39 -0800 (PST)
In-Reply-To: <CAKgT0UdxdY5VF5OzC+W0Y31CcK0T3ffkcRMQrZqJ==L9SdtNuQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 27, 2016 at 12:30 AM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
>> +{
>> +       asm("lea 40f(, %[slen], 4), %%r11\n\t"
>> +           "clc\n\t"
>> +           "jmpq *%%r11\n\t"
>> +           "adcq 7*8(%[src]),%[res]\n\t"
>> +           "adcq 6*8(%[src]),%[res]\n\t"
>> +           "adcq 5*8(%[src]),%[res]\n\t"
>> +           "adcq 4*8(%[src]),%[res]\n\t"
>> +           "adcq 3*8(%[src]),%[res]\n\t"
>> +           "adcq 2*8(%[src]),%[res]\n\t"
>> +           "adcq 1*8(%[src]),%[res]\n\t"
>> +           "adcq 0*8(%[src]),%[res]\n\t"
>> +           "nop\n\t"
>> +           "40: adcq $0,%[res]"
>> +                   : [res] "=r" (sum)
>> +                   : [src] "r" (buff),
>> +                     [slen] "r" (-((unsigned long)(len >> 3))), "[res]" (sum)
>> +                   : "r11");
>> +
>
> With this patch I cannot mix/match different length checksums without
> things failing.  In perf the jmpq in the loop above seems to be set to
> a fixed value so perhaps it is something in how the compiler is
> interpreting the inline assembler.

The perf thing was a red herring.  Turns out the code is working
correctly there.

I actually found the root cause.  The problem is in add32_with_carry3.

> +static inline unsigned int add32_with_carry3(unsigned int a, unsigned int b,
> +                                            unsigned int c)
> +{
> +       asm("addl %2,%0\n\t"
> +           "adcl %3,%0\n\t"
> +           "adcl $0,%0"
> +           : "=r" (a)
> +           : "" (a), "rm" (b), "rm" (c));
> +
> +       return a;
> +}
> +

You need to set the 'a' input variable attribute to "0" instead of ""
and then things work for me correctly.

- Alex
