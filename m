From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v9 tip 8/9] samples: bpf: IO latency analysis (iosnoop/heatmap)
Date: Mon, 23 Mar 2015 10:41:21 -0700
Message-ID: <55105041.5090400@plumgrid.com>
References: <1426894210-27441-1-git-send-email-ast@plumgrid.com> <1426894210-27441-9-git-send-email-ast@plumgrid.com> <20150323074028.GE25184@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150323074028.GE25184@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/23/15 12:40 AM, Ingo Molnar wrote:
>
> * Alexei Starovoitov <ast@plumgrid.com> wrote:
>
>> BPF C program attaches to blk_mq_start_request/blk_update_request kprobe events
>> to calculate IO latency.
>
>   ...
>
>> +/* kprobe is NOT a stable ABI
>> + * This bpf+kprobe example can stop working any time.
>> + */
>> +SEC("kprobe/blk_mq_start_request")
>> +int bpf_prog1(struct pt_regs *ctx)
>> +{
>> +	long rq = ctx->di;
>> +	u64 val = bpf_ktime_get_ns();
>> +
>> +	bpf_map_update_elem(&my_map, &rq, &val, BPF_ANY);
>> +	return 0;
>> +}
>
> So just to make sure the original BPF instrumentation model is still
> upheld: no matter in what way the kernel changes, neither the kprobe,
> nor the BPF program can ever crash or corrupt the kernel, assuming the
> kprobes, perf and BPF subsystem has no bugs, correct?

yes. of course. That was always #1 requirement.

> So 'stops working' here means that the instrumentation data might not
> be reliable if kernel internal interfaces change - but it won't ever
> make the kernel unreliable in any fashion. Right?

yes. of course.

The only situations where it can 'stop working':
- in-kernel blk_mq_start_request function is renamed, so kprobe cannot 
find it and cannot attach.
- arguments to blk_mq_start_request change. Then ctx->di can be 
meaningless and using it as key into map is useless.
- whole logic of blk_mq_start_request/blk_update_request pair changes.
then this sample code won't be measuring any useful io latency.

In all cases kernel will never crash (barring bugs in bpf, kprobe 
subsystems).
