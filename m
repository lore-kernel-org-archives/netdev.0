From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next v2 23/27] net/bpf: split VLAN_PRESENT bit handling from
 VLAN_TCI
Date: Tue,  3 Jan 2017 21:52:40 +0100 (CET)
Message-ID: <154bb17b6dcba84df752a4a5073e449423aa98a7.1483475202.git.mirq-linux@rere.qmqm.pl>
References: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Thomas Graf <tgraf@suug.ch>, Martin KaFai Lau <kafai@fb.com>,
        Craig Gallek <kraig@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:34814 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965966AbdACUw4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 15:52:56 -0500
In-Reply-To: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 net/core/filter.c | 20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 1969b3f118c1..5209c5f5ac4a 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -188,22 +188,20 @@ static u32 convert_skb_access(int skb_field, int dst_reg, int src_reg,
 		break;
 
 	case SKF_AD_VLAN_TAG:
-	case SKF_AD_VLAN_TAG_PRESENT:
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_tci) != 2);
-		BUILD_BUG_ON(VLAN_TAG_PRESENT != 0x1000);
 
 		/* dst_reg = *(u16 *) (src_reg + offsetof(vlan_tci)) */
 		*insn++ = BPF_LDX_MEM(BPF_H, dst_reg, src_reg,
 				      offsetof(struct sk_buff, vlan_tci));
-		if (skb_field == SKF_AD_VLAN_TAG) {
-			*insn++ = BPF_ALU32_IMM(BPF_AND, dst_reg,
-						~VLAN_TAG_PRESENT);
-		} else {
-			/* dst_reg >>= 12 */
-			*insn++ = BPF_ALU32_IMM(BPF_RSH, dst_reg, 12);
-			/* dst_reg &= 1 */
-			*insn++ = BPF_ALU32_IMM(BPF_AND, dst_reg, 1);
-		}
+#ifdef VLAN_TAG_PRESENT
+		*insn++ = BPF_ALU32_IMM(BPF_AND, dst_reg, ~VLAN_TAG_PRESENT);
+#endif
+		break;
+	case SKF_AD_VLAN_TAG_PRESENT:
+		*insn++ = BPF_LDX_MEM(BPF_B, dst_reg, src_reg, PKT_VLAN_PRESENT_OFFSET());
+		if (PKT_VLAN_PRESENT_BIT)
+			*insn++ = BPF_ALU32_IMM(BPF_RSH, dst_reg, PKT_VLAN_PRESENT_BIT);
+		*insn++ = BPF_ALU32_IMM(BPF_AND, dst_reg, 1);
 		break;
 	}
 
-- 
2.11.0
