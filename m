From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atl1c:Atheros L1C Gigabit Ethernet driver
Date: Sun, 08 Feb 2009 23:18:14 -0800 (PST)
Message-ID: <20090208.231814.18575012.davem@davemloft.net>
References: <1234161271580-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jie.yang@atheros.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58489
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753826AbZBIHSV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 02:18:21 -0500
In-Reply-To: <1234161271580-git-send-email-jie.yang@atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <jie.yang@atheros.com>
Date: Mon, 9 Feb 2009 14:34:31 +0800


> +#define PCI_REG_COMMAND	 0x04    /* PCI Command Register */
> +#define CMD_IO_SPACE	 0x0001
> +#define CMD_MEMORY_SPACE 0x0002
> +#define CMD_BUS_MASTER   0x0004

Use definitions in linux/pci_regs.h, instead of inventing
your own.

> +
> +#define BAR_0   0
> +#define BAR_1   1
> +#define BAR_5   5

Likewise.

> +/* Error Codes */
> +#define AT_ERR_EEPROM      1
> +#define AT_ERR_PHY         2
> +#define AT_ERR_CONFIG      3
> +#define AT_ERR_PARAM       4
> +#define AT_ERR_MAC_TYPE    5
> +#define AT_ERR_PHY_TYPE    6
> +#define AT_ERR_PHY_SPEED   7
> +#define AT_ERR_PHY_RES     8
> +#define AT_ERR_TIMEOUT     9

Please do not invent your own error code system, use existing ones.
Otherwise your code is hard for others to understand and review.

> +#define AT_RX_BUF_SIZE		1536

How is this number derived?  Is it ETH_DATA_LEN or ETH_FRAME_LEN
plus some constant or other importnat value?  If so, please
define it as a sum of those descriptive macro values.

> +#define AT_REGS_LEN	75

This definition is really confusing.  It's not the length
of the chip register area, it's the number of registers
the chip has.

Every use in the driver multiplies this value by
"sizeof(u32)".  Just define this macro to "75 * sizeof(u32)"
and update the macro users accordingly.

> +struct atl1c_tpd_desc {
> +	__le16	buffer_len; /* include 4-byte CRC */
> +	u16	vlan_tag;
> +	__le32	word1;
> +	__le64	buffer_addr;
> +};

Is the vlan_tag stored in little or big endian?  I find it
unlikely that it is stored in cpu-endianness, so an
endian typed vlan_tag should be specified here.

The AT_TAG_TO_VLAN() macro will need to be updated to match
whatever endianness this value is stored in.

> +struct atl1c_recv_ret_status {
> +	__le32  word0;
> +	u32	rss_hash;
> +	u16	vlan_tag;
> +	u16	flag;
> +	__le32	word3;
> +};

Well, what endianness are these values stored in?  Cpu endianness?
If not, endian specific types and accessors need to be used here.

> +	u16 autoneg_advertised;
> +#define ADVERTISE_10_HALF               0x0001
> +#define ADVERTISE_10_FULL               0x0002
> +#define ADVERTISE_100_HALF              0x0004
> +#define ADVERTISE_100_FULL              0x0008
> +#define ADVERTISE_1000_HALF             0x0010 /* Not used, just FYI */
> +#define ADVERTISE_1000_FULL             0x0020
> +#define ADVERTISE_DEFAULT (ADVERTISE_10_HALF  |\
> +			   ADVERTISE_10_FULL  |\
> +			   ADVERTISE_100_HALF |\
> +			   ADVERTISE_100_FULL |\
> +			   ADVERTISE_1000_FULL)

Having these self-defined local macros with similar names
as the defines found in linux/mii.h (which also form a bitmask
that fits in 16-bits) is confusing.

Please use the linux/mii.h values here.

> +	if (control & EEPROM_CTRL_RW) {
> +		AT_READ_REG(hw, REG_EEPROM_CTRL, &data);
> +		AT_READ_REG(hw, REG_EEPROM_DATA_LO, p_value);
> +		data = data & 0xFFFF;
> +		*p_value = swab32((data << 16) | (*p_value >> 16));
> +		ret = true;
> +	}

Please make sure the endianness works out properly here,
even on big-endian systems.

I think it's right, but it's worth double checking.

> +#if 0
> +int atl1c_phy_commit(struct atl1c_hw *hw)

Please just elide this code from the driver, you can add
it in when a use is created.

