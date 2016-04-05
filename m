From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 2/8] perf, bpf: allow bpf programs attach to
 tracepoints
Date: Tue, 5 Apr 2016 11:09:30 -0700
Message-ID: <5703FF5A.1040707@fb.com>
References: <1459831974-2891931-1-git-send-email-ast@fb.com>
 <1459831974-2891931-3-git-send-email-ast@fb.com>
 <20160405141857.GN3448@twins.programming.kicks-ass.net>
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
In-Reply-To: <20160405141857.GN3448@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/5/16 7:18 AM, Peter Zijlstra wrote:
> On Mon, Apr 04, 2016 at 09:52:48PM -0700, Alexei Starovoitov wrote:
>> introduce BPF_PROG_TYPE_TRACEPOINT program type and allow it to be
>> attached to tracepoints.
>
> More specifically the perf tracepoint handler, not tracepoints directly.

yes. perf tracepoint handler only. There is no attempt here to attach
to ftrace tracepoint handler.

>> The tracepoint will copy the arguments in the per-cpu buffer and pass
>> it to the bpf program as its first argument.
>
>> The layout of the fields can be discovered by doing
>> 'cat /sys/kernel/debug/tracing/events/sched/sched_switch/format'
>> prior to the compilation of the program with exception that first 8 bytes
>> are reserved and not accessible to the program. This area is used to store
>> the pointer to 'struct pt_regs' which some of the bpf helpers will use:
>> +---------+
>> | 8 bytes | hidden 'struct pt_regs *' (inaccessible to bpf program)
>> +---------+
>> | N bytes | static tracepoint fields defined in tracepoint/format (bpf readonly)
>> +---------+
>> | dynamic | __dynamic_array bytes of tracepoint (inaccessible to bpf yet)
>> +---------+
>>
>> Not that all of the fields are already dumped to user space via perf ring buffer
>> and some application access it directly without consulting tracepoint/format.
>
> We call those apps broken..

yes.
uapi/linux/perf_event.h lines 742-749 are pretty clear about it:
"In other words, PERF_SAMPLE_RAW contents are not an ABI"

>> Same rule applies here: static tracepoint fields should only be accessed
>> in a format defined in tracepoint/format. The order of fields and
>> field sizes are not an ABI.
>
>
>> @@ -56,8 +57,9 @@ perf_trace_##call(void *__data, proto)					\
>>   			     sizeof(u64));				\
>>   	__entry_size -= sizeof(u32);					\
>>   									\
>> -	entry = perf_trace_buf_prepare(__entry_size,			\
>> -			event_call->event.type, &__regs, &rctx);	\
>> +	event_type = prog ? TRACE_EVENT_TYPE_MAX : event_call->event.type; \
>> +	entry = perf_trace_buf_prepare(__entry_size, event_type,	\
>> +				       &__regs, &rctx);			\
>>   	if (!entry)							\
>>   		return;							\
>>   									\
>> @@ -67,6 +69,14 @@ perf_trace_##call(void *__data, proto)					\
>>   									\
>>   	{ assign; }							\
>>   									\
>> +	if (prog) {							\
>> +		*(struct pt_regs **)entry = __regs;			\
>> +		if (!trace_call_bpf(prog, entry) || hlist_empty(head)) { \
>> +			perf_swevent_put_recursion_context(rctx);	\
>> +			return;						\
>
> So if the prog 'fails' you consume the entry,

I wouldn't call it 'fails' ;)
The interpretation of return code from bpf program is defined
in kernel/trace/bpf_trace.c as:
  * 0 - return from kprobe (event is filtered out)
  * 1 - store kprobe event into ring buffer
  * Other values are reserved and currently alias to 1

so the above !trace_call_bpf() check matches existing bpf+kprobe
behavior.

>
>> +		}							\
>> +		memset(&entry->ent, 0, sizeof(entry->ent));		\
>
> But if not, you destroy it and then feed it to perf?

yes. If bpf prog returns 1 the buffer goes into normal ring-buffer
with all perf_event attributes and so on.
So far there wasn't a single real use case where we went this path.
Programs always do aggregation inside and pass stuff to user space
either via bpf maps or via bpf_perf_event_output() helper.
I wanted to keep perf_trace_xx() calls to be minimal in .text size
so memset above is one x86 instruction, but I don't mind
replacing this memset with a call to a helper function that will do:
    local_save_flags(flags);
    tracing_generic_entry_update(entry, flags, preempt_count());
    entry->type = type;
Then whether bpf attached or not the ring buffer will see the same
raw tracepoint entry. You think it's cleaner?

>
>> +	}								\
>>   	perf_trace_buf_submit(entry, __entry_size, rctx, __addr,	\
>>   		__count, __regs, head, __task);				\
>>   }
>
>
>> diff --git a/kernel/trace/trace_event_perf.c b/kernel/trace/trace_event_perf.c
>> index 7a68afca8249..7ada829029d3 100644
>> --- a/kernel/trace/trace_event_perf.c
>> +++ b/kernel/trace/trace_event_perf.c
>> @@ -284,6 +284,9 @@ void *perf_trace_buf_prepare(int size, unsigned short type,
>>   		*regs = this_cpu_ptr(&__perf_regs[*rctxp]);
>>   	raw_data = this_cpu_ptr(perf_trace_buf[*rctxp]);
>>
>> +	if (type == TRACE_EVENT_TYPE_MAX)
>> +		return raw_data;
>> +
>>   	/* zero the dead bytes from align to not leak stack to user */
>>   	memset(&raw_data[size - sizeof(u64)], 0, sizeof(u64));
>
> What's this hunk do? Why can you skip this stuff for BPF attached
> events?

that hunk is skipping init of first 8 bytes, which are occupied
by 'struct trace_entry' normally and are inited as:
    local_save_flags(flags);
    tracing_generic_entry_update(entry, flags, preempt_count());
    entry->type = type;
that adds extra overhead that bpf progs don't need.
If bpf needs current pid, it calls bpf_get_current_pid_tgid() helper.
local_save_flags() is also quite slow x86 insn that is not needed.
If programs would need to read flags, we can introduce new helper
to read it.
These 8 bytes are instead used to store hidden 'struct pt_regs'
pointer which is invisible to bpf programs directly and used
by two bpf helpers: bpf_get_stackid() and bpf_perf_event_output()
which need pt_regs. See patch 4/8
