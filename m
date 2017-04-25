From: David Miller <davem@davemloft.net>
Subject: [PATCH net-next v2] sparc64: Improve 64-bit constant loading in
 eBPF JIT.
Date: Mon, 24 Apr 2017 23:38:49 -0400 (EDT)
Message-ID: <20170424.233849.243510333020799717.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sparclinux@vger.kernel.org, ast@fb.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <sparclinux-owner@vger.kernel.org>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Doing a full 64-bit decomposition is really stupid especially for
simple values like 0 and -1.

But if we are going to optimize this, go all the way and try for all 2
and 3 instruction sequences not requiring a temporary register as
well.

First we do the easy cases where it's a zero or sign extended 32-bit
number (sethi+or, sethi+xor, respectively).

Then we try to find a range of set bits we can load simply then shift
up into place, in various ways.

Then we try negating the constant and see if we can do a simple
sequence using that with a xor at the end.  (f.e. the range of set
bits can't be loaded simply, but for the negated value it can)

The final optimized strategy involves 4 instructions sequences not
needing a temporary register.

Otherwise we sadly fully decompose using a temp..

Example, from ALU64_XOR_K: 0x0000ffffffff0000 ^ 0x0 = 0x0000ffffffff0000:

0000000000000000 <foo>:
   0:   9d e3 bf 50     save  %sp, -176, %sp
   4:   01 00 00 00     nop
   8:   90 10 00 18     mov  %i0, %o0
   c:   13 3f ff ff     sethi  %hi(0xfffffc00), %o1
  10:   92 12 63 ff     or  %o1, 0x3ff, %o1     ! ffffffff <foo+0xffffffff>
  14:   93 2a 70 10     sllx  %o1, 0x10, %o1
  18:   15 3f ff ff     sethi  %hi(0xfffffc00), %o2
  1c:   94 12 a3 ff     or  %o2, 0x3ff, %o2     ! ffffffff <foo+0xffffffff>
  20:   95 2a b0 10     sllx  %o2, 0x10, %o2
  24:   92 1a 60 00     xor  %o1, 0, %o1
  28:   12 e2 40 8a     cxbe  %o1, %o2, 38 <foo+0x38>
  2c:   9a 10 20 02     mov  2, %o5
  30:   10 60 00 03     b,pn   %xcc, 3c <foo+0x3c>
  34:   01 00 00 00     nop
  38:   9a 10 20 01     mov  1, %o5     ! 1 <foo+0x1>
  3c:   81 c7 e0 08     ret
  40:   91 eb 40 00     restore  %o5, %g0, %o0

Signed-off-by: David S. Miller <davem@davemloft.net>
---

v2:
 - fix spaces (Alexei)
 - put details into commit msg (Alexei)

 arch/sparc/net/bpf_jit_comp_64.c | 249 ++++++++++++++++++++++++++++++++++++++-
 1 file changed, 245 insertions(+), 4 deletions(-)

diff --git a/arch/sparc/net/bpf_jit_comp_64.c b/arch/sparc/net/bpf_jit_comp_64.c
index 2b2f3c3..ec7d10d 100644
--- a/arch/sparc/net/bpf_jit_comp_64.c
+++ b/arch/sparc/net/bpf_jit_comp_64.c
@@ -28,6 +28,11 @@ static inline bool is_simm5(unsigned int value)
 	return value + 0x10 < 0x20;
 }
 
+static inline bool is_sethi(unsigned int value)
+{
+	return (value & ~0x3fffff) == 0;
+}
+
 static void bpf_flush_icache(void *start_, void *end_)
 {
 	/* Cheetah's I-cache is fully coherent.  */
@@ -367,16 +372,252 @@ static void emit_loadimm_sext(s32 K, unsigned int dest, struct jit_ctx *ctx)
 	}
 }
 
