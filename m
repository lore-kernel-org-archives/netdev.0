From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next PATCH] csum: Update csum_block_add to use rotate
 instead of byteswap
Date: Wed, 9 Mar 2016 16:58:49 -0800
Message-ID: <CALx6S35OYdrFFVvYid7hA6iHJtW9B=FOuwR4L+EA6TWk5sP7qw@mail.gmail.com>
References: <20160308224238.16551.73881.stgit@localhost.localdomain>
	<1457479557.4067.9.camel@perches.com>
	<CAKgT0Uc94UgzzcNXeFDvA4NKJN78hi-n7d2ar9YFiR8yGhW8Gw@mail.gmail.com>
	<1457502647.4067.38.camel@perches.com>
	<CAKgT0Ud=X55Y9Cj-kO=px0DKSXYwYbza+UsVbNOJGVxHLaYM0w@mail.gmail.com>
	<CALx6S34WoWcK05J52q2z242Nyk7N1q9YjJDw7HsZ4s3VKWoonA@mail.gmail.com>
	<CAKgT0UebO62GBsmL17JrZW0Ptzmr05buc1x6pHv6A_PAr4HBLQ@mail.gmail.com>
	<1457569113.3433.7.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:37261 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754327AbcCJA6u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 19:58:50 -0500
Received: by mail-ig0-f182.google.com with SMTP id z8so6167098ige.0
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 16:58:50 -0800 (PST)
In-Reply-To: <1457569113.3433.7.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 9, 2016 at 4:18 PM, Joe Perches <joe@perches.com> wrote:
> On Wed, 2016-03-09 at 08:08 -0800, Alexander Duyck wrote:
>> On Tue, Mar 8, 2016 at 10:31 PM, Tom Herbert <tom@herbertland.com> wrote:
>> > I took a look inlining these.
>> >
>> > #define rol32(V, X) ({                          \
>> >         int word = V;                           \
>> >         if (__builtin_constant_p(X))            \
>> >                 asm("roll $" #X ",%[word]\n\t"  \
>> >                     : [word] "=r" (word));      \
>> >         else                                    \
>> >                 asm("roll %%cl,%[word]\n\t"     \
>> >                     : [word] "=r" (word)        \
>> >                     : "c" (X));                 \
>> >         word;                                   \
>> > })
>> >
>> > With this I'm seeing a nice speedup in jhash which uses a lot of rol32s...
>> Is gcc really not converting the rol32 calls into rotates?
>
> No, it is.
>
> The difference in the object code with the asm for instance is:
>
> (old, compiled with gcc 5.3.1)
>
> <jhash_2words.constprop.5>:
>      84e:       81 ee 09 41 52 21       sub    $0x21524109,%esi
>      854:       81 ef 09 41 52 21       sub    $0x21524109,%edi
>      85a:       55                      push   %rbp
>      85b:       89 f0                   mov    %esi,%eax
>      85d:       89 f2                   mov    %esi,%edx
>      85f:       48 ff 05 00 00 00 00    incq   0x0(%rip)        # 866 <jhash_2words.constprop.5+0x18>
>      866:       c1 c2 0e                rol    $0xe,%edx
>      869:       35 f7 be ad de          xor    $0xdeadbef7,%eax
>      86e:       48 89 e5                mov    %rsp,%rbp
>      871:       29 d0                   sub    %edx,%eax
>      873:       48 ff 05 00 00 00 00    incq   0x0(%rip)        # 87a <jhash_2words.constprop.5+0x2c>
>      87a:       48 ff 05 00 00 00 00    incq   0x0(%rip)        # 881 <jhash_2words.constprop.5+0x33>
>      881:       89 c2                   mov    %eax,%edx
>      883:       31 c7                   xor    %eax,%edi
>      885:       c1 c2 0b                rol    $0xb,%edx
>      888:       29 d7                   sub    %edx,%edi
>      88a:       89 fa                   mov    %edi,%edx
>      88c:       31 fe                   xor    %edi,%esi
>      88e:       c1 ca 07                ror    $0x7,%edx
>      891:       29 d6                   sub    %edx,%esi
>      893:       89 f2                   mov    %esi,%edx
>      895:       31 f0                   xor    %esi,%eax
>      897:       c1 c2 10                rol    $0x10,%edx
>      89a:       29 d0                   sub    %edx,%eax
>      89c:       89 c2                   mov    %eax,%edx
>      89e:       31 c7                   xor    %eax,%edi
>      8a0:       c1 c2 04                rol    $0x4,%edx
>      8a3:       29 d7                   sub    %edx,%edi
>      8a5:       31 fe                   xor    %edi,%esi
>      8a7:       c1 c7 0e                rol    $0xe,%edi
>      8aa:       29 fe                   sub    %edi,%esi
>      8ac:       31 f0                   xor    %esi,%eax
>      8ae:       c1 ce 08                ror    $0x8,%esi
>      8b1:       29 f0                   sub    %esi,%eax
>      8b3:       5d                      pop    %rbp
>      8b4:       c3                      retq
>
> vs Tom's asm
>
> 000000000000084e <jhash_2words.constprop.5>:
>      84e:       81 ee 09 41 52 21       sub    $0x21524109,%esi
>      854:       8d 87 f7 be ad de       lea    -0x21524109(%rdi),%eax
>      85a:       55                      push   %rbp
>      85b:       89 f2                   mov    %esi,%edx
>      85d:       48 ff 05 00 00 00 00    incq   0x0(%rip)        # 864 <jhash_2words.constprop.5+0x16>
>      864:       48 ff 05 00 00 00 00    incq   0x0(%rip)        # 86b <jhash_2words.constprop.5+0x1d>
>      86b:       81 f2 f7 be ad de       xor    $0xdeadbef7,%edx
>      871:       48 89 e5                mov    %rsp,%rbp
>      874:       c1 c1 0e                rol    $0xe,%ecx
>      877:       29 ca                   sub    %ecx,%edx
>      879:       31 d0                   xor    %edx,%eax
>      87b:       c1 c7 0b                rol    $0xb,%edi
>      87e:       29 f8                   sub    %edi,%eax
>      880:       48 ff 05 00 00 00 00    incq   0x0(%rip)        # 887 <jhash_2words.constprop.5+0x39>
>      887:       31 c6                   xor    %eax,%esi
>      889:       c1 c7 19                rol    $0x19,%edi
>      88c:       29 fe                   sub    %edi,%esi
>      88e:       31 f2                   xor    %esi,%edx
>      890:       c1 c7 10                rol    $0x10,%edi
>      893:       29 fa                   sub    %edi,%edx
>      895:       31 d0                   xor    %edx,%eax
>      897:       c1 c7 04                rol    $0x4,%edi
>      89a:       29 f8                   sub    %edi,%eax
>      89c:       31 f0                   xor    %esi,%eax
>      89e:       29 c8                   sub    %ecx,%eax
>      8a0:       31 d0                   xor    %edx,%eax
>      8a2:       5d                      pop    %rbp
>      8a3:       c1 c2 18                rol    $0x18,%edx
>      8a6:       29 d0                   sub    %edx,%eax
>      8a8:       c3                      retq
>
>> If we need this type of code in order to get the rotates to occur as
>> expected then maybe we need to look at doing arch specific versions of
>> the functions in bitops.h in order to improve the performance since I
>> know these calls are used in some performance critical paths such as
>> crypto and hashing.
>
> Yeah, maybe, but why couldn't gcc generate similar code
> as Tom's asm? (modulo the ripple reducing ror vs rol uses
> when the shift is > 16

I see gcc doing that now, not sure why I was seeing differences before....
