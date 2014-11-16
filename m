From: Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>
Subject: [PATCH] net/at91_ether: fix loading when macb is compiled as a module
Date: Sun, 16 Nov 2014 19:05:06 +0100
Message-ID: <1416161106-27498-1-git-send-email-gilles.chanteperdrix@xenomai.org>
Cc: Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>
To: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-51317.dedibox.fr ([62.210.215.82]:36242 "EHLO
	sd-51317.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751282AbaKPSV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 13:21:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The at91_ether driver depends on symbols defined in the macb driver.

Currently, when compiling both at91_ether and macb as module, starting
the at91_ether module fails, because the macb module can not be loaded
with a macb interface.

Avoid this issue by getting the macb module initialization routine to
always return 0, even when no macb device is detected.

Signed-off-by: Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>
---
 drivers/net/ethernet/cadence/macb.c |   15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 4d9fc05..f70228c 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2327,7 +2327,20 @@ static struct platform_driver macb_driver = {
 	},
 };
 
-module_platform_driver_probe(macb_driver, macb_probe);
+static bool found;
+static int __init macb_driver_init(void)
+{
+	found = platform_driver_probe(&macb_driver, macb_probe) == 0;
+	return 0;
+}
+module_init(macb_driver_init);
+
+static void __exit macb_driver_exit(void)
+{
+	if (found)
+		platform_driver_unregister(&macb_driver);
+}
+module_exit(macb_driver_exit);
 
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("Cadence MACB/GEM Ethernet driver");
-- 
1.7.10.4
