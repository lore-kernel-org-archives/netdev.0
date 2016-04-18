From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 2/8] perf, bpf: allow bpf programs attach to
 tracepoints
Date: Mon, 18 Apr 2016 14:43:07 -0700
Message-ID: <571554EB.9010702@fb.com>
References: <1459831974-2891931-1-git-send-email-ast@fb.com>
 <1459831974-2891931-3-git-send-email-ast@fb.com>
 <20160418162905.220df2f4@gandalf.local.home>
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
In-Reply-To: <20160418162905.220df2f4@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/18/16 1:29 PM, Steven Rostedt wrote:
> On Mon, 4 Apr 2016 21:52:48 -0700
> Alexei Starovoitov <ast@fb.com> wrote:
>
>> introduce BPF_PROG_TYPE_TRACEPOINT program type and allow it to be
>> attached to tracepoints.
>> The tracepoint will copy the arguments in the per-cpu buffer and pass
>> it to the bpf program as its first argument.
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
>> Same rule applies here: static tracepoint fields should only be accessed
>> in a format defined in tracepoint/format. The order of fields and
>> field sizes are not an ABI.
>>
>> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
>> ---
...
>> -	entry = perf_trace_buf_prepare(__entry_size,			\
>> -			event_call->event.type, &__regs, &rctx);	\
>> +	event_type = prog ? TRACE_EVENT_TYPE_MAX : event_call->event.type; \
>
> Can you move this into perf_trace_entry_prepare?

that's the old version.
The last one are commits 1e1dcd93b46 and 98b5c2c65c295 in net-next.

>> +	if (prog) {							\
>> +		*(struct pt_regs **)entry = __regs;			\
>> +		if (!trace_call_bpf(prog, entry) || hlist_empty(head)) { \
>> +			perf_swevent_put_recursion_context(rctx);	\
>> +			return;						\
>> +		}							\
>> +		memset(&entry->ent, 0, sizeof(entry->ent));		\
>> +	}								\
>
> And perhaps this into perf_trace_buf_submit()?
>
> Tracepoints are a major cause of bloat, and the reasons for these
> prepare and submit functions is to move code out of the macros. Every
> tracepoint in the kernel (1000 and counting) will include this code.
> I've already had complaints that each tracepoint can add up to 5k to
> the core.

I was worried about this too, but single 'if' and two calls
(as in commit 98b5c2c65c295) is a better way, since it's faster, cleaner
and doesn't need to refactor the whole perf_trace_buf_submit() to pass
extra event_call argument to it.
perf_trace_buf_submit() is already ugly with 8 arguments!
Passing more args or creating a struct to pass args only going to
hurt performance without much reduction in .text size.
tinyfication folks will disable tracepoints anyway.
Note that the most common case is bpf returning 0 and not even
calling perf_trace_buf_submit() which is already slow due
to so many args passed on stack.
This stuff is called million times a second, so every instruction
counts.
