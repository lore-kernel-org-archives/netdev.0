From: He Kuang <hekuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v6 tip 3/8] tracing: allow BPF programs to call bpf_ktime_get_ns()
Date: Fri, 13 Mar 2015 19:24:27 +0800
Message-ID: <5502C8EB.9070307@huawei.com>
References: <1426047534-8148-1-git-send-email-ast@plumgrid.com> <1426047534-8148-4-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	<linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <wangnan0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1426047534-8148-4-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi, Alexei

I've followed up your bpf version. In bpf filter, sometimes we need to
get 'pid' and some other context informations to decide whether to
filter or not.

For example, to trace a vfs read procedure, we can insert bpf program to
'__vfs_read(struct file *file, char __user *buf ...)', mark some of
'buf' addresses and only trace the read procedure of these 'buf's. But
this parameter is a userspace pointer, the value is meaningless to other
processes, so we should also record 'pid' to make sense.

To a function like __vfs_read, 'pid' can't be extracted from function
parameters directly. What's your opinion on this issue?

Thanks!

On 2015/3/11 12:18, Alexei Starovoitov wrote:
> bpf_ktime_get_ns() is used by programs to compue time delta between events
> or as a timestamp
>
> Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
> ---
>   include/uapi/linux/bpf.h |    1 +
>   kernel/trace/bpf_trace.c |   11 +++++++++++
>   2 files changed, 12 insertions(+)
>
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 4486d36d2e9e..101e509d1001 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -165,6 +165,7 @@ enum bpf_func_id {
>   	BPF_FUNC_map_update_elem, /* int map_update_elem(&map, &key, &value, flags) */
>   	BPF_FUNC_map_delete_elem, /* int map_delete_elem(&map, &key) */
>   	BPF_FUNC_probe_read,      /* int bpf_probe_read(void *dst, int size, void *src) */
> +	BPF_FUNC_ktime_get_ns,    /* u64 bpf_ktime_get_ns(void) */
>   	__BPF_FUNC_MAX_ID,
>   };
>   
> diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
> index 450ea93ac4ab..ee7c2c629e75 100644
> --- a/kernel/trace/bpf_trace.c
> +++ b/kernel/trace/bpf_trace.c
> @@ -56,6 +56,12 @@ static u64 bpf_probe_read(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
>   	return probe_kernel_read(dst, unsafe_ptr, size);
>   }
>   
> +static u64 bpf_ktime_get_ns(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
> +{
> +	/* NMI safe access to clock monotonic */
> +	return ktime_get_mono_fast_ns();
> +}
> +
>   static struct bpf_func_proto kprobe_prog_funcs[] = {
>   	[BPF_FUNC_probe_read] = {
>   		.func = bpf_probe_read,
> @@ -65,6 +71,11 @@ static struct bpf_func_proto kprobe_prog_funcs[] = {
>   		.arg2_type = ARG_CONST_STACK_SIZE,
>   		.arg3_type = ARG_ANYTHING,
>   	},
> +	[BPF_FUNC_ktime_get_ns] = {
> +		.func = bpf_ktime_get_ns,
> +		.gpl_only = true,
> +		.ret_type = RET_INTEGER,
> +	},
>   };
>   
>   static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id)
