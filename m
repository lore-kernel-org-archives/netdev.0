From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/8] generic_hdlc: Update to current logging forms
Date: Sun, 26 Jun 2011 22:01:28 -0700
Message-ID: <d9186716ad410d64b1e09b39408a2f232f178260.1309150684.git.joe@perches.com>
References: <cover.1309150683.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3216 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755583Ab1F0FB4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2011 01:01:56 -0400
In-Reply-To: <cover.1309150683.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use pr_fmt, pr_<level> and netdev_<level> as appropriate.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wan/c101.c       |   30 +++++++-------
 drivers/net/wan/hd64570.c    |    8 ++--
 drivers/net/wan/hd64572.c    |    8 ++--
 drivers/net/wan/hdlc.c       |   16 ++++---
 drivers/net/wan/hdlc_cisco.c |   21 ++++------
 drivers/net/wan/hdlc_fr.c    |   96 +++++++++++++++++++-----------------------
 drivers/net/wan/hdlc_ppp.c   |    9 ++--
 drivers/net/wan/hdlc_x25.c   |   12 ++---
 drivers/net/wan/n2.c         |   42 +++++++++---------
 drivers/net/wan/pc300too.c   |   36 +++++++--------
 drivers/net/wan/pci200syn.c  |   29 ++++++-------
 drivers/net/wan/wanxl.c      |   90 ++++++++++++++++++---------------------
 12 files changed, 186 insertions(+), 211 deletions(-)

diff --git a/drivers/net/wan/c101.c b/drivers/net/wan/c101.c
index 4ac85a0..54f995f 100644
--- a/drivers/net/wan/c101.c
+++ b/drivers/net/wan/c101.c
@@ -14,6 +14,8 @@
  *    Moxa C101 User's Manual
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/capability.h>
@@ -313,44 +315,44 @@ static int __init c101_run(unsigned long irq, unsigned long winbase)
 	int result;
 
 	if (irq<3 || irq>15 || irq == 6) /* FIXME */ {
-		printk(KERN_ERR "c101: invalid IRQ value\n");
+		pr_err("invalid IRQ value\n");
 		return -ENODEV;
 	}
 
 	if (winbase < 0xC0000 || winbase > 0xDFFFF || (winbase & 0x3FFF) !=0) {
-		printk(KERN_ERR "c101: invalid RAM value\n");
+		pr_err("invalid RAM value\n");
 		return -ENODEV;
 	}
 
 	card = kzalloc(sizeof(card_t), GFP_KERNEL);
 	if (card == NULL) {
-		printk(KERN_ERR "c101: unable to allocate memory\n");
+		pr_err("unable to allocate memory\n");
 		return -ENOBUFS;
 	}
 
 	card->dev = alloc_hdlcdev(card);
 	if (!card->dev) {
-		printk(KERN_ERR "c101: unable to allocate memory\n");
+		pr_err("unable to allocate memory\n");
 		kfree(card);
 		return -ENOBUFS;
 	}
 
 	if (request_irq(irq, sca_intr, 0, devname, card)) {
-		printk(KERN_ERR "c101: could not allocate IRQ\n");
+		pr_err("could not allocate IRQ\n");
 		c101_destroy_card(card);
 		return -EBUSY;
 	}
 	card->irq = irq;
 
 	if (!request_mem_region(winbase, C101_MAPPED_RAM_SIZE, devname)) {
-		printk(KERN_ERR "c101: could not request RAM window\n");
+		pr_err("could not request RAM window\n");
 		c101_destroy_card(card);
 		return -EBUSY;
 	}
 	card->phy_winbase = winbase;
 	card->win0base = ioremap(winbase, C101_MAPPED_RAM_SIZE);
 	if (!card->win0base) {
-		printk(KERN_ERR "c101: could not map I/O address\n");
+		pr_err("could not map I/O address\n");
 		c101_destroy_card(card);
 		return -EFAULT;
 	}
@@ -381,7 +383,7 @@ static int __init c101_run(unsigned long irq, unsigned long winbase)
 
 	result = register_hdlc_device(dev);
 	if (result) {
-		printk(KERN_WARNING "c101: unable to register hdlc device\n");
+		pr_warn("unable to register hdlc device\n");
 		c101_destroy_card(card);
 		return result;
 	}
@@ -389,10 +391,8 @@ static int __init c101_run(unsigned long irq, unsigned long winbase)
 	sca_init_port(card); /* Set up C101 memory */
 	set_carrier(card);
 
-	printk(KERN_INFO "%s: Moxa C101 on IRQ%u,"
-	       " using %u TX + %u RX packets rings\n",
-	       dev->name, card->irq,
-	       card->tx_ring_buffers, card->rx_ring_buffers);
+	netdev_info(dev, "Moxa C101 on IRQ%u, using %u TX + %u RX packets rings\n",
+		    card->irq, card->tx_ring_buffers, card->rx_ring_buffers);
 
 	*new_card = card;
 	new_card = &card->next_card;
@@ -405,12 +405,12 @@ static int __init c101_init(void)
 {
 	if (hw == NULL) {
 #ifdef MODULE
-		printk(KERN_INFO "c101: no card initialized\n");
+		pr_info("no card initialized\n");
 #endif
 		return -EINVAL;	/* no parameters specified, abort */
 	}
 
-	printk(KERN_INFO "%s\n", version);
+	pr_info("%s\n", version);
 
 	do {
 		unsigned long irq, ram;
@@ -428,7 +428,7 @@ static int __init c101_init(void)
 			return first_card ? 0 : -EINVAL;
 	}while(*hw++ == ':');
 
-	printk(KERN_ERR "c101: invalid hardware parameters\n");
+	pr_err("invalid hardware parameters\n");
 	return first_card ? 0 : -EINVAL;
 }
 
diff --git a/drivers/net/wan/hd64570.c b/drivers/net/wan/hd64570.c
index a3ea27c..33b67d8 100644
--- a/drivers/net/wan/hd64570.c
+++ b/drivers/net/wan/hd64570.c
@@ -582,8 +582,8 @@ static void sca_dump_rings(struct net_device *dev)
 	       sca_in(DSR_RX(phy_node(port)), card), port->rxin,
 	       sca_in(DSR_RX(phy_node(port)), card) & DSR_DE ? "" : "in");
 	for (cnt = 0; cnt < port_to_card(port)->rx_ring_buffers; cnt++)
-		printk(" %02X", readb(&(desc_address(port, cnt, 0)->stat)));
-	printk(KERN_CONT "\n");
+		pr_cont(" %02X", readb(&(desc_address(port, cnt, 0)->stat)));
+	pr_cont("\n");
 
 	printk(KERN_DEBUG "TX ring: CDA=%u EDA=%u DSR=%02X in=%u "
 	       "last=%u %sactive",
@@ -593,8 +593,8 @@ static void sca_dump_rings(struct net_device *dev)
 	       sca_in(DSR_TX(phy_node(port)), card) & DSR_DE ? "" : "in");
 
 	for (cnt = 0; cnt < port_to_card(port)->tx_ring_buffers; cnt++)
