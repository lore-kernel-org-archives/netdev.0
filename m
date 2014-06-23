From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next 0/2] split BPF out of core networking
Date: Mon, 23 Jun 2014 14:57:53 -0700
Message-ID: <CAMEtUuwV3y4G5+kLQNXojn4vrLmub4JVf1RyZoRoNNnX8U_yJA@mail.gmail.com>
References: <1401692506-7796-1-git-send-email-ast@plumgrid.com>
	<538C3C94.3080206@redhat.com>
	<CAMEtUuzkjZCsReWH9cZs8AU0mJjZH9YOdCBTWusxe6-NZ9mQ=g@mail.gmail.com>
	<538CAEA6.4060307@redhat.com>
	<CAMEtUuwxJOgYgFjg9deQZOffeg6-JUGZXZ1Rj344eQmriQ0F0Q@mail.gmail.com>
	<538D8DAA.7090105@redhat.com>
	<CAMEtUuw8uyCGeLeUB0PXm5cCpqcsjPLZt6y9FcKjapbVPjWTuw@mail.gmail.com>
	<538E319B.3000606@redhat.com>
	<CAMEtUuzsHJioXZtuGje6UmwZmcmDZEn8PdkkYanA9j1sp242+Q@mail.gmail.com>
	<CA+ZOOTOfq705CbUjx9ppw4gLxJ8JFCaFsphwhAS+NskHVjd86Q@mail.gmail.com>
	<CAMEtUuxU_FKL4TJ2wJtOngean2RjjJxBbYpxNjJQKjA7HtU2Bg@mail.gmail.com>
	<CA+ZOOTOjRmj-C0tncH=j4ZJj8aMMVF1RLK-gQiSB6RG=G5Xo7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Chema Gonzalez <chema@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+ZOOTOjRmj-C0tncH=j4ZJj8aMMVF1RLK-gQiSB6RG=G5Xo7w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 20, 2014 at 9:44 AM, Chema Gonzalez <chema@google.com> wrote:
>>
>> Model eBPF based on MIPS ISA? Ouch.
>> That would be one ugly ISA that is not JITable on x64.
>
> Definitely I wasn't making my point clear: IMO if we're redesigning
> the BPF ISA, we should get a clean one (clean=something that is simple
> enough to be readable by a newcomer). I mentioned MIPS because it's
> the one I know the most, and it's kind of clean. I'm definitely not
> proposing to use MIPS as the BPF ISA.

mips is a clean isa? When it was designed 30 years ago, it was good,
but today it really shows its age: delay slots, integer arithmetic that
traps on overflow, lack of real comparison operations, hi/lo, etc.
I strongly believe eBPF isa is way cleaner and easier to understand
than mips isa.

It seems your proposals to make eBPF 'cleaner' are based on
HW mindset, which is not applicable here. Details below:

> 1. how we codify the ISA. Both BPF and eBPF devote 50% of the insn
> space to load/store (4 opcodes/instruction class values of 8
> possible). In comparison, MIPS uses just 14% (9 of 64 opcodes). That

that is a misleading comparison and leads to the wrong conclusions.
Your proposal to remove useful instruction just to save a bit in bpf
class encoding just doesn't make sense. We have infinite room to
add new instructions and opcodes. Unlike HW ISA eBPF is not
limited by 8-bit opcodes and 8-byte instructions. eBPF is not designed
to be run directly by HW, so we're not trying to save rtl gates here.
Among other things we're optimizing for interpreter performance,
so removing instructions can only hurt.

> gives me pause. I'm definitely not suggesting adding more insn just
> because physical ISAs have it, but I think it makes sense to avoid
> using the whole insn space just because it's there, or because classic
> BPF was using it all.

wrong. Classic BPF is a legacy that we have to live with and we
should not sacrifice performance of classic bpf filters just to reduce
number of eBPF instructions.
It made sense only for one classic instruction: BPF_LD + MSH
It is really single purpose instruction to do X = ip->length * 4.
We didn't carry this ugliness into eBPF, since it's not generic,
can be easily represented by generic instructions, complicates JITs.
Since MSH is used at most once per tcpdump filter, few extra
insns add a tiny penalty to overall filter execution time in interpreter
and give no performance penalty at all when filter is JITed.

> 2. instructions (sock_filter_int) hardcode 2 immediate values. This is
> very unusual in ISAs. We're effectively doubling the insn size (from
> 32 to 64 bits), and still we are cramming the whole insn space (only 1
> reserved instruction class of 8 possible ones). The rationale is to

Comparisons with HW encoding is not applicable.
mips picked 4 byte wide instruction and had to live with it. Just look
at hi/lo insns and what compilers have to do with it.
All eBPF instructions today are 8 byte wide. There is no reason
to redesign them into <8 bytes or squeeze bits. It will hurt
performance without giving us anything back.
At the same time we can add 16-byte instruction to represent
load 64-bit immediate, but as I was saying before many factors
need to be considered before we proceed.

