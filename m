From: Erwan Velu <erwanaliasr1@gmail.com>
Subject: [PATCH v4] ipconfig: Inform user if carrier is not ready
Date: Fri, 14 Sep 2012 22:56:19 +0200
Message-ID: <1347656179-17638-1-git-send-email-erwanaliasr1@gmail.com>
Cc: Erwan Velu <erwanaliasr1@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:45104 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172Ab2INU4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2012 16:56:34 -0400
Received: by weyx8 with SMTP id x8so2633238wey.19
        for <netdev@vger.kernel.org>; Fri, 14 Sep 2012 13:56:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While using the ip= option at the cmdline, the kernel can hold the boot
process for 2 minutes (CONF_CARRIER_TIMEOUT) if the carrier is not
present.

While waiting the carrier, user is not informed about this situation and
so could think the kernel is frozen.

If we don't get the carrier after some seconds, let's display a message to
inform the user about the remaining time before reaching the timeout.

Signed-off-by: Erwan Velu <erwanaliasr1@gmail.com>
---
 net/ipv4/ipconfig.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 67e8a6b..fb17bad 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -90,6 +90,7 @@
 /* Define the friendly delay before and after opening net devices */
 #define CONF_POST_OPEN		10	/* After opening: 10 msecs */
 #define CONF_CARRIER_TIMEOUT	120000	/* Wait for carrier timeout */
+#define CONF_WARN_CARRIER_TIMEOUT 5000	/* Time before showing a warning message  */
 
 /* Define the timeout for waiting for a DHCP/BOOTP/RARP reply */
 #define CONF_OPEN_RETRIES 	2	/* (Re)open devices twice */
@@ -205,6 +206,7 @@ static int __init ic_open_devs(void)
 	struct net_device *dev;
 	unsigned short oflags;
 	unsigned long start;
+	unsigned int loops = 0;
 
 	last = &ic_first_dev;
 	rtnl_lock();
@@ -266,6 +268,17 @@ static int __init ic_open_devs(void)
 			if (ic_is_init_dev(dev) && netif_carrier_ok(dev))
 				goto have_carrier;
 
+		/* This loop is blocking the boot process until 
+		 *  we get the carrier or reach the timeout.
+		 *  We have to inform the user about the situation as 
+		 *  it could look like a kernel freeze.
+		 *  After CONF_WARN_CARRIER_TIMEOUT milliseconds,
+		 *  we display the remaing time before reaching the timeout.
+		 */
+		if (++loops == CONF_WARN_CARRIER_TIMEOUT) {
+			pr_info("IP-Config: Waiting up to %d seconds for carrier on interface\n", 
+				(CONF_CARRIER_TIMEOUT - CONF_WARN_CARRIER_TIMEOUT)/ 1000);
+		}
 		msleep(1);
 	}
 have_carrier:
-- 
1.7.10
