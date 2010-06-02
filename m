From: Changli Gao <xiaosuo@gmail.com>
Subject: cls_u32: check unaligned data access
Date: Wed,  2 Jun 2010 23:15:47 +0800
Message-ID: <1275491747-29888-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:44364 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932573Ab0FBPQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 11:16:10 -0400
Received: by pvg16 with SMTP id 16so117774pvg.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 08:16:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

check unaligned data access

before accessing data, check if the corresponding address is aligned, and if
not, return -1.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/sched/cls_u32.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 4f52214..309d275 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -102,7 +102,8 @@ static int u32_classify(struct sk_buff *skb, struct tcf_proto *tp, struct tcf_re
 	} stack[TC_U32_MAXDEPTH];
 
 	struct tc_u_hnode *ht = (struct tc_u_hnode*)tp->root;
-	unsigned int off = skb_network_offset(skb);
+	unsigned int noff = skb_network_offset(skb);
+	unsigned int off = noff;
 	struct tc_u_knode *n;
 	int sdepth = 0;
 	int off2 = 0;
@@ -138,6 +139,8 @@ next_knode:
 			__be32 *data, _data;
 
 			toff = off + key->off + (off2 & key->offmask);
+			if ((toff - noff) % 4)
+				goto out;
 			data = skb_header_pointer(skb, toff, 4, &_data);
 			if (!data)
 				goto out;
@@ -188,6 +191,8 @@ check_terminal:
 		if (ht->divisor) {
 			__be32 *data, _data;
 
+			if ((off + n->sel.hoff - noff) % 4)
+				goto out;
 			data = skb_header_pointer(skb, off + n->sel.hoff, 4,
 						  &_data);
 			if (!data)
@@ -203,6 +208,8 @@ check_terminal:
 			if (n->sel.flags & TC_U32_VAROFFSET) {
 				__be16 *data, _data;
 
+				if ((off + n->sel.offoff - noff) % 2)
+					goto out;
 				data = skb_header_pointer(skb,
 							  off + n->sel.offoff,
 							  2, &_data);
