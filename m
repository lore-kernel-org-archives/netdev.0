From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v2] net: filter: constify detection of pkt_type_offset
Date: Fri, 12 Sep 2014 14:04:43 +0200
Message-ID: <3e68956a7e5b8bb9de226bfcc09092c6852a0a0a.1410523297.git.hannes@stressinduktion.org>
References: <5412D9B9.2020300@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Denis Kirjanov <kda@linux-powerpc.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:60831 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754293AbaILMEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 08:04:52 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by gateway2.nyi.internal (Postfix) with ESMTP id 5A29120A83
	for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 08:04:51 -0400 (EDT)
In-Reply-To: <5412D9B9.2020300@redhat.com>
In-Reply-To: <5412D9B9.2020300@redhat.com>
References: <5412D9B9.2020300@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we have 2 pkt_type_offset functions doing the same thing and
spread across the architecture files. Remove those and replace them
with a PKT_TYPE_OFFSET macro helper which gets the constant value from a
zero sized sk_buff member right in front of the bitfield with offsetof.
This new offset marker does not change size of struct sk_buff.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Markos Chandras <markos.chandras@imgtec.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---

v2) Incorporated Daniel's feedback. I first misinterpreted the feedback
    as something not related to pkt_type_offset.

 arch/mips/net/bpf_jit.c      | 27 +--------------------------
 arch/s390/net/bpf_jit_comp.c | 35 +----------------------------------
 include/linux/skbuff.h       | 10 ++++++++++
 net/core/filter.c            | 31 ++-----------------------------
 4 files changed, 14 insertions(+), 89 deletions(-)

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 0e97ccd..7edc083 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -765,27 +765,6 @@ static u64 jit_get_skb_w(struct sk_buff *skb, unsigned offset)
 	return (u64)err << 32 | ntohl(ret);
 }
 
-#ifdef __BIG_ENDIAN_BITFIELD
-#define PKT_TYPE_MAX	(7 << 5)
-#else
-#define PKT_TYPE_MAX	7
-#endif
-static int pkt_type_offset(void)
-{
-	struct sk_buff skb_probe = {
-		.pkt_type = ~0,
-	};
-	u8 *ct = (u8 *)&skb_probe;
-	unsigned int off;
-
-	for (off = 0; off < sizeof(struct sk_buff); off++) {
-		if (ct[off] == PKT_TYPE_MAX)
-			return off;
-	}
-	pr_err_once("Please fix pkt_type_offset(), as pkt_type couldn't be found\n");
-	return -1;
-}
-
 static int build_body(struct jit_ctx *ctx)
 {
 	void *load_func[] = {jit_get_skb_b, jit_get_skb_h, jit_get_skb_w};
@@ -1332,11 +1311,7 @@ jmp_cmp:
 		case BPF_ANC | SKF_AD_PKTTYPE:
 			ctx->flags |= SEEN_SKB;
 
-			off = pkt_type_offset();
-
-			if (off < 0)
-				return -1;
-			emit_load_byte(r_tmp, r_skb, off, ctx);
+			emit_load_byte(r_tmp, r_skb, PKT_TYPE_OFFSET(), ctx);
 			/* Keep only the last 3 bits */
 			emit_andi(r_A, r_tmp, PKT_TYPE_MAX, ctx);
 #ifdef __BIG_ENDIAN_BITFIELD
diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index 555f5c7..c52ac77 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -227,37 +227,6 @@ static void bpf_jit_epilogue(struct bpf_jit *jit)
 	EMIT2(0x07fe);
 }
 
