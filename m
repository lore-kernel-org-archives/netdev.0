From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH v2 net-next] PPC: bpf_jit_comp: add SKF_AD_HATYPE instruction
Date: Mon, 10 Nov 2014 08:59:43 +0300
Message-ID: <1415599183-3883-1-git-send-email-kda@linux-powerpc.org>
Cc: linuxppc-dev@ozlabs.org, Denis Kirjanov <kda@linux-powerpc.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Philippe Bergheaud <felix@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:37926 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbaKJG1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 01:27:31 -0500
Received: by mail-lb0-f179.google.com with SMTP id l4so5335891lbv.10
        for <netdev@vger.kernel.org>; Sun, 09 Nov 2014 22:27:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add BPF extension SKF_AD_HATYPE to ppc JIT to check
the hw type of the interface

Before:
[   57.723666] test_bpf: #20 LD_HATYPE
[   57.723675] BPF filter opcode 0020 (@0) unsupported
[   57.724168] 48 48 PASS

After:
[  103.053184] test_bpf: #20 LD_HATYPE 7 6 PASS

CC: Alexei Starovoitov<alexei.starovoitov@gmail.com>
CC: Daniel Borkmann<dborkman@redhat.com>
CC: Philippe Bergheaud<felix@linux.vnet.ibm.com>
Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>

v2: address Alexei's comments
---
 arch/powerpc/net/bpf_jit_comp.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index d110e28..d3fa80d 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -361,6 +361,11 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 							    protocol));
 			break;
 		case BPF_ANC | SKF_AD_IFINDEX:
+		case BPF_ANC | SKF_AD_HATYPE:
+			BUILD_BUG_ON(FIELD_SIZEOF(struct net_device,
+						ifindex) != 4);
+			BUILD_BUG_ON(FIELD_SIZEOF(struct net_device,
+						type) != 2);
 			PPC_LD_OFFS(r_scratch1, r_skb, offsetof(struct sk_buff,
 								dev));
 			PPC_CMPDI(r_scratch1, 0);
@@ -368,14 +373,18 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 				PPC_BCC(COND_EQ, addrs[ctx->pc_ret0]);
 			} else {
 				/* Exit, returning 0; first pass hits here. */
-				PPC_BCC_SHORT(COND_NE, (ctx->idx*4)+12);
+				PPC_BCC_SHORT(COND_NE, ctx->idx * 4 + 12);
 				PPC_LI(r_ret, 0);
 				PPC_JMP(exit_addr);
 			}
-			BUILD_BUG_ON(FIELD_SIZEOF(struct net_device,
-						  ifindex) != 4);
-			PPC_LWZ_OFFS(r_A, r_scratch1,
+			if (code == (BPF_ANC | SKF_AD_IFINDEX)) {
+				PPC_LWZ_OFFS(r_A, r_scratch1,
 				     offsetof(struct net_device, ifindex));
+			} else {
+				PPC_LHZ_OFFS(r_A, r_scratch1,
+				     offsetof(struct net_device, type));
+			}
+
 			break;
 		case BPF_ANC | SKF_AD_MARK:
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, mark) != 4);
-- 
2.1.0
