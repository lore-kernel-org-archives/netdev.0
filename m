From: Eric Dumazet <edumazet@google.com>
Subject: Re: use-after-free in sctp_do_sm
Date: Thu, 3 Dec 2015 09:02:00 -0800
Message-ID: <CANn89i+d=mTJ-hAhhgPXsZPGAkQdECxRdbkeRLfozRq8i9Ms+g@mail.gmail.com>
References: <CACT4Y+ZnWRZfQC25uW=GXHAJB=GX0L6tJQUy43P6WNR3=hwT8Q@mail.gmail.com>
	<20151203130525.GB4164@mrl.redhat.com>
	<CACT4Y+ZMshfGvb81VhCGuZzbSec2sCBaJUNFb1QQ-ccyH9BPkQ@mail.gmail.com>
	<CANn89iKEv-q6EFi1eX+Hk_2+jNfZ0ayUqUn_Fh1U7RTs9xjdXg@mail.gmail.com>
	<CACT4Y+bgeqS05zqkAHkxzAP7fuvFSkeEybwDTizw6Gp8KK28Fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:37324 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095AbbLCRCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 12:02:03 -0500
Received: by wmww144 with SMTP id w144so30886645wmw.0
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 09:02:01 -0800 (PST)
In-Reply-To: <CACT4Y+bgeqS05zqkAHkxzAP7fuvFSkeEybwDTizw6Gp8KK28Fw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 3, 2015 at 7:55 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Thu, Dec 3, 2015 at 3:48 PM, Eric Dumazet <edumazet@google.com> wrote:
>>>
>>> No, I don't. But pr_debug always computes its arguments. See no_printk
>>> in printk.h. So this use-after-free happens for all users.
>>
>> Hmm.
>>
>> pr_debug() should be a nop unless either DEBUG or CONFIG_DYNAMIC_DEBUG are set
>>
>> On our production kernels, pr_debug() is a nop.
>>
>> Can you double check ? Thanks !
>
>
> Why should it be nop? no_printk thing in printk.h pretty much
> explicitly makes it not a nop...
>
> Double-checked: debug_post_sfx leads to some generated code:
>
>         debug_post_sfx();
> ffffffff8229f256:       48 8b 85 58 fe ff ff    mov    -0x1a8(%rbp),%rax
> ffffffff8229f25d:       48 85 c0                test   %rax,%rax
> ffffffff8229f260:       74 24                   je
> ffffffff8229f286 <sctp_do_sm+0x176>
> ffffffff8229f262:       8b b0 a8 00 00 00       mov    0xa8(%rax),%esi
> ffffffff8229f268:       48 8b 85 60 fe ff ff    mov    -0x1a0(%rbp),%rax
> ffffffff8229f26f:       44 89 85 74 fe ff ff    mov    %r8d,-0x18c(%rbp)
> ffffffff8229f276:       48 8b 78 20             mov    0x20(%rax),%rdi
> ffffffff8229f27a:       e8 71 28 01 00          callq
> ffffffff822b1af0 <sctp_id2assoc>
> ffffffff8229f27f:       44 8b 85 74 fe ff ff    mov    -0x18c(%rbp),%r8d
>
>         return error;
> }
> ffffffff8229f286:       48 81 c4 a0 01 00 00    add    $0x1a0,%rsp
> ffffffff8229f28d:       44 89 c0                mov    %r8d,%eax
> ffffffff8229f290:       5b                      pop    %rbx
> ffffffff8229f291:       41 5c                   pop    %r12
> ffffffff8229f293:       41 5d                   pop    %r13
> ffffffff8229f295:       41 5e                   pop    %r14
> ffffffff8229f297:       41 5f                   pop    %r15
> ffffffff8229f299:       5d                      pop    %rbp
> ffffffff8229f29a:       c3                      retq

This is a serious concern, because we let in the past lot of patches
converting traditional

#ifdef DEBUG
# define some_hand_coded_ugly_debug()  printk( ...._
#else
# define some_hand_coded_ugly_debug()
#endif

On the premise pr_debug() would be a nop.

It seems it is not always the case. This is a very serious problem.

We probably have hundred of potential bugs, because few people
actually make sure all debugging stuff is correct,
like comments can be wrong because they are not updated properly as time flies.

It is definitely a nop for many cases.

+void eric_test_pr_debug(struct sock *sk)
+{
+       if (atomic_read(&sk->sk_omem_alloc))
+               pr_debug("%s: optmem leakage for sock %p\n",
+                        __func__, sk);
+}

->

0000000000004740 <eric_test_pr_debug>:
    4740: e8 00 00 00 00       callq  4745 <eric_test_pr_debug+0x5>
4741: R_X86_64_PC32 __fentry__-0x4
    4745: 55                   push   %rbp
    4746: 8b 87 24 01 00 00     mov    0x124(%rdi),%eax     //
atomic_read()  but nothing follows
    474c: 48 89 e5             mov    %rsp,%rbp
    474f: 5d                   pop    %rbp
    4750: c3                   retq
