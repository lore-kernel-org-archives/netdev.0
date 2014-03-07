From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v6 net-next 1/3] filter: add Extended BPF interpreter and converter
Date: Fri, 7 Mar 2014 14:19:39 -0800
Message-ID: <CAMEtUuzgM5xKAXZaC+Up9bKy6MaS8V6jFGq49QY7VxQOSFgcBw@mail.gmail.com>
References: <1394076617-8108-1-git-send-email-ast@plumgrid.com>
	<1394076617-8108-2-git-send-email-ast@plumgrid.com>
	<20140307.153808.649644634357014854.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Ingo Molnar <mingo@kernel.org>, Will Drewry <wad@chromium.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Jesse Gross <jesse@nicira.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Jovi Zhangwei <jovi.zhangwei@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	=?ISO-8859-1?Q?Fr=E9d=E9ric_Weisbecker?= <fweisbec@gmail.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Pekka Enberg <penberg@iki.fi>,
	Arjan van de Ven <arjan@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:36481 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248AbaCGWTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 17:19:40 -0500
Received: by mail-wg0-f45.google.com with SMTP id l18so5393423wgh.28
        for <netdev@vger.kernel.org>; Fri, 07 Mar 2014 14:19:39 -0800 (PST)
In-Reply-To: <20140307.153808.649644634357014854.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 7, 2014 at 12:38 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexei Starovoitov <ast@plumgrid.com>
> Date: Wed,  5 Mar 2014 19:30:15 -0800
>
>> Extended BPF extends old BPF in the following ways:
>> - from 2 to 10 registers
>>   Original BPF has two registers (A and X) and hidden frame pointer.
>>   Extended BPF has ten registers and read-only frame pointer.
>> - from 32-bit registers to 64-bit registers
>>   semantics of old 32-bit ALU operations are preserved via 32-bit
>>   subregisters
>> - if (cond) jump_true; else jump_false;
>>   old BPF insns are replaced with:
>>   if (cond) jump_true; /* else fallthrough */
>> - adds signed > and >= insns
>> - 16 4-byte stack slots for register spill-fill replaced with
>>   up to 512 bytes of multi-use stack space
>> - introduces bpf_call insn and register passing convention for zero
>>   overhead calls from/to other kernel functions (not part of this patch)
>> - adds arithmetic right shift insn
>> - adds swab32/swab64 insns
>> - adds atomic_add insn
>> - old tax/txa insns are replaced with 'mov dst,src' insn
>>
>> Extended BPF is designed to be JITed with one to one mapping, which
>> allows GCC/LLVM backends to generate optimized BPF code that performs
>> almost as fast as natively compiled code
>
> I have no fundamental objections to this work, but these patches still
> need some adjustments.

Great!
Let me explain the reasons for the ugly pieces you pointed out:

