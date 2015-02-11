From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH v3 linux-trace 1/8] tracing: attach eBPF programs to
 tracepoints and syscalls
Date: Tue, 10 Feb 2015 23:31:59 -0500
Message-ID: <20150210233159.748f44ad@grimm.local.home>
References: <CAMEtUuy+B9aXP-8m7tA6aNxnS4SKRhMpfGEdWMcbxbj7ggOATw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
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
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuy+B9aXP-8m7tA6aNxnS4SKRhMpfGEdWMcbxbj7ggOATw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Feb 2015 19:04:55 -0800
Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:


> > You mean to be completely invisible to ftrace? And the debugfs/tracefs
> > directory?
> 
> I mean it will be seen in tracefs to get 'id', but without enable/format/filter

In other words, invisible to ftrace. I'm not sure I'll be on board to
work with that.


> > Again, this would mean they become invisible to ftrace, and even
> > ftrace_dump_on_oops.
> 
> yes, since these new tracepoints have no meat inside them.
> They're placeholders sitting idle and waiting for bpf to do
> something useful with them.

Hmm, I have a patch somewhere (never posted it), that add
TRACE_MARKER(), which basically would just print that it was hit. But
no data was passed to it. Something like that I would be more inclined
to take. Then the question is, what can bpf access there? Could just be
a place holder to add a "fast kprobe". This way, it can show up in
trace events with enable and and all that, it just wont have any data
to print out besides the normal pid, flags, etc.

But because it will inject a nop, that could be converted to a jump, it
will give you the power of kprobes but with the speed of a tracepoint.

> 
> > I'm not fully understanding what is to be exported by this new ABI. If
> > the fields available, will always be available, then why can't the
> > appear in a TP_printk()?
> 
> say, we define trace_netif_rx_entry() as this new tracepoint_bpf.
> It will have only one argument 'skb'.
> bpf program will read and print skb fields the way it likes
> for particular tracing scenario.
> So instead of making
> TP_printk("dev=%s napi_id=%#x queue_mapping=%u skbaddr=%p
> vlan_tagged=%d vlan_proto=0x%04x vlan_tci=0x%04x protocol=0x%04x
> ip_summed=%d hash=0x%08x l4_hash=%d len=%u data_len=%u truesize=%u
> mac_header_valid=%d mac_header=%d nr_frags=%d gso_size=%d
> gso_type=%#x",...
> the abi exposed via trace_pipe (as it is today),
> the new tracepoint_bpf abi is presence of 'skb' pointer as one
> and only argument to bpf program.
> Future refactoring of netif_rx would need to guarantee
> that trace_netif_rx_entry(skb) is called. that's it.
> imo such tracepoints are much easier to deal with during
> code changes.

But what can you access from that skb that is guaranteed to be there?
If you say anything, then there's no reason it can't be added to the
printk as well.

> 
> May be some of the existing tracepoints like this one that
> takes one argument can be marked 'bpf-ready', so that
> programs can attach to them only.

I really hate the idea of adding tracepoints that ftrace can't use. It
basically kills the entire busy box usage scenario, as boards that have
extremely limited userspace still make full use of ftrace via the
existing tracepoints.

I still don't see the argument that adding data via the bpf functions
is any different than adding those same items to fields in an event.
Once you add a bpf function, then you must maintain those fields.

Look, you can always add more to a TP_printk(), as that is standard
with all text file kernel parsing. Like stat in /proc. Fields can not
be removed, but more can always be appended to the end.

Any tool that parses trace_pipe is broken if it can't handle extended
fields. The api can be extended, and for text files, that is by
appending to them.

-- Steve
