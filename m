From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC net-next 08/14] bpf: add eBPF verifier
Date: Tue, 1 Jul 2014 22:57:49 -0700
Message-ID: <CAMEtUuztwZQ_kvKEYKgjUp0yRdkao=yCdp3xXkXQJCMYXos2Qg@mail.gmail.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
	<1403913966-4927-9-git-send-email-ast@plumgrid.com>
	<87y4wc4aff.fsf@sejong.aot.lge.com>
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
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Namhyung Kim <namhyung@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87y4wc4aff.fsf@sejong.aot.lge.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 1, 2014 at 10:05 PM, Namhyung Kim <namhyung@gmail.com> wrote:
> Mostly questions and few nitpicks.. :)

great questions. Thank you for review! Answers below:

> On Fri, 27 Jun 2014 17:06:00 -0700, Alexei Starovoitov wrote:
>> +/* types of values:
>> + * - stored in an eBPF register
>> + * - passed into helper functions as an argument
>> + * - returned from helper functions
>> + */
>> +enum bpf_reg_type {
>> +     INVALID_PTR,                    /* reg doesn't contain a valid pointer */
>
> I don't think it's a good name.  The INVALID_PTR can be read as it
> contains a "pointer" which is invalid.  Maybe INTEGER, NUMBER or
> something different can be used.  And I think the struct reg_state->ptr
> should be renamed also.

ok. I agree that 'invalid' part of the name is too negative.
May be 'unknown_value' ?

>> +     PTR_TO_CTX,                     /* reg points to bpf_context */
>> +     PTR_TO_MAP,                     /* reg points to map element value */
>> +     PTR_TO_MAP_CONDITIONAL,         /* points to map element value or NULL */
>> +     PTR_TO_STACK,                   /* reg == frame_pointer */
>> +     PTR_TO_STACK_IMM,               /* reg == frame_pointer + imm */
>> +     PTR_TO_STACK_IMM_MAP_KEY,       /* pointer to stack used as map key */
>> +     PTR_TO_STACK_IMM_MAP_VALUE,     /* pointer to stack used as map elem */
>
> So, these PTR_TO_STACK_IMM[_*] types are only for function argument,
> right?  I guessed it could be used to access memory in general too, but
> then I thought it'd make verification complicated..
>
> And I also agree that it'd better splitting reg types and function
> argument constraints.

Ok. Will split this enum into three.

>> +
>> +/* check read/write into map element returned by bpf_table_lookup() */
>> +static int check_table_access(struct verifier_env *env, int regno, int off,
>> +                           int size)
>
> I guess the "table" is an old name of the "map"?

oops :) Yes. I've been calling them 'bpf tables' initially, but it created too
strong of a correlation to 'hash table', so I've changed the name to 'map'
to stress that this is a generic key/value and not just hash table.

>> +     } else if (state->regs[regno].ptr == PTR_TO_STACK) {
>> +             if (off >= 0 || off < -MAX_BPF_STACK) {
>> +                     verbose("invalid stack off=%d size=%d\n", off, size);
>> +                     return -EACCES;
>> +             }
>
> So memory (stack) access is only allowed for a stack base regsiter and a
> constant offset, right?

Correct.
In other words it allows instructions:
BPF_STX_MEM(BPF_W, BPF_REG_10, BPF_REG_xx, -stack_offset);

Verifier makes no attempt to track pointer arithmetic and just marks
the result as 'invalid_ptr'.
For non-root programs it will reject programs that are trying to do
arithmetic on pointers (it's not part of this patch yet).

>> +     /* check args */
>> +     _(check_func_arg(env, BPF_REG_1, fn->arg1_type, &map_id, &map));
>> +     _(check_func_arg(env, BPF_REG_2, fn->arg2_type, &map_id, &map));
>> +     _(check_func_arg(env, BPF_REG_3, fn->arg3_type, &map_id, &map));
>> +     _(check_func_arg(env, BPF_REG_4, fn->arg4_type, &map_id, &map));
>
> Missing BPF_REG_5?

yes. good catch.
I guess this shows that we didn't have a use case for function with 5 args :)
Will fix this.

>> +#define PEAK_INT() \
>
> s/PEAK/PEEK/ ?

aren't these the same? ;))
Will fix. Thanks!
