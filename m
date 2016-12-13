From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next 19/27] net/bpf_jit: ARM: split VLAN_PRESENT bit
 handling from VLAN_TCI
Date: Tue, 13 Dec 2016 01:12:39 +0100 (CET)
Message-ID: <3d60811f349762a9677cab79989e1809148443dc.1481586602.git.mirq-linux@rere.qmqm.pl>
References: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Russell King <linux@armlinux.org.uk> (maintainer:ARM PORT),
        linux-arm-kernel@lists.infradead.org (moderated list:ARM PORT)
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:50210 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932580AbcLMAMl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 19:12:41 -0500
In-Reply-To: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 arch/arm/net/bpf_jit_32.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index 93d0b6d..6dbc602 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -915,17 +915,20 @@ static int build_body(struct jit_ctx *ctx)
 			emit(ARM_LDR_I(r_A, r_skb, off), ctx);
 			break;
 		case BPF_ANC | SKF_AD_VLAN_TAG:
-		case BPF_ANC | SKF_AD_VLAN_TAG_PRESENT:
 			ctx->seen |= SEEN_SKB;
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_tci) != 2);
 			off = offsetof(struct sk_buff, vlan_tci);
 			emit(ARM_LDRH_I(r_A, r_skb, off), ctx);
-			if (code == (BPF_ANC | SKF_AD_VLAN_TAG))
-				OP_IMM3(ARM_AND, r_A, r_A, ~VLAN_TAG_PRESENT, ctx);
-			else {
-				OP_IMM3(ARM_LSR, r_A, r_A, 12, ctx);
-				OP_IMM3(ARM_AND, r_A, r_A, 0x1, ctx);
-			}
+#ifdef VLAN_TAG_PRESENT
+			OP_IMM3(ARM_AND, r_A, r_A, ~VLAN_TAG_PRESENT, ctx);
+#endif
+			break;
+		case BPF_ANC | SKF_AD_VLAN_TAG_PRESENT:
+			off = PKT_VLAN_PRESENT_OFFSET();
+			emit(ARM_LDRB_I(r_A, r_skb, off), ctx);
+			if (PKT_VLAN_PRESENT_BIT)
+				OP_IMM3(ARM_LSR, r_A, r_A, PKT_VLAN_PRESENT_BIT, ctx);
+			OP_IMM3(ARM_AND, r_A, r_A, 0x1, ctx);
 			break;
 		case BPF_ANC | SKF_AD_PKTTYPE:
 			ctx->seen |= SEEN_SKB;
-- 
2.10.2
