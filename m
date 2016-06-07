From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: [PATCH 4/6] ppc: bpf/jit: A few cleanups
Date: Tue,  7 Jun 2016 19:02:21 +0530
Message-ID: <eb61773bf6fe65c5e0715f51fe47927581e88461.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
References: <cover.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
Cc: Matt Evans <matt@ozlabs.org>,
	Denis Kirjanov <kda@linux-powerpc.org>,
	Paul Mackerras <paulus@samba.org>,
	Alexei Starovoitov <ast@fb.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>
To: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, mpe@ellerman.id.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
In-Reply-To: <cover.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
References: <cover.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1. Per the ISA, ADDIS actually uses RT, rather than RS. Though
the result is the same, make the usage clear.
2. The multiply instruction used is a 32-bit multiply. Rename PPC_MUL()
to PPC_MULW() to make the same clear.
3. PPC_STW[U] take the entire 16-bit immediate value and do not require
word-alignment, per the ISA. Change the macros to use IMM_L().
4. A few white-space cleanups to satisfy checkpatch.pl.

Cc: Matt Evans <matt@ozlabs.org>
Cc: Denis Kirjanov <kda@linux-powerpc.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
---
 arch/powerpc/net/bpf_jit.h      | 13 +++++++------
 arch/powerpc/net/bpf_jit_comp.c |  8 ++++----
 2 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/arch/powerpc/net/bpf_jit.h b/arch/powerpc/net/bpf_jit.h
index 95d0e38..9041d3f 100644
--- a/arch/powerpc/net/bpf_jit.h
+++ b/arch/powerpc/net/bpf_jit.h
@@ -83,7 +83,7 @@ DECLARE_LOAD_FUNC(sk_load_byte_msh);
  */
 #define IMM_H(i)		((uintptr_t)(i)>>16)
 #define IMM_HA(i)		(((uintptr_t)(i)>>16) +			      \
-				 (((uintptr_t)(i) & 0x8000) >> 15))
+					(((uintptr_t)(i) & 0x8000) >> 15))
 #define IMM_L(i)		((uintptr_t)(i) & 0xffff)
 
 #define PLANT_INSTR(d, idx, instr)					      \
@@ -99,16 +99,16 @@ DECLARE_LOAD_FUNC(sk_load_byte_msh);
 #define PPC_MR(d, a)		PPC_OR(d, a, a)
 #define PPC_LI(r, i)		PPC_ADDI(r, 0, i)
 #define PPC_ADDIS(d, a, i)	EMIT(PPC_INST_ADDIS |			      \
-				     ___PPC_RS(d) | ___PPC_RA(a) | IMM_L(i))
+				     ___PPC_RT(d) | ___PPC_RA(a) | IMM_L(i))
 #define PPC_LIS(r, i)		PPC_ADDIS(r, 0, i)
 #define PPC_STD(r, base, i)	EMIT(PPC_INST_STD | ___PPC_RS(r) |	      \
 				     ___PPC_RA(base) | ((i) & 0xfffc))
 #define PPC_STDU(r, base, i)	EMIT(PPC_INST_STDU | ___PPC_RS(r) |	      \
 				     ___PPC_RA(base) | ((i) & 0xfffc))
 #define PPC_STW(r, base, i)	EMIT(PPC_INST_STW | ___PPC_RS(r) |	      \
-				     ___PPC_RA(base) | ((i) & 0xfffc))
+				     ___PPC_RA(base) | IMM_L(i))
 #define PPC_STWU(r, base, i)	EMIT(PPC_INST_STWU | ___PPC_RS(r) |	      \
-				     ___PPC_RA(base) | ((i) & 0xfffc))
+				     ___PPC_RA(base) | IMM_L(i))
 
 #define PPC_LBZ(r, base, i)	EMIT(PPC_INST_LBZ | ___PPC_RT(r) |	      \
 				     ___PPC_RA(base) | IMM_L(i))
@@ -174,13 +174,14 @@ DECLARE_LOAD_FUNC(sk_load_byte_msh);
 #define PPC_CMPWI(a, i)		EMIT(PPC_INST_CMPWI | ___PPC_RA(a) | IMM_L(i))
 #define PPC_CMPDI(a, i)		EMIT(PPC_INST_CMPDI | ___PPC_RA(a) | IMM_L(i))
 #define PPC_CMPLWI(a, i)	EMIT(PPC_INST_CMPLWI | ___PPC_RA(a) | IMM_L(i))
-#define PPC_CMPLW(a, b)		EMIT(PPC_INST_CMPLW | ___PPC_RA(a) | ___PPC_RB(b))
+#define PPC_CMPLW(a, b)		EMIT(PPC_INST_CMPLW | ___PPC_RA(a) |	      \
+					___PPC_RB(b))
 
 #define PPC_SUB(d, a, b)	EMIT(PPC_INST_SUB | ___PPC_RT(d) |	      \
 				     ___PPC_RB(a) | ___PPC_RA(b))
 #define PPC_ADD(d, a, b)	EMIT(PPC_INST_ADD | ___PPC_RT(d) |	      \
 				     ___PPC_RA(a) | ___PPC_RB(b))
-#define PPC_MUL(d, a, b)	EMIT(PPC_INST_MULLW | ___PPC_RT(d) |	      \
+#define PPC_MULW(d, a, b)	EMIT(PPC_INST_MULLW | ___PPC_RT(d) |	      \
 				     ___PPC_RA(a) | ___PPC_RB(b))
 #define PPC_MULHWU(d, a, b)	EMIT(PPC_INST_MULHWU | ___PPC_RT(d) |	      \
 				     ___PPC_RA(a) | ___PPC_RB(b))
diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index 2d66a84..6012aac 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -161,14 +161,14 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 			break;
 		case BPF_ALU | BPF_MUL | BPF_X: /* A *= X; */
 			ctx->seen |= SEEN_XREG;
-			PPC_MUL(r_A, r_A, r_X);
+			PPC_MULW(r_A, r_A, r_X);
 			break;
 		case BPF_ALU | BPF_MUL | BPF_K: /* A *= K */
 			if (K < 32768)
 				PPC_MULI(r_A, r_A, K);
 			else {
 				PPC_LI32(r_scratch1, K);
-				PPC_MUL(r_A, r_A, r_scratch1);
+				PPC_MULW(r_A, r_A, r_scratch1);
 			}
 			break;
 		case BPF_ALU | BPF_MOD | BPF_X: /* A %= X; */
@@ -184,7 +184,7 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 			}
 			if (code == (BPF_ALU | BPF_MOD | BPF_X)) {
 				PPC_DIVWU(r_scratch1, r_A, r_X);
-				PPC_MUL(r_scratch1, r_X, r_scratch1);
+				PPC_MULW(r_scratch1, r_X, r_scratch1);
 				PPC_SUB(r_A, r_A, r_scratch1);
 			} else {
 				PPC_DIVWU(r_A, r_A, r_X);
@@ -193,7 +193,7 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 		case BPF_ALU | BPF_MOD | BPF_K: /* A %= K; */
 			PPC_LI32(r_scratch2, K);
 			PPC_DIVWU(r_scratch1, r_A, r_scratch2);
-			PPC_MUL(r_scratch1, r_scratch2, r_scratch1);
+			PPC_MULW(r_scratch1, r_scratch2, r_scratch1);
 			PPC_SUB(r_A, r_A, r_scratch1);
 			break;
 		case BPF_ALU | BPF_DIV | BPF_K: /* A /= K */
-- 
2.8.2
