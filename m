From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 1/3] bpf: introduce current->pid, tgid, uid, gid, comm accessors
Date: Fri, 12 Jun 2015 14:40:24 -0700
Message-ID: <1434145226-17892-2-git-send-email-ast@plumgrid.com>
References: <1434145226-17892-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Wang Nan <wangnan0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1434145226-17892-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

eBPF programs attached to kprobes need to filter based on
current->pid, uid and other fields, so introduce helper functions:

u64 bpf_get_current_pid_tgid(void)
Return: current->tgid << 32 | current->pid

u64 bpf_get_current_uid_gid(void)
Return: current_gid << 32 | current_uid

bpf_get_current_comm(char *buf, int size_of_buf)
stores current->comm into buf

They can be used from the programs attached to TC as well to classify packets
based on current task fields.

Update tracex2 example to print histogram of write syscalls for each process
instead of aggregated for all.

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---
These helpers will be mainly used by bpf+tracing, but the patch is targeting
net-next tree to minimize merge conflicts and they're useful in TC too.

The feature was requested by Wang Nan <wangnan0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org> and
Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

 include/linux/bpf.h        |    3 ++
 include/uapi/linux/bpf.h   |   19 +++++++++++++
 kernel/bpf/core.c          |    3 ++
 kernel/bpf/helpers.c       |   58 ++++++++++++++++++++++++++++++++++++++
 kernel/trace/bpf_trace.c   |    6 ++++
 net/core/filter.c          |    6 ++++
 samples/bpf/bpf_helpers.h  |    6 ++++
 samples/bpf/tracex2_kern.c |   24 ++++++++++++----
 samples/bpf/tracex2_user.c |   67 ++++++++++++++++++++++++++++++++++++++------
 9 files changed, 178 insertions(+), 14 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 2235aee8096a..1b9a3f5b27f6 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -188,5 +188,8 @@ extern const struct bpf_func_proto bpf_get_prandom_u32_proto;
 extern const struct bpf_func_proto bpf_get_smp_processor_id_proto;
 extern const struct bpf_func_proto bpf_tail_call_proto;
 extern const struct bpf_func_proto bpf_ktime_get_ns_proto;
+extern const struct bpf_func_proto bpf_get_current_pid_tgid_proto;
+extern const struct bpf_func_proto bpf_get_current_uid_gid_proto;
+extern const struct bpf_func_proto bpf_get_current_comm_proto;
 
 #endif /* _LINUX_BPF_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 602f05b7a275..29ef6f99e43d 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -230,6 +230,25 @@ enum bpf_func_id {
 	 * Return: 0 on success
 	 */
 	BPF_FUNC_clone_redirect,
+
+	/**
+	 * u64 bpf_get_current_pid_tgid(void)
+	 * Return: current->tgid << 32 | current->pid
+	 */
+	BPF_FUNC_get_current_pid_tgid,
+
+	/**
+	 * u64 bpf_get_current_uid_gid(void)
+	 * Return: current_gid << 32 | current_uid
+	 */
+	BPF_FUNC_get_current_uid_gid,
+
+	/**
+	 * bpf_get_current_comm(char *buf, int size_of_buf)
+	 * stores current->comm into buf
+	 * Return: 0 on success
+	 */
+	BPF_FUNC_get_current_comm,
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 1e00aa3316dc..1fc45cc83076 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -730,6 +730,9 @@ const struct bpf_func_proto bpf_map_delete_elem_proto __weak;
 const struct bpf_func_proto bpf_get_prandom_u32_proto __weak;
 const struct bpf_func_proto bpf_get_smp_processor_id_proto __weak;
 const struct bpf_func_proto bpf_ktime_get_ns_proto __weak;
