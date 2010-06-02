From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v2] cls_u32: use skb_header_pointer() to dereference data safely
Date: Wed,  2 Jun 2010 22:00:36 +0800
Message-ID: <1275487236-14452-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:44477 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755062Ab0FBOA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 10:00:59 -0400
Received: by pxi18 with SMTP id 18so2457564pxi.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 07:00:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

use skb_header_pointer() to dereference data safely

the original skb->data dereference isn't safe, as there isn't any skb->len or
skb_is_nonlinear() check. skb_header_pointer() is used instead in this patch.
And when the skb isn't long enough, we terminate the function u32_classify()
immediately with -1. Unaligned access is also fixed.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/sched/cls_u32.c |   51 ++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 38 insertions(+), 13 deletions(-)
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 9627542..e6dba22 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -41,6 +41,7 @@
 #include <net/netlink.h>
 #include <net/act_api.h>
 #include <net/pkt_cls.h>
+#include <asm/unaligned.h>
 
 struct tc_u_knode
 {
@@ -98,11 +99,11 @@ static int u32_classify(struct sk_buff *skb, struct tcf_proto *tp, struct tcf_re
 {
 	struct {
 		struct tc_u_knode *knode;
-		u8		  *ptr;
+		unsigned int	  off;
 	} stack[TC_U32_MAXDEPTH];
 
 	struct tc_u_hnode *ht = (struct tc_u_hnode*)tp->root;
-	u8 *ptr = skb_network_header(skb);
+	unsigned int off = skb_network_header(skb) - skb->data;
 	struct tc_u_knode *n;
 	int sdepth = 0;
 	int off2 = 0;
@@ -134,8 +135,14 @@ next_knode:
 #endif
 
 		for (i = n->sel.nkeys; i>0; i--, key++) {
-
-			if ((*(__be32*)(ptr+key->off+(off2&key->offmask))^key->val)&key->mask) {
+			unsigned int toff;
+			__be32 *data, _data;
+
+			toff = off + key->off + (off2 & key->offmask);
+			data = skb_header_pointer(skb, toff, 4, &_data);
+			if (!data)
+				goto out;
+			if ((get_unaligned(data) ^ key->val) & key->mask) {
 				n = n->next;
 				goto next_knode;
 			}
@@ -174,29 +181,46 @@ check_terminal:
 		if (sdepth >= TC_U32_MAXDEPTH)
 			goto deadloop;
 		stack[sdepth].knode = n;
-		stack[sdepth].ptr = ptr;
+		stack[sdepth].off = off;
 		sdepth++;
 
 		ht = n->ht_down;
 		sel = 0;
-		if (ht->divisor)
-			sel = ht->divisor&u32_hash_fold(*(__be32*)(ptr+n->sel.hoff), &n->sel,n->fshift);
-
+		if (ht->divisor) {
+			__be32 *data, _data;
+
+			data = skb_header_pointer(skb, off + n->sel.hoff, 4,
+						  &_data);
+			if (!data)
+				goto out;
+			sel = ht->divisor & u32_hash_fold(get_unaligned(data),
+							  &n->sel, n->fshift);
+		}
 		if (!(n->sel.flags&(TC_U32_VAROFFSET|TC_U32_OFFSET|TC_U32_EAT)))
 			goto next_ht;
 
 		if (n->sel.flags&(TC_U32_OFFSET|TC_U32_VAROFFSET)) {
 			off2 = n->sel.off + 3;
-			if (n->sel.flags&TC_U32_VAROFFSET)
-				off2 += ntohs(n->sel.offmask & *(__be16*)(ptr+n->sel.offoff)) >>n->sel.offshift;
+			if (n->sel.flags & TC_U32_VAROFFSET) {
+				__be16 *data, _data;
+
+				data = skb_header_pointer(skb,
+							  off + n->sel.offoff,
+							  2, &_data);
+				if (!data)
+					goto out;
+				off2 += ntohs(n->sel.offmask &
+					      get_unaligned(data)) >>
+					n->sel.offshift;
+			}
 			off2 &= ~3;
 		}
 		if (n->sel.flags&TC_U32_EAT) {
-			ptr += off2;
+			off += off2;
 			off2 = 0;
 		}
 
-		if (ptr < skb_tail_pointer(skb))
+		if (off < skb->len)
 			goto next_ht;
 	}
 
@@ -204,9 +228,10 @@ check_terminal:
 	if (sdepth--) {
 		n = stack[sdepth].knode;
 		ht = n->ht_up;
-		ptr = stack[sdepth].ptr;
+		off = stack[sdepth].off;
 		goto check_terminal;
 	}
+out:
 	return -1;
 
 deadloop:
