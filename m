From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next v2 5/5] net: filter: optimize BPF migration for
 ARG1/CTX handling
Date: Sat, 26 Apr 2014 11:06:10 -0700
Message-ID: <CAMEtUuxATmQEaEeQMQpn+nnPH=oZe0YB_mdw575pJ2WKcagdRQ@mail.gmail.com>
References: <1398321927-8845-1-git-send-email-dborkman@redhat.com>
	<1398321927-8845-6-git-send-email-dborkman@redhat.com>
	<20140424.160429.890390197318316554.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:60396 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781AbaDZSGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 14:06:12 -0400
Received: by mail-we0-f179.google.com with SMTP id x48so4774630wes.38
        for <netdev@vger.kernel.org>; Sat, 26 Apr 2014 11:06:10 -0700 (PDT)
In-Reply-To: <20140424.160429.890390197318316554.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 24, 2014 at 1:04 PM, David Miller <davem@davemloft.net> wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Thu, 24 Apr 2014 08:45:27 +0200
>
>> Currently, at initial setup in __sk_run_filter() we initialize the
>> BPF stack's frame-pointer and CTX register. However, instead of the
>> CTX register, we initialize context to ARG1, and during user filter
>> migration we emit *always* an instruction that copies the content
>> from ARG1 over to CTX. ARG1 is needed in BPF_CALL instructions to
>> setup ctx; for user BPF filter ARG2 has A, and ARG3 X for call
>> emission. However, we nevertheless copy CTX over to ARG1 in these
>> cases for user migrated filters. We can spare us this extra interpreter
>> instruction and assign it during initial setup time.
>>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>
> We're adjust code for facilities that aren't even used.
>
> I want someone to explain to me exactly how calls in and out of
> the EBPF context are expected to behave.
>
> There are so many cpu calling conventions.  Some use registers up
> to a certain number for passing arguments, then any overflow args
> go on the stack.  Some pass all args on the stack.
>
> How will all such schemes be accomodated by the BPF_CALL facilities?

calling convention was picked to cover common call situations
without performance penalty:
"R1-R5 - arguments to in-kernel function or to bpf program"

Calls from kernel into bpf are limited to one argument (in R1),
since that's what socket filters and seccomp use,
and tracing filters will be fine as well.
(can be extended in the future if needed).

Calls from bpf to kernel are limited to 5 arguments and all
in kernel helper functions look like:
u64 __bpf_helper_func(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
these functions may ignore some or all arguments,
(since on most architectures there is no penalty to ignore args
and negligible cost to pass them comparing to the rest of the program)

Calls from bpf to kernel with 6 or more arguments are not supported,
since they are rare in normal programs and would unnecessary
complicate code and JITs.
x86_64 passes first 6 arguments via registers and the rest on the stack,
other 64-bit architectures pass 7+ in registers.
So from JITs point of view passing 5 is straightforward and no messy
stack manipulations are necessary.

JIT to 32-bit CPUs is not easy,
since all ebpf registers are 64-bit, but underlying cpu is 32-bit,
JIT needs to do 64-bit arithmetic with 32-bit hw registers.
Can be an interesting project for someone with time on hands.
In any case ebpf interpreter is quite fast and well optimized.

32-bit JITs can use middle ground approach too.
If program contains only 32-bit arithmetic, jit it, otherwise let
interpreter run it.

btw the JIT of BPF_CALL to x86_64 looks like:
               case BPF_JMP | BPF_CALL:
                        func = (u8 *)__bpf_call_base + K;
                        jmp_offset = func - (image + addrs[i]);
                        if (!K || !is_simm32(jmp_offset)) {
                                pr_err(...);
                                return -EINVAL;
                        }
                        EMIT1_off32(0xE8, jmp_offset);
                        break;
it's really one to one.

> Until I personally can even begin to understand this, I'm not applying
> any more patches to these areas of the code, sorry.

Point taken.
We realize that documentation in filter.txt is not sufficient.
Last few days we've been working on extensive documentation update.
It should be ready by Monday or Tuesday.

Thank you
Alexei
