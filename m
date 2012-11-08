From: Daniel Borkmann <dxchgb@gmail.com>
Subject: [PATCH net-next 2/2] ARM: net: bpf_jit_32: add VLAN instructions
 for BPF JIT
Date: Thu, 8 Nov 2012 02:31:02 +0100
Message-ID: <20121108013101.GB23143@thinkbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mircea Gherzan <mgherzan@gmail.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:32915 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752935Ab2KHBbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 20:31:07 -0500
Received: by mail-ea0-f174.google.com with SMTP id c13so861810eaa.19
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2012 17:31:06 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is a follow-up for patch "net: filter: add vlan tag access"
to support the new VLAN_TAG/VLAN_TAG_PRESENT accessors in BPF JIT.

Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
Cc: Mircea Gherzan <mgherzan@gmail.com>
Cc: Arnd Bergmann <arnd@arndb.de>
---
 arch/arm/net/bpf_jit_32.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index 8be702d..9af9a69 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -16,6 +16,7 @@
 #include <linux/netdevice.h>
 #include <linux/string.h>
 #include <linux/slab.h>
+#include <linux/if_vlan.h>
 #include <asm/cacheflush.h>
 #include <asm/hwcap.h>
 
@@ -168,6 +169,8 @@ static inline bool is_load_to_a(u16 inst)
 	case BPF_S_ANC_MARK:
 	case BPF_S_ANC_PROTOCOL:
 	case BPF_S_ANC_RXHASH:
+	case BPF_S_ANC_VLAN_TAG:
+	case BPF_S_ANC_VLAN_TAG_PRESENT:
 	case BPF_S_ANC_QUEUE:
 		return true;
 	default:
@@ -815,6 +818,17 @@ b_epilogue:
 			off = offsetof(struct sk_buff, rxhash);
 			emit(ARM_LDR_I(r_A, r_skb, off), ctx);
 			break;
+		case BPF_S_ANC_VLAN_TAG:
+		case BPF_S_ANC_VLAN_TAG_PRESENT:
+			ctx->seen |= SEEN_SKB;
+			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_tci) != 2);
+			off = offsetof(struct sk_buff, vlan_tci);
+			emit(ARM_LDRH_I(r_A, r_skb, off), ctx);
+			if (inst->code == BPF_S_ANC_VLAN_TAG)
+				OP_IMM3(ARM_AND, r_A, r_A, VLAN_VID_MASK, ctx);
+			else
+				OP_IMM3(ARM_AND, r_A, r_A, VLAN_TAG_PRESENT, ctx);
+			break;
 		case BPF_S_ANC_QUEUE:
 			ctx->seen |= SEEN_SKB;
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
