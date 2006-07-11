From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] WAN: converting generic HDLC to use netif_dormant*()
Date: Tue, 11 Jul 2006 23:18:45 +0200
Message-ID: <m3veq3suve.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:5850 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S932130AbWGKVSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2006 17:18:49 -0400
To: Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patch converts generic HDLC (and WAN drivers using it) from
hdlc_set_carrier() to netif_dormant*() interface.
WAN hardware drivers should now use netif_carrier_on|off() like
other network drivers.

Please apply. Thanks.

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>
   
diff --git a/drivers/net/wan/c101.c b/drivers/net/wan/c101.c
index 43d854a..3796a59 100644
--- a/drivers/net/wan/c101.c
+++ b/drivers/net/wan/c101.c
@@ -116,27 +116,33 @@ static inline void openwin(card_t *card,
 #include "hd6457x.c"
 
 
+static inline void set_carrier(port_t *port)
+{
+	if (!sca_in(MSCI1_OFFSET + ST3, port) & ST3_DCD)
+		netif_carrier_on(port_to_dev(port));
+	else
+		netif_carrier_off(port_to_dev(port));
+}
+
+
 static void sca_msci_intr(port_t *port)
 {
-	struct net_device *dev = port_to_dev(port);
-	card_t* card = port_to_card(port);
-	u8 stat = sca_in(MSCI1_OFFSET + ST1, card); /* read MSCI ST1 status */
+	u8 stat = sca_in(MSCI1_OFFSET + ST1, port); /* read MSCI ST1 status */
 
 	/* Reset MSCI TX underrun status bit */
-	sca_out(stat & ST1_UDRN, MSCI0_OFFSET + ST1, card);
+	sca_out(stat & ST1_UDRN, MSCI0_OFFSET + ST1, port);
 
 	if (stat & ST1_UDRN) {
-		struct net_device_stats *stats = hdlc_stats(dev);
+		struct net_device_stats *stats = hdlc_stats(port_to_dev(port));
 		stats->tx_errors++; /* TX Underrun error detected */
 		stats->tx_fifo_errors++;
 	}
 
 	/* Reset MSCI CDCD status bit - uses ch#2 DCD input */
-	sca_out(stat & ST1_CDCD, MSCI1_OFFSET + ST1, card);
+	sca_out(stat & ST1_CDCD, MSCI1_OFFSET + ST1, port);
 
 	if (stat & ST1_CDCD)
-		hdlc_set_carrier(!(sca_in(MSCI1_OFFSET + ST3, card) & ST3_DCD),
-				 dev);
+		set_carrier(port);
 }
 
 
@@ -190,7 +196,7 @@ static int c101_open(struct net_device *
 	sca_out(IE1_UDRN, MSCI0_OFFSET + IE1, port);
 	sca_out(IE0_TXINT, MSCI0_OFFSET + IE0, port);
 
-	hdlc_set_carrier(!(sca_in(MSCI1_OFFSET + ST3, port) & ST3_DCD), dev);
+	set_carrier(port);
 	printk(KERN_DEBUG "0x%X\n", sca_in(MSCI1_OFFSET + ST3, port));
 
 	/* enable MSCI1 CDCD interrupt */
@@ -378,7 +384,7 @@ static int __init c101_run(unsigned long
 	}
 
 	sca_init_sync_port(card); /* Set up C101 memory */
-	hdlc_set_carrier(!(sca_in(MSCI1_OFFSET + ST3, card) & ST3_DCD), dev);
+	set_carrier(card);
 
 	printk(KERN_INFO "%s: Moxa C101 on IRQ%u,"
 	       " using %u TX + %u RX packets rings\n",
diff --git a/drivers/net/wan/hd6457x.c b/drivers/net/wan/hd6457x.c
index d374332..dce2bb3 100644
--- a/drivers/net/wan/hd6457x.c
+++ b/drivers/net/wan/hd6457x.c
@@ -168,6 +168,23 @@ static inline u32 buffer_offset(port_t *
 }
 
 
+static inline void sca_set_carrier(port_t *port)
+{
+	if (!(sca_in(get_msci(port) + ST3, port_to_card(port)) & ST3_DCD)) {
+#ifdef DEBUG_LINK
+		printk(KERN_DEBUG "%s: sca_set_carrier on\n",
+		       port_to_dev(port)->name);
+#endif
+		netif_carrier_on(port_to_dev(port));
+	} else {
+#ifdef DEBUG_LINK
+		printk(KERN_DEBUG "%s: sca_set_carrier off\n",
+		       port_to_dev(port)->name);
+#endif
+		netif_carrier_off(port_to_dev(port));
+	}
+}
+
 
 static void sca_init_sync_port(port_t *port)
 {
@@ -237,9 +254,7 @@ #endif
 			sca_out(DIR_BOFE, DIR_TX(phy_node(port)), card);
 		}
 	}
-
-	hdlc_set_carrier(!(sca_in(get_msci(port) + ST3, card) & ST3_DCD),
-			 port_to_dev(port));
+	sca_set_carrier(port);
 }
 
 
@@ -262,8 +277,7 @@ static inline void sca_msci_intr(port_t 
 	}
 
 	if (stat & ST1_CDCD)
-		hdlc_set_carrier(!(sca_in(msci + ST3, card) & ST3_DCD),
-				 port_to_dev(port));
+		sca_set_carrier(port);
 }
 #endif
 