+static void analyze_64bit_constant(u32 high_bits, u32 low_bits,
+				   int *hbsp, int *lbsp, int *abbasp)
+{
+	int lowest_bit_set, highest_bit_set, all_bits_between_are_set;
+	int i;
+
+	lowest_bit_set = highest_bit_set = -1;
+	i = 0;
+	do {
+		if ((lowest_bit_set == -1) && ((low_bits >> i) & 1))
+			lowest_bit_set = i;
+		if ((highest_bit_set == -1) && ((high_bits >> (32 - i - 1)) & 1))
+			highest_bit_set = (64 - i - 1);
+	}  while (++i < 32 && (highest_bit_set == -1 ||
+			       lowest_bit_set == -1));
+	if (i == 32) {
+		i = 0;
+		do {
+			if (lowest_bit_set == -1 && ((high_bits >> i) & 1))
+				lowest_bit_set = i + 32;
+			if (highest_bit_set == -1 &&
+			    ((low_bits >> (32 - i - 1)) & 1))
+				highest_bit_set = 32 - i - 1;
+		} while (++i < 32 && (highest_bit_set == -1 ||
+				      lowest_bit_set == -1));
+	}
+
+	all_bits_between_are_set = 1;
+	for (i = lowest_bit_set; i <= highest_bit_set; i++) {
+		if (i < 32) {
+			if ((low_bits & (1 << i)) != 0)
+				continue;
+		} else {
+			if ((high_bits & (1 << (i - 32))) != 0)
+				continue;
+		}
+		all_bits_between_are_set = 0;
+		break;
+	}
+	*hbsp = highest_bit_set;
+	*lbsp = lowest_bit_set;
+	*abbasp = all_bits_between_are_set;
+}
+
+static unsigned long create_simple_focus_bits(unsigned long high_bits,
+					      unsigned long low_bits,
+					      int lowest_bit_set, int shift)
+{
+	long hi, lo;
+
+	if (lowest_bit_set < 32) {
+		lo = (low_bits >> lowest_bit_set) << shift;
+		hi = ((high_bits << (32 - lowest_bit_set)) << shift);
+	} else {
+		lo = 0;
+		hi = ((high_bits >> (lowest_bit_set - 32)) << shift);
+	}
+	return hi | lo;
+}
+
+static bool const64_is_2insns(unsigned long high_bits,
+			      unsigned long low_bits)
+{
+	int highest_bit_set, lowest_bit_set, all_bits_between_are_set;
+
+	if (high_bits == 0 || high_bits == 0xffffffff)
+		return true;
+
+	analyze_64bit_constant(high_bits, low_bits,
+			       &highest_bit_set, &lowest_bit_set,
+			       &all_bits_between_are_set);
+
+	if ((highest_bit_set == 63 || lowest_bit_set == 0) &&
+	    all_bits_between_are_set != 0)
+		return true;
+
+	if (highest_bit_set - lowest_bit_set < 21)
+		return true;
+
+	return false;
+}
+
+static void sparc_emit_set_const64_quick2(unsigned long high_bits,
+					  unsigned long low_imm,
+					  unsigned int dest,
+					  int shift_count, struct jit_ctx *ctx)
+{
+	emit_loadimm32(high_bits, dest, ctx);
+
+	/* Now shift it up into place.  */
+	emit_alu_K(SLLX, dest, shift_count, ctx);
+
+	/* If there is a low immediate part piece, finish up by
+	 * putting that in as well.
+	 */
+	if (low_imm != 0)
+		emit(OR | IMMED | RS1(dest) | S13(low_imm) | RD(dest), ctx);
+}
+
 static void emit_loadimm64(u64 K, unsigned int dest, struct jit_ctx *ctx)
 {
+	int all_bits_between_are_set, lowest_bit_set, highest_bit_set;
 	unsigned int tmp = bpf2sparc[TMP_REG_1];
-	u32 high_part = (K >> 32);
-	u32 low_part = (K & 0xffffffff);
+	u32 low_bits = (K & 0xffffffff);
+	u32 high_bits = (K >> 32);
+
+	/* These two tests also take care of all of the one
+	 * instruction cases.
+	 */
+	if (high_bits == 0xffffffff && (low_bits & 0x80000000))
+		return emit_loadimm_sext(K, dest, ctx);
+	if (high_bits == 0x00000000)
+		return emit_loadimm32(K, dest, ctx);
+
+	analyze_64bit_constant(high_bits, low_bits, &highest_bit_set,
+			       &lowest_bit_set, &all_bits_between_are_set);
+
+	/* 1) mov	-1, %reg
+	 *    sllx	%reg, shift, %reg
+	 * 2) mov	-1, %reg
+	 *    srlx	%reg, shift, %reg
+	 * 3) mov	some_small_const, %reg
+	 *    sllx	%reg, shift, %reg
+	 */
+	if (((highest_bit_set == 63 || lowest_bit_set == 0) &&
+	     all_bits_between_are_set != 0) ||
+	    ((highest_bit_set - lowest_bit_set) < 12)) {
+		int shift = lowest_bit_set;
+		long the_const = -1;
+
+		if ((highest_bit_set != 63 && lowest_bit_set != 0) ||
+		    all_bits_between_are_set == 0) {
+			the_const =
+				create_simple_focus_bits(high_bits, low_bits,
+							 lowest_bit_set, 0);
+		} else if (lowest_bit_set == 0)
+			shift = -(63 - highest_bit_set);
+
+		emit(OR | IMMED | RS1(G0) | S13(the_const) | RD(dest), ctx);
+		if (shift > 0)
+			emit_alu_K(SLLX, dest, shift, ctx);
+		else if (shift < 0)
+			emit_alu_K(SRLX, dest, -shift, ctx);
+
+		return;
+	}
+
+	/* Now a range of 22 or less bits set somewhere.
+	 * 1) sethi	%hi(focus_bits), %reg
+	 *    sllx	%reg, shift, %reg
+	 * 2) sethi	%hi(focus_bits), %reg
+	 *    srlx	%reg, shift, %reg
+	 */
+	if ((highest_bit_set - lowest_bit_set) < 21) {
+		unsigned long focus_bits =
+			create_simple_focus_bits(high_bits, low_bits,
+						 lowest_bit_set, 10);
+
+		emit(SETHI(focus_bits, dest), ctx);
+
+		/* If lowest_bit_set == 10 then a sethi alone could
+		 * have done it.
+		 */
+		if (lowest_bit_set < 10)
+			emit_alu_K(SRLX, dest, 10 - lowest_bit_set, ctx);
+		else if (lowest_bit_set > 10)
+			emit_alu_K(SLLX, dest, lowest_bit_set - 10, ctx);
+		return;
+	}
+
+	/* Ok, now 3 instruction sequences.  */
+	if (low_bits == 0) {
+		emit_loadimm32(high_bits, dest, ctx);
+		emit_alu_K(SLLX, dest, 32, ctx);
+		return;
+	}
+
+	/* We may be able to do something quick
+	 * when the constant is negated, so try that.
+	 */
+	if (const64_is_2insns((~high_bits) & 0xffffffff,
+			      (~low_bits) & 0xfffffc00)) {
+		/* NOTE: The trailing bits get XOR'd so we need the
+		 * non-negated bits, not the negated ones.
+		 */
+		unsigned long trailing_bits = low_bits & 0x3ff;
+
+		if ((((~high_bits) & 0xffffffff) == 0 &&
+		     ((~low_bits) & 0x80000000) == 0) ||
+		    (((~high_bits) & 0xffffffff) == 0xffffffff &&
+		     ((~low_bits) & 0x80000000) != 0)) {
+			unsigned long fast_int = (~low_bits & 0xffffffff);
+
+			if ((is_sethi(fast_int) &&
+			     (~high_bits & 0xffffffff) == 0)) {
+				emit(SETHI(fast_int, dest), ctx);
+			} else if (is_simm13(fast_int)) {
+				emit(OR | IMMED | RS1(G0) | S13(fast_int) | RD(dest), ctx);
+			} else {
+				emit_loadimm64(fast_int, dest, ctx);
+			}
+		} else {
+			u64 n = ((~low_bits) & 0xfffffc00) |
+				(((unsigned long)((~high_bits) & 0xffffffff))<<32);
+			emit_loadimm64(n, dest, ctx);
+		}
+
+		low_bits = -0x400 | trailing_bits;
+
+		emit(XOR | IMMED | RS1(dest) | S13(low_bits) | RD(dest), ctx);
+		return;
+	}
+
+	/* 1) sethi	%hi(xxx), %reg
+	 *    or	%reg, %lo(xxx), %reg
+	 *    sllx	%reg, yyy, %reg
+	 */
+	if ((highest_bit_set - lowest_bit_set) < 32) {
+		unsigned long focus_bits =
+			create_simple_focus_bits(high_bits, low_bits,
+						 lowest_bit_set, 0);
+
+		/* So what we know is that the set bits straddle the
+		 * middle of the 64-bit word.
+		 */
+		sparc_emit_set_const64_quick2(focus_bits, 0, dest,
+					      lowest_bit_set, ctx);
+		return;
+	}
+
+	/* 1) sethi	%hi(high_bits), %reg
+	 *    or	%reg, %lo(high_bits), %reg
+	 *    sllx	%reg, 32, %reg
+	 *    or	%reg, low_bits, %reg
+	 */
+	if (is_simm13(low_bits) && ((int)low_bits > 0)) {
+		sparc_emit_set_const64_quick2(high_bits, low_bits,
+					      dest, 32, ctx);
+		return;
+	}
 
+	/* Oh well, we tried... Do a full 64-bit decomposition.  */
 	ctx->tmp_1_used = true;
 
-	emit_set_const(high_part, tmp, ctx);
-	emit_set_const(low_part, dest, ctx);
+	emit_loadimm32(high_bits, tmp, ctx);
+	emit_loadimm32(low_bits, dest, ctx);
 	emit_alu_K(SLLX, tmp, 32, ctx);
 	emit(OR | RS1(dest) | RS2(tmp) | RD(dest), ctx);
 }
-- 
2.1.2.532.g19b5d50

