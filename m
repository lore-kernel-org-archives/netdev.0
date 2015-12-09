From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: bpf: undefined shift in __bpf_prog_run
Date: Wed, 09 Dec 2015 19:04:52 +0100
Message-ID: <56686D44.2060601@iogearbox.net>
References: <CACT4Y+ZxoR3UjLgcNdUm4fECLMx2VdtfrENMtRRCdgHB2n0bJA@mail.gmail.com> <20151204184333.GA42737@ast-mbp.thefacebook.com> <CACT4Y+YLV4scGXSFz=G3ACa-WE8VuT5wDGvPBV9D2Q+devxedA@mail.gmail.com> <20151204191013.GB45508@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>,
	Andrey Ryabinin <ryabinin.a.a@gmail.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151204191013.GB45508@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/04/2015 08:10 PM, Alexei Starovoitov wrote:
> On Fri, Dec 04, 2015 at 08:03:47PM +0100, Dmitry Vyukov wrote:
>>> is it with some random seccomp program?
>>> If normal libseccomp generates such programs than it needs to be fixed.
>>
>> Yes, it is with completely random seccomp program.
>>
>>>> Such shifts have undefined behavior according to C standard and behave
>>>> differently on different archs. I guess we don't want to rely on any
>>>> kind of undefined behavior in bpf/seccomp. And generally want to
>>>> completely define results of all operations in bpf.
>>>
>>> bpf is an engine and we're not going to slow down each shift operation
>>> by extra run-time checks or masks.
>>> In other words bpf shift instruction == shift in C. Both undefined
>>> with for large operands.
>>> If seccomp is relying on undefined behavior, it should be fixed.
>>
>> But note that it is not that result of such operation is undefined, it
>> is overall kernel behavior that becomes undefined.
>
> not true.
> just don't generate random bpf programs with such shifts.
> kernel is fine.

Kind of agree, so in case BPF JITs are being used, undefined behavior of the
C standard would not really apply here, imho. Sure, clang is the front end,
but the actual mapping from BPF to the arch opcode happens in kernel in that
case (and pre-checked by the verifier). What matters in that case is the
emission of the opcode itself from the BPF JIT compiler and the underlying
spec of the ISA.

F.e. while on x86 a shift count of > 31 resp. > 63 can be emitted by the
JIT for the related 32/64 bit operations, the count will be masked with 31
resp. 63 eventually by the HW. In other cases like ppc the result would be
different as the mask there is bigger.

In case not JITs but the BPF interpreter is being used (which is compiled
along with the kernel of course), we might need to consider it as "undefined
behavior" in the sense that gcc _could_ do insane things iff it really wanted
to for those cases. Given the interpreter is generic, gcc cannot make any
assumptions at compile time (wrt constants), disassembly on x86 looks similar
to what we do in JIT case. I think bailing out from the interpreter with
'return 0' seems equally bad/unexpected to me. I recall we had a similar
conversation here [1] on rol32() / ror32() and variants.

As this would only concern the interpreter itself, one option could be to reject
large constants (K) through the verifier and binary AND with upper shift limits
the register cases (w/o modifying JITs). That however would give a wrong impression
on the JIT developer (thinking he needs to copy this). Thus, I'd agree with others
iff gcc really decides to go crazy (and perhaps throw an exception or the like),
we need to address the interpreter. Perhaps we should add some test cases to
test_bpf.c on this to track the behavior.

   [1] https://lkml.org/lkml/2014/10/20/186
