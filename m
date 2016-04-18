From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 0/8] allow bpf attach to tracepoints
Date: Mon, 18 Apr 2016 12:51:43 -0700
Message-ID: <57153ACF.9090105@fb.com>
References: <1459831974-2891931-1-git-send-email-ast@fb.com>
 <20160418121311.10c88768@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"David S . Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Wang Nan <wangnan0@huawei.com>, Josef Bacik <jbacik@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160418121311.10c88768@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/18/16 9:13 AM, Steven Rostedt wrote:
> On Mon, 4 Apr 2016 21:52:46 -0700
> Alexei Starovoitov <ast@fb.com> wrote:
>
>> Hi Steven, Peter,
>>
>> last time we discussed bpf+tracepoints it was a year ago [1] and the reason
>> we didn't proceed with that approach was that bpf would make arguments
>> arg1, arg2 to trace_xx(arg1, arg2) call to be exposed to bpf program
>> and that was considered unnecessary extension of abi. Back then I wanted
>> to avoid the cost of buffer alloc and field assign part in all
>> of the tracepoints, but looks like when optimized the cost is acceptable.
>> So this new apporach doesn't expose any new abi to bpf program.
>> The program is looking at tracepoint fields after they were copied
>> by perf_trace_xx() and described in /sys/kernel/debug/tracing/events/xxx/format
>
> Does this mean that ftrace could use this ability as well? As all the
> current filtering of ftrace was done after it was copied to the buffer,
> and that was what you wanted to avoid.

yeah, it could be added to ftrace as well, but it won't be as effective
as perf_trace, since the cost of trace_event_buffer_reserve() in
trace_event_raw_event_() handler is significantly higher than 
perf_trace_buf_alloc() in perf_trace_().
Then from the program point of view it wouldn't care how that memory
is allocated, so the user tools will just use perf_trace_() style.
The only use case I see for bpf with ftrace's tracepoint handler
is to work as an actual filter, but we already have filters there...
so not clear to me of the actual value of adding bpf to ftrace's
tracepoint handler.
At the same time there is whole ftrace as function tracer. That is
very lucrative field for bpf to plug into ;)

As far as 2nd part of your question about copying. Yeah, it adds to
the cost, so kprobe sometimes is faster than perf_trace tracepoint
that is copying a lot of args which are not going to be used.
