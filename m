From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.69] Don't use destructor in bridge
Date: Fri, 9 May 2003 13:15:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030509131515.6c3d34ca.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch changes the Ethernet bridge back to the original way without
having a destructor function.  This is done so the route cache side effect
code doesn't hold onto a reference to the device.

Fixing the device ref count/module/ destructor code is harder and should
still be done, but this avoids the problem till then.

diff -urNp -X dontdiff linux-2.5.69/net/bridge/br_device.c linux-2.5-bridge/net/bridge/br_device.c
--- linux-2.5.69/net/bridge/br_device.c	2003-05-06 12:07:56.000000000 -0700
+++ linux-2.5-bridge/net/bridge/br_device.c	2003-05-08 15:59:11.000000000 -0700
@@ -110,11 +110,6 @@ static int br_dev_accept_fastpath(struct
 	return -1;
 }
 
-static void br_dev_destruct(struct net_device *dev) 
-{
-	kfree(dev->priv);
-}
-
 void br_dev_setup(struct net_device *dev)
 {
 	memset(dev->dev_addr, 0, ETH_ALEN);
@@ -124,7 +119,6 @@ void br_dev_setup(struct net_device *dev
 	dev->hard_start_xmit = br_dev_xmit;
 	dev->open = br_dev_open;
 	dev->set_multicast_list = br_dev_set_multicast_list;
-	dev->destructor = br_dev_destruct;
 	dev->owner = THIS_MODULE;
 	dev->stop = br_dev_stop;
 	dev->accept_fastpath = br_dev_accept_fastpath;
diff -urNp -X dontdiff linux-2.5.69/net/bridge/br_if.c linux-2.5-bridge/net/bridge/br_if.c
--- linux-2.5.69/net/bridge/br_if.c	2003-05-06 12:07:56.000000000 -0700
+++ linux-2.5-bridge/net/bridge/br_if.c	2003-05-08 15:59:11.000000000 -0700
@@ -174,27 +174,22 @@ int br_del_bridge(const char *name)
 	struct net_device *dev;
 	int ret = 0;
 
-	dev = dev_get_by_name(name);
+	rtnl_lock();
+	dev = __dev_get_by_name(name);
 	if (dev == NULL) 
-		return -ENXIO; 	/* Could not find device */
-
-	if (!(dev->priv_flags & IFF_EBRIDGE)) {
-		/* Attempt to delete non bridge device! */
-		ret = -EPERM;
-	}
-
-	else if (dev->flags & IFF_UP) {
-		/* Not shutdown yet. */
-		ret = -EBUSY;
-	} 
-
+		ret = -ENXIO; 	/* Could not find device */
+	else if (!(dev->priv_flags & IFF_EBRIDGE)) 
+		ret = -EPERM;	/* Attempt to delete non bridge device! */
+	else if (dev->flags & IFF_UP) 
+		ret = -EBUSY;	/* Not shutdown yet. */
 	else {
 		del_ifs((struct net_bridge *) dev->priv);
 	
-		unregister_netdev(dev);
-	}
+		unregister_netdevice(dev);
 
-	dev_put(dev);
+		kfree(dev->priv);
+	}
+	rtnl_unlock();
 	return ret;
 }
 
@@ -283,11 +278,10 @@ void __exit br_cleanup_bridges(void)
 		nxt = dev->next;
 		if ((dev->priv_flags & IFF_EBRIDGE)
 		    && dev->owner == THIS_MODULE) {
-			pr_debug("cleanup %s\n", dev->name);
-
 			del_ifs((struct net_bridge *) dev->priv);
 			
 			unregister_netdevice(dev);
+			kfree(dev->priv);
 		}
 	}
 	rtnl_unlock();
