From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/5] netpoll: cleanup queued transmit
Date: Mon, 23 Oct 2006 12:02:59 -0700
Message-ID: <20061023120259.50d3f2e0@dxpl.pdx.osdl.net>
References: <20061020134826.75dd1cba@freekitty>
 <20061020.140149.125893169.davem@davemloft.net>
 <20061020153027.3bed8c86@dxpl.pdx.osdl.net>
 <20061022.204220.78710782.davem@davemloft.net>
 <20061023115111.0d69846e@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965075AbWJWTEx@vger.kernel.org>
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061023115111.0d69846e@dxpl.pdx.osdl.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch changes the queued transmit path of netpoll, to
use similar logic to the non-queued path. We don't want netpoll
messages going into NIT and network qdisc logic.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- netpoll.orig/net/core/netpoll.c
+++ netpoll/net/core/netpoll.c
@@ -51,13 +51,27 @@ static atomic_t trapped;
 static void zap_completion_queue(void);
 static void arp_reply(struct sk_buff *skb);
 
+static void queue_process(void *);
+static DECLARE_WORK(send_queue, queue_process, NULL);
+
 static void queue_process(void *p)
 {
 	struct sk_buff *skb;
 
-	while ((skb = skb_dequeue(&netpoll_txq)))
-		dev_queue_xmit(skb);
+ 	while ((skb = skb_dequeue(&netpoll_txq))) {
+ 		struct net_device *dev = skb->dev;
 
+ 		netif_tx_lock_bh(dev);
+ 		if (netif_queue_stopped(dev) ||
+ 		    dev->hard_start_xmit(skb, dev) != NETDEV_TX_OK) {
+ 			skb_queue_head(&netpoll_txq, skb);
+ 			netif_tx_unlock_bh(dev);
+
+ 			schedule_delayed_work(&send_queue, 1);
+ 			return;
+ 		}
+ 		netif_tx_unlock_bh(dev);
+ 	}
 }
 
 static void queue_purge(struct net_device *dev)
@@ -77,8 +91,6 @@ static void queue_purge(struct net_devic
 	spin_unlock_irqrestore(&netpoll_txq.lock, flags);
 }
 
-static DECLARE_WORK(send_queue, queue_process, NULL);
-
 void netpoll_queue(struct sk_buff *skb)
 {
 	skb_queue_tail(&netpoll_txq, skb);
