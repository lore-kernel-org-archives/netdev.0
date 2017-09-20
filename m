From: Joel Fernandes <joelaf@google.com>
Subject: [PATCH v4 3/4] samples/bpf: Fix pt_regs issues when cross-compiling
Date: Wed, 20 Sep 2017 09:11:58 -0700
Message-ID: <20170920161159.25747-3-joelaf@google.com>
References: <20170920161159.25747-1-joelaf@google.com>
Cc: netdev@vger.kernel.org, alison@she-devel.com, juri.lelli@arm.com,
        fengc@google.com, daniel@iogearbox.net, davem@davemloft.net,
        ast@kernel.org, kernel-team@android.com,
        Joel Fernandes <joelaf@google.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170920161159.25747-1-joelaf@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

BPF samples fail to build when cross-compiling for ARM64 because of incorrect
pt_regs param selection. This is because clang defines __x86_64__ and
bpf_headers thinks we're building for x86. Since clang is building for the BPF
target, it shouldn't make assumptions about what target the BPF program is
going to run on. To fix this, lets pass ARCH so the header knows which target
the BPF program is being compiled for and can use the correct pt_regs code.

Acked-by: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: Joel Fernandes <joelaf@google.com>
---
 samples/bpf/Makefile                      |  2 +-
 tools/testing/selftests/bpf/bpf_helpers.h | 56 +++++++++++++++++++++++++++----
 2 files changed, 50 insertions(+), 8 deletions(-)

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 13f74b67ca44..ebc2ad69b62c 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -230,7 +230,7 @@ $(obj)/%.o: $(src)/%.c
 	$(CLANG) $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) -I$(obj) \
 		-I$(srctree)/tools/testing/selftests/bpf/ \
 		-D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
-		-Wno-compare-distinct-pointer-types \
+		-D__TARGET_ARCH_$(ARCH) -Wno-compare-distinct-pointer-types \
 		-Wno-gnu-variable-sized-type-not-at-end \
 		-Wno-address-of-packed-member -Wno-tautological-compare \
 		-Wno-unknown-warning-option \
diff --git a/tools/testing/selftests/bpf/bpf_helpers.h b/tools/testing/selftests/bpf/bpf_helpers.h
index 36fb9161b34a..4875395b0b52 100644
--- a/tools/testing/selftests/bpf/bpf_helpers.h
+++ b/tools/testing/selftests/bpf/bpf_helpers.h
@@ -109,7 +109,47 @@ static int (*bpf_skb_under_cgroup)(void *ctx, void *map, int index) =
 static int (*bpf_skb_change_head)(void *, int len, int flags) =
 	(void *) BPF_FUNC_skb_change_head;
 
+/* Scan the ARCH passed in from ARCH env variable (see Makefile) */
+#if defined(__TARGET_ARCH_x86)
+	#define bpf_target_x86
+	#define bpf_target_defined
+#elif defined(__TARGET_ARCH_s930x)
+	#define bpf_target_s930x
+	#define bpf_target_defined
+#elif defined(__TARGET_ARCH_arm64)
+	#define bpf_target_arm64
+	#define bpf_target_defined
+#elif defined(__TARGET_ARCH_mips)
+	#define bpf_target_mips
+	#define bpf_target_defined
+#elif defined(__TARGET_ARCH_powerpc)
+	#define bpf_target_powerpc
+	#define bpf_target_defined
+#elif defined(__TARGET_ARCH_sparc)
+	#define bpf_target_sparc
+	#define bpf_target_defined
+#else
+	#undef bpf_target_defined
+#endif
+
+/* Fall back to what the compiler says */
+#ifndef bpf_target_defined
 #if defined(__x86_64__)
+	#define bpf_target_x86
+#elif defined(__s390x__)
+	#define bpf_target_s930x
+#elif defined(__aarch64__)
+	#define bpf_target_arm64
+#elif defined(__mips__)
+	#define bpf_target_mips
+#elif defined(__powerpc__)
+	#define bpf_target_powerpc
+#elif defined(__sparc__)
+	#define bpf_target_sparc
+#endif
+#endif
+
+#if defined(bpf_target_x86)
 
 #define PT_REGS_PARM1(x) ((x)->di)
 #define PT_REGS_PARM2(x) ((x)->si)
