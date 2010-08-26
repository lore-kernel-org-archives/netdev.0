From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Thu, 26 Aug 2010 08:34:21 -0700
Message-ID: <20100826083421.456b0d1c@nehalam>
References: <4C763A67.5040107@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>,
	Greg Rose <gregory.v.rose@intel.com>,
	Maxime Bizon <mbizon@freebox.fr>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	John Linn <john.linn@xilinx.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	MeeGo <meego-dev@meego.com>, "Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	Toshiharu Okada <okada533@dsn.okisemi.com>,
	Tomoya Morinaga <morinaga526@dsn.okisemi.com>,
	Takahiro Shimizu <shimizu394@dsn.okisemi.com>
To: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56618 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754097Ab0HZPeZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Aug 2010 11:34:25 -0400
In-Reply-To: <4C763A67.5040107@dsn.okisemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Aug 2010 18:56:55 +0900
Masayuki Ohtake <masa-korg@dsn.okisemi.com> wrote:

> ---
> Gigabit Ethernet driver of Topcliff PCH
> 
> Topcliff PCH is the platform controller hub that is going to be used in
> Intel's upcoming general embedded platform. All IO peripherals in
> Topcliff PCH are actually devices sitting on AMBA bus. 
> Topcliff PCH has Gigabit Ethernet I/F. Using this I/F, it is able to 
> access system devices connected to Gigabit Ethernet.
> 
> Signed-off-by: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
> ---

You can initialize your function table at compile time.

> +
> +struct pch_gbe_hw;
> +/**
> + * struct  pch_gbe_functions - HAL APi function pointer
> + * @get_bus_info:	for pch_gbe_hal_get_bus_info
> + * @init_hw:		for pch_gbe_hal_init_hw
> + * @read_phy_reg:	for pch_gbe_hal_read_phy_reg
> + * @write_phy_reg:	for pch_gbe_hal_write_phy_reg
> + * @reset_phy:		for pch_gbe_hal_phy_hw_reset
> + * @sw_reset_phy:	for pch_gbe_hal_phy_sw_reset
> + * @power_up_phy:	for pch_gbe_hal_power_up_phy
> + * @power_down_phy:	for pch_gbe_hal_power_down_phy
> + * @read_mac_addr:	for pch_gbe_hal_read_mac_addr
> + */
> +struct pch_gbe_functions {
> +	void (*get_bus_info) (struct pch_gbe_hw *);
> +	s32(*init_hw) (struct pch_gbe_hw *);
> +	s32(*read_phy_reg) (struct pch_gbe_hw *, u32, u16 *);
> +	s32(*write_phy_reg) (struct pch_gbe_hw *, u32, u16);
> +	void (*reset_phy) (struct pch_gbe_hw *);
> +	void (*sw_reset_phy) (struct pch_gbe_hw *);
> +	void (*power_up_phy) (struct pch_gbe_hw *hw);
> +	void (*power_down_phy) (struct pch_gbe_hw *hw);
> +	s32(*read_mac_addr) (struct pch_gbe_hw *);
> +};

...

> +
> +/*!
> + * @ingroup Gigabit Ether driver Layer
> + * @struct  pch_gbe_hw
> + * @brief   Hardware infomation
> + */
> +struct pch_gbe_hw {
> +	void *back;
> +
> +	struct pch_gbe_regs  __iomem *reg;
> +	spinlock_t miim_lock;
> +
> +	struct pch_gbe_functions func;
Should be:
        const struct pch_gbe_functions *func;

> +	struct pch_gbe_mac_info mac;
> +	struct pch_gbe_phy_info phy;
> +	struct pch_gbe_bus_info bus;
> +
> +	u16 vendor_id;
> +	u16 device_id;
> +	u16 subsystem_vendor_id;
> +	u16 subsystem_device_id;
> +	u8 revision_id;
> +};
...

