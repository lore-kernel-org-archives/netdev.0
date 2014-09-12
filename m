From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v11 net-next 00/12] eBPF syscall, verifier, testsuite
Date: Thu, 11 Sep 2014 18:17:15 -0700
Message-ID: <CALCETrXqwd=dp31fckMPruQMwVw+UAjaf=SSWp8wr_Cdz_tQdw@mail.gmail.com>
References: <1410325808-3657-1-git-send-email-ast@plumgrid.com>
 <541013CE.6020307@redhat.com> <CAMEtUuwrHX4ENK9cZ0C+XVB=wkMz1=wLphX_GVLvd8pyJKMXeQ@mail.gmail.com>
 <5411FC42.3070505@redhat.com> <CAMEtUuziPptHxtw_7fkOdR-paB+8BatNmRPoo3txP8wOp9D6Tw@mail.gmail.com>
 <CALCETrWCEwscbbfX7wAW-A+VQ5Y92igD36BmTXqFra04Qdwk0Q@mail.gmail.com> <CAMEtUuyzOgCZutgsAXs60BO0=0WJGpVAeTYN2hf0Bh1sZ5PMVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linuxfoundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuyzOgCZutgsAXs60BO0=0WJGpVAeTYN2hf0Bh1sZ5PMVg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 11, 2014 at 3:29 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On Thu, Sep 11, 2014 at 2:54 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>>>
>>> the verifier log contains full trace. Last unsafe instruction + error
>>> in many cases is useless. What we found empirically from using
>>> it over last 2 years is that developers have different learning curve
>>> to adjust to 'safe' style of C. Pretty much everyone couldn't
>>> figure out why program is rejected based on last error. Therefore
>>> verifier emits full log. From the 1st insn all the way till the last
>>> 'unsafe' instruction. So the log is multiline output.
>>> 'Understanding eBPF verifier messages' section of
>>> Documentation/networking/filter.txt provides few trivial
>>> examples of these multiline messages.
>>> Like for the program:
>>>   BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
>>>   BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
>>>   BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
>>>   BPF_LD_MAP_FD(BPF_REG_1, 0),
>>>   BPF_CALL_FUNC(BPF_FUNC_map_lookup_elem),
>>>   BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
>>>   BPF_ST_MEM(BPF_DW, BPF_REG_0, 4, 0),
>>>   BPF_EXIT_INSN(),
>>> the verifier log_buf is:
>>>   0: (7a) *(u64 *)(r10 -8) = 0
>>>   1: (bf) r2 = r10
>>>   2: (07) r2 += -8
>>>   3: (b7) r1 = 0
>>>   4: (85) call 1
>>>   5: (15) if r0 == 0x0 goto pc+1
>>>    R0=map_ptr R10=fp
>>>   6: (7a) *(u64 *)(r0 +4) = 0
>>>   misaligned access off 4 size 8
>>>
>>> It will surely change over time as verifier becomes smarter,
>>> supports new types, optimizations and so on.
>>> So this log is not an ABI. It's for humans to read.
>>> The log explains _how_ verifier came to conclusion
>>> that the program is unsafe.
>>
>> Given that you've already arranged (I think) for the verifier to be
>> compilable in the kernel and in userspace, would it make more sense to
>> have the kernel version just say yes or no and to make it easy for
>> user code to retry verification in userspace if they want a full
>> explanation?
>
> Good memory :) Long ago I had a hack where I compiled
> verifier.o for kernel and linked it with userspace wrappers to
> have the same verifier for userspace. It was very fragile.
> and maps were not separate objects and there were no fds.
> It's not feasible anymore, since different subsystems
> will configure different bpf_context and helper functions and
> verifier output is dynamic based on maps that were created.
> For example, if user's samples/bpf/sock_example.c does
> bpf_create_map(HASH, sizeof(key) * 2, ...);
> instead of
> bpf_create_map(HASH, sizeof(key), ...);
> the same program will be rejected in first case and will be
> accepted in the second, because map sizes and ebpf
> program expectations are mismatching.

Hmm.

This actually furthers my thought that the relocations should be a
real relocation table.  Then you could encode the types of the
referenced objects in the table, and a program could be verified
without looking up the fds.  The only extra step would be to confirm
that the actual types referenced match those in the table.

--Andy
