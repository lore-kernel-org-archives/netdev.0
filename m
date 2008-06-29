From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] net: em_cmp.c use unaligned access helpers
Date: Sun, 29 Jun 2008 16:20:37 -0700
Message-ID: <1214781637.6037.13.camel@brick>
References: <1214428440.6908.1.camel@brick>
	 <20080627.201649.95998057.davem@davemloft.net>
	 <20080629095424.GM20815@postel.suug.ch>
	 <20080629095538.GN20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:14639 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752528AbYF2XUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2008 19:20:46 -0400
Received: by wa-out-1112.google.com with SMTP id j37so1012083waf.23
        for <netdev@vger.kernel.org>; Sun, 29 Jun 2008 16:20:45 -0700 (PDT)
In-Reply-To: <20080629095538.GN20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Explicitly check the endianness and use the appropriate unaligned
access helpers rather than conditionally byteswapping after the
unaligned access.

Fixes a bug on big-endian machines where be16/be32_to_cpu are no-ops
and would miss byteswapping in the le case.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Dave, here's a complete patch if you want to apply.

 net/sched/em_cmp.c |   17 +++++++----------
 1 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/net/sched/em_cmp.c b/net/sched/em_cmp.c
index cc49c93..afd2d7a 100644
--- a/net/sched/em_cmp.c
+++ b/net/sched/em_cmp.c
@@ -14,6 +14,7 @@
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
 #include <linux/tc_ematch/tc_em_cmp.h>
+#include <asm/unaligned.h>
 #include <net/pkt_cls.h>
 
 static inline int cmp_needs_transformation(struct tcf_em_cmp *cmp)
@@ -37,23 +38,19 @@ static int em_cmp_match(struct sk_buff *skb, struct tcf_ematch *em,
 			break;
 
 		case TCF_EM_ALIGN_U16:
-			val = *ptr << 8;
-			val |= *(ptr+1);
-
 			if (cmp_needs_transformation(cmp))
-				val = be16_to_cpu(val);
+				val = get_unaligned_le16(ptr);
+			else
+				val = get_unaligned_be16(ptr);
 			break;
 
 		case TCF_EM_ALIGN_U32:
 			/* Worth checking boundries? The branching seems
 			 * to get worse. Visit again. */
-			val = *ptr << 24;
-			val |= *(ptr+1) << 16;
-			val |= *(ptr+2) << 8;
-			val |= *(ptr+3);
-
 			if (cmp_needs_transformation(cmp))
-				val = be32_to_cpu(val);
+				val = get_unaligned_le32(ptr);
+			else
+				val = get_unaligned_be32(ptr);
 			break;
 
 		default:
-- 
1.5.6.1.179.g18c1f



