From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (11/13) move /proc/net/aarp to /proc/net/atalk/arp
Date: Fri, 29 Aug 2003 14:14:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030829141445.1a5cb912.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Schulist <jschlst@samba.org>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Move aarp /proc interface like all the others in 2.6;
the other appletalk /proc interfaces were moved to /proc/net/atalk
but aarp was overlooked.

diff -Nru a/net/appletalk/aarp.c b/net/appletalk/aarp.c
--- a/net/appletalk/aarp.c	Fri Aug 29 13:33:03 2003
+++ b/net/appletalk/aarp.c	Fri Aug 29 13:33:03 2003
@@ -1067,15 +1067,3 @@
 	unregister_snap_client(aarp_dl);
 	aarp_purge();
 }
-
-#ifdef CONFIG_PROC_FS
-void aarp_register_proc_fs(void)
-{
-	proc_net_fops_create("aarp", S_IRUGO, &atalk_seq_arp_fops);
-}
-
-void aarp_unregister_proc_fs(void)
-{
-	proc_net_remove("aarp");
-}
-#endif
diff -Nru a/net/appletalk/atalk_proc.c b/net/appletalk/atalk_proc.c
--- a/net/appletalk/atalk_proc.c	Fri Aug 29 13:33:03 2003
+++ b/net/appletalk/atalk_proc.c	Fri Aug 29 13:33:03 2003
@@ -16,6 +16,8 @@
 #include <linux/atalk.h>
 
 #ifdef CONFIG_PROC_FS
+extern struct file_operations atalk_seq_arp_fops;
+
 static __inline__ struct atalk_iface *atalk_get_interface_idx(loff_t pos)
 {
 	struct atalk_iface *i;
@@ -292,9 +294,16 @@
 		goto out_socket;
 	p->proc_fops = &atalk_seq_socket_fops;
 
+	p = create_proc_entry("arp", S_IRUGO, atalk_proc_dir);
+	if (!p) 
+		goto out_arp;
+	p->proc_fops = &atalk_seq_arp_fops;
+
 	rc = 0;
 out:
 	return rc;
+out_arp:
+	remove_proc_entry("socket", atalk_proc_dir);
 out_socket:
 	remove_proc_entry("route", atalk_proc_dir);
 out_route:
@@ -309,6 +318,7 @@
 	remove_proc_entry("interface", atalk_proc_dir);
 	remove_proc_entry("route", atalk_proc_dir);
 	remove_proc_entry("socket", atalk_proc_dir);
+	remove_proc_entry("arp", atalk_proc_dir);
 	remove_proc_entry("atalk", proc_net);
 }
 
diff -Nru a/net/appletalk/ddp.c b/net/appletalk/ddp.c
--- a/net/appletalk/ddp.c	Fri Aug 29 13:33:03 2003
+++ b/net/appletalk/ddp.c	Fri Aug 29 13:33:03 2003
@@ -61,11 +61,6 @@
 #include <net/route.h>
 #include <linux/atalk.h>
 
-#ifdef CONFIG_PROC_FS
-extern void aarp_register_proc_fs(void);
-extern void aarp_unregister_proc_fs(void);
-#endif
-
 extern void aarp_cleanup_module(void);
 
 extern void aarp_probe_network(struct atalk_iface *atif);
@@ -1831,9 +1826,6 @@
 	register_netdevice_notifier(&ddp_notifier);
 	aarp_proto_init();
 	atalk_proc_init();
-#ifdef CONFIG_PROC_FS
-	aarp_register_proc_fs();
-#endif /* CONFIG_PROC_FS */
 	atalk_register_sysctl();
 	printk(atalk_banner);
 	return 0;
@@ -1855,9 +1847,6 @@
 	atalk_unregister_sysctl();
 #endif /* CONFIG_SYSCTL */
 	atalk_proc_exit();
-#ifdef CONFIG_PROC_FS
-	aarp_unregister_proc_fs();
-#endif /* CONFIG_PROC_FS */
 	aarp_cleanup_module();	/* General aarp clean-up. */
 	unregister_netdevice_notifier(&ddp_notifier);
 	dev_remove_pack(&ltalk_packet_type);
