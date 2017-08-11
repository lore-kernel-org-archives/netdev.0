From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] Add LAN743X driver
Date: Sat, 12 Aug 2017 00:31:59 +0200
Message-ID: <20170811223159.GB4671@lunn.ch>
References: <90A7E81AE28BAE4CBDDB3B35F187D264406F603F@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        UNGLinuxDriver@microchip.com
To: Bryan.Whitehead@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34050 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753581AbdHKWcE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Aug 2017 18:32:04 -0400
Content-Disposition: inline
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264406F603F@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 11, 2017 at 07:47:57PM +0000, Bryan.Whitehead@microchip.com wrote:
> From: Bryan Whitehead <Bryan.Whitehead@microchip.com>
> 
> Add Microchip LAN743X Driver files
> LAN743X is a PCIe Gigabit ethernet adapter
> 
> Signed-off-by: Bryan Whitehead <Bryan.Whitehead@microchip.com>
> ---
>  drivers/net/ethernet/microchip/lan743x.c | 6842 ++++++++++++++++++++++++++++++
>  drivers/net/ethernet/microchip/lan743x.h | 1417 +++++++
>  2 files changed, 8259 insertions(+)
>  create mode 100644 drivers/net/ethernet/microchip/lan743x.c
>  create mode 100644 drivers/net/ethernet/microchip/lan743x.h
> 
> diff --git a/drivers/net/ethernet/microchip/lan743x.c b/drivers/net/ethernet/microchip/lan743x.c
> new file mode 100644
> index 0000000..44d04ac
> --- /dev/null
> +++ b/drivers/net/ethernet/microchip/lan743x.c
> @@ -0,0 +1,6842 @@
> +/*
> + * Copyright (C) 2017 Microchip Technology
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * as published by the Free Software Foundation; either version 2
> + * of the License, or (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, see <http://www.gnu.org/licenses/>.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/pci.h>
> +#include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
> +#include <linux/crc32.h>
> +#include <linux/microchipphy.h>
> +#include <linux/net_tstamp.h>
> +#include <linux/phy.h>
> +#include "lan743x.h"
> +
> +#define DRIVER_AUTHOR   "Bryan Whitehead <Bryan.Whitehead@microchip.com>"
> +#define DRIVER_DESC "LAN743x PCIe Gigabit Ethernet Driver"
> +#define DRIVER_NAME "lan743x"
> +#define DRIVER_VERSION  "0.2.0.0"

Hi Bryan

Best if you don't use a VERSION string. It is pretty meaningless.

> +
> +/* use ethtool to change the message enable for any given adapter */
> +static int msg_enable =	NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK |
> +			NETIF_MSG_IFUP | NETIF_MSG_IFDOWN | NETIF_MSG_TX_QUEUED;
> +module_param(msg_enable, int, 0000);
> +MODULE_PARM_DESC(msg_enable, "Override default message enable");

No module parameters please.

