From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (5/7) ipmr.c - use alloc_netdev
Date: Wed, 25 Jun 2003 11:41:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030625114125.0fef55ca.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rather than explicitly calling kmalloc, use the alloc_netdev infrastructure.

diff -Nru a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
--- a/net/ipv4/ipmr.c	Wed Jun 25 11:30:19 2003
+++ b/net/ipv4/ipmr.c	Wed Jun 25 11:30:19 2003
@@ -186,34 +186,23 @@
 	return (struct net_device_stats*)dev->priv;
 }
 
-static void vif_dev_destructor(struct net_device *dev)
+static void reg_vif_setup(struct net_device *dev)
 {
-	kfree(dev);
-}
-
-static struct net_device *ipmr_reg_vif(struct vifctl *v)
-{
-	struct net_device  *dev;
-	struct in_device *in_dev;
-	int size;
-
-	size = sizeof(*dev) + sizeof(struct net_device_stats);
-	dev = kmalloc(size, GFP_KERNEL);
-	if (!dev)
-		return NULL;
-
-	memset(dev, 0, size);
-
-	dev->priv = dev + 1;
-
-	strcpy(dev->name, "pimreg");
-
 	dev->type		= ARPHRD_PIMREG;
 	dev->mtu		= 1500 - sizeof(struct iphdr) - 8;
 	dev->flags		= IFF_NOARP;
 	dev->hard_start_xmit	= reg_vif_xmit;
 	dev->get_stats		= reg_vif_get_stats;
-	dev->destructor		= vif_dev_destructor;
+	dev->destructor		= (void (*)(struct net_device *)) kfree;
+}
+
+static struct net_device *ipmr_reg_vif(void)
+{
+	struct net_device *dev;
+	struct in_device *in_dev;
+
+	dev = alloc_netdev(sizeof(struct net_device_stats), "pimreg",
+			   reg_vif_setup);
 
 	if (register_netdevice(dev)) {
 		kfree(dev);
@@ -403,7 +392,7 @@
 		 */
 		if (reg_vif_num >= 0)
 			return -EADDRINUSE;
-		dev = ipmr_reg_vif(vifc);
+		dev = ipmr_reg_vif();
 		if (!dev)
 			return -ENOBUFS;
 		break;
