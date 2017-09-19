From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v4 3/4] bpf: add helper bpf_perf_prog_read_value
Date: Tue, 19 Sep 2017 22:40:56 +0200
Message-ID: <59C180D8.1050900@iogearbox.net>
References: <20170919070413.3838201-1-yhs@fb.com> <20170919070413.3838201-4-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com
To: Yonghong Song <yhs@fb.com>, peterz@infradead.org,
        rostedt@goodmis.org, ast@fb.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56363 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751583AbdISUlD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 16:41:03 -0400
In-Reply-To: <20170919070413.3838201-4-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2017 09:04 AM, Yonghong Song wrote:
[...]
>   #ifdef CONFIG_CGROUP_PERF
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 2c68b9e..ba77022 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -590,6 +590,13 @@ union bpf_attr {
>    *     @buf: buf to fill
>    *     @buf_size: size of the buf
>    *     Return: 0 on success or negative error code
> + *
> + * int bpf_perf_prog_read_value(ctx, buf, buf_size)
> + *     read perf prog attached perf event counter and enabled/running time
> + *     @ctx: pointer to ctx
> + *     @buf: buf to fill
> + *     @buf_size: size of the buf
> + *     Return : 0 on success or negative error code
>    */
>   #define __BPF_FUNC_MAPPER(FN)		\
>   	FN(unspec),			\
> @@ -647,6 +654,7 @@ union bpf_attr {
>   	FN(sk_redirect_map),		\
>   	FN(sock_map_update),		\
>   	FN(perf_event_read_value),		\
> +	FN(perf_prog_read_value),		\

(Same here.)

>
>   /* integer value in 'imm' field of BPF_CALL instruction selects which helper
>    * function eBPF program intends to call
> diff --git a/kernel/events/core.c b/kernel/events/core.c
> index 2d5bbe5..d039086 100644
> --- a/kernel/events/core.c
> +++ b/kernel/events/core.c
> @@ -8081,6 +8081,7 @@ static void bpf_overflow_handler(struct perf_event *event,
>   	struct bpf_perf_event_data_kern ctx = {
>   		.data = data,
>   		.regs = regs,
> +		.event = event,
>   	};
>   	int ret = 0;
>
> diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
> index 39ce5d9..596b5c9 100644
> --- a/kernel/trace/bpf_trace.c
> +++ b/kernel/trace/bpf_trace.c
> @@ -603,6 +603,18 @@ BPF_CALL_3(bpf_get_stackid_tp, void *, tp_buff, struct bpf_map *, map,
>   			       flags, 0, 0);
>   }
>
> +BPF_CALL_3(bpf_perf_prog_read_value_tp, void *, ctx, struct bpf_perf_event_value *,
> +	buf, u32, size)

Nit: indent

> +{
> +	struct bpf_perf_event_data_kern *kctx = (struct bpf_perf_event_data_kern *)ctx;

Why having the arg as void * and have this detour instead of having
struct bpf_perf_event_data_kern * right in the helper signature as
argument?

> +	if (size != sizeof(struct bpf_perf_event_value))

unlikely()

> +		return -EINVAL;
> +
> +	return perf_event_read_local(kctx->event, &buf->counter, &buf->enabled,
> +				     &buf->running);
> +}

bpf_perf_prog_read_value_proto_tp would go right underneath here,
and bpf_get_stackid_proto_tp below the previous helper above.

>   static const struct bpf_func_proto bpf_get_stackid_proto_tp = {
>   	.func		= bpf_get_stackid_tp,
>   	.gpl_only	= true,
> @@ -612,6 +624,15 @@ static const struct bpf_func_proto bpf_get_stackid_proto_tp = {
>   	.arg3_type	= ARG_ANYTHING,
>   };
>
> +static const struct bpf_func_proto bpf_perf_prog_read_value_proto_tp = {
> +         .func           = bpf_perf_prog_read_value_tp,
> +         .gpl_only       = true,
> +         .ret_type       = RET_INTEGER,
> +         .arg1_type      = ARG_PTR_TO_CTX,
> +         .arg2_type      = ARG_PTR_TO_UNINIT_MEM,

Same on error path.

> +         .arg3_type      = ARG_CONST_SIZE,
> +};
> +
>   static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id)
>   {
>   	switch (func_id) {
> @@ -619,6 +640,8 @@ static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id)
>   		return &bpf_perf_event_output_proto_tp;
>   	case BPF_FUNC_get_stackid:
>   		return &bpf_get_stackid_proto_tp;
> +	case BPF_FUNC_perf_prog_read_value:
> +		return &bpf_perf_prog_read_value_proto_tp;
>   	default:
>   		return tracing_func_proto(func_id);
>   	}
>
