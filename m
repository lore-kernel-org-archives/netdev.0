From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH] csum: Update csum_block_add to use rotate
 instead of byteswap
Date: Wed, 9 Mar 2016 08:08:18 -0800
Message-ID: <CAKgT0UebO62GBsmL17JrZW0Ptzmr05buc1x6pHv6A_PAr4HBLQ@mail.gmail.com>
References: <20160308224238.16551.73881.stgit@localhost.localdomain>
	<1457479557.4067.9.camel@perches.com>
	<CAKgT0Uc94UgzzcNXeFDvA4NKJN78hi-n7d2ar9YFiR8yGhW8Gw@mail.gmail.com>
	<1457502647.4067.38.camel@perches.com>
	<CAKgT0Ud=X55Y9Cj-kO=px0DKSXYwYbza+UsVbNOJGVxHLaYM0w@mail.gmail.com>
	<CALx6S34WoWcK05J52q2z242Nyk7N1q9YjJDw7HsZ4s3VKWoonA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joe Perches <joe@perches.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:35301 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752645AbcCIQIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 11:08:19 -0500
Received: by mail-ig0-f171.google.com with SMTP id vf5so14978528igb.0
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 08:08:18 -0800 (PST)
In-Reply-To: <CALx6S34WoWcK05J52q2z242Nyk7N1q9YjJDw7HsZ4s3VKWoonA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 8, 2016 at 10:31 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Tue, Mar 8, 2016 at 10:08 PM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On Tue, Mar 8, 2016 at 9:50 PM, Joe Perches <joe@perches.com> wrote:
>>> On Tue, 2016-03-08 at 21:23 -0800, Alexander Duyck wrote:
>>>> On Tue, Mar 8, 2016 at 3:25 PM, Joe Perches <joe@perches.com> wrote:
>>>> > On Tue, 2016-03-08 at 14:42 -0800, Alexander Duyck wrote:
>>>> > > The code for csum_block_add was doing a funky byteswap to swap the even and
>>>> > > odd bytes of the checksum if the offset was odd.  Instead of doing this we
>>>> > > can save ourselves some trouble and just shift by 8 as this should have the
>>>> > > same effect in terms of the final checksum value and only requires one
>>>> > > instruction.
>>>> > 3 instructions?
>>>> I was talking about just the one ror vs mov, shl, shr, and ,and, add.
>>>>
>>>> I assume when you say 3 you are including the test and either some
>>>> form of conditional move or jump?
>>>
>>> Yeah, instruction count also depends on architecture (arm/x86/ppc...)
>>
>> Right.  But the general idea is that rotate is an instruction most
>> architectures have.  I haven't heard of an instruction that swaps even
>> and odd bytes of a 32 bit word.
>>
> Yes, I took a look inlining these.
>
> #define rol32(V, X) ({                          \
>         int word = V;                           \
>         if (__builtin_constant_p(X))            \
>                 asm("roll $" #X ",%[word]\n\t"  \
>                     : [word] "=r" (word));      \
>         else                                    \
>                 asm("roll %%cl,%[word]\n\t"     \
>                     : [word] "=r" (word)        \
>                     : "c" (X));                 \
>         word;                                   \
> })
>
> With this I'm seeing a nice speedup in jhash which uses a lot of rol32s...

Is gcc really not converting the rol32 calls into rotates?

If we need this type of code in order to get the rotates to occur as
expected then maybe we need to look at doing arch specific versions of
the functions in bitops.h in order to improve the performance since I
know these calls are used in some performance critical paths such as
crypto and hashing.

- Alex
