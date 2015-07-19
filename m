From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: Re: [PATCH v2] jhash: Deinline jhash, jhash2 and __jhash_nwords
Date: Sun, 19 Jul 2015 17:14:53 +0200
Message-ID: <55ABBEED.2000707@redhat.com>
References: <1437050416-13295-1-git-send-email-dvlasenk@redhat.com>	<CALx6S367jArRC3eKSKsv7gFrgPxyDHWdtvfeO1SmQR91eYxwSw@mail.gmail.com> <20150716.111729.822179499552193763.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, alexander.h.duyck@redhat.com,
	kadlec@blackhole.kfki.hu, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, tom@herbertland.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150716.111729.822179499552193763.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/16/2015 08:17 PM, David Miller wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Thu, 16 Jul 2015 08:43:25 -0700
> 
>> On Thu, Jul 16, 2015 at 5:40 AM, Denys Vlasenko <dvlasenk@redhat.com> wrote:
>>> This patch deinlines jhash, jhash2 and __jhash_nwords.
>>>
>>> It also removes rhashtable_jhash2(key, length, seed)
>>> because it was merely calling jhash2(key, length, seed).
>>>
>>> With this .config: http://busybox.net/~vda/kernel_config,
>>> after deinlining these functions have sizes and callsite counts
>>> as follows:
>>>
>>> __jhash_nwords: 72 bytes, 75 calls
>>> jhash: 297 bytes, 111 calls
>>> jhash2: 205 bytes, 136 calls
>>>
>> jhash is used in several places in the critical data path. Does the
>> decrease in text size justify performance impact of not inlining it?
> 
> Tom took the words right out of my mouth.
> 
> Denys, you keep making deinlining changes like this all the time, like
> a robot.  But I never see you make any effort to look into the performance
> nor code generation ramifications of your changes.

The performance impact of the call/ret pair on modern x86
CPUs is only 5 cycles. To make a real difference in execution
speed, the function has to be less than 100 bytes of code.

jhash and jhash2, at more than 200 bytes of code, are definitely
far too large for inlining. Here is the smaller of two, jhash2:

<jhash2>:
       8d 84 b2 ef be ad de    lea    -0x21524111(%rdx,%rsi,4),%eax
       55                      push   %rbp
       89 c1                   mov    %eax,%ecx
       48 89 e5                mov    %rsp,%rbp
       89 c2                   mov    %eax,%edx
       eb 62                   jmp    ffffffff81a0d204 <jhash2+0x73>
       03 47 08                add    0x8(%rdi),%eax
       03 17                   add    (%rdi),%edx
       83 ee 03                sub    $0x3,%esi
       03 4f 04                add    0x4(%rdi),%ecx
       48 83 c7 0c             add    $0xc,%rdi
       41 89 c0                mov    %eax,%r8d
       29 c2                   sub    %eax,%edx
       41 c1 c8 1c             ror    $0x1c,%r8d
       01 c8                   add    %ecx,%eax
       44 31 c2                xor    %r8d,%edx
       41 89 d0                mov    %edx,%r8d
       29 d1                   sub    %edx,%ecx
       01 c2                   add    %eax,%edx
       41 c1 c8 1a             ror    $0x1a,%r8d
       41 31 c8                xor    %ecx,%r8d
       44 89 c1                mov    %r8d,%ecx
       44 29 c0                sub    %r8d,%eax
       41 01 d0                add    %edx,%r8d
       c1 c9 18                ror    $0x18,%ecx
       31 c1                   xor    %eax,%ecx
       89 c8                   mov    %ecx,%eax
       29 ca                   sub    %ecx,%edx
       46 8d 0c 01             lea    (%rcx,%r8,1),%r9d
       c1 c8 10                ror    $0x10,%eax
       31 d0                   xor    %edx,%eax
       89 c1                   mov    %eax,%ecx
       41 29 c0                sub    %eax,%r8d
       42 8d 14 08             lea    (%rax,%r9,1),%edx
       c1 c9 0d                ror    $0xd,%ecx
       44 31 c1                xor    %r8d,%ecx
       89 c8                   mov    %ecx,%eax
       41 29 c9                sub    %ecx,%r9d
       01 d1                   add    %edx,%ecx
       c1 c8 1c                ror    $0x1c,%eax
       44 31 c8                xor    %r9d,%eax
       83 fe 03                cmp    $0x3,%esi
       77 99                   ja     ffffffff81a0d1a2 <jhash2+0x11>
       83 fe 02                cmp    $0x2,%esi
       74 0e                   je     ffffffff81a0d21c <jhash2+0x8b>
       83 fe 03                cmp    $0x3,%esi
       74 06                   je     ffffffff81a0d219 <jhash2+0x88>
       ff ce                   dec    %esi
       75 45                   jne    ffffffff81a0d25c <jhash2+0xcb>
       eb 06                   jmp    ffffffff81a0d21f <jhash2+0x8e>
       03 47 08                add    0x8(%rdi),%eax
       03 4f 04                add    0x4(%rdi),%ecx
       89 ce                   mov    %ecx,%esi
       03 17                   add    (%rdi),%edx
       31 c8                   xor    %ecx,%eax
       c1 ce 12                ror    $0x12,%esi
       29 f0                   sub    %esi,%eax
       89 c6                   mov    %eax,%esi
       31 c2                   xor    %eax,%edx
       c1 ce 15                ror    $0x15,%esi
       29 f2                   sub    %esi,%edx
       89 d6                   mov    %edx,%esi
       31 d1                   xor    %edx,%ecx
       c1 ce 07                ror    $0x7,%esi
       29 f1                   sub    %esi,%ecx
       89 ce                   mov    %ecx,%esi
       31 c8                   xor    %ecx,%eax
       c1 ce 10                ror    $0x10,%esi
       29 f0                   sub    %esi,%eax
       89 c6                   mov    %eax,%esi
       31 c2                   xor    %eax,%edx
       c1 ce 1c                ror    $0x1c,%esi
       29 f2                   sub    %esi,%edx
       31 d1                   xor    %edx,%ecx
       c1 ca 12                ror    $0x12,%edx
       29 d1                   sub    %edx,%ecx
       31 c8                   xor    %ecx,%eax
       c1 c9 08                ror    $0x8,%ecx
       29 c8                   sub    %ecx,%eax
       5d                      pop    %rbp
       c3                      retq

Yes, I do think that this much code should not be inlined.

__jhash_nwords is smaller and it is used for hashing 2 or 3 32-bit words,
it may be reasonable to inline it.
I'll send a new patch which keeps it inlined.

> Your changes potentially have large performance implications, yet you
> don't put any effort into considering that aspect at all.

I don't know why you think I'm some sort of zealot hell-bent
on deinlining everything. I'm not. I do listen to other people.

For example:
One of my patches was deninlining net_generic(), you proposed
to drop some BUG_ONs in it instead.
I wasn't insisting to have it "my way".
I sent you a patch which removed BUG_ON but left net_generic()
inlined, and you took the patch.
