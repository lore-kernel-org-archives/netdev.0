From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] update arcnet/pcmcia driver
Date: Mon, 15 Sep 2003 11:54:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030915115430.5b28dbd8.shemminger@osdl.org>
References: <20030909163506.7d87d7e7.shemminger@osdl.org>
	<3F60CC35.3010107@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F60CC35.3010107@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Redo of earlier patch to get rid of MOD_INC/DEC and use alloc_netdev.
This is against 2.6.0-test5 bk latest.

diff -Nru a/drivers/net/pcmcia/com20020_cs.c b/drivers/net/pcmcia/com20020_cs.c
--- a/drivers/net/pcmcia/com20020_cs.c	Mon Sep 15 11:53:32 2003
+++ b/drivers/net/pcmcia/com20020_cs.c	Mon Sep 15 11:53:32 2003
@@ -145,6 +145,20 @@
     dev_node_t          node;
 } com20020_dev_t;
 
+static void com20020_setup(struct net_device *dev)
+{
+	struct arcnet_local *lp = dev->priv;
+
+	lp->timeout = timeout;
+	lp->backplane = backplane;
+	lp->clockp = clockp;
+	lp->clockm = clockm & 3;
+	lp->hw.owner = THIS_MODULE;
+
+	/* fill in our module parameters as defaults */
+	dev->dev_addr[0] = node;
+}
+
 /*======================================================================
 
     com20020_attach() creates an "instance" of the driver, allocating
@@ -173,18 +187,14 @@
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
+    lp = dev->priv;
 
     link->io.Attributes1 = IO_DATA_PATH_WIDTH_8;
     link->io.NumPorts1 = 16;
@@ -201,13 +211,6 @@
     link->conf.IntType = INT_MEMORY_AND_IO;
     link->conf.Present = PRESENT_OPTION;
 
-    /* fill in our module parameters as defaults */
-    dev->dev_addr[0] = node;
-    lp->timeout = timeout;
-    lp->backplane = backplane;
-    lp->clockp = clockp;
-    lp->clockm = clockm & 3;
-    lp->hw.owner = THIS_MODULE;
 
     link->irq.Instance = info->dev = dev;
     link->priv = info;
@@ -234,8 +237,6 @@
     return link;
 
 fail_alloc_dev:
-    kfree(lp);
-fail_alloc_lp:
     kfree(info);
 fail_alloc_info:
     kfree(link);
@@ -303,11 +304,9 @@
 		/* ...but I/O ports are done automatically by card services */
 		
 		unregister_netdev(dev);
-		MOD_DEC_USE_COUNT;
 	    }
 	    
 	    DEBUG(1,"kfree...\n");
-	    kfree(dev->priv);
 	    free_netdev(dev);
 	}
 	DEBUG(1,"kfree2...\n");
@@ -361,7 +360,6 @@
 
     /* Configure card */
     link->state |= DEV_CONFIG;
-    strcpy(info->node.dev_name, dev->name);
 
     DEBUG(1,"arcnet: baseport1 is %Xh\n", link->io.BasePort1);
     i = !CS_SUCCESS;
@@ -407,13 +405,11 @@
 	goto failed;
     }
     
-    MOD_INC_USE_COUNT;
-
     lp = dev->priv;
     lp->card_name = "PCMCIA COM20020";
     lp->card_flags = ARC_CAN_10MBIT; /* pretend all of them can 10Mbit */
 
-    i = com20020_found(dev, 0);
+    i = com20020_found(dev, 0);	/* calls register_netdev */
     
     if (i != 0) {
 	DEBUG(1,KERN_NOTICE "com20020_cs: com20020_found() failed\n");
@@ -421,6 +417,7 @@
     }
 
     info->dev_configured = 1;
+    strcpy(info->node.dev_name, dev->name);
     link->dev = &info->node;
     link->state &= ~DEV_CONFIG_PENDING;
 
