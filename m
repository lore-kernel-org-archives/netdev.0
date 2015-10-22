From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH net-next 2/3] bpf: introduce bpf_perf_event_output()
 helper
Date: Thu, 22 Oct 2015 15:59:30 +0200
Message-ID: <20151022135930.GN3604@twins.programming.kicks-ass.net>
References: <1445396556-4854-1-git-send-email-ast@kernel.org>
 <1445396556-4854-3-git-send-email-ast@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>, Wang Nan <wangnan0@huawei.com>,
	He Kuang <hekuang@huawei.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1445396556-4854-3-git-send-email-ast@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 20, 2015 at 08:02:34PM -0700, Alexei Starovoitov wrote:
> +++ b/kernel/trace/bpf_trace.c
> @@ -215,6 +215,50 @@ const struct bpf_func_proto bpf_perf_event_read_proto = {
>  	.arg2_type	= ARG_ANYTHING,
>  };
>  
> +static u64 bpf_perf_event_output(u64 r1, u64 r2, u64 index, u64 r4, u64 size)
> +{
> +	struct pt_regs *regs = (struct pt_regs *) (long) r1;
> +	struct bpf_map *map = (struct bpf_map *) (long) r2;
> +	struct bpf_array *array = container_of(map, struct bpf_array, map);
> +	void *data = (void *) (long) r4;
> +	struct perf_sample_data sample_data;
> +	struct perf_event *event;
> +	struct perf_raw_record raw = {
> +		.size = size,
> +		.data = data,
> +	};
> +
> +	if (unlikely(index >= array->map.max_entries))
> +		return -E2BIG;
> +
> +	event = (struct perf_event *)array->ptrs[index];
> +	if (unlikely(!event))
> +		return -ENOENT;
> +
> +	if (unlikely(event->attr.type != PERF_TYPE_SOFTWARE ||
> +		     event->attr.config != PERF_COUNT_SW_BPF_OUTPUT))
> +		return -EINVAL;
> +
> +	if (unlikely(event->oncpu != smp_processor_id()))
> +		return -EOPNOTSUPP;
> +
> +	perf_sample_data_init(&sample_data, 0, 0);
> +	sample_data.raw = &raw;
> +	perf_event_output(event, &sample_data, regs);
> +	return 0;
> +}

Note that this function also very much requires event to be local.
