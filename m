From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] update arcnet/pcmcia driver
Date: Tue, 9 Sep 2003 16:35:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030909163506.7d87d7e7.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert driver to use alloc_netdev and get rid of MOD_INC/MOD_DEC
Patch against 2.6.0-test5

diff -Nru a/drivers/net/pcmcia/com20020_cs.c b/drivers/net/pcmcia/com20020_cs.c
--- a/drivers/net/pcmcia/com20020_cs.c	Tue Sep  9 16:33:36 2003
+++ b/drivers/net/pcmcia/com20020_cs.c	Tue Sep  9 16:33:36 2003
@@ -163,6 +163,21 @@
     }
 }
 
+
+static void com20020_setup(struct net_device *dev)
+{
+    struct arcnet_local *lp = dev->priv;
+
+    lp->timeout = timeout;
+    lp->backplane = backplane;
+    lp->clockp = clockp;
+    lp->clockm = clockm & 3;
+    lp->hw.owner = THIS_MODULE;
+
+    /* fill in our module parameters as defaults */
+    dev->dev_addr[0] = node;
+}
+
 /*======================================================================
 
     com20020_attach() creates an "instance" of the driver, allocating
@@ -178,7 +193,6 @@
     com20020_dev_t *info;
     struct net_device *dev;
     int i, ret;
-    struct arcnet_local *lp;
     
     DEBUG(0, "com20020_attach()\n");
     flush_stale_links();
@@ -192,18 +206,13 @@
     if (!info)
 	goto fail_alloc_info;
 
-    lp =  kmalloc(sizeof(struct arcnet_local), GFP_KERNEL);
-    if (!lp)
-	goto fail_alloc_lp;
-
-    dev = dev_alloc("arc%d", &ret);
+    dev = alloc_netdev(sizeof(struct arcnet_local), "arc%d", 
+		       com20020_setup);
     if (!dev)
 	goto fail_alloc_dev;
 
     memset(info, 0, sizeof(struct com20020_dev_t));
-    memset(lp, 0, sizeof(struct arcnet_local));
     memset(link, 0, sizeof(struct dev_link_t));
-    dev->priv = lp;
 
     link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
     link->io.NumPorts1 = 16;
@@ -215,19 +224,11 @@
     else
 	for (i = 0; i < 4; i++)
 	    link->irq.IRQInfo2 |= 1 << irq_list[i];
+
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.Vcc = 50;
     link->conf.IntType = INT_MEMORY_AND_IO;
     link->conf.Present = PRESENT_OPTION;
-
-    /* fill in our module parameters as defaults */
-    dev->dev_addr[0] = node;
-    lp->timeout = timeout;
-    lp->backplane = backplane;
-    lp->clockp = clockp;
-    lp->clockm = clockm & 3;
-    lp->hw.owner = THIS_MODULE;
-
     link->irq.Instance = info->dev = dev;
     link->priv = info;
 
@@ -253,11 +254,9 @@
     return link;
 
 fail_alloc_dev:
-    kfree(lp);
-fail_alloc_lp:
     kfree(info);
 fail_alloc_info:
-    kfree(link);
+    kfree(dev);
     return NULL;
 } /* com20020_attach */
 
@@ -324,11 +323,9 @@
 		/* ...but I/O ports are done automatically by card services */
 		
 		unregister_netdev(dev);
-		MOD_DEC_USE_COUNT;
 	    }
 	    
 	    DEBUG(1,"kfree...\n");
-	    kfree(dev->priv);
 	    free_netdev(dev);
 	}
 	DEBUG(1,"kfree2...\n");
@@ -428,8 +425,6 @@
 	goto failed;
     }
     
-    MOD_INC_USE_COUNT;
-
     lp = dev->priv;
     lp->card_name = "PCMCIA COM20020";
     lp->card_flags = ARC_CAN_10MBIT; /* pretend all of them can 10Mbit */
