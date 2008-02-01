From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 2/3] Generic HDLC - remove now unneeded hdlc_device_desc
Date: Fri, 01 Feb 2008 22:37:12 +0100
Message-ID: <m38x24nyt3.fsf@maximus.localdomain>
References: <m3ejbwnz2e.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:44472 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752120AbYBAVhP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 16:37:15 -0500
In-Reply-To: <m3ejbwnz2e.fsf@maximus.localdomain> (Krzysztof Halasa's message of "Fri\, 01 Feb 2008 22\:31\:37 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removes now unneeded struct hdlc_device_desc

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

diff --git a/drivers/net/wan/hdlc.c b/drivers/net/wan/hdlc.c
index d553e6f..39951d0 100644
--- a/drivers/net/wan/hdlc.c
+++ b/drivers/net/wan/hdlc.c
@@ -1,7 +1,7 @@
 /*
  * Generic HDLC support routines for Linux
  *
- * Copyright (C) 1999 - 2006 Krzysztof Halasa <khc@pm.waw.pl>
+ * Copyright (C) 1999 - 2008 Krzysztof Halasa <khc@pm.waw.pl>
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of version 2 of the GNU General Public License
@@ -39,7 +39,7 @@
 #include <net/net_namespace.h>
 
 
-static const char* version = "HDLC support module revision 1.21";
+static const char* version = "HDLC support module revision 1.22";
 
 #undef DEBUG_LINK
 
@@ -66,19 +66,15 @@ static struct net_device_stats *hdlc_get_stats(struct net_device *dev)
 static int hdlc_rcv(struct sk_buff *skb, struct net_device *dev,
 		    struct packet_type *p, struct net_device *orig_dev)
 {
-	struct hdlc_device_desc *desc = dev_to_desc(dev);
+	struct hdlc_device *hdlc = dev_to_hdlc(dev);
 
 	if (dev->nd_net != &init_net) {
 		kfree_skb(skb);
 		return 0;
 	}
 
-	if (desc->netif_rx)
-		return desc->netif_rx(skb);
-
-	desc->stats.rx_dropped++; /* Shouldn't happen */
-	dev_kfree_skb(skb);
-	return NET_RX_DROP;
+	BUG_ON(!hdlc->proto->netif_rx);
+	return hdlc->proto->netif_rx(skb);
 }
 
 
@@ -87,7 +83,7 @@ static inline void hdlc_proto_start(struct net_device *dev)
 {
 	hdlc_device *hdlc = dev_to_hdlc(dev);
 	if (hdlc->proto->start)
-		return hdlc->proto->start(dev);
+		hdlc->proto->start(dev);
 }
 
 
@@ -96,7 +92,7 @@ static inline void hdlc_proto_stop(struct net_device *dev)
 {
 	hdlc_device *hdlc = dev_to_hdlc(dev);
 	if (hdlc->proto->stop)
-		return hdlc->proto->stop(dev);
+		hdlc->proto->stop(dev);
 }
 
 
@@ -263,8 +259,7 @@ static void hdlc_setup(struct net_device *dev)
 struct net_device *alloc_hdlcdev(void *priv)
 {
 	struct net_device *dev;
-	dev = alloc_netdev(sizeof(struct hdlc_device_desc) +
-			   sizeof(hdlc_device), "hdlc%d", hdlc_setup);
+	dev = alloc_netdev(sizeof(struct hdlc_device), "hdlc%d", hdlc_setup);
 	if (dev)
 		dev_to_hdlc(dev)->priv = priv;
 	return dev;
@@ -281,7 +276,7 @@ void unregister_hdlc_device(struct net_device *dev)
 
 
 int attach_hdlc_protocol(struct net_device *dev, struct hdlc_proto *proto,
-			 int (*rx)(struct sk_buff *skb), size_t size)
+			 size_t size)
 {
 	detach_hdlc_protocol(dev);
 
@@ -297,7 +292,6 @@ int attach_hdlc_protocol(struct net_device *dev, struct hdlc_proto *proto,
 			return -ENOBUFS;
 		}
 	dev_to_hdlc(dev)->proto = proto;
-	dev_to_desc(dev)->netif_rx = rx;
 	return 0;
 }
 
diff --git a/drivers/net/wan/hdlc_cisco.c b/drivers/net/wan/hdlc_cisco.c
index 038a6e7..7133c68 100644
--- a/drivers/net/wan/hdlc_cisco.c
+++ b/drivers/net/wan/hdlc_cisco.c
@@ -250,7 +250,7 @@ static int cisco_rx(struct sk_buff *skb)
 	return NET_RX_DROP;
 
  rx_error:
