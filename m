From: Sargun Dhillon <sargun@sargun.me>
Subject: Re: [PATCH v4 1/2] bpf: Add bpf_probe_write BPF helper to be called
 in tracers (kprobes)
Date: Fri, 22 Jul 2016 17:05:27 -0700
Message-ID: <20160723000526.GA11650@ircssh.c.rugged-nimbus-611.internal>
References: <20160722010915.GA22992@ircssh.c.rugged-nimbus-611.internal>
 <20160722021454.GA135@ast-mbp.thefacebook.com>
 <5791ED30.3000409@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
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
> 
>  "note: %s[%d] is installing a program with bpf_probe_write helper that may corrupt user memory!",
>  current->comm, task_pid_nr(current)
> 
> >>+static u64 bpf_probe_write(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
> >>+{
> >>+	void *unsafe_ptr = (void *) (long) r1;
> >>+	void *src = (void *) (long) r2;
> >>+	int size = (int) r3;
> >>+	struct task_struct *task = current;
> >>+
> >>+	/*
> >
> >bpf_trace.c follows non-net comment style, so it's good here.
> >just distracting vs the rest of net style.
> >
> >>+	 * Ensure we're in a user context which it is safe for the helper
> >>+	 * to run. This helper has no business in a kthread
> >>+	 *
> >>+	 * access_ok should prevent writing to non-user memory, but on
> >>+	 * some architectures (nommu, etc...) access_ok isn't enough
> >>+	 * So we check the current segment
> >>+	 */
> >>+
> >>+	if (unlikely(in_interrupt() || (task->flags & PF_KTHREAD)))
> >>+		return -EPERM;
> >
> >Should we also add a check for !PF_EXITING ?
> >Like signals are not delivered to such tasks and I'm not sure
> >what would be the state of mm of it.
> 
> I agree, good point.
> 
> You can make that 'current->flags & (PF_KTHREAD | PF_EXITING)' and
> we don't need the extra task var either.
> 
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
> 
> How about "bpf_probe_write_user"? It still keeps basic semantics of
> bpf_probe_read, but for the writing part and "user" makes it pretty
> clear that it's not for kernel memory, plus people familiar with
> bpf_probe_read already will make sense on what bpf_probe_write_user
> is about much faster.
> 
> Thanks,
> Daniel

Changes: 
-Renamed bpf_probe_write -> bpf_probe_write_user 
-Changed mechanism by  which usage information and warnings get presented
-Added some comments about why we took this approach to the commit message
-Check for PF_EXITING
-Formating / comments

I did some more testing. And yeah, I was able to crash lots of user programs
but I was never able to get the kernel to panic, or in an obviously 
broken state. 

The probe does fail when you're writing to creative locations (mmap'd to
files for example), but I don't think we can prevent that and I don't think
that is our target audience. 

>From be94a71a97ad39962c5ff0849d3a75edf1159fff Mon Sep 17 00:00:00 2001
From: Sargun Dhillon <sargun@sargun.me>
Date: Mon, 18 Jul 2016 19:38:58 -0700
Subject: [PATCH net-next v4 1/2] bpf: Add bpf_probe_write_user BPF helper to
 be called in tracers
To: linux-kernel@vger.kernel.org,
    netdev@vger.kernel.org
Cc: alexei.starovoitov@gmail.com,
    daniel@iogearbox.net

This allows user memory to be written to during the course of a kprobe.
It shouldn't be used to implement any kind of security mechanism
because of TOC-TOU attacks, but rather to debug, divert, and
manipulate execution of semi-cooperative processes.

Although it uses probe_kernel_write, we limit the address space
the probe can write into by checking the space with access_ok.
This is so the call doesn't sleep. In addition we ensure the threads's
current fs / segment is USER_DS and the thread isn't exiting nor
a kernel thread.

Given this feature is experimental, and has the risk of crashing the
system, we print a warning on first invocation, and the process name
on subsequent invocations.

It was tested with the tracex7 program on x86-64.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
---
 include/uapi/linux/bpf.h  | 10 +++++++++
 kernel/trace/bpf_trace.c  | 52 +++++++++++++++++++++++++++++++++++++++++++++++
 samples/bpf/bpf_helpers.h |  2 ++
 3 files changed, 64 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 2b7076f..da218fe 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -365,6 +365,16 @@ enum bpf_func_id {
 	 */
 	BPF_FUNC_get_current_task,
 
+	/**
+	 * bpf_probe_write_user(void *dst, void *src, int len)
+	 * safely attempt to write to a location
+	 * @dst: destination address in userspace
+	 * @src: source address on stack
+	 * @len: number of bytes to copy
+	 * Return: 0 on success or negative error
+	 */
+	BPF_FUNC_probe_write_user,
+
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index a12bbd3..f9c13e0 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -81,6 +81,56 @@ static const struct bpf_func_proto bpf_probe_read_proto = {
 	.arg3_type	= ARG_ANYTHING,
 };
 
+static u64 bpf_probe_write_user(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	void *unsafe_ptr = (void *) (long) r1;
+	void *src = (void *) (long) r2;
+	int size = (int) r3;
+
+	/*
+	 * Ensure we're in a user context which it is safe for the helper
+	 * to run. This helper has no business in a kthread.
+	 *
+	 * access_ok should prevent writing to non-user memory, but in some
+	 * situations (nommu, temporary switch, etc...) access_ok does not
+	 * provide enough validation.
+	 *
+	 * In order to avoid this we check the current segment to verify that
+	 * it is USER_DS. This avoid odd architectures and user threads that
+	 * temporarily switch to KERNEL_DS.
+	 */
+
+	if (unlikely(in_interrupt() ||
+		     current->flags & (PF_KTHREAD | PF_EXITING)))
+		return -EPERM;
+	if (unlikely(segment_eq(get_fs(), KERNEL_DS)))
+		return -EPERM;
+	if (!access_ok(VERIFY_WRITE, unsafe_ptr, size))
+		return -EPERM;
+
+	return probe_kernel_write(unsafe_ptr, src, size);
+}
+
+static const struct bpf_func_proto bpf_probe_write_user_proto = {
+	.func		= bpf_probe_write_user,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_ANYTHING,
+	.arg2_type	= ARG_PTR_TO_STACK,
+	.arg3_type	= ARG_CONST_STACK_SIZE,
+};
+
+static const struct bpf_func_proto *bpf_get_probe_write_proto(void) {
+	pr_warn_once("*****************************************************\n");
+	pr_warn_once("* bpf_probe_write_user: Experimental Feature in use *\n");
+	pr_warn_once("* bpf_probe_write_user: Feature may corrupt memory  *\n");
+	pr_warn_once("*****************************************************\n");
+	pr_notice_ratelimited("bpf_probe_write_user: %s[%d] installing program with helper: it may corrupt user memory!",
+	current->comm, task_pid_nr(current));
+
+	return &bpf_probe_write_user_proto;
+}
+
 /*
  * limited trace_printk()
  * only %d %u %x %ld %lu %lx %lld %llu %llx %p %s conversion specifiers allowed
@@ -362,6 +412,8 @@ static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
 		return &bpf_get_smp_processor_id_proto;
 	case BPF_FUNC_perf_event_read:
 		return &bpf_perf_event_read_proto;
+	case BPF_FUNC_probe_write_user:
+		return bpf_get_probe_write_proto();
 	default:
 		return NULL;
 	}
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 84e3fd9..217c8d5 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -41,6 +41,8 @@ static int (*bpf_perf_event_output)(void *ctx, void *map, int index, void *data,
 	(void *) BPF_FUNC_perf_event_output;
 static int (*bpf_get_stackid)(void *ctx, void *map, int flags) =
 	(void *) BPF_FUNC_get_stackid;
+static int (*bpf_probe_write_user)(void *dst, void *src, int size) =
+	(void *) BPF_FUNC_probe_write_user;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
-- 
2.7.4
