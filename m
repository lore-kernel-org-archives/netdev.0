From: David Miller <davem@davemloft.net>
Subject: [PATCH 10/14]: pkt_sched: Allocate anonymous qdisc handles in
 dev_queue namespace.
Date: Mon, 14 Jul 2008 16:00:24 -0700 (PDT)
Message-ID: <20080714.160024.28357939.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49275
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758544AbYGNXAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 19:00:23 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 378F1C8C187
	for <netdev@vger.kernel.org>; Mon, 14 Jul 2008 16:00:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When the user does not specify a specific handle, we should allocate
in the per-dev_queue namespace.

qdisc_lookup_dev() is no longer used, delete.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_api.c |   19 +++----------------
 1 files changed, 3 insertions(+), 16 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index cd5ff65..8473719 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -194,19 +194,6 @@ struct Qdisc *qdisc_lookup(struct netdev_queue *dev_queue, u32 handle)
 	return NULL;
 }
 
-static struct Qdisc *qdisc_lookup_dev(struct net_device *dev, u32 handle)
-{
-	unsigned int i;
-
-	for (i = 0; i < dev->num_tx_queues; i++) {
-		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
-		struct Qdisc *q = qdisc_lookup(txq, handle);
-		if (q)
-			return q;
-	}
-	return NULL;
-}
-
 static struct Qdisc *qdisc_leaf(struct Qdisc *p, u32 classid)
 {
 	unsigned long cl;
@@ -435,7 +422,7 @@ EXPORT_SYMBOL(qdisc_class_hash_remove);
 
 /* Allocate an unique handle from space managed by kernel */
 
-static u32 qdisc_alloc_handle(struct net_device *dev)
+static u32 qdisc_alloc_handle(struct netdev_queue *dev_queue)
 {
 	int i = 0x10000;
 	static u32 autohandle = TC_H_MAKE(0x80000000U, 0);
@@ -444,7 +431,7 @@ static u32 qdisc_alloc_handle(struct net_device *dev)
 		autohandle += TC_H_MAKE(0x10000U, 0);
 		if (autohandle == TC_H_MAKE(TC_H_ROOT, 0))
 			autohandle = TC_H_MAKE(0x80000000U, 0);
-	} while	(qdisc_lookup_dev(dev, autohandle) && --i > 0);
+	} while	(qdisc_lookup(dev_queue, autohandle) && --i > 0);
 
 	return i>0 ? autohandle : 0;
 }
@@ -589,7 +576,7 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 		handle = TC_H_MAKE(TC_H_INGRESS, 0);
 	} else {
 		if (handle == 0) {
-			handle = qdisc_alloc_handle(dev);
+			handle = qdisc_alloc_handle(dev_queue);
 			err = -ENOMEM;
 			if (handle == 0)
 				goto err_out_dev_put;
-- 
1.5.6.2.255.gbed62

