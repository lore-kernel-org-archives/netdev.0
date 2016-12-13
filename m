From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next 22/27] net/bpf_jit: SPARC: split VLAN_PRESENT bit
 handling from VLAN_TCI
Date: Tue, 13 Dec 2016 01:12:40 +0100 (CET)
Message-ID: <9c67fc2e501107c688f748405b412134fe5f87d9.1481586602.git.mirq-linux@rere.qmqm.pl>
References: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net> (maintainer:SPARC + UltraSPARC
        (sparc/sparc64),commit_signer:2/4=50%),
        sparclinux@vger.kernel.org (open list:SPARC + UltraSPARC
        (sparc/sparc64))
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:50222 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932592AbcLMAMn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 19:12:43 -0500
In-Reply-To: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 arch/sparc/net/bpf_jit_comp.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index a6d9204..61cc15d 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -601,15 +601,17 @@ void bpf_jit_compile(struct bpf_prog *fp)
 				emit_skb_load32(hash, r_A);
 				break;
 			case BPF_ANC | SKF_AD_VLAN_TAG:
-			case BPF_ANC | SKF_AD_VLAN_TAG_PRESENT:
 				emit_skb_load16(vlan_tci, r_A);
-				if (code != (BPF_ANC | SKF_AD_VLAN_TAG)) {
-					emit_alu_K(SRL, 12);
-					emit_andi(r_A, 1, r_A);
-				} else {
-					emit_loadimm(~VLAN_TAG_PRESENT, r_TMP);
-					emit_and(r_A, r_TMP, r_A);
-				}
+#ifdef VLAN_TAG_PRESENT
+				emit_loadimm(~VLAN_TAG_PRESENT, r_TMP);
+				emit_and(r_A, r_TMP, r_A);
+#endif
+				break;
+			case BPF_ANC | SKF_AD_VLAN_TAG_PRESENT:
+				__emit_skb_load8(__pkt_vlan_present_offset, r_A);
+				if (PKT_VLAN_PRESENT_BIT)
+					emit_alu_K(SRL, PKT_VLAN_PRESENT_BIT);
+				emit_andi(r_A, 1, r_A);
 				break;
 			case BPF_LD | BPF_W | BPF_LEN:
 				emit_skb_load32(len, r_A);
-- 
2.10.2