-	dev_to_desc(dev)->stats.rx_errors++; /* Mark error */
+	dev_to_hdlc(dev)->stats.rx_errors++; /* Mark error */
 	dev_kfree_skb_any(skb);
 	return NET_RX_DROP;
 }
@@ -314,6 +314,7 @@ static struct hdlc_proto proto = {
 	.stop		= cisco_stop,
 	.type_trans	= cisco_type_trans,
 	.ioctl		= cisco_ioctl,
+	.netif_rx	= cisco_rx,
 	.module		= THIS_MODULE,
 };
 
@@ -360,7 +361,7 @@ static int cisco_ioctl(struct net_device *dev, struct ifreq *ifr)
 		if (result)
 			return result;
 
-		result = attach_hdlc_protocol(dev, &proto, cisco_rx,
+		result = attach_hdlc_protocol(dev, &proto,
 					      sizeof(struct cisco_state));
 		if (result)
 			return result;
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index 071a64c..ccd11be 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -957,7 +957,7 @@ static int fr_rx(struct sk_buff *skb)
 
 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
-		dev_to_desc(frad)->stats.rx_dropped++;
+		dev_to_hdlc(frad)->stats.rx_dropped++;
 		return NET_RX_DROP;
 	}
 
@@ -1018,7 +1018,7 @@ static int fr_rx(struct sk_buff *skb)
 	}
 
  rx_error:
-	dev_to_desc(frad)->stats.rx_errors++; /* Mark error */
+	dev_to_hdlc(frad)->stats.rx_errors++; /* Mark error */
 	dev_kfree_skb_any(skb);
 	return NET_RX_DROP;
 }
@@ -1219,6 +1219,7 @@ static struct hdlc_proto proto = {
 	.stop		= fr_stop,
 	.detach		= fr_destroy,
 	.ioctl		= fr_ioctl,
+	.netif_rx	= fr_rx,
 	.module		= THIS_MODULE,
 };
 
