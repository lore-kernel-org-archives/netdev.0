From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v3 linux-trace 1/8] tracing: attach eBPF programs to
 tracepoints and syscalls
Date: Tue, 10 Feb 2015 16:22:50 -0800
Message-ID: <CAMEtUuzY_Po=WtFEFg1aqzJ8dEF4rHGcWDsaS44KYgACMNPPgA@mail.gmail.com>
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

On Tue, Feb 10, 2015 at 1:53 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
> On Tue, 10 Feb 2015 11:53:22 -0800
> Alexei Starovoitov <ast@plumgrid.com> wrote:
>
>> On Tue, Feb 10, 2015 at 5:05 AM, Steven Rostedt <rostedt@goodmis.org> wrote:
>> > On Mon, 9 Feb 2015 22:10:45 -0800
>> > Alexei Starovoitov <ast@plumgrid.com> wrote:
>> >
>> >> One can argue that current TP_printk format is already an ABI,
>> >> because somebody might be parsing the text output.
>> >
>> > If somebody does, then it is an ABI. Luckily, it's not that useful to
>> > parse, thus it hasn't been an issue. As Linus has stated in the past,
>> > it's not that we can't change ABI interfaces, its just that we can not
>> > change them if there's a user space application that depends on it.
>>
>> there are already tools that parse trace_pipe:
>> https://github.com/brendangregg/perf-tools
>
> Yep, and if this becomes a standard, then any change that makes
> trace_pipe different will be reverted.

I think reading of trace_pipe is widespread.

>> > and expect some events to have specific fields. Now we can add new
>> > fields, or even remove fields that no user space tool is using. This is
>> > because today, tools use libtraceevent to parse the event data.
>>
>> not all tools use libtraceevent.
>> gdb calls perf_event_open directly:
>> https://sourceware.org/git/gitweb.cgi?p=binutils-gdb.git;a=blob;f=gdb/nat/linux-btrace.c
>> and parses PERF_RECORD_SAMPLE as a binary.
>> In this case it's branch records, but I think we never said anywhere
>> that PERF_SAMPLE_IP | PERF_SAMPLE_ADDR should come
>> in this particular order.
>
> What particular order? Note, that's a hardware event, not a software
> one.

yes, but gdb assumes that 'u64 ip' precedes, 'u64 addr'
when attr.sample_type = IP | ADDR whereas this is an
internal order of 'if' statements inside perf_output_sample()...

>> But some maintainers think of them as ABI, whereas others
>> are using them freely. imo it's time to remove ambiguity.
>
> I would love to, and have brought this up at Kernel Summit more than
> once with no solution out of it.

let's try it again at plumbers in august?

For now I'm going to drop bpf+tracepoints, since it's so controversial
and go with bpf+syscall and bpf+kprobe only.

Hopefully by august it will be clear what bpf+kprobes can do
and why I'm excited about bpf+tracepoints in the future.

>> The idea for new style of tracepoints is the following:
>> introduce new macro: DEFINE_EVENT_USER
>> and let programs attach to them.
>
> We actually have that today. But it's TRACE_EVENT_FLAGS(), although
> that should be cleaned up a bit. Frederic added it to label events that
> are safe for perf non root. It seems to be used currently only for
> syscalls.

I didn't mean to let unprivileged apps to use.
Better name probably would be: DEFINE_EVENT_BPF
and only let bpf programs use it.

>> These tracepoint will receive one or two pointers to important
>> structs only. They will not have TP_printk, assign and fields.
>> The placement and arguments to these new tracepoints
>> will be an ABI.
>> All existing tracepoints are not.
>
> TP_printk() is not really an issue.

I think it is. The way things are printed is the most
visible part of tracepoints and I suspect maintainers don't
want to add new ones, because internal fields are printed
and users do parse trace_pipe.
Recent discussion about tcp instrumentation was
about adding new tracepoints and a module to print them.
As soon as something like this is in, the next question
'what we're going to do when more arguments need
to be printed'...

