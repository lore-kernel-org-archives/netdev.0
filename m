From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH RFC net-next 08/14] bpf: add eBPF verifier
Date: Wed, 2 Jul 2014 15:43:26 -0700
Message-ID: <CAMEtUuwNL2ngOfMA7HMc6agRnSwYMTkvEqxoy_AFwDVnb-o_Ug@mail.gmail.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
	<1403913966-4927-9-git-send-email-ast@plumgrid.com>
	<53B26BB0.90209@redhat.com>
	<CAMEtUuyc3+jrxG4r4=fk=Gc9OMhO8a2X1oyWPx1LsKzewVf01w@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D1726B207@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
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
To: David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1726B207-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 2, 2014 at 1:11 AM, David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org> wrote:
> From: Alexei Starovoitov
> ...
>> >> +#define _(OP) ({ int ret = OP; if (ret < 0) return ret; })
> ...
>> >> +       _(get_map_info(env, map_id, &map));
>> >
>> > Nit: such macros should be removed, please.
>>
>> It may surely look unconventional, but alternative is to replace
>> every usage of _ macro with:
>> err =
>> if (err)
>>   return err;
>>
>> and since this macro is used 38 times, it will add ~120 unnecessary
>> lines that will only make code much harder to follow.
>> I tried not using macro and results were not pleasing.
>
> The problem is that they are hidden control flow.
> As such they make flow analysis harder for the casual reader.

In the abstract context macros with gotos and returns are bad,
but in this case extra verbosity is the bigger evil.

Consider this piece of code:
#define _(OP) ({ int ret = OP; if (ret < 0) return ret; })

if (opcode == BPF_END || opcode == BPF_NEG) {
    if (BPF_SRC(insn->code) != BPF_X)
        return -EINVAL;

    /* check src operand */
     _(check_reg_arg(regs, insn->dst_reg, 1));

    /* check dest operand */
    _(check_reg_arg(regs, insn->dst_reg, 0));

} else if (opcode == BPF_MOV) {

    if (BPF_SRC(insn->code) == BPF_X)
        /* check src operand */
        _(check_reg_arg(regs, insn->src_reg, 1));

    /* check dest operand */
    _(check_reg_arg(regs, insn->dst_reg, 0));

where casual reader can easily see what the purpose of the code
and what it's doing.

Now rewrite it without '_' macro:
if (opcode == BPF_END || opcode == BPF_NEG) {
    if (BPF_SRC(insn->code) != BPF_X)
            return -EINVAL;

    /* check src operand */
    err = check_reg_arg(regs, insn->dst_reg, 1);
    if (err)
        return err;

    /* check dest operand */
    err = check_reg_arg(regs, insn->dst_reg, 0);
    if (err)
        return err;

} else if (opcode == BPF_MOV) {

    if (BPF_SRC(insn->code) == BPF_X) {
        /* check src operand */
        err = check_reg_arg(regs, insn->src_reg, 1);
        if (err)
            return err;
    }

    /* check dest operand */
    err = check_reg_arg(regs, insn->dst_reg, 0);
    if (err)
        return err;

see how your eyes are now picking up endless control flow of
if conditions and returns, instead of focusing on the code itself.
It's much easier to understand the semantics when if (err) is out
of the way. Note that replacing _ with real name will ruin
the reading experience, since CAPITAL letters of the macro
will be screaming: "look at me", instead of letting reviewer
focus on the code.

I believe that this usage of _ as a macro specifically as defined,
would be a great addition to kernel coding style in general.
I don't want to see _ to be redefined differently.
