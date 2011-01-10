From: Florian Fainelli <ffainelli@freebox.fr>
Subject: Re: [net-next 07/12] e1000: Add support for the CE4100 reference platform
Date: Mon, 10 Jan 2011 13:44:39 +0100
Message-ID: <201101101344.40001.ffainelli@freebox.fr>
References: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com> <1294360199-9860-8-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Dirk Brandewie <dirk.j.brandewie@intel.com>,
	netdev@vger.kernel.org, gosp@redhat.com, bphilips@novell.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:33612 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753816Ab1AJMnR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jan 2011 07:43:17 -0500
In-Reply-To: <1294360199-9860-8-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Friday 07 January 2011 01:29:54 jeffrey.t.kirsher@intel.com wrote:
> From: Dirk Brandewie <dirk.j.brandewie@intel.com>
> 
> This patch adds support for the gigabit phys present on the CE4100
> reference platforms.
> 
> Signed-off-by:  Dirk Brandewie <dirk.j.brandewie@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/e1000/e1000_hw.c    |  328
> +++++++++++++++++++++++++++++++-------- drivers/net/e1000/e1000_hw.h    | 
>  59 +++++++-
>  drivers/net/e1000/e1000_main.c  |   35 ++++
>  drivers/net/e1000/e1000_osdep.h |   19 ++-
>  4 files changed, 365 insertions(+), 76 deletions(-)
> 
[snip]
> @@ -2840,7 +2985,7 @@ static s32 e1000_write_phy_reg_ex(struct e1000_hw
> *hw, u32 reg_addr, {
>  	u32 i;
>  	u32 mdic = 0;
> -	const u32 phy_addr = 1;
> +	const u32 phy_addr = (hw->mac_type == e1000_ce4100) ? hw->phy_addr : 1;

Why not simply use hw->phy_addr and set it to 1 when mac_type is not e1000_ce4100?
hw->phy_addr for CE4100 is auto detected later in this patch, so this should be safe.

> 
>  	e_dbg("e1000_write_phy_reg_ex");
> 
[snip]
> @@ -1135,6 +1153,20 @@ static int __devinit e1000_probe(struct pci_dev
> *pdev, adapter->wol = adapter->eeprom_wol;
>  	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
> 
> +	/* Auto detect PHY address */
> +	if (hw->mac_type == e1000_ce4100) {
> +		for (i = 0; i < 32; i++) {
                                      ^PHY_MAX_ADDR (in linux/phy.h)
> +			hw->phy_addr = i;
> +			e1000_read_phy_reg(hw, PHY_ID2, &tmp);
> +			if (tmp == 0 || tmp == 0xFF) {
> +				if (i == 31)
> +					goto err_eeprom;
> +				continue;
> +			} else
> +				break;
> +		}
> +	}

Do not  you want to also autodetect the PHY address for all e1000
variants?

> +
>  	/* reset the hardware with the new settings */
>  	e1000_reset(adapter);
> 
> @@ -1171,6 +1203,8 @@ err_eeprom:
>  	kfree(adapter->rx_ring);
>  err_dma:
>  err_sw_init:
> +err_mdio_ioremap:
> +	iounmap(ce4100_gbe_mdio_base_virt);
>  	iounmap(hw->hw_addr);
>  err_ioremap:
>  	free_netdev(netdev);
> @@ -1409,6 +1443,7 @@ static bool e1000_check_64k_bound(struct
> e1000_adapter *adapter, void *start, /* First rev 82545 and 82546 need to
> not allow any memory
>  	 * write location to cross 64k boundary due to errata 23 */
>  	if (hw->mac_type == e1000_82545 ||
> +	    hw->mac_type == e1000_ce4100 ||
>  	    hw->mac_type == e1000_82546) {
>  		return ((begin ^ (end - 1)) >> 16) != 0 ? false : true;
>  	}
> diff --git a/drivers/net/e1000/e1000_osdep.h
> b/drivers/net/e1000/e1000_osdep.h index edd1c75..55c1711 100644
> --- a/drivers/net/e1000/e1000_osdep.h
> +++ b/drivers/net/e1000/e1000_osdep.h
> @@ -34,12 +34,21 @@
>  #ifndef _E1000_OSDEP_H_
>  #define _E1000_OSDEP_H_
> 
> -#include <linux/types.h>
> -#include <linux/pci.h>
> -#include <linux/delay.h>
>  #include <asm/io.h>
> -#include <linux/interrupt.h>
> -#include <linux/sched.h>
> +
> +#define CONFIG_RAM_BASE         0x60000
> +#define GBE_CONFIG_OFFSET       0x0
> +
> +#define GBE_CONFIG_RAM_BASE \
> +	((unsigned int)(CONFIG_RAM_BASE + GBE_CONFIG_OFFSET))
> +
> +#define GBE_CONFIG_BASE_VIRT    phys_to_virt(GBE_CONFIG_RAM_BASE)
> +
> +#define GBE_CONFIG_FLASH_WRITE(base, offset, count, data) \
> +	(iowrite16_rep(base + offset, data, count))
> +
> +#define GBE_CONFIG_FLASH_READ(base, offset, count, data) \
> +	(ioread16_rep(base + (offset << 1), data, count))

In my opinion, this is unsafe, especially because not everyone places a valid
e1000 "fake" EEPROM at 0x60000. Also, this is done by the bootloader, so there
is no guarantee chainloading, kexec/kdump or anything overwrites the zone.
Rather I'd go with doing a request_firmware() of the eeprom or, a platform-
specific callback to access it.

Retrieving such board specific informations is really integrator specific.
--
Florian
