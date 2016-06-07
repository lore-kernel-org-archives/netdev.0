From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: [PATCH 2/6] ppc: bpf/jit: Optimize 64-bit Immediate loads
Date: Tue,  7 Jun 2016 19:02:19 +0530
Message-ID: <652931bfae718f0ca83fd4ccb070dd601db8f3b9.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:15770 "EHLO
	mx0b-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932697AbcFGNdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 09:33:50 -0400
Received: from pps.filterd (m0082756.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u57DTsUt007325
	for <netdev@vger.kernel.org>; Tue, 7 Jun 2016 09:33:49 -0400
Received: from e28smtp08.in.ibm.com (e28smtp08.in.ibm.com [125.16.236.8])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23dxwehcwy-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 09:33:48 -0400
Received: from localhost
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <naveen.n.rao@linux.vnet.ibm.com>;
	Tue, 7 Jun 2016 19:03:44 +0530
In-Reply-To: <cover.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
In-Reply-To: <cover.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
References: <cover.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
