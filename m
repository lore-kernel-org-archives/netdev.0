From: Jens Kuske <jenskuske-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/3] net: allwinner: sun4i-emac: fix emac
 SRAM mapping
Date: Mon, 26 Jan 2015 15:34:49 +0100
Message-ID: <54C65089.70305@gmail.com>
References: <1422200959-1717-1-git-send-email-jenskuske@gmail.com> <1422200959-1717-4-git-send-email-jenskuske@gmail.com> <20150125162510.GK8470@lukather>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Lee Jones <lee.jones-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
 linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <linux-sunxi+bncBCC5XIE2SIHBBDFBTGTAKGQEAINPHTY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <20150125162510.GK8470@lukather>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <http://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

Hi,

On 25/01/15 17:25, Maxime Ripard wrote:
> Hi Jens,
>
> On Sun, Jan 25, 2015 at 04:49:19PM +0100, Jens Kuske wrote:
>> The EMAC needs SRAM block A3_A4 being mapped to EMAC peripheral to
>> work. This is done by the bootloader most of the time, but U-Boot
>> Falcon Mode, for example, skips emac initialization and SRAM would
>> stay mapped to the CPU.
>
> Thanks for reviving this.
>
>> Signed-off-by: Jens Kuske <jenskuske-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>>   drivers/net/ethernet/allwinner/Kconfig      |  1 +
>>   drivers/net/ethernet/allwinner/sun4i-emac.c | 18 ++++++++++++++++++
>>   2 files changed, 19 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/allwinner/Kconfig b/drivers/net/ethernet/allwinner/Kconfig
>> index d8d95d4..508a288 100644
>> --- a/drivers/net/ethernet/allwinner/Kconfig
>> +++ b/drivers/net/ethernet/allwinner/Kconfig
>> @@ -28,6 +28,7 @@ config SUN4I_EMAC
>>   	select MII
>>   	select PHYLIB
>>   	select MDIO_SUN4I
>> +	select MFD_SYSCON
>>           ---help---
>>             Support for Allwinner A10 EMAC ethernet driver.
>>
>> diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
>> index 1fcd556..86c891d 100644
>> --- a/drivers/net/ethernet/allwinner/sun4i-emac.c
>> +++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
>> @@ -18,6 +18,8 @@
>>   #include <linux/gpio.h>
>>   #include <linux/interrupt.h>
>>   #include <linux/irq.h>
>> +#include <linux/mfd/syscon.h>
>> +#include <linux/mfd/syscon/sun4i-sc.h>
>>   #include <linux/mii.h>
>>   #include <linux/module.h>
>>   #include <linux/netdevice.h>
>> @@ -28,6 +30,7 @@
>>   #include <linux/of_platform.h>
>>   #include <linux/platform_device.h>
>>   #include <linux/phy.h>
>> +#include <linux/regmap.h>
>>
>>   #include "sun4i-emac.h"
>>
>> @@ -78,6 +81,7 @@ struct emac_board_info {
>>
>>   	struct phy_device	*phy_dev;
>>   	struct device_node	*phy_node;
>> +	struct regmap		*sc;
>>   	unsigned int		link;
>>   	unsigned int		speed;
>>   	unsigned int		duplex;
>> @@ -862,6 +866,18 @@ static int emac_probe(struct platform_device *pdev)
>>   		goto out;
>>   	}
>>
>> +	/* Map SRAM_A3_A4 to EMAC */
>> +	db->sc = syscon_regmap_lookup_by_compatible(
>> +						"allwinner,sun4i-a10-syscon");
>> +	if (IS_ERR(db->sc)) {
>> +		dev_err(&pdev->dev, "failed to find syscon regmap\n");
>> +		ret = PTR_ERR(db->sc);
>> +		goto out;
>> +	}
>> +
>> +	regmap_update_bits(db->sc, SUN4I_SC1, SUN4I_SC1_SRAM_A3_A4_MAP_MASK,
>> +						SUN4I_SC1_SRAM_A3_A4_MAP_EMAC);
>> +
>
> I don't think that using a syscon is the right solution here.
>
> All this SRAM mapping thing is mutually exclusive, and will possibly
> impact other drivers as well.

Each single SRAM area can only be mapped to a single peripheral, so as 
long as the driver only changes bits related to his own area nothing can 
go wrong I believe.

SRAM_C2 looks like it can be mapped do different devices (AE, CE, ACE), 
but as far as I understand this, they are all related to the ACE device, 
sharing a common register space, and would have to be handled by a 
single driver anyway (if that will ever happen without docs) 
https://linux-sunxi.org/ACE_Register_guide

> I think this is a more a case for a small driver in drivers/soc that
> would take care of this, and make sure that client drivers don't step
> on each other's toe.

I'm not convinced this is necessary, but what would this driver do 
different than a basic regmap? Check if the area is already mapped by 
any driver and deny mapping it again by a different driver? Which 
different driver, each area is only interesting for a single 
device/driver? Except maybe mapping it to CPU as general purpose sram, 
but that would need some direct agreement with the driver to steal its 
memory anyway.

Jens
