From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [2.6 patch] atalk compile errors with SYSCTL=n
Date: Wed, 11 Aug 2004 17:01:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040811170101.69c140b6@dell_ss3.pdx.osdl.net>
References: <20040811224747.GQ26174@fs.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@fs.tum.de>, acme@conectiva.com.br
In-Reply-To: <20040811224747.GQ26174@fs.tum.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I prefer to have the CONFIG stuff in the header file.
Here is an alternative that rearranges to put all function prototypes in atalk.h
and stubs if necessary. It gets all the #ifdef CONFIG_ stuff out of the
.c files.

diff -Nru a/include/linux/atalk.h b/include/linux/atalk.h
--- a/include/linux/atalk.h	2004-08-11 17:00:00 -07:00
+++ b/include/linux/atalk.h	2004-08-11 17:00:00 -07:00
@@ -191,10 +191,13 @@
 extern void		 aarp_send_probe(struct net_device *dev,
 					 struct atalk_addr *addr);
 extern void		 aarp_device_down(struct net_device *dev);
+extern void		 aarp_probe_network(struct atalk_iface *atif);
+extern int 		 aarp_proxy_probe_network(struct atalk_iface *atif,
+				     struct atalk_addr *sa);
+extern void		 aarp_proxy_remove(struct net_device *dev,
+					   struct atalk_addr *sa);
 
-#ifdef MODULE
-extern void aarp_cleanup_module(void);
-#endif /* MODULE */
+extern void		aarp_cleanup_module(void);
 
 #define at_sk(__sk) ((struct atalk_sock *)(__sk)->sk_protinfo)
 
@@ -209,8 +212,28 @@
 
 extern struct atalk_route atrtr_default;
 
+extern struct file_operations atalk_seq_arp_fops;
+
+extern int sysctl_aarp_expiry_time;
+extern int sysctl_aarp_tick_time;
+extern int sysctl_aarp_retransmit_limit;
+extern int sysctl_aarp_resolve_time;
+
+#ifdef CONFIG_SYSCTL
+extern void atalk_register_sysctl(void);
+extern void atalk_unregister_sysctl(void);
+#else
+#define atalk_register_sysctl()		do { } while(0)
+#define atalk_unregister_sysctl()	do { } while(0)
+#endif
+
+#ifdef CONFIG_PROC_FS
 extern int atalk_proc_init(void);
 extern void atalk_proc_exit(void);
+#else
+#define atalk_proc_init()	0
+#define atalk_proc_exit()	do { } while(0)
+#endif /* CONFIG_PROC_FS */
 
 #endif /* __KERNEL__ */
 #endif /* __LINUX_ATALK_H__ */
diff -Nru a/net/appletalk/Makefile b/net/appletalk/Makefile
--- a/net/appletalk/Makefile	2004-08-11 17:00:00 -07:00
+++ b/net/appletalk/Makefile	2004-08-11 17:00:00 -07:00
@@ -4,5 +4,6 @@
 
 obj-$(CONFIG_ATALK) += appletalk.o
 
-appletalk-y			:= aarp.o ddp.o atalk_proc.o
+appletalk-y			:= aarp.o ddp.o
+appletalk-$(CONFIG_PROC_FS)	+= atalk_proc.o
 appletalk-$(CONFIG_SYSCTL)	+= sysctl_net_atalk.o
diff -Nru a/net/appletalk/atalk_proc.c b/net/appletalk/atalk_proc.c
--- a/net/appletalk/atalk_proc.c	2004-08-11 17:00:00 -07:00
+++ b/net/appletalk/atalk_proc.c	2004-08-11 17:00:00 -07:00
@@ -15,8 +15,6 @@
 #include <net/sock.h>
 #include <linux/atalk.h>
 
-#ifdef CONFIG_PROC_FS
-extern struct file_operations atalk_seq_arp_fops;
 
 static __inline__ struct atalk_iface *atalk_get_interface_idx(loff_t pos)
 {
@@ -321,14 +319,3 @@
 	remove_proc_entry("arp", atalk_proc_dir);
 	remove_proc_entry("atalk", proc_net);
 }
-
-#else /* CONFIG_PROC_FS */
-int __init atalk_proc_init(void)
-{
-	return 0;
-}
-
-void __exit atalk_proc_exit(void)
-{
-}
-#endif /* CONFIG_PROC_FS */
diff -Nru a/net/appletalk/ddp.c b/net/appletalk/ddp.c
--- a/net/appletalk/ddp.c	2004-08-11 17:00:00 -07:00
+++ b/net/appletalk/ddp.c	2004-08-11 17:00:00 -07:00
@@ -61,16 +61,6 @@
 #include <net/route.h>
 #include <linux/atalk.h>
 
-extern void aarp_cleanup_module(void);
-
-extern void aarp_probe_network(struct atalk_iface *atif);
-extern int  aarp_proxy_probe_network(struct atalk_iface *atif,
-				     struct atalk_addr *sa);
-extern void aarp_proxy_remove(struct net_device *dev, struct atalk_addr *sa);
-
-extern void atalk_register_sysctl(void);
-extern void atalk_unregister_sysctl(void);
-
 struct datalink_proto *ddp_dl, *aarp_dl;
 static struct proto_ops atalk_dgram_ops;
 
diff -Nru a/net/appletalk/sysctl_net_atalk.c b/net/appletalk/sysctl_net_atalk.c
--- a/net/appletalk/sysctl_net_atalk.c	2004-08-11 17:00:00 -07:00
+++ b/net/appletalk/sysctl_net_atalk.c	2004-08-11 17:00:00 -07:00
@@ -7,13 +7,9 @@
  */
 
 #include <linux/config.h>
-
-#ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
-extern int sysctl_aarp_expiry_time;
-extern int sysctl_aarp_tick_time;
-extern int sysctl_aarp_retransmit_limit;
-extern int sysctl_aarp_resolve_time;
+#include <net/sock.h>
+#include <linux/atalk.h>
 
 static struct ctl_table atalk_table[] = {
 	{
@@ -85,13 +81,3 @@
 {
 	unregister_sysctl_table(atalk_table_header);
 }
-
-#else /* CONFIG_PROC_FS */
-void atalk_register_sysctl(void)
-{
-}
-
-void atalk_unregister_sysctl(void)
-{
-}
-#endif /* CONFIG_PROC_FS */ 
