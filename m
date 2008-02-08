From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] [IGMP]: Optimize kfree_skb in igmp_rcv.
Date: Fri,  8 Feb 2008 17:14:17 +0300
Message-ID: <1202480057-23367-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:61992 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751782AbYBHONu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Feb 2008 09:13:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Merge error paths inside igmp_rcv.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/igmp.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index fe2e6cd..d3f34a7 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -922,13 +922,11 @@ int igmp_rcv(struct sk_buff *skb)
 	struct in_device *in_dev = in_dev_get(skb->dev);
 	int len = skb->len;
 
-	if (in_dev==NULL) {
-		kfree_skb(skb);
-		return 0;
-	}
+	if (in_dev == NULL)
+		goto drop;
 
 	if (!pskb_may_pull(skb, sizeof(struct igmphdr)))
-		goto drop;
+		goto drop_ref;
 
 	switch (skb->ip_summed) {
 	case CHECKSUM_COMPLETE:
@@ -938,7 +936,7 @@ int igmp_rcv(struct sk_buff *skb)
 	case CHECKSUM_NONE:
 		skb->csum = 0;
 		if (__skb_checksum_complete(skb))
-			goto drop;
+			goto drop_ref;
 	}
 
 	ih = igmp_hdr(skb);
@@ -972,8 +970,9 @@ int igmp_rcv(struct sk_buff *skb)
 		break;
 	}
 
-drop:
+drop_ref:
 	in_dev_put(in_dev);
+drop:
 	kfree_skb(skb);
 	return 0;
 }
-- 
1.5.3.rc5

