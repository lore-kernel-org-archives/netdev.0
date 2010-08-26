From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Thu, 26 Aug 2010 12:28:03 +0200
Message-ID: <20100826102803.GA5301@merkur.ravnborg.org>
References: <4C763A67.5040107@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4C763A67.5040107@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Masayuki Ohtake.

Just a few comments after a very quick scan over some of the files.

	Sam

On Thu, Aug 26, 2010 at 06:56:55PM +0900, Masayuki Ohtake wrote:
> ---

"---" is used to truncate your changelog, random comments goes below "---".
So there would be no changelog entry in this case.


> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 2decc59..fcc6b7b 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2004,6 +2004,11 @@ menuconfig NETDEV_1000
>  	  If you say N, all options in this submenu will be skipped and disabled.
>  
>  if NETDEV_1000
> +config PCH_GBE
> +        tristate "PCH Gigabit Ethernet"
> +        ---help---
> +          This is an gigabit ethernet driver for PCH.
> +          resources.

Naive readers do not know what PCH is.
Google says it is: Potlatch Corporation

Please elaborate much more.

For new stuff we use "help" - not "---help---".
But you could not know as this is not documented anywhere.

> diff --git a/drivers/net/pch_gbe/Makefile b/drivers/net/pch_gbe/Makefile
> new file mode 100644
> index 0000000..008fa22
> --- /dev/null
> +++ b/drivers/net/pch_gbe/Makefile
> @@ -0,0 +1,6 @@
> +ifeq ($(CONFIG_PCH_GBE_DEBUG_CORE),y)
> +EXTRA_CFLAGS += -DDEBUG
> +endif
Use:
ccflags-$(CONFIG_PCH_GBE_DEBUG_CORE) := -DDEBUG

Btw. where do CONFIG_PCH_GBE_DEBUG_CORE come from. It was not in the Kconfig
file you included.

> +
> +obj-$(CONFIG_PCH_GBE) += pch_gbe.o
> +pch_gbe-objs := pch_gbe_phy.o pch_gbe_ethtool.o pch_gbe_param.o pch_gbe_api.o pch_gbe_main.o

Please do not use -objs.
Do like this:

obj-$(CONFIG_PCH_GBE) += pch_gbe.o
pch_gbe-y :=  pch_gbe_phy.o pch_gbe_ethtool.o pch_gbe_param.o
pch_gbe-y += pch_gbe_api.o pch_gbe_main.o


> diff --git a/drivers/net/pch_gbe/Module.symvers b/drivers/net/pch_gbe/Module.symvers
> new file mode 100644
> index 0000000..e69de29
This file should be dropped.

> diff --git a/drivers/net/pch_gbe/pch_gbe.h b/drivers/net/pch_gbe/pch_gbe.h
> new file mode 100644
> index 0000000..a2b92dd
> --- /dev/null
> +++ b/drivers/net/pch_gbe/pch_gbe.h
> @@ -0,0 +1,425 @@
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
> +#ifndef _PCH_GBE_H_
> +#define _PCH_GBE_H_
> +
> +#include <linux/netdevice.h>
> +#include <linux/mii.h>
> +
> +#undef FALSE
> +#define FALSE	0
> +#undef TRUE
> +#define TRUE	1
Use true/false - no reason for these.

> +
> +#ifdef DEBUG
> +#define PCH_GBE_DEBUG(fmt, args...)\
> +	printk(KERN_DEBUG KBUILD_MODNAME ": " fmt, ##args)
> +#else
> +#define PCH_GBE_DEBUG(fmt, args...)	do { } while (0)
> +#endif

Use standard logging methods. 
pr_* and similar.


> +
> +/* Device Driver infomation */
> +#define DRV_STRING      "PCH Network Driver"
> +#define DRV_EXT         "-NAPI"
> +#define DRV_VERSION     "0.95"DRV_EXT
> +#define DRV_DESCRIPTION \
> +	"OKI semiconductor sample Linux driver for PCH Gigabit ethernet"
> +#define DRV_COPYRIGHT   "Copyright(c) 2010 OKI semiconductor"
> +#define FIRM_VERSION    "N/A"
> +/* TX/RX descriptor defines */
> +#define PCH_GBE_MAX_TXD                     4096
> +#define PCH_GBE_MIN_TXD                        8
> +#define PCH_GBE_MAX_RXD                     4096
> +#define PCH_GBE_MIN_RXD                        8
> +/* Number of Transmit and Receive Descriptors must be a multiple of 8 */
> +#define PCH_GBE_TX_DESC_MULTIPLE               8
> +#define PCH_GBE_RX_DESC_MULTIPLE               8

> +/* only works for sizes that are powers of 2 */
> +#define PCH_GBE_ROUNDUP(i, size) ((i) = (((i) + (size) - 1) & ~((size) - 1)))
We have this already. Search include/linux/*

> + * @read_mac_addr:	for pch_gbe_hal_read_mac_addr
> + */
> +struct pch_gbe_functions {
> +	void (*get_bus_info) (struct pch_gbe_hw *);
> +	s32(*init_hw) (struct pch_gbe_hw *);
> +	s32(*read_phy_reg) (struct pch_gbe_hw *, u32, u16 *);
> +	s32(*write_phy_reg) (struct pch_gbe_hw *, u32, u16);
missign space after s32

> +	void (*reset_phy) (struct pch_gbe_hw *);
> +	void (*sw_reset_phy) (struct pch_gbe_hw *);
> +	void (*power_up_phy) (struct pch_gbe_hw *hw);
> +	void (*power_down_phy) (struct pch_gbe_hw *hw);
> +	s32(*read_mac_addr) (struct pch_gbe_hw *);
> +};
> +



> +	printk(KERN_ERR KBUILD_MODNAME ": " "ERROR: Registers not mapped\n");

In several places...
Use standard logging methods to do this simpler.


> +++ b/drivers/net/pch_gbe/pch_gbe_api.h
> @@ -0,0 +1,31 @@
> +/*

Why is two .h files needed for a single driver?
As this file live in drivers/net/pch_gbe/ this is purely internal stuff.

> +#include "pch_gbe_regs.h"
> +#include "pch_gbe.h"
> +#include "pch_gbe_api.h"

As per comment above I realise that this single driver has three .h files.
Maybe their size warrants this?
