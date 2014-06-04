From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next 0/2] split BPF out of core networking
Date: Tue, 3 Jun 2014 17:38:17 -0700
Message-ID: <CAMEtUuxU_FKL4TJ2wJtOngean2RjjJxBbYpxNjJQKjA7HtU2Bg@mail.gmail.com>
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
In-Reply-To: <CA+ZOOTOfq705CbUjx9ppw4gLxJ8JFCaFsphwhAS+NskHVjd86Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 3, 2014 at 2:40 PM, Chema Gonzalez <chema@google.com> wrote:
> First of all, and just to join the crowd, kernel/bpf/ FTW.
>
> Now, I have some suggestions about eBPF. IMO classic BPF is an ISA
> oriented to filter (meaning returning a single integer that states how
> many bytes of the packet must be captured) packets (e.g. consider the
> 6 load modes, where 3 provide access the packet -- abs, ind, msh --,
> one to an skb field -- len--, the 5th one to the memory itself -- mem
> --, and the 6th is an immediate set mode --imm-- ) that has been used
> in other environments (seccomp, tracing, etc.) by (a) extending the
> idea of a "packet" into a "buffer", and (b) adding ancillary loads.
>
> eBPF should be a generic ISA that can be used by many environments,
> including those served today by classic BPF. IMO, we should get a
> nicely-defined ISA (MIPS anyone?) and check what should go into eBPF
> and what should not.

Model eBPF based on MIPS ISA? Ouch.
That would be one ugly ISA that is not JITable on x64.

eBPF ISA wasn't invented overnight. It was a gigantic effort that
took a lot of time to narrow down x64 into _verifiable_ ISA.
I had to take into account arm64, mips64, sparcv9 architectures too.
Of course, minor things can be improved here or there.
Ugliness of ISA hits compiler writers first. I've seen many
times how cpu designers add new instructions only to be told
by compiler guys that they just wasted silicon.
Fact that llvm/gcc compile C into eBPF is the strongest
statement that eBPF ISA is 99.9% complete.
New instructions may or may not make sense.
Let's examine your proposal:

> - 1. we should considering separating the eBPF ISA farther from classic BPF
>   - eBPF still uses a_reg and x_reg as the names of the 2 op
> registers. This is very confusing, especially when dealing with
> translated filters that do move data between A and X. I've had a_reg
> being X, and x_reg being A. We should rename them d_reg and s_reg.

that is renaming of two fields in sock_filter_int structure.
No change to actual ISA.

You're proposing the following:
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 0e463ee77bb2..bf50fa440ef8 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -287,8 +287,8 @@ enum {

 struct sock_filter_int {
        __u8    code;           /* opcode */
-       __u8    a_reg:4;        /* dest register */
-       __u8    x_reg:4;        /* source register */
+       __u8    dst_reg:4;      /* dest register */
+       __u8    src_reg:4;      /* source register */
        __s16   off;            /* signed offset */
        __s32   imm;            /* signed immediate constant */
 };
sure. I thought comment was explicit enough, but I agree
the fields could have been named better.
Will do a patch to rename it.

>   - BPF_LD vs. BPF_LDX: this made sense in classic BPF, as there was
> only one register, and d_reg was implicit in the name of the insn
> code. Now, why are we keeping both in eBPF, when the register we're
> writing to is made explicit in d_reg (I already forgot if d_reg was
> a_reg or x_reg ;) ? Removing one of them will save us 1/8th of the
> insns.
>   - BPF_ST vs. BPF_STX: same here. Note that the current
> sk_convert_filter() just converts all stores to BPF_STX.

nope. No extra bits can be saved here.
STX means:
*(dest_reg + off) = src_reg;
ST means:
*(dest_reg + off) = imm;
LDX means:
dest_reg = *(src_reg + off)

LD we had to carry over from classic as only two non-generic
instructions: LD_ABS and LD_IND.

> - 2. there are other insn that we should consider adding:
>   - lui: AFAICT, there is no clean way to build a 64-bit number (you
> can LD_IMM the upper part, lsh 32, and then add the lower part).

correct. in tracing filters I do this:
+                       /* construct 64-bit address */
+                       emit(BPF_ALU64_IMM(BPF_MOV, BPF_REG_2, addr >>
32), ctx);
+                       emit(BPF_ALU64_IMM(BPF_LSH, BPF_REG_2, 32), ctx);
+                       emit(BPF_ALU32_IMM(BPF_MOV, BPF_REG_1, (u32)
addr), ctx);
+                       emit(BPF_ALU64_REG(BPF_OR, BPF_REG_1, BPF_REG_2), ctx);

so there is a way to construct 64-bit immediate.
The question is how often do we need to do it? Is it in critical path?
Naive answer "one instruction is better than 4" doesn't count.
See my point above 'cpu designer vs compiler writer'.
None of the risc ISAs have 64-bit imm and eBPF has to consider
simplicity of JITs otherwise those architectures will have a hard time
mapping eBPF to native. If JIT would be too difficult to do, then
there will be no JIT. I don't want eBPF to become an instruction
set that can be JITed only on one architecture...

'mov dest_reg, imm64' may still be ok to add, since x64 can
JIT it with one instruction, arm64 with 4 instructions, but JITs
for other archs will be ugly. They can JIT it as load from memory,
but I need to think it through. Let me explore it more carefully.

Two must have requirements for eBPF:
1. verifiable instructions, meaning that verifier doesn't need to jump
  hoops to prove safety of the program
2. JITable as a minium on x64, arm64, otherwise programs will
  run in interpreter and performance will be lost.

Third requirement of compiler to actually being able to generate
new instructions is also important, but it's not must have.

>   - nop: I'd like to have a nop. Do I know why? Nope.

nope. Let's not add unnecessary instructions.

> I like the idea of every user (packet filter, seccomp, etc.) providing
> a map of the bpf calls that are ok, as in the packet filter stating
> that {1->__skb_get_pay_offset(), 2->__skb_get_nlattr(), ...}, but
> seccomp providing a completely different (or even empty) map.

yes. exactly.
What you're describing is a configuration for generic eBPF verifier.
The implementation details we'll debate when I rebase the verifier
and post it for review :)

Thanks!
