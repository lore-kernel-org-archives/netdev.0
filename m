From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [BUG]:   problem when shutting down ppp connection since 2.5.70
Date: Wed, 9 Jul 2003 11:43:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030709114334.5b8cf7c6.shemminger@osdl.org>
References: <3F03BC55.6050506@nortelnetworks.com>
	<008201c343a3$0f9f8a70$2101a8c0@witbe>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-ppp@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Paul Rolland" <rol@as2917.net>, cfriesen@nortelnetworks.com,
   paulus@samba.org
In-Reply-To: <008201c343a3$0f9f8a70$2101a8c0@witbe>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The problem is that some protocol is still holding a reference to the device.
This is a bug in the protocol, and needs to be fixed (ie not a ppp bug).

Try building a kernel with only IPv4, eliminate all others then add back until
you find the culprit.

The following patch may help also.

diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	Wed Jul  9 11:40:56 2003
+++ b/net/core/dev.c	Wed Jul  9 11:40:56 2003
@@ -72,6 +72,8 @@
  *				        - netif_rx() feedback
  */
 
+#define DEBUG 1
+
 #include <asm/uaccess.h>
 #include <asm/system.h>
 #include <asm/bitops.h>
@@ -2704,6 +2706,8 @@
 	goto out;
 }
 
+extern void dst_dumpref(const struct net_device *dev);
+
 static void netdev_wait_allrefs(struct net_device *dev)
 {
 	unsigned long rebroadcast_time, warning_time;
@@ -2740,6 +2744,30 @@
 		current->state = TASK_RUNNING;
 
 		if (time_after(jiffies, warning_time + 10 * HZ)) {
+#ifdef DEBUG
+			dst_dumpref(dev);
+
+			if (dev->atalk_ptr)
+				printk(KERN_INFO "unregister_netdevice: "
+				       " %s: probably in use as AppleTalk device\n", dev->name);
+			if (dev->ip_ptr)
+				printk(KERN_INFO "unregister_netdevice: "
+				       " %s: probably in use as IPv4 device\n", dev->name);
+
+			if (dev->atalk_ptr)
+				printk(KERN_INFO "unregister_netdevice: "
+				       " %s: probably in use as DECnet device\n", dev->name);
+			if (dev->ip6_ptr)
+				printk(KERN_INFO "unregister_netdevice: "
+				       " %s: probably in use as IPv6 device\n", dev->name);
+
+			if (dev->ec_ptr)
+				printk(KERN_INFO "unregister_netdevice: "
+				       " %s: probably in use as Econet device\n", dev->name);
+			if (dev->ax25_ptr)
+				printk(KERN_INFO "unregister_netdevice: "
+				       " %s: probably in use as AX.25 device\n", dev->name);
+#endif
 			printk(KERN_EMERG "unregister_netdevice: "
 			       "waiting for %s to become free. Usage "
 			       "count = %d\n",
diff -Nru a/net/core/dst.c b/net/core/dst.c
--- a/net/core/dst.c	Wed Jul  9 11:40:56 2003
+++ b/net/core/dst.c	Wed Jul  9 11:40:56 2003
@@ -41,6 +41,21 @@
 static struct timer_list dst_gc_timer =
 	TIMER_INITIALIZER(dst_run_gc, 0, DST_GC_MIN);
 
+
+void dst_dumpref(const struct net_device *dev)
+{
+	struct dst_entry *dst;
+	int count = 0;
+
+	spin_lock_bh(&dst_lock);
+	for (dst = dst_garbage_list; dst; dst = dst->next) {
+		if (dst->dev == dev) ++count;
+	}
+	spin_unlock_bh(&dst_lock);
+
+	printk(KERN_INFO "dst route cache has %d references\n", count);
+}
+
 static void dst_run_gc(unsigned long dummy)
 {
 	int    delayed = 0;