@@ -122,7 +162,7 @@ static int (*bpf_skb_change_head)(void *, int len, int flags) =
 #define PT_REGS_SP(x) ((x)->sp)
 #define PT_REGS_IP(x) ((x)->ip)
 
-#elif defined(__s390x__)
+#elif defined(bpf_target_s390x)
 
 #define PT_REGS_PARM1(x) ((x)->gprs[2])
 #define PT_REGS_PARM2(x) ((x)->gprs[3])
@@ -135,7 +175,7 @@ static int (*bpf_skb_change_head)(void *, int len, int flags) =
 #define PT_REGS_SP(x) ((x)->gprs[15])
 #define PT_REGS_IP(x) ((x)->psw.addr)
 
-#elif defined(__aarch64__)
+#elif defined(bpf_target_arm64)
 
 #define PT_REGS_PARM1(x) ((x)->regs[0])
 #define PT_REGS_PARM2(x) ((x)->regs[1])
@@ -148,7 +188,7 @@ static int (*bpf_skb_change_head)(void *, int len, int flags) =
 #define PT_REGS_SP(x) ((x)->sp)
 #define PT_REGS_IP(x) ((x)->pc)
 
-#elif defined(__mips__)
+#elif defined(bpf_target_mips)
 
 #define PT_REGS_PARM1(x) ((x)->regs[4])
 #define PT_REGS_PARM2(x) ((x)->regs[5])
@@ -161,7 +201,7 @@ static int (*bpf_skb_change_head)(void *, int len, int flags) =
 #define PT_REGS_SP(x) ((x)->regs[29])
 #define PT_REGS_IP(x) ((x)->cp0_epc)
 
-#elif defined(__powerpc__)
+#elif defined(bpf_target_powerpc)
 
 #define PT_REGS_PARM1(x) ((x)->gpr[3])
 #define PT_REGS_PARM2(x) ((x)->gpr[4])
@@ -172,7 +212,7 @@ static int (*bpf_skb_change_head)(void *, int len, int flags) =
 #define PT_REGS_SP(x) ((x)->sp)
 #define PT_REGS_IP(x) ((x)->nip)
 
-#elif defined(__sparc__)
+#elif defined(bpf_target_sparc)
 
 #define PT_REGS_PARM1(x) ((x)->u_regs[UREG_I0])
 #define PT_REGS_PARM2(x) ((x)->u_regs[UREG_I1])
@@ -182,6 +222,8 @@ static int (*bpf_skb_change_head)(void *, int len, int flags) =
 #define PT_REGS_RET(x) ((x)->u_regs[UREG_I7])
 #define PT_REGS_RC(x) ((x)->u_regs[UREG_I0])
 #define PT_REGS_SP(x) ((x)->u_regs[UREG_FP])
+
+/* Should this also be a bpf_target check for the sparc case? */
 #if defined(__arch64__)
 #define PT_REGS_IP(x) ((x)->tpc)
 #else
@@ -190,10 +232,10 @@ static int (*bpf_skb_change_head)(void *, int len, int flags) =
 
 #endif
 
-#ifdef __powerpc__
+#ifdef bpf_target_powerpc
 #define BPF_KPROBE_READ_RET_IP(ip, ctx)		({ (ip) = (ctx)->link; })
 #define BPF_KRETPROBE_READ_RET_IP		BPF_KPROBE_READ_RET_IP
-#elif defined(__sparc__)
+#elif bpf_target_sparc
 #define BPF_KPROBE_READ_RET_IP(ip, ctx)		({ (ip) = PT_REGS_RET(ctx); })
 #define BPF_KRETPROBE_READ_RET_IP		BPF_KPROBE_READ_RET_IP
 #else
-- 
2.14.1.821.g8fa685d3b7-goog
