From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: [PATCHv2 3/7] ppc: bpf/jit: Optimize 64-bit Immediate loads
Date: Wed, 22 Jun 2016 21:55:03 +0530
Message-ID: <ea92fc972da7acb37c33071c96f66ea748724d0c.1466612260.git.naveen.n.rao@linux.vnet.ibm.com>
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

Similar to the LI32() optimization, if the value can be represented
in 32-bits, use LI32(). Also handle loading a few specific forms of
immediate values in an optimum manner.

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
 arch/powerpc/net/bpf_jit.h | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/arch/powerpc/net/bpf_jit.h b/arch/powerpc/net/bpf_jit.h
index a9882db..4c1e055 100644
--- a/arch/powerpc/net/bpf_jit.h
+++ b/arch/powerpc/net/bpf_jit.h
@@ -244,20 +244,25 @@ DECLARE_LOAD_FUNC(sk_load_byte_msh);
 		} } while(0)
 
 #define PPC_LI64(d, i)		do {					      \
-		if (!((uintptr_t)(i) & 0xffffffff00000000ULL))		      \
+		if ((long)(i) >= -2147483648 &&				      \
+				(long)(i) < 2147483648)			      \
 			PPC_LI32(d, i);					      \
 		else {							      \
-			PPC_LIS(d, ((uintptr_t)(i) >> 48));		      \
-			if ((uintptr_t)(i) & 0x0000ffff00000000ULL)	      \
-				PPC_ORI(d, d,				      \
-					((uintptr_t)(i) >> 32) & 0xffff);     \
+			if (!((uintptr_t)(i) & 0xffff800000000000ULL))	      \
+				PPC_LI(d, ((uintptr_t)(i) >> 32) & 0xffff);   \
+			else {						      \
+				PPC_LIS(d, ((uintptr_t)(i) >> 48));	      \
+				if ((uintptr_t)(i) & 0x0000ffff00000000ULL)   \
+					PPC_ORI(d, d,			      \
+					  ((uintptr_t)(i) >> 32) & 0xffff);   \
+			}						      \
 			PPC_SLDI(d, d, 32);				      \
 			if ((uintptr_t)(i) & 0x00000000ffff0000ULL)	      \
 				PPC_ORIS(d, d,				      \
 					 ((uintptr_t)(i) >> 16) & 0xffff);    \
 			if ((uintptr_t)(i) & 0x000000000000ffffULL)	      \
 				PPC_ORI(d, d, (uintptr_t)(i) & 0xffff);	      \
-		} } while (0);
+		} } while (0)
 
 #ifdef CONFIG_PPC64
 #define PPC_FUNC_ADDR(d,i) do { PPC_LI64(d, i); } while(0)
-- 
2.8.2