>> @@ -637,6 +641,10 @@ void sk_filter_release_rcu(struct rcu_head *rcu)
>>  {
>>       struct sk_filter *fp = container_of(rcu, struct sk_filter, rcu);
>>
>> +     if ((void *)fp->bpf_func == (void *)sk_run_filter_ext)
>> +             /* arch specific jit_free are expecting this value */
>> +             fp->bpf_func = sk_run_filter;
>> +
>
> You should never need to cast ->bpf_func for any reason, the types have
> to be correct on both sides of assignments and tests.
>
> Furthermore, for this case, I think we should not continue to use
> ad-hoc mechanisms for the JIT implementations to test this condition.
>
> Rather, make some explicit piece of state for this, and have the JITs
> test that instead.

Agreed. In the first patch I didn't want to touch 5 arch/*/net/*jit
files to test for
the flag whether 'bpf_func' comes from JIT or not.
and was thinking to clean it up as follow on.
but if that's must have, I will roll it into this patch.

>
>> +     /* sock_filter_ext insns must be executed by sk_run_filter_ext */
>> +     fp->bpf_func = (typeof(fp->bpf_func))sk_run_filter_ext;
>
> Likewise.

btw, JITs are doing similar typecast:
from bpf_jit_comp.c:
fp->bpf_func = (void *)image;

I can see two ways of avoiding this typecast:

1. removing typecast with extra 'if' in the hot path:
SK_RUN_FILTER wants to dereference 'bpf_func' and execute it.
It's easy to add boolean flag 'is_sock_filter_ext' into sk_filter and
make a union
out of 'bpf_func' and 'bpf_func_ext', but the macro would need to check
the flag just to avoid typecast :(

2.
Another alternative is to do
struct sk_filter {
  ..
union {
    unsigned int (*bpf_func)(const struct sk_buff *skb,const struct
sock_filter *filter);
    unsigned int (*bpf_func_ext)(void*, const struct sock_filter_ext *filter);
    unsigned int (*bpf_func_generic)(void *, void*);
};

assignments into sk_filter will use correct field like:
fp->bpf_func_ext = sk_run_filter_ext;
and the hot call macro will look like:
#define SK_RUN_FILTER(F, CTX) (*F->bpf_func_generic)(CTX, F->insns)

I think current typecasts are equally ugly, but 'union' style
will be cleaner from gcc point of view.

If there are no better suggestions, I'll go with #2. ok?

> 'ctx' is an sk_buff pointer, you keep casting back and forth between void and
> sk_buff * in sk_run_filter_ext, please do not do this.
>
> You cannot make this thing opaque, the interpreter must operate in an environment
> where the type of the memory behind 'ctx' is not ambiguous.  Therefore using a
> void pointer and all these casts is not appropriate at all.

interpreter doesn't need to know what is hiding behind 'ctx' that's
why it is 'void*'.
It's a job of sk_chk_filter() and sk_chk_filter_ext() to verify that ctx and
set of instructions given to interpreter are valid for each other.
If we force interpreter to know the exact type of data, we won't be able to
make a generic, across the kernel, interpreter.
That is the main problem of existing sk_run_filter() that can only
take 'sk_buff' as input
and seccomp has to pass NULL and mess with pseudo instruction
BPF_S_ANC_SECCOMP that calls multiple functions.
Here I'm converting the seccomp calls into single 'load' insn from 'void * ctx'
that is directly JITed into single CPU load.
IMO the more we move the smart-bits into 'bpf/ebpf checker' the
simpler and faster
the execution will be.

BPF_LD+BPF_ABS and BPF_LD+BPF_IND are legacy insns.
I kept them to keep compatibility with current filters.
They will be present in the filter code only when filter input is skb.
sk_convert_filter() and sk_chk_filter_ext() will guarantee that that's the case.
So imo typecast from void *ctx into sk_buff is appropriate.

btw, sk_chk_filter_ext() was posted as part of V1 series (under
bpf_check() name),
but I'm deferring it as suggested by Daniel until ebpf jit an other
pieces are in.

>> @@ -676,6 +759,9 @@ int sk_unattached_filter_create(struct sk_filter **pfp,
>>       if (fprog->filter == NULL)
>>               return -EINVAL;
>>
>> +     if (bpf_ext_enable)
>> +             return sk_prepare_filter_ext(pfp, fprog, NULL);
>> +
>>       fp = kmalloc(sk_filter_size(fprog->len), GFP_KERNEL);
>>       if (!fp)
>>               return -ENOMEM;
>
> To me this is the wrong priority, if the user has JIT enabled it should
> take priority over translation into extended BPF.

btw, ebpf jit coming in the next diff (it was also previewed in V1 series).

In the 1/3 commit log of this patch I explain the current relation
between bpf_ext_enable and bpf_jit_enable flags.

In the next patch with ebpf jit, single bpf_jit_enable flag will act for both:
  if (bpf_ext_enable) {
        convert to new
        sk_chk_filter() - check old bpf
        if (bpf_jit_enable)
             use new jit
        else
             use new interpreter
     } else {
        sk_chk_filter() - check old bpf
        if (bpf_jit_enable)
            use old jit
        else
            use old interpreter
     }

I believe Daniel oked this approach, but if you object, I can do it differently.
Are you saying 'bpf_jit_enable' flag should mean: do old jit no matter what?
Then we would need another flag 'bpf_ext_jit_enable' as well?
Seems overkill to me.

>
>> @@ -726,21 +812,27 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
>>       if (fprog->filter == NULL)
>>               return -EINVAL;
>>
>> -     fp = sock_kmalloc(sk, sk_fsize, GFP_KERNEL);
>> -     if (!fp)
>> -             return -ENOMEM;
>> -     if (copy_from_user(fp->insns, fprog->filter, fsize)) {
>> -             sock_kfree_s(sk, fp, sk_fsize);
>> -             return -EFAULT;
>> -     }
>> +     if (bpf_ext_enable) {
>> +             err = sk_prepare_filter_ext(&fp, fprog, sk);
>> +             if (err)
>> +                     return err;
>
> Likewise.
>
>> +#ifdef __x86_64
>> +#define LOAD_IMM /**/
>> +#define K insn->imm
>> +#else
>> +#define LOAD_IMM (K = insn->imm)
>> +     s32 K = insn->imm;
>> +#endif
>
> There is no way we should have a cpu type ifdef in this code.  Please pick one
> way or the other and get rid of the CPP test entirely.

Sure. I can do that,
but similar check exists already in sk_run_filter():
#if defined(CONFIG_X86_32)
#define K (fentry->k)
#else
                const u32 K = fentry->k;
#endif
do you want me to kill both of them then?

Thanks
Alexei
