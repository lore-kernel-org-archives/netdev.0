From: Daniel Borkmann <dxchgb@gmail.com>
Subject: [PATCH net-next 2/2] PPC: net: bpf_jit_comp: add VLAN instructions
 for BPF JIT
Date: Thu, 8 Nov 2012 22:41:39 +0100
Message-ID: <20121108214137.GB29696@thinkbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: matt@ozlabs.org, benh@kernel.crashing.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:36793 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756690Ab2KHVlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 16:41:44 -0500
Received: by mail-ea0-f174.google.com with SMTP id c13so1241445eaa.19
        for <netdev@vger.kernel.org>; Thu, 08 Nov 2012 13:41:43 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is a follow-up for patch "net: filter: add vlan tag access"
to support the new VLAN_TAG/VLAN_TAG_PRESENT accessors in BPF JIT.

Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
Cc: Matt Evans <matt@ozlabs.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 Disclaimer: uncompiled and untested, since I don't have a PPC machine,
 but it should (hopefully) integrate cleanly; impl. after PPC instruction
 reference.

 arch/powerpc/net/bpf_jit_comp.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index b9434de..e834f1e 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -13,6 +13,8 @@
 #include <asm/cacheflush.h>
 #include <linux/netdevice.h>
 #include <linux/filter.h>
+#include <linux/if_vlan.h>
+
 #include "bpf_jit.h"
 
 #ifndef __BIG_ENDIAN
@@ -89,6 +91,8 @@ static void bpf_jit_build_prologue(struct sk_filter *fp, u32 *image,
 	case BPF_S_ANC_IFINDEX:
 	case BPF_S_ANC_MARK:
 	case BPF_S_ANC_RXHASH:
+	case BPF_S_ANC_VLAN_TAG:
+	case BPF_S_ANC_VLAN_TAG_PRESENT:
 	case BPF_S_ANC_CPU:
 	case BPF_S_ANC_QUEUE:
 	case BPF_S_LD_W_ABS:
@@ -382,6 +386,16 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 			PPC_LWZ_OFFS(r_A, r_skb, offsetof(struct sk_buff,
 							  rxhash));
 			break;
+		case BPF_S_ANC_VLAN_TAG:
+		case BPF_S_ANC_VLAN_TAG_PRESENT:
+			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_tci) != 2);
+			PPC_LHZ_OFFS(r_A, r_skb, offsetof(struct sk_buff,
+							  vlan_tci));
+			if (filter[i].code == BPF_S_ANC_VLAN_TAG)
+				PPC_ANDI(r_A, r_A, VLAN_VID_MASK);
+			else
+				PPC_ANDI(r_A, r_A, VLAN_TAG_PRESENT);
+			break;
 		case BPF_S_ANC_QUEUE:
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
 						  queue_mapping) != 2);
