From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] Convert hp100 to useing alloc_etherdev
Date: Tue, 8 Jul 2003 15:14:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030708151427.328aae38.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Change hp100 driver to using alloc_etherdev instead of separate allocation of dev->priv.

Builds, but not tested since do not have hardware.

diff -Nru a/drivers/net/hp100.c b/drivers/net/hp100.c
--- a/drivers/net/hp100.c	Mon Jul  7 14:49:18 2003
+++ b/drivers/net/hp100.c	Mon Jul  7 14:49:18 2003
@@ -713,11 +713,8 @@
 	}
 
 	/* Initialise the "private" data structure for this card. */
-	if ((dev->priv = kmalloc(sizeof(struct hp100_private), GFP_KERNEL)) == NULL)
-		return -ENOMEM;
-
 	lp = (struct hp100_private *) dev->priv;
-	memset(lp, 0, sizeof(struct hp100_private));
+
 	spin_lock_init(&lp->lock);
 	lp->id = eid;
 	lp->chip = chip;
@@ -777,7 +774,6 @@
 
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pci_dev->dev);
-	ether_setup(dev);
 
 	/* If busmaster mode is wanted, a dma-capable memory area is needed for
 	 * the rx and tx PDLs 
@@ -2963,8 +2959,6 @@
 		pci_free_consistent(p->pci_dev, MAX_RINGSIZE + 0x0f, p->page_vaddr_algn, virt_to_whatever(d, p->page_vaddr_algn));
 	if (p->mem_ptr_virt)
 		iounmap(p->mem_ptr_virt);
-	kfree(d->priv);
-	d->priv = NULL;
 	kfree(d);
 	hp100_devlist[i] = NULL;
 }
@@ -2983,9 +2977,10 @@
 	cards = 0;
 	while ((hp100_port[++i] != -1) && (i < HP100_DEVICES)) {
 		/* Create device and set basics args */
-		hp100_devlist[i] = kmalloc(sizeof(struct net_device), GFP_KERNEL);
+		hp100_devlist[i] = alloc_etherdev(sizeof(struct hp100_private));
 		if (!hp100_devlist[i])
 			goto fail;
+
 		memset(hp100_devlist[i], 0x00, sizeof(struct net_device));
 #if LINUX_VERSION_CODE >= 0x020362	/* 2.3.99-pre7 */
 		memcpy(hp100_devlist[i]->name, hp100_name[i], IFNAMSIZ);	/* Copy name */
@@ -2998,7 +2993,6 @@
 		/* Try to create the device */
 		if (register_netdev(hp100_devlist[i]) != 0) {
 			/* DeAllocate everything */
-			/* Note: if dev->priv is mallocated, there is no way to fail */
 			kfree(hp100_devlist[i]);
 			hp100_devlist[i] = (struct net_device *) NULL;
 		} else
