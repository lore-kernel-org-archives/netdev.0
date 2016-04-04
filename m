From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: [PATCHv2 net 3/3] samples/bpf: Enable powerpc support
Date: Mon,  4 Apr 2016 22:31:34 +0530
Message-ID: <28d2e09a7db94a0a71b3222b3e5ffacb0d4a8dd7.1459789086.git.naveen.n.rao@linux.vnet.ibm.com>
References: <5ab5eec91d2d0bc7f221d714ef84afac83b2604b.1459789086.git.naveen.n.rao@linux.vnet.ibm.com>
Cc: Alexei Starovoitov <ast@fb.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"David S . Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>,
	Michael Ellerman <mpe@ellerman.id.au>
To: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5ab5eec91d2d0bc7f221d714ef84afac83b2604b.1459789086.git.naveen.n.rao@linux.vnet.ibm.com>
In-Reply-To: <5ab5eec91d2d0bc7f221d714ef84afac83b2604b.1459789086.git.naveen.n.rao@linux.vnet.ibm.com>
References: <5ab5eec91d2d0bc7f221d714ef84afac83b2604b.1459789086.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the necessary definitions for building bpf samples on ppc.

Since ppc doesn't store function return address on the stack, modify how
PT_REGS_RET() and PT_REGS_FP() work.

Also, introduce PT_REGS_IP() to access the instruction pointer.

Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
---
v2: updated macros using ({ }) gcc extension as per Alexei

 samples/bpf/bpf_helpers.h   | 26 ++++++++++++++++++++++++++
 samples/bpf/spintest_kern.c |  2 +-
 samples/bpf/tracex2_kern.c  |  4 ++--
 samples/bpf/tracex4_kern.c  |  2 +-
 4 files changed, 30 insertions(+), 4 deletions(-)

diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 9363500..7904a2a 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -82,6 +82,7 @@ static int (*bpf_l4_csum_replace)(void *ctx, int off, int from, int to, int flag
 #define PT_REGS_FP(x) ((x)->bp)
 #define PT_REGS_RC(x) ((x)->ax)
 #define PT_REGS_SP(x) ((x)->sp)
+#define PT_REGS_IP(x) ((x)->ip)
 
 #elif defined(__s390x__)
 
@@ -94,6 +95,7 @@ static int (*bpf_l4_csum_replace)(void *ctx, int off, int from, int to, int flag
 #define PT_REGS_FP(x) ((x)->gprs[11]) /* Works only with CONFIG_FRAME_POINTER */
 #define PT_REGS_RC(x) ((x)->gprs[2])
 #define PT_REGS_SP(x) ((x)->gprs[15])
+#define PT_REGS_IP(x) ((x)->ip)
 
 #elif defined(__aarch64__)
 
@@ -106,6 +108,30 @@ static int (*bpf_l4_csum_replace)(void *ctx, int off, int from, int to, int flag
 #define PT_REGS_FP(x) ((x)->regs[29]) /* Works only with CONFIG_FRAME_POINTER */
 #define PT_REGS_RC(x) ((x)->regs[0])
 #define PT_REGS_SP(x) ((x)->sp)
+#define PT_REGS_IP(x) ((x)->pc)
+
+#elif defined(__powerpc__)
+
+#define PT_REGS_PARM1(x) ((x)->gpr[3])
+#define PT_REGS_PARM2(x) ((x)->gpr[4])
+#define PT_REGS_PARM3(x) ((x)->gpr[5])
+#define PT_REGS_PARM4(x) ((x)->gpr[6])
+#define PT_REGS_PARM5(x) ((x)->gpr[7])
+#define PT_REGS_RC(x) ((x)->gpr[3])
+#define PT_REGS_SP(x) ((x)->sp)
+#define PT_REGS_IP(x) ((x)->nip)
 
 #endif
+
+#ifdef __powerpc__
+#define BPF_KPROBE_READ_RET_IP(ip, ctx)		({ (ip) = (ctx)->link; })
+#define BPF_KRETPROBE_READ_RET_IP		BPF_KPROBE_READ_RET_IP
+#else
+#define BPF_KPROBE_READ_RET_IP(ip, ctx)		({				\
+		bpf_probe_read(&(ip), sizeof(ip), (void *)PT_REGS_RET(ctx)); })
+#define BPF_KRETPROBE_READ_RET_IP(ip, ctx)	({				\
+		bpf_probe_read(&(ip), sizeof(ip),				\
+				(void *)(PT_REGS_FP(ctx) + sizeof(ip))); })
+#endif
+
 #endif
diff --git a/samples/bpf/spintest_kern.c b/samples/bpf/spintest_kern.c
index 4b27619..ce0167d 100644
--- a/samples/bpf/spintest_kern.c
+++ b/samples/bpf/spintest_kern.c
@@ -34,7 +34,7 @@ struct bpf_map_def SEC("maps") stackmap = {
 #define PROG(foo) \
 int foo(struct pt_regs *ctx) \
 { \
-	long v = ctx->ip, *val; \
+	long v = PT_REGS_IP(ctx), *val; \
 \
 	val = bpf_map_lookup_elem(&my_map, &v); \
 	bpf_map_update_elem(&my_map, &v, &v, BPF_ANY); \
diff --git a/samples/bpf/tracex2_kern.c b/samples/bpf/tracex2_kern.c
index 09c1adc..6d6eefd 100644
--- a/samples/bpf/tracex2_kern.c
+++ b/samples/bpf/tracex2_kern.c
@@ -27,10 +27,10 @@ int bpf_prog2(struct pt_regs *ctx)
 	long init_val = 1;
 	long *value;
 
-	/* x64/s390x specific: read ip of kfree_skb caller.
+	/* read ip of kfree_skb caller.
 	 * non-portable version of __builtin_return_address(0)
 	 */
-	bpf_probe_read(&loc, sizeof(loc), (void *)PT_REGS_RET(ctx));
+	BPF_KPROBE_READ_RET_IP(loc, ctx);
 
 	value = bpf_map_lookup_elem(&my_map, &loc);
 	if (value)
diff --git a/samples/bpf/tracex4_kern.c b/samples/bpf/tracex4_kern.c
index ac46714..6dd8e38 100644
--- a/samples/bpf/tracex4_kern.c
+++ b/samples/bpf/tracex4_kern.c
@@ -40,7 +40,7 @@ int bpf_prog2(struct pt_regs *ctx)
 	long ip = 0;
 
 	/* get ip address of kmem_cache_alloc_node() caller */
-	bpf_probe_read(&ip, sizeof(ip), (void *)(PT_REGS_FP(ctx) + sizeof(ip)));
+	BPF_KRETPROBE_READ_RET_IP(ip, ctx);
 
 	struct pair v = {
 		.val = bpf_ktime_get_ns(),
-- 
2.7.4
