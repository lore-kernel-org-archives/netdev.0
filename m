From: Sargun Dhillon <sargun@sargun.me>
Subject: Re: [PATCH net-next v3 1/2] bpf: Add bpf_copy_to_user BPF helper to
 be called in tracers (kprobes)
Date: Thu, 21 Jul 2016 03:47:06 -0700
Message-ID: <20160721104705.GA3446@ircssh.c.rugged-nimbus-611.internal>
References: <20160719093242.GA23753@ircssh.c.rugged-nimbus-611.internal>
 <578E0C61.6070705@iogearbox.net>
 <20160719163443.GA57855@ast-mbp.thefacebook.com>
 <578EB597.2080608@iogearbox.net>
 <20160720030200.GA70500@ast-mbp.thefacebook.com>
 <alpine.DEB.2.02.1607200133350.13397@ircssh.c.rugged-nimbus-611.internal>
 <579002A3.3090406@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <579002A3.3090406@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 21, 2016 at 01:00:51AM +0200, Daniel Borkmann wrote:
> On 07/20/2016 11:58 AM, Sargun Dhillon wrote:
> [...]
> >So, with that, what about the following:
> >It includes
> >-Desupporting no MMU platforms as we've deemed them incapable of being
> >  safe
> >-Checking that we're not in a kthread
> >-Checking that the active mm is the thread's mm
> >-A log message indicating the experimental nature of this helper
> >
> >It does not include:
> >-A heuristic to determine is access_ok is broken, or if the platform
> >  didn't implement it. It seems all platforms with MMUs implement it today,
> >  and it seems clear to make that platforms should do something better than
> >  return 1, if they can
> 
> I don't really like couple of things, your ifdef CONFIG_MMU might not be
> needed I think, couple of these checks seem redundant, (I'm not yet sure
> about the task->mm != task->active_mm thingy), the helper should definitely
> be gpl_only and ARG_PTR_TO_RAW_STACK is just buggy. Also, this should be
> a bit analogue to bpf_probe_read we have. How about something roughly along
> the lines of below diff (obviously needs extensive testing ...)? This
> can still do all kind of ugly crap to the user process, but limited to
> the cap_sys_admin to shoot himself in the foot.
* You're right about CONFIG_MMU. We don't need it, all of the nommu platforms 
properly deal with it from my research.

It was always ARG_PTR_TO_STACK? Or are you saying ARG_PTR_TO_STACK is buggy and 
we should make it ARG_PTR_TO_RAW_STACK?

I originally named the function bpf_probe_write. Upon further thought I don't 
think that makes sense. The reason is because bpf_probe_read is analogous to 
probe_kernel_read. If we had bpf_probe_write, I think people might reason it to 
be equivalent to probe_kernel_write, and be confused when they can't write to 
kernel space.

I tried to make the external facing documentaion close to copy_to_user. That's 
how people should use it, not like _write. Therefor I think it makes sense to 
keep that the name.

I added a check for (!task) -- It seems to be spattered throughou the eBPF 
helper code. Alexei mentioned earlier that it can be null, but I'm not sure of 
the case

RE: task->mm != task->active_mm -- There are a couple scenarios where kthreads 
do this, and the only user call that should hit this is execve. There's only a 
brief period where this can be true and I don't think it's worth dealing with 
that case -- I'm not really sure you can plant a kprobe at the right site either

Did some minimal testing with tracex7 and others.

I was able to copy memory into other process's space while certain 
syscalls were going on. I don't think that there are a reasonable set of 
protections.

I'll do more testing. Any suggestions of what might break? I've looked at 
writing to unitialized memory, Memory out of bounds, etc... Do you know of any 
"weak spots"?

The rest of the helpers return EINVAL on invalid state. I think it makes sense 
to match them. ENOPERM makes sense for interacting with an illegal chunk of 
memory, but ENOPERM just because you're in a kthread seems especially weird.