@@ -566,7 +580,7 @@ #endif
    - all DMA interrupts
 */
 
-	hdlc_set_carrier(!(sca_in(msci + ST3, card) & ST3_DCD), dev);
+	sca_set_carrier(port);
 
 #ifdef __HD64570_H
 	/* MSCI TX INT and RX INT A IRQ enable */
diff --git a/drivers/net/wan/hdlc_cisco.c b/drivers/net/wan/hdlc_cisco.c
index 1fd0466..f289dab 100644
--- a/drivers/net/wan/hdlc_cisco.c
+++ b/drivers/net/wan/hdlc_cisco.c
@@ -192,9 +192,7 @@ static int cisco_rx(struct sk_buff *skb)
 					       "uptime %ud%uh%um%us)\n",
 					       dev->name, days, hrs,
 					       min, sec);
-#if 0
-					netif_carrier_on(dev);
-#endif
+					netif_dormant_off(dev);
 					hdlc->state.cisco.up = 1;
 				}
 			}
@@ -227,9 +225,7 @@ static void cisco_timer(unsigned long ar
 		       hdlc->state.cisco.settings.timeout * HZ)) {
 		hdlc->state.cisco.up = 0;
 		printk(KERN_INFO "%s: Link down\n", dev->name);
-#if 0
-		netif_carrier_off(dev);
-#endif
+		netif_dormant_on(dev);
 	}
 
 	cisco_keepalive_send(dev, CISCO_KEEPALIVE_REQ,
@@ -265,10 +261,7 @@ static void cisco_stop(struct net_device
 {
 	hdlc_device *hdlc = dev_to_hdlc(dev);
 	del_timer_sync(&hdlc->state.cisco.timer);
-#if 0
-	if (netif_carrier_ok(dev))
-		netif_carrier_off(dev);
-#endif
+	netif_dormant_on(dev);
 	hdlc->state.cisco.up = 0;
 	hdlc->state.cisco.request_sent = 0;
 }
@@ -328,6 +321,7 @@ int hdlc_cisco_ioctl(struct net_device *
 		dev->type = ARPHRD_CISCO;
 		dev->flags = IFF_POINTOPOINT | IFF_NOARP;
 		dev->addr_len = 0;
+		netif_dormant_on(dev);
 		return 0;
 	}
 
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index 523afe1..7bb737b 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -301,7 +301,7 @@ static int pvc_open(struct net_device *d
 	if (pvc->open_count++ == 0) {
 		hdlc_device *hdlc = dev_to_hdlc(pvc->master);
 		if (hdlc->state.fr.settings.lmi == LMI_NONE)
-			pvc->state.active = hdlc->carrier;
+			pvc->state.active = netif_carrier_ok(pvc->master);
 
 		pvc_carrier(pvc->state.active, pvc);
 		hdlc->state.fr.dce_changed = 1;
@@ -545,11 +545,7 @@ static void fr_set_link_state(int reliab
 
 	hdlc->state.fr.reliable = reliable;
 	if (reliable) {
-#if 0
-		if (!netif_carrier_ok(dev))
-			netif_carrier_on(dev);
-#endif
-
+		netif_dormant_off(dev);
 		hdlc->state.fr.n391cnt = 0; /* Request full status */
 		hdlc->state.fr.dce_changed = 1;
 
@@ -562,11 +558,7 @@ #endif
 			}
 		}
 	} else {
-#if 0
-		if (netif_carrier_ok(dev))
-			netif_carrier_off(dev);
-#endif
-
+		netif_dormant_on(dev);
 		while (pvc) {		/* Deactivate all PVCs */
 			pvc_carrier(0, pvc);
 			pvc->state.exist = pvc->state.active = 0;
diff --git a/drivers/net/wan/hdlc_generic.c b/drivers/net/wan/hdlc_generic.c
index 46cef8f..fa6da37 100644
--- a/drivers/net/wan/hdlc_generic.c
+++ b/drivers/net/wan/hdlc_generic.c
@@ -35,10 +35,11 @@ #include <linux/pkt_sched.h>
 #include <linux/inetdevice.h>
 #include <linux/lapb.h>
 #include <linux/rtnetlink.h>
+#include <linux/notifier.h>
 #include <linux/hdlc.h>
 
 
-static const char* version = "HDLC support module revision 1.18";
+static const char* version = "HDLC support module revision 1.19";
 
 #undef DEBUG_LINK
 
@@ -74,57 +75,51 @@ static int hdlc_rcv(struct sk_buff *skb,
 
 
 
-static void __hdlc_set_carrier_on(struct net_device *dev)
+static inline void hdlc_proto_start(struct net_device *dev)
 {
 	hdlc_device *hdlc = dev_to_hdlc(dev);
 	if (hdlc->proto.start)
 		return hdlc->proto.start(dev);
-#if 0
-#ifdef DEBUG_LINK
-	if (netif_carrier_ok(dev))
-		printk(KERN_ERR "hdlc_set_carrier_on(): already on\n");
-#endif
-	netif_carrier_on(dev);
-#endif
 }
 
 
 
-static void __hdlc_set_carrier_off(struct net_device *dev)
+static inline void hdlc_proto_stop(struct net_device *dev)
 {
 	hdlc_device *hdlc = dev_to_hdlc(dev);
 	if (hdlc->proto.stop)
 		return hdlc->proto.stop(dev);
-
-#if 0
-#ifdef DEBUG_LINK
-	if (!netif_carrier_ok(dev))
-		printk(KERN_ERR "hdlc_set_carrier_off(): already off\n");
-#endif
-	netif_carrier_off(dev);
-#endif
 }
 
 
 
-void hdlc_set_carrier(int on, struct net_device *dev)
+static int hdlc_device_event(struct notifier_block *this, unsigned long event,
+			     void *ptr)
 {
-	hdlc_device *hdlc = dev_to_hdlc(dev);
+	struct net_device *dev = ptr;
+	hdlc_device *hdlc;
 	unsigned long flags;
-	on = on ? 1 : 0;
+	int on;
+ 
+	if (dev->get_stats != hdlc_get_stats)
+		return NOTIFY_DONE; /* not an HDLC device */
+ 
+	if (event != NETDEV_CHANGE)
+		return NOTIFY_DONE; /* Only interrested in carrier changes */
+
+	on = netif_carrier_ok(dev);
 
 #ifdef DEBUG_LINK
-	printk(KERN_DEBUG "hdlc_set_carrier %i\n", on);
+	printk(KERN_DEBUG "%s: hdlc_device_event NETDEV_CHANGE, carrier %i\n",
+	       dev->name, on);
 #endif
 
+	hdlc = dev_to_hdlc(dev);
 	spin_lock_irqsave(&hdlc->state_lock, flags);
 
 	if (hdlc->carrier == on)
 		goto carrier_exit; /* no change in DCD line level */
 
-#ifdef DEBUG_LINK
-	printk(KERN_INFO "%s: carrier %s\n", dev->name, on ? "ON" : "off");
-#endif
 	hdlc->carrier = on;
 
 	if (!hdlc->open)
@@ -132,14 +127,15 @@ #endif
 
 	if (hdlc->carrier) {
 		printk(KERN_INFO "%s: Carrier detected\n", dev->name);
-		__hdlc_set_carrier_on(dev);
+		hdlc_proto_start(dev);
 	} else {
 		printk(KERN_INFO "%s: Carrier lost\n", dev->name);
-		__hdlc_set_carrier_off(dev);
+		hdlc_proto_stop(dev);
 	}
 
 carrier_exit:
 	spin_unlock_irqrestore(&hdlc->state_lock, flags);
+	return NOTIFY_DONE;
 }
 
 
@@ -166,7 +162,7 @@ #endif
 
 	if (hdlc->carrier) {
 		printk(KERN_INFO "%s: Carrier detected\n", dev->name);
-		__hdlc_set_carrier_on(dev);
+		hdlc_proto_start(dev);
 	} else
 		printk(KERN_INFO "%s: No carrier\n", dev->name);
 
@@ -191,7 +187,7 @@ #endif
 
 	hdlc->open = 0;
 	if (hdlc->carrier)
-		__hdlc_set_carrier_off(dev);
+		hdlc_proto_stop(dev);
 
 	spin_unlock_irq(&hdlc->state_lock);
 
@@ -324,7 +320,6 @@ MODULE_LICENSE("GPL v2");
 
 EXPORT_SYMBOL(hdlc_open);
 EXPORT_SYMBOL(hdlc_close);
-EXPORT_SYMBOL(hdlc_set_carrier);
 EXPORT_SYMBOL(hdlc_ioctl);
 EXPORT_SYMBOL(alloc_hdlcdev);
 EXPORT_SYMBOL(register_hdlc_device);
@@ -336,9 +331,18 @@ static struct packet_type hdlc_packet_ty
 };
 
 
+static struct notifier_block hdlc_notifier = {
+        .notifier_call = hdlc_device_event,
+};
+
+
 static int __init hdlc_module_init(void)
 {
+	int result;
+
 	printk(KERN_INFO "%s\n", version);
+	if ((result = register_netdevice_notifier(&hdlc_notifier)) != 0)
+                return result;
         dev_add_pack(&hdlc_packet_type);
 	return 0;
 }
@@ -348,6 +352,7 @@ static int __init hdlc_module_init(void)
 static void __exit hdlc_module_exit(void)
 {
 	dev_remove_pack(&hdlc_packet_type);
+	unregister_netdevice_notifier(&hdlc_notifier);
 }
 
 
diff --git a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
index 29a756d..006f3c5 100644
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -149,7 +149,10 @@ static inline void wanxl_cable_intr(port
 	printk(KERN_INFO "%s: %s%s module, %s cable%s%s\n",
 	       port->dev->name, pm, dte, cable, dsr, dcd);
 
-	hdlc_set_carrier(value & STATUS_CABLE_DCD, port->dev);
+	if (value & STATUS_CABLE_DCD)
+		netif_carrier_on(port->dev);
+	else
+		netif_carrier_off(port->dev);
 }
 
 
diff --git a/include/linux/hdlc.h b/include/linux/hdlc.h
index df695e9..9e46b25 100644
--- a/include/linux/hdlc.h
+++ b/include/linux/hdlc.h
@@ -224,8 +224,6 @@ static __inline__ void debug_frame(const
 int hdlc_open(struct net_device *dev);
 /* Must be called by hardware driver when HDLC device is being closed */
 void hdlc_close(struct net_device *dev);
-/* Called by hardware driver when DCD line level changes */
-void hdlc_set_carrier(int on, struct net_device *dev);
 
 /* May be used by hardware driver to gain control over HDLC device */
 static __inline__ void hdlc_proto_detach(hdlc_device *hdlc)
