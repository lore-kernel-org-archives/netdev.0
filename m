From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] cls_u32: use skb_copy_bits() to dereference data safely
Date: Mon, 31 May 2010 10:24:25 +0800
Message-ID: <1275272665-19047-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:40703 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755314Ab0EaCZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 May 2010 22:25:19 -0400
Received: by pvg11 with SMTP id 11so1137644pvg.19
        for <netdev@vger.kernel.org>; Sun, 30 May 2010 19:25:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

use skb_copy_bits() to dereference data safely

the original skb->data dereference isn't safe, as there isn't any skb->len or
skb_is_nonlinear() check. skb_copy_bits() is used instead in this patch. And
when the skb isn't long enough, we terminate the function u32_classify()
immediately with -1.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/sched/cls_u32.c |   40 +++++++++++++++++++++++++++++-----------
 1 file changed, 29 insertions(+), 11 deletions(-)
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 9627542..db35197 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -98,11 +98,11 @@ static int u32_classify(struct sk_buff *skb, struct tcf_proto *tp, struct tcf_re
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
@@ -134,8 +134,13 @@ next_knode:
 #endif
 
 		for (i = n->sel.nkeys; i>0; i--, key++) {
+			unsigned int toff;
+			__be32 data;
 
-			if ((*(__be32*)(ptr+key->off+(off2&key->offmask))^key->val)&key->mask) {
+			toff = off + key->off + (off2 & key->offmask);
+			if (skb_copy_bits(skb, toff, &data, 4))
+				goto out;
+			if ((data ^ key->val) & key->mask) {
 				n = n->next;
 				goto next_knode;
 			}
@@ -174,29 +179,41 @@ check_terminal:
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
+		if (ht->divisor) {
+			__be32 data;
 
+			if (skb_copy_bits(skb, off + n->sel.hoff, &data, 4))
+				goto out;
+			sel = ht->divisor & u32_hash_fold(data, &n->sel,
+							  n->fshift);
+		}
 		if (!(n->sel.flags&(TC_U32_VAROFFSET|TC_U32_OFFSET|TC_U32_EAT)))
 			goto next_ht;
 
 		if (n->sel.flags&(TC_U32_OFFSET|TC_U32_VAROFFSET)) {
 			off2 = n->sel.off + 3;
-			if (n->sel.flags&TC_U32_VAROFFSET)
-				off2 += ntohs(n->sel.offmask & *(__be16*)(ptr+n->sel.offoff)) >>n->sel.offshift;
+			if (n->sel.flags & TC_U32_VAROFFSET) {
+				__be16 data;
+
+				if (skb_copy_bits(skb, off + n->sel.offoff,
+						  &data, 2))
+					goto out;
+				off2 += ntohs(n->sel.offmask & data) >>
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
 
@@ -204,9 +221,10 @@ check_terminal:
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
