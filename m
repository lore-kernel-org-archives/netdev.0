From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH RFC net-next 08/14] bpf: add eBPF verifier
Date: Wed, 2 Jul 2014 16:04:05 -0700
Message-ID: <CAMEtUuxfrAUDDQVGNsNV2PeDii-6LAwQCbB2XGEHTJDwkkvyWg@mail.gmail.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
	<1403913966-4927-9-git-send-email-ast@plumgrid.com>
	<CA+ZOOTODDPN=6SECq1uPPD7AGP1zgBJ+bfYaX9o3YhnaCTiHYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+ZOOTODDPN=6SECq1uPPD7AGP1zgBJ+bfYaX9o3YhnaCTiHYQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 2, 2014 at 3:22 PM, Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
>> + * - unreachable insns exist (shouldn't be a forest. program = one function)
> This seems to me an unnecessary style restriction on user code.

unreachable instructions to me is a ticking time bomb of potential exploits.
Definitely should be rejected.

>> +#define _(OP) ({ int ret = OP; if (ret < 0) return ret; })
> +1 to removing the _ macro. If you want to avoid the 3 lines (is there
> anything in the style guide against "if ((err=OP) < 0) ..." ?), at

assignment and function call inside 'if' ? I don't like such style.

> least use some meaningful macro name (DO_AND_CHECK, or something like
> that).

Try replacing _ with any other name and see how bad it will look.
I tried with MACRO_NAME and with 'if (err) goto' and with 'if (err) return',
before I converged on _ macro.
I think it's a hidden gem of this patch.

> Can you please add:
>
> + } else if (class == BPF_LD) {
> +   if (BPF_MODE(insn->code) == BPF_ABS) {
> +     pr_cont("(%02x) r0 = *(%s *)skb[%d]\n",
> +       insn->code,
> +       bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
> +       insn->imm);
> +   } else if (BPF_MODE(insn->code) == BPF_IND) {
> +     pr_cont("(%02x) r0 = *(%s *)skb[r%d + %d]\n",
> +       insn->code,
> +       bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
> +       insn->src_reg, insn->imm);
> +   } else {
> +     pr_cont("BUG_ld_%02x\n", insn->code);
> +     return;
> +   }
>
> Note that I'm hardcoding r0 (instead of using %d for insn->dst_reg)
> because that's how ebpf writes the instructions.

ohh yes. it's a copy paste error, since it was in a different file before.
Will definitely add. Thanks!

>> +static void init_reg_state(struct reg_state *regs)
>> +{
>> +       struct reg_state *reg;
>> +       int i;
>> +
>> +       for (i = 0; i < MAX_BPF_REG; i++) {
>> +               regs[i].ptr = INVALID_PTR;
>> +               regs[i].read_ok = false;
>> +               regs[i].imm = 0xbadbad;
>> +       }
>> +       reg = regs + BPF_REG_FP;
> Any reason you switching from the array syntax to the pointer one? I
> find "reg = regs[BPF_REG_FP];" more readable (and the one you chose in
> the loop).

in this function no particular reason. It felt a bit less verbose, but
I can make
the change.

>> +       reg = regs + BPF_REG_1; /* 1st arg to a function */
>> +       reg->ptr = PTR_TO_CTX;
> Wait, doesn't this depend on doing "BPF_MOV64_REG(BPF_REG_CTX,
> BPF_REG_ARG1)" (the bpf-to-ebpf prologue), which is only enforced on
> filters converted from bpf? In fact, shouldn't this set
> regs[BPF_REG_CTX] instead of regs[BPF_REG_1] ?

nope. it's REG_1.
as you said r6=r1 is only emitted by converted classic filters.
Verifier will see this 'r6=r1' assignment and will copy the r1 type into r6.

Thank you for review!
