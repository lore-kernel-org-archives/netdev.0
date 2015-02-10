From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH v3 linux-trace 1/8] tracing: attach eBPF programs to
 tracepoints and syscalls
Date: Tue, 10 Feb 2015 00:13:30 -0500
Message-ID: <20150210001330.67b35e62@grimm.local.home>
References: <1423539961-21792-1-git-send-email-ast@plumgrid.com>
	<1423539961-21792-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1423539961-21792-2-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon,  9 Feb 2015 19:45:54 -0800
Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:

> +/* For tracepoint filters argN fields match one to one to arguments
> + * passed to tracepoint events
> + *
> + * For syscall entry filters argN fields match syscall arguments
> + * For syscall exit filters arg1 is a return value
> + */
> +struct bpf_context {
> +	u64 arg1;
> +	u64 arg2;
> +	u64 arg3;
> +	u64 arg4;
> +	u64 arg5;
> +	u64 arg6;
> +};
> +
> +#endif /* _LINUX_KERNEL_BPF_TRACE_H */
> diff --git a/include/trace/ftrace.h b/include/trace/ftrace.h
> index 139b5067345b..4c275ce2dcf0 100644
> --- a/include/trace/ftrace.h
> +++ b/include/trace/ftrace.h
> @@ -17,6 +17,7 @@
>   */
>  
>  #include <linux/ftrace_event.h>
> +#include <trace/bpf_trace.h>
>  
>  /*
>   * DECLARE_EVENT_CLASS can be used to add a generic function
> @@ -755,12 +756,32 @@ __attribute__((section("_ftrace_events"))) *__event_##call = &event_##call
>  #undef __perf_task
>  #define __perf_task(t)	(__task = (t))
>  
> +/* zero extend integer, pointer or aggregate type to u64 without warnings */
> +#define __CAST_TO_U64(EXPR) ({ \
> +	u64 ret = 0; \
> +	typeof(EXPR) expr = EXPR; \
> +	switch (sizeof(expr)) { \
> +	case 8: ret = *(u64 *) &expr; break; \
> +	case 4: ret = *(u32 *) &expr; break; \
> +	case 2: ret = *(u16 *) &expr; break; \
> +	case 1: ret = *(u8 *) &expr; break; \
> +	} \
> +	ret; })
> +
> +#define __BPF_CAST1(a,...) __CAST_TO_U64(a)
> +#define __BPF_CAST2(a,...) __CAST_TO_U64(a), __BPF_CAST1(__VA_ARGS__)
> +#define __BPF_CAST3(a,...) __CAST_TO_U64(a), __BPF_CAST2(__VA_ARGS__)
> +#define __BPF_CAST4(a,...) __CAST_TO_U64(a), __BPF_CAST3(__VA_ARGS__)
> +#define __BPF_CAST5(a,...) __CAST_TO_U64(a), __BPF_CAST4(__VA_ARGS__)
> +#define __BPF_CAST6(a,...) __CAST_TO_U64(a), __BPF_CAST5(__VA_ARGS__)
> +
>  #undef DECLARE_EVENT_CLASS
>  #define DECLARE_EVENT_CLASS(call, proto, args, tstruct, assign, print)	\
>  static notrace void							\
>  perf_trace_##call(void *__data, proto)					\
>  {									\
>  	struct ftrace_event_call *event_call = __data;			\
> +	struct bpf_prog *prog = event_call->prog;			\
>  	struct ftrace_data_offsets_##call __maybe_unused __data_offsets;\
>  	struct ftrace_raw_##call *entry;				\
>  	struct pt_regs __regs;						\
> @@ -771,6 +792,16 @@ perf_trace_##call(void *__data, proto)					\
>  	int __data_size;						\
>  	int rctx;							\
>  									\
> +	if (prog) {							\
> +		__maybe_unused const u64 z = 0;				\
> +		struct bpf_context __ctx = ((struct bpf_context) {	\
> +				__BPF_CAST6(args, z, z, z, z, z)	\

Note, there is no guarantee that args is at most 6. For example, in
drivers/net/wireless/brcm80211/brcmsmac/brcms_trace_events.h, the
trace_event brcms_txstatus has 8 args.

But I guess that's OK if you do not need those last args, right?

Also, there's no interface the lets us know what the args are. I may be
able to come up with something. That's the reason I never filtered
before tracing. Because we had no way of knowing what to filter on,
because the args were never visible.

I'm nervous about showing args of tracepoints too, because we don't want
that to become a strict ABI either.

-- Steve



> +			});						\
> +									\
> +		if (!trace_call_bpf(prog, &__ctx))			\
> +			return;						\
> +	}								\
> +									\
>  	__data_size = ftrace_get_offsets_##call(&__data_offsets, args); \
