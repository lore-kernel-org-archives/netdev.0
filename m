From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] act_pedit: access skb->data safely
Date: Wed,  2 Jun 2010 22:55:02 +0800
Message-ID: <1275490502-22608-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:56930 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755579Ab0FBOzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 10:55:18 -0400
Received: by pwj2 with SMTP id 2so1731147pwj.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 07:55:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

access skb->data safely

we should use skb_header_pointer() and skb_store_bits() to access skb->data to
handle small or non-linear skbs.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/sched/act_pedit.c |   24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index fdbd0b7..50e3d94 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -125,7 +125,7 @@ static int tcf_pedit(struct sk_buff *skb, struct tc_action *a,
 {
 	struct tcf_pedit *p = a->priv;
 	int i, munged = 0;
-	u8 *pptr;
+	unsigned int off;
 
 	if (!(skb->tc_verd & TC_OK2MUNGE)) {
 		/* should we set skb->cloned? */
@@ -134,7 +134,7 @@ static int tcf_pedit(struct sk_buff *skb, struct tc_action *a,
 		}
 	}
 
-	pptr = skb_network_header(skb);
+	off = skb_network_offset(skb);
 
 	spin_lock(&p->tcf_lock);
 
@@ -144,17 +144,17 @@ static int tcf_pedit(struct sk_buff *skb, struct tc_action *a,
 		struct tc_pedit_key *tkey = p->tcfp_keys;
 
 		for (i = p->tcfp_nkeys; i > 0; i--, tkey++) {
-			u32 *ptr;
+			u32 *ptr, _data;
 			int offset = tkey->off;
 
 			if (tkey->offmask) {
-				if (skb->len > tkey->at) {
-					 char *j = pptr + tkey->at;
-					 offset += ((*j & tkey->offmask) >>
-						   tkey->shift);
-				} else {
+				char *d, _d;
+
+				d = skb_header_pointer(skb, off + tkey->at, 1,
+						       &_d);
+				if (!d)
 					goto bad;
-				}
+				offset += (*d & tkey->offmask) >> tkey->shift;
 			}
 
 			if (offset % 4) {
@@ -169,9 +169,13 @@ static int tcf_pedit(struct sk_buff *skb, struct tc_action *a,
 				goto bad;
 			}
 
-			ptr = (u32 *)(pptr+offset);
+			ptr = skb_header_pointer(skb, off + offset, 4, &_data);
+			if (!ptr)
+				goto bad;
 			/* just do it, baby */
 			*ptr = ((*ptr & tkey->mask) ^ tkey->val);
+			if (ptr == &_data)
+				skb_store_bits(skb, off + offset, ptr, 4);
 			munged++;
 		}
 
