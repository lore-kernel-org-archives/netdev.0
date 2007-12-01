From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 4/6][IPV4] Use ctl paths to register net/ipv4/
 table
Date: Sat, 01 Dec 2007 16:05:53 +0300
Message-ID: <47515C31.80904@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:60297 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751129AbXLANGI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 08:06:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the same as I did for the net/core/ table in the
second patch in his series: use the paths and isolate 
the whole table in the .c file.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/net/ip.h b/include/net/ip.h
index 83fb9f1..7e1dd67 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -393,6 +393,4 @@ int ipv4_doint_and_flush_strategy(ctl_table *table, int __user *name, int nlen,
 extern int ip_misc_proc_init(void);
 #endif
 
-extern struct ctl_table ipv4_table[];
-
 #endif	/* _IP_H */
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 3546424..bfd0dec 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -13,6 +13,7 @@
 #include <linux/igmp.h>
 #include <linux/inetdevice.h>
 #include <linux/seqlock.h>
+#include <linux/init.h>
 #include <net/snmp.h>
 #include <net/icmp.h>
 #include <net/ip.h>
@@ -247,7 +248,7 @@ static int strategy_allowed_congestion_control(ctl_table *table, int __user *nam
 
 }
 
-ctl_table ipv4_table[] = {
+static struct ctl_table ipv4_table[] = {
 	{
 		.ctl_name	= NET_IPV4_TCP_TIMESTAMPS,
 		.procname	= "tcp_timestamps",
@@ -878,3 +879,19 @@ ctl_table ipv4_table[] = {
 	},
 	{ .ctl_name = 0 }
 };
+
+static __initdata struct ctl_path net_ipv4_path[] = {
+	{ .procname = "net", .ctl_name = CTL_NET, },
+	{ .procname = "ipv4", .ctl_name = NET_IPV4, },
+	{ },
+};
+
+static __init int sysctl_ipv4_init(void)
+{
+	struct ctl_table_header *hdr;
+
+	hdr = register_sysctl_paths(net_ipv4_path, ipv4_table);
+	return hdr == NULL ? -ENOMEM : 0;
+}
+
+__initcall(sysctl_ipv4_init);
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index 747fc55..a4f0ed8 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -31,14 +31,6 @@
 #endif
 
 struct ctl_table net_table[] = {
-#ifdef CONFIG_INET
-	{
-		.ctl_name	= NET_IPV4,
-		.procname	= "ipv4",
-		.mode		= 0555,
-		.child		= ipv4_table
-	},
-#endif
 #ifdef CONFIG_TR
 	{
 		.ctl_name	= NET_TR,
-- 
1.5.3.4

