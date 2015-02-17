From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH net-next v2 5/6] ppc: bpf: Add SKF_AD_CPU for ppc32
Date: Tue, 17 Feb 2015 10:04:42 +0300
Message-ID: <1424156683-2682-6-git-send-email-kda@linux-powerpc.org>
References: <1424156683-2682-1-git-send-email-kda@linux-powerpc.org>
Cc: linuxppc-dev@lists.ozlabs.org,
	Denis Kirjanov <kda@linux-powerpc.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:37790 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932696AbbBQHAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 02:00:54 -0500
Received: by lbvn10 with SMTP id n10so2755808lbv.4
        for <netdev@vger.kernel.org>; Mon, 16 Feb 2015 23:00:53 -0800 (PST)
In-Reply-To: <1424156683-2682-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
 arch/powerpc/net/bpf_jit.h      | 17 +++++++++++++++++
 arch/powerpc/net/bpf_jit_comp.c | 14 +-------------
 2 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/arch/powerpc/net/bpf_jit.h b/arch/powerpc/net/bpf_jit.h
index 2d5e715..889fd19 100644
--- a/arch/powerpc/net/bpf_jit.h
+++ b/arch/powerpc/net/bpf_jit.h
@@ -154,6 +154,23 @@ DECLARE_LOAD_FUNC(sk_load_byte_msh);
 #define PPC_LL_OFFS(r, base, i) do { PPC_LWZ_OFFS(r, base, i); } while(0)
 #endif
 
+#ifdef CONFIG_SMP
+#ifdef CONFIG_PPC64
+#define PPC_BPF_LOAD_CPU(r)		\
+	do { BUILD_BUG_ON(FIELD_SIZEOF(struct paca_struct, paca_index) != 2);	\
+		PPC_LHZ_OFFS(r, 13, offsetof(struct paca_struct, paca_index));		\
+	} while (0)
+#else
+#define PPC_BPF_LOAD_CPU(r)     \
+	do { BUILD_BUG_ON(FIELD_SIZEOF(struct thread_info, cpu) != 4);			\
+		PPC_LHZ_OFFS(r, (1 & ~(THREAD_SIZE - 1)),							\
+				offsetof(struct thread_info, cpu));							\
+	} while(0)
+#endif
+#else
+#define PPC_BPF_LOAD_CPU(r) do { PPC_LI(r, 0); } while(0)
+#endif
+
 #define PPC_CMPWI(a, i)		EMIT(PPC_INST_CMPWI | ___PPC_RA(a) | IMM_L(i))
 #define PPC_CMPDI(a, i)		EMIT(PPC_INST_CMPDI | ___PPC_RA(a) | IMM_L(i))
 #define PPC_CMPLWI(a, i)	EMIT(PPC_INST_CMPLWI | ___PPC_RA(a) | IMM_L(i))
diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index 8b29268..17cea18 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -411,20 +411,8 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 			PPC_SRWI(r_A, r_A, 5);
 			break;
 		case BPF_ANC | SKF_AD_CPU:
-#ifdef CONFIG_SMP
-			/*
-			 * PACA ptr is r13:
-			 * raw_smp_processor_id() = local_paca->paca_index
-			 */
-			BUILD_BUG_ON(FIELD_SIZEOF(struct paca_struct,
-						  paca_index) != 2);
-			PPC_LHZ_OFFS(r_A, 13,
-				     offsetof(struct paca_struct, paca_index));
-#else
-			PPC_LI(r_A, 0);
-#endif
+			PPC_BPF_LOAD_CPU(r_A);
 			break;
-
 			/*** Absolute loads from packet header/data ***/
 		case BPF_LD | BPF_W | BPF_ABS:
 			func = CHOOSE_LOAD_FUNC(K, sk_load_word);
-- 
2.1.3
