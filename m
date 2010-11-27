From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH] b44: fix workarround for wap54g10
Date: Sat, 27 Nov 2010 17:47:43 +0100
Message-ID: <1290876463-4372-1-git-send-email-hauke@hauke-m.de>
Cc: netdev@vger.kernel.org, Hauke Mehrtens <hauke@hauke-m.de>
To: zambrano@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:56431 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752944Ab0K0Q4H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Nov 2010 11:56:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code for the b44_wap54g10_workaround was never included, because
the config option was wrong. The nvram_get function was never in
mainline kernel, only in external OpenWrt patches.

The code should be compiled in when CONFIG_BCM47XX is selected and not
when CONFIG_SSB_DRIVER_MIPS is selected, because nvram_getenv is only
available on bcm47xx platforms and now in the mainline kernel code.
Using an include is better than a second function declaration, to fix
this when the function signature changes.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/b44.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index c6e8631..2e2b762 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -381,11 +381,11 @@ static void b44_set_flow_ctrl(struct b44 *bp, u32 local, u32 remote)
 	__b44_set_flow_ctrl(bp, pause_enab);
 }
 
-#ifdef SSB_DRIVER_MIPS
-extern char *nvram_get(char *name);
+#ifdef CONFIG_BCM47XX
+#include <asm/mach-bcm47xx/nvram.h>
 static void b44_wap54g10_workaround(struct b44 *bp)
 {
-	const char *str;
+	char buf[20];
 	u32 val;
 	int err;
 
@@ -394,10 +394,9 @@ static void b44_wap54g10_workaround(struct b44 *bp)
 	 * see https://dev.openwrt.org/ticket/146
 	 * check and reset bit "isolate"
 	 */
-	str = nvram_get("boardnum");
-	if (!str)
+	if (nvram_getenv("boardnum", buf, sizeof(buf)) < 0)
 		return;
-	if (simple_strtoul(str, NULL, 0) == 2) {
+	if (simple_strtoul(buf, NULL, 0) == 2) {
 		err = __b44_readphy(bp, 0, MII_BMCR, &val);
 		if (err)
 			goto error;
-- 
1.7.1

