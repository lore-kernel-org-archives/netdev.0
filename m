From: "Hiremath, Vaibhav" <hvaibhav@ti.com>
Subject: RE: [PATCH 1/5] ARM: OMAP2+: gpmc: Fix kernel BUG for DT boot mode
Date: Thu, 18 Oct 2012 16:16:48 +0000
Message-ID: <79CD15C6BA57404B839C016229A409A83EB43B17@DBDE01.ent.ti.com>
References: <cover.1350327320.git.richardcochran@gmail.com>
 <41d66042625157d089e9c9532030a6831e79c641.1350327324.git.richardcochran@gmail.com>
 <507DB9EC.9060407@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Mohammed, Afzal" <afzal@ti.com>,
	Russell King <linux@arm.linux.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Tony Lindgren <tony@atomide.com>,
	David Miller <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: "Hunter, Jon" <jon-hunter@ti.com>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:45029 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932172Ab2JRQRF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 12:17:05 -0400
In-Reply-To: <507DB9EC.9060407@ti.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 17, 2012 at 01:17:56, Hunter, Jon wrote:
> 
> On 10/15/2012 02:16 PM, Richard Cochran wrote:
> > From: hvaibhav@ti.com <hvaibhav@ti.com>
> > 
> > With recent changes in omap gpmc driver code, in case of DT
> > boot mode, where bootloader does not configure gpmc cs space
> > will result into kernel BUG() inside gpmc_mem_init() function,
> > as gpmc cs0 gpmc_config7[0].csvalid bit is set to '1' and
> > gpmc_config7[0].baseaddress is set to '0' on reset.
> 
> I am not sure I completely follow the logic here.
> 
> Won't this problem occur if the bootloader does not configure the gpmc
> cs space AND we are not using DT?
> 

That's what exactly the above comment describes.

> Is the csvalid bit set because we are booting from the internal ROM?
> 

As per TRM, the reset value of the CS0_valis bit is set to 0. I have pasted 
TRM statement below -

"Chip-select enable (reset value is 1 for CS[0] and 0 for CS[1-5])."

And same applies to OMAP3 family of devices.

> I guess I don't see why csvalid bit being set and a base-address of 0x0
> should not be allowed. That should be a valid combination.
> 

Yes, agreed.

> One problem I see with gpmc_mem_init() is that it assumes that
> BOOT_ROM_SPACE is 1MB for all devices starting at 0x0 apart from the
> apollon board. For newer devices such as OMAP4, there is only 48KB of
> internal ROM and only mapped to 0x0 when booting from internal ROM. So
> this needs to be fixed.
> 
> How much internal ROM does the AM335x have and where is it mapped?
> 

AM33xx memory map is something like,

Boot ROM  0x4000_0000 0x4001_FFFF 128KB
          0x4002_0000 0x4002_BFFF 48KB    32-bit Ex/R(1) - Public
Reserved  0x4002_C000 0x400F_FFFF 848KB   Reserved
Reserved  0x4010_0000 0x401F_FFFF 1MB     Reserved
Reserved  0x4020_0000 0x402E_FFFF 960KB   Reserved
Reserved  0x402f_0000 0x4020_03FF 64KB    Reserved
SRAM internal 0x402F_0400 0x402F_FFFF    32-bit Ex/R/W(1)


> > This use-case is applicable for any board/EVM which doesn't have
> > any peripheral connected to gpmc cs0, for example BeagleXM and
> > BeagleBone, so DT boot mode fails.
> > 
> > This patch adds of_have_populated_dt() check before creating
> > device, so that for DT boot mode, gpmc probe will not be called
> > which is expected behavior, as gpmc is not supported yet from DT.
> 
> Yes, but we do actually still allow some platform devices to be probed
> (such as dmtimers) when booting with DT that don't support DT yet. So
> this change prevents us from using the gpmc on boards when booting with DT.
> 

The idea here was,

In order to use GPMC in meaningful way, where some peripheral is connected 
to the GPMC, you must create platform_device for the probe to happen 
properly. Now all the devices I know so far, we have gpmc_smsc911x_init(), 
omap_nand_flash_init(), etc...
These api's are getting called only through machine_desc.init_xxx callbacks,
And in case of DT, we have centralized machine_desc definition for all 
platforms (board-generic.c). So even though you want to use GPMC for DT boot
mode, you can not make use of peripheral without changing board-files to 
change to create platform_device.

Does it make sense?

> I am not convinced that this is addressing the underlying problem with
> gpmc_mem_init().
> 

The patch you submitted is cleanup patch and is required irrespective of 
this patch. I believe this patch is just makes sure that, if you are booting 
from DT and you do not have meaningful DT node for GPMC and peripheral 
interfaced to it, no point in probing it. 

Does it make any sense???


On other hand, Your patch is anyway required, as that I would consider as 
cleanup of existing code (in error handling).

Thanks,
Vaibhav

> Cheers
> Jon
> 
