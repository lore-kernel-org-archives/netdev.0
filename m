From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH] net: em_cmp.c use unaligned access helpers
Date: Fri, 04 Jul 2008 19:10:40 -0700
Message-ID: <1215223840.27271.7.camel@brick>
References: <1214428440.6908.1.camel@brick>
	 <20080627.201649.95998057.davem@davemloft.net>
	 <20080629095424.GM20815@postel.suug.ch> <1214762490.6037.9.camel@brick>
	 <20080629232638.GO20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:16629 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831AbYGECKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 22:10:42 -0400
Received: by wa-out-1112.google.com with SMTP id j37so919444waf.23
        for <netdev@vger.kernel.org>; Fri, 04 Jul 2008 19:10:42 -0700 (PDT)
In-Reply-To: <20080629232638.GO20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-06-30 at 01:26 +0200, Thomas Graf wrote:
> * Harvey Harrison <harvey.harrison@gmail.com> 2008-06-29 11:01
> > OK, but be16/32_to_cpu is a no-op on be-arches, so there is a bug here on
> > big-endian machines as they won't switch it back, your simplified patch
> > is actually a bugfix in that case.
> 
> I noticed that my change wouldn't be correct. The point is to allow
> userspace to convert the filter values to big endian once, supply them
> to the kernel and compare big endian values directly. The be16/32_to_cpu
> convertion is available to support greater-than/lesser-than on little
> endian architectures.

Thomas, maybe I'm just being slow, put if it's always a be-value, why
not the following:

From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] net: em_cmp.c use unaligned access helper

ptr pointers to a big endian value, instead of constructing a be
value and conditionally byteswapping on little-endian arches, use
the unaligned to access helpers return a cpu-endian value.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 net/sched/em_cmp.c |   20 +++-----------------
 1 files changed, 3 insertions(+), 17 deletions(-)

diff --git a/net/sched/em_cmp.c b/net/sched/em_cmp.c
index cc49c93..6e64af1 100644
--- a/net/sched/em_cmp.c
+++ b/net/sched/em_cmp.c
@@ -14,13 +14,9 @@
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
 #include <linux/tc_ematch/tc_em_cmp.h>
+#include <asm/unaligned.h>
 #include <net/pkt_cls.h>
 
-static inline int cmp_needs_transformation(struct tcf_em_cmp *cmp)
-{
-	return unlikely(cmp->flags & TCF_EM_CMP_TRANS);
-}
-
 static int em_cmp_match(struct sk_buff *skb, struct tcf_ematch *em,
 			struct tcf_pkt_info *info)
 {
@@ -37,23 +33,13 @@ static int em_cmp_match(struct sk_buff *skb, struct tcf_ematch *em,
 			break;
 
 		case TCF_EM_ALIGN_U16:
-			val = *ptr << 8;
-			val |= *(ptr+1);
-
-			if (cmp_needs_transformation(cmp))
-				val = be16_to_cpu(val);
+			val = get_unaligned_be16(ptr);
 			break;
 
 		case TCF_EM_ALIGN_U32:
 			/* Worth checking boundries? The branching seems
 			 * to get worse. Visit again. */
-			val = *ptr << 24;
-			val |= *(ptr+1) << 16;
-			val |= *(ptr+2) << 8;
-			val |= *(ptr+3);
-
-			if (cmp_needs_transformation(cmp))
-				val = be32_to_cpu(val);
+			val = get_unaligned_be32(ptr);
 			break;
 
 		default:
-- 
1.5.6.1.322.ge904b



