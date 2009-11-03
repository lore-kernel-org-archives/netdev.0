From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] em_meta: avoid one dev_put()
Date: Tue, 03 Nov 2009 22:38:49 +0100
Message-ID: <4AF0A2E9.1080505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34430 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755239AbZKCVir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 16:38:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another rcu conversion to avoid one dev_hold()/dev_put() pair

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/em_meta.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index 18d85d2..8e8d836 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -303,17 +303,17 @@ META_COLLECTOR(var_sk_bound_if)
 {
 	SKIP_NONLOCAL(skb);
 
-	 if (skb->sk->sk_bound_dev_if == 0) {
+	if (skb->sk->sk_bound_dev_if == 0) {
 		dst->value = (unsigned long) "any";
 		dst->len = 3;
-	 } else  {
+	} else {
 		struct net_device *dev;
 
-		dev = dev_get_by_index(&init_net, skb->sk->sk_bound_dev_if);
+		rcu_read_lock();
+		dev = dev_get_by_index_rcu(&init_net, skb->sk->sk_bound_dev_if);
 		*err = var_dev(dev, dst);
-		if (dev)
-			dev_put(dev);
-	 }
+		rcu_read_unlock();
+	}
 }
 
 META_COLLECTOR(int_sk_refcnt)
