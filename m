From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] [IrDA] LMP discovery timer not started by
	default
Date: Wed, 23 Jan 2008 04:34:22 +0100
Message-ID: <20080123033422.GA20754@sortiz.org>
Reply-To: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ross Burton <ross-RWuK6r/cQWRpLGFMi4vTTA@public.gmane.org>,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

By default, LMP sets up a 3 seconds timer for discovery.
We don't need it until discovery is set to 1.

This patch is against your latest net-2.6.25 tree.

From: Ross Burton <ross-RWuK6r/cQWRpLGFMi4vTTA@public.gmane.org>
Signed-off-by: Ross Burton <ross-RWuK6r/cQWRpLGFMi4vTTA@public.gmane.org>
Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
---
 net/irda/irlmp.c       |    7 +++++--
 net/irda/irlmp_event.c |    4 +---
 net/irda/irsysctl.c    |   28 +++++++++++++++++++++++++++-
 3 files changed, 33 insertions(+), 6 deletions(-)

Index: net-2.6.25/net/irda/irlmp.c
===================================================================
--- net-2.6.25.orig/net/irda/irlmp.c	2008-01-14 19:27:06.000000000 +0100
+++ net-2.6.25/net/irda/irlmp.c	2008-01-23 00:57:12.000000000 +0100
@@ -103,9 +103,12 @@
 	irlmp->last_lsap_sel = 0x0f; /* Reserved 0x00-0x0f */
 	strcpy(sysctl_devname, "Linux");
 
-	/* Do discovery every 3 seconds */
 	init_timer(&irlmp->discovery_timer);
-	irlmp_start_discovery_timer(irlmp, sysctl_discovery_timeout*HZ);
+
+	/* Do discovery every 3 seconds, conditionaly */
+	if (sysctl_discovery)
+		irlmp_start_discovery_timer(irlmp,
+					    sysctl_discovery_timeout*HZ);
 
 	return 0;
 }
Index: net-2.6.25/net/irda/irlmp_event.c
===================================================================
--- net-2.6.25.orig/net/irda/irlmp_event.c	2008-01-14 19:27:06.000000000 +0100
+++ net-2.6.25/net/irda/irlmp_event.c	2008-01-23 00:57:38.000000000 +0100
@@ -174,9 +174,7 @@
 	/* We always cleanup the log (active & passive discovery) */
 	irlmp_do_expiry();
 
-	/* Active discovery is conditional */
-	if (sysctl_discovery)
-		irlmp_do_discovery(sysctl_discovery_slots);
+	irlmp_do_discovery(sysctl_discovery_slots);
 
 	/* Restart timer */
 	irlmp_start_discovery_timer(irlmp, sysctl_discovery_timeout * HZ);
Index: net-2.6.25/net/irda/irsysctl.c
===================================================================
--- net-2.6.25.orig/net/irda/irsysctl.c	2008-01-14 19:27:06.000000000 +0100
+++ net-2.6.25/net/irda/irsysctl.c	2008-01-22 21:30:30.000000000 +0100
@@ -29,6 +29,8 @@
 #include <linux/init.h>
 
 #include <net/irda/irda.h>		/* irda_debug */
+#include <net/irda/irlmp.h>
+#include <net/irda/timer.h>
 #include <net/irda/irias_object.h>
 
 extern int  sysctl_discovery;
@@ -45,6 +47,8 @@
 extern int  sysctl_warn_noreply_time;
 extern int  sysctl_lap_keepalive_time;
 
+extern struct irlmp_cb *irlmp;
+
 /* this is needed for the proc_dointvec_minmax - Jean II */
 static int max_discovery_slots = 16;		/* ??? */
 static int min_discovery_slots = 1;
@@ -85,6 +89,27 @@
 	return ret;
 }
 
+
+static int do_discovery(ctl_table *table, int write, struct file *filp,
+                    void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+       int ret;
+
+       ret = proc_dointvec(table, write, filp, buffer, lenp, ppos);
+       if (ret)
+	       return ret;
+
+       if (irlmp == NULL)
+	       return -ENODEV;
+
+       if (sysctl_discovery)
+	       irlmp_start_discovery_timer(irlmp, sysctl_discovery_timeout*HZ);
+       else
+	       del_timer_sync(&irlmp->discovery_timer);
+
+       return ret;
+}
+
 /* One file */
 static ctl_table irda_table[] = {
 	{
@@ -93,7 +118,8 @@
 		.data		= &sysctl_discovery,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= &do_discovery,
+		.strategy       = &sysctl_intvec
 	},
 	{
 		.ctl_name	= NET_IRDA_DEVNAME,


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
