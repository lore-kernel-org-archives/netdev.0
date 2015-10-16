From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 5/6] arcnet: com20020-pci: add led trigger support
Date: Fri, 16 Oct 2015 13:00:59 +0200
Message-ID: <1444993260-9667-6-git-send-email-m.grzeschik@pengutronix.de>
References: <1444993260-9667-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: joe@perches.com, netdev@vger.kernel.org, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:47579 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932237AbbJPLBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 07:01:14 -0400
In-Reply-To: <1444993260-9667-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The EAE PLX-PCI card has special leds on the the main io pci resource
bar. This patch adds support to trigger the conflict and data leds with
the packages.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arcdevice.h    | 19 ++++++++++
 drivers/net/arcnet/arcnet.c       | 72 ++++++++++++++++++++++++++++++++++++++
 drivers/net/arcnet/com20020-pci.c | 73 +++++++++++++++++++++++++++++++++++++++
 drivers/net/arcnet/com20020.h     | 10 ++++++
 4 files changed, 174 insertions(+)

diff --git a/drivers/net/arcnet/arcdevice.h b/drivers/net/arcnet/arcdevice.h
index d7fdea1..2edc0c0 100644
--- a/drivers/net/arcnet/arcdevice.h
+++ b/drivers/net/arcnet/arcdevice.h
@@ -237,6 +237,8 @@ struct Outgoing {
 		numsegs;	/* number of segments */
 };
 