-		printk(" %02X", readb(&(desc_address(port, cnt, 1)->stat)));
-	printk("\n");
+		pr_cont(" %02X", readb(&(desc_address(port, cnt, 1)->stat)));
+	pr_cont("\n");
 
 	printk(KERN_DEBUG "MSCI: MD: %02x %02x %02x, ST: %02x %02x %02x %02x,"
 	       " FST: %02x CST: %02x %02x\n",
diff --git a/drivers/net/wan/hd64572.c b/drivers/net/wan/hd64572.c
index e305274..efc0db1 100644
--- a/drivers/net/wan/hd64572.c
+++ b/drivers/net/wan/hd64572.c
@@ -530,8 +530,8 @@ static void sca_dump_rings(struct net_device *dev)
 	       sca_in(DSR_RX(port->chan), card), port->rxin,
 	       sca_in(DSR_RX(port->chan), card) & DSR_DE ? "" : "in");
 	for (cnt = 0; cnt < port->card->rx_ring_buffers; cnt++)
-		printk(" %02X", readb(&(desc_address(port, cnt, 0)->stat)));
-	printk(KERN_CONT "\n");
+		pr_cont(" %02X", readb(&(desc_address(port, cnt, 0)->stat)));
+	pr_cont("\n");
 
 	printk(KERN_DEBUG "TX ring: CDA=%u EDA=%u DSR=%02X in=%u "
 	       "last=%u %sactive",
@@ -541,8 +541,8 @@ static void sca_dump_rings(struct net_device *dev)
 	       sca_in(DSR_TX(port->chan), card) & DSR_DE ? "" : "in");
 
 	for (cnt = 0; cnt < port->card->tx_ring_buffers; cnt++)
-		printk(" %02X", readb(&(desc_address(port, cnt, 1)->stat)));
-	printk("\n");
+		pr_cont(" %02X", readb(&(desc_address(port, cnt, 1)->stat)));
+	pr_cont("\n");
 
 	printk(KERN_DEBUG "MSCI: MD: %02x %02x %02x,"
 	       " ST: %02x %02x %02x %02x %02x, FST: %02x CST: %02x %02x\n",
diff --git a/drivers/net/wan/hdlc.c b/drivers/net/wan/hdlc.c
index 5d4bb61..10cc7df 100644
--- a/drivers/net/wan/hdlc.c
+++ b/drivers/net/wan/hdlc.c
@@ -22,6 +22,8 @@
  * - proto->start() and stop() are called with spin_lock_irq held.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/errno.h>
 #include <linux/hdlc.h>
 #include <linux/if_arp.h>
@@ -130,10 +132,10 @@ static int hdlc_device_event(struct notifier_block *this, unsigned long event,
 		goto carrier_exit;
 
 	if (hdlc->carrier) {
-		printk(KERN_INFO "%s: Carrier detected\n", dev->name);
+		netdev_info(dev, "Carrier detected\n");
 		hdlc_proto_start(dev);
 	} else {
-		printk(KERN_INFO "%s: Carrier lost\n", dev->name);
+		netdev_info(dev, "Carrier lost\n");
 		hdlc_proto_stop(dev);
 	}
 
@@ -165,10 +167,10 @@ int hdlc_open(struct net_device *dev)
 	spin_lock_irq(&hdlc->state_lock);
 
 	if (hdlc->carrier) {
-		printk(KERN_INFO "%s: Carrier detected\n", dev->name);
+		netdev_info(dev, "Carrier detected\n");
 		hdlc_proto_start(dev);
 	} else
-		printk(KERN_INFO "%s: No carrier\n", dev->name);
+		netdev_info(dev, "No carrier\n");
 
 	hdlc->open = 1;
 
@@ -281,8 +283,8 @@ int attach_hdlc_protocol(struct net_device *dev, struct hdlc_proto *proto,
 	if (size)
 		if ((dev_to_hdlc(dev)->state = kmalloc(size,
 						       GFP_KERNEL)) == NULL) {
-			printk(KERN_WARNING "Memory squeeze on"
-			       " hdlc_proto_attach()\n");
+			netdev_warn(dev,
+				    "Memory squeeze on hdlc_proto_attach()\n");
 			module_put(proto->module);
 			return -ENOBUFS;
 		}
@@ -363,7 +365,7 @@ static int __init hdlc_module_init(void)
 {
 	int result;
 
-	printk(KERN_INFO "%s\n", version);
+	pr_info("%s\n", version);
 	if ((result = register_netdevice_notifier(&hdlc_notifier)) != 0)
 		return result;
 	dev_add_pack(&hdlc_packet_type);
diff --git a/drivers/net/wan/hdlc_cisco.c b/drivers/net/wan/hdlc_cisco.c
index b1e5e5b..3f20808 100644
--- a/drivers/net/wan/hdlc_cisco.c
+++ b/drivers/net/wan/hdlc_cisco.c
@@ -103,9 +103,7 @@ static void cisco_keepalive_send(struct net_device *dev, u32 type,
 	skb = dev_alloc_skb(sizeof(struct hdlc_header) +
 			    sizeof(struct cisco_packet));
 	if (!skb) {
-		printk(KERN_WARNING
-		       "%s: Memory squeeze on cisco_keepalive_send()\n",
-		       dev->name);
+		netdev_warn(dev, "Memory squeeze on cisco_keepalive_send()\n");
 		return;
 	}
 	skb_reserve(skb, 4);
@@ -181,8 +179,8 @@ static int cisco_rx(struct sk_buff *skb)
 		     CISCO_PACKET_LEN) &&
 		    (skb->len != sizeof(struct hdlc_header) +
 		     CISCO_BIG_PACKET_LEN)) {
-			printk(KERN_INFO "%s: Invalid length of Cisco control"
-			       " packet (%d bytes)\n", dev->name, skb->len);
+			netdev_info(dev, "Invalid length of Cisco control packet (%d bytes)\n",
+				    skb->len);
 			goto rx_error;
 		}
 
@@ -217,8 +215,7 @@ static int cisco_rx(struct sk_buff *skb)
 			return NET_RX_SUCCESS;
 
 		case CISCO_ADDR_REPLY:
-			printk(KERN_INFO "%s: Unexpected Cisco IP address "
-			       "reply\n", dev->name);
+			netdev_info(dev, "Unexpected Cisco IP address reply\n");
 			goto rx_error;
 
 		case CISCO_KEEPALIVE_REQ:
@@ -235,9 +232,8 @@ static int cisco_rx(struct sk_buff *skb)
 					min = sec / 60; sec -= min * 60;
 					hrs = min / 60; min -= hrs * 60;
 					days = hrs / 24; hrs -= days * 24;
-					printk(KERN_INFO "%s: Link up (peer "
-					       "uptime %ud%uh%um%us)\n",
-					       dev->name, days, hrs, min, sec);
+					netdev_info(dev, "Link up (peer uptime %ud%uh%um%us)\n",
+						    days, hrs, min, sec);
 					netif_dormant_off(dev);
 					st->up = 1;
 				}
@@ -249,8 +245,7 @@ static int cisco_rx(struct sk_buff *skb)
 		} /* switch (keepalive type) */
 	} /* switch (protocol) */
 
-	printk(KERN_INFO "%s: Unsupported protocol %x\n", dev->name,
-	       ntohs(data->protocol));
+	netdev_info(dev, "Unsupported protocol %x\n", ntohs(data->protocol));
 	dev_kfree_skb_any(skb);
 	return NET_RX_DROP;
 
