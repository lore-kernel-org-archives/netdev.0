From: Jon Hunter <jon-hunter@ti.com>
Subject: Re: [PATCH 1/5] ARM: OMAP2+: gpmc: Fix kernel BUG for DT boot mode
Date: Wed, 17 Oct 2012 09:41:25 -0500
Message-ID: <507EC395.7060409@ti.com>
References: <cover.1350327320.git.richardcochran@gmail.com> <41d66042625157d089e9c9532030a6831e79c641.1350327324.git.richardcochran@gmail.com> <20121016174835.GV15569@atomide.com> <507DCA8D.7060309@ti.com> <20121016212647.GM15569@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	Afzal Mohammed <afzal@ti.com>,
	Russell King <linux@arm.linux.org.uk>,
	Arnd Bergmann <arnd@arndb.de>, <netdev@vger.kernel.org>,
	"hvaibhav@ti.com" <hvaibhav@ti.com>,
	David Miller <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: Tony Lindgren <tony@atomide.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:45936 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757063Ab2JQOll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2012 10:41:41 -0400
In-Reply-To: <20121016212647.GM15569@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 10/16/2012 04:26 PM, Tony Lindgren wrote:
> * Jon Hunter <jon-hunter@ti.com> [121016 14:00]:
>> Hi Tony,
>>
>> On 10/16/2012 12:48 PM, Tony Lindgren wrote:
>>> * Richard Cochran <richardcochran@gmail.com> [121015 12:18]:
>>>> From: hvaibhav@ti.com <hvaibhav@ti.com>
>>>>
>>>> With recent changes in omap gpmc driver code, in case of DT
>>>> boot mode, where bootloader does not configure gpmc cs space
>>>> will result into kernel BUG() inside gpmc_mem_init() function,
>>>> as gpmc cs0 gpmc_config7[0].csvalid bit is set to '1' and
>>>> gpmc_config7[0].baseaddress is set to '0' on reset.
>>>>
>>>> This use-case is applicable for any board/EVM which doesn't have
>>>> any peripheral connected to gpmc cs0, for example BeagleXM and
>>>> BeagleBone, so DT boot mode fails.
>>>>
>>>> This patch adds of_have_populated_dt() check before creating
>>>> device, so that for DT boot mode, gpmc probe will not be called
>>>> which is expected behavior, as gpmc is not supported yet from DT.
>>>
>>> I'm applying this one into omap-for-v3.7-rc1/fixes-part2.
>>>
>>> Next time, please also cc linux-omap@vger.kernel.org for series
>>> like this. I'm sure the people reading the omap list are interested
>>> in these.
>>
>> This patch appears to be masking an underlying issue. How about 
>> something like the following ...
> 
> OK that looks good to me. I'll drop the earlier fix and use
> yours instead.

Hi Tony, sorry but I realised now that in my patch that I need to
take care of releasing and memory and clocks that were acquired 
during the probe. Here is a V2. If you prefer I can create a delta
patch also with the previous. 

Cheers
Jon

>From 91f5234d567c07ce1579b50e52de1a1e06ce5c68 Mon Sep 17 00:00:00 2001
From: Jon Hunter <jon-hunter@ti.com>
Date: Tue, 16 Oct 2012 15:22:58 -0500
Subject: [PATCH V2] ARM: OMAP2+: Allow kernel to boot even if GPMC fails to
 reserve memory

Currently, if the GPMC driver fails to reserve memory when probed we will
call BUG() and the kernel will not boot. Instead of calling BUG(), return
an error from probe and allow kernel to boot.

Boot tested on AM335x beagle bone board and OMAP4430 Panda board.

V2 changes:
- Ensure that clock and memory resources are released on error.

Signed-off-by: Jon Hunter <jon-hunter@ti.com>
---
 arch/arm/mach-omap2/gpmc.c |   24 +++++++++++++++++++-----
 1 file changed, 19 insertions(+), 5 deletions(-)

diff --git a/arch/arm/mach-omap2/gpmc.c b/arch/arm/mach-omap2/gpmc.c
index 5ac5cf3..92b5718 100644
--- a/arch/arm/mach-omap2/gpmc.c
+++ b/arch/arm/mach-omap2/gpmc.c
@@ -868,9 +868,9 @@ static void __devexit gpmc_mem_exit(void)
 
 }
 
-static void __devinit gpmc_mem_init(void)
+static int __devinit gpmc_mem_init(void)
 {
-	int cs;
+	int cs, rc;
 	unsigned long boot_rom_space = 0;
 
 	/* never allocate the first page, to facilitate bug detection;
@@ -890,13 +890,21 @@ static void __devinit gpmc_mem_init(void)
 		if (!gpmc_cs_mem_enabled(cs))
 			continue;
 		gpmc_cs_get_memconf(cs, &base, &size);
-		if (gpmc_cs_insert_mem(cs, base, size) < 0)
-			BUG();
+		rc = gpmc_cs_insert_mem(cs, base, size);
+		if (IS_ERR_VALUE(rc)) {
+			while (--cs >= 0)
+				if (gpmc_cs_mem_enabled(cs))
+					gpmc_cs_delete_mem(cs);
+			return rc;
+		}
 	}
+
+	return 0;
 }
 
 static __devinit int gpmc_probe(struct platform_device *pdev)
 {
+	int rc;
 	u32 l;
 	struct resource *res;
 
@@ -936,7 +944,13 @@ static __devinit int gpmc_probe(struct platform_device *pdev)
 	dev_info(gpmc_dev, "GPMC revision %d.%d\n", GPMC_REVISION_MAJOR(l),
 		 GPMC_REVISION_MINOR(l));
 
-	gpmc_mem_init();
+	rc = gpmc_mem_init();
+	if (IS_ERR_VALUE(rc)) {
+		clk_disable_unprepare(gpmc_l3_clk);
+		clk_put(gpmc_l3_clk);
+		dev_err(gpmc_dev, "failed to reserve memory\n");
+		return rc;
+	}
 
 	if (IS_ERR_VALUE(gpmc_setup_irq()))
 		dev_warn(gpmc_dev, "gpmc_setup_irq failed\n");
-- 
1.7.9.5
 
