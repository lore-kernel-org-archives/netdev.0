From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v3 linux-trace 1/8] tracing: attach eBPF programs to
 tracepoints and syscalls
Date: Tue, 10 Feb 2015 19:04:55 -0800
Message-ID: <CAMEtUuy+B9aXP-8m7tA6aNxnS4SKRhMpfGEdWMcbxbj7ggOATw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ingo Molnar <mingo@kernel.org>, Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 10, 2015 at 4:50 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
>
>> >> But some maintainers think of them as ABI, whereas others
>> >> are using them freely. imo it's time to remove ambiguity.
>> >
>> > I would love to, and have brought this up at Kernel Summit more than
>> > once with no solution out of it.
>>
>> let's try it again at plumbers in august?
>
> Well, we need a statement from Linus. And it would be nice if we could
> also get Ingo involved in the discussion, but he seldom comes to
> anything but Kernel Summit.

+1

> BTW, I wonder if I could make a simple compiler in the kernel that
> would translate the current ftrace filters into a BPF program, where it
> could use the program and not use the current filter logic.

yep. I've sent that patch last year.
It converted pred_tree into bpf program.
I can try to dig it up. It doesn't provide extra programmability
though, just makes filtering logic much faster.

>> imo the solution is DEFINE_EVENT_BPF that doesn't
>> print anything and a bpf program to process it.
>
> You mean to be completely invisible to ftrace? And the debugfs/tracefs
> directory?

I mean it will be seen in tracefs to get 'id', but without enable/format/filter

>> I'm not suggesting to preserve the meaning of 'pid' semantically
>> in all cases. That's not what users would want anyway.
>> I want to allow programs to access important fields and print
>> them in more generic way than current TP_printk does.
>> Then exposed ABI of such tracepoint_bpf is smaller than
>> with current tracepoints.
>
> Again, this would mean they become invisible to ftrace, and even
> ftrace_dump_on_oops.

yes, since these new tracepoints have no meat inside them.
They're placeholders sitting idle and waiting for bpf to do
something useful with them.

> I'm not fully understanding what is to be exported by this new ABI. If
> the fields available, will always be available, then why can't the
> appear in a TP_printk()?

say, we define trace_netif_rx_entry() as this new tracepoint_bpf.
It will have only one argument 'skb'.
bpf program will read and print skb fields the way it likes
for particular tracing scenario.
So instead of making
TP_printk("dev=%s napi_id=%#x queue_mapping=%u skbaddr=%p
vlan_tagged=%d vlan_proto=0x%04x vlan_tci=0x%04x protocol=0x%04x
ip_summed=%d hash=0x%08x l4_hash=%d len=%u data_len=%u truesize=%u
mac_header_valid=%d mac_header=%d nr_frags=%d gso_size=%d
gso_type=%#x",...
the abi exposed via trace_pipe (as it is today),
the new tracepoint_bpf abi is presence of 'skb' pointer as one
and only argument to bpf program.
Future refactoring of netif_rx would need to guarantee
that trace_netif_rx_entry(skb) is called. that's it.
imo such tracepoints are much easier to deal with during
code changes.

May be some of the existing tracepoints like this one that
takes one argument can be marked 'bpf-ready', so that
programs can attach to them only.

>> let's start slow then with bpf+syscall and bpf+kprobe only.
>
> I'm fine with that.

thanks. will wait for merge window to close and will repost.
