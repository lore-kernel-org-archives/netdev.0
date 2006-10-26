From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/8] netpoll info leak
Date: Thu, 26 Oct 2006 15:46:50 -0700
Message-ID: <20061026225645.658927874@osdl.org>
References: <20061026225535.443288276@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:16315 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1423695AbWJZXBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 19:01:05 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=netpoll-info-leak.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After looking harder, Steve noticed that the netpoll
beast leaked a little every time it shutdown for a nap.
Not a big leak, but a nuisance kind of thing.

He took out his refcount duct tape and patched the
leak. It was overkill since there was already other
locking in that area, but it looked clean and wouldn't
attract fleas.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 include/linux/netpoll.h |    1 +
 net/core/netpoll.c      |   25 +++++++++++++++++++------
 2 files changed, 20 insertions(+), 6 deletions(-)

--- linux-2.6.orig/include/linux/netpoll.h
+++ linux-2.6/include/linux/netpoll.h
@@ -25,6 +25,7 @@ struct netpoll {
 };
 
 struct netpoll_info {
+	atomic_t refcnt;
 	spinlock_t poll_lock;
 	int poll_owner;
 	int tries;
--- linux-2.6.orig/net/core/netpoll.c
+++ linux-2.6/net/core/netpoll.c
@@ -649,8 +649,11 @@ int netpoll_setup(struct netpoll *np)
 		npinfo->tries = MAX_RETRIES;
 		spin_lock_init(&npinfo->rx_lock);
 		skb_queue_head_init(&npinfo->arp_tx);
-	} else
+		atomic_set(&npinfo->refcnt, 1);
+	} else {
 		npinfo = ndev->npinfo;
+		atomic_inc(&npinfo->refcnt);
+	}
 
 	if (!ndev->poll_controller) {
 		printk(KERN_ERR "%s: %s doesn't support polling, aborting.\n",
@@ -757,12 +760,22 @@ void netpoll_cleanup(struct netpoll *np)
 
 	if (np->dev) {
 		npinfo = np->dev->npinfo;
-		if (npinfo && npinfo->rx_np == np) {
-			spin_lock_irqsave(&npinfo->rx_lock, flags);
-			npinfo->rx_np = NULL;
-			npinfo->rx_flags &= ~NETPOLL_RX_ENABLED;
-			spin_unlock_irqrestore(&npinfo->rx_lock, flags);
+		if (npinfo) {
+			if (npinfo->rx_np == np) {
+				spin_lock_irqsave(&npinfo->rx_lock, flags);
+				npinfo->rx_np = NULL;
+				npinfo->rx_flags &= ~NETPOLL_RX_ENABLED;
+				spin_unlock_irqrestore(&npinfo->rx_lock, flags);
+			}
+
+			np->dev->npinfo = NULL;
+			if (atomic_dec_and_test(&npinfo->refcnt)) {
+				skb_queue_purge(&npinfo->arp_tx);
+
+				kfree(npinfo);
+			}
 		}
+
 		dev_put(np->dev);
 	}
 

--
Stephen Hemminger <shemminger@osdl.org>

