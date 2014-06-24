From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH 2/2] powerpc: bpf: Fix the broken LD_VLAN_TAG_PRESENT test
Date: Tue, 24 Jun 2014 13:59:29 +0400
Message-ID: <1403603969-24436-2-git-send-email-kda@linux-powerpc.org>
References: <1403603969-24436-1-git-send-email-kda@linux-powerpc.org>
Cc: linuxppc-dev@lists.ozlabs.org,
	Denis Kirjanov <kda@linux-powerpc.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:55816 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966AbaFXKYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 06:24:23 -0400
Received: by mail-lb0-f173.google.com with SMTP id s7so116405lbd.4
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 03:24:21 -0700 (PDT)
In-Reply-To: <1403603969-24436-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have to return the boolean here if the tag presents
or not, not jusr ORing the TCI with the mask which results to:

[  709.412097] test_bpf: #18 LD_VLAN_TAG_PRESENT
[  709.412245] ret 4096 != 1
[  709.412332] ret 4096 != 1
[  709.412333] FAIL (2 times)
---
 arch/powerpc/net/bpf_jit_comp.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index af0ed4d..a3d8f58 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -394,8 +394,10 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 							  vlan_tci));
 			if (code == (BPF_ANC | SKF_AD_VLAN_TAG))
 				PPC_ANDI(r_A, r_A, ~VLAN_TAG_PRESENT);
-			else
+			else {
 				PPC_ANDI(r_A, r_A, VLAN_TAG_PRESENT);
+				PPC_SRWI(r_A, r_A, 12);
+			}
 			break;
 		case BPF_ANC | SKF_AD_QUEUE:
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
-- 
2.0.0
