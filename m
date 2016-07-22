From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v4 1/2] bpf: Add bpf_probe_write BPF helper to be called
 in tracers (kprobes)
Date: Fri, 22 Jul 2016 08:59:55 -0700
Message-ID: <20160722155953.GA7543@ast-mbp.thefacebook.com>
References: <20160722010915.GA22992@ircssh.c.rugged-nimbus-611.internal>
 <20160722021454.GA135@ast-mbp.thefacebook.com>
 <5791ED30.3000409@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sargun Dhillon <sargun@sargun.me>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5791ED30.3000409@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 22, 2016 at 11:53:52AM +0200, Daniel Borkmann wrote:
> On 07/22/2016 04:14 AM, Alexei Starovoitov wrote:
> >On Thu, Jul 21, 2016 at 06:09:17PM -0700, Sargun Dhillon wrote:
> >>This allows user memory to be written to during the course of a kprobe.
> >>It shouldn't be used to implement any kind of security mechanism
> >>because of TOC-TOU attacks, but rather to debug, divert, and
> >>manipulate execution of semi-cooperative processes.
> >>
> >>Although it uses probe_kernel_write, we limit the address space
> >>the probe can write into by checking the space with access_ok.
> >>This is so the call doesn't sleep.
> >>
> >>Given this feature is experimental, and has the risk of crashing
> >>the system, we print a warning on invocation.
> >>
> >>It was tested with the tracex7 program on x86-64.
> >>
> >>Signed-off-by: Sargun Dhillon <sargun@sargun.me>
> >>Cc: Alexei Starovoitov <ast@kernel.org>
> >>Cc: Daniel Borkmann <daniel@iogearbox.net>
> >>---
> >>  include/uapi/linux/bpf.h  | 12 ++++++++++++
> >>  kernel/bpf/verifier.c     |  9 +++++++++
> >>  kernel/trace/bpf_trace.c  | 37 +++++++++++++++++++++++++++++++++++++
> >>  samples/bpf/bpf_helpers.h |  2 ++
> >>  4 files changed, 60 insertions(+)
> >>
> >>diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> >>index 2b7076f..4536282 100644
> >>--- a/include/uapi/linux/bpf.h
> >>+++ b/include/uapi/linux/bpf.h
> >>@@ -365,6 +365,18 @@ enum bpf_func_id {
> >>  	 */
> >>  	BPF_FUNC_get_current_task,
> >>
> >>+	/**
> >>+	 * bpf_probe_write(void *dst, void *src, int len)
> >>+	 * safely attempt to write to a location
> >>+	 * @dst: destination address in userspace
> >>+	 * @src: source address on stack
> >>+	 * @len: number of bytes to copy
> >>+	 * Return:
> >>+	 *   Returns number of bytes that could not be copied.
> >>+	 *   On success, this will be zero
> >
> >that is odd comment.
> >there are only three possible return values 0, -EFAULT, -EPERM
> 
> Agree.
> 
> >>+	 */
> >>+	BPF_FUNC_probe_write,
> >>+
> >>  	__BPF_FUNC_MAX_ID,
> >>  };
> >>
> >>diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> >>index f72f23b..6785008 100644
> >>--- a/kernel/bpf/verifier.c
> >>+++ b/kernel/bpf/verifier.c
> >>@@ -1154,6 +1154,15 @@ static int check_call(struct verifier_env *env, int func_id)
> >>  		return -EINVAL;
> >>  	}
> >>
> >>+	if (func_id == BPF_FUNC_probe_write) {
> >>+		pr_warn_once("************************************************\n");
> >>+		pr_warn_once("* bpf_probe_write: Experimental Feature in use *\n");
> >>+		pr_warn_once("* bpf_probe_write: Feature may corrupt memory  *\n");
> >>+		pr_warn_once("************************************************\n");
> >>+		pr_notice_ratelimited("bpf_probe_write in use by: %.16s-%d",
> >>+				      current->comm, task_pid_nr(current));
> >>+	}
> >
> >I think single line pr_notice_ratelimited() with 'feature may corrupt user memory'
> >will be enough.
> 
> Agree.
> 
> >Also please move this to tracing specific part into bpf_trace.c
> >similar to bpf_get_trace_printk_proto() instead of verifier.c
> 
> Yes, sorry for not being too clear about it, this spot will then be
> called by the verifier to fetch it for every function call. Meaning that
> this could get printed multiple times for loading a single program, but
> I think it's okay. If single line, I'd make that pr_warn_ratelimited(),
> and probably something like ...

yes, but inside check_call() it may be printed even more times, since the same
call site can be verified multiple times due to different reg types.

>  "note: %s[%d] is installing a program with bpf_probe_write helper that may corrupt user memory!",
>  current->comm, task_pid_nr(current)

sounds good to me.

> 
> You can make that 'current->flags & (PF_KTHREAD | PF_EXITING)' and
> we don't need the extra task var either.

+1

> >>+	if (unlikely(segment_eq(get_fs(), KERNEL_DS)))
> >>+		return -EPERM;
> >>+	if (!access_ok(VERIFY_WRITE, unsafe_ptr, size))
> >>+		return -EPERM;
> >>+
> >>+	return probe_kernel_write(unsafe_ptr, src, size);
> >>+}
> >>+
> >>+static const struct bpf_func_proto bpf_probe_write_proto = {
> >>+	.func		= bpf_probe_write,
> >>+	.gpl_only	= true,
> >>+	.ret_type	= RET_INTEGER,
> >>+	.arg1_type	= ARG_ANYTHING,
> >>+	.arg2_type	= ARG_PTR_TO_STACK,
> >>+	.arg3_type	= ARG_CONST_STACK_SIZE,
> >
> >I have 2nd thoughts on naming.
> >I think 'consistency' with probe_read is actually hurting here.
> >People derive semantic of the helper mainly from the name.
> >If we call it bpf_probe_read, it would mean that it's generic
> >writing function, whereas bpf_copy_to_user has clear meaning
> >that it's writing to user memory only.
> >In other words bpf_probe_read and bpf_copy_to_user _are_ different
> >functions with purpose that is easily seen in the name,
> >whereas bpf_probe_read and bpf_probe_write look like a pair,
> >but they're not. probe_read can read kernel and user memory,
> >whereas probe_write only user.
> 
> Okay, but still I think that bpf_copy_to_user is a bit of a weird name
> for that helper, I associate copy_to_user mostly with data buffers or
> structures passed around with syscalls, but not necessarily with something
> else, meaning it's not quite obvious to me deriving this from the name
> to what this helper can achieve.

vhost is copying vring descriptors to user space with it,
In that path there are no syscalls in sight ;)

> How about "bpf_probe_write_user"? It still keeps basic semantics of
> bpf_probe_read, but for the writing part and "user" makes it pretty
> clear that it's not for kernel memory, plus people familiar with
> bpf_probe_read already will make sense on what bpf_probe_write_user
> is about much faster.

I like it. Let's do bpf_probe_write_user then.
