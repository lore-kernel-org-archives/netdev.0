From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (9/9) freenetdev - fix leaky drivers
Date: Tue, 19 Aug 2003 12:36:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819123654.54919e58.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When doing the audit for this change, it was obvious that several drivers
allocate but never free the net_device.

This fixes these drivers.  This patch is riskier than the earlier
ones, because it isn't just a simple substitution and maybe there
is a reason they never free.

diff -Nru a/drivers/message/fusion/mptlan.c b/drivers/message/fusion/mptlan.c
--- a/drivers/message/fusion/mptlan.c	Tue Aug 19 09:05:35 2003
+++ b/drivers/message/fusion/mptlan.c	Tue Aug 19 09:05:35 2003
@@ -1534,7 +1534,7 @@
 		printk (KERN_INFO ": %s/%s: Fusion MPT LAN device unregistered\n",
 			       IOC_AND_NETDEV_NAMES_s_s(dev));
 		unregister_netdev(dev);
-		//mpt_landev[i] = (struct net_device *) 0xdeadbeef; /* Debug */
+		free_netdev(dev);
 		mpt_landev[i] = NULL;
 	}
 
diff -Nru a/drivers/net/lasi_82596.c b/drivers/net/lasi_82596.c
--- a/drivers/net/lasi_82596.c	Tue Aug 19 09:05:35 2003
+++ b/drivers/net/lasi_82596.c	Tue Aug 19 09:05:35 2003
@@ -1596,7 +1596,7 @@
 		lp = (struct i596_private *) netdevice->priv;
 		dma_free_noncoherent(lp->dev, sizeof(struct i596_private), 
 				       (void *)netdevice->mem_start, lp->dma_addr);
-		netdevice->priv = NULL;
+		free_netdev(netdevice);
 	}
 
 	unregister_parisc_driver(&lan_driver);
diff -Nru a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
--- a/drivers/net/wan/cosa.c	Tue Aug 19 09:05:35 2003
+++ b/drivers/net/wan/cosa.c	Tue Aug 19 09:05:35 2003
@@ -632,6 +632,7 @@
 {
 	sppp_detach(chan->pppdev.dev);
 	unregister_netdev(chan->pppdev.dev);
+	free_netdev(chan->ppp.dev);
 }
 
 static int cosa_sppp_open(struct net_device *d)
diff -Nru a/drivers/usb/gadget/ether.c b/drivers/usb/gadget/ether.c
--- a/drivers/usb/gadget/ether.c	Tue Aug 19 09:05:35 2003
+++ b/drivers/usb/gadget/ether.c	Tue Aug 19 09:05:35 2003
@@ -1635,6 +1635,7 @@
 	}
 
 	unregister_netdev (dev->net);
+	free_netdev(dev->net);
 
 	/* assuming we used keventd, it must quiesce too */
 	flush_scheduled_work ();
