From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/8) hdlc_fr - use alloc_ether/netdev
Date: Tue, 2 Dec 2003 14:01:08 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031202140108.24c1dd6b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The HDLC frame relay device use's kmalloc directly to create the network device.
This patch switches to alloc_netdev/alloc_etherdev as necessary.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1499  -> 1.1500 
#	drivers/net/wan/hdlc_fr.c	1.10    -> 1.11   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/12/01	shemminger@osdl.org	1.1500
# Make PVC net_devices use alloc_netdev
# --------------------------------------------
#
diff -Nru a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
--- a/drivers/net/wan/hdlc_fr.c	Mon Dec  1 13:53:42 2003
+++ b/drivers/net/wan/hdlc_fr.c	Mon Dec  1 13:53:42 2003
@@ -986,7 +986,13 @@
 	}
 }
 
-
+static void fr_dlci_setup(struct net_device *dev)
+{
+	dev->type = ARPHRD_DLCI;
+	dev->flags = IFF_POINTOPOINT;
+	dev->hard_header_len = 10;
+	dev->addr_len = 2;
+}
 
 static int fr_add_pvc(hdlc_device *hdlc, unsigned int dlci, int type)
 {
@@ -1009,26 +1015,26 @@
 
 	used = pvc_is_used(pvc);
 
-	dev = kmalloc(sizeof(struct net_device) +
-		      sizeof(struct net_device_stats), GFP_KERNEL);
+	if (type == ARPHRD_ETHER) {
+		dev = alloc_etherdev(sizeof(struct net_device_stats));
+		prefix = "pvceth%d" ;
+	} else {
+		dev = alloc_netdev(sizeof(struct net_device_stats),
+				   "pvc", fr_dlci_setup);
+		prefix = "pvc%d";
+	}
+				  
 	if (!dev) {
 		printk(KERN_WARNING "%s: Memory squeeze on fr_pvc()\n",
 		       hdlc_to_name(hdlc));
 		delete_unused_pvcs(hdlc);
 		return -ENOBUFS;
 	}
-	memset(dev, 0, sizeof(struct net_device) +
-	       sizeof(struct net_device_stats));
 
 	if (type == ARPHRD_ETHER) {
-		ether_setup(dev);
 		memcpy(dev->dev_addr, "\x00\x01", 2);
                 get_random_bytes(dev->dev_addr + 2, ETH_ALEN - 2);
 	} else {
-		dev->type = ARPHRD_DLCI;
-		dev->flags = IFF_POINTOPOINT;
-		dev->hard_header_len = 10;
-		dev->addr_len = 2;
 		*(u16*)dev->dev_addr = htons(dlci);
 		dlci_to_q922(dev->broadcast, dlci);
 	}
@@ -1044,13 +1050,13 @@
 
 	result = dev_alloc_name(dev, prefix);
 	if (result < 0) {
-		kfree(dev);
+		free_netdev(dev);
 		delete_unused_pvcs(hdlc);
 		return result;
 	}
 
 	if (register_netdevice(dev) != 0) {
-		kfree(dev);
+		free_netdev(dev);
 		delete_unused_pvcs(hdlc);
 		return -EIO;
 	}
