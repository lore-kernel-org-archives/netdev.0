From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH v7 tip 4/8] tracing: allow BPF programs to call
 bpf_trace_printk()
Date: Thu, 19 Mar 2015 11:29:31 -0400
Message-ID: <20150319112931.14f3569b@gandalf.local.home>
References: <1426542584-9406-1-git-send-email-ast@plumgrid.com>
	<1426542584-9406-5-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1426542584-9406-5-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 16 Mar 2015 14:49:40 -0700
Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:

> Debugging of BPF programs needs some form of printk from the program,
> so let programs call limited trace_printk() with %d %u %x %p modifiers only.
> 
> Similar to kernel modules, during program load verifier checks whether program
> is calling bpf_trace_printk() and if so, kernel allocates trace_printk buffers
> and emits big 'this is debug only' banner.
> 
> Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
> ---
>  include/uapi/linux/bpf.h |    1 +
>  kernel/trace/bpf_trace.c |   68 ++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 69 insertions(+)
> 
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 101e509d1001..4095f3d9a716 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -166,6 +166,7 @@ enum bpf_func_id {
>  	BPF_FUNC_map_delete_elem, /* int map_delete_elem(&map, &key) */
>  	BPF_FUNC_probe_read,      /* int bpf_probe_read(void *dst, int size, void *src) */
>  	BPF_FUNC_ktime_get_ns,    /* u64 bpf_ktime_get_ns(void) */
> +	BPF_FUNC_trace_printk,    /* int bpf_trace_printk(const char *fmt, int fmt_size, ...) */
>  	__BPF_FUNC_MAX_ID,
>  };
>  
> diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
> index 74eb6abda6a1..a22763a4d2e2 100644
> --- a/kernel/trace/bpf_trace.c
> +++ b/kernel/trace/bpf_trace.c
> @@ -62,6 +62,60 @@ static u64 bpf_ktime_get_ns(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
>  	return ktime_get_mono_fast_ns();
>  }
>  
> +/* limited trace_printk()
> + * only %d %u %x %ld %lu %lx %lld %llu %llx %p conversion specifiers allowed
> + */
> +static u64 bpf_trace_printk(u64 r1, u64 fmt_size, u64 r3, u64 r4, u64 r5)
> +{
> +	char *fmt = (char *) (long) r1;
> +	int fmt_cnt = 0;
> +	bool mod_l[3] = {};
> +	int i;
> +
> +	/* bpf_check() guarantees that fmt points to bpf program stack and
> +	 * fmt_size bytes of it were initialized by bpf program
> +	 */
> +	if (fmt[fmt_size - 1] != 0)
> +		return -EINVAL;
> +
> +	/* check format string for allowed specifiers */
> +	for (i = 0; i < fmt_size; i++)

Even though there's only a single "if" statement after the "for", it is
usually considered proper to add the brackets if the next line is
complex (more than one line). Which it is in this case.


> +		if (fmt[i] == '%') {
> +			if (fmt_cnt >= 3)
> +				return -EINVAL;
> +			i++;
> +			if (i >= fmt_size)
> +				return -EINVAL;
> +
> +			if (fmt[i] == 'l') {
> +				mod_l[fmt_cnt] = true;
> +				i++;
> +				if (i >= fmt_size)
> +					return -EINVAL;
> +			} else if (fmt[i] == 'p') {
> +				mod_l[fmt_cnt] = true;
> +				fmt_cnt++;

So you also allow pointer conversions like "%pS" and "%pF"?

> +				continue;
> +			}
> +
> +			if (fmt[i] == 'l') {
> +				mod_l[fmt_cnt] = true;
> +				i++;
> +				if (i >= fmt_size)
> +					return -EINVAL;
> +			}
> +
> +			if (fmt[i] != 'd' && fmt[i] != 'u' && fmt[i] != 'x')
> +				return -EINVAL;
> +			fmt_cnt++;
> +		}
> +
> +	return __trace_printk(1/* fake ip will not be printed */, fmt,
> +			      mod_l[0] ? r3 : (u32) r3,
> +			      mod_l[1] ? r4 : (u32) r4,
> +			      mod_l[2] ? r5 : (u32) r5);

Does the above work on 32 bit machines? as "%ld" would be (u32), but
here you are passing in u64.

-- Steve

> +}
> +
>  static struct bpf_func_proto kprobe_prog_funcs[] = {
>  	[BPF_FUNC_probe_read] = {
>  		.func = bpf_probe_read,
> @@ -76,6 +130,13 @@ static struct bpf_func_proto kprobe_prog_funcs[] = {
>  		.gpl_only = true,
>  		.ret_type = RET_INTEGER,
>  	},
> +	[BPF_FUNC_trace_printk] = {
> +		.func = bpf_trace_printk,
> +		.gpl_only = true,
> +		.ret_type = RET_INTEGER,
> +		.arg1_type = ARG_PTR_TO_STACK,
> +		.arg2_type = ARG_CONST_STACK_SIZE,
> +	},
>  };
>  
>  static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id)
> @@ -90,6 +151,13 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
>  	default:
>  		if (func_id < 0 || func_id >= ARRAY_SIZE(kprobe_prog_funcs))
>  			return NULL;
> +
> +		if (func_id == BPF_FUNC_trace_printk)
> +			/* this program might be calling bpf_trace_printk,
> +			 * so allocate per-cpu printk buffers
> +			 */
> +			trace_printk_init_buffers();
> +
>  		return &kprobe_prog_funcs[func_id];
>  	}
>  }