> +static void atl1c_phy_magic_data(struct atl1c_hw *hw)
> +{
> +	u16 data;
> +
> +	atl1c_write_phy_reg(hw, MII_DBG_ADDR, 0x12);
> +	atl1c_write_phy_reg(hw, MII_DBG_DATA, 0x4C04);
> +
> +	atl1c_write_phy_reg(hw, MII_DBG_ADDR, 0x05);
> +	atl1c_write_phy_reg(hw, MII_DBG_DATA, 0x2C46);
> +
> +	atl1c_write_phy_reg(hw, MII_DBG_ADDR, 0x36);
> +	atl1c_write_phy_reg(hw, MII_DBG_DATA, 0xE12C);
> +
> +	atl1c_write_phy_reg(hw, MII_DBG_ADDR, 0x04);
> +	atl1c_write_phy_reg(hw, MII_DBG_DATA, 0x88BB);
> +
> +	atl1c_write_phy_reg(hw, MII_DBG_ADDR, 0x00);
> +	atl1c_write_phy_reg(hw, MII_DBG_DATA, 0x02EF);

No magic constants please, document these MII PHY registers and what
bits and values you are setting into them, using appropriate register
offset and value macros.

I am pretty sure you can find out what these register writes are
doing, and thus be able to document them properly :-)

> +/* register definition */
> +#define REG_PM_CTRLSTAT             	0x44
> +#define PM_CTRLSTAT_PME_EN		0x100

All of these PCI config space registers should either use
the definitions in linux/pci_reg.h or the appropriate
extended PCI config space register probing mechanisms such
as pci_find_capability().

pci_find_capability() is the correct way to find the PM,
VPD, PCI-E etc. extended register areas.


> +			netif_carrier_on(netdev);
> +			netif_wake_queue(netdev);
 ...
> +			netif_carrier_off(netdev);
> +			netif_stop_queue(netdev);

Doing a carrier state change as well as a queue wake/stop is
redundant.  Setting the carrier off is enough to stop packet
flow on transmit to the device.  And likewise setting the
carrier on is enough to (re-)start packet flow for transmit.

> +static int atl1c_clean(struct napi_struct *napi, int budget)
> +{
> +	struct atl1c_adapter *adapter =
> +			container_of(napi, struct atl1c_adapter, napi);
> +	int work_done = 0;
> +	int i;
> +
> +	/* Keep link state information with original netdev */
> +	if (!netif_carrier_ok(adapter->netdev))
> +		goto quit_polling;
> +
> +	for (i = 0; i < adapter->num_rx_queues; i++)
> +		atl1c_clean_rx_irq(adapter, i, &work_done, budget);

This is going to perform very poorly.  You should instantiate
a seperate NAPI instance for each RX queue, and only schedule NAPI
for those specific RX queues which indicate RX packets are available
at interrupt time.

Otherwise having seperate RX queues is pointless, as all of the SMP
locking gains from RX seperation will not be realized.

If it is not possible to implement things this way, either because
it is very difficult or impossible due to the interrupt architecture
of the chip, then please just use one RX queue at this time.  You
can add the RX multi-queue support back later once it is implemented
properly.

> +	netdev->open = &atl1c_open;
> +	netdev->stop = &atl1c_close;
> +	netdev->hard_start_xmit = &atl1c_xmit_frame;
> +	netdev->get_stats = &atl1c_get_stats;
> +	netdev->set_multicast_list = &atl1c_set_multi;
> +	netdev->set_mac_address = &atl1c_set_mac_addr;
> +	netdev->change_mtu = &atl1c_change_mtu;
> +	netdev->do_ioctl = &atl1c_ioctl;
> +	netdev->tx_timeout = &atl1c_tx_timeout;

Please use net_device_ops, the function pointer initialization method
you are using here is deprecated and will be eliminated at some point
in the future.

> +	/* enable device (incl. PCI PM wakeup and hotplug setup) */
> +	err = pci_enable_device(pdev);
> +	if (err) {
> +		dev_err(&pdev->dev, "cannot enable PCI device\n");
> +		return err;
> +	}

Please use pci_enable_device_mem() if only MEM space register
accesses will be used.


> +	/* get user settings */
> +	atl1c_check_options(adapter);

Please do not use module parameters for network device
configuration knobs.

Many of the controls you have specified are supported by
ethtool, and that is the consistent interface we have for
users to make these setting changes.
