From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (8/16) sir - alloc_irdadev
Date: Tue, 30 Sep 2003 15:07:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930150744.019054e8.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert this driver to use alloc_irdadev and dev->priv to store
local data.

diff -Nru a/drivers/net/irda/sir_dev.c b/drivers/net/irda/sir_dev.c
--- a/drivers/net/irda/sir_dev.c	Tue Sep 30 11:56:36 2003
+++ b/drivers/net/irda/sir_dev.c	Tue Sep 30 11:56:36 2003
@@ -538,28 +538,6 @@
 
 /* ----------------------------------------------------------------------------- */
 
-static int sirdev_init(struct net_device *ndev)
-{
-	struct sir_dev *dev = ndev->priv;
-
-	SET_MODULE_OWNER(ndev);
-
-	/* Set up to be a normal IrDA network device driver */
-	irda_device_setup(ndev);
-
-	dev->flags = IFF_SIR | IFF_PIO;
-
-	/* Override the network functions we need to use */
-	ndev->hard_start_xmit = sirdev_hard_xmit;
-	ndev->open = sirdev_open;
-	ndev->stop = sirdev_close;
-	ndev->get_stats = sirdev_get_stats;
-	ndev->do_ioctl = sirdev_ioctl;
-
-	return 0;
-}
-
-
 struct sir_dev * sirdev_get_instance(const struct sir_driver *drv, const char *name)
 {
 	struct net_device *ndev;
@@ -577,12 +555,12 @@
 	/*
 	 *  Allocate new instance of the device
 	 */
-	dev = kmalloc(sizeof(*dev), GFP_KERNEL);
-	if (dev == NULL) {
+	ndev = alloc_irdadev(sizeof(*dev));
+	if (ndev == NULL) {
 		ERROR("%s - Can't allocate memory for IrDA control block!\n", __FUNCTION__);
 		goto out;
 	}
-	memset(dev, 0, sizeof(*dev));
+	dev = ndev->priv;
 
 	irda_init_max_qos_capabilies(&dev->qos);
 	dev->qos.baud_rate.bits = IR_9600|IR_19200|IR_38400|IR_57600|IR_115200;
@@ -591,11 +569,6 @@
 
 	strncpy(dev->hwname, name, sizeof(dev->hwname)-1);
 
-	ndev = kmalloc(sizeof(*ndev), GFP_KERNEL);
-	if (ndev == NULL)
-		goto out_freedev;
-	memset(ndev, 0, sizeof(*ndev));
-
 	atomic_set(&dev->enable_rx, 0);
 	dev->tx_skb = NULL;
 
@@ -609,10 +582,17 @@
 	dev->drv = drv;
 	dev->netdev = ndev;
 
-	ndev->priv = (void *) dev;
-	ndev->init = sirdev_init;
+	SET_MODULE_OWNER(ndev);
+
+	dev->flags = IFF_SIR | IFF_PIO;
+
+	/* Override the network functions we need to use */
+	ndev->hard_start_xmit = sirdev_hard_xmit;
+	ndev->open = sirdev_open;
+	ndev->stop = sirdev_close;
+	ndev->get_stats = sirdev_get_stats;
+	ndev->do_ioctl = sirdev_ioctl;
 
-	strcpy(ndev->name, "irda%d");
 	if (register_netdev(ndev)) {
 		ERROR("%s(), register_netdev() failed!\n", __FUNCTION__);
 		goto out_freenetdev;
@@ -621,9 +601,7 @@
 	return dev;
 
 out_freenetdev:
-	kfree(ndev);
-out_freedev:
-	kfree(dev);
+	free_netdev(ndev);
 out:
 	return NULL;
 }
@@ -653,10 +631,9 @@
 	up(&dev->fsm.sem);
 
 	/* Remove netdevice */
-	if (dev->netdev)
-		unregister_netdev(dev->netdev);
+	unregister_netdev(dev->netdev);
 
-	kfree(dev);
+	free_netdev(dev->netdev);
 
 	return 0;
 }
