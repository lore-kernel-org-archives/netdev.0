From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.68] [BRIDGE] Possible race with timer on shutdown
Date: Thu, 24 Apr 2003 13:51:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030424135103.494998f0.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I added del_timer_sync() in one of my earlier fixes, which was a good
idea but introduced a possible small race where timer was trying to acquire
lock while del_timer_sync() was waiting for other CPU's to complete timers
and holding the bridge lock.

This fixes that by calling del_timer_sync() with no locks held at last
stage of cleanup.

diff -Nru a/net/bridge/br_device.c b/net/bridge/br_device.c
--- a/net/bridge/br_device.c	Thu Apr 24 13:41:15 2003
+++ b/net/bridge/br_device.c	Thu Apr 24 13:41:15 2003
@@ -105,12 +105,7 @@
 
 static int br_dev_stop(struct net_device *dev)
 {
-	struct net_bridge *br;
-
-	br = dev->priv;
-	write_lock(&br->lock);
-	br_stp_disable_bridge(br);
-	write_unlock(&br->lock);
+	br_stp_disable_bridge(dev->priv);
 
 	netif_stop_queue(dev);
 
diff -Nru a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
--- a/net/bridge/br_stp_if.c	Thu Apr 24 13:41:15 2003
+++ b/net/bridge/br_stp_if.c	Thu Apr 24 13:41:15 2003
@@ -64,11 +64,12 @@
 	br_timer_set(&br->gc_timer, jiffies);
 }
 
-/* called under bridge lock */
+/* NO locks held */
 void br_stp_disable_bridge(struct net_bridge *br)
 {
 	struct net_bridge_port *p;
 
+	write_lock(&br->lock);
 	br->topology_change = 0;
 	br->topology_change_detected = 0;
 	br_timer_clear(&br->hello_timer);
@@ -84,6 +85,7 @@
 
 		p = p->next;
 	}
+	write_unlock(&br->lock);
 
 	del_timer_sync(&br->tick);
 }
