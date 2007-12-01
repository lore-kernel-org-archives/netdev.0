From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 5/6][TR] Use ctl paths to register net/token-ring/
 table
Date: Sat, 01 Dec 2007 16:10:04 +0300
Message-ID: <47515D2C.70605@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:55163 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751067AbXLANKO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 08:10:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The same thing for token-ring - use ctl paths and get
rid of external references on the tr_table.

Unfortunately, I couldn't split this patch into cleanup and 
use-the-paths parts.

As a lame excuse I can say, that the cleanup is just moving
the tr_table from one file to another. Since the source 
file is empty after the move, I remove it.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/linux/if_tr.h b/include/linux/if_tr.h
index 046e9d9..5bcec8b 100644
--- a/include/linux/if_tr.h
+++ b/include/linux/if_tr.h
@@ -49,9 +49,6 @@ static inline struct trh_hdr *tr_hdr(const struct sk_buff *skb)
 {
 	return (struct trh_hdr *)skb_mac_header(skb);
 }
-#ifdef CONFIG_SYSCTL
-extern struct ctl_table tr_table[];
-#endif
 #endif
 
 /* This is an Token-Ring LLC structure */
diff --git a/net/802/Makefile b/net/802/Makefile
index 977704a..68569ff 100644
--- a/net/802/Makefile
+++ b/net/802/Makefile
@@ -3,9 +3,8 @@
 #
 
 # Check the p8022 selections against net/core/Makefile.
-obj-$(CONFIG_SYSCTL)	+= sysctl_net_802.o
 obj-$(CONFIG_LLC)	+= p8022.o psnap.o
-obj-$(CONFIG_TR)	+= p8022.o psnap.o tr.o sysctl_net_802.o
+obj-$(CONFIG_TR)	+= p8022.o psnap.o tr.o
 obj-$(CONFIG_NET_FC)	+=                 fc.o
 obj-$(CONFIG_FDDI)	+=                 fddi.o
 obj-$(CONFIG_HIPPI)	+=                 hippi.o
diff --git a/net/802/sysctl_net_802.c b/net/802/sysctl_net_802.c
deleted file mode 100644
index ead5603..0000000
--- a/net/802/sysctl_net_802.c
+++ /dev/null
@@ -1,33 +0,0 @@
-/* -*- linux-c -*-
- *		sysctl_net_802.c: sysctl interface to net 802 subsystem.
- *
- *		Begun April 1, 1996, Mike Shaver.
- *		Added /proc/sys/net/802 directory entry (empty =) ). [MS]
- *
- *		This program is free software; you can redistribute it and/or
- *		modify it under the terms of the GNU General Public License
- *		as published by the Free Software Foundation; either version
- *		2 of the License, or (at your option) any later version.
- */
-
-#include <linux/mm.h>
-#include <linux/if_tr.h>
-#include <linux/sysctl.h>
-
-#ifdef CONFIG_TR
-extern int sysctl_tr_rif_timeout;
-#endif
-
-struct ctl_table tr_table[] = {
-#ifdef CONFIG_TR
-	{
-		.ctl_name	= NET_TR_RIF_TIMEOUT,
-		.procname	= "rif_timeout",
-		.data		= &sysctl_tr_rif_timeout,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
-	},
-#endif /* CONFIG_TR */
-	{ 0 },
-};
diff --git a/net/802/tr.c b/net/802/tr.c
index d8a5386..23fa151 100644
--- a/net/802/tr.c
+++ b/net/802/tr.c
@@ -35,6 +35,7 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/init.h>
+#include <linux/sysctl.h>
 #include <net/arp.h>
 #include <net/net_namespace.h>
 
@@ -634,6 +635,26 @@ struct net_device *alloc_trdev(int sizeof_priv)
 	return alloc_netdev(sizeof_priv, "tr%d", tr_setup);
 }
 
+#ifdef CONFIG_SYSCTL
+static struct ctl_table tr_table[] = {
+	{
+		.ctl_name	= NET_TR_RIF_TIMEOUT,
+		.procname	= "rif_timeout",
+		.data		= &sysctl_tr_rif_timeout,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec
+	},
+	{ 0 },
+};
+
+static __initdata struct ctl_path tr_path[] = {
+	{ .procname = "net", .ctl_name = CTL_NET, },
+	{ .procname = "token-ring", .ctl_name = NET_TR, },
+	{ }
+};
+#endif
+
 /*
  *	Called during bootup.  We don't actually have to initialise
  *	too much for this.
@@ -644,7 +665,9 @@ static int __init rif_init(void)
 	rif_timer.expires  = sysctl_tr_rif_timeout;
 	setup_timer(&rif_timer, rif_check_expire, 0);
 	add_timer(&rif_timer);
-
+#ifdef CONFIG_SYSCTL
+	register_sysctl_paths(tr_path, tr_table);
+#endif
 	proc_net_fops_create(&init_net, "tr_rif", S_IRUGO, &rif_seq_fops);
 	return 0;
 }
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index a4f0ed8..16ad14b 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -31,14 +31,6 @@
 #endif
 
 struct ctl_table net_table[] = {
-#ifdef CONFIG_TR
-	{
-		.ctl_name	= NET_TR,
-		.procname	= "token-ring",
-		.mode		= 0555,
-		.child		= tr_table,
-	},
-#endif
 	{ 0 },
 };
 
-- 
1.5.3.4

