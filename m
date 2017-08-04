From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] samples/bpf: Fix cross compiler error with bpf sample
Date: Fri, 04 Aug 2017 20:44:43 +0200
Message-ID: <5984C09B.8090301@iogearbox.net>
References: <20170804054623.5229-1-joelaf@google.com> <59847D97.8080003@iogearbox.net> <CAJWu+oqY7KLbVGSmuedoZp0D9usXuP0JUfzws_aUt461M3gxQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        "open list:BPF (Safe dynamic programs and tools)"
        <netdev@vger.kernel.org>
To: Joel Fernandes <joelaf@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJWu+oqY7KLbVGSmuedoZp0D9usXuP0JUfzws_aUt461M3gxQA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/04/2017 08:33 PM, Joel Fernandes wrote:
> On Fri, Aug 4, 2017 at 6:58 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> On 08/04/2017 07:46 AM, Joel Fernandes wrote:
>>>
>>> When cross-compiling the bpf sample map_perf_test for aarch64, I find that
>>> __NR_getpgrp is undefined. This causes build errors. Fix it by allowing
>>> the
>>> deprecated syscall in the sample.
>>>
>>> Signed-off-by: Joel Fernandes <joelaf@google.com>
>>> ---
>>>    samples/bpf/map_perf_test_user.c | 2 ++
>>>    1 file changed, 2 insertions(+)
>>>
>>> diff --git a/samples/bpf/map_perf_test_user.c
>>> b/samples/bpf/map_perf_test_user.c
>>> index 1a8894b5ac51..6e6fc7121640 100644
>>> --- a/samples/bpf/map_perf_test_user.c
>>> +++ b/samples/bpf/map_perf_test_user.c
>>> @@ -8,7 +8,9 @@
>>>    #include <sched.h>
>>>    #include <stdio.h>
>>>    #include <sys/types.h>
>>> +#define __ARCH_WANT_SYSCALL_DEPRECATED
>>>    #include <asm/unistd.h>
>>> +#undef __ARCH_WANT_SYSCALL_DEPRECATED
>>
>>
>> So the only arch that sets __ARCH_WANT_SYSCALL_DEPRECATED
>> is score:
>>
>>    $ git grep -n __ARCH_WANT_SYSCALL_DEPRECATED
>>    arch/score/include/uapi/asm/unistd.h:7:#define
>> __ARCH_WANT_SYSCALL_DEPRECATED
>>    include/uapi/asm-generic/unistd.h:837:#ifdef
>> __ARCH_WANT_SYSCALL_DEPRECATED
>>    include/uapi/asm-generic/unistd.h:899:#endif /*
>> __ARCH_WANT_SYSCALL_DEPRECATED */
>>
>> But even if this would make aarch64 compile, the syscall
>> numbers don't match up:
>>
>>    $ git grep -n __NR_getpgrp include/uapi/asm-generic/unistd.h
>>    include/uapi/asm-generic/unistd.h:841:#define __NR_getpgrp 1060
>>    include/uapi/asm-generic/unistd.h:843:__SYSCALL(__NR_getpgrp, sys_getpgrp)
>>
>> The only thing that can be found on arm64 is:
>>
>>    $ git grep -n __NR_getpgrp arch/arm64/
>>    arch/arm64/include/asm/unistd32.h:154:#define __NR_getpgrp 65
>>    arch/arm64/include/asm/unistd32.h:155:__SYSCALL(__NR_getpgrp, sys_getpgrp)
>>
>> In arch/arm64/include/asm/unistd.h, it does include the
>> uapi/asm/unistd.h when compat is not set, but without the
>> __ARCH_WANT_SYSCALL_DEPRECATED. That doesn't look correct
>> unless I'm missing something, hmm, can't we just attach the
>> kprobes to a different syscall, one that is not deprecated,
>> so that we don't run into this in the first place?
>
> Yes, I agree that's better. I think we can use getpgid. I'll try to
> whip something today and send it out.

Ok, cool. Please make sure that this doesn't clash with anything
else attached to map_perf_test_kern.c already given the obj file
is loaded first with the attachment points.

> I also wanted to fix something else, HOSTCC is set to gcc, but I want
> the boostrap part of the sample to run an ARM so I have to make HOSTCC
> my cross-compiler. Right now I'm hacking it to point to the arm64 gcc
> however I think I'd like to add a 'cross compile mode' or something
> whether HOSTCC points to CROSS_COMPILE instead. I'm happy to discuss
> any ideas to get this fixed too.

Yeah, sounds like a good idea to add such possibility. In case of
cross compiling to a target arch with different endianess, you might
also need to specifically select bpfeb (big endian) resp. bpfel
(little endian) as clang target. (Just bpf target uses host endianess.)

Thanks, Joel!
