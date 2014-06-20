From: Chema Gonzalez <chema@google.com>
Subject: Re: [PATCH v2 net-next 0/2] split BPF out of core networking
Date: Fri, 20 Jun 2014 09:44:43 -0700
Message-ID: <CA+ZOOTOjRmj-C0tncH=j4ZJj8aMMVF1RLK-gQiSB6RG=G5Xo7w@mail.gmail.com>
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
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuxU_FKL4TJ2wJtOngean2RjjJxBbYpxNjJQKjA7HtU2Bg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Sorry for the delay in the answer. Been mired somewhere else.]

On Tue, Jun 3, 2014 at 5:38 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On Tue, Jun 3, 2014 at 2:40 PM, Chema Gonzalez <chema@google.com> wrote:
>> First of all, and just to join the crowd, kernel/bpf/ FTW.
>>
>> Now, I have some suggestions about eBPF. IMO classic BPF is an ISA
>> oriented to filter (meaning returning a single integer that states how
>> many bytes of the packet must be captured) packets (e.g. consider the
>> 6 load modes, where 3 provide access the packet -- abs, ind, msh --,
>> one to an skb field -- len--, the 5th one to the memory itself -- mem
>> --, and the 6th is an immediate set mode --imm-- ) that has been used
>> in other environments (seccomp, tracing, etc.) by (a) extending the
>> idea of a "packet" into a "buffer", and (b) adding ancillary loads.
>>
>> eBPF should be a generic ISA that can be used by many environments,
>> including those served today by classic BPF. IMO, we should get a
>> nicely-defined ISA (MIPS anyone?) and check what should go into eBPF
>> and what should not.
>
> Model eBPF based on MIPS ISA? Ouch.
> That would be one ugly ISA that is not JITable on x64.

Definitely I wasn't making my point clear: IMO if we're redesigning
the BPF ISA, we should get a clean one (clean=something that is simple
enough to be readable by a newcomer). I mentioned MIPS because it's
the one I know the most, and it's kind of clean. I'm definitely not
proposing to use MIPS as the BPF ISA.

In particular, I have 4 cleanliness concerns related to load/stores:

1. how we codify the ISA. Both BPF and eBPF devote 50% of the insn
space to load/store (4 opcodes/instruction class values of 8
possible). In comparison, MIPS uses just 14% (9 of 64 opcodes). That
gives me pause. I'm definitely not suggesting adding more insn just
because physical ISAs have it, but I think it makes sense to avoid
using the whole insn space just because it's there, or because classic
BPF was using it all.

2. instructions (sock_filter_int) hardcode 2 immediate values. This is
very unusual in ISAs. We're effectively doubling the insn size (from
32 to 64 bits), and still we are cramming the whole insn space (only 1
reserved instruction class of 8 possible ones). The rationale is to
support a new addressing mode (BPF_ST|BPF_MEM), where both the offset
to src_reg and the immediate value are hardcoded in the insn. (See
more below.)

3. name reuse: we're reusing names b etween classic BPF and eBPF. For
example, BPF_LD*|BPF_MEM in classic BPF refers to access to the M[]
buffer. BPF_LDX|BPF_MEM in eBPF is a generic memory access. I find
this very confusing, especially because we'll have to live with
classic BPF in userland filters for a long time. In fact, if you ask
me, I'll come up with some generic name for the generic linux
filtering mechanism (eBPF and internal BPF sound too much like BPF),
to make it clear that this is not just BPF.

4. simplicity: both BPF and eBPF have 4 ld/st operations types (LD,
LDX, ST, STX) and many addressing modes/modifiers (6 for BPF, 4 for
eBPF), where only a subset of the {operation types, modifier} tuples
are valid. I think we can make it simpler. For the eBPF case, we
currently have 6 valid combinations:

4.1. BPF_LDX|BPF_MEM
Operation: dst_reg = *(size *) (src_reg + off16)

This is the basic load insn. It's used to convert most of the classic
BPF addressing modes by setting the right src_reg (FP in the classic
BPF M[] access, CTX for the classic BPF BPF_LD*|BPF_LEN access and
seccomp_data access, etc.)

4.2. BPF_LD|BPF_ABS
Operation: BPF_R0 = ntoh<size>(*(size *) (skb->data + imm32))

4.3. BPF_LD|BPF_IND
Operation: BPF_R0 = ntoh<size>(*(size *) (skb->data + src_reg + imm32))

The two eBPF BPF_LD insn are BPF_LDX|BPF_MEM insn to access an skbuff.
For example, BPF_LD|BPF_ABS does "dst_reg = packet[imm32]", which is a
BPF_LDX|BPF_MEM with the following differences:
a. packet is skb->data == CTX == BPF_R6 (this is equivalent to
src_reg==R6 in BPF_LDX|BPF_MEM)
b. output is left in R0, not in dst_reg
c. result is ntohs()|ntohl()
d. every packet access is checked using
load_pointer()/skb_header_pointer()/bpf_internal_load_pointer_neg_helper()

Now, (a,b,c) seem like details that should be worked with multiple
instructions (in fact the x86 JIT does that). (d) is IMO the only part
important enough to justify a different insn. I'd call this mode
BPF_SKBUFF_PROTECTED (or something like that), because that is the
main idea of this instruction: that any memory access (ld or st) is
checked during runtime assuming it's an skbuff.

