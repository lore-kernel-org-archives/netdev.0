From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: bpf: arm: make hole-faulting more robust
Date: Fri, 19 Sep 2014 00:57:03 +0200
Message-ID: <1411081023-17874-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mircea Gherzan <mgherzan@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29236 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932071AbaIRW5h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 18:57:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Will Deacon pointed out, that the currently used opcode for filling holes,
that is 0xe7ffffff, seems not robust enough ...

  $ echo 0xffffffe7 | xxd -r > test.bin
  $ arm-linux-gnueabihf-objdump -m arm -D -b binary test.bin
  ...
  0: e7ffffff     udf    #65535  ; 0xffff

... while for Thumb, it ends up as ...

  0: ffff e7ff    vqshl.u64  q15, <illegal reg q15.5>, #63

... which is a bit fragile. The ARM specification defines some *permanently*
guaranteed undefined instruction (UDF) space, for example for ARM in ARMv7-AR,
section A5.4 and for Thumb in ARMv7-M, section A5.2.6.

Similarly, ptrace, kprobes, kgdb, bug and uprobes make use of such instruction
as well to trap. Given mentioned section from the specification, we can find
such a universe as (where 'x' denotes 'don't care'):

  ARM:    xxxx 0111 1111 xxxx xxxx xxxx 1111 xxxx
  Thumb:  1101 1110 xxxx xxxx

We therefore can use a more robust and so far unallocated pair of opcodes
for ARM: 0xe7f002f0 and Thumb: 0xde03. Moreover, when filling we should also
use proper macros __opcode_to_mem_arm() and __opcode_to_mem_thumb16().

New dump:

  $ echo 0xf002f0e7 | xxd -r > test.bin
  $ arm-unknown-linux-gnueabi-objdump -m arm -D -b binary test.bin
  ...
  0: e7f002f0     udf    #32
  $ echo 0x03de | xxd -r > test.bin
  $ arm-unknown-linux-gnueabi-objdump -marm -Mforce-thumb -D -b binary test.bin
  ...
  0: de03         udf    #3

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Mircea Gherzan <mgherzan@gmail.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
---
 arch/arm/net/bpf_jit_32.c | 22 ++++++++++++++++++----
 arch/arm/net/bpf_jit_32.h | 15 +++++++++++++++
 2 files changed, 33 insertions(+), 4 deletions(-)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index 6b45f64..3b71b68 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -16,6 +16,7 @@
 #include <linux/string.h>
 #include <linux/slab.h>
 #include <linux/if_vlan.h>
+
 #include <asm/cacheflush.h>
 #include <asm/hwcap.h>
 #include <asm/opcodes.h>
@@ -173,13 +174,26 @@ static inline bool is_load_to_a(u16 inst)
 	}
 }
 
+static void __jit_fill_hole_arm(u32 *ptr, unsigned int bytes)
+{
+	for (; bytes >= sizeof(u32); bytes -= sizeof(u32))
+		*ptr++ = __opcode_to_mem_arm(ARM_INST_UDF);
+}
+
+static void __jit_fill_hole_thumb2(u16 *ptr, unsigned int bytes)
+{
+	for (; bytes >= sizeof(u16); bytes -= sizeof(u16))
+		*ptr++ = __opcode_to_mem_thumb16(THUMB2_INST_UDF);
+}
+
 static void jit_fill_hole(void *area, unsigned int size)
 {
-	/* Insert illegal UND instructions. */
-	u32 *ptr, fill_ins = 0xe7ffffff;
+	const bool thumb2 = IS_ENABLED(CONFIG_THUMB2_KERNEL);
 	/* We are guaranteed to have aligned memory. */
-	for (ptr = area; size >= sizeof(u32); size -= sizeof(u32))
-		*ptr++ = fill_ins;
+	if (thumb2)
+		__jit_fill_hole_thumb2(area, size);
+	else
+		__jit_fill_hole_arm(area, size);
 }
 
 static void build_prologue(struct jit_ctx *ctx)
diff --git a/arch/arm/net/bpf_jit_32.h b/arch/arm/net/bpf_jit_32.h
index afb8462..4982db8 100644
--- a/arch/arm/net/bpf_jit_32.h
+++ b/arch/arm/net/bpf_jit_32.h
@@ -114,6 +114,21 @@
 
 #define ARM_INST_UMULL		0x00800090
 
+/*
+ * Use a suitable undefined instruction to use for ARM/Thumb2 faulting.
+ * We need to be careful not to conflict with those used by other modules
+ * (BUG, kprobes, etc) and the register_undef_hook() system.
+ *
+ * The ARM architecture reference manual guarantees that the following
+ * instruction space will produce an undefined instruction exception on
+ * all CPUs:
+ *
+ * ARM:   xxxx 0111 1111 xxxx xxxx xxxx 1111 xxxx	ARMv7-AR, section A5.4
+ * Thumb: 1101 1110 xxxx xxxx				ARMv7-M, section A5.2.6
+ */
+#define ARM_INST_UDF		0xe7f002f0
+#define THUMB2_INST_UDF		0xde03
+
 /* register */
 #define _AL3_R(op, rd, rn, rm)	((op ## _R) | (rd) << 12 | (rn) << 16 | (rm))
 /* immediate */
-- 
1.9.3
