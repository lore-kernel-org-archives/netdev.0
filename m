From: Vitaliy Gusev <vgusev@openvz.org>
Subject: [PATCH] route: Fix caught BUG_ON during rt_secret_rebuild_oneshot()
Date: Tue, 16 Mar 2010 14:07:51 +0300
Message-ID: <201003161407.51925.vgusev@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:27909 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937749Ab0CPLDX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Mar 2010 07:03:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

route: Fix caught BUG_ON during rt_secret_rebuild_oneshot()

Call rt_secret_rebuild can cause BUG_ON(timer_pending(&net->ipv4.rt_secret_timer)) in
add_timer as there is not any synchronization for call rt_secret_rebuild_oneshot()
for the same net namespace.

Also this issue affects to rt_secret_reschedule().

Thus use mod_timer enstead.

Signed-off-by: Vitaliy Gusev <vgusev@openvz.org>

---
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 4f11faa..8a77318 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -922,10 +922,8 @@ static void rt_secret_rebuild_oneshot(struct net *net)
 {
 	del_timer_sync(&net->ipv4.rt_secret_timer);
 	rt_cache_invalidate(net);
-	if (ip_rt_secret_interval) {
-		net->ipv4.rt_secret_timer.expires += ip_rt_secret_interval;
-		add_timer(&net->ipv4.rt_secret_timer);
-	}
+	if (ip_rt_secret_interval)
+		mod_timer(&net->ipv4.rt_secret_timer, jiffies + ip_rt_secret_interval);
 }
 
 static void rt_emergency_hash_rebuild(struct net *net)
@@ -3072,22 +3070,20 @@ static void rt_secret_reschedule(int old)
 	rtnl_lock();
 	for_each_net(net) {
 		int deleted = del_timer_sync(&net->ipv4.rt_secret_timer);
+		long time;
 
 		if (!new)
 			continue;
 
 		if (deleted) {
-			long time = net->ipv4.rt_secret_timer.expires - jiffies;
+			time = net->ipv4.rt_secret_timer.expires - jiffies;
 
 			if (time <= 0 || (time += diff) <= 0)
 				time = 0;
-
-			net->ipv4.rt_secret_timer.expires = time;
 		} else
-			net->ipv4.rt_secret_timer.expires = new;
+			time = new;
 
-		net->ipv4.rt_secret_timer.expires += jiffies;
-		add_timer(&net->ipv4.rt_secret_timer);
+		mod_timer(&net->ipv4.rt_secret_timer, jiffies + time);
 	}
 	rtnl_unlock();
 }
