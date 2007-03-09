From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: about : [NET]: Replace CONFIG_NET_DEBUG with sysctl.
Date: Fri, 9 Mar 2007 10:06:44 -0800
Message-ID: <20070309100644.448d186d@freekitty>
References: <20070308205214.580772044@linux-foundation.org>
	<20070308205305.582324346@linux-foundation.org>
	<20070308.204209.69409441.davem@davemloft.net>
	<45F0FFE7.1080304@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:42777 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767451AbXCISHQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 13:07:16 -0500
In-Reply-To: <45F0FFE7.1080304@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This was what the patch was (complete with spulling error)...

Covert network warning messages from a compile time to runtime choice.
Removes kernel config option and replaces it with new /proc/sys/net/core/warnings.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>  


---
 Documentation/filesystems/proc.txt |    9 +++++++++
 include/linux/sysctl.h             |    1 +
 include/net/sock.h                 |   12 +++++-------
 net/Kconfig                        |    7 -------
 net/core/sysctl_net_core.c         |    8 ++++++++
 net/core/utils.c                   |    2 ++
 6 files changed, 25 insertions(+), 14 deletions(-)

--- net-2.6.22.orig/Documentation/filesystems/proc.txt	2007-03-08 11:23:38.000000000 -0800
+++ net-2.6.22/Documentation/filesystems/proc.txt	2007-03-08 11:26:10.000000000 -0800
@@ -1421,6 +1421,15 @@
 be dropped.  The  default  settings  limit  warning messages to one every five
 seconds.
 
+warnings
+--------
+
+This controls console messages from the networking stack that can occur because
+of problems on the network like duplicate address or bad checksums. Normally,
+this should be enabled, but if the problem persists the messages can be
+disabled.
+
+
 netdev_max_backlog
 ------------------
 
--- net-2.6.22.orig/include/linux/sysctl.h	2007-03-08 11:11:46.000000000 -0800
+++ net-2.6.22/include/linux/sysctl.h	2007-03-08 11:17:39.000000000 -0800
@@ -290,6 +290,7 @@
 	NET_CORE_BUDGET=19,
 	NET_CORE_AEVENT_ETIME=20,
 	NET_CORE_AEVENT_RSEQTH=21,
+	NET_CORE_WARNINGS=22,
 };
 
 /* /proc/sys/net/ethernet */
--- net-2.6.22.orig/include/net/sock.h	2007-03-08 11:06:36.000000000 -0800
+++ net-2.6.22/include/net/sock.h	2007-03-08 11:26:17.000000000 -0800
@@ -1333,14 +1333,12 @@
 /* 
  *	Enable debug/info messages 
  */
+extern int net_msg_warn;
+#define NETDEBUG(fmt, args...) \
+	do { if (net_msg_warn) printk(fmt,##args); } while (0)
 
-#ifdef CONFIG_NETDEBUG
-#define NETDEBUG(fmt, args...)	printk(fmt,##args)
-#define LIMIT_NETDEBUG(fmt, args...) do { if (net_ratelimit()) printk(fmt,##args); } while(0)
-#else
-#define NETDEBUG(fmt, args...)	do { } while (0)
-#define LIMIT_NETDEBUG(fmt, args...) do { } while(0)
-#endif
+#define LIMIT_NETDEBUG(fmt, args...) \
+	do { if (net_msg_warn && net_ratelimit()) printk(fmt,##args); } while(0)
 
 /*
  * Macros for sleeping on a socket. Use them like this:
--- net-2.6.22.orig/net/Kconfig	2007-03-08 11:21:05.000000000 -0800
+++ net-2.6.22/net/Kconfig	2007-03-08 11:21:16.000000000 -0800
@@ -27,13 +27,6 @@
 
 menu "Networking options"
 
-config NETDEBUG
-	bool "Network packet debugging"
-	help
-	  You can say Y here if you want to get additional messages useful in
-	  debugging bad packets, but can overwhelm logs under denial of service
-	  attacks.
-
 source "net/packet/Kconfig"
 source "net/unix/Kconfig"
 source "net/xfrm/Kconfig"
--- net-2.6.22.orig/net/core/sysctl_net_core.c	2007-03-08 11:10:40.000000000 -0800
+++ net-2.6.22/net/core/sysctl_net_core.c	2007-03-08 11:37:18.000000000 -0800
@@ -136,6 +136,14 @@
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
 	},
+	{
+		.ctl_name	= NET_CORE_WARNINGS,
+		.procname	= "warnings",
+		.data		= &net_msg_warn,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec
+	},
 	{ .ctl_name = 0 }
 };
 
--- net-2.6.22.orig/net/core/utils.c	2007-03-08 11:18:09.000000000 -0800
+++ net-2.6.22/net/core/utils.c	2007-03-08 11:39:08.000000000 -0800
@@ -32,6 +32,8 @@
 
 int net_msg_cost = 5*HZ;
 int net_msg_burst = 10;
+int net_msg_warn = 1;
+EXPORT_SYMBOL(net_msg_warn);
 
 /*
  * All net warning printk()s should be guarded by this function.
