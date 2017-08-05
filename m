From: Joel Fernandes <joelaf@google.com>
Subject: Re: [PATCH] samples/bpf: Fix cross compiler error with bpf sample
Date: Sat, 5 Aug 2017 11:53:04 -0700
Message-ID: <CAJWu+orP-oej1jJchOqfW=ZHK5eacyYRtNVHGZ+axob4LjjOAQ@mail.gmail.com>
References: <20170804054623.5229-1-joelaf@google.com> <59847D97.8080003@iogearbox.net>
 <CAJWu+oqY7KLbVGSmuedoZp0D9usXuP0JUfzws_aUt461M3gxQA@mail.gmail.com> <5984C09B.8090301@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: LKML <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        "open list:BPF (Safe dynamic programs and tools)"
        <netdev@vger.kernel.org>, Marc Zyngier <marc.zyngier@arm.com>,
        Will Deacon <will.deacon@arm.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5984C09B.8090301@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Daniel,

<snip>
>>>
>>> So the only arch that sets __ARCH_WANT_SYSCALL_DEPRECATED
>>> is score:
>>>
>>>    $ git grep -n __ARCH_WANT_SYSCALL_DEPRECATED
>>>    arch/score/include/uapi/asm/unistd.h:7:#define
>>> __ARCH_WANT_SYSCALL_DEPRECATED
>>>    include/uapi/asm-generic/unistd.h:837:#ifdef
>>> __ARCH_WANT_SYSCALL_DEPRECATED
>>>    include/uapi/asm-generic/unistd.h:899:#endif /*
>>> __ARCH_WANT_SYSCALL_DEPRECATED */
>>>
>>> But even if this would make aarch64 compile, the syscall
>>> numbers don't match up:
>>>
>>>    $ git grep -n __NR_getpgrp include/uapi/asm-generic/unistd.h
>>>    include/uapi/asm-generic/unistd.h:841:#define __NR_getpgrp 1060
>>>    include/uapi/asm-generic/unistd.h:843:__SYSCALL(__NR_getpgrp,
>>> sys_getpgrp)
>>>
>>> The only thing that can be found on arm64 is:
>>>
>>>    $ git grep -n __NR_getpgrp arch/arm64/
>>>    arch/arm64/include/asm/unistd32.h:154:#define __NR_getpgrp 65
>>>    arch/arm64/include/asm/unistd32.h:155:__SYSCALL(__NR_getpgrp,
>>> sys_getpgrp)
>>>
>>> In arch/arm64/include/asm/unistd.h, it does include the
>>> uapi/asm/unistd.h when compat is not set, but without the
>>> __ARCH_WANT_SYSCALL_DEPRECATED. That doesn't look correct
>>> unless I'm missing something, hmm, can't we just attach the
>>> kprobes to a different syscall, one that is not deprecated,
>>> so that we don't run into this in the first place?
>>
>>
>> Yes, I agree that's better. I think we can use getpgid. I'll try to
>> whip something today and send it out.

So switching to getppid fixes it, however most of the _kern.o BPF
samples still don't build on aarch64 for me.

The trouble is with inline assembler statements in the ARM64 asm
include headers (which I think upsets LLVM/clang when building for the
BPF target).

Also about skipping headers to fix this, currently we pass
-D__ASM_SYSREG_H from samples/bpf/Makefile so that inline assembler
statements are skipped (this was added in 2015 to this file). However,
not including this causes build errors at the moment. So as sysreg.h
isn't included, the SYS_MIDR_EL1 macro from
arch/arm64/include/asm/sysreg.h is missing causing this build error.
This caused by an include originating from skbuff.h :

In file included from samples/bpf/map_perf_test_kern.c:7:
In file included from ./include/linux/skbuff.h:17:
In file included from ./include/linux/kernel.h:13:
In file included from ./include/linux/printk.h:8:
In file included from ./include/linux/cache.h:5:
In file included from ./arch/arm64/include/asm/cache.h:19:
./arch/arm64/include/asm/cputype.h:119:9: error: use of undeclared
identifier 'SYS_MPIDR_EL1'
        return read_cpuid(MPIDR_EL1);
               ^

There are other paths too like mm.h including asm/pgtable.h which
breaks because of the inline assembler issues.

In file included from samples/bpf/map_perf_test_kern.c:7:
In file included from ./include/linux/skbuff.h:34:
In file included from ./include/linux/dma-mapping.h:10:
In file included from ./include/linux/scatterlist.h:7:
In file included from ./include/linux/mm.h:70:
./arch/arm64/include/asm/pgtable.h:607:9: error: value
'18446744073709550591' out of range for constraint 'L'
        : "L" (~PTE_AF), "I" (ilog2(PTE_AF)));


I believe the main problem here is we are trying to build for BPF
target while including ARM64 asm headers (which I think we can't
avoid?). I was thinking of just setting ARCH to x86 when compiling the
_kern.o parts of the bpf samples. However that doesn't make sense as
we probably need to be arch aware in the samples?

I am at a loss at the moment for ideas. I would love to get any other
ideas - how does x86 solve this issue?. I tried doing something like:
skip as many asm headers using the -D trick,  passing "-include
<stubs.h>" and defining as many things as I can in stubs.h as noops.
However I got stuck with that idea when I hit the above mm build
error.

I am also CC'ing some ARM64 folks as well for any thoughts, I am
looking forward to getting the samples working on my arm64 platform.

Thanks!

Best,

-Joel




>
> Ok, cool. Please make sure that this doesn't clash with anything
> else attached to map_perf_test_kern.c already given the obj file
> is loaded first with the attachment points.
>
>> I also wanted to fix something else, HOSTCC is set to gcc, but I want
>> the boostrap part of the sample to run an ARM so I have to make HOSTCC
>> my cross-compiler. Right now I'm hacking it to point to the arm64 gcc
>> however I think I'd like to add a 'cross compile mode' or something
>> whether HOSTCC points to CROSS_COMPILE instead. I'm happy to discuss
>> any ideas to get this fixed too.
>
>
> Yeah, sounds like a good idea to add such possibility. In case of
> cross compiling to a target arch with different endianess, you might
> also need to specifically select bpfeb (big endian) resp. bpfel
> (little endian) as clang target. (Just bpf target uses host endianess.)
>
> Thanks, Joel!
