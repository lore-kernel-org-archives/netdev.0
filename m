From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v3 1/2] bpf: Add bpf_copy_to_user BPF helper
 to be called in tracers (kprobes)
Date: Thu, 21 Jul 2016 01:00:51 +0200
Message-ID: <579002A3.3090406@iogearbox.net>
References: <20160719093242.GA23753@ircssh.c.rugged-nimbus-611.internal> <578E0C61.6070705@iogearbox.net> <20160719163443.GA57855@ast-mbp.thefacebook.com> <578EB597.2080608@iogearbox.net> <20160720030200.GA70500@ast-mbp.thefacebook.com> <alpine.DEB.2.02.1607200133350.13397@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Sargun Dhillon <sargun@sargun.me>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1607200133350.13397@ircssh.c.rugged-nimbus-611.internal>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/20/2016 11:58 AM, Sargun Dhillon wrote:
[...]
> So, with that, what about the following:
> It includes
> -Desupporting no MMU platforms as we've deemed them incapable of being
>   safe
> -Checking that we're not in a kthread
> -Checking that the active mm is the thread's mm
> -A log message indicating the experimental nature of this helper
>
> It does not include:
> -A heuristic to determine is access_ok is broken, or if the platform
>   didn't implement it. It seems all platforms with MMUs implement it today,
>   and it seems clear to make that platforms should do something better than
>   return 1, if they can

I don't really like couple of things, your ifdef CONFIG_MMU might not be
needed I think, couple of these checks seem redundant, (I'm not yet sure
about the task->mm != task->active_mm thingy), the helper should definitely
be gpl_only and ARG_PTR_TO_RAW_STACK is just buggy. Also, this should be
a bit analogue to bpf_probe_read we have. How about something roughly along
the lines of below diff (obviously needs extensive testing ...)? This
can still do all kind of ugly crap to the user process, but limited to
the cap_sys_admin to shoot himself in the foot.

  include/uapi/linux/bpf.h |  3 +++
  kernel/trace/bpf_trace.c | 30 ++++++++++++++++++++++++++++++
  2 files changed, 33 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 2b7076f..4d339c6 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -365,6 +365,9 @@ enum bpf_func_id {
  	 */
  	BPF_FUNC_get_current_task,

+	/* Doc goes here ... */
+	BPF_FUNC_probe_write,
+
  	__BPF_FUNC_MAX_ID,
  };

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index a12bbd3..43a4386c 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -81,6 +81,34 @@ static const struct bpf_func_proto bpf_probe_read_proto = {
  	.arg3_type	= ARG_ANYTHING,
  };

+static u64 bpf_probe_write(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	struct task_struct *task = current;
+	void *unsafe_ptr = (void *)(long) r1;
+	void *src = (void *)(long) r2;
+	int size = (int) r3;
+
+	if (unlikely(in_interrupt() || (task->flags & PF_KTHREAD)))
+		return -EPERM;
+	if (segment_eq(get_fs(), KERNEL_DS))
+		return -EPERM;
+	if (!access_ok(VERIFY_WRITE, unsafe_ptr, size))
+		return -EPERM;
+
+	/* pr_warn_once() barks here ... */
+
+	return probe_kernel_write(unsafe_ptr, src, size);
+}
+
+static const struct bpf_func_proto bpf_probe_write_proto = {
+	.func           = bpf_probe_write,
+	.gpl_only       = true,
+	.ret_type       = RET_INTEGER,
+	.arg1_type      = ARG_ANYTHING,
+	.arg2_type      = ARG_PTR_TO_STACK,
+	.arg3_type      = ARG_CONST_STACK_SIZE,
+};
+
  /*
   * limited trace_printk()
   * only %d %u %x %ld %lu %lx %lld %llu %llx %p %s conversion specifiers allowed
@@ -344,6 +372,8 @@ static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
  		return &bpf_map_delete_elem_proto;
  	case BPF_FUNC_probe_read:
  		return &bpf_probe_read_proto;
+	case BPF_FUNC_probe_write:
+		return &bpf_probe_write_proto;
  	case BPF_FUNC_ktime_get_ns:
  		return &bpf_ktime_get_ns_proto;
  	case BPF_FUNC_tail_call:
-- 
1.9.3
