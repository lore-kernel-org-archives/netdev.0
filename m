From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH] net: export pkt_type_offset() helper
Date: Wed,  3 Sep 2014 00:03:58 +0400
Message-ID: <1409688238-3152-1-git-send-email-kda@linux-powerpc.org>
Cc: Denis Kirjanov <kda@linux-powerpc.org>,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Daniel Borkmann <dborkman@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:40575 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754164AbaIBUaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 16:30:22 -0400
Received: by mail-la0-f42.google.com with SMTP id mc6so8592104lab.1
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 13:30:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we have 2 pkt_type_offset functions doing
the same thing and spread across the architecture files.
Let's use the generic helper routine.

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
Cc: Markos Chandras <markos.chandras@imgtec.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Daniel Borkmann <dborkman@redhat.com>
---
 arch/mips/net/bpf_jit.c      | 21 ---------------------
 arch/s390/net/bpf_jit_comp.c | 38 ++++----------------------------------
 include/linux/filter.h       |  7 +++++++
 net/core/filter.c            |  7 +------
 4 files changed, 12 insertions(+), 61 deletions(-)

diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 05a5661..08ff823 100644
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
diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index 61e45b7..34383d1 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -223,37 +223,6 @@ static void bpf_jit_epilogue(struct bpf_jit *jit)
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
@@ -753,12 +722,13 @@ call_fn:	/* lg %r1,<d(function)>(%r13) */
 		}
 		break;
 	case BPF_ANC | SKF_AD_PKTTYPE:
-		if (pkt_type_offset < 0)
+		offset = pkt_type_offset();
+		if (offset < 0)
 			goto out;
 		/* lhi %r5,0 */
 		EMIT4(0xa7580000);
-		/* ic %r5,<d(pkt_type_offset)>(%r2) */
-		EMIT4_DISP(0x43502000, pkt_type_offset);
+		/* ic %r5,<d(offset)>(%r2) */
+		EMIT4_DISP(0x43502000, offset);
 		/* srl %r5,5 */
 		EMIT4_DISP(0x88500000, 5);
 		break;
diff --git a/include/linux/filter.h b/include/linux/filter.h
index a5227ab..97e0549 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -424,6 +424,13 @@ static inline void *bpf_load_pointer(const struct sk_buff *skb, int k,
 	return bpf_internal_load_pointer_neg_helper(skb, k, size);
 }
 
+#ifdef __BIG_ENDIAN_BITFIELD
+#define PKT_TYPE_MAX	(7 << 5)
+#else
+#define PKT_TYPE_MAX    7
+#endif
+unsigned int pkt_type_offset(void);
+
 #ifdef CONFIG_BPF_JIT
 #include <stdarg.h>
 #include <linux/linkage.h>
diff --git a/net/core/filter.c b/net/core/filter.c
index d814b8a..b4a2e00 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -91,12 +91,7 @@ EXPORT_SYMBOL(sk_filter);
  * to make sure its still a 3bit field starting at a byte boundary;
  * taken from arch/x86/net/bpf_jit_comp.c.
  */
-#ifdef __BIG_ENDIAN_BITFIELD
-#define PKT_TYPE_MAX	(7 << 5)
-#else
-#define PKT_TYPE_MAX	7
-#endif
-static unsigned int pkt_type_offset(void)
+unsigned int pkt_type_offset(void)
 {
 	struct sk_buff skb_probe = { .pkt_type = ~0, };
 	u8 *ct = (u8 *) &skb_probe;
-- 
2.0.0