The BPF_LD|BPF_IND insn could be replaced in 2 steps, one to get
src_reg+imm32 into a tmp register, and the other to perform the final
load based on the tmp register.

4.4. BPF_STX|BPF_MEM
Operation: *(size *) (dst_reg + off16) = src_reg

This is the basic store insn. LGTM.

4.5. BPF_ST|BPF_MEM
Operation: *(size *) (dst_reg + off16) = imm32

This insn encodes 2 immediate values (the offset and the imm32 value)
in the insn, and actually forces the sock_filter_int 64-bit struct to
have both a 16-bit offset field and a 32-bit immediate field). In
fact, it's the only instructions that uses .off and .imm at the same
time (for all other instructions, at least one of the fields is always
0).

This did not exist in classic BPF (where BPF_ST|BPF_MEM actually did
"mem[pc->k] = A;"). In fact, it's rare to find an ISA that allows
encoding 2 immediate values in a single insn. My impression (after
checking the x86 JIT implementation, which works on the eBPF code) is
that this was added as an x86 optimization, because x86 allows
encoding 2 values (offset and immediate) by using the displacement and
immediate suffixes. I wonder whether the ISA would be more readable if
we did this in 2 insn, one to put dst_reg+off16 in a temporary
register, and the second a simpler BPF_STX|BPF_MEM. Then we could use
the same space for the immediate and offset fields.

4.6. BPF_STX|BPF_XADD
Operation: mem[dst_reg + off16] += src_reg

I assume there's some use case for this, apart from the fact that x86
has an easy construction for this.

You guys have done an excellent job simplifying the 4 opcodes x 6
addressing modes in classic BPF, but I think we should go a step
further, and make it even simpler. I can see how we only need basic
load (4.1), protected load (4.2, 4.3), basic store (4.4, 4.5), and
maybe XADD store (4.6).

> eBPF ISA wasn't invented overnight. It was a gigantic effort that
> took a lot of time to narrow down x64 into _verifiable_ ISA.
> I had to take into account arm64, mips64, sparcv9 architectures too.
> Of course, minor things can be improved here or there.
> Ugliness of ISA hits compiler writers first. I've seen many
> times how cpu designers add new instructions only to be told
> by compiler guys that they just wasted silicon.
> Fact that llvm/gcc compile C into eBPF is the strongest
> statement that eBPF ISA is 99.9% complete.
> New instructions may or may not make sense.
> Let's examine your proposal:
>
>> - 1. we should considering separating the eBPF ISA farther from classic BPF
>>   - eBPF still uses a_reg and x_reg as the names of the 2 op
>> registers. This is very confusing, especially when dealing with
>> translated filters that do move data between A and X. I've had a_reg
>> being X, and x_reg being A. We should rename them d_reg and s_reg.
>
> that is renaming of two fields in sock_filter_int structure.
> No change to actual ISA.
I saw you already wrote this one. Thanks!

>> - 2. there are other insn that we should consider adding:
>>   - lui: AFAICT, there is no clean way to build a 64-bit number (you
>> can LD_IMM the upper part, lsh 32, and then add the lower part).
>
> correct. in tracing filters I do this:
> +                       /* construct 64-bit address */
> +                       emit(BPF_ALU64_IMM(BPF_MOV, BPF_REG_2, addr >>
> 32), ctx);
> +                       emit(BPF_ALU64_IMM(BPF_LSH, BPF_REG_2, 32), ctx);
> +                       emit(BPF_ALU32_IMM(BPF_MOV, BPF_REG_1, (u32)
> addr), ctx);
> +                       emit(BPF_ALU64_REG(BPF_OR, BPF_REG_1, BPF_REG_2), ctx);
>
> so there is a way to construct 64-bit immediate.
> The question is how often do we need to do it? Is it in critical path?
> Naive answer "one instruction is better than 4" doesn't count.
> See my point above 'cpu designer vs compiler writer'.
> None of the risc ISAs have 64-bit imm and eBPF has to consider
> simplicity of JITs otherwise those architectures will have a hard time
> mapping eBPF to native. If JIT would be too difficult to do, then
> there will be no JIT. I don't want eBPF to become an instruction
> set that can be JITed only on one architecture...
That's a good point, and I don't know enough of the other arch's to
realize whether lui is feasible or not.

>>   - nop: I'd like to have a nop. Do I know why? Nope.
> nope. Let's not add unnecessary instructions.
A valid nop is a useful instruction: padding, filling up arrays of
sock_filter_int correctly (as in lib/test_bpf.c, where we're currently
using a "ld #0", which loads zero to register A), and other use cases
(see http://en.wikipedia.org/wiki/NOP ).

Thanks,
-Chema


>> I like the idea of every user (packet filter, seccomp, etc.) providing
>> a map of the bpf calls that are ok, as in the packet filter stating
>> that {1->__skb_get_pay_offset(), 2->__skb_get_nlattr(), ...}, but
>> seccomp providing a completely different (or even empty) map.
>
> yes. exactly.
> What you're describing is a configuration for generic eBPF verifier.
> The implementation details we'll debate when I rebase the verifier
> and post it for review :)
>
> Thanks!
