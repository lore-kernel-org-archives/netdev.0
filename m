From: Joel Fernandes <joelaf@google.com>
Subject: [PATCH RFC 4/5] samples/bpf: Fix pt_regs issues when cross-compiling
Date: Mon,  7 Aug 2017 06:03:05 -0700
Message-ID: <20170807130306.31530-5-joelaf@google.com>
References: <20170807130306.31530-1-joelaf@google.com>
Cc: Chenbo Feng <fengc@google.com>,
        Alison Chaiken <alison@she-devel.com>,
        Juri Lelli <jlelli@google.com>,
        Joel Fernandes <joelaf@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        netdev@vger.kernel.org (open list:BPF (Safe dynamic programs and tools))
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170807130306.31530-1-joelaf@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

BPF samples fail to build when cross-compiling for ARM64 because of incorrect
pt_regs param selection. This is because clang defines __x86_64__ and
bpf_headers thinks we're building for x86. Since clang is building for the BPF
target, it shouldn't make assumptions about what target the BPF program is
going to run on. To fix this, lets pass ARCH so the header knows which target
the BPF program is being compiled for and can use the correct pt_regs code.

Signed-off-by: Joel Fernandes <joelaf@google.com>
---
 samples/bpf/Makefile      |  2 +-
 samples/bpf/bpf_helpers.h | 49 +++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 44 insertions(+), 7 deletions(-)

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 7591cdd7fe69..8cbcaffe4001 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -199,7 +199,7 @@ ASM_STUBS := ${ARCH_ASM_STUBS} -include $(src)/generic_asmstubs.h
 
 CLANG_ARGS = $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
 		-D__KERNEL__ -Wno-unused-value -Wno-pointer-sign \
-		$(ASM_STUBS) \
+		-D__TARGET_ARCH_$(ARCH) $(ASM_STUBS) \
 		-Wno-compare-distinct-pointer-types \
 		-Wno-gnu-variable-sized-type-not-at-end \
 		-Wno-address-of-packed-member -Wno-tautological-compare \
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 67c9c4438e4b..199d2e32703a 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -96,7 +96,42 @@ static int (*bpf_skb_under_cgroup)(void *ctx, void *map, int index) =
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
@@ -109,7 +144,7 @@ static int (*bpf_skb_change_head)(void *, int len, int flags) =
 #define PT_REGS_SP(x) ((x)->sp)
 #define PT_REGS_IP(x) ((x)->ip)
 
-#elif defined(__s390x__)
+#elif defined(bpf_target_s390x)
 
 #define PT_REGS_PARM1(x) ((x)->gprs[2])
 #define PT_REGS_PARM2(x) ((x)->gprs[3])
@@ -122,7 +157,7 @@ static int (*bpf_skb_change_head)(void *, int len, int flags) =
 #define PT_REGS_SP(x) ((x)->gprs[15])
 #define PT_REGS_IP(x) ((x)->psw.addr)
 
-#elif defined(__aarch64__)
+#elif defined(bpf_target_arm64)
 
 #define PT_REGS_PARM1(x) ((x)->regs[0])
 #define PT_REGS_PARM2(x) ((x)->regs[1])
@@ -135,7 +170,7 @@ static int (*bpf_skb_change_head)(void *, int len, int flags) =
 #define PT_REGS_SP(x) ((x)->sp)
 #define PT_REGS_IP(x) ((x)->pc)
 
-#elif defined(__powerpc__)
+#elif defined(bpf_target_powerpc)
 
 #define PT_REGS_PARM1(x) ((x)->gpr[3])
 #define PT_REGS_PARM2(x) ((x)->gpr[4])
@@ -146,7 +181,7 @@ static int (*bpf_skb_change_head)(void *, int len, int flags) =
 #define PT_REGS_SP(x) ((x)->sp)
 #define PT_REGS_IP(x) ((x)->nip)
 
-#elif defined(__sparc__)
+#elif defined(bpf_target_sparc)
 
 #define PT_REGS_PARM1(x) ((x)->u_regs[UREG_I0])
 #define PT_REGS_PARM2(x) ((x)->u_regs[UREG_I1])
@@ -156,6 +191,8 @@ static int (*bpf_skb_change_head)(void *, int len, int flags) =
 #define PT_REGS_RET(x) ((x)->u_regs[UREG_I7])
 #define PT_REGS_RC(x) ((x)->u_regs[UREG_I0])
 #define PT_REGS_SP(x) ((x)->u_regs[UREG_FP])
+
+/* Should this also be a bpf_target check for the sparc case? */
 #if defined(__arch64__)
 #define PT_REGS_IP(x) ((x)->tpc)
 #else
@@ -164,10 +201,10 @@ static int (*bpf_skb_change_head)(void *, int len, int flags) =
 
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
2.14.0.rc1.383.gd1ce394fe2-goog