+const struct bpf_func_proto bpf_get_current_pid_tgid_proto __weak;
+const struct bpf_func_proto bpf_get_current_uid_gid_proto __weak;
+const struct bpf_func_proto bpf_get_current_comm_proto __weak;
 
 /* Always built-in helper functions. */
 const struct bpf_func_proto bpf_tail_call_proto = {
diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
index 7ad5d8842d5b..d1dce346c56f 100644
--- a/kernel/bpf/helpers.c
+++ b/kernel/bpf/helpers.c
@@ -14,6 +14,8 @@
 #include <linux/random.h>
 #include <linux/smp.h>
 #include <linux/ktime.h>
+#include <linux/sched.h>
+#include <linux/uidgid.h>
 
 /* If kernel subsystem is allowing eBPF programs to call this function,
  * inside its own verifier_ops->get_func_proto() callback it should return
@@ -124,3 +126,59 @@ const struct bpf_func_proto bpf_ktime_get_ns_proto = {
 	.gpl_only	= true,
 	.ret_type	= RET_INTEGER,
 };
+
+static u64 bpf_get_current_pid_tgid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	struct task_struct *task = current;
+
+	if (!task)
+		return -EINVAL;
+
+	return (u64) task->tgid << 32 | task->pid;
+}
+
+const struct bpf_func_proto bpf_get_current_pid_tgid_proto = {
+	.func		= bpf_get_current_pid_tgid,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+};
+
+static u64 bpf_get_current_uid_gid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	struct task_struct *task = current;
+	kuid_t uid;
+	kgid_t gid;
+
+	if (!task)
+		return -EINVAL;
+
+	current_uid_gid(&uid, &gid);
+	return (u64) from_kgid(current_user_ns(), gid) << 32 |
+		from_kuid(current_user_ns(), uid);
+}
+
+const struct bpf_func_proto bpf_get_current_uid_gid_proto = {
+	.func		= bpf_get_current_uid_gid,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+};
+
+static u64 bpf_get_current_comm(u64 r1, u64 size, u64 r3, u64 r4, u64 r5)
+{
+	struct task_struct *task = current;
+	char *buf = (char *) (long) r1;
+
+	if (!task)
+		return -EINVAL;
+
+	memcpy(buf, task->comm, min_t(size_t, size, sizeof(task->comm)));
+	return 0;
+}
+
+const struct bpf_func_proto bpf_get_current_comm_proto = {
+	.func		= bpf_get_current_comm,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_STACK,
+	.arg2_type	= ARG_CONST_STACK_SIZE,
+};
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 50c4015a8ad3..3a17638cdf46 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -162,6 +162,12 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 		return &bpf_ktime_get_ns_proto;
 	case BPF_FUNC_tail_call:
 		return &bpf_tail_call_proto;
+	case BPF_FUNC_get_current_pid_tgid:
+		return &bpf_get_current_pid_tgid_proto;
+	case BPF_FUNC_get_current_uid_gid:
+		return &bpf_get_current_uid_gid_proto;
+	case BPF_FUNC_get_current_comm:
+		return &bpf_get_current_comm_proto;
 
 	case BPF_FUNC_trace_printk:
 		/*
diff --git a/net/core/filter.c b/net/core/filter.c
index d271c06bf01f..20aa51ccbf9d 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1459,6 +1459,12 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 		return &bpf_l4_csum_replace_proto;
 	case BPF_FUNC_clone_redirect:
 		return &bpf_clone_redirect_proto;
+	case BPF_FUNC_get_current_pid_tgid:
+		return &bpf_get_current_pid_tgid_proto;
+	case BPF_FUNC_get_current_uid_gid:
+		return &bpf_get_current_uid_gid_proto;
+	case BPF_FUNC_get_current_comm:
+		return &bpf_get_current_comm_proto;
 	default:
 		return sk_filter_func_proto(func_id);
 	}
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index f531a0b3282d..bdf1c1607b80 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -25,6 +25,12 @@ static void (*bpf_tail_call)(void *ctx, void *map, int index) =
 	(void *) BPF_FUNC_tail_call;
 static unsigned long long (*bpf_get_smp_processor_id)(void) =
 	(void *) BPF_FUNC_get_smp_processor_id;
+static unsigned long long (*bpf_get_current_pid_tgid)(void) =
+	(void *) BPF_FUNC_get_current_pid_tgid;
+static unsigned long long (*bpf_get_current_uid_gid)(void) =
+	(void *) BPF_FUNC_get_current_uid_gid;
+static int (*bpf_get_current_comm)(void *buf, int buf_size) =
+	(void *) BPF_FUNC_get_current_comm;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
diff --git a/samples/bpf/tracex2_kern.c b/samples/bpf/tracex2_kern.c
index 19ec1cfc45db..dc50f4f2943f 100644
--- a/samples/bpf/tracex2_kern.c
+++ b/samples/bpf/tracex2_kern.c
@@ -62,11 +62,18 @@ static unsigned int log2l(unsigned long v)
 		return log2(v);
 }
 
+struct hist_key {
+	char comm[16];
+	u64 pid_tgid;
+	u64 uid_gid;
+	u32 index;
+};
+
 struct bpf_map_def SEC("maps") my_hist_map = {
-	.type = BPF_MAP_TYPE_ARRAY,
-	.key_size = sizeof(u32),
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(struct hist_key),
 	.value_size = sizeof(long),
-	.max_entries = 64,
+	.max_entries = 1024,
 };
 
 SEC("kprobe/sys_write")
@@ -75,11 +82,18 @@ int bpf_prog3(struct pt_regs *ctx)
 	long write_size = ctx->dx; /* arg3 */
 	long init_val = 1;
 	long *value;
-	u32 index = log2l(write_size);
+	struct hist_key key = {};
+
+	key.index = log2l(write_size);
+	key.pid_tgid = bpf_get_current_pid_tgid();
+	key.uid_gid = bpf_get_current_uid_gid();
+	bpf_get_current_comm(&key.comm, sizeof(key.comm));
 
-	value = bpf_map_lookup_elem(&my_hist_map, &index);
+	value = bpf_map_lookup_elem(&my_hist_map, &key);
 	if (value)
 		__sync_fetch_and_add(value, 1);
+	else
+		bpf_map_update_elem(&my_hist_map, &key, &init_val, BPF_ANY);
 	return 0;
 }
 char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/tracex2_user.c b/samples/bpf/tracex2_user.c
