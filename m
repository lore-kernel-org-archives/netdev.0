From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/5) remove bpqether pre-existing device discovery loop
Date: Tue, 13 Jan 2004 11:00:39 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040113110039.647711c9.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-hams@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Remove duplicate/conflicting code now that netdev_register_notifier replays the 
device registration events. Reorder initialization to avoid having to simplify error unwind 
if /proc creation failed.

diff -Nru a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
--- a/drivers/net/hamradio/bpqether.c	Tue Jan 13 10:23:55 2004
+++ b/drivers/net/hamradio/bpqether.c	Tue Jan 13 10:23:55 2004
@@ -606,33 +606,20 @@
  */
 static int __init bpq_init_driver(void)
 {
-	struct net_device *dev;
-
-	dev_add_pack(&bpq_packet_type);
-
-	register_netdevice_notifier(&bpq_dev_notifier);
-
-	printk(banner);
-
 #ifdef CONFIG_PROC_FS
 	if (!proc_net_fops_create("bpqether", S_IRUGO, &bpq_info_fops)) {
 		printk(KERN_ERR
 			"bpq: cannot create /proc/net/bpqether entry.\n");
-		unregister_netdevice_notifier(&bpq_dev_notifier);
-		dev_remove_pack(&bpq_packet_type);
 		return -ENOENT;
 	}
 #endif  /* CONFIG_PROC_FS */
 
-	rtnl_lock();
-	for (dev = dev_base; dev != NULL; dev = dev->next) {
-		if (dev_is_ethdev(dev) && bpq_new_device(dev)) {
-			printk(KERN_ERR
-			       "bpq: cannot setup dev for '%s'\n",
-			       dev->name);
-		}
-	}
-	rtnl_unlock();
+	dev_add_pack(&bpq_packet_type);
+
+	register_netdevice_notifier(&bpq_dev_notifier);
+
+	printk(banner);
+
 	return 0;
 }
 
