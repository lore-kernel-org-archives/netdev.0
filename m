From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sealevel -- syncppp startup fix
Date: Fri, 26 Sep 2003 16:48:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030926164821.1e83dce9.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The sealevel driver called sppp_attach before checking that board existed
and never called detach in the error path.

My change is to call sppp_attach from the netdev->init hook which happens
later in the process, and call detach from the uninit hook.

Also, changed the structure element 'netdev' to 'pppdev' to avoid confusion.

Here is the fix against 2.6.0-test5 latest

--- linux-2.5/drivers/net/wan/sealevel.c	2003-09-22 10:21:32.000000000 -0700
+++ linux-2.5-net/drivers/net/wan/sealevel.c	2003-09-26 16:47:02.163974888 -0700
@@ -32,7 +32,7 @@
 struct slvl_device
 {
 	struct z8530_channel *chan;
-	struct ppp_device netdev;
+	struct ppp_device pppdev;
 	int channel;
 };
 
@@ -199,11 +199,24 @@ static int sealevel_neigh_setup_dev(stru
 	return 0;
 }
 
+static int sealevel_attach(struct net_device *dev)
+{
+	struct slvl_device *sv = dev->priv;
+	sppp_attach(&sv->pppdev);
+	return 0;
+}
+
+static void sealevel_detach(struct net_device *dev)
+{
+	sppp_detach(dev);
+}
 		
 static void slvl_setup(struct net_device *d)
 {
 	d->open = sealevel_open;
 	d->stop = sealevel_close;
+	d->init = sealevel_attach;
+	d->uninit = sealevel_detach;
 	d->hard_start_xmit = sealevel_queue_xmit;
 	d->get_stats = sealevel_get_stats;
 	d->set_multicast_list = NULL;
@@ -225,11 +238,10 @@ static inline struct slvl_device *slvl_a
 		return NULL;
 
 	sv = d->priv;
-	sv->netdev.dev = d;
+	sv->pppdev.dev = d;
 	d->base_addr = iobase;
 	d->irq = irq;
 		
-	sppp_attach(&sv->netdev);
 	return sv;
 }
 
@@ -315,8 +327,8 @@ static __init struct slvl_board *slvl_in
 	dev->irq=irq;
 	dev->chanA.private=&b->dev[0];
 	dev->chanB.private=&b->dev[1];
-	dev->chanA.netdevice=b->dev[0]->netdev.dev;
-	dev->chanB.netdevice=b->dev[1]->netdev.dev;
+	dev->chanA.netdevice=b->dev[0]->pppdev.dev;
+	dev->chanB.netdevice=b->dev[1]->pppdev.dev;
 	dev->chanA.dev=dev;
 	dev->chanB.dev=dev;
 
@@ -357,10 +369,10 @@ static __init struct slvl_board *slvl_in
 	
 	enable_irq(irq);
 
-	if (register_netdev(b->dev[0]->netdev.dev)) 
+	if (register_netdev(b->dev[0]->pppdev.dev)) 
 		goto dmafail2;
 		
-	if (register_netdev(b->dev[1]->netdev.dev)) 
+	if (register_netdev(b->dev[1]->pppdev.dev)) 
 		goto fail_unit;
 
 	z8530_describe(dev, "I/O", iobase);
@@ -368,7 +380,7 @@ static __init struct slvl_board *slvl_in
 	return b;
 
 fail_unit:
-	unregister_netdev(b->dev[0]->netdev.dev);
+	unregister_netdev(b->dev[0]->pppdev.dev);
 	
 dmafail2:
 	free_dma(dev->chanA.rxdma);
@@ -377,9 +389,9 @@ dmafail:
 fail:
 	free_irq(irq, dev);
 fail1_1:
-	free_netdev(b->dev[1]->netdev.dev);
+	free_netdev(b->dev[1]->pppdev.dev);
 fail1_0:
-	free_netdev(b->dev[0]->netdev.dev);
+	free_netdev(b->dev[0]->pppdev.dev);
 fail2:
 	kfree(b);
 fail3:
@@ -395,9 +407,7 @@ static void __exit slvl_shutdown(struct 
 	
 	for(u=0; u<2; u++)
 	{
-		struct net_device *d = b->dev[u]->netdev.dev;
-		sppp_detach(d);
-
+		struct net_device *d = b->dev[u]->pppdev.dev;
 		unregister_netdev(d);
 		free_netdev(d);
 	}
