From: Jason Baron <jbaron@akamai.com>
Subject: Re: use-after-free in sctp_do_sm
Date: Thu, 3 Dec 2015 14:32:13 -0500
Message-ID: <566098BD.6010803@akamai.com>
References: <CACT4Y+ZnWRZfQC25uW=GXHAJB=GX0L6tJQUy43P6WNR3=hwT8Q@mail.gmail.com>
 <20151203130525.GB4164@mrl.redhat.com>
 <CACT4Y+ZMshfGvb81VhCGuZzbSec2sCBaJUNFb1QQ-ccyH9BPkQ@mail.gmail.com>
 <CANn89iKEv-q6EFi1eX+Hk_2+jNfZ0ayUqUn_Fh1U7RTs9xjdXg@mail.gmail.com>
 <CACT4Y+bgeqS05zqkAHkxzAP7fuvFSkeEybwDTizw6Gp8KK28Fw@mail.gmail.com>
 <CANn89i+d=mTJ-hAhhgPXsZPGAkQdECxRdbkeRLfozRq8i9Ms+g@mail.gmail.com>
 <CACT4Y+YJe-OJj9q1Kr5-_ApDt1UBKLjTRxhP62EHtEAwZt5vXw@mail.gmail.com>
 <f7twpsvgyar.fsf@aconole.bos.csb>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Joe Perches <joe@perches.com>
To: Aaron Conole <aconole@redhat.com>,
	Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175]:38989 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751618AbbLCTcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 14:32:19 -0500
