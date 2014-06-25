From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH v2 2/2] powerpc: bpf: Fix the broken LD_VLAN_TAG_PRESENT test
Date: Wed, 25 Jun 2014 21:34:57 +0400
Message-ID: <1403717697-3911-2-git-send-email-kda@linux-powerpc.org>
References: <1403717697-3911-1-git-send-email-kda@linux-powerpc.org>
Cc: linuxppc-dev@lists.ozlabs.org,
	Denis Kirjanov <kda@linux-powerpc.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:62455 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757672AbaFYR7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 13:59:51 -0400
Received: by mail-la0-f48.google.com with SMTP id el20so1039759lab.35
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 10:59:50 -0700 (PDT)
In-Reply-To: <1403717697-3911-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have to return the boolean here if the tag presents
or not, not just ANDing the TCI with the mask which results to:

[  709.412097] test_bpf: #18 LD_VLAN_TAG_PRESENT
[  709.412245] ret 4096 != 1
[  709.412332] ret 4096 != 1
[  709.412333] FAIL (2 times)

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
 arch/powerpc/net/bpf_jit_comp.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index 892167b..82e82ca 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -394,10 +394,12 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 
 			PPC_LHZ_OFFS(r_A, r_skb, offsetof(struct sk_buff,
 							  vlan_tci));
-			if (code == (BPF_ANC | SKF_AD_VLAN_TAG))
+			if (code == (BPF_ANC | SKF_AD_VLAN_TAG)) {
 				PPC_ANDI(r_A, r_A, ~VLAN_TAG_PRESENT);
-			else
+			} else {
 				PPC_ANDI(r_A, r_A, VLAN_TAG_PRESENT);
+				PPC_SRWI(r_A, r_A, 12);
+			}
 			break;
 		case BPF_ANC | SKF_AD_QUEUE:
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
-- 
2.0.0
