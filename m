From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: [PATCHv2 2/7] ppc: bpf/jit: Fix/enhance 32-bit Load Immediate implementation
Date: Wed, 22 Jun 2016 21:55:02 +0530
Message-ID: <d584015e9fb33ed526d693c5ab3c228d385f3c74.1466612260.git.naveen.n.rao@linux.vnet.ibm.com>
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

The existing LI32() macro can sometimes result in a sign-extended 32-bit
load that does not clear the top 32-bits properly. As an example,
loading 0x7fffffff results in the register containing
0xffffffff7fffffff. While this does not impact classic BPF JIT
implementation (since that only uses the lower word for all operations),
we would like to share this macro between classic BPF JIT and extended
BPF JIT, wherein the entire 64-bit value in the register matters. Fix
this by first doing a shifted LI followed by ORI.

An additional optimization is with loading values between -32768 to -1,
where we now only need a single LI.

The new implementation now generates the same or less number of
instructions.

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
 arch/powerpc/net/bpf_jit.h | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/arch/powerpc/net/bpf_jit.h b/arch/powerpc/net/bpf_jit.h
index 889fd19..a9882db 100644
--- a/arch/powerpc/net/bpf_jit.h
+++ b/arch/powerpc/net/bpf_jit.h
@@ -232,10 +232,17 @@ DECLARE_LOAD_FUNC(sk_load_byte_msh);
 					     (((cond) & 0x3ff) << 16) |	      \
 					     (((dest) - (ctx->idx * 4)) &     \
 					      0xfffc))
-#define PPC_LI32(d, i)		do { PPC_LI(d, IMM_L(i));		      \
-		if ((u32)(uintptr_t)(i) >= 32768) {			      \
-			PPC_ADDIS(d, d, IMM_HA(i));			      \
+/* Sign-extended 32-bit immediate load */
+#define PPC_LI32(d, i)		do {					      \
+		if ((int)(uintptr_t)(i) >= -32768 &&			      \
+				(int)(uintptr_t)(i) < 32768)		      \
+			PPC_LI(d, i);					      \
+		else {							      \
+			PPC_LIS(d, IMM_H(i));				      \
+			if (IMM_L(i))					      \
+				PPC_ORI(d, d, IMM_L(i));		      \
 		} } while(0)
+
 #define PPC_LI64(d, i)		do {					      \
 		if (!((uintptr_t)(i) & 0xffffffff00000000ULL))		      \
 			PPC_LI32(d, i);					      \
-- 
2.8.2
