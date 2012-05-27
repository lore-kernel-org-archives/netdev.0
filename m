From: Felix Fietkau <nbd@openwrt.org>
Subject: [RFC] skb: avoid unnecessary reallocations in __skb_cow
Date: Sun, 27 May 2012 17:26:10 +0200
Message-ID: <1338132370-88299-1-git-send-email-nbd@openwrt.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:33211 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750926Ab2E0P0Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 May 2012 11:26:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At the beginning of __skb_cow, headroom gets set to a minimum of
NET_SKB_PAD. This causes unnecessary reallocations if the buffer was not
cloned and the headroom is just below NET_SKB_PAD, but still more than the
amount requested by the caller.
This was showing up frequently in my tests on VLAN tx, where
vlan_insert_tag calls skb_cow_head(skb, VLAN_HLEN).

Fix this by only setting the headroom delta if either there is less
headroom than specified by the caller, or if reallocation has to be done
anyway because the skb was cloned.

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
---
 include/linux/skbuff.h |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0e50171..1898471 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1894,12 +1894,15 @@ static inline int skb_clone_writable(const struct sk_buff *skb, unsigned int len
 static inline int __skb_cow(struct sk_buff *skb, unsigned int headroom,
 			    int cloned)
 {
+	unsigned int alloc_headroom = headroom;
 	int delta = 0;
 
 	if (headroom < NET_SKB_PAD)
-		headroom = NET_SKB_PAD;
-	if (headroom > skb_headroom(skb))
-		delta = headroom - skb_headroom(skb);
+		alloc_headroom = NET_SKB_PAD;
+	if (headroom > skb_headroom(skb) ||
+	    (cloned && alloc_headroom > skb_headroom(skb))) {
+		delta = alloc_headroom - skb_headroom(skb);
+	}
 
 	if (delta || cloned)
 		return pskb_expand_head(skb, ALIGN(delta, NET_SKB_PAD), 0,
-- 
1.7.3.2
