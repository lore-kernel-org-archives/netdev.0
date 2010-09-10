From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v3] Gigabit Ethernet driver of Topcliff PCH
Date: Thu, 09 Sep 2010 23:32:07 -0700
Message-ID: <1284100327.24986.324.camel@Joe-Laptop>
References: <4C89C23A.6090707@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	John Linn <john.linn@xilinx.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	Maxime Bizon <mbizon@freebox.fr>,
	Greg Rose <gregory.v.rose@intel.com>,
	ML netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, MeeGo <meego-dev@meego.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jili Slaby <jslaby@suse.cz>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	"Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	Arjan <arjan@linux.intel.com>,
	Toshiharu Okada <okada533@dsn.okisemi.com>,
	Takahiro Shimizu <shimizu394@dsn.okisemi.com>,
	Tomoya Morinaga <morinaga526@dsn.okisemi.com>
To: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C89C23A.6090707@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-09-10 at 14:29 +0900, Masayuki Ohtake wrote:

> diff --git a/drivers/net/pch_gbe/pch_gbe_ethtool.c b/drivers/net/pch_gbe/pch_gbe_ethtool.c
[]
> +static void pch_gbe_get_regs(struct net_device *netdev,
> +				struct ethtool_regs *regs, void *p)
> +{
> +	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
> +	struct pch_gbe_hw *hw = &adapter->hw;
> +	struct pci_dev *pdev = adapter->pdev;
> +	u32 *regs_buff = p;
> +	u16 i, reg, tmp;
> +
> +	regs->version = pdev->revision;
> +	regs->version = 0x1000000 | (regs->version << 16) | pdev->device;
 
Might be simpler as:
	regs->version = 0x1000000 | (__u32)pdev->revision << 16 | pdev->device;

The block below is a bit confusing to me.

> +	memset(p, 0, PCH_GBE_REGS_LEN * (int)sizeof(u32));
 
It seems the memset is unnecessary as it's completely
overwritten below.

> +	for (i = 0; i < PCH_GBE_MAC_REGS_LEN; i++)
> +		regs_buff[i] = ioread32(&hw->reg->INT_ST + i);
> +	/* PHY register */
> +	for (i = PCH_GBE_MAC_REGS_LEN, reg = 0; reg < PCH_GBE_PHY_REGS_LEN;
> +	     i++, reg++) {
> +		pch_gbe_hal_read_phy_reg(&adapter->hw, reg, &tmp);
> +		regs_buff[i] = tmp;
> +	}

I think i'd be simpler to do something like:

	for (i = 0; i < PCH_GBE_MAC_REGS_LEN; i++)
		*regs_buff++ = ioread32(&hw->reg->INT_ST + i);

	/* PHY register */
	for (i = 0; i < PCH_GBE_PHY_REGS_LEN; i++) {
		pch_gbe_hal_read_phy_reg(&adapter->hw, i, &tmp);
		*regs_buff++ = tmp;
	}

[]

+void pch_gbe_mac_mar_set(struct pch_gbe_hw *hw, u8 * addr, u32 index)
> +{
> +	u32 mar_low, mar_high, adrmask;
> +
> +	pr_debug("index : 0x%x\n", index);
> +
> +	/*
> +	 * HW expects these in little endian so we reverse the byte order
> +	 * from network order (big endian) to little endian
> +	 */
> +	mar_high = ((u32) addr[0] | ((u32) addr[1] << 8) |
> +		   ((u32) addr[2] << 16) | ((u32) addr[3] << 24));
> +	mar_low = ((u32) addr[4] | ((u32) addr[5] << 8));
> +	/* Stop the MAC Address of index. */
> +	adrmask = ioread32(&hw->reg->ADDR_MASK);
> +	iowrite32((adrmask | (0x0001 << index)), &hw->reg->ADDR_MASK);
> +	/* wait busy */
> +	while ((ioread32(&hw->reg->ADDR_MASK) & PCH_GBE_BUSY)) {
> +		int tmp = 0;
> +		udelay(20);
> +		tmp++;
> +		if (tmp == 1000) {
> +			pr_err("Address mask bit is not cleared\n");
> +			break;
> +		}
> +	}
 
You need to move the declaration of tmp out of the while.

Do these really need to be busy-waits?

> +	/* Set the MAC address to the MAC address 1A/1B register */
> +	iowrite32(mar_high, &hw->reg->mac_adr[index].high);
> +	iowrite32(mar_low, &hw->reg->mac_adr[index].low);
> +	/* Start the MAC address of index */
> +	iowrite32((adrmask & ~(0x0001 << index)), &hw->reg->ADDR_MASK);
> +	/* wait busy */
> +	while ((ioread32(&hw->reg->ADDR_MASK) & PCH_GBE_BUSY)) {
> +		int tmp = 0;
> +		udelay(20);
> +		tmp++;
> +		if (tmp == 1000) {
> +			pr_err("Address mask bit is not cleared\n");
> +			break;
> +		}
> +	}
> +}

Here too.  There are more of these too I'm not listing.
Perhaps you could review the logic a bit more.
