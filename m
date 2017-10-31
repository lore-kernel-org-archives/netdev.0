From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH 1/2] bpf: add a bpf_override_function helper
Date: Mon, 30 Oct 2017 18:35:41 -0700
Message-ID: <d3b63b61-84b4-69a8-ec79-7a3fcca43ca1@fb.com>
References: <1509398375-11927-1-git-send-email-josef@toxicpanda.com>
 <1509398375-11927-2-git-send-email-josef@toxicpanda.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Josef Bacik <jbacik@fb.com>
To: Josef Bacik <josef@toxicpanda.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <ast@kernel.org>, <kernel-team@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1509398375-11927-2-git-send-email-josef@toxicpanda.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/30/17 2:19 PM, Josef Bacik wrote:
> From: Josef Bacik <jbacik@fb.com>
>
> Error injection is sloppy and very ad-hoc.  BPF could fill this niche
> perfectly with it's kprobe functionality.  We could make sure errors are
> only triggered in specific call chains that we care about with very
> specific situations.  Accomplish this with the bpf_override_funciton
> helper.  This will modify the probe'd callers return value to the
> specified value and set the PC to an override function that simply
> returns, bypassing the originally probed function.  This gives us a nice
> clean way to implement systematic error injection for all of our code
> paths.
>
> Signed-off-by: Josef Bacik <jbacik@fb.com>
> ---
>  arch/Kconfig                     |  3 +++
>  arch/x86/Kconfig                 |  1 +
>  arch/x86/include/asm/kprobes.h   |  4 ++++
>  arch/x86/include/asm/ptrace.h    |  5 +++++
>  arch/x86/kernel/kprobes/ftrace.c | 14 ++++++++++++
>  include/uapi/linux/bpf.h         |  7 +++++-
>  kernel/trace/Kconfig             | 11 ++++++++++
>  kernel/trace/bpf_trace.c         | 47 +++++++++++++++++++++++++++++++++++-----
>  kernel/trace/trace.h             |  6 +++++
>  kernel/trace/trace_kprobe.c      | 23 ++++++++++++++------
>  10 files changed, 108 insertions(+), 13 deletions(-)
>
> diff --git a/arch/Kconfig b/arch/Kconfig
> index d789a89cb32c..4fb618082259 100644
> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -195,6 +195,9 @@ config HAVE_OPTPROBES
>  config HAVE_KPROBES_ON_FTRACE
>  	bool
>
> +config HAVE_KPROBE_OVERRIDE
> +	bool
> +
>  config HAVE_NMI
>  	bool
>
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 971feac13506..5126d2750dd0 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -152,6 +152,7 @@ config X86
>  	select HAVE_KERNEL_XZ
>  	select HAVE_KPROBES
>  	select HAVE_KPROBES_ON_FTRACE
> +	select HAVE_KPROBE_OVERRIDE
>  	select HAVE_KRETPROBES
>  	select HAVE_KVM
>  	select HAVE_LIVEPATCH			if X86_64
> diff --git a/arch/x86/include/asm/kprobes.h b/arch/x86/include/asm/kprobes.h
> index 6cf65437b5e5..c6c3b1f4306a 100644
> --- a/arch/x86/include/asm/kprobes.h
> +++ b/arch/x86/include/asm/kprobes.h
> @@ -67,6 +67,10 @@ extern const int kretprobe_blacklist_size;
>  void arch_remove_kprobe(struct kprobe *p);
>  asmlinkage void kretprobe_trampoline(void);
>
> +#ifdef CONFIG_KPROBES_ON_FTRACE
> +extern void arch_ftrace_kprobe_override_function(struct pt_regs *regs);
> +#endif
> +
>  /* Architecture specific copy of original instruction*/
>  struct arch_specific_insn {
>  	/* copy of the original instruction */
> diff --git a/arch/x86/include/asm/ptrace.h b/arch/x86/include/asm/ptrace.h
> index 91c04c8e67fa..f04e71800c2f 100644
> --- a/arch/x86/include/asm/ptrace.h
> +++ b/arch/x86/include/asm/ptrace.h
> @@ -108,6 +108,11 @@ static inline unsigned long regs_return_value(struct pt_regs *regs)
>  	return regs->ax;
>  }
>
> +static inline void regs_set_return_value(struct pt_regs *regs, unsigned long rc)
> +{
> +	regs->ax = rc;
> +}
> +
>  /*
>   * user_mode(regs) determines whether a register set came from user
>   * mode.  On x86_32, this is true if V8086 mode was enabled OR if the
> diff --git a/arch/x86/kernel/kprobes/ftrace.c b/arch/x86/kernel/kprobes/ftrace.c
> index 041f7b6dfa0f..3c455bf490cb 100644
> --- a/arch/x86/kernel/kprobes/ftrace.c
> +++ b/arch/x86/kernel/kprobes/ftrace.c
> @@ -97,3 +97,17 @@ int arch_prepare_kprobe_ftrace(struct kprobe *p)
>  	p->ainsn.boostable = false;
>  	return 0;
>  }
> +
> +asmlinkage void override_func(void);
> +asm(
> +	".type override_func, @function\n"
> +	"override_func:\n"
> +	"	ret\n"
> +	".size override_func, .-override_func\n"
> +);
> +
> +void arch_ftrace_kprobe_override_function(struct pt_regs *regs)
> +{
> +	regs->ip = (unsigned long)&override_func;
> +}
> +NOKPROBE_SYMBOL(arch_ftrace_kprobe_override_function);
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 0b7b54d898bd..1ad5b87a42f6 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -673,6 +673,10 @@ union bpf_attr {
>   *     @buf: buf to fill
>   *     @buf_size: size of the buf
>   *     Return : 0 on success or negative error code
> + *
> + * int bpf_override_return(pt_regs, rc)
> + *	@pt_regs: pointer to struct pt_regs
> + *	@rc: the return value to set
>   */
>  #define __BPF_FUNC_MAPPER(FN)		\
>  	FN(unspec),			\
> @@ -732,7 +736,8 @@ union bpf_attr {
>  	FN(xdp_adjust_meta),		\
>  	FN(perf_event_read_value),	\
>  	FN(perf_prog_read_value),	\
> -	FN(getsockopt),
> +	FN(getsockopt),			\
> +	FN(override_return),
>
>  /* integer value in 'imm' field of BPF_CALL instruction selects which helper
>   * function eBPF program intends to call
> diff --git a/kernel/trace/Kconfig b/kernel/trace/Kconfig
> index 434c840e2d82..9dc0deeaad2b 100644
> --- a/kernel/trace/Kconfig
> +++ b/kernel/trace/Kconfig
> @@ -518,6 +518,17 @@ config FUNCTION_PROFILER
>
>  	  If in doubt, say N.
>
> +config BPF_KPROBE_OVERRIDE
> +	bool "Enable BPF programs to override a kprobed function"
> +	depends on BPF_EVENTS
> +	depends on KPROBES_ON_FTRACE
> +	depends on HAVE_KPROBE_OVERRIDE
> +	depends on DYNAMIC_FTRACE_WITH_REGS
> +	default n
> +	help
> +	 Allows BPF to override the execution of a probed function and
> +	 set a different return value.  This is used for error injection.
> +
>  config FTRACE_MCOUNT_RECORD
>  	def_bool y
>  	depends on DYNAMIC_FTRACE
> diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
> index 136aa6bb0422..38b6d6016b71 100644
> --- a/kernel/trace/bpf_trace.c
> +++ b/kernel/trace/bpf_trace.c
> @@ -13,10 +13,14 @@
>  #include <linux/filter.h>
>  #include <linux/uaccess.h>
>  #include <linux/ctype.h>
> +#include <asm/kprobes.h>
> +
>  #include "trace.h"
>
>  u64 bpf_get_stackid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
>
> +static DEFINE_PER_CPU(int, pc_modified);
> +
>  /**
>   * trace_call_bpf - invoke BPF program
>   * @call: tracepoint event
> @@ -27,16 +31,18 @@ u64 bpf_get_stackid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
>   *
>   * Return: BPF programs always return an integer which is interpreted by
>   * kprobe handler as:
> - * 0 - return from kprobe (event is filtered out)
> - * 1 - store kprobe event into ring buffer
> - * Other values are reserved and currently alias to 1
> + * TRACE_KPROBE_SKIP - return from kprobe (event is filtered out)
> + * TRACE_KPOBE_STORE - store kprobe event into ring buffer
> + * TRACE_KPROBE_MODIFIED - we modified the registers, make sure the dispatcher
> + *			skips the event and returns so the kprobe infrastructure
> + *			doesn't mess with the next instruction.
>   */
>  unsigned int trace_call_bpf(struct trace_event_call *call, void *ctx)
>  {
>  	unsigned int ret;
>
>  	if (in_nmi()) /* not supported yet */
> -		return 1;
> +		return TRACE_KPROBE_STORE;
>
>  	preempt_disable();
>
> @@ -47,7 +53,7 @@ unsigned int trace_call_bpf(struct trace_event_call *call, void *ctx)
>  		 * and don't send kprobe event into ring-buffer,
>  		 * so return zero here
>  		 */
> -		ret = 0;
> +		ret = TRACE_KPROBE_SKIP;
>  		goto out;
>  	}
>
> @@ -67,7 +73,13 @@ unsigned int trace_call_bpf(struct trace_event_call *call, void *ctx)
>  	 * rcu_dereference() which is accepted risk.
>  	 */
>  	ret = BPF_PROG_RUN_ARRAY_CHECK(call->prog_array, ctx, BPF_PROG_RUN);
> +	if (ret)
> +		ret = TRACE_KPROBE_STORE;
>
> +	if (__this_cpu_read(pc_modified)) {
> +		__this_cpu_write(pc_modified, 0);
> +		ret = TRACE_KPROBE_MODIFIED;

we probably need to fork trace_call_bpf() specifically for kprobes,
since this new functionality is not applicable to tracepoints and
uprobes. Like perf_event type bpf prog is using bpf_overflow_handler()

> +	}
>   out:
>  	__this_cpu_dec(bpf_prog_active);
>  	preempt_enable();
> @@ -76,6 +88,29 @@ unsigned int trace_call_bpf(struct trace_event_call *call, void *ctx)
>  }
>  EXPORT_SYMBOL_GPL(trace_call_bpf);
>
> +#ifdef CONFIG_BPF_KPROBE_OVERRIDE
> +BPF_CALL_2(bpf_override_return, struct pt_regs *, regs, unsigned long, rc)
> +{
> +	__this_cpu_write(pc_modified, 1);
> +	regs_set_return_value(regs, rc);
> +	arch_ftrace_kprobe_override_function(regs);
> +	return 0;
> +}
> +#else
> +BPF_CALL_2(bpf_override_return, struct pt_regs *, regs, unsigned long, rc)
> +{
> +	return -EINVAL;
> +}
> +#endif
> +
> +static const struct bpf_func_proto bpf_override_return_proto = {
> +	.func		= bpf_override_return,
> +	.gpl_only	= true,
> +	.ret_type	= RET_INTEGER,
> +	.arg1_type	= ARG_PTR_TO_CTX,
> +	.arg2_type	= ARG_ANYTHING,
> +};
> +
>  BPF_CALL_3(bpf_probe_read, void *, dst, u32, size, const void *, unsafe_ptr)
>  {
>  	int ret;
> @@ -551,6 +586,8 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
>  		return &bpf_get_stackid_proto;
>  	case BPF_FUNC_perf_event_read_value:
>  		return &bpf_perf_event_read_value_proto;
> +	case BPF_FUNC_override_return:
> +		return &bpf_override_return_proto;

good call to allow it on kprobes only.
It probably needs to be tighten further to allow it
in ftrace-based kprobes only.
imo 'depends on KPROBES_ON_FTRACE' isn't not enough,
since kprobe in the middle of the function will still work via trap
and won't work with this override_func().

>  	default:
>  		return tracing_func_proto(func_id);
>  	}
> diff --git a/kernel/trace/trace.h b/kernel/trace/trace.h
> index 652c682707cd..317ff2e961ac 100644
> --- a/kernel/trace/trace.h
> +++ b/kernel/trace/trace.h
> @@ -278,6 +278,12 @@ enum {
>  	TRACE_ARRAY_FL_GLOBAL	= (1 << 0)
>  };
>
> +enum {
> +	TRACE_KPROBE_SKIP = 0,
> +	TRACE_KPROBE_STORE,
> +	TRACE_KPROBE_MODIFIED,
> +};
> +
>  extern struct list_head ftrace_trace_arrays;
>
>  extern struct mutex trace_types_lock;
> diff --git a/kernel/trace/trace_kprobe.c b/kernel/trace/trace_kprobe.c
> index abf92e478cfb..722fc6568134 100644
> --- a/kernel/trace/trace_kprobe.c
> +++ b/kernel/trace/trace_kprobe.c
> @@ -1170,7 +1170,7 @@ static int kretprobe_event_define_fields(struct trace_event_call *event_call)
>  #ifdef CONFIG_PERF_EVENTS
>
>  /* Kprobe profile handler */
> -static void
> +static int
>  kprobe_perf_func(struct trace_kprobe *tk, struct pt_regs *regs)
>  {
>  	struct trace_event_call *call = &tk->tp.call;
> @@ -1179,12 +1179,19 @@ kprobe_perf_func(struct trace_kprobe *tk, struct pt_regs *regs)
>  	int size, __size, dsize;
>  	int rctx;
>
> -	if (bpf_prog_array_valid(call) && !trace_call_bpf(call, regs))
> -		return;
> +	if (bpf_prog_array_valid(call)) {
> +		int ret = trace_call_bpf(call, regs);

actually, can we keep trace_call_bpf() as-is and move
if (__this_cpu_read(pc_modified))
logic into here ?
I think kprobe_perf_func() runs with preempt_disabled.
May be specialized trace_call_kprobe_bpf() would be better
still to avoid double preempt_disable.
