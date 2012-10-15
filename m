From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 1/5] ARM: OMAP2+: gpmc: Fix kernel BUG for DT boot mode
Date: Mon, 15 Oct 2012 21:16:31 +0200
Message-ID: <41d66042625157d089e9c9532030a6831e79c641.1350327324.git.richardcochran@gmail.com>
References: <cover.1350327320.git.richardcochran@gmail.com>
Cc: <linux-arm-kernel@lists.infradead.org>,
	Arnd Bergmann <arnd@arndb.de>,
	David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	"hvaibhav@ti.com" <hvaibhav@ti.com>, Afzal Mohammed <afzal@ti.com>,
	Tony Lindgren <tony@atomide.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:60571 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754488Ab2JOTQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 15:16:50 -0400
Received: by mail-wi0-f172.google.com with SMTP id hq12so2528454wib.1
        for <netdev@vger.kernel.org>; Mon, 15 Oct 2012 12:16:50 -0700 (PDT)
In-Reply-To: <cover.1350327320.git.richardcochran@gmail.com>
In-Reply-To: <cover.1350327320.git.richardcochran@gmail.com>
References: <cover.1350327320.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: hvaibhav@ti.com <hvaibhav@ti.com>

With recent changes in omap gpmc driver code, in case of DT
boot mode, where bootloader does not configure gpmc cs space
will result into kernel BUG() inside gpmc_mem_init() function,
as gpmc cs0 gpmc_config7[0].csvalid bit is set to '1' and
gpmc_config7[0].baseaddress is set to '0' on reset.

This use-case is applicable for any board/EVM which doesn't have
any peripheral connected to gpmc cs0, for example BeagleXM and
BeagleBone, so DT boot mode fails.

This patch adds of_have_populated_dt() check before creating
device, so that for DT boot mode, gpmc probe will not be called
which is expected behavior, as gpmc is not supported yet from DT.

Signed-off-by: Vaibhav Hiremath <hvaibhav@ti.com>
Cc: Afzal Mohammed <afzal@ti.com>
Cc: Tony Lindgren <tony@atomide.com>
Cc Paul Walmsley <paul@pwsan.com>
---
 arch/arm/mach-omap2/gpmc.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-omap2/gpmc.c b/arch/arm/mach-omap2/gpmc.c
index 5ac5cf3..90b033e 100644
--- a/arch/arm/mach-omap2/gpmc.c
+++ b/arch/arm/mach-omap2/gpmc.c
@@ -981,6 +981,10 @@ static int __init omap_gpmc_init(void)
 	struct platform_device *pdev;
 	char *oh_name = "gpmc";
 
+	/* If dtb is there, the devices will be created dynamically */
+	if (of_have_populated_dt())
+		return -ENODEV;
+
 	oh = omap_hwmod_lookup(oh_name);
 	if (!oh) {
 		pr_err("Could not look up %s\n", oh_name);
-- 
1.7.2.5