index 91b8d0896fbb..cd0241c1447a 100644
--- a/samples/bpf/tracex2_user.c
+++ b/samples/bpf/tracex2_user.c
@@ -3,6 +3,7 @@
 #include <stdlib.h>
 #include <signal.h>
 #include <linux/bpf.h>
+#include <string.h>
 #include "libbpf.h"
 #include "bpf_load.h"
 
@@ -20,23 +21,42 @@ static void stars(char *str, long val, long max, int width)
 	str[i] = '\0';
 }
 
-static void print_hist(int fd)
+struct task {
+	char comm[16];
+	__u64 pid_tgid;
+	__u64 uid_gid;
+};
+
+struct hist_key {
+	struct task t;
+	__u32 index;
+};
+
+#define SIZE sizeof(struct task)
+
+static void print_hist_for_pid(int fd, void *task)
 {
-	int key;
+	struct hist_key key = {}, next_key;
+	char starstr[MAX_STARS];
 	long value;
 	long data[MAX_INDEX] = {};
-	char starstr[MAX_STARS];
-	int i;
 	int max_ind = -1;
 	long max_value = 0;
+	int i, ind;
 
-	for (key = 0; key < MAX_INDEX; key++) {
-		bpf_lookup_elem(fd, &key, &value);
-		data[key] = value;
-		if (value && key > max_ind)
-			max_ind = key;
+	while (bpf_get_next_key(fd, &key, &next_key) == 0) {
+		if (memcmp(&next_key, task, SIZE)) {
+			key = next_key;
+			continue;
+		}
+		bpf_lookup_elem(fd, &next_key, &value);
+		ind = next_key.index;
+		data[ind] = value;
+		if (value && ind > max_ind)
+			max_ind = ind;
 		if (value > max_value)
 			max_value = value;
+		key = next_key;
 	}
 
 	printf("           syscall write() stats\n");
@@ -48,6 +68,35 @@ static void print_hist(int fd)
 		       MAX_STARS, starstr);
 	}
 }
+
+static void print_hist(int fd)
+{
+	struct hist_key key = {}, next_key;
+	static struct task tasks[1024];
+	int task_cnt = 0;
+	int i;
+
+	while (bpf_get_next_key(fd, &key, &next_key) == 0) {
+		int found = 0;
+
+		for (i = 0; i < task_cnt; i++)
+			if (memcmp(&tasks[i], &next_key, SIZE) == 0)
+				found = 1;
+		if (!found)
+			memcpy(&tasks[task_cnt++], &next_key, SIZE);
+		key = next_key;
+	}
+
+	for (i = 0; i < task_cnt; i++) {
+		printf("\npid %d cmd %s uid %d\n",
+		       (__u32) tasks[i].pid_tgid,
+		       tasks[i].comm,
+		       (__u32) tasks[i].uid_gid);
+		print_hist_for_pid(fd, &tasks[i]);
+	}
+
+}
+
 static void int_exit(int sig)
 {
 	print_hist(map_fd[1]);
-- 
1.7.9.5
