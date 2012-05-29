From: Felix Fietkau <nbd@openwrt.org>
Subject: [PATCH] skb: avoid unnecessary reallocations in __skb_cow
Date: Tue, 29 May 2012 15:35:08 +0200
Message-ID: <1338298508-40376-1-git-send-email-nbd@openwrt.org>
Cc: eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:58986 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750980Ab2E2NfO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2012 09:35:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At the beginning of __skb_cow, headroom gets set to a minimum of
NET_SKB_PAD. This causes unnecessary reallocations if the buffer was not
cloned and the headroom is just below NET_SKB_PAD, but still more than the
amount requested by the caller.
This was showing up frequently in my tests on VLAN tx, where
vlan_insert_tag calls skb_cow_head(skb, VLAN_HLEN).

Locally generated packets should have enough headroom, and for forward
paths, we already have NET_SKB_PAD bytes of headroom, so we don't need to
add any extra space here.

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
---
 include/linux/skbuff.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0e50171..b534a1b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1896,8 +1896,6 @@ static inline int __skb_cow(struct sk_buff *skb, unsigned int headroom,
 {
 	int delta = 0;
 
-	if (headroom < NET_SKB_PAD)
-		headroom = NET_SKB_PAD;
 	if (headroom > skb_headroom(skb))
 		delta = headroom - skb_headroom(skb);
 
-- 
1.7.3.2