@@ -1277,7 +1278,7 @@ static int fr_ioctl(struct net_device *dev, struct ifreq *ifr)
 			return result;
 
 		if (dev_to_hdlc(dev)->proto != &proto) { /* Different proto */
-			result = attach_hdlc_protocol(dev, &proto, fr_rx,
+			result = attach_hdlc_protocol(dev, &proto,
 						      sizeof(struct frad_state));
 			if (result)
 				return result;
diff --git a/drivers/net/wan/hdlc_ppp.c b/drivers/net/wan/hdlc_ppp.c
index 519e155..10396d9 100644
--- a/drivers/net/wan/hdlc_ppp.c
+++ b/drivers/net/wan/hdlc_ppp.c
@@ -122,7 +122,7 @@ static int ppp_ioctl(struct net_device *dev, struct ifreq *ifr)
 		if (result)
 			return result;
 
-		result = attach_hdlc_protocol(dev, &proto, NULL,
+		result = attach_hdlc_protocol(dev, &proto,
 					      sizeof(struct ppp_state));
 		if (result)
 			return result;
diff --git a/drivers/net/wan/hdlc_raw.c b/drivers/net/wan/hdlc_raw.c
index e23bc66..bbbb819 100644
--- a/drivers/net/wan/hdlc_raw.c
+++ b/drivers/net/wan/hdlc_raw.c
@@ -82,7 +82,7 @@ static int raw_ioctl(struct net_device *dev, struct ifreq *ifr)
 		if (result)
 			return result;
 
-		result = attach_hdlc_protocol(dev, &proto, NULL,
+		result = attach_hdlc_protocol(dev, &proto,
 					      sizeof(raw_hdlc_proto));
 		if (result)
 			return result;
diff --git a/drivers/net/wan/hdlc_raw_eth.c b/drivers/net/wan/hdlc_raw_eth.c
index 8895394..11b16bd 100644
--- a/drivers/net/wan/hdlc_raw_eth.c
+++ b/drivers/net/wan/hdlc_raw_eth.c
@@ -96,7 +96,7 @@ static int raw_eth_ioctl(struct net_device *dev, struct ifreq *ifr)
 		if (result)
 			return result;
 
-		result = attach_hdlc_protocol(dev, &proto, NULL,
+		result = attach_hdlc_protocol(dev, &proto,
 					      sizeof(raw_hdlc_proto));
 		if (result)
 			return result;
diff --git a/drivers/net/wan/hdlc_x25.c b/drivers/net/wan/hdlc_x25.c
index cd7b22f..c15cc11 100644
--- a/drivers/net/wan/hdlc_x25.c
+++ b/drivers/net/wan/hdlc_x25.c
@@ -164,17 +164,17 @@ static void x25_close(struct net_device *dev)
 
 static int x25_rx(struct sk_buff *skb)
 {
-	struct hdlc_device_desc *desc = dev_to_desc(skb->dev);
+	struct hdlc_device *hdlc = dev_to_hdlc(skb->dev);
 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
-		desc->stats.rx_dropped++;
+		hdlc->stats.rx_dropped++;
 		return NET_RX_DROP;
 	}
 
 	if (lapb_data_received(skb->dev, skb) == LAPB_OK)
 		return NET_RX_SUCCESS;
 
-	desc->stats.rx_errors++;
+	hdlc->stats.rx_errors++;
 	dev_kfree_skb_any(skb);
 	return NET_RX_DROP;
 }
@@ -184,6 +184,7 @@ static struct hdlc_proto proto = {
 	.open		= x25_open,
 	.close		= x25_close,
 	.ioctl		= x25_ioctl,
+	.netif_rx	= x25_rx,
 	.module		= THIS_MODULE,
 };
 
@@ -211,8 +212,7 @@ static int x25_ioctl(struct net_device *dev, struct ifreq *ifr)
 		if (result)
 			return result;
 
-		if ((result = attach_hdlc_protocol(dev, &proto,
-						   x25_rx, 0)) != 0)
+		if ((result = attach_hdlc_protocol(dev, &proto, 0)))
 			return result;
 		dev->hard_start_xmit = x25_xmit;
 		dev->type = ARPHRD_X25;
diff --git a/include/linux/hdlc.h b/include/linux/hdlc.h
index db390c5..6115545 100644
--- a/include/linux/hdlc.h
+++ b/include/linux/hdlc.h
@@ -26,13 +26,6 @@
 #include <linux/netdevice.h>
 #include <linux/hdlc/ioctl.h>
 
-
-/* Used by all network devices here, pointed to by netdev_priv(dev) */
-struct hdlc_device_desc {
-	int (*netif_rx)(struct sk_buff *skb);
-	struct net_device_stats stats;
-};
-
 /* This structure is a private property of HDLC protocols.
    Hardware drivers have no interest here */
 
@@ -44,12 +37,15 @@ struct hdlc_proto {
 	void (*detach)(struct net_device *dev);
 	int (*ioctl)(struct net_device *dev, struct ifreq *ifr);
 	__be16 (*type_trans)(struct sk_buff *skb, struct net_device *dev);
+	int (*netif_rx)(struct sk_buff *skb);
 	struct module *module;
 	struct hdlc_proto *next; /* next protocol in the list */
 };
 
 
+/* Pointed to by dev->priv */
 typedef struct hdlc_device {
+	struct net_device_stats stats;
 	/* used by HDLC layer to take control over HDLC device from hw driver*/
 	int (*attach)(struct net_device *dev,
 		      unsigned short encoding, unsigned short parity);
@@ -83,18 +79,11 @@ void unregister_hdlc_protocol(struct hdlc_proto *proto);
 
 struct net_device *alloc_hdlcdev(void *priv);
 
-
-static __inline__ struct hdlc_device_desc* dev_to_desc(struct net_device *dev)
-{
-	return netdev_priv(dev);
-}
-
-static __inline__ hdlc_device* dev_to_hdlc(struct net_device *dev)
+static inline struct hdlc_device* dev_to_hdlc(struct net_device *dev)
 {
-	return netdev_priv(dev) + sizeof(struct hdlc_device_desc);
+	return dev->priv;
 }
 
-
 static __inline__ void debug_frame(const struct sk_buff *skb)
 {
 	int i;
@@ -116,13 +105,13 @@ int hdlc_open(struct net_device *dev);
 void hdlc_close(struct net_device *dev);
 
 int attach_hdlc_protocol(struct net_device *dev, struct hdlc_proto *proto,
-			 int (*rx)(struct sk_buff *skb), size_t size);
+			 size_t size);
 /* May be used by hardware driver to gain control over HDLC device */
 void detach_hdlc_protocol(struct net_device *dev);
 
 static __inline__ struct net_device_stats *hdlc_stats(struct net_device *dev)
 {
-	return &dev_to_desc(dev)->stats;
+	return &dev_to_hdlc(dev)->stats;
 }
 
 