> +static int lan743x_pci_init(struct lan743x_adapter *adapter,
> +			    struct pci_dev *pdev)
> +{
> +	int ret = -ENODEV;
> +	int bars = 0;
> +	struct lan743x_pci *pci = &adapter->pci;
> +
> +	NETIF_ASSERT(adapter, probe, adapter->netdev, pdev);
> +	memset(pci, 0, sizeof(struct lan743x_pci));

You seem to like memset. But is it actually needed? Adapter is
allocated via alloc_etherdev() so is guaranteed to already be zeroed.
And then you memset all of adaptor. And then you memset this memory
again....

> +	pci->pdev = pdev;
> +
> +	ret = pci_enable_device_mem(pdev);
> +	if (ret) {
> +		NETIF_WARNING(adapter, probe, adapter->netdev,
> +			      "failed pci_enable_device_mem, ret = %d", ret);
> +		goto clean_up;
> +	}
> +	pci->init_flags |= INIT_FLAG_PCI_DEVICE_ENABLED;
> +
> +	if (pdev->vendor != PCI_VENDOR_ID_SMSC) {

How would that happen? Do you think the PCI core will call your probe
for any random PCI device? Or just those you list in
lan743x_pcidev_tbl.

> +		NETIF_ERROR(adapter, probe, adapter->netdev,
> +			    "Unsupported Vendor ID, 0x%04X,", pdev->vendor);
> +		ret = -ENODEV;
> +		goto clean_up;
> +	}
> +
> +	if (pdev->device != PCI_DEVICE_ID_SMSC_LAN7430) {

???

> +		NETIF_ERROR(adapter, probe, adapter->netdev,
> +			    "Unsupported Device ID, 0x%04X", pdev->device);
> +		ret = -ENODEV;
> +		goto clean_up;
> +	}
> +
> +	NETIF_INFO(adapter, probe, adapter->netdev,
> +		   "PCI: Vendor ID = 0x%04X, Device ID = 0x%04X",
> +		   pdev->vendor, pdev->device);

I doubt this wrapper around netif_info() is going to be accepted.  I
also think you need to kill about 90% of your info and err messages.

> +/* CSR */
> +static int lan743x_csr_init(struct lan743x_adapter *adapter)
> +{
> +	struct lan743x_csr *csr = &adapter->csr;
> +	int result = -ENOMEM;

I don't think this initialization is required.

> +	int supported = 0;
> +
> +	NETIF_ASSERT(adapter, probe, adapter->netdev, csr);
> +	memset(csr, 0, sizeof(struct lan743x_csr));
> +
> +	csr->csr_address = lan743x_pci_get_bar_address(adapter, 0);
> +	if (!csr->csr_address) {
> +		NETIF_ERROR(adapter, probe, adapter->netdev,
> +			    "failed to get csr_address");
> +		result = -ENOMEM;
> +		goto clean_up;
> +	}
> +
> +	csr->id_rev = lan743x_csr_read(adapter, ID_REV);
> +	csr->fpga_rev = lan743x_csr_read(adapter, FPGA_REV);
> +
> +	NETIF_INFO(adapter, probe, adapter->netdev,
> +		   "ID_REV = 0x%08X, FPGA_REV = %d.%d",
> +		   csr->id_rev,	(csr->fpga_rev) & 0x000000FF,
> +		   ((csr->fpga_rev) >> 8) & 0x000000FF);
> +
> +	if ((csr->id_rev & 0xFFFF0000) == 0x74300000)
> +		supported = 1;
> +
> +	if (!supported) {

Using the supported variable seems a bit pointless.

> +		NETIF_ERROR(adapter, probe, adapter->netdev,
> +			    "unsupported adapter, ID_REV = 0x%08X",
> +			    csr->id_rev);
> +		result = -ENODEV;
> +		goto clean_up;
> +	}
> +
> +	result = lan743x_csr_light_reset(adapter);
> +	if (result) {
> +		NETIF_ERROR(adapter, probe, adapter->netdev,
> +			    "light reset failed");
> +		goto clean_up;
> +	}
> +
> +	result = 0;
> +
> +clean_up:
> +	if (result)
> +		lan743x_csr_cleanup(adapter);
> +	return result;
> +}
> +
> +static inline u32 lan743x_csr_read(struct lan743x_adapter *adapter, int offset)

Please don't use inline. Let the compiler decide.

> +{
> +	return ioread32(&adapter->csr.csr_address[offset]);
> +}
> +
> +static inline void lan743x_csr_write(
> +	struct lan743x_adapter *adapter, int offset, u32 data)
> +{
> +	iowrite32(data, &adapter->csr.csr_address[offset]);
> +}


> +
> +static int lan743x_mdiobus_read(struct mii_bus *bus, int phy_id, int index);
> +static int lan743x_mdiobus_write(struct mii_bus *bus, int phy_id, int index,
> +				 u16 regval);

Please try to rearrange to code to avoid these.

> +static int lan743x_mac_init(struct lan743x_adapter *adapter)
> +{
> +	struct lan743x_mac *mac = &adapter->mac;
> +	struct net_device *netdev;
> +	u32 data;
> +	int ret = -ENODEV;
> +	u32 mac_addr_hi = 0;
> +	u32 mac_addr_lo = 0;
> +	bool mac_address_valid = true;
> +
> +	NETIF_ASSERT(adapter, probe, adapter->netdev, mac);
> +
> +	memset(mac, 0, sizeof(*mac));
> +
> +	netdev = adapter->netdev;
> +
> +	ret = lan743x_mac_reset(adapter);
> +	if (ret) {
> +		NETIF_ERROR(adapter, probe, adapter->netdev,
> +			    "mac reset failed");
> +		goto clean_up;
> +	}
> +
> +	/* setup auto duplex, and speed detection */
> +	data = lan743x_csr_read(adapter, MAC_CR);
> +	data |= MAC_CR_ADD_ | MAC_CR_ASD_;
> +	data |= MAC_CR_CNTR_RST_;
> +	lan743x_csr_write(adapter, MAC_CR, data);
> +
> +	mutex_init(&mac->tx_mutex);
> +	mac->tx_enable_bits = 0;
> +	mutex_init(&mac->rx_mutex);
> +	mac->rx_enable_bits = 0;
> +
> +	mac->mdiobus = mdiobus_alloc();
> +	if (!(mac->mdiobus)) {
> +		NETIF_ERROR(adapter, probe, adapter->netdev,
> +			    "mdiobus_alloc failed");
> +		ret = -ENOMEM;
> +		goto clean_up;
> +	}
> +	mac->flags |= MAC_FLAG_MDIOBUS_ALLOCATED;
> +
> +	mutex_init(&mac->mii_mutex);
> +	mac->mdiobus->priv = (void *)adapter;
> +	mac->mdiobus->read = lan743x_mdiobus_read;
> +	mac->mdiobus->write = lan743x_mdiobus_write;
> +	mac->mdiobus->name = "lan743x-mdiobus";
> +
> +	snprintf(mac->mdiobus->id, MII_BUS_ID_SIZE,
> +		 "pci-%s", pci_name(adapter->pci.pdev));
> +
> +	/* set to internal PHY id */
> +	mac->mdiobus->phy_mask = ~(1 << 1);

BIT(1)?

> +
> +	/* register mdiobus */
> +	ret = mdiobus_register(mac->mdiobus);
> +	if (ret < 0) {
> +		NETIF_ERROR(adapter, probe, adapter->netdev,
> +			    "failed to register MDIO bus");
> +		goto clean_up;
> +	}
> +	NETIF_INFO(adapter, probe, adapter->netdev,
> +		   "successfully registered MDIO bus, %s", mac->mdiobus->id);
> +	mac->flags |= MAC_FLAG_MDIOBUS_REGISTERED;
> +
> +	mac_addr_hi = lan743x_csr_read(adapter, MAC_RX_ADDRH);
> +	mac_addr_lo = lan743x_csr_read(adapter, MAC_RX_ADDRL);
> +	mac->mac_address[0] = mac_addr_lo & 0xFF;
> +	mac->mac_address[1] = (mac_addr_lo >> 8) & 0xFF;
> +	mac->mac_address[2] = (mac_addr_lo >> 16) & 0xFF;
> +	mac->mac_address[3] = (mac_addr_lo >> 24) & 0xFF;
> +	mac->mac_address[4] = mac_addr_hi & 0xFF;
> +	mac->mac_address[5] = (mac_addr_hi >> 8) & 0xFF;
> +
> +	if (((mac_addr_hi & 0x0000FFFF) == 0x0000FFFF) &&
> +	    (mac_addr_lo == 0xFFFFFFFF)) {
> +		NETIF_INFO(adapter, probe, adapter->netdev,
> +			   "MAC address not available from EEPROM or OTP");
> +		mac_address_valid = false;
> +	} else if (!is_valid_ether_addr(mac->mac_address)) {
> +		NETIF_WARNING(adapter, probe, adapter->netdev,
> +			      "MAC address is not valid");
> +		mac_address_valid = false;
> +	}
> +
> +	if (!mac_address_valid) {
> +		random_ether_addr(mac->mac_address);
> +		NETIF_INFO(adapter, probe, adapter->netdev,
> +			   "MAC address set to random address");
> +		mac_addr_lo = mac->mac_address[0] |
> +			      (mac->mac_address[1] << 8) |
> +			      (mac->mac_address[2] << 16) |
> +			      (mac->mac_address[3] << 24);
> +		mac_addr_hi = mac->mac_address[4] |
> +			      (mac->mac_address[5] << 8);
> +	}
> +
> +	lan743x_csr_write(adapter, MAC_RX_ADDRL, mac_addr_lo);
> +	lan743x_csr_write(adapter, MAC_RX_ADDRH, mac_addr_hi);

Why not use lan743x_mac_set_address()?

> +	NETIF_INFO(adapter, probe, adapter->netdev,
> +		   "MAC Address = %02X:%02X:%02X:%02X:%02X:%02X",
> +		   mac->mac_address[0], mac->mac_address[1],
> +		   mac->mac_address[2], mac->mac_address[3],
> +		   mac->mac_address[4], mac->mac_address[5]);
> +
> +	ether_addr_copy(netdev->dev_addr, mac->mac_address);
> +
> +	ret = 0;
> +
> +clean_up:
> +	if (ret)
> +		lan743x_mac_cleanup(adapter);
> +	return ret;
> +}
> +

> +#define MAC_MII_READ            1
> +#define MAC_MII_WRITE           0
> +static inline u32 lan743x_mac_mii_access(int id, int index, int read)

Again no inline functions. The compiler will probably inline it
anyway.

> +{
> +	u32 ret;
> +
> +	ret = ((u32)id << MAC_MII_ACC_PHY_ADDR_SHIFT_) &
> +	      MAC_MII_ACC_PHY_ADDR_MASK_;
> +	ret |= ((u32)index << MAC_MII_ACC_MIIRINDA_SHIFT_) &
> +	       MAC_MII_ACC_MIIRINDA_MASK_;

It appears you only support C22. So maybe change the function prototype to

u32 lan743x_mac_mii_access(u16 id, u16 index, int read)

and you can avoid the casts in the code.

> +	if (read)
> +		ret |= MAC_MII_ACC_MII_READ_;
> +	else
> +		ret |= MAC_MII_ACC_MII_WRITE_;
> +	ret |= MAC_MII_ACC_MII_BUSY_;
> +
> +	return ret;
> +}
> +
> +static int lan743x_mac_mii_wait_till_not_busy(struct lan743x_adapter *adapter)
> +{
> +	unsigned long start_time = jiffies;
> +	u32 data;
> +
> +	do {
> +		data = lan743x_csr_read(adapter, MAC_MII_ACC);
> +
> +		if (!(data & MAC_MII_ACC_MII_BUSY_))
> +			return 0;
> +	} while (!time_after(jiffies, start_time + HZ));
> +
> +	NETIF_ERROR(adapter, drv, adapter->netdev, "mii is busy");
> +	return -EIO;
> +}
> +
> +static int lan743x_mac_mii_read(struct lan743x_adapter *adapter,
> +				int phy_id, int index)
> +{
> +	struct lan743x_mac *mac = &adapter->mac;
> +	u32 val, addr;
> +	int ret;
> +
> +	mutex_lock(&mac->mii_mutex);

This is not needed. The mdio core will insure you don't get called
twice. See bus->mdio_lock.

> +
> +	/* comfirm MII not busy */
> +	ret = lan743x_mac_mii_wait_till_not_busy(adapter);
> +	if (ret < 0)
> +		goto done;
> +
> +	/* set the address, index & direction (read from PHY) */
> +	addr = lan743x_mac_mii_access(phy_id, index, MAC_MII_READ);

It is not really an address. So maybe call it reg?

> +	lan743x_csr_write(adapter, MAC_MII_ACC, addr);
> +
> +	ret = lan743x_mac_mii_wait_till_not_busy(adapter);
> +	if (ret < 0)
> +		goto done;
> +
> +	val = lan743x_csr_read(adapter, MAC_MII_DATA);
> +
> +	ret = (int)(val & 0xFFFF);
> +
> +done:
> +	mutex_unlock(&mac->mii_mutex);
> +#if (LAN743X_PHY_TRACE_ENABLE != 0)
> +	NETIF_INFO(adapter, drv, adapter->netdev,
> +		   "MII READ: phy_id = %d, index = %d, value = 0x%04X",
> +		   phy_id, index, ret);

You can get the same information from the mdio trace point.

> +#endif
> +	return ret;
> +}
> +
> +static int lan743x_mdiobus_read(struct mii_bus *bus, int phy_id, int index)
> +{
> +	struct lan743x_adapter *adapter = bus->priv;
> +
> +	return lan743x_mac_mii_read(adapter, phy_id, index);
> +}


> +static int lan743x_mac_set_mtu(struct lan743x_adapter *adapter, int new_mtu)
> +{
> +	struct lan743x_mac *mac = &adapter->mac;
> +	int ret = 0;
> +	u32 mac_rx = 0;
> +
> +	if (new_mtu > LAN743X_MAX_FRAME_SIZE)
> +		return -EINVAL;

You can set dev->max_mtu and the code will check this for you.
Ah, i see you already do. So why check here?

> +	if (new_mtu <= 0)
> +		return -EINVAL;

So you can deliberately send runt packets? It seems better to enforce
ETH_MIN_MTU, which the core will do for you by default.

> +
> +	mutex_lock(&mac->rx_mutex);
> +	if (mac->rx_enable_bits) {
> +		ret = lan743x_mac_rx_disable_all(adapter);
> +		if (ret) {
> +			NETIF_ERROR(adapter, drv, adapter->netdev,
> +				    "Failed to disable mac");
> +			goto done;
> +		}
> +	}
> +
> +	mac_rx = lan743x_csr_read(adapter, MAC_RX);
> +	mac_rx &= ~(MAC_RX_MAX_SIZE_MASK_);
> +	mac_rx |= (((new_mtu + ETH_HLEN + 4) << MAC_RX_MAX_SIZE_SHIFT_) &
> +		  MAC_RX_MAX_SIZE_MASK_);
> +	lan743x_csr_write(adapter, MAC_RX, mac_rx);
> +
> +	if (mac->rx_enable_bits) {
> +		ret = lan743x_mac_rx_enable_all(adapter);
> +		if (ret) {
> +			NETIF_ERROR(adapter, drv, adapter->netdev,
> +				    "Failed to enable mac");
> +			goto done;
> +		}
> +	}
> +done:
> +	mutex_unlock(&mac->rx_mutex);
> +	return ret;
> +}

> +static int lan743x_phy_open(struct lan743x_adapter *adapter)
> +{
> +	struct lan743x_phy *phy = &adapter->phy;
> +	int ret;
> +	u32 mii_adv;
> +	struct phy_device *phydev;
> +	struct net_device *netdev;
> +	struct lan743x_mac *mac = &adapter->mac;
> +	int phy_id1 = 0;
> +	int phy_id2 = 0;
> +
> +	netdev = adapter->netdev;
> +
> +	NETIF_ASSERT(adapter, ifup, adapter->netdev, mac->mdiobus);
> +
> +	phydev = phy_find_first(mac->mdiobus);
> +	if (!phydev) {
> +		NETIF_ERROR(adapter, ifup, adapter->netdev, "no PHY found");
> +		ret = -EIO;
> +		goto clean_up;
> +	}
> +
> +	phydev->irq = PHY_POLL;

It will default to polling.

> +
> +	NETIF_INFO(adapter, ifup, adapter->netdev,
> +		   "phy irq assigned to %d", phydev->irq);

See comment below about phy_attached_info().

> +	ret = phy_connect_direct(netdev, phydev,
> +				 lan743x_phy_link_status_change,
> +				 PHY_INTERFACE_MODE_GMII);
> +	if (ret) {
> +		NETIF_ERROR(adapter, ifup, adapter->netdev,
> +			    "can't attach PHY to %s", mac->mdiobus->id);
> +		ret = -EIO;
> +		goto clean_up;
> +	}
> +	phy->flags |= PHY_FLAG_ATTACHED;
> +
> +	if (!(phydev->drv)) {
> +		NETIF_ERROR(adapter, ifup, adapter->netdev,
> +			    "Missing PHY Driver");
> +		ret = -EIO;
> +		goto clean_up;
> +	}

Could you please explain how that can happen?

> +	phy_id1 = phy_read(phydev, MII_PHYSID1);
> +	phy_id2 = phy_read(phydev, MII_PHYSID2);
> +	NETIF_INFO(adapter, ifup, adapter->netdev,
> +		   "PHY_ID1 = 0x%04x", phy_id1);
> +	NETIF_INFO(adapter, ifup, adapter->netdev,
> +		   "PHY_ID2 = 0x%04x", phy_id2);

phy_attached_info()

> +
> +	/* MAC doesn't support 1000T Half */
> +	phydev->supported &= ~SUPPORTED_1000baseT_Half;
> +
> +	/* support both flow controls */
> +	phy->fc_request_control = (FLOW_CTRL_RX | FLOW_CTRL_TX);
> +	phydev->advertising &= ~(ADVERTISED_Pause | ADVERTISED_Asym_Pause);
> +	mii_adv = (u32)mii_advertise_flowctrl(phy->fc_request_control);
> +	phydev->advertising |= mii_adv_to_ethtool_adv_t(mii_adv);
> +
> +	phy->fc_autoneg = phydev->autoneg;
> +
> +	/* PHY interrupt enabled here */
> +	phy_start(phydev);
> +
> +	phy_start_aneg(phydev);
> +
> +	phy->flags |= PHY_FLAG_OPENED;
> +	ret = 0;
> +
> +clean_up:
> +	if (ret)
> +		lan743x_phy_close(adapter);
> +	return ret;
> +}
> +

> +static int lan743x_netdev_change_mtu(struct net_device *netdev, int new_mtu)
> +{
> +	int ret = 0;
> +	struct lan743x_adapter *adapter = netdev_priv(netdev);
> +
> +	NETIF_INFO(adapter, drv, adapter->netdev, "new_mtu = %d", new_mtu);
> +	ret = lan743x_mac_set_mtu(adapter, new_mtu);
> +	if (!ret)
> +		netdev->mtu = new_mtu;

dev_set_mtu() will do this for you.

> +	return ret;
> +}
> +

> +
> +static int lan743x_netdev_set_mac_address(struct net_device *netdev,
> +					  void *addr)
> +{
> +	struct lan743x_adapter *adapter = NULL;
> +	struct sockaddr *sock_addr = addr;
> +
> +	NETIF_ASSERT(adapter, drv, adapter->netdev, netdev);
> +
> +	if (netif_running(netdev))
> +		return -EBUSY;
> +
> +	if (!is_valid_ether_addr(sock_addr->sa_data))
> +		return -EADDRNOTAVAIL;

Look at how eth_mac_addr() calls eth_prepare_mac_addr_change().

> +
> +	ether_addr_copy(netdev->dev_addr, sock_addr->sa_data);
> +
> +	adapter = netdev_priv(netdev);
> +	lan743x_mac_set_address(adapter, sock_addr->sa_data);
> +	lan743x_rfe_update_mac_address(adapter);
> +
> +	return 0;
> +}

> +static int lan743x_ethtool_get_eeprom_len(struct net_device *netdev)
> +{
> +	return 0;
> +}

And the point of this is?

> +static int lan743x_ethtool_set_eee(struct net_device *netdev,
> +				   struct ethtool_eee *eee)
> +{
> +	struct lan743x_adapter *adapter = netdev_priv(netdev);
> +	struct phy_device *phydev = NULL;
> +	u32 buf = 0;
> +
> +	if (!netdev)
> +		return -EINVAL;
> +	adapter = netdev_priv(netdev);
> +	if (!adapter)
> +		return -EINVAL;
> +	phydev = netdev->phydev;
> +	if (!phydev)
> +		return -EIO;
> +	if (!phydev->drv) {
> +		NETIF_ERROR(adapter, drv, adapter->netdev,
> +			    "Missing PHY Driver");
> +		return -EIO;
> +	}

I don't see any calls to phy_init_eee(), so i'm not sure this works.

> +	if (eee->eee_enabled) {
> +		buf = lan743x_csr_read(adapter, MAC_CR);
> +		buf |= MAC_CR_EEE_EN_;
> +		lan743x_csr_write(adapter, MAC_CR, buf);
> +
> +		phy_ethtool_set_eee(phydev, eee);
> +
> +		buf = (u32)eee->tx_lpi_timer;
> +		lan743x_csr_write(adapter, MAC_EEE_TX_LPI_REQ_DLY_CNT, buf);
> +		NETIF_INFO(adapter, drv, adapter->netdev, "Enabled EEE");
> +	} else {
> +		buf = lan743x_csr_read(adapter, MAC_CR);
> +		buf &= ~MAC_CR_EEE_EN_;
> +		lan743x_csr_write(adapter, MAC_CR, buf);
> +		NETIF_INFO(adapter, drv, adapter->netdev, "Disabled EEE");
> +	}
> +
> +	return 0;
> +}
> +

> +static int lan743x_pcidev_probe(struct pci_dev *pdev,
> +				const struct pci_device_id *id)
> +{
> +	struct net_device *netdev = NULL;
> +	struct lan743x_adapter *adapter = NULL;
> +	int ret = -ENODEV;
> +
> +	NETIF_ASSERT(adapter, probe, adapter->netdev, pdev);
> +
> +	netdev = alloc_etherdev(sizeof(struct lan743x_adapter));
> +	if (!netdev) {
> +		NETIF_ERROR(adapter, probe, adapter->netdev,
> +			    "alloc_etherdev returned NULL");
> +		ret = -ENOMEM;
> +		goto clean_up;
> +	}
> +
> +	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
> +	SET_NETDEV_DEV(netdev, &pdev->dev);
> +	pci_set_drvdata(pdev, netdev);
> +	adapter = netdev_priv(netdev);
> +	if (!adapter) {
> +		NETIF_ERROR(adapter, probe, adapter->netdev,
> +			    "netdev_priv returned NULL");

Cannot happen. One allocation is made for both netdev and the private
area.

> +		ret = -ENOMEM;
> +		goto clean_up;
> +	}
> +	memset(adapter, 0, sizeof(struct lan743x_adapter));

and the allocation will zero the memory.

> +	adapter->netdev = netdev;
> +	adapter->init_flags = 0;
> +	adapter->open_flags = 0;

Don't you trust the memset you just did? If memset does not work, you
may as well give up now.

> +	strncpy(netdev->name, "eth%d", sizeof(netdev->name));

alloc_etherdev_mqs() will do this for you, as part of
alloc_etherdev().

> +	ret = register_netdev(netdev);
> +	if (ret < 0) {
> +		NETIF_ERROR(adapter, probe, adapter->netdev,
> +			    "failed to register net device, ret = %d", ret);
> +		goto clean_up;
> +	}
> +	adapter->init_flags |= LAN743X_INIT_FLAG_NETDEV_REGISTERED;
> +
> +	NETIF_INFO(adapter, probe, adapter->netdev, "Probe succeeded");
> +	ret = 0;
> +
> +clean_up:
> +	if (ret && adapter) {
> +		NETIF_WARNING(adapter, probe, adapter->netdev,
> +			      "Incomplete initialization, performing clean up");
> +		lan743x_device_cleanup(adapter);
> +	}
> +	return ret;
> +}
> +

> diff --git a/drivers/net/ethernet/microchip/lan743x.h b/drivers/net/ethernet/microchip/lan743x.h
> new file mode 100644
> index 0000000..8cf4323
> --- /dev/null
> +++ b/drivers/net/ethernet/microchip/lan743x.h

All the following forward declartions need to die, unless you have a
lot of mutual recursion. By having functions in the wrong order, you
are preventing the compiler from being able to optimize your code as
well. It can only inline what it has already seen.

   Andrew
