From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 36/53] netns xfrm: xfrm_route_forward() in netns
Date: Tue, 25 Nov 2008 20:27:08 +0300
Message-ID: <1227634045-27534-36-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-7-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-8-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-9-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-10-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-11-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-12-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-13-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-14-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-15-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-16-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-17-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-18-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-19-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-20-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-21-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-22-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-23-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-24-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-25-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-26-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-27-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-28-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-29-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-30-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-31-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-32-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-33-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-34-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-35-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:41393 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754005AbYKYRZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:25:07 -0500
Received: by ey-out-2122.google.com with SMTP id 6so23517eyi.37
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:25:05 -0800 (PST)
In-Reply-To: <1227634045-27534-35-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/xfrm.h     |    4 +++-
 net/xfrm/xfrm_policy.c |    3 ++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 158848f..36c8cff 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1050,7 +1050,9 @@ extern int __xfrm_route_forward(struct sk_buff *skb, unsigned short family);
 
 static inline int xfrm_route_forward(struct sk_buff *skb, unsigned short family)
 {
-	return	!init_net.xfrm.policy_count[XFRM_POLICY_OUT] ||
+	struct net *net = dev_net(skb->dev);
+
+	return	!net->xfrm.policy_count[XFRM_POLICY_OUT] ||
 		(skb->dst->flags & DST_NOXFRM) ||
 		__xfrm_route_forward(skb, family);
 }
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 8097c99..54b50a2 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2044,6 +2044,7 @@ EXPORT_SYMBOL(__xfrm_policy_check);
 
 int __xfrm_route_forward(struct sk_buff *skb, unsigned short family)
 {
+	struct net *net = dev_net(skb->dev);
 	struct flowi fl;
 
 	if (xfrm_decode_session(skb, &fl, family) < 0) {
@@ -2052,7 +2053,7 @@ int __xfrm_route_forward(struct sk_buff *skb, unsigned short family)
 		return 0;
 	}
 
-	return xfrm_lookup(&init_net, &skb->dst, &fl, NULL, 0) == 0;
+	return xfrm_lookup(net, &skb->dst, &fl, NULL, 0) == 0;
 }
 EXPORT_SYMBOL(__xfrm_route_forward);
 
-- 
1.5.6.5