imo the solution is DEFINE_EVENT_BPF that doesn't
print anything and a bpf program to process it.
Then programs decide what they like to pass to
user space and in what format.
The kernel/user ABI is the position of this new tracepoint
and arguments that are passed in.
bpf program takes care of walking pointers, extracting
interesting fields, aggregating and passing them to
user in the format specific to this particular program.
Then when user wants to collect more fields it just
changes the program and corresponding userland side.

>> The position of new tracepoints and their arguments
>> will be an ABI and the programs can be both.
>
> You means "special tracepoints" one that does export the arguments?
>
> Question is, how many maintainers will add these, knowing that they
> will have to be forever maintained as is.

Obviously we would need to prove usefulness of
tracepoint_bpf before they're accepted.
Hopefully bpf+kprobe will make an impression on its own
and users would want similar but without debug info.

>> If program is using bpf_fetch*() helpers it obviously
>> wants to access internal data structures, so
>> it's really nothing more, but 'safe kernel module'
>> and kernel layout specific.
>> Both old and new tracepoints + programs will be used
>> for live kernel debugging.
>>
>> If program is accessing user-ized data structures then
>
> Technically, the TP_struct__entry is a user-ized structure.
>
>> it is portable and will run on any kernel.
>> In uapi header we can define:
>> struct task_struct_user {
>>   int pid;
>>   int prio;
>
> Here's a perfect example of something that looks stable to show to
> user space, but is really a pimple that is hiding cancer.
>
> Lets start with pid. We have name spaces. What pid will be put there?
> We have to show the pid of the name space it is under.
>
> Then we have prio. What is prio in the DEADLINE scheduler. It is rather
> meaningless. Also, it is meaningless in SCHED_OTHER.
>
> Also note that even for SCHED_FIFO, the prio is used differently in the
> kernel than it is in userspace. For the kernel, lower is higher.

well, ->prio and ->pid are already printed by sched tracepoints
and their meaning depends on scheduler. So users taking that
into account.
I'm not suggesting to preserve the meaning of 'pid' semantically
in all cases. That's not what users would want anyway.
I want to allow programs to access important fields and print
them in more generic way than current TP_printk does.
Then exposed ABI of such tracepoint_bpf is smaller than
with current tracepoints.

>> };
>> and let bpf programs access it via real 'struct task_struct *'
>> pointer passed into tracepoint.
>> bpf loader will translate offsets and sizes used inside
>> the program into real task_struct's offsets and loads.
>
> It would need to do more that that. It may have to calculate the value
> that it returns, as the internal value may be different with different
> kernels.

back to 'prio'... the 'prio' accessible from the program
should be the same 'prio' that we're storing inside task_struct.
No extra conversions.
The bpf-script for sched analytics would want to see
the actual value to make sense of it.

> But what if the userspace tool depends on that value returning
> something meaningful. If it was meaningful in the past, it will have to
> be meaningful in the future, even if the internals of the kernel make
> it otherwise.

in some cases... yes. if we make a poor choice of
selecting fields for this 'task_struct_user' then some fields
may disappear from real task_struct, and placeholders
will be left in _user version.
so exposed fields need to be thought through.

In case of networking some of these choices were
already made by classic bpf. Fields:
protocol, pkttype, ifindex, hatype, mark, hash, queue_mapping
have to be reference-able from 'skb' pointer.
They can move from skb to some other struct, change
their sizes, location within sk_buff, etc
They can even disappear, but user visible
struct sk_buff_user will still contain the above.

> eBPF is very flexible, which means it is bound to have someone use it
> in a way you never dreamed of, and that will be what bites you in the
> end (pun intended).

understood :)
let's start slow then with bpf+syscall and bpf+kprobe only.

>> also not all bpf programs are equal.
>> bpf+existing tracepoint is not ABI
>
> Why not?

well, because we want to see more tracepoints in the kernel.
We're already struggling to add more.

