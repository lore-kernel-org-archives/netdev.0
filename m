From: dmitry.krivoschekov@gmail.com
Subject: [PATCH 2/3] ipconfig: add 'ipwait' cmdline parameter
Date: Thu, 16 Apr 2009 13:37:38 +0400
Message-ID: <1239874659-19273-3-git-send-email-dmitry.krivoschekov@gmail.com>
References: <1239874659-19273-1-git-send-email-dmitry.krivoschekov@gmail.com>
Cc: Dmitry Krivoschekov <dkrivoschekov@ru.mvista.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.79.90.228] ([213.79.90.228]:10139 "EHLO
	buildserver.ru.mvista.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752249AbZDPJgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 05:36:11 -0400
In-Reply-To: <1239874659-19273-1-git-send-email-dmitry.krivoschekov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Krivoschekov <dkrivoschekov@ru.mvista.com>

Adding a cmdline parameter so it's possible to change the delay
before and after opening a network device, e.g. "ipwait=300,700"
sets a delay for 300 and 700 msec before and after opening respectively.

Signed-off-by: Dmitry Krivoschekov <dkrivoschekov@ru.mvista.com>
---
 Documentation/filesystems/nfsroot.txt |   11 +++++++++++
 net/ipv4/ipconfig.c                   |   29 ++++++++++++++++++++++++++---
 2 files changed, 37 insertions(+), 3 deletions(-)

diff --git a/Documentation/filesystems/nfsroot.txt b/Documentation/filesystems/nfsroot.txt
index 68baddf..9b05025 100644
--- a/Documentation/filesystems/nfsroot.txt
+++ b/Documentation/filesystems/nfsroot.txt
@@ -156,8 +156,19 @@ ip=<client-ip>:<server-ip>:<gw-ip>:<netmask>:<hostname>:<device>:<autoconf>
 
                 Default: any
 
+ipwait=<delay-pre>,<delay-post>
 
+  This parameter allows you to change a pause before and after opening of
+  a network device. It is useful if you want to optimize boot-up time for
+  your system, or if default delays are not sufficient for your net device.
 
+  <delay-pre>	Delay (in msecs) to pause before opening a net device
+
+                Default: 500 msec
+
+  <delay-post>	Delay (in msecs) to pause after a net device has been opened
+
+                Default: 1000 msec
 
 3.) Boot Loader
     ----------
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 4c6e38f..8222466 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -85,7 +85,7 @@
 #define IPCONFIG_DYNAMIC
 #endif
 
-/* Define the friendly delay before and after opening net devices */
+/* Define the default friendly delay before and after opening net devices */
 #define CONF_PRE_OPEN		500	/* Before opening: 1/2 second */
 #define CONF_POST_OPEN		1000	/* After opening: 1 second */
 
@@ -182,6 +182,10 @@ struct ic_device {
 static struct ic_device *ic_first_dev __initdata = NULL;/* List of open device */
 static struct net_device *ic_dev __initdata = NULL;	/* Selected device */
 
+/* delay before and after opening devices */
+static unsigned long ic_wait_pre __initdata;
+static unsigned long ic_wait_post __initdata;
+
 static int __init ic_open_devs(void)
 {
 	struct ic_device *d, **last;
@@ -1283,15 +1287,22 @@ static int __init ip_auto_config(void)
 #ifdef IPCONFIG_DYNAMIC
  try_try_again:
 #endif
+
+	if (!ic_wait_pre)
+		ic_wait_pre = CONF_PRE_OPEN;
+
 	/* Give hardware a chance to settle */
-	msleep(CONF_PRE_OPEN);
+	msleep(ic_wait_pre);
 
 	/* Setup all network devices */
 	if (ic_open_devs() < 0)
 		return -1;
 
+	if (!ic_wait_post)
+		ic_wait_post = CONF_POST_OPEN;
+
 	/* Give drivers a chance to settle */
-	msleep(CONF_POST_OPEN);
+	msleep(ic_wait_post);
 
 	/*
 	 * If the config information is insufficient (e.g., our IP address or
@@ -1529,6 +1540,18 @@ static int __init vendor_class_identifier_setup(char *addrs)
 	return 1;
 }
 
+static int __init ipwait_setup(char *addrs)
+{
+	char *p;
+
+	p = strsep(&addrs, ",");
+	if (strict_strtoul(p, 10, &ic_wait_pre) == 0)
+		strict_strtoul(addrs, 10, &ic_wait_post);
+
+	return 1;
+}
+
 __setup("ip=", ip_auto_config_setup);
+__setup("ipwait=", ipwait_setup);
 __setup("nfsaddrs=", nfsaddrs_config_setup);
 __setup("dhcpclass=", vendor_class_identifier_setup);
-- 
1.6.1.2.MVISTA.5.ga9f3b