In-Reply-To: <f7twpsvgyar.fsf@aconole.bos.csb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12/03/2015 01:52 PM, Aaron Conole wrote:
> Dmitry Vyukov <dvyukov@google.com> writes:
>> On Thu, Dec 3, 2015 at 6:02 PM, Eric Dumazet <edumazet@google.com> wrote:
>>> On Thu, Dec 3, 2015 at 7:55 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>>> On Thu, Dec 3, 2015 at 3:48 PM, Eric Dumazet <edumazet@google.com> wrote:
>>>>>>
>>>>>> No, I don't. But pr_debug always computes its arguments. See no_printk
>>>>>> in printk.h. So this use-after-free happens for all users.
>>>>>
>>>>> Hmm.
>>>>>
>>>>> pr_debug() should be a nop unless either DEBUG or
>>>>> CONFIG_DYNAMIC_DEBUG are set
>>>>>
>>>>> On our production kernels, pr_debug() is a nop.
>>>>>
>>>>> Can you double check ? Thanks !
>>>>
>>>>
>>>> Why should it be nop? no_printk thing in printk.h pretty much
>>>> explicitly makes it not a nop...
> 
> Because it was until commit 5264f2f75d8. It also violates my reading of
> the following from printk.h:
> 
>  * All of these will print unconditionally, although note that pr_debug()
>  * and other debug macros are compiled out unless either DEBUG is defined
>  * or CONFIG_DYNAMIC_DEBUG is set.
> 
>>>>
>>>> Double-checked: debug_post_sfx leads to some generated code:
>>>>
>>>>         debug_post_sfx();
>>>> ffffffff8229f256:       48 8b 85 58 fe ff ff    mov    -0x1a8(%rbp),%rax
>>>> ffffffff8229f25d:       48 85 c0                test   %rax,%rax
>>>> ffffffff8229f260:       74 24                   je
>>>> ffffffff8229f286 <sctp_do_sm+0x176>
>>>> ffffffff8229f262:       8b b0 a8 00 00 00       mov    0xa8(%rax),%esi
>>>> ffffffff8229f268:       48 8b 85 60 fe ff ff    mov    -0x1a0(%rbp),%rax
>>>> ffffffff8229f26f:       44 89 85 74 fe ff ff    mov    %r8d,-0x18c(%rbp)
>>>> ffffffff8229f276:       48 8b 78 20             mov    0x20(%rax),%rdi
>>>> ffffffff8229f27a:       e8 71 28 01 00          callq
>>>> ffffffff822b1af0 <sctp_id2assoc>
>>>> ffffffff8229f27f:       44 8b 85 74 fe ff ff    mov    -0x18c(%rbp),%r8d
>>>>
>>>>         return error;
>>>> }
>>>> ffffffff8229f286:       48 81 c4 a0 01 00 00    add    $0x1a0,%rsp
>>>> ffffffff8229f28d:       44 89 c0                mov    %r8d,%eax
>>>> ffffffff8229f290:       5b                      pop    %rbx
>>>> ffffffff8229f291:       41 5c                   pop    %r12
>>>> ffffffff8229f293:       41 5d                   pop    %r13
>>>> ffffffff8229f295:       41 5e                   pop    %r14
>>>> ffffffff8229f297:       41 5f                   pop    %r15
>>>> ffffffff8229f299:       5d                      pop    %rbp
>>>> ffffffff8229f29a:       c3                      retq
>>>
>>> This is a serious concern, because we let in the past lot of patches
>>> converting traditional
> 
> +1
> 
>>> #ifdef DEBUG
>>> # define some_hand_coded_ugly_debug()  printk( ...._
>>> #else
>>> # define some_hand_coded_ugly_debug()
>>> #endif
>>>
>>> On the premise pr_debug() would be a nop.
>>>
>>> It seems it is not always the case. This is a very serious problem.
> 
> +1
> 
>>> We probably have hundred of potential bugs, because few people
>>> actually make sure all debugging stuff is correct,
>>> like comments can be wrong because they are not updated properly as
>>> time flies.
>>>
>>> It is definitely a nop for many cases.
>>>
>>> +void eric_test_pr_debug(struct sock *sk)
>>> +{
>>> +       if (atomic_read(&sk->sk_omem_alloc))
>>> +               pr_debug("%s: optmem leakage for sock %p\n",
>>> +                        __func__, sk);
>>> +}
>>>
>>> ->
>>>
>>> 0000000000004740 <eric_test_pr_debug>:
>>>     4740: e8 00 00 00 00       callq  4745 <eric_test_pr_debug+0x5>
>>> 4741: R_X86_64_PC32 __fentry__-0x4
>>>     4745: 55                   push   %rbp
>>>     4746: 8b 87 24 01 00 00     mov    0x124(%rdi),%eax     //
>>> atomic_read()  but nothing follows
>>>     474c: 48 89 e5             mov    %rsp,%rbp
>>>     474f: 5d                   pop    %rbp
>>>     4750: c3                   retq
>>
>>
>>
>> I would expect that it is nop when argument evaluation does not have
>> side-effects. For example, for a load of a variable compiler will most
>> likely elide it (though, it does not have to elide it, because the
>> load is spelled in the code, so it can also legally emit the load and
>> doesn't use the result).
>> But if argument computation has side-effect (or compiler can't prove
>> otherwise), it must emit code. It must emit code for function calls
>> when the function is defined in a different translation unit, and for
>> volatile accesses (most likely including atomic accesses), etc
> 
> This isn't 100% true. As you state, in order to reach the return 0, all
> side effects must be evaluated. Load generally does not have side
> effects, so it can be safely elided, but function() must be emitted.
> 
> However, that is _not_ required to get the desired warning emission on a
> printf argument function, see http://pastebin.com/UHuaydkj for an
> example.
> 
> I think that as a minimum, the following patch should be evaluted, but am
> unsure to whom I should submit it (after I test):

Agreed - the intention here is certainly to have no side effects. It
looks like 'no_printk()' is used in quite a few other places that would
benefit from this change. So we probably want a generic
'really_no_printk()' macro.

Thanks,

-Jason

> 
> diff --git a/include/linux/printk.h b/include/linux/printk.h
> index 9729565..cd24d2d 100644
> --- a/include/linux/printk.h
> +++ b/include/linux/printk.h
> @@ -286,7 +286,7 @@ extern asmlinkage void dump_stack(void) __cold;
>         printk(KERN_DEBUG pr_fmt(fmt), ##__VA_ARGS__)
>  #else
>  #define pr_debug(fmt, ...) \
> -       no_printk(KERN_DEBUG pr_fmt(fmt), ##__VA_ARGS__)
> +       ({ if(0) printk(KERN_DEBUG pr_fmt(fmt), ##__VA_ARGS__); 0;})
>  #endif
>  
>  /*
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
