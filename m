From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 2/2] drivers/net/sunvnet.c: Use pr_<level> and netdev_<level>
Date: Tue, 17 Aug 2010 10:55:05 -0700
Message-ID: <1282067705-14800-2-git-send-email-joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1128 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754480Ab0HQRzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Aug 2010 13:55:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the current message logging styles.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/sunvnet.c |   50 ++++++++++++++++++++----------------------------
 1 files changed, 21 insertions(+), 29 deletions(-)

diff --git a/drivers/net/sunvnet.c b/drivers/net/sunvnet.c
index d281a7b..bf3c762 100644
--- a/drivers/net/sunvnet.c
+++ b/drivers/net/sunvnet.c
@@ -3,6 +3,8 @@
  * Copyright (C) 2007, 2008 David S. Miller <davem@davemloft.net>
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
@@ -20,7 +22,6 @@
 #include "sunvnet.h"
 
 #define DRV_MODULE_NAME		"sunvnet"
-#define PFX DRV_MODULE_NAME	": "
 #define DRV_MODULE_VERSION	"1.0"
 #define DRV_MODULE_RELDATE	"June 25, 2007"
 
@@ -45,9 +46,9 @@ static int vnet_handle_unknown(struct vnet_port *port, void *arg)
 {
 	struct vio_msg_tag *pkt = arg;
 
-	printk(KERN_ERR PFX "Received unknown msg [%02x:%02x:%04x:%08x]\n",
+	pr_err("Received unknown msg [%02x:%02x:%04x:%08x]\n",
 	       pkt->type, pkt->stype, pkt->stype_env, pkt->sid);
-	printk(KERN_ERR PFX "Resetting connection.\n");
+	pr_err("Resetting connection\n");
 
 	ldc_disconnect(port->vio.lp);
 
@@ -400,8 +401,8 @@ static int vnet_rx(struct vnet_port *port, void *msgbuf)
 	if (unlikely(pkt->tag.stype_env != VIO_DRING_DATA))
 		return 0;
 	if (unlikely(pkt->seq != dr->rcv_nxt)) {
-		printk(KERN_ERR PFX "RX out of sequence seq[0x%llx] "
-		       "rcv_nxt[0x%llx]\n", pkt->seq, dr->rcv_nxt);
+		pr_err("RX out of sequence seq[0x%llx] rcv_nxt[0x%llx]\n",
+		       pkt->seq, dr->rcv_nxt);
 		return 0;
 	}
 
@@ -464,8 +465,7 @@ static int handle_mcast(struct vnet_port *port, void *msgbuf)
 	struct vio_net_mcast_info *pkt = msgbuf;
 
 	if (pkt->tag.stype != VIO_SUBTYPE_ACK)
-		printk(KERN_ERR PFX "%s: Got unexpected MCAST reply "
-		       "[%02x:%02x:%04x:%08x]\n",
+		pr_err("%s: Got unexpected MCAST reply [%02x:%02x:%04x:%08x]\n",
 		       port->vp->dev->name,
 		       pkt->tag.type,
 		       pkt->tag.stype,
@@ -520,7 +520,7 @@ static void vnet_event(void *arg, int event)
 	}
 
 	if (unlikely(event != LDC_EVENT_DATA_READY)) {
-		printk(KERN_WARNING PFX "Unexpected LDC event %d\n", event);
+		pr_warning("Unexpected LDC event %d\n", event);
 		spin_unlock_irqrestore(&vio->lock, flags);
 		return;
 	}
@@ -662,8 +662,7 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			netif_stop_queue(dev);
 
 			/* This is a hard error, log it. */
-			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when "
-			       "queue awake!\n", dev->name);
+			netdev_err(dev, "BUG! Tx Ring full when queue awake!\n");
 			dev->stats.tx_errors++;
 		}
 		spin_unlock_irqrestore(&port->vio.lock, flags);
@@ -696,8 +695,7 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	err = __vnet_tx_trigger(port);
 	if (unlikely(err < 0)) {
-		printk(KERN_INFO PFX "%s: TX trigger error %d\n",
-		       dev->name, err);
+		netdev_info(dev, "TX trigger error %d\n", err);
 		d->hdr.state = VIO_DESC_FREE;
 		dev->stats.tx_carrier_errors++;
 		goto out_dropped_unlock;
@@ -952,12 +950,12 @@ static int __devinit vnet_port_alloc_tx_bufs(struct vnet_port *port)
 
 		err = -ENOMEM;
 		if (!buf) {
-			printk(KERN_ERR "TX buffer allocation failure\n");
+			pr_err("TX buffer allocation failure\n");
 			goto err_out;
 		}
 		err = -EFAULT;
 		if ((unsigned long)buf & (8UL - 1)) {
-			printk(KERN_ERR "TX buffer misaligned\n");
+			pr_err("TX buffer misaligned\n");
 			kfree(buf);
 			goto err_out;
 		}
@@ -1030,7 +1028,7 @@ static struct vnet * __devinit vnet_new(const u64 *local_mac)
 
 	dev = alloc_etherdev(sizeof(*vp));
 	if (!dev) {
-		printk(KERN_ERR PFX "Etherdev alloc failed, aborting.\n");
+		pr_err("Etherdev alloc failed, aborting\n");
 		return ERR_PTR(-ENOMEM);
 	}
 
@@ -1056,12 +1054,11 @@ static struct vnet * __devinit vnet_new(const u64 *local_mac)
 
 	err = register_netdev(dev);
 	if (err) {
-		printk(KERN_ERR PFX "Cannot register net device, "
-		       "aborting.\n");
+		pr_err("Cannot register net device, aborting\n");
 		goto err_out_free_dev;
 	}
 
-	printk(KERN_INFO "%s: Sun LDOM vnet %pM\n", dev->name, dev->dev_addr);
+	netdev_info(dev, "Sun LDOM vnet %pM\n", dev->dev_addr);
 
 	list_add(&vp->list, &vnet_list);
 
@@ -1133,10 +1130,7 @@ static struct vio_driver_ops vnet_vio_ops = {
 
 static void __devinit print_version(void)
 {
-	static int version_printed;
-
-	if (version_printed++ == 0)
-		printk(KERN_INFO "%s", version);
+	printk_once(KERN_INFO "%s", version);
 }
 
 const char *remote_macaddr_prop = "remote-mac-address";
@@ -1157,7 +1151,7 @@ static int __devinit vnet_port_probe(struct vio_dev *vdev,
 
 	vp = vnet_find_parent(hp, vdev->mp);
 	if (IS_ERR(vp)) {
-		printk(KERN_ERR PFX "Cannot find port parent vnet.\n");
+		pr_err("Cannot find port parent vnet\n");
 		err = PTR_ERR(vp);
 		goto err_out_put_mdesc;
 	}
@@ -1165,15 +1159,14 @@ static int __devinit vnet_port_probe(struct vio_dev *vdev,
 	rmac = mdesc_get_property(hp, vdev->mp, remote_macaddr_prop, &len);
 	err = -ENODEV;
 	if (!rmac) {
-		printk(KERN_ERR PFX "Port lacks %s property.\n",
-		       remote_macaddr_prop);
+		pr_err("Port lacks %s property\n", remote_macaddr_prop);
 		goto err_out_put_mdesc;
 	}
 
 	port = kzalloc(sizeof(*port), GFP_KERNEL);
 	err = -ENOMEM;
 	if (!port) {
-		printk(KERN_ERR PFX "Cannot allocate vnet_port.\n");
+		pr_err("Cannot allocate vnet_port\n");
 		goto err_out_put_mdesc;
 	}
 
@@ -1214,9 +1207,8 @@ static int __devinit vnet_port_probe(struct vio_dev *vdev,
 
 	dev_set_drvdata(&vdev->dev, port);
 
-	printk(KERN_INFO "%s: PORT ( remote-mac %pM%s )\n",
-	       vp->dev->name, port->raddr,
-	       switch_port ? " switch-port" : "");
+	pr_info("%s: PORT ( remote-mac %pM%s )\n",
+		vp->dev->name, port->raddr, switch_port ? " switch-port" : "");
 
 	vio_port_up(&port->vio);
 
-- 
1.7.2.19.g9a302

