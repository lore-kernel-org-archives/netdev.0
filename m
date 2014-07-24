From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC v2 net-next 10/16] bpf: add eBPF verifier
Date: Wed, 23 Jul 2014 17:48:26 -0700
Message-ID: <CAMEtUuzWcNLYUOALQbyQ48+GfATrB-wdZP0Y+rVuF=u7m+H=kg@mail.gmail.com>
References: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
	<1405657206-12060-11-git-send-email-ast@plumgrid.com>
	<CAGXu5j+HJ-sSkjE_1+UZXZiL19u0oOA8QSrOmkepWPaMBsv9eg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:54383 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933897AbaGXAs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 20:48:28 -0400
Received: by mail-wi0-f171.google.com with SMTP id hi2so8692372wib.10
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 17:48:26 -0700 (PDT)
In-Reply-To: <CAGXu5j+HJ-sSkjE_1+UZXZiL19u0oOA8QSrOmkepWPaMBsv9eg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 23, 2014 at 4:38 PM, Kees Cook <keescook@chromium.org> wrote:
>> +Program that doesn't check return value of map_lookup_elem() before accessing
>> +map element:
>> +  BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
>> +  BPF_ALU64_REG(BPF_MOV, BPF_REG_2, BPF_REG_10),
>> +  BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
>> +  BPF_ALU64_IMM(BPF_MOV, BPF_REG_1, 1),
>> +  BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
>
> Is the expectation that these pointers are direct kernel function
> addresses? It looks like they're indexes in the check_call routine
> below. What specifically were the pointer leaks you'd mentioned?

yes, the pointer returned from map_lookup_elem() is a direct pointer
to map element value. If program prints it, that obviously a leak.
Therefore I'm planning to add 'secure' mode to verifier where such
pointer leaks are detected and rejected. This mode will be on for
any non-root syscall.

>> +#define _(OP) ({ int ret = OP; if (ret < 0) return ret; })
>
> This seems overly terse. :) And the meaning tends to be overloaded
> (this obviously isn't a translatable string, etc). Perhaps call it
> "chk" or "ret_fail"? And I think OP in the body should have ()s around
> it to avoid potential macro expansion silliness.

Sure, I'll wrap OP in ().
you've missed the previous thread about my favorite _ macro:
http://www.spinics.net/lists/netdev/msg288070.html
I think I gave a ton of 'pro' arguments already.
Looks like I have to order a bunch of t-shirts with '#define _()' on
them and give it to everyone on the next conference :)

>> +static const char *const bpf_jmp_string[] = {
>> +       "jmp", "==", ">", ">=", "&", "!=", "s>", "s>=", "call", "exit"
>> +};
>
> It seems like these string arrays should have literal initializers
> like reg_type_str does.

yeah. good point. will do.

>> +static int check_reg_arg(struct reg_state *regs, int regno, bool is_src)
>> +{
>
> Since regno is always populated with dst_reg/src_reg (u8 :4 sized),
> shouldn't this be u8 instead of int? (And in check_* below too?) More

why? 'int' type is much friendlier to compiler. u8,u16 is a pain to deal with.
unsigned types in general are much harder for optimizer.

> importantly, regno needs bounds checking. MAX_BPF_REG is 10, but
> dst_reg/src_reg could be up to 15, IIUC.

grr. yes. somehow lost this check in this version. good catch.

>> +       } else {
>> +               if (regno == BPF_REG_FP)
>> +                       /* frame pointer is read only */
>
> Why no verbose() call here?

no good reason.will add.

>> +               slot = &state->stack[MAX_BPF_STACK + off];
>> +               slot->stype = STACK_SPILL;
>> +               /* save register state */
>> +               slot->type = state->regs[value_regno].type;
>> +               slot->imm = state->regs[value_regno].imm;
>> +               for (i = 1; i < 8; i++) {
>> +                       slot = &state->stack[MAX_BPF_STACK + off + i];
>
> off and size need bounds checking here and below.

off and size were checked in check_mem_access().
Here size is 1,2,4,8 and off is within [-MAX_BPF_STACK,0)
so no extra checks needed.

>> +/* check read/write into map element returned by bpf_map_lookup_elem() */
>> +static int check_map_access(struct verifier_env *env, int regno, int off,
>> +                           int size)
>> +{
>> +       struct bpf_map *map;
>> +       int map_id = env->cur_state.regs[regno].imm;
>> +
>> +       _(get_map_info(env, map_id, &map));
>> +
>> +       if (off < 0 || off + size > map->value_size) {
>
> This could be tricked with a negative size, or a giant size, wrapping negative.

nope. cannot. check_map_access() is called from check_mem_access()
where off and size were checked.

>> +static int check_mem_access(struct verifier_env *env, int regno, int off,
>> +                           int bpf_size, enum bpf_access_type t,
>> +                           int value_regno)
>> +{
>> +       struct verifier_state *state = &env->cur_state;
>> +       int size;
>> +
>> +       _(size = bpf_size_to_bytes(bpf_size));
>> +
>> +       if (off % size != 0) {
>> +               verbose("misaligned access off %d size %d\n", off, size);
>> +               return -EACCES;
>> +       }
>
> I think more off and size checking is needed here.

I don't see the problem. Here it's the main entry into other checks.
alignment check above is a common check for all memory accesses.
All other stricter checks are in check_map_access(), check_stack_*(),
check_ctx_access() that are called from this check_mem_access() func.
Why do you think more checking is needed?

>> +/* when register 'regno' is passed into function that will read 'access_size'
>> + * bytes from that pointer, make sure that it's within stack boundary
>> + * and all elements of stack are initialized
>> + */
>> +static int check_stack_boundary(struct verifier_env *env,
>> +                               int regno, int access_size)
>> +{
>> +       struct verifier_state *state = &env->cur_state;
>> +       struct reg_state *regs = state->regs;
>> +       int off, i;
>> +
>
> regno bounds checking needed.

nope. check_stack_boundary() is called from check_func_arg()
which is called only with constant regnos: 1,2,3,4,5 to check function
arguments.

> Unless I've overlooked something, I think this needs much stricter
> evaluation of register numbers, offsets, and sizes.

sorry to hear that first glance was disappointing :)
I hope my explanation made it more clear.
The only check that I forgot to carry over the last year is in
check_reg_arg(). Around november last year the verifier patches I keep
posting diverged a little bit from the one we keep running in production,
since eBPF got few instruction renamed, so I had to keep tracking the two.
Once this version gets upstreamed we can finally drop the internal one.
check_reg_arg() is indeed incorrect here. Will fix. That was a good catch.
Thank you for review!
