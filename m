From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH RFC v4 net-next 01/26] net: filter: add "load 64-bit
 immediate" eBPF instruction
Date: Wed, 13 Aug 2014 11:35:44 -0700
Message-ID: <CALCETrXfp+7FmEzAoLiqzqY73NBzt8JsD40hzvhT3=gr-Scp=g@mail.gmail.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
 <1407916658-8731-2-git-send-email-ast@plumgrid.com> <CALCETrXzZVxMGUgDPOKwN0DPLvupU=ew1z6D4U-jHg+RoyZyLg@mail.gmail.com>
 <CAMEtUuxog0w-XkYMHM=Zto_gejy8x5agxohAWOs1zPEtXTr0Sw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuxog0w-XkYMHM=Zto_gejy8x5agxohAWOs1zPEtXTr0Sw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 13, 2014 at 10:44 AM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On Wed, Aug 13, 2014 at 9:08 AM, Andy Lutomirski <luto@amacapital.net> wrote:
>> On Wed, Aug 13, 2014 at 12:57 AM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>>> add BPF_LD_IMM64 instruction to load 64-bit immediate value into register.
>>> All previous instructions were 8-byte. This is first 16-byte instruction.
>>> Two consecutive 'struct bpf_insn' blocks are interpreted as single instruction:
>>> insn[0/1].code = BPF_LD | BPF_DW | BPF_IMM
>>> insn[0/1].dst_reg = destination register
>>> insn[0].imm = lower 32-bit
>>> insn[1].imm = upper 32-bit
>>
>> This might be unnecessarily difficult for fancy static analysis tools
>> to reason about.  Would it make sense to assign two different codes
>> for this?  For example, insn[0].code = code_for_load_low,
>> insns[1].code = code_for_load_high, along with a verifier check that
>> they come in matched pairs and that code_for_load_high isn't a jump
>> target?
>
> see my reply to David for the same thing. Short answer is that
> sequence of instructions (even if it is a pair of instructions like this)
> is very hard to detect in verifier and JITs.
> As soon as we give compiler two instructions instead of one,
> compiler may optimize them in a fancy ways. Like two loads of
> 64-bit immediate with upper 32-bit the same, may came out as
> 4 instructions: load_high, load_low, load_low, mov.
> Or in some cases as single load_low, etc.
> load 64-bit imm has to stay as single instruction to be verifiable
> and patch-able easily.
> One can argue: force compiler to emit load_low and load_hi
> always together, but then that's exactly what I have. It's a single insn.

The compiler can still think of it as a single insn, though, but some
future compiler might not.  In any case, I think that, if you use the
same code for high and for low, you need logic in the JIT that's at
least as complicated.  For example, what happens if you have two
consecutive 64-bit immediate loads to the same register?  Now you have
four consecutive 8-byte insn words that differ only in their immediate
values, and you need to split them correctly.

>
>> (Something else that I find confusing about eBPF: the instruction
>> mnemonics are very strange.  Have you considered giving them real
>> names?  For example, load.imm.low instead of BPF_LD | BPF_DW | BPF_IMM
>> is easier to read and pronounce.)
>
> BPF_LD | BPF_DW | BPF_IMM is not really a name. It's macro
> for cases when instructions are generated from inside the kernel.
> Instructions mnemonics are not defined yet.
> llvm emits assembler code like:
> bpf_prog2:
>   ldw r1, 16(r1)
>   std -8(r10), r1
>   mov r1, 1
>   std -16(r10), r1
>   ld_64 r1, 1
>   mov r2, r10
>   addi r2, -8
>   call 4
>   jeqi r0, 0 goto .LBB1_2
>   ldd r1, 0(r0)
>   addi r1, 1
>   std 0(r0), r1
> .LBB1_3:
>   mov r0, 0
>   ret
> ...
> I'm open to change assembler/disassembler mnemonics.

Ah, ok.  I didn't realize that there were mnemonics at all.

--Andy

-- 
Andy Lutomirski
AMA Capital Management, LLC
