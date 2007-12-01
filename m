From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 2/6][CORE] Isolate the net/core/ sysctl table
Date: Sat, 01 Dec 2007 15:59:52 +0300
Message-ID: <47515AC8.3010904@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:32795 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751324AbXLANAB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 08:00:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using ctl paths we can put all the stuff, related to net/core/
sysctl table, into one file and remove all the references on it.

As a good side effect this hides the "core_table" name from
the global name space :)

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/net/sock.h b/include/net/sock.h
index 43e3cd9..8f32a71 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1325,10 +1325,6 @@ extern __u32 sysctl_rmem_max;
 
 extern void sk_init(void);
 
-#ifdef CONFIG_SYSCTL
-extern struct ctl_table core_table[];
-#endif
-
 extern int sysctl_optmem_max;
 
 extern __u32 sysctl_wmem_default;
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 277c8fa..e322713 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -10,10 +10,11 @@
 #include <linux/module.h>
 #include <linux/socket.h>
 #include <linux/netdevice.h>
+#include <linux/init.h>
 #include <net/sock.h>
 #include <net/xfrm.h>
 
-ctl_table core_table[] = {
+static struct ctl_table net_core_table[] = {
 #ifdef CONFIG_NET
 	{
 		.ctl_name	= NET_CORE_WMEM_MAX,
@@ -149,3 +150,19 @@ ctl_table core_table[] = {
 	},
 	{ .ctl_name = 0 }
 };
+
+static __initdata struct ctl_path net_core_path[] = {
+	{ .procname = "net", .ctl_name = CTL_NET, },
+	{ .procname = "core", .ctl_name = NET_CORE, },
+	{ },
+};
+
+static __init int sysctl_core_init(void)
+{
+	struct ctl_table_header *hdr;
+
+	hdr = register_sysctl_paths(net_core_path, net_core_table);
+	return hdr == NULL ? -ENOMEM : 0;
+}
+
+__initcall(sysctl_core_init);
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index c50c793..747fc55 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -31,12 +31,6 @@
 #endif
 
 struct ctl_table net_table[] = {
-	{
-		.ctl_name	= NET_CORE,
-		.procname	= "core",
-		.mode		= 0555,
-		.child		= core_table,
-	},
 #ifdef CONFIG_INET
 	{
 		.ctl_name	= NET_IPV4,
-- 
1.5.3.4

