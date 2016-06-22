From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: [PATCHv2 4/7] ppc: bpf/jit: Introduce rotate immediate instructions
Date: Wed, 22 Jun 2016 21:55:04 +0530
Message-ID: <8264e2692c8d0b2a019827e052cdda29c4ec2fbc.1466612260.git.naveen.n.rao@linux.vnet.ibm.com>
References: <cover.1466612260.git.naveen.n.rao@linux.vnet.ibm.com>
Cc: Matt Evans <matt@ozlabs.org>,
	Denis Kirjanov <kda@linux-powerpc.org>,
	Paul Mackerras <paulus@samba.org>,
	Alexei Starovoitov <ast@fb.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>,
	Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
To: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1466612260.git.naveen.n.rao@linux.vnet.ibm.com>
In-Reply-To: <cover.1466612260.git.naveen.n.rao@linux.vnet.ibm.com>
References: <cover.1466612260.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since we will be using the rotate immediate instructions for extended
BPF JIT, let's introduce macros for the same. And since the shift
immediate operations use the rotate immediate instructions, let's redo
those macros to use the newly introduced instructions.

Cc: Matt Evans <matt@ozlabs.org>
Cc: Denis Kirjanov <kda@linux-powerpc.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Cc: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/ppc-opcode.h |  2 ++
 arch/powerpc/net/bpf_jit.h            | 20 +++++++++++---------
 2 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/arch/powerpc/include/asm/ppc-opcode.h b/arch/powerpc/include/asm/ppc-opcode.h
index 1d035c1..fd8d640 100644
--- a/arch/powerpc/include/asm/ppc-opcode.h
+++ b/arch/powerpc/include/asm/ppc-opcode.h
@@ -272,6 +272,8 @@
 #define __PPC_SH(s)	__PPC_WS(s)
 #define __PPC_MB(s)	(((s) & 0x1f) << 6)
 #define __PPC_ME(s)	(((s) & 0x1f) << 1)
+#define __PPC_MB64(s)	(__PPC_MB(s) | ((s) & 0x20))
+#define __PPC_ME64(s)	__PPC_MB64(s)
 #define __PPC_BI(s)	(((s) & 0x1f) << 16)
 #define __PPC_CT(t)	(((t) & 0x0f) << 21)
 
diff --git a/arch/powerpc/net/bpf_jit.h b/arch/powerpc/net/bpf_jit.h
index 4c1e055..95d0e38 100644
--- a/arch/powerpc/net/bpf_jit.h
+++ b/arch/powerpc/net/bpf_jit.h
@@ -210,18 +210,20 @@ DECLARE_LOAD_FUNC(sk_load_byte_msh);
 				     ___PPC_RS(a) | ___PPC_RB(s))
 #define PPC_SRW(d, a, s)	EMIT(PPC_INST_SRW | ___PPC_RA(d) |	      \
 				     ___PPC_RS(a) | ___PPC_RB(s))
+#define PPC_RLWINM(d, a, i, mb, me)	EMIT(PPC_INST_RLWINM | ___PPC_RA(d) | \
+					___PPC_RS(a) | __PPC_SH(i) |	      \
+					__PPC_MB(mb) | __PPC_ME(me))
+#define PPC_RLDICR(d, a, i, me)		EMIT(PPC_INST_RLDICR | ___PPC_RA(d) | \
+					___PPC_RS(a) | __PPC_SH(i) |	      \
+					__PPC_ME64(me) | (((i) & 0x20) >> 4))
+
 /* slwi = rlwinm Rx, Ry, n, 0, 31-n */
-#define PPC_SLWI(d, a, i)	EMIT(PPC_INST_RLWINM | ___PPC_RA(d) |	      \
-				     ___PPC_RS(a) | __PPC_SH(i) |	      \
-				     __PPC_MB(0) | __PPC_ME(31-(i)))
+#define PPC_SLWI(d, a, i)	PPC_RLWINM(d, a, i, 0, 31-(i))
 /* srwi = rlwinm Rx, Ry, 32-n, n, 31 */
-#define PPC_SRWI(d, a, i)	EMIT(PPC_INST_RLWINM | ___PPC_RA(d) |	      \
-				     ___PPC_RS(a) | __PPC_SH(32-(i)) |	      \
-				     __PPC_MB(i) | __PPC_ME(31))
+#define PPC_SRWI(d, a, i)	PPC_RLWINM(d, a, 32-(i), i, 31)
 /* sldi = rldicr Rx, Ry, n, 63-n */
-#define PPC_SLDI(d, a, i)	EMIT(PPC_INST_RLDICR | ___PPC_RA(d) |	      \
-				     ___PPC_RS(a) | __PPC_SH(i) |	      \
-				     __PPC_MB(63-(i)) | (((i) & 0x20) >> 4))
+#define PPC_SLDI(d, a, i)	PPC_RLDICR(d, a, i, 63-(i))
+
 #define PPC_NEG(d, a)		EMIT(PPC_INST_NEG | ___PPC_RT(d) | ___PPC_RA(a))
 
 /* Long jump; (unconditional 'branch') */
-- 
2.8.2
