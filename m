From: Tom Zanussi <tom.zanussi@linux.intel.com>
Subject: Re: [RFC][PATCH 00/10] Add trace event support to eBPF
Date: Tue, 16 Feb 2016 16:35:27 -0600
Message-ID: <1455662127.2641.157.camel@tzanussi-mobl.amr.corp.intel.com>
References: <cover.1455291671.git.tom.zanussi@linux.intel.com>
	 <20160214000236.GA16236@ast-mbp.kubiwireless.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, masami.hiramatsu.pt@hitachi.com,
	namhyung@kernel.org, peterz@infradead.org,
	linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160214000236.GA16236@ast-mbp.kubiwireless.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2016-02-14 at 01:02 +0100, Alexei Starovoitov wrote:
> On Fri, Feb 12, 2016 at 10:11:18AM -0600, Tom Zanussi wrote:
> > Hi,
> > 
> > As promised in previous threads, this patchset shares some common
> > functionality with the hist triggers code and enables trace events to
> > be accessed from eBPF programs.
> 
> great that you've started working on BPF!
> 
> > It needs to be applied on top of current tracing/for-next with the
> > hist triggers v13 patches applied:
> > 
> >   https://lkml.org/lkml/2015/12/10/640
> > 
> > Any input welcome, especially things that could be done better wrt
> > eBPF, since I'm not as familiar with that code...
> 
> this dependency looks odd. As I was saying a year ago I don't think

It's not actually a dependency, just a consequence of trying to share
code for this RFC that happened to already be in hist triggers.  I could
just as well have removed the hunk that deletes that code from hist
triggers, but one of the main points was to show how they could be
shared.

> this hist triggers belong in the kernel. BPF already can do
> way more complex aggregation and histograms.

Way more?  I still can't accomplish with eBPF some of the most basic and
helpful use cases that I can with hist triggers, such as using
stacktraces as hash keys.  And the locking in the eBPF hashmap
implementation prevents anything like the function_hist [1] tracer from
being implemented on top of it:

.
.
.
ip: [ffffffffa0166350] gen7_render_get_cmd_length_mask     hitcount: 18551173520
ip: [ffffffff817589b0] _cond_resched                       hitcount: 19242157574
ip: [ffffffff8175bd60] _raw_spin_lock                      hitcount: 19275222963
ip: [ffffffff81232c60] __fdget                             hitcount: 22865629762
ip: [ffffffff81232c00] __fget_light                        hitcount: 24594932641
ip: [ffffffff8175bed0] _raw_spin_lock_irqsave              hitcount: 26510496751
ip: [ffffffff8175bb30] _raw_spin_unlock_irqrestore         hitcount: 26525916042
ip: [ffffffffa018d6c0] gen6_ring_get_seqno                 hitcount: 95888137753

Totals:
    Hits: 1020596753338
    Entries: 7102
    Dropped: 0

[1]
http://git.yoctoproject.org/cgit/cgit.cgi/linux-yocto-contrib/commit/?h=tzanussi/func-hist-v0&id=fa123181a068574bd9e300416cc947aa7424d808

> Take a look at all the tools written on top of it:
> https://github.com/iovisor/bcc/tree/master/tools

That's great, but it's all out-of-tree.  Supporting out-of-tree users
has never been justification for merging in-kernel code (or for blocking
it from being merged). 

> I don't buy into reasoning that hist triggers are needed to do
> performance analysis in the busybox. If not in busybox,
> just use perf+bpf or bcc.
> 

I have systems with tiny amounts of memory and storage that have zero
chance of ever having a compiler or Python running on them.  It's
indispensable on those systems to have access to all and nothing more
than the ftrace-based tools and trace event files directly.  I even have
systems that don't have a shell at all, but can nonetheless access all
the ftrace and trace event functionality through a different channel.
hist triggers is just another one of those tools, a logical progression
towards allowing users in such a situation (among others) to make more
efficient and concise use of the trace event data.  I don't see what
your problem with that is.

> that aside we do need to be able to attach bpf to tracepoints.
> The key goal of bpf+tracepoints is to be faster than bpf+kprobe.
> kprobes were good enough for almost all use cases so far except
> when we started processing millions of events per second via
> kprobe+bpf. At that point even optimized kprobe adds too much
> overhead.
> 

It sounds from this like you're mainly interested in hooking into the
trace events but not the trace event data, which is fine, but other
tools might find some value in the trace event data, even if it may not
be the most optimal path.

I haven't measured the overhead of the cost of accessing data from the
trace buffers, but I do know that the hist triggers have no problem
logging millions of events per second.

In the past I have measured the basic hist triggers mechanism and found
it to be somewhat faster than the ftrace function tracer itself:

    over a kernel compile:

    no tracing:

      real    110m47.817s
      user    99m34.144s
      sys    7m19.928s

    function tracer enabled:

      real 138m6.854s
      user 100m57.692s
      sys 36m27.724s

    function_graph tracer enabled:

      real    194m38.052s
      user    102m32.192s
      sys    97m47.056s

    function_hist tracer enabled:

      real    128m44.682s
      user    100m29.080s
      sys    26m52.880s

Given the fact that I haven't heard people complaining about the
overhead of even the function_graph tracer, I don't think the overhead
would be a show-stopper in most cases.

> Patch 9:
> +       char common_pid_field_name1[] = "common_pid";
> +       key.pid = bpf_trace_event_field_read(ctx, common_pid_field_name1);
> 
> this is already achieved by bpf_get_current_pid_tgid()
> and it is several times faster.
> 

Right, but the point of the examples was just to show that the mechanism
worked.  I guess I should have named them tracexX_... instead, to make
that clear.

