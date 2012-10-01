From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH 2/2] tg3: fix build-time dependency with
 IS_DEPENDENCY_SATISFIED()
Date: Mon, 1 Oct 2012 12:10:59 -0400
Message-ID: <20121001161059.GA27396@windriver.com>
References: <1349094080-769-1-git-send-email-anisse@astier.eu>
 <1349094080-769-2-git-send-email-anisse@astier.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Michal Marek <mmarek@suse.cz>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Michael Chan" <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Anisse Astier <anisse@astier.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:38181 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430Ab2JAQLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 12:11:14 -0400
Content-Disposition: inline
In-Reply-To: <1349094080-769-2-git-send-email-anisse@astier.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[[PATCH 2/2] tg3: fix build-time dependency with IS_DEPENDENCY_SATISFIED()] On 01/10/2012 (Mon 14:21) Anisse Astier wrote:

> When CONFIG_TIGON3=y and CONFIG_HWMON=y, we will get this error:
>   LD      init/built-in.o
> drivers/built-in.o: In function `tg3_hwmon_open':
> tg3.c:(.text+0xc1d12): undefined reference to `hwmon_device_register'
> drivers/built-in.o: In function `tg3_close':
> tg3.c:(.text+0xc2e7f): undefined reference to `hwmon_device_unregister'
> make: *** [vmlinux] Error 1
> 
> Use the new IS_DEPENDENCY_SATISFIED() facility to solve this problem.

Even though my fingerprints may be on IS_ENABLED, I'm not a fan of using
it (or things like this extension) all over the place for #ifdef blocks
that can be avoided some other clean way.

How about we just fix this the way Dave suggested a few months ago?

P.

--

>From e7c432cf5eb44b188c1aa2b188877c42300de8b9 Mon Sep 17 00:00:00 2001
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 1 Oct 2012 11:43:49 -0400
Subject: [PATCH] tg3: unconditionally select HWMON support when tg3 is
 enabled.

There is the seldom used corner case where HWMON=m at the same
time as TIGON3=y (typically randconfigs) which will cause a link
fail like:

drivers/built-in.o: In function `tg3_close':
tg3.c:(.text+0x16bd86): undefined reference to `hwmon_device_unregister'
drivers/built-in.o: In function `tg3_hwmon_open':
tg3.c:(.text+0x16fc4b): undefined reference to `hwmon_device_register'
make[1]: *** [vmlinux] Error 1

Fix it as suggested by DaveM[1] by having the Kconfig logic simply
select HWMON when TIGON3 is selected.  This gets rid of all the
extra IS_ENABLED ifdeffery in tg3.c as a side benefit.

[1] http://marc.info/?l=linux-netdev&m=134250573718151&w=2

Cc: Michael Chan <mchan@broadcom.com>
Reported-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Reported-by: Anisse Astier <anisse@astier.eu>
Suggested-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/ethernet/broadcom/Kconfig | 1 +
 drivers/net/ethernet/broadcom/tg3.c   | 9 ---------
 2 files changed, 1 insertion(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index f15e72e..4bd416b 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -101,6 +101,7 @@ config TIGON3
 	tristate "Broadcom Tigon3 support"
 	depends on PCI
 	select PHYLIB
+	select HWMON
 	---help---
 	  This driver supports Broadcom Tigon3 based gigabit Ethernet cards.
 
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index bf906c5..711eb14 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -44,10 +44,8 @@
 #include <linux/prefetch.h>
 #include <linux/dma-mapping.h>
 #include <linux/firmware.h>
-#if IS_ENABLED(CONFIG_HWMON)
 #include <linux/hwmon.h>
 #include <linux/hwmon-sysfs.h>
-#endif
 
 #include <net/checksum.h>
 #include <net/ip.h>
@@ -9517,7 +9515,6 @@ static int tg3_init_hw(struct tg3 *tp, int reset_phy)
 	return tg3_reset_hw(tp, reset_phy);
 }
 
-#if IS_ENABLED(CONFIG_HWMON)
 static void tg3_sd_scan_scratchpad(struct tg3 *tp, struct tg3_ocir *ocir)
 {
 	int i;
@@ -9570,22 +9567,17 @@ static const struct attribute_group tg3_group = {
 	.attrs = tg3_attributes,
 };
 
-#endif
-
 static void tg3_hwmon_close(struct tg3 *tp)
 {
-#if IS_ENABLED(CONFIG_HWMON)
 	if (tp->hwmon_dev) {
 		hwmon_device_unregister(tp->hwmon_dev);
 		tp->hwmon_dev = NULL;
 		sysfs_remove_group(&tp->pdev->dev.kobj, &tg3_group);
 	}
-#endif
 }
 
 static void tg3_hwmon_open(struct tg3 *tp)
 {
-#if IS_ENABLED(CONFIG_HWMON)
 	int i, err;
 	u32 size = 0;
 	struct pci_dev *pdev = tp->pdev;
@@ -9617,7 +9609,6 @@ static void tg3_hwmon_open(struct tg3 *tp)
 		dev_err(&pdev->dev, "Cannot register hwmon device, aborting\n");
 		sysfs_remove_group(&pdev->dev.kobj, &tg3_group);
 	}
-#endif
 }
 
 
-- 
1.7.11.1
