From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v3 linux-trace 1/8] tracing: attach eBPF programs to
 tracepoints and syscalls
Date: Tue, 10 Feb 2015 22:33:05 -0800
Message-ID: <CAMEtUuxizvHF09y_vU-c+L=n16tqWDqJPTybGB1a_OqN7p+jsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 10, 2015 at 8:31 PM, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org> wrote:
>> > Again, this would mean they become invisible to ftrace, and even
>> > ftrace_dump_on_oops.
>>
>> yes, since these new tracepoints have no meat inside them.
>> They're placeholders sitting idle and waiting for bpf to do
>> something useful with them.
>
> Hmm, I have a patch somewhere (never posted it), that add
> TRACE_MARKER(), which basically would just print that it was hit. But
> no data was passed to it. Something like that I would be more inclined
> to take. Then the question is, what can bpf access there? Could just be
> a place holder to add a "fast kprobe". This way, it can show up in
> trace events with enable and and all that, it just wont have any data
> to print out besides the normal pid, flags, etc.
>
> But because it will inject a nop, that could be converted to a jump, it
> will give you the power of kprobes but with the speed of a tracepoint.

fair enough.
Something like TRACE_MARKER(arg1, arg2) that prints
it was hit without accessing the args would be enough.
Without any args it is indeed a 'fast kprobe' only.
Debug info would still be needed to access
function arguments.
On x64 function entry point and x64 abi make it easy
to access args, but i386 or kprobe in the middle
lose visibility when debug info is not available.
TRACE_MARKER (with few key args that function
is operating on) is enough to achieve roughly the same
as kprobe without debug info.

>> > I'm not fully understanding what is to be exported by this new ABI. If
>> > the fields available, will always be available, then why can't the
>> > appear in a TP_printk()?
>>
>> say, we define trace_netif_rx_entry() as this new tracepoint_bpf.
>> It will have only one argument 'skb'.
>> bpf program will read and print skb fields the way it likes
>> for particular tracing scenario.
>> So instead of making
>> TP_printk("dev=%s napi_id=%#x queue_mapping=%u skbaddr=%p
>> vlan_tagged=%d vlan_proto=0x%04x vlan_tci=0x%04x protocol=0x%04x
>> ip_summed=%d hash=0x%08x l4_hash=%d len=%u data_len=%u truesize=%u
>> mac_header_valid=%d mac_header=%d nr_frags=%d gso_size=%d
>> gso_type=%#x",...
>> the abi exposed via trace_pipe (as it is today),
>> the new tracepoint_bpf abi is presence of 'skb' pointer as one
>> and only argument to bpf program.
>> Future refactoring of netif_rx would need to guarantee
>> that trace_netif_rx_entry(skb) is called. that's it.
>> imo such tracepoints are much easier to deal with during
>> code changes.
>
> But what can you access from that skb that is guaranteed to be there?
> If you say anything, then there's no reason it can't be added to the
> printk as well.

programs can access any field via bpf_fetch*() helpers which
make them kernel layout dependent or via user-ized sk_buff
with few fields which is portable.
In both cases kernel/user abi is only 'skb' pointer.
whether it's debugging program that needs full access
via fetch* helpers or portable program that uses stable api
it's up to program author.
Just like kprobes, it's clear, that if program is using
fetch* helpers it's doing it without any abi guarantees.
'perf probe' and 'bpf with fetch* helpers are the same.
perf probe creates wrappers on top of probe_kernel_read and
bpf_fetch* helpers are wrappers on top of probe_kernel_read.
Complains that 'my kprobe with flags=%cx mode=+4($stack)
stopped working in new kernel' are equivalent to complains
that program with bpf_fetch* stopped working.

Whereas if program is using user-ized structs it will work
across kernel versions, though it will be able to see
only very limited slice of in-kernel data.

>> May be some of the existing tracepoints like this one that
>> takes one argument can be marked 'bpf-ready', so that
>> programs can attach to them only.
>
> I really hate the idea of adding tracepoints that ftrace can't use. It
> basically kills the entire busy box usage scenario, as boards that have
> extremely limited userspace still make full use of ftrace via the
> existing tracepoints.

agree. I think your trace_marker with few args is a good
middle ground.

> I still don't see the argument that adding data via the bpf functions
> is any different than adding those same items to fields in an event.
> Once you add a bpf function, then you must maintain those fields.
>
> Look, you can always add more to a TP_printk(), as that is standard
> with all text file kernel parsing. Like stat in /proc. Fields can not
> be removed, but more can always be appended to the end.
>
> Any tool that parses trace_pipe is broken if it can't handle extended
> fields. The api can be extended, and for text files, that is by
> appending to them.

I agree that any text parsing script should be able to cope
with additional args without problems. I think it's a fear of
<1% breakage is causing maintainers to avoid any changes
to tracepoints even when they just add few args to the end
of TP_printk.
When tracepoints stop printing and the only thing they see
is single pointer to a well known struct like sk_buff,
this fear of tracepoints should fade.
programs are not part of the kernel, so whatever they do
and print is not our headache. We only make sure that
interface between kernel and programs is stable.
In other words kernel ABI is what kernel exposes to
user space and to bpf programs. Though programs
are run inside the kernel what they do it outside of
kernel abi. So when program prints fields is not our
problem, whereas when tracepoint prints fields it's
kernel abi.

ps I'll be traveling for the next few weeks, so
apologize in advance for slow response.