One point I would make about this though is that while it might be
slower to access this particular field that way, the user who's just
trying to get something done doesn't need to know about
bpf_get_current_pid_tgid() and can just look at the available fields in
the trace event format file and use them directly - trading off
efficiency for ease-of-use.

I also wonder about the trace event fields that don't boil down to
simple assignments - do each of them require 'helper' functions be
written in order to access the same data, if you're not interested in
using the trace event data? 

> +       char count_field_name1[] = "count";
> +       count = bpf_trace_event_field_read(ctx, count_field_name1);
> 
> Already possible by simple PT_REGS_PARM3(ctx) which is faster as well.

It may be 'simple' in that it's only 20 chars or so, but that seems to
imply a certain kind of deep knowledge on the part of the user in order
to be able to write even a simple eBPF program.  Maybe some users would
like to just say, 'just get me the count value, I don't really want to
know all about this pt_regs thing'.  BTW, where is PT_REGS_PARM3() and
how to use it documented for a new user, other than via the examples? 

> And if you're using bcc you can write
> sys_read(struct pt_regs *ctx, int fd, char *buf, size_t count)
> { .. use 'count' ...}
> and bcc will automatically convert 'count' to ctx->dx.
> The latest perf can do this as well with slightly different syntax.
> 
> Patch 10:
> +       char len_field[] = "len";
> +       len = bpf_trace_event_field_read(ctx, len_field);
> +
> +       char name_field[] = "name";
> +       bpf_trace_event_field_read_string(ctx, name_field, name, sizeof(name));
> +
> +       char common_pid_field[] = "common_pid";
> +       common_pid = bpf_trace_event_field_read(ctx, common_pid_field);
> 
> all of the above can be done already and it's even demoed
> in samples/bpf/tracex1_kern.c

Right, and again, just an example to show that it works, and in this
case that you're getting the same data from the kprobe and the static
trace event.

> 
> The main problem with this patch set is in patch 5:
> +       field_name = (char *) (long) r2;
> +       field = trace_find_event_field(ctx->call, field_name);
> 
> This is very slow, since it's doing for_each_field(){strcmp()}
> That's the reason that simple ctx->register or bpf_probe_read()
> are much faster.
> 

Yes, this and the next thing were the main reasons for making this an
RFC patch - I actually was hoping for someone to point out the 'right'
way to do this in eBPF.

Obviously there's no reason to do this lookup more than once - it should
be done once and then saved, but I ran into a few questions about that:

 - should I have a helper that returns a pointer to the field, then save
it in a 'global hashmap' with one entry, like I've seen in other eBPF
code, and pass it in whenever accessing the field contents?
 - I tried that but the top half was masked off, why?
 - given that I only want something like the field lookup to happen
once, in eBPF what's the accepted way to do a 'begin probe' i.e. some
code like populating a global field array before the 'main' program
starts?

> There are few other issues with this set:
> Patch 2:
> +       if (off < 0 || off >= TRACE_EVENT_CTX_HDR_SIZE + BUF_MAX_DATA_SIZE)
> +               return false;
> that will allow bpf program to read a page worth of data from some
> stack pointer, since in patch 6:
> +               struct trace_event_context ctx = { call, entry };
> +               if (!trace_call_bpf(prog, &ctx))
> the kernel probably won't crash, but it shouldn't be allowed.
> 

Right, the intent was to allow the eBPF program a somehow access a
pointer to the trace record, and grab the field directly.  Obviously I
don't have a clue about how to make that properly happen in the eBPF
interpreter, and I don't see anything explaining all the voodoo
surrounding that even in the comments.  I guess I'd have to spend a few
hours reading the BPF code and the verifier even, to understand that.
It would be nice if an interface that seems like it would be used by
other people wanting to extend eBPF could provide some hints in the
comments if not be thoroughly explained in the documentation.

> Patch 6 is odd.
> We already have prog_type_kprobe to work with kprobes.
> Having prog_type_trace_event there is unnecessary.
> 

Not if you intend on making use of the trace event data.  Which I think
I've realized that you don't, and therefore this whole patchset is
indeed pointless.

> The syscall part of Patch 7 is probably unnecessary too.
> When we benchmarked bpf+syscall it turned out that adding
> kprobe to sys_xx is actually faster than using syscall_enter() logic.
> May be things have changed. Need to re-measure.
> 
> The tracepoint part of Patch 7 makes sense, but it has too much
> overhead to be competitive with kprobe.
> perf_trace_buf_prepare() does local_save_flags() which is quite
> expensive instruction when tracepoint is called million times a second.
> perf_fetch_caller_regs() is heavy too, since it zeros pt_regs which
> will be unused the bpf program.
> 
> I'm also working on bpf+tracepoint.
> My plan was to add a variant of perf_trace_buf_prepare() that
> doesn't populate 'struct trace_entry' and just returns a pointer.
> Then perf_trace_##call() does tstruct and {assign;} into that
> 'entry' pointer and then call bpf prog with
> 'struct ctx {regs, entry_ptr, __data_size}'

Ah, I think this is what I was missing with the Patch 2 thing.  Well, I
guess I'll find out what was the right way to do it when I see your
patch.

> Then bpf prog will call a helper to copy the data into its stack
> and will access it there as normal.
> It's going to be significantly faster than for_each_field+strcmp
> approach and little bit faster than kprobe, but I'm not happy
> with that speed yet.
> I'm still thinking on how to avoid 2nd copy and extra helper.
> The program should be able to access the entry_ptr directly,
> but some verifier magic needs to be done. so it's still wip.
> 
> btw, ast@plumgrid is no longer functional and
> please cc netdev every time kernel/bpf/ is touched.
> 

Why netdev?  This has nothing to do with networking.