> 3. name reuse: we're reusing names b etween classic BPF and eBPF. For
> example, BPF_LD*|BPF_MEM in classic BPF refers to access to the M[]
> buffer. BPF_LDX|BPF_MEM in eBPF is a generic memory access. I find
> this very confusing, especially because we'll have to live with

That's one opinion. I think names are fine and
Documentation/networking/filter.txt explains both classic and eBPF
encoding well enough.

> classic BPF in userland filters for a long time. In fact, if you ask
> me, I'll come up with some generic name for the generic linux
> filtering mechanism (eBPF and internal BPF sound too much like BPF),
> to make it clear that this is not just BPF.

I don't think it's a good idea. I like BPF abbreviation, since the name
implies the use case. Renaming eBPF to ISA_X will be confusing.
Now everyone understands that BPF is a safe instruction set that
can be dynamically loaded into the kernel. eBPF is the same
plus more.

> 4. simplicity: both BPF and eBPF have 4 ld/st operations types (LD,
> LDX, ST, STX) and many addressing modes/modifiers (6 for BPF, 4 for
> eBPF), where only a subset of the {operation types, modifier} tuples
> are valid. I think we can make it simpler. For the eBPF case, we
> currently have 6 valid combinations:

That's a good summary. I think documentation explained it already,
but if you feel it's still missing pieces, please send a patch to
improve the doc.

> The two eBPF BPF_LD insn are BPF_LDX|BPF_MEM insn to access an skbuff.
> For example, BPF_LD|BPF_ABS does "dst_reg = packet[imm32]", which is a
> BPF_LDX|BPF_MEM with the following differences:
> a. packet is skb->data == CTX == BPF_R6 (this is equivalent to
> src_reg==R6 in BPF_LDX|BPF_MEM)
> b. output is left in R0, not in dst_reg
> c. result is ntohs()|ntohl()
> d. every packet access is checked using
> load_pointer()/skb_header_pointer()/bpf_internal_load_pointer_neg_helper()
>
> Now, (a,b,c) seem like details that should be worked with multiple
> instructions (in fact the x86 JIT does that).

and penalize performance of converted classic filters?? No.
LD+ABS and LD+IND must stay as-is, since these two are most
commonly used instructions in tcpdump filters and we cannot
split them even in two instruction without degrading performance.

> The BPF_LD|BPF_IND insn could be replaced in 2 steps, one to get
> src_reg+imm32 into a tmp register, and the other to perform the final
> load based on the tmp register.

nope. it's a critical path instruction. we cannot split it into two or
performance will suffer.

> 4.5. BPF_ST|BPF_MEM
> Operation: *(size *) (dst_reg + off16) = imm32
>
> This insn encodes 2 immediate values (the offset and the imm32 value)
> in the insn, and actually forces the sock_filter_int 64-bit struct to
> have both a 16-bit offset field and a 32-bit immediate field). In
> fact, it's the only instructions that uses .off and .imm at the same
> time (for all other instructions, at least one of the fields is always
> 0).

I've considered not introducing BPF_ST_MEM in the first place,
but then decided to add it to improve code for stack initialization.
Majority of cpus have *(u32*)(stack - offset) = 0 instruction (even mips
has it, since it has register zero), and this instruction is used a lot
to initialize variables on stack. Obviously two instructions can be
used instead (BPF_MOV_IMM + BPF_STX_MEM), but having one
instruction improves interpreter performance, so here we have
BPF_ST_MEM.

> immediate suffixes. I wonder whether the ISA would be more readable if
> we did this in 2 insn, one to put dst_reg+off16 in a temporary
> register, and the second a simpler BPF_STX|BPF_MEM. Then we could use
> the same space for the immediate and offset fields.

There is no reason to squeeze bits or reduce instruction size. It will
only make things more complex and slower. If you disagree, please
rewrite interpreter, converter, compiler backends, JIT and
measure performance on variety of programs. Then we'll have
facts to talk about. So far I don't like any of these proposals.

>>>   - nop: I'd like to have a nop. Do I know why? Nope.
>> nope. Let's not add unnecessary instructions.
> A valid nop is a useful instruction: padding, filling up arrays of
> sock_filter_int correctly (as in lib/test_bpf.c, where we're currently
> using a "ld #0", which loads zero to register A), and other use cases
> (see http://en.wikipedia.org/wiki/NOP ).

especially I don't like to add 'nop' instruction.
code==0 to mean 'ld #0' is one of classic BPF ugliness.
We're not filling up arrays with nops in lib/test_bpf.c
Zero is invalid opcode in eBPF and should stay so, since it's
an easy check for humans like me who are looking at eBPF in hex.

Thanks
Alexei
