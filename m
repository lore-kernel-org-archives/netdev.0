From: dmitry.krivoschekov@gmail.com
Subject: [PATCH 3/3] ipconfig: look for a network device forever if NFS root
Date: Thu, 16 Apr 2009 13:37:39 +0400
Message-ID: <1239874659-19273-4-git-send-email-dmitry.krivoschekov@gmail.com>
References: <1239874659-19273-1-git-send-email-dmitry.krivoschekov@gmail.com>
Cc: Dmitry Krivoschekov <dkrivoschekov@ru.mvista.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.79.90.228] ([213.79.90.228]:10138 "EHLO
	buildserver.ru.mvista.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751404AbZDPJgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 05:36:11 -0400
In-Reply-To: <1239874659-19273-1-git-send-email-dmitry.krivoschekov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Krivoschekov <dkrivoschekov@ru.mvista.com>

For now ip_auto_config() makes a pause before opening a network device
so the h/w can settle. It may not work well for USB network devices
as the period needed for devices to settle may vary from time to time due
to non-deterministic specifics of USB protocol itself.
The period will also depend on a certain USB configuration, e.g. whether
a USB device is sitting behind a USB hub(s) or not.

The issue gets critical when such a device is used to mount a NFS root
filesystem. Currently if ip_auto_config() can't find a network device
it gives up leaving the kernel in unusable state.

To resolve the issue the patch adds a loop waiting until a
suitable network device gets available.

Signed-off-by: Dmitry Krivoschekov <dkrivoschekov@ru.mvista.com>
---
 net/ipv4/ipconfig.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 8222466..0066424 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -1284,7 +1284,7 @@ static int __init ip_auto_config(void)
 		return 0;
 
 	DBG(("IP-Config: Entered.\n"));
-#ifdef IPCONFIG_DYNAMIC
+#if defined(IPCONFIG_DYNAMIC) || defined(CONFIG_ROOT_NFS)
  try_try_again:
 #endif
 
@@ -1295,8 +1295,16 @@ static int __init ip_auto_config(void)
 	msleep(ic_wait_pre);
 
 	/* Setup all network devices */
-	if (ic_open_devs() < 0)
-		return -1;
+	if (ic_open_devs() < 0) {
+#ifdef CONFIG_ROOT_NFS
+		if (ROOT_DEV ==  Root_NFS) {
+			printk(KERN_ERR	"IP-Config: Could not open device, "
+					"Retrying forever (NFS root)...\n");
+			goto try_try_again;
+		} else
+#endif
+			return -1;
+	}
 
 	if (!ic_wait_post)
 		ic_wait_post = CONF_POST_OPEN;
-- 
1.6.1.2.MVISTA.5.ga9f3b

