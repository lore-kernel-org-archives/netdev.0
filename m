From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.74] convert appletalk/ipddp to dynamic allocation
Date: Wed, 9 Jul 2003 13:13:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030709131334.79df4dca.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-atalk@lists.netspace.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Jay Schulist <jschlst@samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Part of the continuing campaign to fix all network devices to allocate dynamically.

Built, loaded/unloaded and configured but don't have real test environment to communicate
with other hosts.

diff -Nru a/drivers/net/appletalk/ipddp.c b/drivers/net/appletalk/ipddp.c
--- a/drivers/net/appletalk/ipddp.c	Wed Jul  9 12:55:44 2003
+++ b/drivers/net/appletalk/ipddp.c	Wed Jul  9 12:55:44 2003
@@ -72,17 +72,8 @@
 		printk("%s: Appletalk-IP Decap. mode by Jay Schulist <jschlst@samba.org>\n", 
 			dev->name);
 
-	/* Fill in the device structure with ethernet-generic values. */
-        ether_setup(dev);
-
 	/* Initalize the device structure. */
         dev->hard_start_xmit = ipddp_xmit;
-
-        dev->priv = kmalloc(sizeof(struct net_device_stats), GFP_KERNEL);
-        if(!dev->priv)
-                return -ENOMEM;
-        memset(dev->priv,0,sizeof(struct net_device_stats));
-
         dev->get_stats      = ipddp_get_stats;
         dev->do_ioctl       = ipddp_ioctl;
 
@@ -281,7 +272,7 @@
         }
 }
 
-static struct net_device dev_ipddp;
+static struct net_device *dev_ipddp;
 
 MODULE_LICENSE("GPL");
 MODULE_PARM(ipddp_mode, "i");
@@ -290,29 +281,33 @@
 {
 	int err;
 
-	dev_ipddp.init = ipddp_init;
-	err=dev_alloc_name(&dev_ipddp, "ipddp%d");
-        if(err < 0)
-                return err;
+	dev_ipddp = alloc_netdev(sizeof(struct net_device_stats), 
+				 "ipddp%d", ether_setup);
 
-	if(register_netdev(&dev_ipddp) != 0)
-                return -EIO;
+	if (!dev_ipddp)
+		return -ENOMEM;
 
-	return 0;
+	dev_ipddp->init = ipddp_init;
+
+	if((err = register_netdev(dev_ipddp)))
+	   kfree(dev_ipddp);
+
+	return err;
 }
 
 static void __exit ipddp_cleanup_module(void)
 {
         struct ipddp_route *p;
 
-	unregister_netdev(&dev_ipddp);
-        kfree(dev_ipddp.priv);
+	unregister_netdev(dev_ipddp);
 
         while (ipddp_route_list) {
                 p = ipddp_route_list->next;
                 kfree(ipddp_route_list);
                 ipddp_route_list = p;
         }
+
+        kfree(dev_ipddp);
 }
 
 module_init(ipddp_init_module);
