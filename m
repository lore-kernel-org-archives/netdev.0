From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] icmp: RCU conversion in icmp_address_reply()
Date: Tue, 08 Jun 2010 10:34:35 +0200
Message-ID: <1275986075.2475.73.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:50545 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999Ab0FHIei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 04:34:38 -0400
Received: by fxm8 with SMTP id 8so2663562fxm.19
        for <netdev@vger.kernel.org>; Tue, 08 Jun 2010 01:34:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- rcu_read_lock() already held by caller
- use __in_dev_get_rcu() instead of in_dev_get() / in_dev_put()
- remove goto out;

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/icmp.c |   12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index d65e921..bdb6c71 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -925,6 +925,7 @@ static void icmp_address(struct sk_buff *skb)
 /*
  * RFC1812 (4.3.3.9).	A router SHOULD listen all replies, and complain
  *			loudly if an inconsistency is found.
+ * called with rcu_read_lock()
  */
 
 static void icmp_address_reply(struct sk_buff *skb)
@@ -935,12 +936,12 @@ static void icmp_address_reply(struct sk_buff *skb)
 	struct in_ifaddr *ifa;
 
 	if (skb->len < 4 || !(rt->rt_flags&RTCF_DIRECTSRC))
-		goto out;
+		return;
 
-	in_dev = in_dev_get(dev);
+	in_dev = __in_dev_get_rcu(dev);
 	if (!in_dev)
-		goto out;
-	rcu_read_lock();
+		return;
+
 	if (in_dev->ifa_list &&
 	    IN_DEV_LOG_MARTIANS(in_dev) &&
 	    IN_DEV_FORWARD(in_dev)) {
@@ -958,9 +959,6 @@ static void icmp_address_reply(struct sk_buff *skb)
 			       mp, dev->name, &rt->rt_src);
 		}
 	}
-	rcu_read_unlock();
-	in_dev_put(in_dev);
-out:;
 }
 
 static void icmp_discard(struct sk_buff *skb)


