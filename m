From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 2/8] perf, bpf: allow bpf programs attach to
 tracepoints
Date: Tue, 5 Apr 2016 11:21:49 -0700
Message-ID: <5704023D.8050601@fb.com>
References: <1459831974-2891931-1-git-send-email-ast@fb.com>
 <1459831974-2891931-3-git-send-email-ast@fb.com>
 <20160405141857.GN3448@twins.programming.kicks-ass.net>
 <5703FF5A.1040707@fb.com>
 <20160405181654.GR3408@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt@goodmis.org>,
	"David S . Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Wang Nan <wangnan0@huawei.com>, Josef Bacik <jbacik@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160405181654.GR3408@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/5/16 11:16 AM, Peter Zijlstra wrote:
> On Tue, Apr 05, 2016 at 11:09:30AM -0700, Alexei Starovoitov wrote:
>>>> @@ -67,6 +69,14 @@ perf_trace_##call(void *__data, proto)					\
>>>>   									\
>>>>   	{ assign; }							\
>>>>   									\
>>>> +	if (prog) {							\
>>>> +		*(struct pt_regs **)entry = __regs;			\
>>>> +		if (!trace_call_bpf(prog, entry) || hlist_empty(head)) { \
>>>> +			perf_swevent_put_recursion_context(rctx);	\
>>>> +			return;						\
>>>> +		}							\
>>>> +		memset(&entry->ent, 0, sizeof(entry->ent));		\
>>>
>>> But if not, you destroy it and then feed it to perf?
>>
>> yes. If bpf prog returns 1 the buffer goes into normal ring-buffer
>> with all perf_event attributes and so on.
>> So far there wasn't a single real use case where we went this path.
>> Programs always do aggregation inside and pass stuff to user space
>> either via bpf maps or via bpf_perf_event_output() helper.
>> I wanted to keep perf_trace_xx() calls to be minimal in .text size
>> so memset above is one x86 instruction, but I don't mind
>> replacing this memset with a call to a helper function that will do:
>>     local_save_flags(flags);
>>     tracing_generic_entry_update(entry, flags, preempt_count());
>>     entry->type = type;
>> Then whether bpf attached or not the ring buffer will see the same
>> raw tracepoint entry. You think it's cleaner?
>
> Yeah, otherwise you get very weird and surprising behaviour.

ok. will respin.

> Also, one possible use-case is dynamic filters where the BPF program is
> basically used to filter events, although I suppose we already have a
> hook for that elsewhere.

There is no other bpf hook for tracepoints. This patch is it.
And yes, after respin such use case will be possible.
Thanks!
