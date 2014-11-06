From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH net-next] PPC: bpf_jit_comp: add SKF_AD_HATYPE instruction
Date: Thu,  6 Nov 2014 09:02:35 +0300
Message-ID: <1415253755-4001-1-git-send-email-kda@linux-powerpc.org>
Cc: linuxppc-dev@ozlabs.org, Denis Kirjanov <kda@linux-powerpc.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Philippe Bergheaud <felix@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:33239 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955AbaKFGaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 01:30:19 -0500
Received: by mail-lb0-f173.google.com with SMTP id n15so352737lbi.18
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 22:30:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add BPF extension SKF_AD_HATYPE to ppc JIT to check
the hw type of the interface

JIT off:
[   69.106783] test_bpf: #20 LD_HATYPE 48 48 PASS
JIT on:
[   64.721757] test_bpf: #20 LD_HATYPE 7 6 PASS

CC: Alexei Starovoitov<alexei.starovoitov@gmail.com>
CC: Daniel Borkmann<dborkman@redhat.com>
CC: Philippe Bergheaud<felix@linux.vnet.ibm.com>
Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
 arch/powerpc/net/bpf_jit_comp.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index d110e28..8bf4fc2 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -412,6 +412,22 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 			PPC_ANDI(r_A, r_A, PKT_TYPE_MAX);
 			PPC_SRWI(r_A, r_A, 5);
 			break;
+		case BPF_ANC | SKF_AD_HATYPE:
+			BUILD_BUG_ON(FIELD_SIZEOF(struct net_device, type) != 2);
+			PPC_LD_OFFS(r_scratch1, r_skb, offsetof(struct sk_buff,
+								dev));
+			PPC_CMPDI(r_scratch1, 0);
+			if (ctx->pc_ret0 != -1) {
+				PPC_BCC(COND_EQ, addrs[ctx->pc_ret0]);
+			} else {
+				/* Exit, returning 0; first pass hits here. */
+				PPC_BCC_SHORT(COND_NE, (ctx->idx*4)+12);
+				PPC_LI(r_ret, 0);
+				PPC_JMP(exit_addr);
+			}
+			PPC_LHZ_OFFS(r_A, r_scratch1,
+				     offsetof(struct net_device, type));
+			break;
 		case BPF_ANC | SKF_AD_CPU:
 #ifdef CONFIG_SMP
 			/*
-- 
2.1.0
