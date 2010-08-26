From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Thu, 26 Aug 2010 07:44:30 -0700
Message-ID: <1282833870.1875.52.camel@Joe-Laptop>
References: <4C763A67.5040107@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
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
Received: from mail.perches.com ([173.55.12.10]:1347 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751341Ab0HZOod (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Aug 2010 10:44:33 -0400
In-Reply-To: <4C763A67.5040107@dsn.okisemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-08-26 at 18:56 +0900, Masayuki Ohtake wrote:
> Gigabit Ethernet driver of Topcliff PCH
> +++ b/drivers/net/pch_gbe/pch_gbe.h

Just a few style comments

> +#undef FALSE
> +#define FALSE	0
> +#undef TRUE
> +#define TRUE	1

Perhaps better to use the kernel true/false.

> +#ifdef DEBUG
> +#define PCH_GBE_DEBUG(fmt, args...)\
> +	printk(KERN_DEBUG KBUILD_MODNAME ": " fmt, ##args)
> +#else
> +#define PCH_GBE_DEBUG(fmt, args...)	do { } while (0)
> +#endif

Better to use

#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

and

	pr_debug(fmt, ...);

[]

> +struct pch_gbe_functions {
> +	void (*get_bus_info) (struct pch_gbe_hw *);
> +	s32(*init_hw) (struct pch_gbe_hw *);
> +	s32(*read_phy_reg) (struct pch_gbe_hw *, u32, u16 *);

Trivial: Inconsistent spacing (a few times)
Perhaps:
	s32 (*read_phy_reg) etc...

> +	s32(*write_phy_reg) (struct pch_gbe_hw *, u32, u16);
> +	void (*reset_phy) (struct pch_gbe_hw *);
[]
> +	s32(*read_mac_addr) (struct pch_gbe_hw *);

> +++ b/drivers/net/pch_gbe/pch_gbe_api.c
> @@ -0,0 +1,247 @@
[]

Convert all the
	printk(KERN_<level> KBUILD_MODNAME ": " etc
to
	pr_<level>(etc

> +#include "pch_gbe.h"
> +#include "pch_gbe_phy.h"
[]
> +static s32 pch_gbe_plat_init_hw(struct pch_gbe_hw *hw)
> +{
> +	s32 ret_val;
> +
> +	ret_val = pch_gbe_phy_get_id(hw);
> +	if (ret_val) {
> +		printk(KERN_ERR KBUILD_MODNAME ": "
> +			"pch_gbe_phy_get_id error\n");

		pr_err("pch_gbe_phy_get_id error\n");

> +inline s32 pch_gbe_hal_setup_init_funcs(struct pch_gbe_hw *hw)
> +{
> +	if (hw->reg) {
> +		pch_gbe_plat_init_function_pointers(hw);
> +		return 0;
> +	}
> +	printk(KERN_ERR KBUILD_MODNAME ": " "ERROR: Registers not mapped\n");

	pr_err("ERROR: Registers not mapped\n");
	etc...

> +	return -ENOSYS;
> +}

These are more commonly written as:

	if (!fn_ptr) {
		[ report_error_condition ]
		return -ERRNO;
	}

	rtn = fn_ptr(foo);
	if (rtn is err) {
		[ report_error_condition ]
		return -ERRNO2;
	}

	return 0;

For more complicated styles where some unwinding
is necessary

	if (!fn_ptr) {
		[ report_error_condition ]
		err = -ERRNO;
		goto out;
	}

	windup

	rtn = fn_ptr(foo);
	if (rtn is err) {
		[ report_error_condition ]
		err = ERRNO2
		goto out2;
	}

	return 0;

outn:
	..
out2:
	unwind;
out:
	return err;

> +
> +/**
> + * pch_gbe_hal_get_bus_info - Obtain bus information for adapter
> + * @hw:	Pointer to the HW structure
> + */
> +inline void pch_gbe_hal_get_bus_info(struct pch_gbe_hw *hw)
> +{
> +	if (hw->func.get_bus_info)
> +		hw->func.get_bus_info(hw);
> +	else
> +		printk(KERN_ERR KBUILD_MODNAME ": " "Error: configuration\n");

		pr_err("ERROR: configuration\n");
		etc...

> +++ b/drivers/net/pch_gbe/pch_gbe_ethtool.c

[]

Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
before any include

> +#include <linux/pci.h>
> +#include <linux/ethtool.h>
[]
> +static int pch_gbe_get_settings(struct net_device *netdev,
> +				 struct ethtool_cmd *ecmd)
> +{
> +	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
> +	int ret;
> +
> +	PCH_GBE_DEBUG("ethtool: %s\n", __func__);

If you really want to track entering functions,
it might be better to use something like:

#define FUNC_ENTER() pr_devel("ethtool: %s enter\n", __func__)
#define FUNC_EXIT() pr_devel("ethtool: %s exit\n",  __func__)

Unlike pr_debug, pr_devel does not remain active in
code when DEBUG is not #defined.  Look up dynamic_debug.

> +	PCH_GBE_DEBUG("hw->mac.addr : 0x%02x %02x %02x %02x %02x %02x\n",
> +		hw->mac.addr[0], hw->mac.addr[1], hw->mac.addr[2],
> +		hw->mac.addr[3], hw->mac.addr[4], hw->mac.addr[5]);

There's a vsprintf pointer extension "%pM" used for mac addresses

	pr_debug("hw->mac.addr: %pM\n, hw->mac.addr);

etc.

