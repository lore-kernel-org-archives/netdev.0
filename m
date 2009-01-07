From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 38/42] uwb: convert devices to net_device_ops
Date: Tue, 06 Jan 2009 16:33:54 -0800
Message-ID: <20090107003349.555693360@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, david.vrabel@csr.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:60729 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757036AbZAGAyS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:54:18 -0500
Content-Disposition: inline; filename=uwb.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/uwb/i1480/i1480u-wlp/lc.c	2009-01-05 14:31:38.074069717 -0800
+++ b/drivers/uwb/i1480/i1480u-wlp/lc.c	2009-01-05 14:36:27.342318530 -0800
@@ -181,6 +181,15 @@ error:
 }
 #endif
 
+static const struct net_device_ops i1480u_netdev_ops = {
+	.ndo_open	= i1480u_open,
+	.ndo_stop 	= i1480u_stop,
+	.ndo_start_xmit = i1480u_hard_start_xmit,
+	.ndo_tx_timeout = i1480u_tx_timeout,
+	.ndo_set_config = i1480u_set_config,
+	.ndo_change_mtu = i1480u_change_mtu,
+};
+
 static
 int i1480u_add(struct i1480u *i1480u, struct usb_interface *iface)
 {
@@ -235,13 +244,7 @@ int i1480u_add(struct i1480u *i1480u, st
 	net_dev->features |= NETIF_F_HIGHDMA;
 	net_dev->watchdog_timeo = 5*HZ;		/* FIXME: a better default? */
 
-	net_dev->open = i1480u_open;
-	net_dev->stop = i1480u_stop;
-	net_dev->hard_start_xmit = i1480u_hard_start_xmit;
-	net_dev->tx_timeout = i1480u_tx_timeout;
-	net_dev->get_stats = i1480u_get_stats;
-	net_dev->set_config = i1480u_set_config;
-	net_dev->change_mtu = i1480u_change_mtu;
+	net_dev->netdev_ops = &i1480u_netdev_ops;
 
 #ifdef i1480u_FLOW_CONTROL
 	/* Notification endpoint setup (submitted when we open the device) */
--- a/drivers/uwb/i1480/i1480u-wlp/i1480u-wlp.h	2009-01-05 14:35:49.078569623 -0800
+++ b/drivers/uwb/i1480/i1480u-wlp/i1480u-wlp.h	2009-01-05 14:36:06.718845136 -0800
@@ -221,7 +221,6 @@ struct i1480u {
 	struct net_device *net_dev;
 
 	spinlock_t lock;
-	struct net_device_stats stats;
 
 	/* RX context handling */
 	struct sk_buff *rx_skb;
@@ -271,7 +270,6 @@ extern int i1480u_stop(struct net_device
 extern int i1480u_hard_start_xmit(struct sk_buff *, struct net_device *);
 extern void i1480u_tx_timeout(struct net_device *);
 extern int i1480u_set_config(struct net_device *, struct ifmap *);
-extern struct net_device_stats *i1480u_get_stats(struct net_device *);
 extern int i1480u_change_mtu(struct net_device *, int);
 extern void i1480u_uwb_notifs_cb(void *, struct uwb_dev *, enum uwb_notifs);
 
--- a/drivers/uwb/i1480/i1480u-wlp/netdev.c	2009-01-05 14:34:29.010821205 -0800
+++ b/drivers/uwb/i1480/i1480u-wlp/netdev.c	2009-01-05 14:36:19.862975627 -0800
@@ -262,15 +262,6 @@ int i1480u_stop(struct net_device *net_d
 	return 0;
 }
 
-
-/** Report statistics */
-struct net_device_stats *i1480u_get_stats(struct net_device *net_dev)
-{
-	struct i1480u *i1480u = netdev_priv(net_dev);
-	return &i1480u->stats;
-}
-
-
 /**
  *
  * Change the interface config--we probably don't have to do anything.
--- a/drivers/uwb/i1480/i1480u-wlp/rx.c	2009-01-05 14:37:21.409819109 -0800
+++ b/drivers/uwb/i1480/i1480u-wlp/rx.c	2009-01-05 14:46:48.222569803 -0800
@@ -167,7 +167,7 @@ do {							\
 do {							\
 	if (printk_ratelimit())				\
 		dev_err(&i1480u->usb_iface->dev, msg);	\
-	i1480u->stats.rx_dropped++;			\
+	i1480u->net_dev->stats.rx_dropped++;			\
 } while (0)
 
 
@@ -193,10 +193,8 @@ void i1480u_skb_deliver(struct i1480u *i
 	if (!should_parse)
 		goto out;
 	i1480u->rx_skb->protocol = eth_type_trans(i1480u->rx_skb, net_dev);
-	i1480u->stats.rx_packets++;
-	i1480u->stats.rx_bytes += i1480u->rx_untd_pkt_size;
-	net_dev->last_rx = jiffies;
-	/* FIXME: flow control: check netif_rx() retval */
+	net_dev->stats.rx_packets++;
+	net_dev->stats.rx_bytes += i1480u->rx_untd_pkt_size;
 
 	netif_rx(i1480u->rx_skb);		/* deliver */
 out:
--- a/drivers/uwb/i1480/i1480u-wlp/tx.c	2009-01-05 14:38:33.469819531 -0800
+++ b/drivers/uwb/i1480/i1480u-wlp/tx.c	2009-01-05 14:46:39.510569625 -0800
@@ -117,8 +117,8 @@ void i1480u_tx_cb(struct urb *urb)
 	switch (urb->status) {
 	case 0:
 		spin_lock_irqsave(&i1480u->lock, flags);
-		i1480u->stats.tx_packets++;
-		i1480u->stats.tx_bytes += urb->actual_length;
+		net_dev->stats.tx_packets++;
+		net_dev->stats.tx_bytes += urb->actual_length;
 		spin_unlock_irqrestore(&i1480u->lock, flags);
 		break;
 	case -ECONNRESET:	/* Not an error, but a controlled situation; */
@@ -530,7 +530,7 @@ int i1480u_hard_start_xmit(struct sk_buf
 	return NETDEV_TX_OK;
 error:
 	dev_kfree_skb_any(skb);
-	i1480u->stats.tx_dropped++;
+	net_dev->stats.tx_dropped++;
 out:
 	return NETDEV_TX_OK;
 }

-- 

