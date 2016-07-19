From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v3 1/2] bpf: Add bpf_copy_to_user BPF helper to
 be called in tracers (kprobes)
Date: Tue, 19 Jul 2016 09:34:45 -0700
Message-ID: <20160719163443.GA57855@ast-mbp.thefacebook.com>
References: <20160719093242.GA23753@ircssh.c.rugged-nimbus-611.internal>
 <578E0C61.6070705@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sargun Dhillon <sargun@sargun.me>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33279 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753160AbcGSQet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 12:34:49 -0400
Content-Disposition: inline
In-Reply-To: <578E0C61.6070705@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 19, 2016 at 01:17:53PM +0200, Daniel Borkmann wrote:
> >+		return -EINVAL;
> >+
> >+	/* Is this a user address, or a kernel address? */
> >+	if (!access_ok(VERIFY_WRITE, to, size))
> >+		return -EINVAL;
> >+
> >+	return probe_kernel_write(to, from, size);
> 
> I'm still worried that this can lead to all kind of hard to find
> bugs or races for user processes, if you make this writable to entire
> user address space (which is the only thing that access_ok() checks
> for). What if the BPF program has bugs and writes to wrong addresses
> for example, introducing bugs in some other, non-intended processes
> elsewhere? Can this be limited to syscalls only? And if so, to the
> passed memory only?

my understanding that above code will write only to memory of current process,
so impact is contained and in that sense buggy kprobe program is no different
from buggy seccomp prorgram.
Limiting this to syscalls will make it too limited.
I'm in favor of this change, because it allows us to experiment
with restartable sequences and lock-free algorithms that need ultrafast
access to cpuid without burdening the kernel with stable abi.

> Have you played around with ptrace() to check whether you could
> achieve similar functionality (was thinking about things like [1],
> PTRACE_PEEK{TEXT,DATA} / PTRACE_POKE{TEXT,DATA}). If not, why can't
> this be limited to a similar functionality for only the current task.
> ptrace() utilizes helpers like access_process_vm(), maybe this can
> similarly be adapted here, too (under the circumstances that sleeping
> is not allowed)?

If we hack access_process_vm I think at the end it will look like
probe_kernel_write. Walking mm requires semaphore, so we would only
be able to do it in task_work and there we can do normal copy_to_user
just as well, but it will complicate the programs quite a bit, since
writes will be asynchronous and batched.
Looks like with access_ok+probe_write we can achieve the same
with a lot less code.
As far as races between user and bpf program, yeah, if process
is multithreaded, the other threads may access the same mem that
bpf is writing to, but that's no different from reading.
For tracing we walk complex datastructures and pointers. They
can be changed by user space on the fly and bpf will see garbage.
Like we have uprobe+bpf that walks clang c++ internal datastructures
to figure out how long it takes clang to process .h headers.
There is a lot of fragility in the bpf script, yet it's pretty
useful to quickly analyze compile times.
I see bpf_copy_to_user to be hugely valuable too, not as a stable
interface, but rather as a tool to quickly debug and experiment.