@@ -272,7 +267,7 @@ static void cisco_timer(unsigned long arg)
 	if (st->up &&
 	    time_after(jiffies, st->last_poll + st->settings.timeout * HZ)) {
 		st->up = 0;
-		printk(KERN_INFO "%s: Link down\n", dev->name);
+		netdev_info(dev, "Link down\n");
 		netif_dormant_on(dev);
 	}
 
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index fc433f2..b25c922 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -446,15 +446,14 @@ static netdev_tx_t pvc_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static inline void fr_log_dlci_active(pvc_device *pvc)
 {
-	printk(KERN_INFO "%s: DLCI %d [%s%s%s]%s %s\n",
-	       pvc->frad->name,
-	       pvc->dlci,
-	       pvc->main ? pvc->main->name : "",
-	       pvc->main && pvc->ether ? " " : "",
-	       pvc->ether ? pvc->ether->name : "",
-	       pvc->state.new ? " new" : "",
-	       !pvc->state.exist ? "deleted" :
-	       pvc->state.active ? "active" : "inactive");
+	netdev_info(pvc->frad, "DLCI %d [%s%s%s]%s %s\n",
+		    pvc->dlci,
+		    pvc->main ? pvc->main->name : "",
+		    pvc->main && pvc->ether ? " " : "",
+		    pvc->ether ? pvc->ether->name : "",
+		    pvc->state.new ? " new" : "",
+		    !pvc->state.exist ? "deleted" :
+		    pvc->state.active ? "active" : "inactive");
 }
 
 
@@ -481,16 +480,14 @@ static void fr_lmi_send(struct net_device *dev, int fullrep)
 	if (dce && fullrep) {
 		len += state(hdlc)->dce_pvc_count * (2 + stat_len);
 		if (len > HDLC_MAX_MRU) {
-			printk(KERN_WARNING "%s: Too many PVCs while sending "
-			       "LMI full report\n", dev->name);
+			netdev_warn(dev, "Too many PVCs while sending LMI full report\n");
 			return;
 		}
 	}
 
 	skb = dev_alloc_skb(len);
 	if (!skb) {
-		printk(KERN_WARNING "%s: Memory squeeze on fr_lmi_send()\n",
-		       dev->name);
+		netdev_warn(dev, "Memory squeeze on fr_lmi_send()\n");
 		return;
 	}
 	memset(skb->data, 0, len);
@@ -615,8 +612,7 @@ static void fr_timer(unsigned long arg)
 		state(hdlc)->last_errors <<= 1; /* Shift the list */
 		if (state(hdlc)->request) {
 			if (state(hdlc)->reliable)
-				printk(KERN_INFO "%s: No LMI status reply "
-				       "received\n", dev->name);
+				netdev_info(dev, "No LMI status reply received\n");
 			state(hdlc)->last_errors |= 1;
 		}
 
@@ -628,8 +624,7 @@ static void fr_timer(unsigned long arg)
 	}
 
 	if (state(hdlc)->reliable != reliable) {
-		printk(KERN_INFO "%s: Link %sreliable\n", dev->name,
-		       reliable ? "" : "un");
+		netdev_info(dev, "Link %sreliable\n", reliable ? "" : "un");
 		fr_set_link_state(reliable, dev);
 	}
 
@@ -665,33 +660,32 @@ static int fr_lmi_recv(struct net_device *dev, struct sk_buff *skb)
 
 	if (skb->len < (lmi == LMI_ANSI ? LMI_ANSI_LENGTH :
 			LMI_CCITT_CISCO_LENGTH)) {
-		printk(KERN_INFO "%s: Short LMI frame\n", dev->name);
+		netdev_info(dev, "Short LMI frame\n");
 		return 1;
 	}
 
 	if (skb->data[3] != (lmi == LMI_CISCO ? NLPID_CISCO_LMI :
 			     NLPID_CCITT_ANSI_LMI)) {
-		printk(KERN_INFO "%s: Received non-LMI frame with LMI DLCI\n",
-		       dev->name);
+		netdev_info(dev, "Received non-LMI frame with LMI DLCI\n");
 		return 1;
 	}
 
 	if (skb->data[4] != LMI_CALLREF) {
-		printk(KERN_INFO "%s: Invalid LMI Call reference (0x%02X)\n",
-		       dev->name, skb->data[4]);
+		netdev_info(dev, "Invalid LMI Call reference (0x%02X)\n",
+			    skb->data[4]);
 		return 1;
 	}
 
 	if (skb->data[5] != (dce ? LMI_STATUS_ENQUIRY : LMI_STATUS)) {
-		printk(KERN_INFO "%s: Invalid LMI Message type (0x%02X)\n",
-		       dev->name, skb->data[5]);
+		netdev_info(dev, "Invalid LMI Message type (0x%02X)\n",
+			    skb->data[5]);
 		return 1;
 	}
 
 	if (lmi == LMI_ANSI) {
 		if (skb->data[6] != LMI_ANSI_LOCKSHIFT) {
-			printk(KERN_INFO "%s: Not ANSI locking shift in LMI"
-			       " message (0x%02X)\n", dev->name, skb->data[6]);
+			netdev_info(dev, "Not ANSI locking shift in LMI message (0x%02X)\n",
+				    skb->data[6]);
 			return 1;
 		}
 		i = 7;
@@ -700,34 +694,34 @@ static int fr_lmi_recv(struct net_device *dev, struct sk_buff *skb)
 
 	if (skb->data[i] != (lmi == LMI_CCITT ? LMI_CCITT_REPTYPE :
 			     LMI_ANSI_CISCO_REPTYPE)) {
-		printk(KERN_INFO "%s: Not an LMI Report type IE (0x%02X)\n",
-		       dev->name, skb->data[i]);
+		netdev_info(dev, "Not an LMI Report type IE (0x%02X)\n",
+			    skb->data[i]);
 		return 1;
 	}
 
 	if (skb->data[++i] != LMI_REPT_LEN) {
-		printk(KERN_INFO "%s: Invalid LMI Report type IE length"
-		       " (%u)\n", dev->name, skb->data[i]);
+		netdev_info(dev, "Invalid LMI Report type IE length (%u)\n",
+			    skb->data[i]);
 		return 1;
 	}
 
 	reptype = skb->data[++i];
 	if (reptype != LMI_INTEGRITY && reptype != LMI_FULLREP) {
-		printk(KERN_INFO "%s: Unsupported LMI Report type (0x%02X)\n",
-		       dev->name, reptype);
+		netdev_info(dev, "Unsupported LMI Report type (0x%02X)\n",
+			    reptype);
 		return 1;
 	}
 
 	if (skb->data[++i] != (lmi == LMI_CCITT ? LMI_CCITT_ALIVE :
 			       LMI_ANSI_CISCO_ALIVE)) {
-		printk(KERN_INFO "%s: Not an LMI Link integrity verification"
-		       " IE (0x%02X)\n", dev->name, skb->data[i]);
+		netdev_info(dev, "Not an LMI Link integrity verification IE (0x%02X)\n",
+			    skb->data[i]);
 		return 1;
 	}
 
 	if (skb->data[++i] != LMI_INTEG_LEN) {
-		printk(KERN_INFO "%s: Invalid LMI Link integrity verification"
-		       " IE length (%u)\n", dev->name, skb->data[i]);
+		netdev_info(dev, "Invalid LMI Link integrity verification IE length (%u)\n",
+			    skb->data[i]);
 		return 1;
 	}
 	i++;
@@ -801,14 +795,14 @@ static int fr_lmi_recv(struct net_device *dev, struct sk_buff *skb)
 
 		if (skb->data[i] != (lmi == LMI_CCITT ? LMI_CCITT_PVCSTAT :
 				       LMI_ANSI_CISCO_PVCSTAT)) {
-			printk(KERN_INFO "%s: Not an LMI PVC status IE"
-			       " (0x%02X)\n", dev->name, skb->data[i]);
+			netdev_info(dev, "Not an LMI PVC status IE (0x%02X)\n",
+				    skb->data[i]);
 			return 1;
 		}
 
 		if (skb->data[++i] != stat_len) {
-			printk(KERN_INFO "%s: Invalid LMI PVC status IE length"
-			       " (%u)\n", dev->name, skb->data[i]);
+			netdev_info(dev, "Invalid LMI PVC status IE length (%u)\n",
+				    skb->data[i]);
 			return 1;
 		}
 		i++;
@@ -829,9 +823,7 @@ static int fr_lmi_recv(struct net_device *dev, struct sk_buff *skb)
 		pvc = add_pvc(dev, dlci);
 
 		if (!pvc && !no_ram) {
-			printk(KERN_WARNING
-			       "%s: Memory squeeze on fr_lmi_recv()\n",
-			       dev->name);
+			netdev_warn(dev, "Memory squeeze on fr_lmi_recv()\n");
 			no_ram = 1;
 		}
 
@@ -902,8 +894,8 @@ static int fr_rx(struct sk_buff *skb)
 	pvc = find_pvc(hdlc, dlci);
 	if (!pvc) {
 #ifdef DEBUG_PKT
-		printk(KERN_INFO "%s: No PVC for received frame's DLCI %d\n",
-		       frad->name, dlci);
+		netdev_info(frad, "No PVC for received frame's DLCI %d\n",
+			    dlci);
 #endif
 		dev_kfree_skb_any(skb);
 		return NET_RX_DROP;
@@ -962,14 +954,14 @@ static int fr_rx(struct sk_buff *skb)
 			break;
 
 		default:
-			printk(KERN_INFO "%s: Unsupported protocol, OUI=%x "
-			       "PID=%x\n", frad->name, oui, pid);
+			netdev_info(frad, "Unsupported protocol, OUI=%x PID=%x\n",
+				    oui, pid);
 			dev_kfree_skb_any(skb);
 			return NET_RX_DROP;
 		}
 	} else {
-		printk(KERN_INFO "%s: Unsupported protocol, NLPID=%x "
-		       "length = %i\n", frad->name, data[3], skb->len);
+		netdev_info(frad, "Unsupported protocol, NLPID=%x length=%i\n",
+			    data[3], skb->len);
 		dev_kfree_skb_any(skb);
 		return NET_RX_DROP;
 	}
