From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] net: em_cmp.c use unaligned access helpers
Date: Wed, 25 Jun 2008 14:14:00 -0700
Message-ID: <1214428440.6908.1.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:54526 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825AbYFYVOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 17:14:03 -0400
Received: by yx-out-2324.google.com with SMTP id 31so730340yxl.1
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2008 14:14:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both locations are loading a big-endian value in cpu-endianness.  The
be32/be16_to_cpu immediately afterwards seems suspect.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 net/sched/em_cmp.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/sched/em_cmp.c b/net/sched/em_cmp.c
index cc49c93..56f1eae 100644
--- a/net/sched/em_cmp.c
+++ b/net/sched/em_cmp.c
@@ -15,6 +15,7 @@
 #include <linux/skbuff.h>
 #include <linux/tc_ematch/tc_em_cmp.h>
 #include <net/pkt_cls.h>
+#include <asm/unaligned.h>
 
 static inline int cmp_needs_transformation(struct tcf_em_cmp *cmp)
 {
@@ -37,9 +38,7 @@ static int em_cmp_match(struct sk_buff *skb, struct tcf_ematch *em,
 			break;
 
 		case TCF_EM_ALIGN_U16:
-			val = *ptr << 8;
-			val |= *(ptr+1);
-
+			val = get_unaligned_be16(ptr);
 			if (cmp_needs_transformation(cmp))
 				val = be16_to_cpu(val);
 			break;
@@ -47,11 +46,7 @@ static int em_cmp_match(struct sk_buff *skb, struct tcf_ematch *em,
 		case TCF_EM_ALIGN_U32:
 			/* Worth checking boundries? The branching seems
 			 * to get worse. Visit again. */
-			val = *ptr << 24;
-			val |= *(ptr+1) << 16;
-			val |= *(ptr+2) << 8;
-			val |= *(ptr+3);
-
+			val = get_unaligned_be32(ptr);
 			if (cmp_needs_transformation(cmp))
 				val = be32_to_cpu(val);
 			break;
-- 
1.5.6.290.gc4e15



