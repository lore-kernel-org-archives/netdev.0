From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next 20/27] net/bpf_jit: MIPS: split VLAN_PRESENT bit
 handling from VLAN_TCI
Date: Tue, 13 Dec 2016 01:12:39 +0100 (CET)
Message-ID: <06129d2e359239a2df5c7a29c2d5e6dee32aa638.1481586602.git.mirq-linux@rere.qmqm.pl>
References: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Ralf Baechle <ralf@linux-mips.org> (supporter:MIPS),
        linux-mips@linux-mips.org (open list:MIPS)
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:50224 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932593AbcLMAMm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 19:12:42 -0500
In-Reply-To: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 arch/mips/net/bpf_jit.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 49a2e22..4b12b5d 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -1138,19 +1138,23 @@ static int build_body(struct jit_ctx *ctx)
 			emit_load(r_A, r_skb, off, ctx);
 			break;
 		case BPF_ANC | SKF_AD_VLAN_TAG:
-		case BPF_ANC | SKF_AD_VLAN_TAG_PRESENT:
 			ctx->flags |= SEEN_SKB | SEEN_A;
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
 						  vlan_tci) != 2);
 			off = offsetof(struct sk_buff, vlan_tci);
 			emit_half_load(r_s0, r_skb, off, ctx);
-			if (code == (BPF_ANC | SKF_AD_VLAN_TAG)) {
-				emit_andi(r_A, r_s0, (u16)~VLAN_TAG_PRESENT, ctx);
-			} else {
-				emit_andi(r_A, r_s0, VLAN_TAG_PRESENT, ctx);
-				/* return 1 if present */
-				emit_sltu(r_A, r_zero, r_A, ctx);
-			}
+#ifdef VLAN_TAG_PRESENT
+			emit_andi(r_A, r_s0, (u16)~VLAN_TAG_PRESENT, ctx);
+#endif
+			break;
+		case BPF_ANC | SKF_AD_VLAN_TAG_PRESENT:
+			ctx->flags |= SEEN_SKB | SEEN_A;
+			emit_load_byte(r_A, r_skb, PKT_VLAN_PRESENT_OFFSET(), ctx);
+			if (PKT_VLAN_PRESENT_BIT)
+				emit_srl(r_A, r_A, PKT_VLAN_PRESENT_BIT, ctx);
+			emit_andi(r_A, r_s0, 1, ctx);
+			/* return 1 if present */
+			emit_sltu(r_A, r_zero, r_A, ctx);
 			break;
 		case BPF_ANC | SKF_AD_PKTTYPE:
 			ctx->flags |= SEEN_SKB;
-- 
2.10.2
