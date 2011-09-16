From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] wan: make LAPB callbacks const
Date: Fri, 16 Sep 2011 14:04:29 -0700
Message-ID: <20110916140429.4a144301@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42593 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932215Ab1IPVHg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 17:07:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is compile tested only.
Suggested by dumpster diving in PAX.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/wan/hdlc_x25.c  |   16 ++++++++--------
 drivers/net/wan/lapbether.c |    3 +--
 drivers/net/wan/x25_asy.c   |    3 +--
 include/linux/lapb.h        |    3 ++-
 include/net/lapb.h          |    2 +-
 net/lapb/lapb_iface.c       |   29 +++++++++++++++--------------
 6 files changed, 28 insertions(+), 28 deletions(-)

--- a/drivers/net/wan/hdlc_x25.c	2011-09-16 11:30:01.849087557 -0700
+++ b/drivers/net/wan/hdlc_x25.c	2011-09-16 11:31:04.901093255 -0700
@@ -134,15 +134,15 @@ static netdev_tx_t x25_xmit(struct sk_bu
 
 static int x25_open(struct net_device *dev)
 {
-	struct lapb_register_struct cb;
 	int result;
-
-	cb.connect_confirmation = x25_connected;
-	cb.connect_indication = x25_connected;
-	cb.disconnect_confirmation = x25_disconnected;
-	cb.disconnect_indication = x25_disconnected;
-	cb.data_indication = x25_data_indication;
-	cb.data_transmit = x25_data_transmit;
+	static const struct lapb_register_struct cb = {
+		.connect_confirmation = x25_connected,
+		.connect_indication = x25_connected,
+		.disconnect_confirmation = x25_disconnected,
+		.disconnect_indication = x25_disconnected,
+		.data_indication = x25_data_indication,
+		.data_transmit = x25_data_transmit,
+	};
 
 	result = lapb_register(dev, &cb);
 	if (result != LAPB_OK)
--- a/drivers/net/wan/lapbether.c	2011-09-16 11:31:22.609091232 -0700
+++ b/drivers/net/wan/lapbether.c	2011-09-16 11:31:30.597091736 -0700
@@ -259,14 +259,13 @@ static int lapbeth_set_mac_address(struc
 }
 
 
-static struct lapb_register_struct lapbeth_callbacks = {
+static const struct lapb_register_struct lapbeth_callbacks = {
 	.connect_confirmation    = lapbeth_connected,
 	.connect_indication      = lapbeth_connected,
 	.disconnect_confirmation = lapbeth_disconnected,
 	.disconnect_indication   = lapbeth_disconnected,
 	.data_indication         = lapbeth_data_indication,
 	.data_transmit           = lapbeth_data_transmit,
-
 };
 
 /*
--- a/drivers/net/wan/x25_asy.c	2011-09-16 11:31:38.833091828 -0700
+++ b/drivers/net/wan/x25_asy.c	2011-09-16 11:31:46.317091608 -0700
@@ -434,14 +434,13 @@ static void x25_asy_disconnected(struct
 	netif_rx(skb);
 }
 
-static struct lapb_register_struct x25_asy_callbacks = {
+static const struct lapb_register_struct x25_asy_callbacks = {
 	.connect_confirmation = x25_asy_connected,
 	.connect_indication = x25_asy_connected,
 	.disconnect_confirmation = x25_asy_disconnected,
 	.disconnect_indication = x25_asy_disconnected,
 	.data_indication = x25_asy_data_indication,
 	.data_transmit = x25_asy_data_transmit,
-
 };
 
 
--- a/include/linux/lapb.h	2011-09-16 11:32:21.021093958 -0700
+++ b/include/linux/lapb.h	2011-09-16 11:38:16.593110202 -0700
@@ -44,7 +44,8 @@ struct lapb_parms_struct {
 	unsigned int mode;
 };
 
-extern int lapb_register(struct net_device *dev, struct lapb_register_struct *callbacks);
+extern int lapb_register(struct net_device *dev,
+			 const struct lapb_register_struct *callbacks);
 extern int lapb_unregister(struct net_device *dev);
 extern int lapb_getparms(struct net_device *dev, struct lapb_parms_struct *parms);
 extern int lapb_setparms(struct net_device *dev, struct lapb_parms_struct *parms);
--- a/include/net/lapb.h	2011-09-16 11:32:21.037093954 -0700
+++ b/include/net/lapb.h	2011-09-16 11:34:34.361100045 -0700
@@ -95,7 +95,7 @@ struct lapb_cb {
 	struct sk_buff_head	write_queue;
 	struct sk_buff_head	ack_queue;
 	unsigned char		window;
-	struct lapb_register_struct callbacks;
+	const struct lapb_register_struct *callbacks;
 
 	/* FRMR control information */
 	struct lapb_frame	frmr_data;
--- a/net/lapb/lapb_iface.c	2011-09-16 11:32:21.053093960 -0700
+++ b/net/lapb/lapb_iface.c	2011-09-16 11:38:16.593110202 -0700
@@ -139,7 +139,8 @@ out:
 	return lapb;
 }
 
-int lapb_register(struct net_device *dev, struct lapb_register_struct *callbacks)
+int lapb_register(struct net_device *dev,
+		  const struct lapb_register_struct *callbacks)
 {
 	struct lapb_cb *lapb;
 	int rc = LAPB_BADTOKEN;
@@ -158,7 +159,7 @@ int lapb_register(struct net_device *dev
 		goto out;
 
 	lapb->dev       = dev;
-	lapb->callbacks = *callbacks;
+	lapb->callbacks = callbacks;
 
 	__lapb_insert_cb(lapb);
 
@@ -380,32 +381,32 @@ int lapb_data_received(struct net_device
 
 void lapb_connect_confirmation(struct lapb_cb *lapb, int reason)
 {
-	if (lapb->callbacks.connect_confirmation)
-		lapb->callbacks.connect_confirmation(lapb->dev, reason);
+	if (lapb->callbacks->connect_confirmation)
+		lapb->callbacks->connect_confirmation(lapb->dev, reason);
 }
 
 void lapb_connect_indication(struct lapb_cb *lapb, int reason)
 {
-	if (lapb->callbacks.connect_indication)
-		lapb->callbacks.connect_indication(lapb->dev, reason);
+	if (lapb->callbacks->connect_indication)
+		lapb->callbacks->connect_indication(lapb->dev, reason);
 }
 
 void lapb_disconnect_confirmation(struct lapb_cb *lapb, int reason)
 {
-	if (lapb->callbacks.disconnect_confirmation)
-		lapb->callbacks.disconnect_confirmation(lapb->dev, reason);
+	if (lapb->callbacks->disconnect_confirmation)
+		lapb->callbacks->disconnect_confirmation(lapb->dev, reason);
 }
 
 void lapb_disconnect_indication(struct lapb_cb *lapb, int reason)
 {
-	if (lapb->callbacks.disconnect_indication)
-		lapb->callbacks.disconnect_indication(lapb->dev, reason);
+	if (lapb->callbacks->disconnect_indication)
+		lapb->callbacks->disconnect_indication(lapb->dev, reason);
 }
 
 int lapb_data_indication(struct lapb_cb *lapb, struct sk_buff *skb)
 {
-	if (lapb->callbacks.data_indication)
-		return lapb->callbacks.data_indication(lapb->dev, skb);
+	if (lapb->callbacks->data_indication)
+		return lapb->callbacks->data_indication(lapb->dev, skb);
 
 	kfree_skb(skb);
 	return NET_RX_SUCCESS; /* For now; must be != NET_RX_DROP */
@@ -415,8 +416,8 @@ int lapb_data_transmit(struct lapb_cb *l
 {
 	int used = 0;
 
-	if (lapb->callbacks.data_transmit) {
-		lapb->callbacks.data_transmit(lapb->dev, skb);
+	if (lapb->callbacks->data_transmit) {
+		lapb->callbacks->data_transmit(lapb->dev, skb);
 		used = 1;
 	}
 
