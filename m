From: Sargun Dhillon <sargun@sargun.me>
Subject: Re: [PATCH net-next v3 1/2] bpf: Add bpf_copy_to_user BPF helper to
 be called in tracers (kprobes)
Date: Wed, 20 Jul 2016 02:58:48 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1607200133350.13397@ircssh.c.rugged-nimbus-611.internal>
References: <20160719093242.GA23753@ircssh.c.rugged-nimbus-611.internal> <578E0C61.6070705@iogearbox.net> <20160719163443.GA57855@ast-mbp.thefacebook.com> <578EB597.2080608@iogearbox.net> <20160720030200.GA70500@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:34899 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753172AbcGTJ6u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 05:58:50 -0400
Received: by mail-io0-f177.google.com with SMTP id m101so42927957ioi.2
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 02:58:49 -0700 (PDT)
In-Reply-To: <20160720030200.GA70500@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 19 Jul 2016, Alexei Starovoitov wrote:

> On Wed, Jul 20, 2016 at 01:19:51AM +0200, Daniel Borkmann wrote:
>> On 07/19/2016 06:34 PM, Alexei Starovoitov wrote:
>>> On Tue, Jul 19, 2016 at 01:17:53PM +0200, Daniel Borkmann wrote:
>>>>> +		return -EINVAL;
>>>>> +
>>>>> +	/* Is this a user address, or a kernel address? */
>>>>> +	if (!access_ok(VERIFY_WRITE, to, size))
>>>>> +		return -EINVAL;
>>>>> +
>>>>> +	return probe_kernel_write(to, from, size);
>>>>
>>>> I'm still worried that this can lead to all kind of hard to find
>>>> bugs or races for user processes, if you make this writable to entire
>>>> user address space (which is the only thing that access_ok() checks
>>>> for). What if the BPF program has bugs and writes to wrong addresses
>>>> for example, introducing bugs in some other, non-intended processes
>>>> elsewhere? Can this be limited to syscalls only? And if so, to the
>>>> passed memory only?
>>>
>>> my understanding that above code will write only to memory of current process,
>>> so impact is contained and in that sense buggy kprobe program is no different
>>> from buggy seccomp prorgram.
>>
>> Compared to seccomp, you might not notice that a race has happened,
>> in seccomp case you might have killed your process, which is visible.
>> But ok, in ptrace() case it might be similar issue perhaps ...
>>
>> The asm-generic version does __access_ok(..) { return 1; } for nommu
>> case, I haven't checked closely enough whether there's actually an arch
>> that uses this, but for example arm nommu with only one addr space would
>> certainly result in access_ok() as 1, and then you could also go into
>> probe_kernel_write(), no?
>
> good point. how arm nommu handles copy_to_user? if there is nommu
> then there is no user/kernel mm ? Crazy archs.
> I guess we have to disable this helper on all such archs.
>
How do y'all do testing / development with nommu architectures?

Also, what are the guarantees of memory protection a single address space 
nommu architecture gives you? It seems like with some of the access_ok 
implementations there's little protection.

It seems to me that the same risk that's in copy_to_user for user provided 
pointers in those architectures exists in this helper (nil). So, I agree, 
that we should probably just disable this helper.

>> Don't know that code well enough, but I believe the check would only
>> ensure in normal use-cases that user process doesn't fiddle with kernel
>> address space, but not necessarily guarantee that this really only
>> belongs to the process address space.
>
> why? on x86 that exactly what it does. access_ok=true means
> it's user space address and since we're in _this user context_
> probe_kernel_write can only affect this user.
>
I actually added a second check to ensure that the user context we're in 
is the active user context. This prevents this helper from effecting other 
processes during things like a process_vm_writev.

