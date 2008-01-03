From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH 2/2] NET: Clone the sk_buff 'iif' field in __skb_clone()
Date: Thu, 03 Jan 2008 12:25:45 -0500
Message-ID: <20080103172545.14445.95317.stgit@flek.americas.hpqcorp.net>
References: <20080103171649.14445.65274.stgit@flek.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:10224 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752036AbYACRZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 12:25:47 -0500
In-Reply-To: <20080103171649.14445.65274.stgit@flek.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both NetLabel and SELinux (other LSMs may grow to use it as well) rely on the
'iif' field to determine the receiving network interface of inbound packets.
Unfortunately, at present this field is not preserved across a skb clone
operation which can lead to garbage values if the cloned skb is sent back
through the network stack.  This patch corrects this problem by properly
copying the 'iif' field in __skb_clone() and removing the 'iif' field
assignment from skb_act_clone() since it is no longer needed.

Also, while we are here, get rid of that silly C() macro.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 include/net/sch_generic.h |    1 -
 net/core/skbuff.c         |   20 +++++++++-----------
 2 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index c926551..4c3b351 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -325,7 +325,6 @@ static inline struct sk_buff *skb_act_clone(struct sk_buff *skb, gfp_t gfp_mask)
 		n->tc_verd = SET_TC_VERD(n->tc_verd, 0);
 		n->tc_verd = CLR_TC_OK2MUNGE(n->tc_verd);
 		n->tc_verd = CLR_TC_MUNGED(n->tc_verd);
-		n->iif = skb->iif;
 	}
 	return n;
 }
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5b4ce9b..c726cd4 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -407,31 +407,29 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 
 static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
 {
-#define C(x) n->x = skb->x
-
 	n->next = n->prev = NULL;
 	n->sk = NULL;
 	__copy_skb_header(n, skb);
 
-	C(len);
-	C(data_len);
-	C(mac_len);
+	n->iif = skb->iif;
+	n->len = skb->len;
+	n->data_len = skb->data_len;
+	n->mac_len = skb->mac_len;
 	n->cloned = 1;
 	n->hdr_len = skb->nohdr ? skb_headroom(skb) : skb->hdr_len;
 	n->nohdr = 0;
 	n->destructor = NULL;
-	C(truesize);
+	n->truesize = skb->truesize;
 	atomic_set(&n->users, 1);
-	C(head);
-	C(data);
-	C(tail);
-	C(end);
+	n->head = skb->head;
+	n->data = skb->data;
+	n->tail = skb->tail;
+	n->end = skb->end;
 
 	atomic_inc(&(skb_shinfo(skb)->dataref));
 	skb->cloned = 1;
 
 	return n;
-#undef C
 }
 
 /**

