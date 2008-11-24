From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH net-next] pcmcia: compile error from "convert to net_device_ops"
Date: Mon, 24 Nov 2008 11:25:15 +0800
Message-ID: <492A1E9B.6020700@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61969 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751955AbYKXDZc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Nov 2008 22:25:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/pcmcia/axnet_cs.c:907: error: static declaration of 'ei_tx_timeout' follows non-static declaration
drivers/net/pcmcia/../8390.h:36: error: previous declaration of 'ei_tx_timeout' was here
drivers/net/pcmcia/axnet_cs.c:1056: error: static declaration of 'ei_start_xmit' follows non-static declaration
drivers/net/pcmcia/../8390.h:37: error: previous declaration of 'ei_start_xmit' was here
make[3]: *** [drivers/net/pcmcia/axnet_cs.o] Error 1
make[2]: *** [drivers/net/pcmcia] Error 2
make[1]: *** [drivers/net] Error 2
make: *** [drivers] Error 2

This bug comes from commit 4e4fd4e485ad63a9074ff09a9b53ffc7a5c594ec
(ne2k: convert to net_device_ops).

Cc: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 2aca8df..e853de9 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -904,7 +904,7 @@ int ei_debug = 1;
 /* Index to functions. */
 static void ei_tx_intr(struct net_device *dev);
 static void ei_tx_err(struct net_device *dev);
-static void ei_tx_timeout(struct net_device *dev);
+void ei_tx_timeout(struct net_device *dev);
 static void ei_receive(struct net_device *dev);
 static void ei_rx_overrun(struct net_device *dev);
 
@@ -956,8 +956,10 @@ static int ax_open(struct net_device *dev)
 #ifdef HAVE_TX_TIMEOUT
 	/* The card I/O part of the driver (e.g. 3c503) can hook a Tx timeout
 	    wrapper that does e.g. media check & then calls ei_tx_timeout. */
+#ifdef CONFIG_COMPAT_NET_DEV_OPS
 	if (dev->tx_timeout == NULL)
 		 dev->tx_timeout = ei_tx_timeout;
+#endif
 	if (dev->watchdog_timeo <= 0)
 		 dev->watchdog_timeo = TX_TIMEOUT;
 #endif
@@ -1008,7 +1010,7 @@ static int ax_close(struct net_device *dev)
  * completed (or failed) - i.e. never posted a Tx related interrupt.
  */
 
-static void ei_tx_timeout(struct net_device *dev)
+void ei_tx_timeout(struct net_device *dev)
 {
 	long e8390_base = dev->base_addr;
 	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
@@ -1043,7 +1045,8 @@ static void ei_tx_timeout(struct net_device *dev)
 	spin_unlock_irqrestore(&ei_local->page_lock, flags);
 	netif_wake_queue(dev);
 }
-    
+EXPORT_SYMBOL_GPL(ei_tx_timeout);
+
 /**
  * ei_start_xmit - begin packet transmission
  * @skb: packet to be sent
@@ -1052,7 +1055,7 @@ static void ei_tx_timeout(struct net_device *dev)
  * Sends a packet to an 8390 network device.
  */
  
-static int ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
+int ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	long e8390_base = dev->base_addr;
 	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
@@ -1168,6 +1171,7 @@ static int ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
     
 	return 0;
 }
+EXPORT_SYMBOL_GPL(ei_start_xmit);
 
 /**
  * ax_interrupt - handle the interrupts from an 8390
@@ -1717,8 +1721,10 @@ static void axdev_setup(struct net_device *dev)
     
 	ei_local = (struct ei_device *)netdev_priv(dev);
 	spin_lock_init(&ei_local->page_lock);
-    
+
+#ifdef CONFIG_COMPAT_NET_DEV_OPS
 	dev->hard_start_xmit = &ei_start_xmit;
+#endif
 	dev->get_stats	= get_stats;
 	dev->set_multicast_list = &set_multicast_list;
 