@@ -1073,8 +1065,7 @@ static int fr_add_pvc(struct net_device *frad, unsigned int dlci, int type)
 	int used;
 
 	if ((pvc = add_pvc(frad, dlci)) == NULL) {
-		printk(KERN_WARNING "%s: Memory squeeze on fr_add_pvc()\n",
-		       frad->name);
+		netdev_warn(frad, "Memory squeeze on fr_add_pvc()\n");
 		return -ENOBUFS;
 	}
 
@@ -1089,8 +1080,7 @@ static int fr_add_pvc(struct net_device *frad, unsigned int dlci, int type)
 		dev = alloc_netdev(0, "pvc%d", pvc_setup);
 
 	if (!dev) {
-		printk(KERN_WARNING "%s: Memory squeeze on fr_pvc()\n",
-		       frad->name);
+		netdev_warn(frad, "Memory squeeze on fr_pvc()\n");
 		delete_unused_pvcs(hdlc);
 		return -ENOBUFS;
 	}
diff --git a/drivers/net/wan/hdlc_ppp.c b/drivers/net/wan/hdlc_ppp.c
index 941f053..055a918 100644
--- a/drivers/net/wan/hdlc_ppp.c
+++ b/drivers/net/wan/hdlc_ppp.c
@@ -223,8 +223,7 @@ static void ppp_tx_cp(struct net_device *dev, u16 pid, u8 code,
 	skb = dev_alloc_skb(sizeof(struct hdlc_header) +
 			    sizeof(struct cp_header) + magic_len + len);
 	if (!skb) {
-		printk(KERN_WARNING "%s: out of memory in ppp_tx_cp()\n",
-		       dev->name);
+		netdev_warn(dev, "out of memory in ppp_tx_cp()\n");
 		return;
 	}
 	skb_reserve(skb, sizeof(struct hdlc_header));
@@ -345,7 +344,7 @@ static void ppp_cp_event(struct net_device *dev, u16 pid, u16 event, u8 code,
 		ppp_tx_cp(dev, pid, CP_CODE_REJ, ++ppp->seq, len, data);
 
 	if (old_state != OPENED && proto->state == OPENED) {
-		printk(KERN_INFO "%s: %s up\n", dev->name, proto_name(pid));
+		netdev_info(dev, "%s up\n", proto_name(pid));
 		if (pid == PID_LCP) {
 			netif_dormant_off(dev);
 			ppp_cp_event(dev, PID_IPCP, START, 0, 0, 0, NULL);
@@ -356,7 +355,7 @@ static void ppp_cp_event(struct net_device *dev, u16 pid, u16 event, u8 code,
 		}
 	}
 	if (old_state == OPENED && proto->state != OPENED) {
-		printk(KERN_INFO "%s: %s down\n", dev->name, proto_name(pid));
+		netdev_info(dev, "%s down\n", proto_name(pid));
 		if (pid == PID_LCP) {
 			netif_dormant_on(dev);
 			ppp_cp_event(dev, PID_IPCP, STOP, 0, 0, 0, NULL);
@@ -585,7 +584,7 @@ static void ppp_timer(unsigned long arg)
 			break;
 		if (time_after(jiffies, ppp->last_pong +
 			       ppp->keepalive_timeout * HZ)) {
-			printk(KERN_INFO "%s: Link down\n", proto->dev->name);
+			netdev_info(proto->dev, "Link down\n");
 			ppp_cp_event(proto->dev, PID_LCP, STOP, 0, 0, 0, NULL);
 			ppp_cp_event(proto->dev, PID_LCP, START, 0, 0, 0, NULL);
 		} else {	/* send keep-alive packet */
diff --git a/drivers/net/wan/hdlc_x25.c b/drivers/net/wan/hdlc_x25.c
index 70527e5..56aeb01 100644
--- a/drivers/net/wan/hdlc_x25.c
+++ b/drivers/net/wan/hdlc_x25.c
@@ -34,7 +34,7 @@ static void x25_connect_disconnect(struct net_device *dev, int reason, int code)
 	unsigned char *ptr;
 
 	if ((skb = dev_alloc_skb(1)) == NULL) {
-		printk(KERN_ERR "%s: out of memory\n", dev->name);
+		netdev_err(dev, "out of memory\n");
 		return;
 	}
 
@@ -106,9 +106,8 @@ static netdev_tx_t x25_xmit(struct sk_buff *skb, struct net_device *dev)
 				/* Send connect confirm. msg to level 3 */
 				x25_connected(dev, 0);
 			else
-				printk(KERN_ERR "%s: LAPB connect request "
-				       "failed, error code = %i\n",
-				       dev->name, result);
+				netdev_err(dev, "LAPB connect request failed, error code = %i\n",
+					   result);
 		}
 		break;
 
@@ -118,9 +117,8 @@ static netdev_tx_t x25_xmit(struct sk_buff *skb, struct net_device *dev)
 				/* Send disconnect confirm. msg to level 3 */
 				x25_disconnected(dev, 0);
 			else
-				printk(KERN_ERR "%s: LAPB disconnect request "
-				       "failed, error code = %i\n",
-				       dev->name, result);
+				netdev_err(dev, "LAPB disconnect request failed, error code = %i\n",
+					   result);
 		}
 		break;
 
diff --git a/drivers/net/wan/n2.c b/drivers/net/wan/n2.c
index 17d408f..5129ad5 100644
--- a/drivers/net/wan/n2.c
+++ b/drivers/net/wan/n2.c
@@ -16,6 +16,8 @@
  *    SDL Inc. PPP/HDLC/CISCO driver
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/capability.h>
@@ -341,57 +343,57 @@ static int __init n2_run(unsigned long io, unsigned long irq,
 	int i;
 
 	if (io < 0x200 || io > 0x3FF || (io % N2_IOPORTS) != 0) {
-		printk(KERN_ERR "n2: invalid I/O port value\n");
+		pr_err("invalid I/O port value\n");
 		return -ENODEV;
 	}
 
 	if (irq < 3 || irq > 15 || irq == 6) /* FIXME */ {
-		printk(KERN_ERR "n2: invalid IRQ value\n");
+		pr_err("invalid IRQ value\n");
 		return -ENODEV;
 	}
 
 	if (winbase < 0xA0000 || winbase > 0xFFFFF || (winbase & 0xFFF) != 0) {
-		printk(KERN_ERR "n2: invalid RAM value\n");
+		pr_err("invalid RAM value\n");
 		return -ENODEV;
 	}
 
 	card = kzalloc(sizeof(card_t), GFP_KERNEL);
 	if (card == NULL) {
-		printk(KERN_ERR "n2: unable to allocate memory\n");
+		pr_err("unable to allocate memory\n");
 		return -ENOBUFS;
 	}
 
 	card->ports[0].dev = alloc_hdlcdev(&card->ports[0]);
 	card->ports[1].dev = alloc_hdlcdev(&card->ports[1]);
 	if (!card->ports[0].dev || !card->ports[1].dev) {
-		printk(KERN_ERR "n2: unable to allocate memory\n");
+		pr_err("unable to allocate memory\n");
 		n2_destroy_card(card);
 		return -ENOMEM;
 	}
 
 	if (!request_region(io, N2_IOPORTS, devname)) {
-		printk(KERN_ERR "n2: I/O port region in use\n");
+		pr_err("I/O port region in use\n");
 		n2_destroy_card(card);
 		return -EBUSY;
 	}
 	card->io = io;
 
 	if (request_irq(irq, sca_intr, 0, devname, card)) {
-		printk(KERN_ERR "n2: could not allocate IRQ\n");
+		pr_err("could not allocate IRQ\n");
 		n2_destroy_card(card);
 		return -EBUSY;
 	}
 	card->irq = irq;
 
 	if (!request_mem_region(winbase, USE_WINDOWSIZE, devname)) {
-		printk(KERN_ERR "n2: could not request RAM window\n");
+		pr_err("could not request RAM window\n");
 		n2_destroy_card(card);
 		return -EBUSY;
 	}
 	card->phy_winbase = winbase;
 	card->winbase = ioremap(winbase, USE_WINDOWSIZE);
 	if (!card->winbase) {
-		printk(KERN_ERR "n2: ioremap() failed\n");
+		pr_err("ioremap() failed\n");
 		n2_destroy_card(card);
 		return -EFAULT;
 	}
@@ -413,7 +415,7 @@ static int __init n2_run(unsigned long io, unsigned long irq,
 		break;
 
 	default:
-		printk(KERN_ERR "n2: invalid window size\n");
+		pr_err("invalid window size\n");
 		n2_destroy_card(card);
 		return -ENODEV;
 	}
@@ -433,12 +435,12 @@ static int __init n2_run(unsigned long io, unsigned long irq,
 	card->buff_offset = (valid0 + valid1) * sizeof(pkt_desc) *
 		(card->tx_ring_buffers + card->rx_ring_buffers);
 
-	printk(KERN_INFO "n2: RISCom/N2 %u KB RAM, IRQ%u, "
-	       "using %u TX + %u RX packets rings\n", card->ram_size / 1024,
-	       card->irq, card->tx_ring_buffers, card->rx_ring_buffers);
+	pr_info("RISCom/N2 %u KB RAM, IRQ%u, using %u TX + %u RX packets rings\n",
+		card->ram_size / 1024, card->irq,
+		card->tx_ring_buffers, card->rx_ring_buffers);
 
 	if (card->tx_ring_buffers < 1) {
-		printk(KERN_ERR "n2: RAM test failed\n");
+		pr_err("RAM test failed\n");
 		n2_destroy_card(card);
 		return -EIO;
 	}
@@ -474,16 +476,14 @@ static int __init n2_run(unsigned long io, unsigned long irq,
 		port->card = card;
 
 		if (register_hdlc_device(dev)) {
-			printk(KERN_WARNING "n2: unable to register hdlc "
-			       "device\n");
+			pr_warn("unable to register hdlc device\n");
 			port->card = NULL;
 			n2_destroy_card(card);
 			return -ENOBUFS;
 		}
 		sca_init_port(port); /* Set up SCA memory */
 
-		printk(KERN_INFO "%s: RISCom/N2 node %d\n",
-		       dev->name, port->phy_node);
+		netdev_info(dev, "RISCom/N2 node %d\n", port->phy_node);
 	}
 
 	*new_card = card;
@@ -498,12 +498,12 @@ static int __init n2_init(void)
 {
 	if (hw==NULL) {
 #ifdef MODULE
-		printk(KERN_INFO "n2: no card initialized\n");
+		pr_info("no card initialized\n");
 #endif
 		return -EINVAL;	/* no parameters specified, abort */
 	}
 
-	printk(KERN_INFO "%s\n", version);
+	pr_info("%s\n", version);
 
 	do {
 		unsigned long io, irq, ram;
@@ -541,7 +541,7 @@ static int __init n2_init(void)
 			return first_card ? 0 : -EINVAL;
 	}while(*hw++ == ':');
 
-	printk(KERN_ERR "n2: invalid hardware parameters\n");
+	pr_err("invalid hardware parameters\n");
 	return first_card ? 0 : -EINVAL;
 }
 
diff --git a/drivers/net/wan/pc300too.c b/drivers/net/wan/pc300too.c
index c7ab3be..c49c1b3 100644
--- a/drivers/net/wan/pc300too.c
+++ b/drivers/net/wan/pc300too.c
@@ -17,6 +17,8 @@
  * PC300/X21 cards.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/slab.h>
@@ -318,7 +320,7 @@ static int __devinit pc300_pci_init_one(struct pci_dev *pdev,
 
 	card = kzalloc(sizeof(card_t), GFP_KERNEL);
 	if (card == NULL) {
-		printk(KERN_ERR "pc300: unable to allocate memory\n");
+		pr_err("unable to allocate memory\n");
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
 		return -ENOBUFS;
@@ -328,7 +330,7 @@ static int __devinit pc300_pci_init_one(struct pci_dev *pdev,
 	if (pci_resource_len(pdev, 0) != PC300_PLX_SIZE ||
 	    pci_resource_len(pdev, 2) != PC300_SCA_SIZE ||
 	    pci_resource_len(pdev, 3) < 16384) {
-		printk(KERN_ERR "pc300: invalid card EEPROM parameters\n");
+		pr_err("invalid card EEPROM parameters\n");
 		pc300_pci_remove_one(pdev);
 		return -EFAULT;
 	}
@@ -345,7 +347,7 @@ static int __devinit pc300_pci_init_one(struct pci_dev *pdev,
 	if (card->plxbase == NULL ||
 	    card->scabase == NULL ||
 	    card->rambase == NULL) {
-		printk(KERN_ERR "pc300: ioremap() failed\n");
+		pr_err("ioremap() failed\n");
 		pc300_pci_remove_one(pdev);
 	}
 
@@ -370,7 +372,7 @@ static int __devinit pc300_pci_init_one(struct pci_dev *pdev,
 
 	for (i = 0; i < card->n_ports; i++)
 		if (!(card->ports[i].netdev = alloc_hdlcdev(&card->ports[i]))) {
-			printk(KERN_ERR "pc300: unable to allocate memory\n");
+			pr_err("unable to allocate memory\n");
 			pc300_pci_remove_one(pdev);
 			return -ENOMEM;
 		}
@@ -411,15 +413,14 @@ static int __devinit pc300_pci_init_one(struct pci_dev *pdev,
 	card->buff_offset = card->n_ports * sizeof(pkt_desc) *
 		(card->tx_ring_buffers + card->rx_ring_buffers);
 
-	printk(KERN_INFO "pc300: PC300/%s, %u KB RAM at 0x%x, IRQ%u, "
-	       "using %u TX + %u RX packets rings\n",
-	       card->type == PC300_X21 ? "X21" :
-	       card->type == PC300_TE ? "TE" : "RSV",
-	       ramsize / 1024, ramphys, pdev->irq,
-	       card->tx_ring_buffers, card->rx_ring_buffers);
+	pr_info("PC300/%s, %u KB RAM at 0x%x, IRQ%u, using %u TX + %u RX packets rings\n",
+		card->type == PC300_X21 ? "X21" :
+		card->type == PC300_TE ? "TE" : "RSV",
+		ramsize / 1024, ramphys, pdev->irq,
+		card->tx_ring_buffers, card->rx_ring_buffers);
 
 	if (card->tx_ring_buffers < 1) {
-		printk(KERN_ERR "pc300: RAM test failed\n");
+		pr_err("RAM test failed\n");
 		pc300_pci_remove_one(pdev);
 		return -EFAULT;
 	}
@@ -429,8 +430,7 @@ static int __devinit pc300_pci_init_one(struct pci_dev *pdev,
 
 	/* Allocate IRQ */
 	if (request_irq(pdev->irq, sca_intr, IRQF_SHARED, "pc300", card)) {
-		printk(KERN_WARNING "pc300: could not allocate IRQ%d.\n",
-		       pdev->irq);
+		pr_warn("could not allocate IRQ%d\n", pdev->irq);
 		pc300_pci_remove_one(pdev);
 		return -EBUSY;
 	}
@@ -466,15 +466,13 @@ static int __devinit pc300_pci_init_one(struct pci_dev *pdev,
 
 		sca_init_port(port);
 		if (register_hdlc_device(dev)) {
-			printk(KERN_ERR "pc300: unable to register hdlc "
-			       "device\n");
+			pr_err("unable to register hdlc device\n");
 			port->card = NULL;
 			pc300_pci_remove_one(pdev);
 			return -ENOBUFS;
 		}
 
-		printk(KERN_INFO "%s: PC300 channel %d\n",
-		       dev->name, port->chan);
+		netdev_info(dev, "PC300 channel %d\n", port->chan);
 	}
 	return 0;
 }
@@ -505,11 +503,11 @@ static struct pci_driver pc300_pci_driver = {
 static int __init pc300_init_module(void)
 {
 	if (pci_clock_freq < 1000000 || pci_clock_freq > 80000000) {
-		printk(KERN_ERR "pc300: Invalid PCI clock frequency\n");
+		pr_err("Invalid PCI clock frequency\n");
 		return -EINVAL;
 	}
 	if (use_crystal_clock != 0 && use_crystal_clock != 1) {
-		printk(KERN_ERR "pc300: Invalid 'use_crystal_clock' value\n");
+		pr_err("Invalid 'use_crystal_clock' value\n");
 		return -EINVAL;
 	}
 
diff --git a/drivers/net/wan/pci200syn.c b/drivers/net/wan/pci200syn.c
index fd73759..1ce2116 100644
--- a/drivers/net/wan/pci200syn.c
+++ b/drivers/net/wan/pci200syn.c
@@ -14,6 +14,8 @@
  *    PLX Technology Inc. PCI9052 Data Book
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/capability.h>
@@ -297,7 +299,7 @@ static int __devinit pci200_pci_init_one(struct pci_dev *pdev,
 
 	card = kzalloc(sizeof(card_t), GFP_KERNEL);
 	if (card == NULL) {
-		printk(KERN_ERR "pci200syn: unable to allocate memory\n");
+		pr_err("unable to allocate memory\n");
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
 		return -ENOBUFS;
@@ -306,7 +308,7 @@ static int __devinit pci200_pci_init_one(struct pci_dev *pdev,
 	card->ports[0].netdev = alloc_hdlcdev(&card->ports[0]);
 	card->ports[1].netdev = alloc_hdlcdev(&card->ports[1]);
 	if (!card->ports[0].netdev || !card->ports[1].netdev) {
-		printk(KERN_ERR "pci200syn: unable to allocate memory\n");
+		pr_err("unable to allocate memory\n");
 		pci200_pci_remove_one(pdev);
 		return -ENOMEM;
 	}
@@ -314,7 +316,7 @@ static int __devinit pci200_pci_init_one(struct pci_dev *pdev,
 	if (pci_resource_len(pdev, 0) != PCI200SYN_PLX_SIZE ||
 	    pci_resource_len(pdev, 2) != PCI200SYN_SCA_SIZE ||
 	    pci_resource_len(pdev, 3) < 16384) {
-		printk(KERN_ERR "pci200syn: invalid card EEPROM parameters\n");
+		pr_err("invalid card EEPROM parameters\n");
 		pci200_pci_remove_one(pdev);
 		return -EFAULT;
 	}
@@ -331,7 +333,7 @@ static int __devinit pci200_pci_init_one(struct pci_dev *pdev,
 	if (card->plxbase == NULL ||
 	    card->scabase == NULL ||
 	    card->rambase == NULL) {
-		printk(KERN_ERR "pci200syn: ioremap() failed\n");
+		pr_err("ioremap() failed\n");
 		pci200_pci_remove_one(pdev);
 		return -EFAULT;
 	}
@@ -357,12 +359,12 @@ static int __devinit pci200_pci_init_one(struct pci_dev *pdev,
 	card->buff_offset = 2 * sizeof(pkt_desc) * (card->tx_ring_buffers +
 						    card->rx_ring_buffers);
 
-	printk(KERN_INFO "pci200syn: %u KB RAM at 0x%x, IRQ%u, using %u TX +"
-	       " %u RX packets rings\n", ramsize / 1024, ramphys,
-	       pdev->irq, card->tx_ring_buffers, card->rx_ring_buffers);
+	pr_info("%u KB RAM at 0x%x, IRQ%u, using %u TX + %u RX packets rings\n",
+		ramsize / 1024, ramphys,
+		pdev->irq, card->tx_ring_buffers, card->rx_ring_buffers);
 
 	if (card->tx_ring_buffers < 1) {
-		printk(KERN_ERR "pci200syn: RAM test failed\n");
+		pr_err("RAM test failed\n");
 		pci200_pci_remove_one(pdev);
 		return -EFAULT;
 	}
@@ -373,8 +375,7 @@ static int __devinit pci200_pci_init_one(struct pci_dev *pdev,
 
 	/* Allocate IRQ */
 	if (request_irq(pdev->irq, sca_intr, IRQF_SHARED, "pci200syn", card)) {
-		printk(KERN_WARNING "pci200syn: could not allocate IRQ%d.\n",
-		       pdev->irq);
+		pr_warn("could not allocate IRQ%d\n", pdev->irq);
 		pci200_pci_remove_one(pdev);
 		return -EBUSY;
 	}
@@ -400,15 +401,13 @@ static int __devinit pci200_pci_init_one(struct pci_dev *pdev,
 		port->card = card;
 		sca_init_port(port);
 		if (register_hdlc_device(dev)) {
-			printk(KERN_ERR "pci200syn: unable to register hdlc "
-			       "device\n");
+			pr_err("unable to register hdlc device\n");
 			port->card = NULL;
 			pci200_pci_remove_one(pdev);
 			return -ENOBUFS;
 		}
 
-		printk(KERN_INFO "%s: PCI200SYN channel %d\n",
-		       dev->name, port->chan);
+		netdev_info(dev, "PCI200SYN channel %d\n", port->chan);
 	}
 
 	sca_flush(card);
@@ -435,7 +434,7 @@ static struct pci_driver pci200_pci_driver = {
 static int __init pci200_init_module(void)
 {
 	if (pci_clock_freq < 1000000 || pci_clock_freq > 80000000) {
-		printk(KERN_ERR "pci200syn: Invalid PCI clock frequency\n");
+		pr_err("Invalid PCI clock frequency\n");
 		return -EINVAL;
 	}
 	return pci_register_driver(&pci200_pci_driver);
diff --git a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
index 4ea89fe..8d7aa43 100644
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -13,6 +13,8 @@
  *   - wanXL100 will require minor driver modifications, no access to hw
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/slab.h>
@@ -102,9 +104,8 @@ static inline dma_addr_t pci_map_single_debug(struct pci_dev *pdev, void *ptr,
 {
 	dma_addr_t addr = pci_map_single(pdev, ptr, size, direction);
 	if (addr + size > 0x100000000LL)
-		printk(KERN_CRIT "wanXL %s: pci_map_single() returned memory"
-		       " at 0x%LX!\n", pci_name(pdev),
-		       (unsigned long long)addr);
+		pr_crit("%s: pci_map_single() returned memory at 0x%llx!\n",
+			pci_name(pdev), (unsigned long long)addr);
 	return addr;
 }
 
@@ -147,8 +148,8 @@ static inline void wanxl_cable_intr(port_t *port)
 		}
 		dte = (value & STATUS_CABLE_DCE) ? " DCE" : " DTE";
 	}
-	printk(KERN_INFO "%s: %s%s module, %s cable%s%s\n",
-	       port->dev->name, pm, dte, cable, dsr, dcd);
+	netdev_info(port->dev, "%s%s module, %s cable%s%s\n",
+		    pm, dte, cable, dsr, dcd);
 
 	if (value & STATUS_CABLE_DCD)
 		netif_carrier_on(port->dev);
@@ -198,8 +199,8 @@ static inline void wanxl_rx_intr(card_t *card)
 	while (desc = &card->status->rx_descs[card->rx_in],
 	       desc->stat != PACKET_EMPTY) {
 		if ((desc->stat & PACKET_PORT_MASK) > card->n_ports)
-			printk(KERN_CRIT "wanXL %s: received packet for"
-			       " nonexistent port\n", pci_name(card->pdev));
+			pr_crit("%s: received packet for nonexistent port\n",
+				pci_name(card->pdev));
 		else {
 			struct sk_buff *skb = card->rx_skbs[card->rx_in];
 			port_t *port = &card->ports[desc->stat &
@@ -397,7 +398,7 @@ static int wanxl_open(struct net_device *dev)
 	int i;
 
 	if (get_status(port)->open) {
-		printk(KERN_ERR "%s: port already open\n", dev->name);
+		netdev_err(dev, "port already open\n");
 		return -EIO;
 	}
 	if ((i = hdlc_open(dev)) != 0)
@@ -417,7 +418,7 @@ static int wanxl_open(struct net_device *dev)
 		}
 	} while (time_after(timeout, jiffies));
 
-	printk(KERN_ERR "%s: unable to open port\n", dev->name);
+	netdev_err(dev, "unable to open port\n");
 	/* ask the card to close the port, should it be still alive */
 	writel(1 << (DOORBELL_TO_CARD_CLOSE_0 + port->node), dbr);
 	return -EFAULT;
@@ -443,7 +444,7 @@ static int wanxl_close(struct net_device *dev)
 	} while (time_after(timeout, jiffies));
 
 	if (get_status(port)->open)
-		printk(KERN_ERR "%s: unable to close port\n", dev->name);
+		netdev_err(dev, "unable to close port\n");
 
 	netif_stop_queue(dev);
 
@@ -568,11 +569,7 @@ static int __devinit wanxl_pci_init_one(struct pci_dev *pdev,
 	int i, ports, alloc_size;
 
 #ifndef MODULE
-	static int printed_version;
-	if (!printed_version) {
-		printed_version++;
-		printk(KERN_INFO "%s\n", version);
-	}
+	pr_info_once("%s\n", version);
 #endif
 
 	i = pci_enable_device(pdev);
@@ -588,7 +585,7 @@ static int __devinit wanxl_pci_init_one(struct pci_dev *pdev,
 	   work on most platforms */
 	if (pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(28)) ||
 	    pci_set_dma_mask(pdev, DMA_BIT_MASK(28))) {
-		printk(KERN_ERR "wanXL: No usable DMA configuration\n");
+		pr_err("No usable DMA configuration\n");
 		return -EIO;
 	}
 
@@ -607,8 +604,7 @@ static int __devinit wanxl_pci_init_one(struct pci_dev *pdev,
 	alloc_size = sizeof(card_t) + ports * sizeof(port_t);
 	card = kzalloc(alloc_size, GFP_KERNEL);
 	if (card == NULL) {
-		printk(KERN_ERR "wanXL %s: unable to allocate memory\n",
-		       pci_name(pdev));
+		pr_err("%s: unable to allocate memory\n", pci_name(pdev));
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
 		return -ENOBUFS;
@@ -635,7 +631,7 @@ static int __devinit wanxl_pci_init_one(struct pci_dev *pdev,
 	   to indicate the card can do 32-bit DMA addressing */
 	if (pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32)) ||
 	    pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
-		printk(KERN_ERR "wanXL: No usable DMA configuration\n");
+		pr_err("No usable DMA configuration\n");
 		wanxl_pci_remove_one(pdev);
 		return -EIO;
 	}
@@ -645,7 +641,7 @@ static int __devinit wanxl_pci_init_one(struct pci_dev *pdev,
 
 	card->plx = ioremap_nocache(plx_phy, 0x70);
 	if (!card->plx) {
-		printk(KERN_ERR "wanxl: ioremap() failed\n");
+		pr_err("ioremap() failed\n");
  		wanxl_pci_remove_one(pdev);
 		return -EFAULT;
 	}
@@ -657,8 +653,8 @@ static int __devinit wanxl_pci_init_one(struct pci_dev *pdev,
 	timeout = jiffies + 20 * HZ;
 	while ((stat = readl(card->plx + PLX_MAILBOX_0)) != 0) {
 		if (time_before(timeout, jiffies)) {
-			printk(KERN_WARNING "wanXL %s: timeout waiting for"
-			       " PUTS to complete\n", pci_name(pdev));
+			pr_warn("%s: timeout waiting for PUTS to complete\n",
+				pci_name(pdev));
 			wanxl_pci_remove_one(pdev);
 			return -ENODEV;
 		}
@@ -669,8 +665,8 @@ static int __devinit wanxl_pci_init_one(struct pci_dev *pdev,
 			break;
 
 		default:
-			printk(KERN_WARNING "wanXL %s: PUTS test 0x%X"
-			       " failed\n", pci_name(pdev), stat & 0x30);
+			pr_warn("%s: PUTS test 0x%X failed\n",
+				pci_name(pdev), stat & 0x30);
 			wanxl_pci_remove_one(pdev);
 			return -ENODEV;
 		}
@@ -688,17 +684,16 @@ static int __devinit wanxl_pci_init_one(struct pci_dev *pdev,
 	/* sanity check the board's reported memory size */
 	if (ramsize < BUFFERS_ADDR +
 	    (TX_BUFFERS + RX_BUFFERS) * BUFFER_LENGTH * ports) {
-		printk(KERN_WARNING "wanXL %s: no enough on-board RAM"
-		       " (%u bytes detected, %u bytes required)\n",
-		       pci_name(pdev), ramsize, BUFFERS_ADDR +
-		       (TX_BUFFERS + RX_BUFFERS) * BUFFER_LENGTH * ports);
+		pr_warn("%s: no enough on-board RAM (%u bytes detected, %u bytes required)\n",
+			pci_name(pdev), ramsize,
+			BUFFERS_ADDR +
+			(TX_BUFFERS + RX_BUFFERS) * BUFFER_LENGTH * ports);
 		wanxl_pci_remove_one(pdev);
 		return -ENODEV;
 	}
 
 	if (wanxl_puts_command(card, MBX1_CMD_BSWAP)) {
-		printk(KERN_WARNING "wanXL %s: unable to Set Byte Swap"
-		       " Mode\n", pci_name(pdev));
+		pr_warn("%s: unable to Set Byte Swap Mode\n", pci_name(pdev));
 		wanxl_pci_remove_one(pdev);
 		return -ENODEV;
 	}
@@ -715,7 +710,7 @@ static int __devinit wanxl_pci_init_one(struct pci_dev *pdev,
 
 	mem = ioremap_nocache(mem_phy, PDM_OFFSET + sizeof(firmware));
 	if (!mem) {
-		printk(KERN_ERR "wanxl: ioremap() failed\n");
+		pr_err("ioremap() failed\n");
  		wanxl_pci_remove_one(pdev);
 		return -EFAULT;
 	}
@@ -734,8 +729,7 @@ static int __devinit wanxl_pci_init_one(struct pci_dev *pdev,
 	writel(0, card->plx + PLX_MAILBOX_5);
 
 	if (wanxl_puts_command(card, MBX1_CMD_ABORTJ)) {
-		printk(KERN_WARNING "wanXL %s: unable to Abort and Jump\n",
-		       pci_name(pdev));
+		pr_warn("%s: unable to Abort and Jump\n", pci_name(pdev));
 		wanxl_pci_remove_one(pdev);
 		return -ENODEV;
 	}
@@ -749,8 +743,8 @@ static int __devinit wanxl_pci_init_one(struct pci_dev *pdev,
 	}while (time_after(timeout, jiffies));
 
 	if (!stat) {
-		printk(KERN_WARNING "wanXL %s: timeout while initializing card "
-		       "firmware\n", pci_name(pdev));
+		pr_warn("%s: timeout while initializing card firmware\n",
+			pci_name(pdev));
 		wanxl_pci_remove_one(pdev);
 		return -ENODEV;
 	}
@@ -759,13 +753,13 @@ static int __devinit wanxl_pci_init_one(struct pci_dev *pdev,
 	ramsize = stat;
 #endif
 
-	printk(KERN_INFO "wanXL %s: at 0x%X, %u KB of RAM at 0x%X, irq %u\n",
-	       pci_name(pdev), plx_phy, ramsize / 1024, mem_phy, pdev->irq);
+	pr_info("%s: at 0x%X, %u KB of RAM at 0x%X, irq %u\n",
+		pci_name(pdev), plx_phy, ramsize / 1024, mem_phy, pdev->irq);
 
 	/* Allocate IRQ */
 	if (request_irq(pdev->irq, wanxl_intr, IRQF_SHARED, "wanXL", card)) {
-		printk(KERN_WARNING "wanXL %s: could not allocate IRQ%i.\n",
-		       pci_name(pdev), pdev->irq);
+		pr_warn("%s: could not allocate IRQ%i\n",
+			pci_name(pdev), pdev->irq);
 		wanxl_pci_remove_one(pdev);
 		return -EBUSY;
 	}
@@ -776,8 +770,8 @@ static int __devinit wanxl_pci_init_one(struct pci_dev *pdev,
 		port_t *port = &card->ports[i];
 		struct net_device *dev = alloc_hdlcdev(port);
 		if (!dev) {
-			printk(KERN_ERR "wanXL %s: unable to allocate"
-			       " memory\n", pci_name(pdev));
+			pr_err("%s: unable to allocate memory\n",
+			       pci_name(pdev));
 			wanxl_pci_remove_one(pdev);
 			return -ENOMEM;
 		}
@@ -793,8 +787,8 @@ static int __devinit wanxl_pci_init_one(struct pci_dev *pdev,
 		port->node = i;
 		get_status(port)->clocking = CLOCK_EXT;
 		if (register_hdlc_device(dev)) {
-			printk(KERN_ERR "wanXL %s: unable to register hdlc"
-			       " device\n", pci_name(pdev));
+			pr_err("%s: unable to register hdlc device\n",
+			       pci_name(pdev));
 			free_netdev(dev);
 			wanxl_pci_remove_one(pdev);
 			return -ENOBUFS;
@@ -802,11 +796,11 @@ static int __devinit wanxl_pci_init_one(struct pci_dev *pdev,
 		card->n_ports++;
 	}
 
-	printk(KERN_INFO "wanXL %s: port", pci_name(pdev));
+	pr_info("%s: port", pci_name(pdev));
 	for (i = 0; i < ports; i++)
-		printk("%s #%i: %s", i ? "," : "", i,
-		       card->ports[i].dev->name);
-	printk("\n");
+		pr_cont("%s #%i: %s",
+			i ? "," : "", i, card->ports[i].dev->name);
+	pr_cont("\n");
 
 	for (i = 0; i < ports; i++)
 		wanxl_cable_intr(&card->ports[i]); /* get carrier status etc.*/
@@ -836,7 +830,7 @@ static struct pci_driver wanxl_pci_driver = {
 static int __init wanxl_init_module(void)
 {
 #ifdef MODULE
-	printk(KERN_INFO "%s\n", version);
+	pr_info("%s\n", version);
 #endif
 	return pci_register_driver(&wanxl_pci_driver);
 }
-- 
1.7.6.rc1

