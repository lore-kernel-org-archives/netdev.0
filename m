From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/4) dlci netdevice event handling
Date: Mon, 8 Sep 2003 14:14:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030908141445.5a5c0d42.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Since dlci device is a pseudo device built on top of sdla, change it to
handle unregister events and delete itself.

diff -Nru a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
--- a/drivers/net/wan/dlci.c	Mon Sep  8 14:03:04 2003
+++ b/drivers/net/wan/dlci.c	Mon Sep  8 14:03:04 2003
@@ -509,20 +509,46 @@
 
 }
 
-int __init init_dlci(void)
+/* if slave is unregistering, then cleanup master */
+static int dlci_dev_event(struct notifier_block *unused,
+			  unsigned long event, void *ptr)
+{
+	struct net_device *dev = (struct net_device *) ptr;
+
+	if (event == NETDEV_UNREGISTER) {
+		struct dlci_local *dlp;
+
+		list_for_each_entry(dlp, &dlci_devs, list) {
+			if (dlp->slave == dev) {
+				unregister_netdevice(dlp->master);
+				dev_put(dlp->slave);
+				break;
+			}
+		}
+	}
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block dlci_notifier = {
+	.notifier_call = dlci_dev_event,
+};
+
+static int __init init_dlci(void)
 {
 	dlci_ioctl_set(dlci_ioctl);
+	register_netdevice_notifier(&dlci_notifier);
 
 	printk("%s.\n", version);
 
 	return 0;
 }
 
-void __exit dlci_exit(void)
+static void __exit dlci_exit(void)
 {
 	struct dlci_local	*dlp, *nxt;
 	
 	dlci_ioctl_set(NULL);
+	unregister_netdevice_notifier(&dlci_notifier);
 
 	rtnl_lock();
 	list_for_each_entry_safe(dlp, nxt, &dlci_devs, list) {
