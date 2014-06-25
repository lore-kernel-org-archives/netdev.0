From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH v2 1/2] powerpc: bpf: Use correct mask while accessing the VLAN tag
Date: Wed, 25 Jun 2014 21:34:56 +0400
Message-ID: <1403717697-3911-1-git-send-email-kda@linux-powerpc.org>
Cc: linuxppc-dev@lists.ozlabs.org,
	Denis Kirjanov <kda@linux-powerpc.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:45109 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757672AbaFYR7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 13:59:49 -0400
Received: by mail-lb0-f171.google.com with SMTP id s7so2134747lbd.30
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 10:59:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To get a full tag (and not just a VID) we should access the TCI
except the VLAN_TAG_PRESENT field (which means that 802.1q header
is present). Also ensure that the VLAN_TAG_PRESENT stay on its place

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
 arch/powerpc/net/bpf_jit_comp.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index 6dcdade..892167b 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -390,10 +390,12 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 		case BPF_ANC | SKF_AD_VLAN_TAG:
 		case BPF_ANC | SKF_AD_VLAN_TAG_PRESENT:
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_tci) != 2);
+			BUILD_BUG_ON(VLAN_TAG_PRESENT != 0x1000);
+
 			PPC_LHZ_OFFS(r_A, r_skb, offsetof(struct sk_buff,
 							  vlan_tci));
 			if (code == (BPF_ANC | SKF_AD_VLAN_TAG))
-				PPC_ANDI(r_A, r_A, VLAN_VID_MASK);
+				PPC_ANDI(r_A, r_A, ~VLAN_TAG_PRESENT);
 			else
 				PPC_ANDI(r_A, r_A, VLAN_TAG_PRESENT);
 			break;
-- 
2.0.0
