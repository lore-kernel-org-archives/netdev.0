From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [RFC PATCH] net, gro: fix the truesize of all fragments
Date: Fri, 20 Dec 2013 19:45:43 +0800
Message-ID: <1387539943-25521-1-git-send-email-zwu.kernel@gmail.com>
Cc: eric.dumazet@gmail.com, Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:58298 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755863Ab3LTLp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 06:45:58 -0500
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <zwu.kernel@gmail.com>;
	Fri, 20 Dec 2013 04:45:58 -0700
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 037636E8040
	for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 06:45:51 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp23033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBKBjrtx9044452
	for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 11:45:53 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBKBjraQ023223
	for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 06:45:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

When the truesize of all fragments was calculated, it didn't take
the first small piece of data into account.

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 net/core/skbuff.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2b6b863..0665bd6 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3027,9 +3027,12 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		frag->page_offset += offset;
 		skb_frag_size_sub(frag, offset);
 
-		/* all fragments truesize : remove (head size + sk_buff) */
+		/**
+		 * all fragments truesize :
+		 * remove (head size + sk_buff + offset)
+		 */
 		delta_truesize = skb->truesize -
-				 SKB_TRUESIZE(skb_end_offset(skb));
+				 SKB_TRUESIZE(skb_end_offset(skb) + offset);
 
 		skb->truesize -= skb->data_len;
 		skb->len -= skb->data_len;
@@ -3060,7 +3063,8 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		memcpy(frag + 1, skbinfo->frags, sizeof(*frag) * skbinfo->nr_frags);
 		/* We dont need to clear skbinfo->nr_frags here */
 
-		delta_truesize = skb->truesize - SKB_DATA_ALIGN(sizeof(struct sk_buff));
+		delta_truesize = skb->truesize -
+			SKB_DATA_ALIGN(sizeof(struct sk_buff)) - offset;
 		NAPI_GRO_CB(skb)->free = NAPI_GRO_FREE_STOLEN_HEAD;
 		goto done;
 	}
-- 
1.7.6.5
