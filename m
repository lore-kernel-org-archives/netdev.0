From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] change delete bridge to work with new unregister
Date: Thu, 29 May 2003 10:24:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030529102407.3d3cfefd.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The changes in 2.5.70 for unregister cause deleteing a bridge device to
hang, because the last reference to the bridge was being dropped after
calling unregister_netdev.  Doing the unregister under lock, instead
of by holding a reference fixes that.

diff -Nru a/net/bridge/br_if.c b/net/bridge/br_if.c
--- a/net/bridge/br_if.c	Thu May 29 10:19:39 2003
+++ b/net/bridge/br_if.c	Thu May 29 10:19:39 2003
@@ -170,11 +170,12 @@
 	struct net_device *dev;
 	int ret = 0;
 
-	dev = dev_get_by_name(name);
+	rtnl_lock();
+	dev = __dev_get_by_name(name);
 	if (dev == NULL) 
-		return -ENXIO; 	/* Could not find device */
+		ret =  -ENXIO; 	/* Could not find device */
 
-	if (!(dev->priv_flags & IFF_EBRIDGE)) {
+	else if (!(dev->priv_flags & IFF_EBRIDGE)) {
 		/* Attempt to delete non bridge device! */
 		ret = -EPERM;
 	}
@@ -186,11 +187,10 @@
 
 	else {
 		del_ifs((struct net_bridge *) dev->priv);
-	
-		unregister_netdev(dev);
+		unregister_netdevice(dev);
 	}
 
-	dev_put(dev);
+	rtnl_unlock();
 	return ret;
 }
 