-/* Helper to find the offset of pkt_type in sk_buff
- * Make sure its still a 3bit field starting at the MSBs within a byte.
- */
-#define PKT_TYPE_MAX 0xe0
-static int pkt_type_offset;
-
-static int __init bpf_pkt_type_offset_init(void)
-{
-	struct sk_buff skb_probe = {
-		.pkt_type = ~0,
-	};
-	char *ct = (char *)&skb_probe;
-	int off;
-
-	pkt_type_offset = -1;
-	for (off = 0; off < sizeof(struct sk_buff); off++) {
-		if (!ct[off])
-			continue;
-		if (ct[off] == PKT_TYPE_MAX)
-			pkt_type_offset = off;
-		else {
-			/* Found non matching bit pattern, fix needed. */
-			WARN_ON_ONCE(1);
-			pkt_type_offset = -1;
-			return -1;
-		}
-	}
-	return 0;
-}
-device_initcall(bpf_pkt_type_offset_init);
-
 /*
  * make sure we dont leak kernel information to user
  */
@@ -757,12 +726,10 @@ call_fn:	/* lg %r1,<d(function)>(%r13) */
 		}
 		break;
 	case BPF_ANC | SKF_AD_PKTTYPE:
-		if (pkt_type_offset < 0)
-			goto out;
 		/* lhi %r5,0 */
 		EMIT4(0xa7580000);
 		/* ic %r5,<d(pkt_type_offset)>(%r2) */
-		EMIT4_DISP(0x43502000, pkt_type_offset);
+		EMIT4_DISP(0x43502000, PKT_TYPE_OFFSET());
 		/* srl %r5,5 */
 		EMIT4_DISP(0x88500000, 5);
 		break;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 07c9fdd..756e3d0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -548,6 +548,16 @@ struct sk_buff {
 				ip_summed:2,
 				nohdr:1,
 				nfctinfo:3;
+
+/* if you move pkt_type around you also must adapt those constants */
+#ifdef __BIG_ENDIAN_BITFIELD
+#define PKT_TYPE_MAX	(7 << 5)
+#else
+#define PKT_TYPE_MAX	7
+#endif
+#define PKT_TYPE_OFFSET()	offsetof(struct sk_buff, __pkt_type_offset)
+
+	__u8			__pkt_type_offset[0];
 	__u8			pkt_type:3,
 				fclone:2,
 				ipvs_property:1,
diff --git a/net/core/filter.c b/net/core/filter.c
index dfc716f..601f28d 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -87,30 +87,6 @@ int sk_filter(struct sock *sk, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(sk_filter);
 
-/* Helper to find the offset of pkt_type in sk_buff structure. We want
- * to make sure its still a 3bit field starting at a byte boundary;
- * taken from arch/x86/net/bpf_jit_comp.c.
- */
-#ifdef __BIG_ENDIAN_BITFIELD
-#define PKT_TYPE_MAX	(7 << 5)
-#else
-#define PKT_TYPE_MAX	7
-#endif
-static unsigned int pkt_type_offset(void)
-{
-	struct sk_buff skb_probe = { .pkt_type = ~0, };
-	u8 *ct = (u8 *) &skb_probe;
-	unsigned int off;
-
-	for (off = 0; off < sizeof(struct sk_buff); off++) {
-		if (ct[off] == PKT_TYPE_MAX)
-			return off;
-	}
-
-	pr_err_once("Please fix %s, as pkt_type couldn't be found!\n", __func__);
-	return -1;
-}
-
 static u64 __skb_get_pay_offset(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
 {
 	return skb_get_poff((struct sk_buff *)(unsigned long) ctx);
@@ -190,11 +166,8 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
 		break;
 
 	case SKF_AD_OFF + SKF_AD_PKTTYPE:
-		*insn = BPF_LDX_MEM(BPF_B, BPF_REG_A, BPF_REG_CTX,
-				    pkt_type_offset());
-		if (insn->off < 0)
-			return false;
-		insn++;
+		*insn++ = BPF_LDX_MEM(BPF_B, BPF_REG_A, BPF_REG_CTX,
+				      PKT_TYPE_OFFSET());
 		*insn = BPF_ALU32_IMM(BPF_AND, BPF_REG_A, PKT_TYPE_MAX);
 #ifdef __BIG_ENDIAN_BITFIELD
 		insn++;
-- 
1.9.3