>> x86 code comments this with "note that, depending on architecture,
>> this function probably just checks that the pointer is in the user
>> space range - after calling this function, memory access functions may
>> still return -EFAULT".
>
> Yes. I've read that comment to :)
> Certainly not an expert, but the archs I've looked at, access_ok
> has the same meaning as on x86. They check the space range to
> make sure address doesn't belong to kernel.
> Could I have missed something? Certainly. Please double check :)
>
>> Also, what happens in case of kernel thread?
>
> my understanding if access_ok(addr)=true the addr will never point
> to memory of kernel thread.
> We need expert opinion. Whom should we ping?
>
>> As it stands, it does ...
>>
>> 	if (unlikely(in_interrupt()))
>> 		return -EINVAL;
>> 	if (unlikely(!task || !task->pid))
>> 		return -EINVAL;
>>
>> So up to here, irq/sirq, NULL current and that current is not the 'idle'
>> process is being checked (still fail to see the point for the !task->pid,
>> I believe the intend here is different).
>>
>> 	/* Is this a user address, or a kernel address? */
>> 	if (!access_ok(VERIFY_WRITE, to, size))
>> 		return -EINVAL;
>>
>> Now here. What if it's a kernel thread? You'll have KERNEL_DS segment,
>> task->pid was non-zero as well for the kthread, so access_ok() will
>> pass and you can still execute probe_kernel_write() ...
>
> I think user_addr_max() should be zero for kthread, but
> worth checking for sure.
>
>>> Limiting this to syscalls will make it too limited.
>>> I'm in favor of this change, because it allows us to experiment
>>> with restartable sequences and lock-free algorithms that need ultrafast
>>> access to cpuid without burdening the kernel with stable abi.
>>>
>>>> Have you played around with ptrace() to check whether you could
>>>> achieve similar functionality (was thinking about things like [1],
>>>> PTRACE_PEEK{TEXT,DATA} / PTRACE_POKE{TEXT,DATA}). If not, why can't
>>>> this be limited to a similar functionality for only the current task.
>>>> ptrace() utilizes helpers like access_process_vm(), maybe this can
>>>> similarly be adapted here, too (under the circumstances that sleeping
>>>> is not allowed)?
>>>
>>> If we hack access_process_vm I think at the end it will look like
>>> probe_kernel_write. Walking mm requires semaphore, so we would only
>>> be able to do it in task_work and there we can do normal copy_to_user
>>> just as well, but it will complicate the programs quite a bit, since
>>> writes will be asynchronous and batched.
>>> Looks like with access_ok+probe_write we can achieve the same
>>> with a lot less code.
>>
>> I believe it may not quite be the same as it currently stands. No
>> fundamental objection, just that this needs to be made "safe" to the
>> limits you state above yourself. ;)
>
> completely agree :) the more eyes on the patch the better.
>
>>> As far as races between user and bpf program, yeah, if process
>>> is multithreaded, the other threads may access the same mem that
>>> bpf is writing to, but that's no different from reading.
>>> For tracing we walk complex datastructures and pointers. They
>>> can be changed by user space on the fly and bpf will see garbage.
>>> Like we have uprobe+bpf that walks clang c++ internal datastructures
>>> to figure out how long it takes clang to process .h headers.
>>> There is a lot of fragility in the bpf script, yet it's pretty
>>> useful to quickly analyze compile times.
>>> I see bpf_copy_to_user to be hugely valuable too, not as a stable
>>> interface, but rather as a tool to quickly debug and experiment.
>>
>> Right, so maybe there should be a warn once to the dmesg log that this
>> is just experimental?
>
> good point. The tracing experience showed that trace_printk warning
> was quite effective on steering user space assumptions. Let's do
> something here as well.
>
>
So, with that, what about the following:
It includes
-Desupporting no MMU platforms as we've deemed them incapable of being
  safe
-Checking that we're not in a kthread
-Checking that the active mm is the thread's mm
-A log message indicating the experimental nature of this helper

It does not include:
-A heuristic to determine is access_ok is broken, or if the platform
  didn't implement it. It seems all platforms with MMUs implement it today,
  and it seems clear to make that platforms should do something better than
  return 1, if they can


commit 04951b1caf63e06024350389cbddbcccf1a4674b
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
index ebfbb7d..e5f17b0 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -81,6 +81,68 @@ static const struct bpf_func_proto bpf_probe_read_proto = {
  	.arg3_type	= ARG_ANYTHING,
  };

+static void bpf_copy_to_user_warn(void) {
+	pr_warn_once("**************************************************\n");
+	pr_warn_once("* bpf_copy_to_user: Experimental Feature in use  *\n");
+	pr_warn_once("* bpf_copy_to_user: Feature may corrupt memory   *\n");
+	pr_warn_once("**************************************************\n");
+}
+
+static u64 bpf_copy_to_user(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+/*
+ * There isn't enough protection on no MMU architectures for this helper
+ * to be considered safe
+ */
+#ifdef CONFIG_MMU
+	void *to = (void *) (long) r1;
+	void *from = (void *) (long) r2;
+	int size = (int) r3;
+	struct task_struct *task = current;
+
+	/*
+	 * Ensure we're in a user context which it is safe for the helper
+	 * to run.
+	 * Also, this helper has no business in a kthread.
+	 * Although, access_ok should prevent writing to non-user memory
+	 * On some architectures (nommu, etc...) access_ok isn't enough
+	 */
+
+	if (unlikely(in_interrupt() || !task))
+		return -EINVAL;
+
+	if (unlikely(!task->pid || !task->mm || task->flags & PF_KTHREAD))
+		return -EINVAL;
+
+	/*
+	 * Make sure that this thread hasn't adopted another process's
+	 * memory context a la process_vm_(read/write)v to avoid unintended
+	 * side effects
+	 */
+	if (unlikely(task->mm != task->active_mm))
+		return -EINVAL;
+
+	/* Is this a user address, or a kernel address? */
+	if (!access_ok(VERIFY_WRITE, to, size))
+		return -EINVAL;
+
+	DO_ONCE(bpf_copy_to_user_warn);
+
+	return probe_kernel_write(to, from, size);
+#else /* CONFIG_MMU */
+	return -ENOTSUP;
+#endif /* CONFIG_MMU */
+}
+
+static const struct bpf_func_proto bpf_copy_to_user_proto = {
+	.func		= bpf_copy_to_user,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_ANYTHING,
+	.arg2_type	= ARG_PTR_TO_RAW_STACK,
+	.arg3_type	= ARG_CONST_STACK_SIZE,
+};
+
  /*
   * limited trace_printk()
   * only %d %u %x %ld %lu %lx %lld %llu %llx %p %s conversion specifiers allowed
@@ -360,6 +422,8 @@ static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
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
