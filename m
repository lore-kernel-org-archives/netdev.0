From: Tom Zanussi <tom.zanussi@linux.intel.com>
Subject: Re: [RFC][PATCH 00/10] Add trace event support to eBPF
Date: Thu, 18 Feb 2016 15:27:18 -0600
Message-ID: <1455830838.14359.58.camel@tzanussi-mobl.amr.corp.intel.com>
References: <cover.1455291671.git.tom.zanussi@linux.intel.com>
	 <20160214000236.GA16236@ast-mbp.kubiwireless.com>
	 <1455662127.2641.157.camel@tzanussi-mobl.amr.corp.intel.com>
	 <20160217045103.GA47275@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, masami.hiramatsu.pt@hitachi.com,
	namhyung@kernel.org, peterz@infradead.org,
	linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:54647 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757143AbcBRV12 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 16:27:28 -0500
In-Reply-To: <20160217045103.GA47275@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-02-16 at 20:51 -0800, Alexei Starovoitov wrote:
> On Tue, Feb 16, 2016 at 04:35:27PM -0600, Tom Zanussi wrote:
> > On Sun, 2016-02-14 at 01:02 +0100, Alexei Starovoitov wrote:
> > > On Fri, Feb 12, 2016 at 10:11:18AM -0600, Tom Zanussi wrote:
> 
> > > this hist triggers belong in the kernel. BPF already can do
> > > way more complex aggregation and histograms.
> > 
> > Way more?  I still can't accomplish with eBPF some of the most basic and
> > helpful use cases that I can with hist triggers, such as using
> > stacktraces as hash keys.  And the locking in the eBPF hashmap
> > implementation prevents anything like the function_hist [1] tracer from
> > being implemented on top of it:
> 
> Both statements are not true.

Erm, not exactly...

> In the link from previous email take a look at funccount_example.txt:
> # ./funccount 'vfs_*'
> Tracing... Ctrl-C to end.
> ^C
> ADDR             FUNC                          COUNT
> ffffffff811efe81 vfs_create                        1
> ffffffff811f24a1 vfs_rename                        1
> ffffffff81215191 vfs_fsync_range                   2
> ffffffff81231df1 vfs_lock_file                    30
> ffffffff811e8dd1 vfs_fstatat                     152
> ffffffff811e8d71 vfs_fstat                       154
> ffffffff811e4381 vfs_write                       166
> ffffffff811e8c71 vfs_getattr_nosec               262
> ffffffff811e8d41 vfs_getattr                     262
> ffffffff811e3221 vfs_open                        264
> ffffffff811e4251 vfs_read                        470
> Detaching...
> 

When I tried to use it to trace all functions:

  # ./funccount.py '*'

I got about 5 minutes worth of these kinds of error messages, which I
couldn't break out of:

write of "p:kprobes/p_rootfs_mount rootfs_mount" into kprobe_events failed: Device or resource busy
open(/sys/kernel/debug/tracing/events/kprobes/p_legacy_pic_int_noop/id): Too many open files
open(/sys/kernel/debug/tracing/events/kprobes/p_legacy_pic_irq_pending_noop/id): Too many open files
open(/sys/kernel/debug/tracing/events/kprobes/p_legacy_pic_probe/id): Too many open files
open(/sys/kernel/debug/tracing/events/kprobes/p_unmask_8259A_irq/id): Too many open files
open(/sys/kernel/debug/tracing/events/kprobes/p_enable_8259A_irq/id): Too many open files
open(/sys/kernel/debug/tracing/events/kprobes/p_mask_8259A_irq/id): Too many open files
open(/sys/kernel/debug/tracing/events/kprobes/p_disable_8259A_irq/id): Too many open files
open(/sys/kernel/debug/tracing/events/kprobes/p_i8259A_irq_pending/id): Too many open files
...

Which is probably a good thing, since that's a relatively common thing
for someone to try, whereas this subset probably isn't:

  # ./funccount.py '*spin*'

Which on my machine resulted in a hard lockup on all CPUs.  I'm not set
up to grab serial output on that machine, but here's a screenshot of
most of the stacktrace, all I could get:

  http://picpaste.com/bcc-spinstar-hardlock-fobQbcuG.JPG

There's nothing special about that machine and it's running a stock
4.4.0 kernel, so it should be pretty easy to reproduce on anything with
just a BPF-enabled config.  If not, let me know and I'll send more
specific info.

> And this is done without adding new code to the kernel.
> 
> Another example is offwaketime that uses two stack traces as
> part of single key.
> 

Which has the below code in the script itself implementing a stack
walker:

static u64 get_frame(u64 *bp) {
    if (*bp) {
        // The following stack walker is x86_64 specific
        u64 ret = 0;
        if (bpf_probe_read(&ret, sizeof(ret), (void *)(*bp+8)))
            return 0;
        if (bpf_probe_read(bp, sizeof(*bp), (void *)*bp))
            *bp = 0;
        if (ret < __START_KERNEL_map)
            return 0;
        return ret;
    }
    return 0;
}

