From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/3] netpoll: use device xmit directly
Date: Fri, 20 Oct 2006 15:32:44 -0700
Message-ID: <20061020153244.6fcde6f5@dxpl.pdx.osdl.net>
References: <20061020084015.5c559326@localhost.localdomain>
	<20061020.134209.85688168.davem@davemloft.net>
	<20061020134826.75dd1cba@freekitty>
	<20061020.140149.125893169.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030374AbWJTWfb@vger.kernel.org>
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061020.140149.125893169.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For most normal sends, the netpoll code was using the dev->hard_start_xmit
directly. If it got busy, it would process later, but this code path uses
dev_queue_xmit() and that code would send the skb through NIT and other
stuff that netpoll doesn't want.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- netpoll.orig/net/core/netpoll.c
+++ netpoll/net/core/netpoll.c
@@ -51,17 +51,28 @@ static atomic_t trapped;
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
+	while ((skb = skb_dequeue(&netpoll_txq))) {
+		struct net_device *dev = skb->dev;
+		netif_tx_lock_bh(dev);
+		if (netif_queue_stopped(dev) ||
+		    dev->hard_start_xmit(skb, dev) != NETDEV_TX_OK) {
+			skb_queue_head(&netpoll_txq, skb);
+			netif_tx_unlock_bh(dev);
 
+			schedule_delayed_work(&send_queue, 1);
+			break;
+		}
+		netif_tx_unlock_bh(dev);
+	}
 }
 
-static DECLARE_WORK(send_queue, queue_process, NULL);
-
 void netpoll_queue(struct sk_buff *skb)
 {
 	skb_queue_tail(&netpoll_txq, skb);
