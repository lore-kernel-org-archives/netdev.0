From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] tr/olympic probe: remove #warning, improve error handling
Date: Wed, 10 Sep 2003 21:37:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030910213758.78570231.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

This patch to 2.6.0-test5 removes the #warning in tokenring/olympic.c
and improves error handling in the probe function.

Comments?  or merge?

Thanks,
--
~Randy


patch_name:	tr_olympic_probe.patch
patch_version:	2003-09-10.21:32:18
author:		Randy.Dunlap <rddunlap@osdl.org>
description:	remove #warning to check ioremap() results;
		add more error handling to probe function;
product:	Linux
product_versions: 260-test5
maintainer:	jgarzik@pobox.com
diffstat:	=
 drivers/net/tokenring/olympic.c |   37 ++++++++++++++++++++++++-------------
 1 files changed, 24 insertions(+), 13 deletions(-)

diff -Naur ./drivers/net/tokenring/olympic.c~olyprobe ./drivers/net/tokenring/olympic.c
--- ./drivers/net/tokenring/olympic.c~olyprobe	2003-09-08 12:50:21.000000000 -0700
+++ ./drivers/net/tokenring/olympic.c	2003-09-10 21:26:00.000000000 -0700
@@ -210,14 +210,13 @@
 	pci_set_master(pdev);
 
 	if ((i = pci_request_regions(pdev,"olympic"))) { 
-		return i ; 
-	} ; 
+		goto op_disable_dev;
+	}
  
 	dev = alloc_trdev(sizeof(struct olympic_private)) ; 
-
 	if (!dev) {
-		pci_release_regions(pdev) ; 
-		return -ENOMEM ; 
+		i = -ENOMEM; 
+		goto op_free_dev;
 	}
 
 	olympic_priv = dev->priv ;
@@ -231,10 +230,12 @@
 	dev->base_addr=pci_resource_start(pdev, 0);
 	dev->init=NULL; /* Must be NULL otherwise we get called twice */
 	olympic_priv->olympic_card_name = pci_name(pdev);
+	olympic_priv->pdev = pdev; 
 	olympic_priv->olympic_mmio = ioremap(pci_resource_start(pdev,1),256);
 	olympic_priv->olympic_lap = ioremap(pci_resource_start(pdev,2),2048);
-#warning check ioremap return value
-	olympic_priv->pdev = pdev ; 
+	if (!olympic_priv->olympic_mmio || !olympic_priv->olympic_lap) {
+		goto op_free_iomap;
+	}
 				
 	if ((pkt_buf_sz[card_no] < 100) || (pkt_buf_sz[card_no] > 18000) )
 		olympic_priv->pkt_buf_sz = PKT_BUF_SZ ; 
@@ -246,12 +247,8 @@
 	olympic_priv->olympic_message_level = message_level[card_no] ; 
 	olympic_priv->olympic_network_monitor = network_monitor[card_no];
 	
-	if((i = olympic_init(dev))) {
-		iounmap(olympic_priv->olympic_mmio) ; 
-		iounmap(olympic_priv->olympic_lap) ; 
-		kfree(dev) ; 
-		pci_release_regions(pdev) ; 
-		return i ; 
+	if ((i = olympic_init(dev))) {
+		goto op_free_iomap;
 	}				
 
 	dev->open=&olympic_open;
@@ -275,6 +272,20 @@
 		printk("Olympic: Network Monitor information: /proc/%s\n",proc_name); 
 	}
 	return  0 ;
+
+op_free_iomap:
+	if (olympic_priv->olympic_mmio)
+		iounmap(olympic_priv->olympic_mmio); 
+	if (olympic_priv->olympic_lap)
+		iounmap(olympic_priv->olympic_lap);
+
+op_free_dev:
+	free_netdev(dev);
+	pci_release_regions(pdev); 
+
+op_disable_dev:
+	pci_disable_device(pdev);
+	return i;
 }
 
 static int __devinit olympic_init(struct net_device *dev)