int waker(struct pt_regs *ctx, struct task_struct *p) {
    u32 pid = p->pid;

    if (!(FILTER))
        return 0;

    u64 bp = 0;
    struct wokeby_t woke = {};
    int depth = 0;
    bpf_get_current_comm(&woke.name, sizeof(woke.name));
    bp = ctx->bp;

    // unrolled loop (MAXWDEPTH):
    if (!(woke.ret[depth++] = get_frame(&bp))) goto out;
    if (!(woke.ret[depth++] = get_frame(&bp))) goto out;
    if (!(woke.ret[depth++] = get_frame(&bp))) goto out;
    if (!(woke.ret[depth++] = get_frame(&bp))) goto out;
    if (!(woke.ret[depth++] = get_frame(&bp))) goto out;
    if (!(woke.ret[depth++] = get_frame(&bp))) goto out;
    if (!(woke.ret[depth++] = get_frame(&bp))) goto out;
    if (!(woke.ret[depth++] = get_frame(&bp))) goto out;
    if (!(woke.ret[depth++] = get_frame(&bp))) goto out;
    woke.ret[depth] = get_frame(&bp);

I think one call to this pretty much cancels out any performance gains
you might have made by fastidiously avoiding trace events.

So technically users can use stacktraces as hash keys, but they're
expected to use the bpf_probe_read() kernel primitives to write a stack
walker themselves.  Not exactly what I was hoping for..

> > > Take a look at all the tools written on top of it:
> > > https://github.com/iovisor/bcc/tree/master/tools
> > 
> > That's great, but it's all out-of-tree.  Supporting out-of-tree users
> > has never been justification for merging in-kernel code (or for blocking
> > it from being merged). 
> 
> huh? perf is the only in-tree user space project.
> All others tools and libraries are out-of-tree and that makes sense.
> 

What about all the other things under tools/?

> Actually would be great to merge bcc with perf eventually, but choice
> of C++ isn't going to make it easy. The only real difference
> between perf+bpf and bcc is that bcc integrates clang/llvm
> as a library whereas perf+bpf deals with elf files and standalone compiler.
> There are pros and cons for both and it's great that both are actively
> growing and gaining user traction.
> 

Why worry about merging bcc with perf?  Why not a tools/bcc?

> > I have systems with tiny amounts of memory and storage that have zero
> > chance of ever having a compiler or Python running on them.  It's
> 
> if your system is so short on memory, then you don't want to bloat
> the kernel with histtriggers especially since they're not
> going to be used 24/7 due to the overhead.
> 
> > I haven't measured the overhead of the cost of accessing data from the
> > trace buffers, but I do know that the hist triggers have no problem
> > logging millions of events per second.
> > 
> > In the past I have measured the basic hist triggers mechanism and found
> > it to be somewhat faster than the ftrace function tracer itself:
> > 
> >     over a kernel compile:
> > 
> >     no tracing:
> > 
> >       real   110m47.817s
> >       user    99m34.144s
> >       sys      7m19.928s
> ... 
> >     function_hist tracer enabled:
> >       real   128m44.682s
> >       user   100m29.080s
> >       sys     26m52.880s
> 
> 78% of cpu time is in user space. Not a great test of kernel
> datapath, but 'sys 7m19.928s vs 26m52.880s' actually means that
> the kernel part is 3 times slower. That is your enormous overhead.
> 

Like I said, I didn't drill down on any measurements to see which part
was due to hist triggers code vs the ftrace calls - my point was only to
show that the hist triggers are actually faster than the function
tracer.

I guess that anything that does useful work on every single function
call is going to add some measurable amount of overhead.  I'm still
interested in seeing what that would be for eBPF.

> 2 hours to compile the kernel. ouch. that must be very low end device.
> For comparison full kernel build on my box:
> real    2m49.693s
> user    66m44.204s
> sys     5m29.257s
> 
> > One point I would make about this though is that while it might be
> > slower to access this particular field that way, the user who's just
> > trying to get something done doesn't need to know about
> > bpf_get_current_pid_tgid() and can just look at the available fields in
> > the trace event format file and use them directly - trading off
> > efficiency for ease-of-use.
> 
> sorry, but nack for such 'ease-of-use'.
> We're not going to sacrifice performance even if there are few raw edges
> in the user space. User tools can be improved, new compilers and
> front-ends written, but kernel API will stay fixed and must be fast
> from the start.
> 

OK, so it sounds like eBPF will never support access to trace events.
Good to know, that officially makes our work completely orthogonal.

> > surrounding that even in the comments.  I guess I'd have to spend a few
> > hours reading the BPF code and the verifier even, to understand that.
> 
> not sure what is your goal. Runtime lookup via field name is not acceptable
> whether it's cached or not. There is no place for strcmp in the critical path.
> 

Exactly - that's why I was asking about a 'begin probe', in order to do
the lookup once, in an non-critical path.

> > > please cc netdev every time kernel/bpf/ is touched.
> > > 
> > 
> > Why netdev?  This has nothing to do with networking.
> 
> because that's what MAINTAINERS file says.
> kernel/bpf/* is used for both tracing and networking and all significant
> changes should be going through net-next to avoid conflicts and
> to make sure that active developers can do a thorough review.
> 