+#define ARCNET_LED_NAME_SZ (IFNAMSIZ + 6)
+
 struct arcnet_local {
 	uint8_t config,		/* current value of CONFIG register */
 		timeout,	/* Extended timeout for COM20020 */
@@ -260,6 +262,11 @@ struct arcnet_local {
 	/* On preemtive and SMB a lock is needed */
 	spinlock_t lock;
 
+	struct led_trigger *tx_led_trig;
+	char tx_led_trig_name[ARCNET_LED_NAME_SZ];
+	struct led_trigger *recon_led_trig;
+	char recon_led_trig_name[ARCNET_LED_NAME_SZ];
+
 	/*
 	 * Buffer management: an ARCnet card has 4 x 512-byte buffers, each of
 	 * which can be used for either sending or receiving.  The new dynamic
@@ -309,6 +316,8 @@ struct arcnet_local {
 		int (*reset)(struct net_device *dev, int really_reset);
 		void (*open)(struct net_device *dev);
 		void (*close)(struct net_device *dev);
+		void (*datatrigger) (struct net_device * dev, int enable);
+		void (*recontrigger) (struct net_device * dev, int enable);
 
 		void (*copy_to_card)(struct net_device *dev, int bufnum,
 				     int offset, void *buf, int count);
@@ -319,6 +328,16 @@ struct arcnet_local {
 	void __iomem *mem_start;	/* pointer to ioremap'ed MMIO */
 };
 
+enum arcnet_led_event {
+	ARCNET_LED_EVENT_RECON,
+	ARCNET_LED_EVENT_OPEN,
+	ARCNET_LED_EVENT_STOP,
+	ARCNET_LED_EVENT_TX,
+};
+
+void arcnet_led_event(struct net_device *netdev, enum arcnet_led_event event);
+void devm_arcnet_led_init(struct net_device *netdev, int index, int subid);
+
 #if ARCNET_DEBUG_MAX & D_SKB
 void arcnet_dump_skb(struct net_device *dev, struct sk_buff *skb, char *desc);
 #else
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index 542e2b4..4242522 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -52,6 +52,8 @@
 #include <linux/init.h>
 #include <linux/jiffies.h>
 
+#include <linux/leds.h>
+
 #include "arcdevice.h"
 #include "com9026.h"
 
@@ -189,6 +191,71 @@ static void arcnet_dump_packet(struct net_device *dev, int bufnum,
 
 #endif
 
+/* Trigger a LED event in response to a ARCNET device event */
+void arcnet_led_event(struct net_device *dev, enum arcnet_led_event event)
+{
+	struct arcnet_local *lp = netdev_priv(dev);
+	unsigned long led_delay = 350;
+	unsigned long tx_delay = 50;
+
+	switch (event) {
+	case ARCNET_LED_EVENT_RECON:
+		led_trigger_blink_oneshot(lp->recon_led_trig,
+					  &led_delay, &led_delay, 0);
+		break;
+	case ARCNET_LED_EVENT_OPEN:
+		led_trigger_event(lp->tx_led_trig, LED_OFF);
+		led_trigger_event(lp->recon_led_trig, LED_OFF);
+		break;
+	case ARCNET_LED_EVENT_STOP:
+		led_trigger_event(lp->tx_led_trig, LED_OFF);
+		led_trigger_event(lp->recon_led_trig, LED_OFF);
+		break;
+	case ARCNET_LED_EVENT_TX:
+		led_trigger_blink_oneshot(lp->tx_led_trig,
+					  &tx_delay, &tx_delay, 0);
+		break;
+	}
+}
+EXPORT_SYMBOL_GPL(arcnet_led_event);
+
+static void arcnet_led_release(struct device *gendev, void *res)
+{
+	struct arcnet_local *lp = netdev_priv(to_net_dev(gendev));
+
+	led_trigger_unregister_simple(lp->tx_led_trig);
+	led_trigger_unregister_simple(lp->recon_led_trig);
+}
+
+/* Register ARCNET LED triggers for a arcnet device
+ *
+ * This is normally called from a driver's probe function
+ */
+void devm_arcnet_led_init(struct net_device *netdev, int index, int subid)
+{
+	struct arcnet_local *lp = netdev_priv(netdev);
+	void *res;
+
+	res = devres_alloc(arcnet_led_release, 0, GFP_KERNEL);
+	if (!res) {
+		netdev_err(netdev, "cannot register LED triggers\n");
+		return;
+	}
+
+	snprintf(lp->tx_led_trig_name, sizeof(lp->tx_led_trig_name),
+		 "arc%d-%d-tx", index, subid);
+	snprintf(lp->recon_led_trig_name, sizeof(lp->recon_led_trig_name),
+		 "arc%d-%d-recon", index, subid);
+
+	led_trigger_register_simple(lp->tx_led_trig_name,
+				    &lp->tx_led_trig);
+	led_trigger_register_simple(lp->recon_led_trig_name,
+				    &lp->recon_led_trig);
+
+	devres_add(&netdev->dev, res);
+}
+EXPORT_SYMBOL_GPL(devm_arcnet_led_init);
+
 /* Unregister a protocol driver from the arc_proto_map.  Protocol drivers
  * are responsible for registering themselves, but the unregister routine
  * is pretty generic so we'll do it here.
@@ -425,6 +492,7 @@ int arcnet_open(struct net_device *dev)
 
 	netif_start_queue(dev);
 
+	arcnet_led_event(dev, ARCNET_LED_EVENT_OPEN);
 	return 0;
 
  out_module_put:
@@ -438,6 +506,7 @@ int arcnet_close(struct net_device *dev)
 {
 	struct arcnet_local *lp = netdev_priv(dev);
 
+	arcnet_led_event(dev, ARCNET_LED_EVENT_STOP);
 	netif_stop_queue(dev);
 
 	/* flush TX and disable RX */
@@ -585,6 +654,8 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 	arc_printk(D_DEBUG, dev, "%s: %d: %s, status: %x\n",
 		   __FILE__, __LINE__, __func__, lp->hw.status(dev));
 
+	arcnet_led_event(dev, ARCNET_LED_EVENT_TX);
+
 	spin_unlock_irqrestore(&lp->lock, flags);
 	return retval;		/* no need to try again */
 }
@@ -837,6 +908,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 
 			arc_printk(D_RECON, dev, "Network reconfiguration detected (status=%Xh)\n",
 				   status);
+			arcnet_led_event(dev, ARCNET_LED_EVENT_RECON);
 			/* MYRECON bit is at bit 7 of diagstatus */
 			if (diagstatus & 0x80)
 				arc_printk(D_RECON, dev, "Put out that recon myself\n");
diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index 637a611..239de38 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -41,6 +41,7 @@
 #include <linux/pci.h>
 #include <linux/list.h>
 #include <linux/io.h>
+#include <linux/leds.h>
 
 #include "arcdevice.h"
 #include "com20020.h"
@@ -62,6 +63,36 @@ module_param(clockp, int, 0);
 module_param(clockm, int, 0);
 MODULE_LICENSE("GPL");
 
+static void led_tx_set(struct led_classdev *led_cdev,
+			     enum led_brightness value)
+{
+	struct com20020_dev *card;
+	struct com20020_priv *priv;
+	struct com20020_pci_card_info *ci;
+
+	card = container_of(led_cdev, struct com20020_dev, tx_led);
+
+	priv = card->pci_priv;
+	ci = priv->ci;
+
+	outb(!!value, priv->misc + ci->leds[card->index].green);
+}
+
+static void led_recon_set(struct led_classdev *led_cdev,
+			     enum led_brightness value)
+{
+	struct com20020_dev *card;
+	struct com20020_priv *priv;
+	struct com20020_pci_card_info *ci;
+
+	card = container_of(led_cdev, struct com20020_dev, recon_led);
+
+	priv = card->pci_priv;
+	ci = priv->ci;
+
+	outb(!!value, priv->misc + ci->leds[card->index].red);
+}
+
 static void com20020pci_remove(struct pci_dev *pdev);
 
 static int com20020pci_probe(struct pci_dev *pdev,
@@ -170,14 +201,41 @@ static int com20020pci_probe(struct pci_dev *pdev,
 
 		card->index = i;
 		card->pci_priv = priv;
+		card->tx_led.brightness_set = led_tx_set;
+		card->tx_led.default_trigger = devm_kasprintf(&pdev->dev,
+						GFP_KERNEL, "arc%d-%d-tx",
+						dev->dev_id, i);
+		card->tx_led.name = devm_kasprintf(&pdev->dev, GFP_KERNEL,
+						"pci:green:tx:%d-%d",
+						dev->dev_id, i);
+
+		card->tx_led.dev = &dev->dev;
+		card->recon_led.brightness_set = led_recon_set;
+		card->recon_led.default_trigger = devm_kasprintf(&pdev->dev,
+						GFP_KERNEL, "arc%d-%d-recon",
+						dev->dev_id, i);
+		card->recon_led.name = devm_kasprintf(&pdev->dev, GFP_KERNEL,
+						"pci:red:recon:%d-%d",
+						dev->dev_id, i);
+		card->recon_led.dev = &dev->dev;
 		card->dev = dev;
 
+		ret = devm_led_classdev_register(&pdev->dev, &card->tx_led);
+		if (ret)
+			goto out_port;
+
+		ret = devm_led_classdev_register(&pdev->dev, &card->recon_led);
+		if (ret)
+			goto out_port;
+
 		dev_set_drvdata(&dev->dev, card);
 
 		ret = com20020_found(dev, IRQF_SHARED);
 		if (ret)
 			goto out_port;
 
+		devm_arcnet_led_init(dev, dev->dev_id, i);
+
 		list_add(&card->list, &priv->list_dev);
 	}
 
@@ -261,6 +319,12 @@ static struct com20020_pci_card_info card_info_eae_arc1 = {
 		.offset = 0x10,
 		.size = 0x04,
 	},
+	.leds = {
+		{
+			.green = 0x0,
+			.red = 0x1,
+		},
+	},
 	.rotary = 0x0,
 	.flags = ARC_CAN_10MBIT,
 };
@@ -284,6 +348,15 @@ static struct com20020_pci_card_info card_info_eae_ma1 = {
 		.offset = 0x10,
 		.size = 0x04,
 	},
+	.leds = {
+		{
+			.green = 0x0,
+			.red = 0x1,
+		}, {
+			.green = 0x2,
+			.red = 0x3,
+		},
+	},
 	.rotary = 0x0,
 	.flags = ARC_CAN_10MBIT,
 };
