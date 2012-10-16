From: Jon Hunter <jon-hunter@ti.com>
Subject: Re: [PATCH 1/5] ARM: OMAP2+: gpmc: Fix kernel BUG for DT boot mode
Date: Tue, 16 Oct 2012 15:58:53 -0500
Message-ID: <507DCA8D.7060309@ti.com>
References: <cover.1350327320.git.richardcochran@gmail.com> <41d66042625157d089e9c9532030a6831e79c641.1350327324.git.richardcochran@gmail.com> <20121016174835.GV15569@atomide.com>
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
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20121016174835.GV15569@atomide.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tony,

On 10/16/2012 12:48 PM, Tony Lindgren wrote:
> * Richard Cochran <richardcochran@gmail.com> [121015 12:18]:
>> From: hvaibhav@ti.com <hvaibhav@ti.com>
>>
>> With recent changes in omap gpmc driver code, in case of DT
>> boot mode, where bootloader does not configure gpmc cs space
>> will result into kernel BUG() inside gpmc_mem_init() function,
>> as gpmc cs0 gpmc_config7[0].csvalid bit is set to '1' and
>> gpmc_config7[0].baseaddress is set to '0' on reset.
>>
>> This use-case is applicable for any board/EVM which doesn't have
>> any peripheral connected to gpmc cs0, for example BeagleXM and
>> BeagleBone, so DT boot mode fails.
>>
>> This patch adds of_have_populated_dt() check before creating
>> device, so that for DT boot mode, gpmc probe will not be called
>> which is expected behavior, as gpmc is not supported yet from DT.
> 
> I'm applying this one into omap-for-v3.7-rc1/fixes-part2.
> 
> Next time, please also cc linux-omap@vger.kernel.org for series
> like this. I'm sure the people reading the omap list are interested
> in these.

This patch appears to be masking an underlying issue. How about 
something like the following ...

Cheers
Jon

>From 753a4928bf6f7baa4c001bdca3d15a85e999db4c Mon Sep 17 00:00:00 2001
From: Jon Hunter <jon-hunter@ti.com>
Date: Tue, 16 Oct 2012 15:22:58 -0500
Subject: [PATCH] ARM: OMAP2+: Allow kernel to boot even if GPMC fails to
 reserve memory

Currently, if the GPMC driver fails to reserve memory when probed we will
call BUG() and the kernel will not boot. Instead of calling BUG(), return
an error from probe and allow kernel to boot.

Tested on AM335x beagle bone board.

Signed-off-by: Jon Hunter <jon-hunter@ti.com>
---
 arch/arm/mach-omap2/gpmc.c |   18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/arch/arm/mach-omap2/gpmc.c b/arch/arm/mach-omap2/gpmc.c
index 5ac5cf3..8f0d3c8 100644
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
@@ -890,13 +890,17 @@ static void __devinit gpmc_mem_init(void)
 		if (!gpmc_cs_mem_enabled(cs))
 			continue;
 		gpmc_cs_get_memconf(cs, &base, &size);
-		if (gpmc_cs_insert_mem(cs, base, size) < 0)
-			BUG();
+		rc = gpmc_cs_insert_mem(cs, base, size);
+		if (IS_ERR_VALUE(rc))
+			return rc;
 	}
+
+	return 0;
 }
 
 static __devinit int gpmc_probe(struct platform_device *pdev)
 {
+	int rc;
 	u32 l;
 	struct resource *res;
 
@@ -936,7 +940,11 @@ static __devinit int gpmc_probe(struct platform_device *pdev)
 	dev_info(gpmc_dev, "GPMC revision %d.%d\n", GPMC_REVISION_MAJOR(l),
 		 GPMC_REVISION_MINOR(l));
 
-	gpmc_mem_init();
+	rc = gpmc_mem_init();
+	if (IS_ERR_VALUE(rc)) {
+		dev_err(gpmc_dev, "failed to reserve memory\n");
+		return rc;
+	}
 
 	if (IS_ERR_VALUE(gpmc_setup_irq()))
 		dev_warn(gpmc_dev, "gpmc_setup_irq failed\n");
-- 
1.7.9.5
