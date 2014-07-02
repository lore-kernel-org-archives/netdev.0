From: Namhyung Kim <namhyung-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RFC net-next 11/14] tracing: allow eBPF programs to be attached to events
Date: Wed, 02 Jul 2014 14:32:45 +0900
Message-ID: <87tx70496q.fsf@sejong.aot.lge.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
	<1403913966-4927-12-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1403913966-4927-12-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> (Alexei
	Starovoitov's message of "Fri, 27 Jun 2014 17:06:03 -0700")
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 27 Jun 2014 17:06:03 -0700, Alexei Starovoitov wrote:
> User interface:
> cat bpf_123 > /sys/kernel/debug/tracing/__event__/filter
>
> where 123 is an id of the eBPF program priorly loaded.
> __event__ is static tracepoint event.
> (kprobe events will be supported in the future patches)
>
> eBPF programs can call in-kernel helper functions to:
> - lookup/update/delete elements in maps
> - memcmp
> - trace_printk

ISTR Steve doesn't like to use trace_printk() (at least for production
kernels) anymore.  And I'm not sure it'd work if there's no existing
trace_printk() on a system.

> - load_pointer
> - dump_stack


[SNIP]
> @@ -634,6 +635,15 @@ ftrace_raw_event_##call(void *__data, proto)				\
>  	if (ftrace_trigger_soft_disabled(ftrace_file))			\
>  		return;							\
>  									\
> +	if (unlikely(ftrace_file->flags & FTRACE_EVENT_FL_FILTERED) &&	\
> +	    unlikely(ftrace_file->event_call->flags & TRACE_EVENT_FL_BPF)) { \
> +		struct bpf_context __ctx;				\
> +									\
> +		populate_bpf_context(&__ctx, args, 0, 0, 0, 0, 0);	\
> +		trace_filter_call_bpf(ftrace_file->filter, &__ctx);	\
> +		return;							\
> +	}								\
> +									\

Hmm..  But it seems the eBPF prog is not a filter - it'd always drop the
event.  And I think it's better to use a recorded entry rather then args
as a bpf_context so that tools like perf can manipulate it at compile
time based on the event format.

Thanks,
Namhyung


>  	__data_size = ftrace_get_offsets_##call(&__data_offsets, args); \
>  									\
>  	entry = ftrace_event_buffer_reserve(&fbuffer, ftrace_file,	\
