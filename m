From: Erwan Velu <erwanaliasr1@gmail.com>
Subject: [PATCH] ipconfig: Inform user if carrier is not ready
Date: Thu, 13 Sep 2012 23:59:52 +0200
Message-ID: <50525758.1090609@gmail.com>
References: <5052403B.4040408@gmail.com> <20120913.163134.361379133013906511.davem@davemloft.net> <50524419.4080404@gmail.com> <20120913.164525.1171098883605242394.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:47319 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758834Ab2IMV77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 17:59:59 -0400
Received: by weyx8 with SMTP id x8so1987489wey.19
        for <netdev@vger.kernel.org>; Thu, 13 Sep 2012 14:59:58 -0700 (PDT)
In-Reply-To: <20120913.164525.1171098883605242394.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erwan Velu <erwanaliasr1@gmail.com>

While using the ip= option at the cmdline, the kernel can hold the boot
process for 2 minutes (CONF_CARRIER_TIMEOUT) if the carrier is not
present.

While waiting the carrier, user is not informed about this situation and
so could think the kernel is frozen.

This patch is just adding a simple message every second telling we are
waiting the carrier to come up.
---
  net/ipv4/ipconfig.c |    8 ++++++++
  1 file changed, 8 insertions(+)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 67e8a6b..d9f34b7 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -205,6 +205,7 @@ static int __init ic_open_devs(void)
      struct net_device *dev;
      unsigned short oflags;
      unsigned long start;
+    unsigned int loops=0;

      last = &ic_first_dev;
      rtnl_lock();
@@ -266,6 +267,13 @@ static int __init ic_open_devs(void)
              if (ic_is_init_dev(dev) && netif_carrier_ok(dev))
                  goto have_carrier;

+        loops++;
+        /* This loop is blocking the boot process until we get the 
carrier or reach the timeout.
+         * We have to inform the user about the situation as it could 
look like a kernel freeze.
+         * Every second, we display a short message indicating we wait 
the carrier */
+        if ((loops % 1000) == 0) {
+            pr_info("IP-Config: Waiting Carrier (%d/%d):\n",loops / 
1000, CONF_CARRIER_TIMEOUT / 1000);
+        }
          msleep(1);
      }
  have_carrier:
-- 
1.7.10
