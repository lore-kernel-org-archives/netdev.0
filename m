From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC][PATCH 00/10] Add trace event support to eBPF
Date: Sun, 14 Feb 2016 01:02:41 +0100
Message-ID: <20160214000236.GA16236@ast-mbp.kubiwireless.com>
References: <cover.1455291671.git.tom.zanussi@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rostedt@goodmis.org, masami.hiramatsu.pt@hitachi.com,
	namhyung@kernel.org, peterz@infradead.org,
	linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Tom Zanussi <tom.zanussi@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1455291671.git.tom.zanussi@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 12, 2016 at 10:11:18AM -0600, Tom Zanussi wrote:
> Hi,
> 
> As promised in previous threads, this patchset shares some common
> functionality with the hist triggers code and enables trace events to
> be accessed from eBPF programs.

great that you've started working on BPF!

> It needs to be applied on top of current tracing/for-next with the
> hist triggers v13 patches applied:
> 
>   https://lkml.org/lkml/2015/12/10/640
> 
> Any input welcome, especially things that could be done better wrt
> eBPF, since I'm not as familiar with that code...

this dependency looks odd. As I was saying a year ago I don't think
this hist triggers belong in the kernel. BPF already can do
way more complex aggregation and histograms.
Take a look at all the tools written on top of it:
https://github.com/iovisor/bcc/tree/master/tools
I don't buy into reasoning that hist triggers are needed to do
performance analysis in the busybox. If not in busybox,
just use perf+bpf or bcc.

that aside we do need to be able to attach bpf to tracepoints.
The key goal of bpf+tracepoints is to be faster than bpf+kprobe.
kprobes were good enough for almost all use cases so far except
when we started processing millions of events per second via
kprobe+bpf. At that point even optimized kprobe adds too much
overhead.

Patch 9:
+       char common_pid_field_name1[] = "common_pid";
+       key.pid = bpf_trace_event_field_read(ctx, common_pid_field_name1);

this is already achieved by bpf_get_current_pid_tgid()
and it is several times faster.

+       char count_field_name1[] = "count";
+       count = bpf_trace_event_field_read(ctx, count_field_name1);

Already possible by simple PT_REGS_PARM3(ctx) which is faster as well.
And if you're using bcc you can write
sys_read(struct pt_regs *ctx, int fd, char *buf, size_t count)
{ .. use 'count' ...}
and bcc will automatically convert 'count' to ctx->dx.
The latest perf can do this as well with slightly different syntax.

Patch 10:
+       char len_field[] = "len";
+       len = bpf_trace_event_field_read(ctx, len_field);
+
+       char name_field[] = "name";
+       bpf_trace_event_field_read_string(ctx, name_field, name, sizeof(name));
+
+       char common_pid_field[] = "common_pid";
+       common_pid = bpf_trace_event_field_read(ctx, common_pid_field);

all of the above can be done already and it's even demoed
in samples/bpf/tracex1_kern.c

The main problem with this patch set is in patch 5:
+       field_name = (char *) (long) r2;
+       field = trace_find_event_field(ctx->call, field_name);

This is very slow, since it's doing for_each_field(){strcmp()}
That's the reason that simple ctx->register or bpf_probe_read()
are much faster.

There are few other issues with this set:
Patch 2:
+       if (off < 0 || off >= TRACE_EVENT_CTX_HDR_SIZE + BUF_MAX_DATA_SIZE)
+               return false;
that will allow bpf program to read a page worth of data from some
stack pointer, since in patch 6:
+               struct trace_event_context ctx = { call, entry };
+               if (!trace_call_bpf(prog, &ctx))
the kernel probably won't crash, but it shouldn't be allowed.

Patch 6 is odd.
We already have prog_type_kprobe to work with kprobes.
Having prog_type_trace_event there is unnecessary.

The syscall part of Patch 7 is probably unnecessary too.
When we benchmarked bpf+syscall it turned out that adding
kprobe to sys_xx is actually faster than using syscall_enter() logic.
May be things have changed. Need to re-measure.

The tracepoint part of Patch 7 makes sense, but it has too much
overhead to be competitive with kprobe.
perf_trace_buf_prepare() does local_save_flags() which is quite
expensive instruction when tracepoint is called million times a second.
perf_fetch_caller_regs() is heavy too, since it zeros pt_regs which
will be unused the bpf program.

I'm also working on bpf+tracepoint.
My plan was to add a variant of perf_trace_buf_prepare() that
doesn't populate 'struct trace_entry' and just returns a pointer.
Then perf_trace_##call() does tstruct and {assign;} into that
'entry' pointer and then call bpf prog with
'struct ctx {regs, entry_ptr, __data_size}'
Then bpf prog will call a helper to copy the data into its stack
and will access it there as normal.
It's going to be significantly faster than for_each_field+strcmp
approach and little bit faster than kprobe, but I'm not happy
with that speed yet.
I'm still thinking on how to avoid 2nd copy and extra helper.
The program should be able to access the entry_ptr directly,
but some verifier magic needs to be done. so it's still wip.

btw, ast@plumgrid is no longer functional and
please cc netdev every time kernel/bpf/ is touched.
