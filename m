From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 4/5] bpf, samples: don't zero data when not needed
Date: Wed, 13 Apr 2016 00:10:53 +0200
Message-ID: <b9758f9dbd9d9f5f82c5c9e80d7bedbedf6146bc.1460497071.git.daniel@iogearbox.net>
References: <cover.1460497071.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch, bblanco@plumgrid.com,
	brendan.d.gregg@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34352 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932656AbcDLWLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 18:11:14 -0400
In-Reply-To: <cover.1460497071.git.daniel@iogearbox.net>
In-Reply-To: <cover.1460497071.git.daniel@iogearbox.net>
References: <cover.1460497071.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the zero initialization in the sample programs where appropriate.
Note that this is an optimization which is now possible, old programs
still doing the zero initialization are just fine as well. Also, make
sure we don't have padding issues when we don't memset() the entire
struct anymore.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/offwaketime_kern.c | 10 ++++++----
 samples/bpf/tracex1_kern.c     |  4 +---
 samples/bpf/tracex2_kern.c     |  4 ++--
 samples/bpf/tracex5_kern.c     |  6 +++---
 4 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/samples/bpf/offwaketime_kern.c b/samples/bpf/offwaketime_kern.c
index 983629a..e7d9a0a 100644
--- a/samples/bpf/offwaketime_kern.c
+++ b/samples/bpf/offwaketime_kern.c
@@ -11,7 +11,7 @@
 #include <linux/version.h>
 #include <linux/sched.h>
 
-#define _(P) ({typeof(P) val = 0; bpf_probe_read(&val, sizeof(val), &P); val;})
+#define _(P) ({typeof(P) val; bpf_probe_read(&val, sizeof(val), &P); val;})
 
 #define MINBLOCK_US	1
 
@@ -61,7 +61,7 @@ SEC("kprobe/try_to_wake_up")
 int waker(struct pt_regs *ctx)
 {
 	struct task_struct *p = (void *) PT_REGS_PARM1(ctx);
-	struct wokeby_t woke = {};
+	struct wokeby_t woke;
 	u32 pid;
 
 	pid = _(p->pid);
@@ -75,17 +75,19 @@ int waker(struct pt_regs *ctx)
 
 static inline int update_counts(void *ctx, u32 pid, u64 delta)
 {
-	struct key_t key = {};
 	struct wokeby_t *woke;
 	u64 zero = 0, *val;
+	struct key_t key;
 
+	__builtin_memset(&key.waker, 0, sizeof(key.waker));
 	bpf_get_current_comm(&key.target, sizeof(key.target));
 	key.tret = bpf_get_stackid(ctx, &stackmap, STACKID_FLAGS);
+	key.wret = 0;
 
 	woke = bpf_map_lookup_elem(&wokeby, &pid);
 	if (woke) {
 		key.wret = woke->ret;
-		__builtin_memcpy(&key.waker, woke->name, TASK_COMM_LEN);
+		__builtin_memcpy(&key.waker, woke->name, sizeof(key.waker));
 		bpf_map_delete_elem(&wokeby, &pid);
 	}
 
diff --git a/samples/bpf/tracex1_kern.c b/samples/bpf/tracex1_kern.c
index 3f450a8..107da14 100644
--- a/samples/bpf/tracex1_kern.c
+++ b/samples/bpf/tracex1_kern.c
@@ -23,16 +23,14 @@ int bpf_prog1(struct pt_regs *ctx)
 	/* attaches to kprobe netif_receive_skb,
 	 * looks for packets on loobpack device and prints them
 	 */
-	char devname[IFNAMSIZ] = {};
+	char devname[IFNAMSIZ];
 	struct net_device *dev;
 	struct sk_buff *skb;
 	int len;
 
 	/* non-portable! works for the given kernel only */
 	skb = (struct sk_buff *) PT_REGS_PARM1(ctx);
-
 	dev = _(skb->dev);
-
 	len = _(skb->len);
 
 	bpf_probe_read(devname, sizeof(devname), dev->name);
diff --git a/samples/bpf/tracex2_kern.c b/samples/bpf/tracex2_kern.c
index 6d6eefd..5e11c20 100644
--- a/samples/bpf/tracex2_kern.c
+++ b/samples/bpf/tracex2_kern.c
@@ -66,7 +66,7 @@ struct hist_key {
 	char comm[16];
 	u64 pid_tgid;
 	u64 uid_gid;
-	u32 index;
+	u64 index;
 };
 
 struct bpf_map_def SEC("maps") my_hist_map = {
@@ -82,7 +82,7 @@ int bpf_prog3(struct pt_regs *ctx)
 	long write_size = PT_REGS_PARM3(ctx);
 	long init_val = 1;
 	long *value;
-	struct hist_key key = {};
+	struct hist_key key;
 
 	key.index = log2l(write_size);
 	key.pid_tgid = bpf_get_current_pid_tgid();
diff --git a/samples/bpf/tracex5_kern.c b/samples/bpf/tracex5_kern.c
index b3f4295..f95f232 100644
--- a/samples/bpf/tracex5_kern.c
+++ b/samples/bpf/tracex5_kern.c
@@ -22,7 +22,7 @@ struct bpf_map_def SEC("maps") progs = {
 SEC("kprobe/seccomp_phase1")
 int bpf_prog1(struct pt_regs *ctx)
 {
-	struct seccomp_data sd = {};
+	struct seccomp_data sd;
 
 	bpf_probe_read(&sd, sizeof(sd), (void *)PT_REGS_PARM1(ctx));
 
@@ -40,7 +40,7 @@ int bpf_prog1(struct pt_regs *ctx)
 /* we jump here when syscall number == __NR_write */
 PROG(__NR_write)(struct pt_regs *ctx)
 {
-	struct seccomp_data sd = {};
+	struct seccomp_data sd;
 
 	bpf_probe_read(&sd, sizeof(sd), (void *)PT_REGS_PARM1(ctx));
 	if (sd.args[2] == 512) {
@@ -53,7 +53,7 @@ PROG(__NR_write)(struct pt_regs *ctx)
 
 PROG(__NR_read)(struct pt_regs *ctx)
 {
-	struct seccomp_data sd = {};
+	struct seccomp_data sd;
 
 	bpf_probe_read(&sd, sizeof(sd), (void *)PT_REGS_PARM1(ctx));
 	if (sd.args[2] > 128 && sd.args[2] <= 1024) {
-- 
1.9.3