diff --git a/drivers/net/arcnet/com20020.h b/drivers/net/arcnet/com20020.h
index 4363b65..cd98223 100644
--- a/drivers/net/arcnet/com20020.h
+++ b/drivers/net/arcnet/com20020.h
@@ -26,6 +26,7 @@
  */
 #ifndef __COM20020_H
 #define __COM20020_H
+#include <linux/leds.h>
 
 int com20020_check(struct net_device *dev);
 int com20020_found(struct net_device *dev, int shared);
@@ -36,6 +37,11 @@ extern const struct net_device_ops com20020_netdev_ops;
 
 #define PLX_PCI_MAX_CARDS 2
 
+struct ledoffsets {
+	int green;
+	int red;
+};
+
 struct com20020_pci_channel_map {
 	u32 bar;
 	u32 offset;
@@ -49,6 +55,7 @@ struct com20020_pci_card_info {
 	struct com20020_pci_channel_map chan_map_tbl[PLX_PCI_MAX_CARDS];
 	struct com20020_pci_channel_map misc_map;
 
+	struct ledoffsets leds[PLX_PCI_MAX_CARDS];
 	int rotary;
 
 	unsigned int flags;
@@ -64,6 +71,9 @@ struct com20020_dev {
 	struct list_head list;
 	struct net_device *dev;
 
+	struct led_classdev tx_led;
+	struct led_classdev recon_led;
+
 	struct com20020_priv *pci_priv;
 	int index;
 };
-- 
2.6.1
