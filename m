From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v4 1/4] bpf: add helper bpf_perf_event_read_value
 for perf event array map
Date: Tue, 19 Sep 2017 22:33:26 +0200
Message-ID: <59C17F16.10503@iogearbox.net>
References: <20170919070413.3838201-1-yhs@fb.com> <20170919070413.3838201-2-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com
To: Yonghong Song <yhs@fb.com>, peterz@infradead.org,
        rostedt@goodmis.org, ast@fb.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55395 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751348AbdISUdg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 16:33:36 -0400
In-Reply-To: <20170919070413.3838201-2-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2017 09:04 AM, Yonghong Song wrote:
[...]

Just some minor things, but a bit scattered.

> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 43ab5c4..2c68b9e 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -582,6 +582,14 @@ union bpf_attr {
>    *	@map: pointer to sockmap to update
>    *	@key: key to insert/update sock in map
>    *	@flags: same flags as map update elem
> + *
> + * int bpf_perf_event_read_value(map, flags, buf, buf_size)
> + *     read perf event counter value and perf event enabled/running time
> + *     @map: pointer to perf_event_array map
> + *     @flags: index of event in the map or bitmask flags
> + *     @buf: buf to fill
> + *     @buf_size: size of the buf
> + *     Return: 0 on success or negative error code
>    */
>   #define __BPF_FUNC_MAPPER(FN)		\
>   	FN(unspec),			\
> @@ -638,6 +646,7 @@ union bpf_attr {
>   	FN(redirect_map),		\
>   	FN(sk_redirect_map),		\
>   	FN(sock_map_update),		\
> +	FN(perf_event_read_value),		\

Nit: can you indent the '\' so it aligns with the rest

>   /* integer value in 'imm' field of BPF_CALL instruction selects which helper
>    * function eBPF program intends to call
> @@ -681,7 +690,8 @@ enum bpf_func_id {
>   #define BPF_F_ZERO_CSUM_TX		(1ULL << 1)
>   #define BPF_F_DONT_FRAGMENT		(1ULL << 2)
>
> -/* BPF_FUNC_perf_event_output and BPF_FUNC_perf_event_read flags. */
> +/* BPF_FUNC_perf_event_output, BPF_FUNC_perf_event_read and
> + * BPF_FUNC_perf_event_read_value flags. */

Nit: comment style

>   #define BPF_F_INDEX_MASK		0xffffffffULL
>   #define BPF_F_CURRENT_CPU		BPF_F_INDEX_MASK
>   /* BPF_FUNC_perf_event_output for sk_buff input context. */
> @@ -864,4 +874,10 @@ enum {
>   #define TCP_BPF_IW		1001	/* Set TCP initial congestion window */
>   #define TCP_BPF_SNDCWND_CLAMP	1002	/* Set sndcwnd_clamp */
>
> +struct bpf_perf_event_value {
> +	__u64 counter;
> +	__u64 enabled;
> +	__u64 running;
> +};
> +
[...]
> diff --git a/kernel/events/core.c b/kernel/events/core.c
> index 3e691b7..2d5bbe5 100644
> --- a/kernel/events/core.c
> +++ b/kernel/events/core.c
> @@ -3684,10 +3684,12 @@ static inline u64 perf_event_count(struct perf_event *event)
>    *     will not be local and we cannot read them atomically
>    *   - must not have a pmu::count method
>    */
> -int perf_event_read_local(struct perf_event *event, u64 *value)
> +int perf_event_read_local(struct perf_event *event, u64 *value,
> +			  u64 *enabled, u64 *running)
>   {
>   	unsigned long flags;
>   	int ret = 0;
> +	u64 now;
>
>   	/*
>   	 * Disabling interrupts avoids all counter scheduling (context
> @@ -3718,14 +3720,21 @@ int perf_event_read_local(struct perf_event *event, u64 *value)
>   		goto out;
>   	}
>
> +	now = event->shadow_ctx_time + perf_clock();
> +	if (enabled)
> +		*enabled = now - event->tstamp_enabled;
>   	/*
>   	 * If the event is currently on this CPU, its either a per-task event,
>   	 * or local to this CPU. Furthermore it means its ACTIVE (otherwise
>   	 * oncpu == -1).
>   	 */
> -	if (event->oncpu == smp_processor_id())
> +	if (event->oncpu == smp_processor_id()) {
>   		event->pmu->read(event);
> -
> +		if (running)
> +			*running = now - event->tstamp_running;
> +	} else if (running) {
> +		*running = event->total_time_running;
> +	}
>   	*value = local64_read(&event->count);
>   out:
>   	local_irq_restore(flags);
> diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
> index dc498b6..39ce5d9 100644
> --- a/kernel/trace/bpf_trace.c
> +++ b/kernel/trace/bpf_trace.c
> @@ -255,13 +255,13 @@ const struct bpf_func_proto *bpf_get_trace_printk_proto(void)
>   	return &bpf_trace_printk_proto;
>   }
>
> -BPF_CALL_2(bpf_perf_event_read, struct bpf_map *, map, u64, flags)
> -{
> +static __always_inline int
> +get_map_perf_counter(struct bpf_map *map, u64 flags,
> +		u64 *value, u64 *enabled, u64 *running) {

Nit: coding style

>   	struct bpf_array *array = container_of(map, struct bpf_array, map);
>   	unsigned int cpu = smp_processor_id();
>   	u64 index = flags & BPF_F_INDEX_MASK;
>   	struct bpf_event_entry *ee;
> -	u64 value = 0;
>   	int err;
>
>   	if (unlikely(flags & ~(BPF_F_INDEX_MASK)))
> @@ -275,7 +275,17 @@ BPF_CALL_2(bpf_perf_event_read, struct bpf_map *, map, u64, flags)
>   	if (!ee)
>   		return -ENOENT;
>
> -	err = perf_event_read_local(ee->event, &value);
> +	err = perf_event_read_local(ee->event, value, enabled, running);
> +	return err;

err can be removed entirely then.

   return perf_event_read_local(ee->event, value, enabled, running);

> +}
> +
> +

Nit: Two newlines slipped in.

> +BPF_CALL_2(bpf_perf_event_read, struct bpf_map *, map, u64, flags)
> +{
> +	u64 value = 0;
> +	int err;
> +
> +	err = get_map_perf_counter(map, flags, &value, NULL, NULL);
>   	/*
>   	 * this api is ugly since we miss [-22..-2] range of valid
>   	 * counter values, but that's uapi
> @@ -285,6 +295,20 @@ BPF_CALL_2(bpf_perf_event_read, struct bpf_map *, map, u64, flags)
>   	return value;
>   }

Can you also move the bpf_perf_event_read_proto definition right
underneath here as we have with all other helpers?

> +BPF_CALL_4(bpf_perf_event_read_value, struct bpf_map *, map, u64, flags,
> +	struct bpf_perf_event_value *, buf, u32, size)

Nit: indent

> +{
> +	int err;
> +
> +	if (unlikely(size != sizeof(struct bpf_perf_event_value)))
> +		return -EINVAL;
> +	err = get_map_perf_counter(map, flags, &buf->counter, &buf->enabled,
> +                            &buf->running);

^ This is only indented with spaces.

> +	if (err)
> +		return err;
> +	return 0;

Also here err can be removed entirely, make it
less convoluted:

BPF_CALL_4(bpf_perf_event_read_value, struct bpf_map *, map, u64, flags,
           struct bpf_perf_event_value *, eval, u32, size)
{
        if (unlikely(size != sizeof(struct bpf_perf_event_value)))
                return -EINVAL;

        return get_map_perf_counter(map, flags, &eval->counter, &eval->enabled,
                                    &eval->running);
}

> +}
> +
>   static const struct bpf_func_proto bpf_perf_event_read_proto = {
>   	.func		= bpf_perf_event_read,
>   	.gpl_only	= true,
> @@ -293,6 +317,16 @@ static const struct bpf_func_proto bpf_perf_event_read_proto = {
>   	.arg2_type	= ARG_ANYTHING,
>   };
>
> +static const struct bpf_func_proto bpf_perf_event_read_value_proto = {
> +	.func		= bpf_perf_event_read_value,
> +	.gpl_only	= true,
> +	.ret_type	= RET_INTEGER,
> +	.arg1_type	= ARG_CONST_MAP_PTR,
> +	.arg2_type	= ARG_ANYTHING,
> +	.arg3_type	= ARG_PTR_TO_UNINIT_MEM,

If you do that, then error paths need to memset the region, e.g.
see bpf_skb_get_tunnel_opt() and bpf_skb_get_tunnel_key() helpers
which operate similarly.

> +	.arg4_type	= ARG_CONST_SIZE,
> +};
> +
>   static DEFINE_PER_CPU(struct perf_sample_data, bpf_sd);
>
>   static __always_inline u64
> @@ -499,6 +533,8 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
>   		return &bpf_perf_event_output_proto;
>   	case BPF_FUNC_get_stackid:
>   		return &bpf_get_stackid_proto;
> +	case BPF_FUNC_perf_event_read_value:
> +		return &bpf_perf_event_read_value_proto;
>   	default:
>   		return tracing_func_proto(func_id);
>   	}
>
