From: Markos Chandras <markos.chandras@imgtec.com>
Subject: [PATCH 15/17] MIPS: bpf: Fix PKT_TYPE case for big-endian cores
Date: Mon, 23 Jun 2014 10:38:58 +0100
Message-ID: <1403516340-22997-16-git-send-email-markos.chandras@imgtec.com>
References: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Alexei Starovoitov" <ast@plumgrid.com>, <netdev@vger.kernel.org>
To: <linux-mips@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:1877 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753099AbaFWJjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 05:39:43 -0400
In-Reply-To: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The skb->pkt_type field is defined as follows:

u8 pkt_type:3,
   fclone:2,
   ipvs_property:1,
   peeked:1,
   nf_trace:1

resulting to the following layout in big-endian systems

[pkt_type][fclone][ipvs_propery][peeked][nf_trace]
^                                                ^
|                                                |
LSB                                             MSB

As a result, the existing code did not work because it was trying to
match pkt_type == 7 whereas in reality it is 7<<5 on big-endian
systems.

This has been fixed in the interpreter in
0dcceabb0c1bf2d4c12a748df9933fad303072a7
"net: filter: fix SKF_AD_PKTTYPE extension on big-endian"

The fix is to look for 7<<5 on big-endian systems for the pkt_type
field, and shift by 5 so the packet type will be at the lower 3 bits
of the A register.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>
---
 arch/mips/net/bpf_jit.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 09ebc886c7aa..4920e0fd05ee 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -745,13 +745,17 @@ static u64 jit_get_skb_w(struct sk_buff *skb, unsigned offset)
 	return (u64)err << 32 | ntohl(ret);
 }
 
-#define PKT_TYPE_MAX 7
+#ifdef __BIG_ENDIAN_BITFIELD
+#define PKT_TYPE_MAX	(7 << 5)
+#else
+#define PKT_TYPE_MAX	7
+#endif
 static int pkt_type_offset(void)
 {
 	struct sk_buff skb_probe = {
 		.pkt_type = ~0,
 	};
-	char *ct = (char *)&skb_probe;
+	u8 *ct = (u8 *)&skb_probe;
 	unsigned int off;
 
 	for (off = 0; off < sizeof(struct sk_buff); off++) {
@@ -1314,6 +1318,10 @@ jmp_cmp:
 			emit_load_byte(r_tmp, r_skb, off, ctx);
 			/* Keep only the last 3 bits */
 			emit_andi(r_A, r_tmp, PKT_TYPE_MAX, ctx);
+#ifdef __BIG_ENDIAN_BITFIELD
+			/* Get the actual packet type to the lower 3 bits */
+			emit_srl(r_A, r_A, 5, ctx);
+#endif
 			break;
 		case BPF_ANC | SKF_AD_QUEUE:
 			ctx->flags |= SEEN_SKB | SEEN_A;
-- 
2.0.0
