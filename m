From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next] selftests/bpf: get rid of -D__x86_64__
Date: Thu, 4 May 2017 16:34:08 -0700
Message-ID: <5d1d290b-7ff7-7f9d-15a0-599596e0778c@fb.com>
References: <6a5fa930-cb76-8eee-94c7-7c5fe8fb8cdc@fb.com>
 <20170503.133512.310640909764585408.davem@davemloft.net>
 <d809baa4-c864-af99-38af-fbcb6637ca2b@fb.com>
 <20170504.093723.1592226593887244452.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:60762 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752377AbdEDXeb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 19:34:31 -0400
In-Reply-To: <20170504.093723.1592226593887244452.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/4/17 6:37 AM, David Miller wrote:
> From: Alexei Starovoitov <ast@fb.com>
> Date: Wed, 3 May 2017 20:30:22 -0700
>
>> I would buy that debian folks indeed care about multi-arch, but
>> what above does is making #include <linux/types.h> to be a nop
>> for any cross-compiler on sparc that included it.
>
> No, if you installed cross compiler for arch X it would add
> another stanza doing that "ifdef __ARCH__, include blah, endif"
> dance.
>
>> You're right that we cannot assume much about /usr/include craziness.
>> In that sense adding __native_arch__ macro is also wrong, since
>> it assumes sane /usr/include without inline asm or other things
>> that clang for bpf arch can consume.
>
> You can assume that it's for the ARCH we are trying to run tests
> for, which needs to be in the family of the kernel arch.
>
>> In that sense the only way to be independent from arch dependent
>> things in /usr/include is to put all arch specific headers
>> into our own dir in tools/selftests/ (or may be tools/bpf/include)
>> and point clang to that. I think the list of .h in there will be
>> limited. Only things like linux/types.h and gnu/stubs.h,
>> so it will be manageable.
>> Thoughts?
>
> No, this way lies madness.
>
> If you want to get the kernel headers, set up the proper environment
> instead of constantly trying to fight it.

We don't want to get kernel headers.
We made this mistake with samples/bpf/, since tracing actually needs
the headers to be able to call bpf_probe_read() with correct offsets.
This stuff just doesn't work on arm and not clear whether it's working
on other archs beyond x86.
For arm we had this -D__ASM_SYSREG_H hack, but it stopped working
and Andy tried to address it in [1], but it didn't go far.
So today samples/bpf/ are completely broken on arm and it's making
people believe that xdp and networking programs also need kernel
headers and also cannot work on arm, which is not the case at all.
Hence I don't want testing/selftests/bpf/ to have anything to do
with kernel headers and arch specific headers too.
All xdp programs are 90% arch independent. The only difference is
big vs little endian and clang solves this for us automatically,
since selftests's Makefile is using 'clang -target bpf' which
picks native endianness.
All headers included by tools/testing/selftests/bpf/test_*.c programs
shouldn't use anything arch specific.
They #include <linux/tcp.h> to get 'struct tcphdr' and things like
IPPROTO_IPIP and AF_INET6.
These headers should work seamlessly on all archs, but since such
headers typically do #include <linux/types.h> which is arch dependent
we get into the issue we're discussing.
We don't need native <linux/types.h>. Moreover it's incorrect to
use native types.h, since we're compiling to bpf bytecode which
is 64-bit and needs to see types.h with sizeof(void*)==8.
When we're compiling xdp programs on x86 we're compiling them
into bpf bytecode with little endian flavor. Nothing x86 specific
about it. The same bytecode will run on arm64.
That is the case for all networking programs.
Hence I think the cleanest solution is to have bpf arch's types.h
either installed with llvm/gcc or picked from selftests's dir.

Tracing side is quite different.
For example: samples/bpf/offwaketime_kern.c does:
struct task_struct *p = (void *) PT_REGS_PARM1(ctx);
u32 pid;
bpf_probe_read(&pid, sizeof(pid), &p->pid);

The '&p->pid' offset is arch and kernel specific, hence
not only we need kernel headers for the given architecture,
but autoconf.h of that specific kernel with correct kernel version too.

[1]
https://www.spinics.net/lists/arm-kernel/msg567602.html
