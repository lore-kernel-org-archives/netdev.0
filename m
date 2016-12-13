From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next 21/27] net/bpf_jit: PPC: split VLAN_PRESENT bit
 handling from VLAN_TCI
Date: Tue, 13 Dec 2016 01:12:39 +0100 (CET)
Message-ID: <e21e4fae330ecdde5bfc651ab0ae490d37002bcc.1481586602.git.mirq-linux@rere.qmqm.pl>
References: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org> (supporter:LINUX
        FOR POWERPC (32-BIT AND 64-BIT)),
        Paul Mackerras <paulus@samba.org> (supporter:LINUX FOR POWERPC
        (32-BIT AND 64-BIT)),
        Michael Ellerman <mpe@ellerman.id.au> (supporter:LINUX FOR POWERPC
        (32-BIT AND 64-BIT),commit_signer:2/5=40%),
        linuxppc-dev@lists.ozlabs.org (open list:LINUX FOR POWERPC (32-BIT AND
        64-BIT))
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:50226 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932610AbcLMAMn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 19:12:43 -0500
In-Reply-To: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 arch/powerpc/net/bpf_jit_comp.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index 7e706f3..22ae63f 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -377,18 +377,19 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 							  hash));
 			break;
 		case BPF_ANC | SKF_AD_VLAN_TAG:
-		case BPF_ANC | SKF_AD_VLAN_TAG_PRESENT:
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_tci) != 2);
-			BUILD_BUG_ON(VLAN_TAG_PRESENT != 0x1000);
 
 			PPC_LHZ_OFFS(r_A, r_skb, offsetof(struct sk_buff,
 							  vlan_tci));
-			if (code == (BPF_ANC | SKF_AD_VLAN_TAG)) {
-				PPC_ANDI(r_A, r_A, ~VLAN_TAG_PRESENT);
-			} else {
-				PPC_ANDI(r_A, r_A, VLAN_TAG_PRESENT);
-				PPC_SRWI(r_A, r_A, 12);
-			}
+#ifdef VLAN_TAG_PRESENT
+			PPC_ANDI(r_A, r_A, ~VLAN_TAG_PRESENT);
+#endif
+			break;
+		case BPF_ANC | SKF_AD_VLAN_TAG_PRESENT:
+			PPC_LBZ_OFFS(r_A, r_skb, PKT_VLAN_PRESENT_OFFSET());
+			if (PKT_VLAN_PRESENT_BIT)
+				PPC_SRWI(r_A, r_A, PKT_VLAN_PRESENT_BIT);
+			PPC_ANDI(r_A, r_A, 1);
 			break;
 		case BPF_ANC | SKF_AD_QUEUE:
 			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
-- 
2.10.2
