From: Joel Fernandes <joelaf@google.com>
Subject: [PATCH RFC 3/5] samples/bpf: Fix inline asm issues building samples on arm64
Date: Mon,  7 Aug 2017 06:03:04 -0700
Message-ID: <20170807130306.31530-4-joelaf@google.com>
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

inline assembly has haunted building samples on arm64 for quite sometime.
This patch uses the pre-processor to noop all occurences of inline asm when
compiling the BPF sample for the BPF target.

This patch reintroduces inclusion of asm/sysregs.h which needs to be included
to avoid compiler errors now, see [1]. Previously a hack prevented this
inclusion [2] (to avoid the exact problem this patch fixes - skipping inline
assembler) but the hack causes other errors now and no longer works.

Using the preprocessor to noop the inline asm occurences, we also avoid
any future unstable hackery needed (such as those that skip asm headers)
and provides information that asm headers may have which could have been
used but which the inline asm issues prevented. This is the least messy
of all hacks in my opinion.

[1] https://lkml.org/lkml/2017/8/5/143
[2] https://lists.linaro.org/pipermail/linaro-kernel/2015-November/024036.html

Signed-off-by: Joel Fernandes <joelaf@google.com>
---
 samples/bpf/Makefile           | 40 +++++++++++++++++++++++++++++++++-------
 samples/bpf/arm64_asmstubs.h   |  3 +++
 samples/bpf/bpf_helpers.h      | 12 ++++++------
 samples/bpf/generic_asmstubs.h |  4 ++++
 4 files changed, 46 insertions(+), 13 deletions(-)
 create mode 100644 samples/bpf/arm64_asmstubs.h
 create mode 100644 samples/bpf/generic_asmstubs.h

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index e5642c8c144d..7591cdd7fe69 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -151,6 +151,8 @@ HOSTLOADLIBES_test_map_in_map += -lelf
 #  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
 LLC ?= llc
 CLANG ?= clang
+PERL ?= perl
+RM ?= rm
 
 # Detect that we're cross compiling and use the right compilers and flags
 ifdef CROSS_COMPILE
@@ -186,14 +188,38 @@ verify_target_bpf: verify_cmds
 
 $(src)/*.c: verify_target_bpf
 
-# asm/sysreg.h - inline assembly used by it is incompatible with llvm.
-# But, there is no easy way to fix it, so just exclude it since it is
-# useless for BPF samples.
-$(obj)/%.o: $(src)/%.c
-	$(CLANG) $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
-		-D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
+curdir := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
+ifeq ($(wildcard  $(curdir)/${ARCH}_asmstubs.h),)
+    ARCH_ASM_STUBS :=
+else
+    ARCH_ASM_STUBS := -include $(src)/${ARCH}_asmstubs.h
+endif
+
+ASM_STUBS := ${ARCH_ASM_STUBS} -include $(src)/generic_asmstubs.h
+
+CLANG_ARGS = $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
+		-D__KERNEL__ -Wno-unused-value -Wno-pointer-sign \
+		$(ASM_STUBS) \
 		-Wno-compare-distinct-pointer-types \
 		-Wno-gnu-variable-sized-type-not-at-end \
 		-Wno-address-of-packed-member -Wno-tautological-compare \
 		-Wno-unknown-warning-option \
-		-O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
+		-O2 -emit-llvm
+
+$(obj)/%.o: $(src)/%.c
+	# Steps to compile BPF sample while getting rid of inline asm
+	# This has the advantage of not having to skip important asm headers
+	# Step 1. Use clang preprocessor to stub out asm() calls
+	# Step 2. Replace all "asm volatile" with single keyword "asmvolatile"
+	# Step 3. Use clang preprocessor to noop all asm volatile() calls
+	#         and restore asm_bpf to asm for BPF's asm directives
+	# Step 4. Compile and link
+
+	$(CLANG) -E $(CLANG_ARGS) -c $< -o - | \
+	$(PERL) -pe "s/[_\s]*asm[_\s]*volatile[_\s]*/asmvolatile/g" | \
+	$(CLANG) -E $(ASM_STUBS) - -o - | \
+	$(CLANG) -E -Dasm_bpf=asm - -o $@.tmp.c
+
+	$(CLANG) $(CLANG_ARGS) -c $@.tmp.c \
+		-o - | $(LLC) -march=bpf -filetype=obj -o $@
+	$(RM) $@.tmp.c
diff --git a/samples/bpf/arm64_asmstubs.h b/samples/bpf/arm64_asmstubs.h
new file mode 100644
index 000000000000..23d47dbe61b1
--- /dev/null
+++ b/samples/bpf/arm64_asmstubs.h
@@ -0,0 +1,3 @@
+/* Special handing for current_stack_pointer */
+#define __ASM_STACK_POINTER_H
+#define current_stack_pointer 0
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 9a9c95f2c9fb..67c9c4438e4b 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -64,12 +64,12 @@ static int (*bpf_xdp_adjust_head)(void *ctx, int offset) =
  * emit BPF_LD_ABS and BPF_LD_IND instructions
  */
 struct sk_buff;
-unsigned long long load_byte(void *skb,
-			     unsigned long long off) asm("llvm.bpf.load.byte");
-unsigned long long load_half(void *skb,
-			     unsigned long long off) asm("llvm.bpf.load.half");
-unsigned long long load_word(void *skb,
-			     unsigned long long off) asm("llvm.bpf.load.word");
+unsigned long long load_byte(void *skb, unsigned long long off)
+			     asm_bpf("llvm.bpf.load.byte");
+unsigned long long load_half(void *skb, unsigned long long off)
+			     asm_bpf("llvm.bpf.load.half");
+unsigned long long load_word(void *skb, unsigned long long off)
+			     asm_bpf("llvm.bpf.load.word");
 
 /* a helper structure used by eBPF C program
  * to describe map attributes to elf_bpf loader
diff --git a/samples/bpf/generic_asmstubs.h b/samples/bpf/generic_asmstubs.h
new file mode 100644
index 000000000000..1b9e9f5094d8
--- /dev/null
+++ b/samples/bpf/generic_asmstubs.h
@@ -0,0 +1,4 @@
+#define bpf_noop_stub
+#define asm(...) bpf_noop_stub
+#define __asm__(...) bpf_noop_stub
+#define asmvolatile(...) bpf_noop_stub
-- 
2.14.0.rc1.383.gd1ce394fe2-goog
