From: David Daney <david.daney@cavium.com>
Subject: [PATCH v2 5/5] MIPS: BPF: Fix multiple problems in JIT skb access helpers.
Date: Tue, 14 Mar 2017 14:21:44 -0700
Message-ID: <20170314212144.29988-6-david.daney@cavium.com>
References: <20170314212144.29988-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
        "Steven J. Hill" <steven.hill@cavium.com>,
        David Daney <david.daney@cavium.com>
To: linux-mips@linux-mips.org, ralf@linux-mips.org,
        James Hogan <james.hogan@imgtec.com>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314212144.29988-1-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 o Socket data is unsigned, so use unsigned accessors instructions.

 o Fix path result pointer generation arithmetic.

 o Fix half-word byte swapping code for unsigned semantics.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 arch/mips/net/bpf_jit_asm.S | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/arch/mips/net/bpf_jit_asm.S b/arch/mips/net/bpf_jit_asm.S
index 5d2e0c8..88a2075 100644
--- a/arch/mips/net/bpf_jit_asm.S
+++ b/arch/mips/net/bpf_jit_asm.S
@@ -90,18 +90,14 @@ FEXPORT(sk_load_half_positive)
 	is_offset_in_header(2, half)
 	/* Offset within header boundaries */
 	PTR_ADDU t1, $r_skb_data, offset
-	.set	reorder
-	lh	$r_A, 0(t1)
-	.set	noreorder
+	lhu	$r_A, 0(t1)
 #ifdef CONFIG_CPU_LITTLE_ENDIAN
 # if defined(__mips_isa_rev) && (__mips_isa_rev >= 2)
-	wsbh	t0, $r_A
-	seh	$r_A, t0
+	wsbh	$r_A, $r_A
 # else
-	sll	t0, $r_A, 24
-	andi	t1, $r_A, 0xff00
-	sra	t0, t0, 16
-	srl	t1, t1, 8
+	sll	t0, $r_A, 8
+	srl	t1, $r_A, 8
+	andi	t0, t0, 0xff00
 	or	$r_A, t0, t1
 # endif
 #endif
@@ -115,7 +111,7 @@ FEXPORT(sk_load_byte_positive)
 	is_offset_in_header(1, byte)
 	/* Offset within header boundaries */
 	PTR_ADDU t1, $r_skb_data, offset
-	lb	$r_A, 0(t1)
+	lbu	$r_A, 0(t1)
 	jr	$r_ra
 	 move	$r_ret, zero
 	END(sk_load_byte)
@@ -139,6 +135,11 @@ FEXPORT(sk_load_byte_positive)
  * (void *to) is returned in r_s0
  *
  */
+#ifdef CONFIG_CPU_LITTLE_ENDIAN
+#define DS_OFFSET(SIZE) (4 * SZREG)
+#else
+#define DS_OFFSET(SIZE) ((4 * SZREG) + (4 - SIZE))
+#endif
 #define bpf_slow_path_common(SIZE)				\
 	/* Quick check. Are we within reasonable boundaries? */ \
 	LONG_ADDIU	$r_s1, $r_skb_len, -SIZE;		\
@@ -150,7 +151,7 @@ FEXPORT(sk_load_byte_positive)
 	PTR_LA		t0, skb_copy_bits;			\
 	PTR_S		$r_ra, (5 * SZREG)($r_sp);		\
 	/* Assign low slot to a2 */				\
-	move		a2, $r_sp;				\
+	PTR_ADDIU	a2, $r_sp, DS_OFFSET(SIZE);		\
 	jalr		t0;					\
 	/* Reset our destination slot (DS but it's ok) */	\
 	 INT_S		zero, (4 * SZREG)($r_sp);		\
-- 
2.9.3
