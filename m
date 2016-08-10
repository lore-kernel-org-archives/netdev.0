From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] net: ipconfig: fix use after free
Date: Wed, 10 Aug 2016 11:44:17 +0200
Message-ID: <1470822257-13275-1-git-send-email-u.kleine-koenig@pengutronix.de>
References: <CAMuHMdVjugL0y-C+vet=qbcER8rjuFKwFgrutRUAs=uOk0JZ1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
	Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
	kernel@pengutronix.de
To: Geert Uytterhoeven <geert@linux-m68k.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:53644 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S938784AbcHJTC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 15:02:26 -0400
In-Reply-To: <CAMuHMdVjugL0y-C+vet=qbcER8rjuFKwFgrutRUAs=uOk0JZ1A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ic_close_devs() calls kfree() for all devices's ic_device. Since commit
2647cffb2bc6 ("net: ipconfig: Support using "delayed" DHCP replies")
the active device's ic_device is still used however to print the
ipconfig summary which results in an oops if the memory is already
changed. So delay freeing until after the autoconfig results are
reported.

Fixes: 2647cffb2bc6 ("net: ipconfig: Support using "delayed" DHCP replies")
Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>
---
 net/ipv4/ipconfig.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 42cf629357b5..66c2fe602810 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -1493,14 +1493,6 @@ static int __init ip_auto_config(void)
 		return -1;
 
 	/*
-	 * Close all network devices except the device we've
-	 * autoconfigured and set up routes.
-	 */
-	ic_close_devs();
-	if (ic_setup_if() < 0 || ic_setup_routes() < 0)
-		return -1;
-
-	/*
 	 * Record which protocol was actually used.
 	 */
 #ifdef IPCONFIG_DYNAMIC
@@ -1534,6 +1526,15 @@ static int __init ip_auto_config(void)
 	pr_cont("\n");
 #endif /* !SILENT */
 
+	/*
+	 * Close all network devices except the device we've
+	 * autoconfigured and set up routes.
+	 */
+	ic_close_devs();
+	if (ic_setup_if() < 0 || ic_setup_routes() < 0)
+		return -1;
+
+
 	return 0;
 }
 
-- 
2.8.1