>> bpf+new tracepoint is ABI if programs are not using bpf_fetch
>
> How is this different?

the new ones will be explicit by definition.

>> bpf+syscall is ABI if programs are not using bpf_fetch
>
> Well, this is easy. As syscalls are ABI, and the tracepoints for them
> match the ABI, it by default becomes an ABI.
>
>> bpf+kprobe is not ABI
>
> Right.
>
>> bpf+sockets is ABI
>
> Right, because sockets themselves are ABI.
>
>> At the end we want most of the programs to be written
>> without assuming anything about kernel internals.
>> But for live kernel debugging we will write programs
>> very specific to given kernel layout.
>
> And here lies the trick. How do we differentiate applications for
> everyday use from debugging tools? There's been times when debugging
> tools have shown themselves as being so useful they become everyday
> use tools.
>
>>
>> We can categorize the above in non-ambigous via
>> bpf program type.
>> Programs with:
>> BPF_PROG_TYPE_TRACEPOINT - not ABI
>> BPF_PROG_TYPE_KPROBE - not ABI
>> BPF_PROG_TYPE_SOCKET_FILTER - ABI
>
> Again, what enforces this? (hint, it's Linus)
>
>
>>
>> for my proposed 'new tracepoints' we can add type:
>> BPF_PROG_TYPE_TRACEPOINT_USER - ABI
>> and disallow calls to bpf_fetch*() for them.
>> To make it more strict we can do kernel version check
>> for all prog types that are 'not ABI', but is it really necessary?
>
> If we have something that makes it difficult for a tool to work from
> one kernel to the next, or ever with different configs, where that tool
> will never become a standard, then that should be good enough to keep
> it from dictating user ABI.
>
> To give you an example, we thought about scrambling the trace event
> field locations from boot to boot to keep tools from hard coding the
> event layout. This may sound crazy, but developers out there are crazy.
> And if you want to keep them from abusing interfaces, you just need to
> be a bit more crazy than they are.

that is indeed crazy. the point is understood.

right now I cannot think of a solid way to prevent abuse
of bpf+tracepoint, so just going to drop it for now.
Cool things can be done with bpf+kprobe/syscall already.

>> To summarize and consolidate other threads:
>> - I will remove reading of PERF_SAMPLE_RAW in tracex1 example.
>> it's really orthogonal to this whole discussion.
>
> Or yous libtraceevent ;-) We really need to finish that and package it
> up for distros.

sure. some sophisticated example can use it too.

>> - will add more comments through out that just because
>> programs can read tracepoint arguments, they shouldn't
>> make any assumptions that args stays as-is from version to version
>
> We may need to find a way to actually keep it from being as is from
> version to version even if the users do not change.
>
>> - will work on a patch to demonstrate how few in-kernel
>> structures can be user-ized and how programs can access
>> them in version-indepedent way
>
> It will be interesting to see what kernel structures can be user-ized
> that are not already used by system calls.

well, for networking, few fields I mentioned above would
be enough for most of the programs.

>> btw the concept of user-ized data structures already exists
>> with classic bpf, since 'A = load -0x1000' is translated into
>> 'A = skb->protocol'. I'm thinking of something similar
>> but more generic and less obscure.
>
> I have to try to wrap my head around understanding the classic bpf, and
> how "load -0x1000" translates to "skb->protocol". Is that documented
> somewhere?

well, the magic constants are in uapi/linux/filter.h
load -0x1000 = skb->protocol
load -0x1000 + 4 = skb->pkt_type
load -0x1000 + 8 = skb->dev->ifindex
for eBPF I want to clean it up in a way that user program
will see:
struct sk_buff_user {
  int protocol;
  int pkt_type;
  int ifindex;
 ...
};
and C code of bpf program will look normal: skb->ifindex.
bpf loader will do verification and translation of
'load skb_ptr+12' into sequence of loads with correct
internal offsets.
So struct sk_buff_user is only an interface. It won't exist
in such layout in memory.