> --- /dev/null
> +++ b/drivers/net/pch_gbe/pch_gbe_api.c
> @@ -0,0 +1,247 @@
> +/*
> + * Copyright (C) 2010 OKI SEMICONDUCTOR Co., LTD.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; version 2 of the License.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.
> + */
> +
> +#include "pch_gbe.h"
> +#include "pch_gbe_phy.h"
> +
> +/* bus type values */
> +#define pch_gbe_bus_type_unknown	0
> +#define pch_gbe_bus_type_pci		1
> +#define pch_gbe_bus_type_pcix		2
> +#define pch_gbe_bus_type_pci_express	3
> +#define pch_gbe_bus_type_reserved	4
> +
> +/* bus speed values */
> +#define pch_gbe_bus_speed_unknown	0
> +#define pch_gbe_bus_speed_33		1
> +#define pch_gbe_bus_speed_66		2
> +#define pch_gbe_bus_speed_100		3
> +#define pch_gbe_bus_speed_120		4
> +#define pch_gbe_bus_speed_133		5
> +#define pch_gbe_bus_speed_2500		6
> +#define pch_gbe_bus_speed_reserved	7
> +
> +/* bus width values */
> +#define pch_gbe_bus_width_unknown	0
> +#define pch_gbe_bus_width_pcie_x1	1
> +#define pch_gbe_bus_width_pcie_x2	2
> +#define pch_gbe_bus_width_pcie_x4	4
> +#define pch_gbe_bus_width_32		5
> +#define pch_gbe_bus_width_64		6
> +#define pch_gbe_bus_width_reserved	7
> +
> +/**
> + * pch_gbe_plat_get_bus_info - Obtain bus information for adapter
> + * @hw:	Pointer to the HW structure
> + */
> +static void pch_gbe_plat_get_bus_info(struct pch_gbe_hw *hw)
> +{
> +	hw->bus.type  = pch_gbe_bus_type_pci_express;
> +	hw->bus.speed = pch_gbe_bus_speed_2500;
> +	hw->bus.width = pch_gbe_bus_width_pcie_x1;
> +}
> +
> +/**
> + * pch_gbe_plat_init_hw - Initialize hardware
> + * @hw:	Pointer to the HW structure
> + * Returns
> + *	0:		Successfully
> + *	Negative value:	Failed-EBUSY
> + */
> +static s32 pch_gbe_plat_init_hw(struct pch_gbe_hw *hw)
> +{
> +	s32 ret_val;
> +
> +	ret_val = pch_gbe_phy_get_id(hw);
> +	if (ret_val) {
> +		printk(KERN_ERR KBUILD_MODNAME ": "
> +			"pch_gbe_phy_get_id error\n");
> +		return ret_val;
> +	}
> +	pch_gbe_phy_init_setting(hw);
> +	/* Setup Mac interface option RGMII */
> +#ifdef PCH_GBE_MAC_IFOP_RGMII
> +	pch_gbe_phy_set_rgmii(hw);
> +#endif
> +	return ret_val;
> +}
> +

static const struct pch_gbe_functions pch_gbe_ops = {
	.get_bus_info             = pch_gbe_plat_get_bus_info,
	.init_hw                  = pch_gbe_plat_init_hw,
	.read_phy_reg             = pch_gbe_phy_read_reg_miic,
	.write_phy_reg            = pch_gbe_phy_write_reg_miic,
	.reset_phy                = pch_gbe_phy_hw_reset,
	.sw_reset_phy             = pch_gbe_phy_sw_reset,
	.power_up_phy             = pch_gbe_phy_power_up,
	.power_down_phy           = pch_gbe_phy_power_down,
	.read_mac_addr            = pch_gbe_mac_read_mac_addr,
}; 

> +/**
> + * pch_gbe_plat_init_function_pointers - Init func ptrs
> + * @hw:	Pointer to the HW structure
> + */
> +void pch_gbe_plat_init_function_pointers(struct pch_gbe_hw *hw)
> +{
> +	struct pch_gbe_phy_info *phy = &hw->phy;
> +	struct pch_gbe_functions *func = &hw->func;

	const struct pch_gbe_functions *func = &hw->func;

> +
> +	/* Set PHY parameter */
> +	phy->reset_delay_us     = PCH_GBE_PHY_RESET_DELAY_US;

	func = &pch_gbe_ops;

	(Don't init at run time)
> +}