> 
>  include/uapi/linux/bpf.h |  3 +++
>  kernel/trace/bpf_trace.c | 30 ++++++++++++++++++++++++++++++
>  2 files changed, 33 insertions(+)
> 
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 2b7076f..4d339c6 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -365,6 +365,9 @@ enum bpf_func_id {
>  	 */
>  	BPF_FUNC_get_current_task,
> 
> +	/* Doc goes here ... */
> +	BPF_FUNC_probe_write,
> +
>  	__BPF_FUNC_MAX_ID,
>  };
> 
> diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
> index a12bbd3..43a4386c 100644
> --- a/kernel/trace/bpf_trace.c
> +++ b/kernel/trace/bpf_trace.c
> @@ -81,6 +81,34 @@ static const struct bpf_func_proto bpf_probe_read_proto = {
>  	.arg3_type	= ARG_ANYTHING,
>  };
> 
> +static u64 bpf_probe_write(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
> +{
> +	struct task_struct *task = current;
> +	void *unsafe_ptr = (void *)(long) r1;
> +	void *src = (void *)(long) r2;
> +	int size = (int) r3;
> +
> +	if (unlikely(in_interrupt() || (task->flags & PF_KTHREAD)))
> +		return -EPERM;
> +	if (segment_eq(get_fs(), KERNEL_DS))
> +		return -EPERM;
> +	if (!access_ok(VERIFY_WRITE, unsafe_ptr, size))
> +		return -EPERM;
> +
> +	/* pr_warn_once() barks here ... */
> +
> +	return probe_kernel_write(unsafe_ptr, src, size);
> +}
> +
> +static const struct bpf_func_proto bpf_probe_write_proto = {
> +	.func           = bpf_probe_write,
> +	.gpl_only       = true,
> +	.ret_type       = RET_INTEGER,
> +	.arg1_type      = ARG_ANYTHING,
> +	.arg2_type      = ARG_PTR_TO_STACK,
> +	.arg3_type      = ARG_CONST_STACK_SIZE,
> +};
> +
>  /*
>   * limited trace_printk()
>   * only %d %u %x %ld %lu %lx %lld %llu %llx %p %s conversion specifiers allowed
> @@ -344,6 +372,8 @@ static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
>  		return &bpf_map_delete_elem_proto;
>  	case BPF_FUNC_probe_read:
>  		return &bpf_probe_read_proto;
> +	case BPF_FUNC_probe_write:
> +		return &bpf_probe_write_proto;
>  	case BPF_FUNC_ktime_get_ns:
>  		return &bpf_ktime_get_ns_proto;
>  	case BPF_FUNC_tail_call:
> -- 
> 1.9.3
commit e95732cb75e256af621ecaf85fd48d51bf91da1b
Author: Sargun Dhillon <sargun@sargun.me>
Date:   Mon Jul 18 19:38:58 2016 -0700

    bpf: Add bpf_copy_to_user BPF helper to be called in tracers (kprobes)
    
    This allows user memory to be written to during the course of a kprobe.
    It shouldn't be used to implement any kind of security mechanism
    because of TOC-TOU attacks, but rather to debug, divert, and
    manipulate execution of semi-cooperative processes.
    
    Although it uses probe_kernel_write, we limit the address space
    the probe can write into by checking the space with access_ok.
    This call shouldn't sleep on any architectures based on review.
    
    It was tested with the tracex7 program on x86-64.
    
    Signed-off-by: Sargun Dhillon <sargun@sargun.me>
    Cc: Alexei Starovoitov <ast@kernel.org>
    Cc: Daniel Borkmann <daniel@iogearbox.net>

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index c4d9224..d435f7c 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -364,6 +364,17 @@ enum bpf_func_id {
 	 */
 	BPF_FUNC_get_current_task,
 
+	/**
+	 * copy_to_user(to, from, len) - Copy a block of data into user space.
+	 * @to: destination address in userspace
+	 * @from: source address on stack
+	 * @len: number of bytes to copy
+	 * Return:
+	 *   Returns number of bytes that could not be copied.
+	 *   On success, this will be zero
+	 */
+	BPF_FUNC_copy_to_user,
+
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index ebfbb7d..b82b9e9 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -81,6 +81,48 @@ static const struct bpf_func_proto bpf_probe_read_proto = {
 	.arg3_type	= ARG_ANYTHING,
 };
 
+static u64 bpf_copy_to_user(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	void *unsafe_ptr = (void *) (long) r1;
+	void *src = (void *) (long) r2;
+	int size = (int) r3;
+	struct task_struct *task = current;
+
+	/*
+	 * Ensure we're in a user context which it is safe for the helper
+	 * to run.
+	 * Also, this helper has no business in a kthread.
+	 * Although, access_ok should prevent writing to non-user memory
+	 * On some architectures (nommu, etc...) access_ok isn't enough
+	 * So we check get_fs()
+	 */
+
+	if (unlikely(!task))
+		return -EINVAL;
+	if (unlikely(in_interrupt() || (task->flags & PF_KTHREAD)))
+		return -EINVAL;
+	if (unlikely(segment_eq(get_fs(), KERNEL_DS)))
+		return -EINVAL;
+	if (!access_ok(VERIFY_WRITE, unsafe_ptr, size))
+		return -EPERM;
+
+	pr_warn_once("**************************************************\n");
+	pr_warn_once("* bpf_copy_to_user: Experimental Feature in use  *\n");
+	pr_warn_once("* bpf_copy_to_user: Feature may corrupt memory   *\n");
+	pr_warn_once("**************************************************\n");
+
+	return probe_kernel_write(unsafe_ptr, src, size);
+}
+
+static const struct bpf_func_proto bpf_copy_to_user_proto = {
+	.func		= bpf_copy_to_user,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_ANYTHING,
+	.arg2_type	= ARG_PTR_TO_STACK,
+	.arg3_type	= ARG_CONST_STACK_SIZE,
+};
+
 /*
  * limited trace_printk()
  * only %d %u %x %ld %lu %lx %lld %llu %llx %p %s conversion specifiers allowed
@@ -360,6 +402,8 @@ static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
 		return &bpf_get_smp_processor_id_proto;
 	case BPF_FUNC_perf_event_read:
 		return &bpf_perf_event_read_proto;
+	case BPF_FUNC_copy_to_user:
+		return &bpf_copy_to_user_proto;
 	default:
 		return NULL;
 	}
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 84e3fd9..a54a26c 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -41,6 +41,8 @@ static int (*bpf_perf_event_output)(void *ctx, void *map, int index, void *data,
 	(void *) BPF_FUNC_perf_event_output;
 static int (*bpf_get_stackid)(void *ctx, void *map, int flags) =
 	(void *) BPF_FUNC_get_stackid;
+static int (*bpf_copy_to_user)(void *to, void *from, int size) =
+	(void *) BPF_FUNC_copy_to_user;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
