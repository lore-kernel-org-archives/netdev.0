From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next 23/27] net/bpf: split VLAN_PRESENT bit handling from
 VLAN_TCI
Date: Tue, 13 Dec 2016 01:12:40 +0100 (CET)
Message-ID: <dd1669132ff887bdecdea362b7296981c000fd5b.1481586602.git.mirq-linux@rere.qmqm.pl>
References: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net> (maintainer:NETWORKING
        [GENERAL],commit_signer:74/77=96%),
        Alexei Starovoitov <ast@fb.com> (commit_signer:67/77=87%),
        Daniel Borkmann <daniel@iogearbox.net> (commit_signer:65/77=84%
        ,authored:57/77=74%,added_lines:1224/1906=64%,removed_lines:409/493=83%),
        Thomas Graf <tgraf@suug.ch> (added_lines:173/1906=9%),
        Martin KaFai Lau <kafai@fb.com> (added_lines:124/1906=7%),
        Craig Gallek <kraig@google.com> (added_lines:100/1906=5%),
        netdev@vger.kernel.org (open list:NETWORKING [GENERAL]),
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:50228 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932612AbcLMAMo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 19:12:44 -0500
In-Reply-To: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 net/core/filter.c | 20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index b146170..c3321f1 100644
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
2.10.2
