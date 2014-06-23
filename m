From: Markos Chandras <markos.chandras@imgtec.com>
Subject: [PATCH 10/17] MIPS: bpf: Fix return values for VLAN_TAG_PRESENT case
Date: Mon, 23 Jun 2014 10:38:53 +0100
Message-ID: <1403516340-22997-11-git-send-email-markos.chandras@imgtec.com>
References: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Alexei Starovoitov" <ast@plumgrid.com>, <netdev@vger.kernel.org>
To: <linux-mips@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:18243 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597AbaFWJjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 05:39:35 -0400
In-Reply-To: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If VLAN_TAG_PRESENT is not zero, then return 1 as expected by
classic BPF. Otherwise return 0.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
---
 arch/mips/net/bpf_jit.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index a4d1b76e7373..d852bb6d3fe3 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -1316,10 +1316,13 @@ jmp_cmp:
 						  vlan_tci) != 2);
 			off = offsetof(struct sk_buff, vlan_tci);
 			emit_half_load(r_s0, r_skb, off, ctx);
-			if (code == (BPF_ANC | SKF_AD_VLAN_TAG))
+			if (code == (BPF_ANC | SKF_AD_VLAN_TAG)) {
 				emit_andi(r_A, r_s0, (u16)~VLAN_TAG_PRESENT, ctx);
-			else
+			} else {
 				emit_andi(r_A, r_s0, VLAN_TAG_PRESENT, ctx);
+				/* return 1 if present */
+				emit_sltu(r_A, r_zero, r_A, ctx);
+			}
 			break;
 		case BPF_ANC | SKF_AD_PKTTYPE:
 			ctx->flags |= SEEN_SKB;
-- 
2.0.0
