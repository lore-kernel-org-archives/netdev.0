From: Stefano Brivio <sbrivio@redhat.com>
Subject: [PATCH net] ipv4: Don't override return code from ip_route_input_noref()
Date: Thu, 31 Aug 2017 18:11:41 +0200
Message-ID: <c4d8970306e614ac139cf2f33ab5e6bb73b30154.1504194307.git.sbrivio@redhat.com>
Cc: Sabrina Dubroca <sdubroca@redhat.com>, Wei Wang <weiwan@google.com>
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58380 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751662AbdHaQMa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 31 Aug 2017 12:12:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After ip_route_input() calls ip_route_input_noref(), another
check on skb_dst() is done, but if this fails, we shouldn't
override the return code from ip_route_input_noref(), as it
could have been more specific (i.e. -EHOSTUNREACH).

This also saves one call to skb_dst_force_safe() and one to
skb_dst() in case the ip_route_input_noref() check fails.

Reported-by: Sabrina Dubroca <sdubroca@redhat.com>
Fixes: ad65a2f05695 ("ipv4: call dst_hold_safe() properly")
Signed-off-by: Stefano Brivio <sbrivio@redhat.com>
---
 include/net/route.h | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index cb0a76d9dde1..1b09a9368c68 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -189,10 +189,11 @@ static inline int ip_route_input(struct sk_buff *skb, __be32 dst, __be32 src,
 
 	rcu_read_lock();
 	err = ip_route_input_noref(skb, dst, src, tos, devin);
-	if (!err)
+	if (!err) {
 		skb_dst_force_safe(skb);
-	if (!skb_dst(skb))
-		err = -EINVAL;
+		if (!skb_dst(skb))
+			err = -EINVAL;
+	}
 	rcu_read_unlock();
 
 	return err;
-- 
2.9.4
