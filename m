From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Subject: [PATCH] samples: bpf: enable trace samples for s390x
Date: Mon, 6 Jul 2015 16:20:07 +0200
Message-ID: <20150706162007.69824718@holzheu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:37969 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751817AbbGFOUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 10:20:13 -0400
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <holzheu@linux.vnet.ibm.com>;
	Mon, 6 Jul 2015 15:20:12 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 1037E1B08061
	for <netdev@vger.kernel.org>; Mon,  6 Jul 2015 15:21:20 +0100 (BST)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t66EK9nE31653940
	for <netdev@vger.kernel.org>; Mon, 6 Jul 2015 14:20:09 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t66EK9Tu018492
	for <netdev@vger.kernel.org>; Mon, 6 Jul 2015 08:20:09 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The trace bpf samples do not compile on s390x because they use x86
specific fields from the "pt_regs" structure.

Fix this and access the fields via new PT_REGS macros.

Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
---
 samples/bpf/bpf_helpers.h  | 25 +++++++++++++++++++++++++
 samples/bpf/tracex1_kern.c |  2 +-
 samples/bpf/tracex2_kern.c |  6 +++---
 samples/bpf/tracex3_kern.c |  4 ++--
 samples/bpf/tracex4_kern.c |  6 +++---
 samples/bpf/tracex5_kern.c |  6 +++---
 6 files changed, 37 insertions(+), 12 deletions(-)

diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index bdf1c16..c77c872 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -60,4 +60,29 @@ static int (*bpf_l3_csum_replace)(void *ctx, int off, int from, int to, int flag
 static int (*bpf_l4_csum_replace)(void *ctx, int off, int from, int to, int flags) =
 	(void *) BPF_FUNC_l4_csum_replace;
 
+#if defined(__x86_64__)
+
+#define PT_REGS_PARM1(x) ((x)->di)
+#define PT_REGS_PARM2(x) ((x)->si)
+#define PT_REGS_PARM3(x) ((x)->dx)
+#define PT_REGS_PARM4(x) ((x)->cx)
+#define PT_REGS_PARM5(x) ((x)->r8)
+#define PT_REGS_RET(x) ((x)->sp)
+#define PT_REGS_FP(x) ((x)->bp)
+#define PT_REGS_RC(x) ((x)->ax)
+#define PT_REGS_SP(x) ((x)->sp)
+
+#elif defined(__s390x__)
+
+#define PT_REGS_PARM1(x) ((x)->gprs[2])
+#define PT_REGS_PARM2(x) ((x)->gprs[3])
+#define PT_REGS_PARM3(x) ((x)->gprs[4])
+#define PT_REGS_PARM4(x) ((x)->gprs[5])
+#define PT_REGS_PARM5(x) ((x)->gprs[6])
+#define PT_REGS_RET(x) ((x)->gprs[14])
+#define PT_REGS_FP(x) ((x)->gprs[11]) /* Works only with CONFIG_FRAME_POINTER */
+#define PT_REGS_RC(x) ((x)->gprs[2])
+#define PT_REGS_SP(x) ((x)->gprs[15])
+
+#endif
 #endif
diff --git a/samples/bpf/tracex1_kern.c b/samples/bpf/tracex1_kern.c
index 3162046..3f450a8 100644
--- a/samples/bpf/tracex1_kern.c
+++ b/samples/bpf/tracex1_kern.c
@@ -29,7 +29,7 @@ int bpf_prog1(struct pt_regs *ctx)
 	int len;
 
 	/* non-portable! works for the given kernel only */
-	skb = (struct sk_buff *) ctx->di;
+	skb = (struct sk_buff *) PT_REGS_PARM1(ctx);
 
 	dev = _(skb->dev);
 
diff --git a/samples/bpf/tracex2_kern.c b/samples/bpf/tracex2_kern.c
index dc50f4f..b32367c 100644
--- a/samples/bpf/tracex2_kern.c
+++ b/samples/bpf/tracex2_kern.c
@@ -27,10 +27,10 @@ int bpf_prog2(struct pt_regs *ctx)
 	long init_val = 1;
 	long *value;
 
-	/* x64 specific: read ip of kfree_skb caller.
+	/* x64/s390x specific: read ip of kfree_skb caller.
 	 * non-portable version of __builtin_return_address(0)
 	 */
-	bpf_probe_read(&loc, sizeof(loc), (void *)ctx->sp);
+	bpf_probe_read(&loc, sizeof(loc), (void *)PT_REGS_RET(ctx));
 
 	value = bpf_map_lookup_elem(&my_map, &loc);
 	if (value)
@@ -79,7 +79,7 @@ struct bpf_map_def SEC("maps") my_hist_map = {
 SEC("kprobe/sys_write")
 int bpf_prog3(struct pt_regs *ctx)
 {
-	long write_size = ctx->dx; /* arg3 */
+	long write_size = PT_REGS_PARM3(ctx);
 	long init_val = 1;
 	long *value;
 	struct hist_key key = {};
diff --git a/samples/bpf/tracex3_kern.c b/samples/bpf/tracex3_kern.c
index 255ff27..bf337fb 100644
--- a/samples/bpf/tracex3_kern.c
+++ b/samples/bpf/tracex3_kern.c
@@ -23,7 +23,7 @@ struct bpf_map_def SEC("maps") my_map = {
 SEC("kprobe/blk_mq_start_request")
 int bpf_prog1(struct pt_regs *ctx)
 {
-	long rq = ctx->di;
+	long rq = PT_REGS_PARM1(ctx);
 	u64 val = bpf_ktime_get_ns();
 
 	bpf_map_update_elem(&my_map, &rq, &val, BPF_ANY);
@@ -51,7 +51,7 @@ struct bpf_map_def SEC("maps") lat_map = {
 SEC("kprobe/blk_update_request")
 int bpf_prog2(struct pt_regs *ctx)
 {
-	long rq = ctx->di;
+	long rq = PT_REGS_PARM1(ctx);
 	u64 *value, l, base;
 	u32 index;
 
diff --git a/samples/bpf/tracex4_kern.c b/samples/bpf/tracex4_kern.c
index 126b805..ac46714 100644
--- a/samples/bpf/tracex4_kern.c
+++ b/samples/bpf/tracex4_kern.c
@@ -27,7 +27,7 @@ struct bpf_map_def SEC("maps") my_map = {
 SEC("kprobe/kmem_cache_free")
 int bpf_prog1(struct pt_regs *ctx)
 {
-	long ptr = ctx->si;
+	long ptr = PT_REGS_PARM2(ctx);
 
 	bpf_map_delete_elem(&my_map, &ptr);
 	return 0;
@@ -36,11 +36,11 @@ int bpf_prog1(struct pt_regs *ctx)
 SEC("kretprobe/kmem_cache_alloc_node")
 int bpf_prog2(struct pt_regs *ctx)
 {
-	long ptr = ctx->ax;
+	long ptr = PT_REGS_RC(ctx);
 	long ip = 0;
 
 	/* get ip address of kmem_cache_alloc_node() caller */
-	bpf_probe_read(&ip, sizeof(ip), (void *)(ctx->bp + sizeof(ip)));
+	bpf_probe_read(&ip, sizeof(ip), (void *)(PT_REGS_FP(ctx) + sizeof(ip)));
 
 	struct pair v = {
 		.val = bpf_ktime_get_ns(),
diff --git a/samples/bpf/tracex5_kern.c b/samples/bpf/tracex5_kern.c
index b71fe07..b3f4295 100644
--- a/samples/bpf/tracex5_kern.c
+++ b/samples/bpf/tracex5_kern.c
@@ -24,7 +24,7 @@ int bpf_prog1(struct pt_regs *ctx)
 {
 	struct seccomp_data sd = {};
 
-	bpf_probe_read(&sd, sizeof(sd), (void *)ctx->di);
+	bpf_probe_read(&sd, sizeof(sd), (void *)PT_REGS_PARM1(ctx));
 
 	/* dispatch into next BPF program depending on syscall number */
 	bpf_tail_call(ctx, &progs, sd.nr);
@@ -42,7 +42,7 @@ PROG(__NR_write)(struct pt_regs *ctx)
 {
 	struct seccomp_data sd = {};
 
-	bpf_probe_read(&sd, sizeof(sd), (void *)ctx->di);
+	bpf_probe_read(&sd, sizeof(sd), (void *)PT_REGS_PARM1(ctx));
 	if (sd.args[2] == 512) {
 		char fmt[] = "write(fd=%d, buf=%p, size=%d)\n";
 		bpf_trace_printk(fmt, sizeof(fmt),
@@ -55,7 +55,7 @@ PROG(__NR_read)(struct pt_regs *ctx)
 {
 	struct seccomp_data sd = {};
 
-	bpf_probe_read(&sd, sizeof(sd), (void *)ctx->di);
+	bpf_probe_read(&sd, sizeof(sd), (void *)PT_REGS_PARM1(ctx));
 	if (sd.args[2] > 128 && sd.args[2] <= 1024) {
 		char fmt[] = "read(fd=%d, buf=%p, size=%d)\n";
 		bpf_trace_printk(fmt, sizeof(fmt),
-- 
2.3.8
