From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v2] net: bpf: arm: make hole-faulting more robust
Date: Fri, 19 Sep 2014 14:56:57 +0200
Message-ID: <1411131417-23667-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Russell King <linux@arm.linux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mircea Gherzan <mgherzan@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26314 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751829AbaISM5k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2014 08:57:40 -0400
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

We therefore should use a more robust opcode that fits both. Russell King
suggested that we can even reuse a single 32-bit word, that is, 0xe7fddef1
which will fault if executed in ARM *or* Thumb mode as done in f928d4f2a86f
("ARM: poison the vectors page"). That will still hold our requirements:

  $ echo 0xf1defde7 | xxd -r > test.bin
  $ arm-unknown-linux-gnueabi-objdump -m arm -D -b binary test.bin
  ...
  0: e7fddef1     udf    #56801 ; 0xdde1
  $ echo 0xf1defde7f1defde7f1defde7 | xxd -r > test.bin
  $ arm-unknown-linux-gnueabi-objdump -marm -Mforce-thumb -D -b binary test.bin
  ...
  0: def1         udf    #241 ; 0xf1
  2: e7fd         b.n    0x0
  4: def1         udf    #241 ; 0xf1
  6: e7fd         b.n    0x4
  8: def1         udf    #241 ; 0xf1
  a: e7fd         b.n    0x8

So on ARM 0xe7fddef1 conforms to the above UDF pattern, and the low 16 bit
likewise correspond to UDF in Thumb case. The 0xe7fd part is an unconditional
branch back to the UDF instruction.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Mircea Gherzan <mgherzan@gmail.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
---
 v1->v2:
  - Use single word version instead of separately handling ARM and Thumb

 arch/arm/net/bpf_jit_32.c |  6 +++---
 arch/arm/net/bpf_jit_32.h | 14 ++++++++++++++
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index 6b45f64..e1268f9 100644
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
@@ -175,11 +176,10 @@ static inline bool is_load_to_a(u16 inst)
 
 static void jit_fill_hole(void *area, unsigned int size)
 {
-	/* Insert illegal UND instructions. */
-	u32 *ptr, fill_ins = 0xe7ffffff;
+	u32 *ptr;
 	/* We are guaranteed to have aligned memory. */
 	for (ptr = area; size >= sizeof(u32); size -= sizeof(u32))
-		*ptr++ = fill_ins;
+		*ptr++ = __opcode_to_mem_arm(ARM_INST_UDF);
 }
 
 static void build_prologue(struct jit_ctx *ctx)
diff --git a/arch/arm/net/bpf_jit_32.h b/arch/arm/net/bpf_jit_32.h
index afb8462..b2d7d92 100644
--- a/arch/arm/net/bpf_jit_32.h
+++ b/arch/arm/net/bpf_jit_32.h
@@ -114,6 +114,20 @@
 
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
+#define ARM_INST_UDF		0xe7fddef1
+
 /* register */
 #define _AL3_R(op, rd, rn, rm)	((op ## _R) | (rd) << 12 | (rn) << 16 | (rm))
 /* immediate */
-- 
1.7.11.7
