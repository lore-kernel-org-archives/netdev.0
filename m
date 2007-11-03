From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 02/11] netpoll: netpoll_poll cleanup
Date: Sat, 03 Nov 2007 11:43:16 -0700
Message-ID: <20071103184338.516371353@linux-foundation.org>
References: <20071103184314.216145305@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49905 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758113AbXKCXgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2007 19:36:39 -0400
Content-Disposition: inline; filename=netpoll-poll-cleanup.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Restructure code slightly to improve readability:
  * dereference device once
  * change obvious while() loop
  * let poll_napi() handle null list itself

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/net/core/netpoll.c	2007-11-03 10:02:50.000000000 -0700
+++ b/net/core/netpoll.c	2007-11-03 11:40:27.000000000 -0700
@@ -139,16 +139,15 @@ static int poll_one_napi(struct netpoll_
 	return budget - work;
 }
 
-static void poll_napi(struct netpoll *np)
+static void poll_napi(struct net_device *dev)
 {
-	struct netpoll_info *npinfo = np->dev->npinfo;
-	struct napi_struct *napi;
 	int budget = 16;
+	struct napi_struct *napi;
 
-	list_for_each_entry(napi, &np->dev->napi_list, dev_list) {
+	list_for_each_entry(napi, &dev->napi_list, dev_list) {
 		if (napi->poll_owner != smp_processor_id() &&
 		    spin_trylock(&napi->poll_lock)) {
-			budget = poll_one_napi(npinfo, napi, budget);
+			budget = poll_one_napi(dev->npinfo, napi, budget);
 			spin_unlock(&napi->poll_lock);
 
 			if (!budget)
@@ -159,30 +158,27 @@ static void poll_napi(struct netpoll *np
 
 static void service_arp_queue(struct netpoll_info *npi)
 {
-	struct sk_buff *skb;
+	if (npi) {
+		struct sk_buff *skb;
 
-	if (unlikely(!npi))
-		return;
-
-	skb = skb_dequeue(&npi->arp_tx);
-
-	while (skb != NULL) {
-		arp_reply(skb);
-		skb = skb_dequeue(&npi->arp_tx);
+		while ( (skb = skb_dequeue(&npi->arp_tx)) )
+			arp_reply(skb);
 	}
 }
 
 void netpoll_poll(struct netpoll *np)
 {
-	if (!np->dev || !netif_running(np->dev) || !np->dev->poll_controller)
+	struct net_device *dev = np->dev;
+
+	if (!dev || !netif_running(dev) || !dev->poll_controller)
 		return;
 
 	/* Process pending work on NIC */
-	np->dev->poll_controller(np->dev);
-	if (!list_empty(&np->dev->napi_list))
-		poll_napi(np);
+	dev->poll_controller(dev);
+
+	poll_napi(dev);
 
-	service_arp_queue(np->dev->npinfo);
+	service_arp_queue(dev->npinfo);
 
 	zap_completion_queue();
 }

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

