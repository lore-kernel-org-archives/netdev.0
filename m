From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH RFC v4 net-next 01/26] net: filter: add "load 64-bit
 immediate" eBPF instruction
Date: Wed, 13 Aug 2014 10:44:04 -0700
Message-ID: <CAMEtUuxog0w-XkYMHM=Zto_gejy8x5agxohAWOs1zPEtXTr0Sw@mail.gmail.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
	<1407916658-8731-2-git-send-email-ast@plumgrid.com>
	<CALCETrXzZVxMGUgDPOKwN0DPLvupU=ew1z6D4U-jHg+RoyZyLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrXzZVxMGUgDPOKwN0DPLvupU=ew1z6D4U-jHg+RoyZyLg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 13, 2014 at 9:08 AM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
> On Wed, Aug 13, 2014 at 12:57 AM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>> add BPF_LD_IMM64 instruction to load 64-bit immediate value into register.
>> All previous instructions were 8-byte. This is first 16-byte instruction.
>> Two consecutive 'struct bpf_insn' blocks are interpreted as single instruction:
>> insn[0/1].code = BPF_LD | BPF_DW | BPF_IMM
>> insn[0/1].dst_reg = destination register
>> insn[0].imm = lower 32-bit
>> insn[1].imm = upper 32-bit
>
> This might be unnecessarily difficult for fancy static analysis tools
> to reason about.  Would it make sense to assign two different codes
> for this?  For example, insn[0].code = code_for_load_low,
> insns[1].code = code_for_load_high, along with a verifier check that
> they come in matched pairs and that code_for_load_high isn't a jump
> target?

see my reply to David for the same thing. Short answer is that
sequence of instructions (even if it is a pair of instructions like this)
is very hard to detect in verifier and JITs.
As soon as we give compiler two instructions instead of one,
compiler may optimize them in a fancy ways. Like two loads of
64-bit immediate with upper 32-bit the same, may came out as
4 instructions: load_high, load_low, load_low, mov.
Or in some cases as single load_low, etc.
load 64-bit imm has to stay as single instruction to be verifiable
and patch-able easily.
One can argue: force compiler to emit load_low and load_hi
always together, but then that's exactly what I have. It's a single insn.

> (Something else that I find confusing about eBPF: the instruction
> mnemonics are very strange.  Have you considered giving them real
> names?  For example, load.imm.low instead of BPF_LD | BPF_DW | BPF_IMM
> is easier to read and pronounce.)

BPF_LD | BPF_DW | BPF_IMM is not really a name. It's macro
for cases when instructions are generated from inside the kernel.
Instructions mnemonics are not defined yet.
llvm emits assembler code like:
bpf_prog2:
  ldw r1, 16(r1)
  std -8(r10), r1
  mov r1, 1
  std -16(r10), r1
  ld_64 r1, 1
  mov r2, r10
  addi r2, -8
  call 4
  jeqi r0, 0 goto .LBB1_2
  ldd r1, 0(r0)
  addi r1, 1
  std 0(r0), r1
.LBB1_3:
  mov r0, 0
  ret
...
I'm open to change assembler/disassembler mnemonics.
