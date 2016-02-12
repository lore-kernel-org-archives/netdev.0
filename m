From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Thu, 11 Feb 2016 18:18:25 -0800
Message-ID: <56BD40F1.2030707@gmail.com>
References: <90A7E81AE28BAE4CBDDB3B35F187D264402EF4A2@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: Bryan.Whitehead@microchip.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36774 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309AbcBLCTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 21:19:32 -0500
Received: by mail-pf0-f174.google.com with SMTP id e127so39301420pfe.3
        for <netdev@vger.kernel.org>; Thu, 11 Feb 2016 18:19:31 -0800 (PST)
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264402EF4A2@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/02/16 10:58, Bryan.Whitehead@microchip.com wrote:
> This is the initial submission of an ethernet driver for
> the Microchip LAN9352.
> 
> The LAN9352 is a 2-Port 10/100 Managed Ethernet Switch with
> 16-Bit Non-PCI CPU Interface. The CPU interface includes a basic
> ethernet controller interface whose virtual phy is connected
> internally to a 3rd port on the embedded switch.
> 
> This driver only operates as a simple ethernet controller
> on the CPU interface. Since this interface is connected directly
> to the embedded switch, the result is that traffic can be sent and
> received on both physical ports.

If this is an integrated switch, have you considered using the DSA
subsystem and having this driver just be the Ethernet driver that
interfaces to your CPU interface, but does not attempt to configure the
switch in any way?

It would also help if you clarified the references to the SMSC911x
controllers and explain whether this was used for the Ethernet MAC, or
how the things are pieced together, as it seems like there could be
different strategies to support your hardware here.

> 
> Signed-off-by: Bryan Whitehead <Bryan.Whitehead@microchip.com>
> ---
>  Documentation/devicetree/bindings/net/mchp9352.txt |   31 +
>  MAINTAINERS                                        |    9 +
>  drivers/net/ethernet/microchip/Kconfig             |   32 +-
>  drivers/net/ethernet/microchip/Makefile            |    1 +
>  drivers/net/ethernet/microchip/mchp9352.c          | 2587 ++++++++++++++++++++
>  drivers/net/ethernet/microchip/mchp9352.h          |  443 ++++
>  6 files changed, 3102 insertions(+), 1 deletion(-)
>  create mode 100644 Documentation/devicetree/bindings/net/mchp9352.txt
>  create mode 100644 drivers/net/ethernet/microchip/mchp9352.c
>  create mode 100644 drivers/net/ethernet/microchip/mchp9352.h
> 
> diff --git a/Documentation/devicetree/bindings/net/mchp9352.txt b/Documentation/devicetree/bindings/net/mchp9352.txt
> new file mode 100644
> index 0000000..5b22e73
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/mchp9352.txt
> @@ -0,0 +1,31 @@
> +* Microchip LAN9352 Controller
> +
> +Required properties:
> +- compatible : Should be "microchip,lan9352"
> +- reg : Address and length of the io space for Microchip LAN
> +- interrupts : Should contain Microchip LAN interrupt line
> +- interrupt-parent : Should be the phandle for the interrupt controller

This is more like an optional property, in general there is a default
parent configured in your Device Tree.

> +  that services interrupts for this device
> +- phy-mode : See ethernet.txt file in the same directory

Same question as Andrew, if this is a 2-port switch, should not we have
one phy-mode per port of the switch?

> +
> +Optional properties:
> +- reg-shift : Specify the quantity to shift the register offsets by
> +- reg-io-width : Specify the size (in bytes) of the IO accesses that
> +  should be performed on the device.  Valid value for Microchip LAN is
> +  2 or 4.  If it's omitted or invalid, the size would be 2.
> +- microchip,irq-active-high : Indicates the IRQ polarity is active-high

Should not that be indicated in the interrupts property as a specific cell?

> +- microchip,irq-push-pull : Indicates the IRQ type is push-pull

Same here maybe?

> +- microchip,save-mac-address : Indicates that mac address needs to be saved
> +  before resetting the controller

That's a software construct here, no?

> +
> +Examples:
> +
> +lan9220@f4000000 {
> +	compatible = "microchip,lan9352";
> +	reg = <0xf4000000 0x2000000>;
> +	phy-mode = "mii";
> +	interrupt-parent = <&gpio1>;
> +	interrupts = <31>;
> +	reg-io-width = <4>;
> +	microchip,irq-push-pull;
> +};
> diff --git a/MAINTAINERS b/MAINTAINERS
> index f678c37..c39edef 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -7136,6 +7136,15 @@ T:	git git://git.monstr.eu/linux-2.6-microblaze.git
>  S:	Supported
>  F:	arch/microblaze/
>  
> +MICROCHIP LAN9352 ETHERNET DRIVER
> +M:	Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
> +M:	Bryan Whitehead <Bryan.Whitehead@microchip.com>
> +L:	netdev@vger.kernel.org
> +S:	Maintained
> +F:	Documentation/devicetree/bindings/net/mchp9352.txt
> +F:	drivers/net/ethernet/microchip/mchp9352.h
> +F:	drivers/net/ethernet/microchip/mchp9352.c
> +
>  MICROSOFT SURFACE PRO 3 BUTTON DRIVER
>  M:	Chen Yu <yu.c.chen@intel.com>
>  L:	platform-driver-x86@vger.kernel.org
> diff --git a/drivers/net/ethernet/microchip/Kconfig b/drivers/net/ethernet/microchip/Kconfig
> index 36a09d9..1f346a7 100644
> --- a/drivers/net/ethernet/microchip/Kconfig
> +++ b/drivers/net/ethernet/microchip/Kconfig
> @@ -5,7 +5,6 @@
>  config NET_VENDOR_MICROCHIP
>  	bool "Microchip devices"
>  	default y
> -	depends on SPI
>  	---help---
>  	  If you have a network (Ethernet) card belonging to this class, say Y.
>  
> @@ -28,6 +27,7 @@ config ENC28J60
>  
>  config ENC28J60_WRITEVERIFY
>  	bool "Enable write verify"
> +	depends on SPI
>  	depends on ENC28J60

That could be a preliminary patch, separate from this one.

>  	---help---
>  	  Enable the verify after the buffer write useful for debugging purpose.
> @@ -42,4 +42,34 @@ config ENCX24J600
>        To compile this driver as a module, choose M here. The module will be
>        called encx24j600.
>  

[snip]

> +#if USE_DEBUG > 0
> +static int debug = 16;
> +#else
> +static int debug = 3;
> +#endif
> +
> +module_param(debug, int, 0);
> +MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");

Consider using the netif_msg() debug facility which is configurable from
user-space through ethtool.

> +
> +struct mchp9352_data;
> +
> +struct mchp9352_ops {
> +	u32 (*reg_read)(struct mchp9352_data *pdata, u32 reg);
> +	void (*reg_write)(struct mchp9352_data *pdata, u32 reg, u32 val);
> +	void (*rx_readfifo)(struct mchp9352_data *pdata,
> +			    unsigned int *buf, unsigned int wordcount);
> +	void (*tx_writefifo)(struct mchp9352_data *pdata,
> +			     unsigned int *buf, unsigned int wordcount);
> +};
> +
> +#define MCHP9352_NUM_SUPPLIES 2
> +
> +struct mchp9352_data {
> +	void __iomem *ioaddr;
> +
> +	unsigned int idrev;
> +
> +	/* device configuration (copied from platform_data during probe) */
> +	struct mchp9352_platform_config config;
> +
> +	/* This needs to be acquired before calling any of below:
> +	 * mchp9352_mac_read(), mchp9352_mac_write()
> +	 */
> +	spinlock_t mac_lock;
> +
> +	/* spinlock to ensure register accesses are serialised */
> +	spinlock_t dev_lock;
> +
> +	struct phy_device *phy_dev;
> +	struct mii_bus *mii_bus;
> +	int phy_irq[PHY_MAX_ADDR];

The mii_bus structure already contains an irq array for each and every
possible 32 PHYs on the bus.

> +	int last_duplex;
> +	int last_carrier;
> +
> +	u32 msg_enable;
> +	unsigned int gpio_setting;
> +	unsigned int gpio_orig_setting;
> +	struct net_device *dev;
> +	struct napi_struct napi;
> +
> +	unsigned int software_irq_signal;
> +
> +#define MIN_PACKET_SIZE (64)
> +	char loopback_tx_pkt[MIN_PACKET_SIZE];
> +	char loopback_rx_pkt[MIN_PACKET_SIZE];
> +	unsigned int resetcount;

The loopback code seems pretty convulated, might be best to drop for
this initial submission, and once the driver is merged add it later, in
a way that it is controllable through NETIF_FLOOPBACK for instance?

[snip]

> +
> +static inline u32 __mchp9352_reg_read(struct mchp9352_data *pdata, u32 reg)
> +{
> +	if (pdata->config.flags & MCHP9352_USE_32BIT)
> +		return readl(pdata->ioaddr + reg);
> +
> +	if (pdata->config.flags & MCHP9352_USE_16BIT)
> +		return ((readw(pdata->ioaddr + reg) & 0xFFFF) |
> +			((readw(pdata->ioaddr + reg + 2) & 0xFFFF) << 16));

Would not it be better to have a generic structure which contains
function pointers to the correct I/O accessors width, such that you
could assign them once and for all during probe? Something like this:

struct mchp9532_io_ops {
	u32 (*read)(struct ..., u32 reg);
	void (*write)(struct ..., u32 reg, u32 value);
	void (*write_rep)(...)
	...
};

[snip]

> +	if (pdata->config.flags & MCHP9352_USE_32BIT) {
> +		iowrite32_rep(pdata->ioaddr + TX_DATA_FIFO, buf, wordcount);
> +		goto out;
> +	}

You probably want a write N words I/O operation here as well.

[snip]

> +
> +/* Request resources, currently just regulators.
> + *
> + * The SMSC911x has two power pins: vddvario and vdd33a, in designs where
> + * these are not always-on we need to request regulators to be turned on
> + * before we can try to access the device registers.

The comment here might be outdated and for another chip/design?

> + */
> +static int mchp9352_request_resources(struct platform_device *pdev)
> +{
> +	struct net_device *ndev = platform_get_drvdata(pdev);
> +	struct mchp9352_data *pdata = netdev_priv(ndev);
> +	int ret = 0;
> +
> +	/* Request regulators */
> +	pdata->supplies[0].supply = "vdd33a";
> +	pdata->supplies[1].supply = "vddvario";
> +	ret = regulator_bulk_get(&pdev->dev,
> +				 ARRAY_SIZE(pdata->supplies),
> +				 pdata->supplies);

Should not that come from Device Tree?

[snip]

> +/* Fetches a MAC register value. Assumes mac_lock is acquired */
> +static u32 mchp9352_mac_read(struct mchp9352_data *pdata, unsigned int offset)
> +{
> +	unsigned int temp;
> +
> +	MCHP_ASSERT_MAC_LOCK(pdata);
> +
> +	temp = mchp9352_reg_read(pdata, MAC_CSR_CMD);
> +	if (unlikely(temp & MAC_CSR_CMD_CSR_BUSY_)) {
> +		MCHP_WARN(pdata, hw, "MAC busy at entry");
> +		return 0xFFFFFFFF;
> +	}
> +
> +	/* Send the MAC cmd */
> +	mchp9352_reg_write(pdata, MAC_CSR_CMD, ((offset & 0xFF) |
> +		MAC_CSR_CMD_CSR_BUSY_ | MAC_CSR_CMD_R_NOT_W_));
> +
> +	/* Workaround for hardware read-after-write restriction */
> +	temp = mchp9352_reg_read(pdata, BYTE_TEST);
> +
> +	/* Wait for the read to complete */
> +	if (likely(mchp9352_mac_complete(pdata) == 0))
> +		return mchp9352_reg_read(pdata, MAC_CSR_DATA);

Missing cpu_relax() here?

> +
> +	MCHP_WARN(pdata, hw, "MAC busy after read");
> +	return 0xFFFFFFFF;
> +}
> +
> +/* Set a mac register, mac_lock must be acquired before calling */
> +static void mchp9352_mac_write(struct mchp9352_data *pdata,
> +			       unsigned int offset, u32 val)
> +{
> +	unsigned int temp;
> +
> +	MCHP_ASSERT_MAC_LOCK(pdata);
> +
> +	temp = mchp9352_reg_read(pdata, MAC_CSR_CMD);
> +	if (unlikely(temp & MAC_CSR_CMD_CSR_BUSY_)) {
> +		MCHP_WARN(pdata, hw,
> +			  "mchp9352_mac_write failed, MAC busy at entry");
> +		return;
> +	}
> +
> +	/* Send data to write */
> +	mchp9352_reg_write(pdata, MAC_CSR_DATA, val);
> +
> +	/* Write the actual data */
> +	mchp9352_reg_write(pdata, MAC_CSR_CMD, ((offset & 0xFF) |
> +		MAC_CSR_CMD_CSR_BUSY_));
> +
> +	/* Workaround for hardware read-after-write restriction */
> +	temp = mchp9352_reg_read(pdata, BYTE_TEST);
> +
> +	/* Wait for the write to complete */
> +	if (likely(mchp9352_mac_complete(pdata) == 0))
> +		return;

Same here

> +
> +	MCHP_WARN(pdata, hw, "mchp9352_mac_write failed, MAC busy after write");
> +}
> +
> +/* Get a phy register */
> +static int mchp9352_mii_read(struct mii_bus *bus, int phyaddr, int regidx)
> +{
> +	struct mchp9352_data *pdata = (struct mchp9352_data *)bus->priv;
> +	unsigned long flags;
> +	unsigned int addr;
> +	int i, reg;
> +
> +	spin_lock_irqsave(&pdata->mac_lock, flags);
> +
> +	/* Confirm MII not busy */
> +	if (unlikely(mchp9352_mac_read(pdata, MII_ACC) & MII_ACC_MII_BUSY_)) {
> +		MCHP_WARN(pdata, hw, "MII is busy in mchp9352_mii_read???");
> +		reg = -EIO;
> +		goto out;
> +	}
> +
> +	/* Set the address, index & direction (read from PHY) */
> +	addr = ((phyaddr & 0x1F) << 11) | ((regidx & 0x1F) << 6);
> +	mchp9352_mac_write(pdata, MII_ACC, addr);
> +
> +	/* Wait for read to complete w/ timeout */
> +	for (i = 0; i < 100; i++)
> +		if (!(mchp9352_mac_read(pdata, MII_ACC) & MII_ACC_MII_BUSY_)) {
> +			reg = mchp9352_mac_read(pdata, MII_DATA);
> +			goto out;
> +		}

Missing cpu_relax() and/or delay here too?

[snip]

> +static void mchp9352_phy_update_flowcontrol(struct mchp9352_data *pdata)
> +{
> +	struct phy_device *phy_dev = pdata->phy_dev;
> +	u32 afc = mchp9352_reg_read(pdata, AFC_CFG);
> +	u32 flow;
> +	unsigned long flags;
> +
> +	if (phy_dev->duplex == DUPLEX_FULL) {
> +		u16 lcladv = phy_read(phy_dev, MII_ADVERTISE);
> +		u16 rmtadv = phy_read(phy_dev, MII_LPA);
> +		u8 cap = mii_resolve_flowctrl_fdx(lcladv, rmtadv);

The PHY library should already resolve that for you, is not that working?

> +
> +		if (cap & FLOW_CTRL_RX)
> +			flow = 0xFFFF0002;
> +		else
> +			flow = 0;
> +
> +		if (cap & FLOW_CTRL_TX)
> +			afc |= 0xF;
> +		else
> +			afc &= ~0xF;
> +
> +		MCHP_TRACE(pdata, hw, "rx pause %s, tx pause %s",
> +			   (cap & FLOW_CTRL_RX ? "enabled" : "disabled"),
> +			   (cap & FLOW_CTRL_TX ? "enabled" : "disabled"));
> +	} else {
> +		MCHP_TRACE(pdata, hw, "half duplex");
> +		flow = 0;
> +		afc |= 0xF;
> +	}
> +
> +	spin_lock_irqsave(&pdata->mac_lock, flags);
> +	mchp9352_mac_write(pdata, FLOW, flow);
> +	spin_unlock_irqrestore(&pdata->mac_lock, flags);
> +
> +	mchp9352_reg_write(pdata, AFC_CFG, afc);
> +}
> +
> +/* Update link mode if anything has changed.  Called periodically when the
> + * PHY is in polling mode, even if nothing has changed.
> + */
> +static void mchp9352_phy_adjust_link(struct net_device *dev)
> +{
> +	struct mchp9352_data *pdata = netdev_priv(dev);
> +	struct phy_device *phy_dev = pdata->phy_dev;
> +	unsigned long flags;
> +
> +	if (phy_dev->duplex != pdata->last_duplex) {
> +		unsigned int mac_cr;
> +
> +		MCHP_TRACE(pdata, hw, "duplex state has changed");
> +
> +		spin_lock_irqsave(&pdata->mac_lock, flags);
> +		mac_cr = mchp9352_mac_read(pdata, MAC_CR);
> +		if (phy_dev->duplex) {
> +			MCHP_TRACE(pdata, hw,
> +				   "configuring for full duplex mode");
> +			mac_cr |= MAC_CR_FDPX_;
> +		} else {
> +			MCHP_TRACE(pdata, hw,
> +				   "configuring for half duplex mode");
> +			mac_cr &= ~MAC_CR_FDPX_;
> +		}
> +		mchp9352_mac_write(pdata, MAC_CR, mac_cr);
> +		spin_unlock_irqrestore(&pdata->mac_lock, flags);
> +
> +		mchp9352_phy_update_flowcontrol(pdata);
> +		pdata->last_duplex = phy_dev->duplex;
> +	}

You are ignoring the link here, which is typically what should trigger a
reprogramming of registers, is that intentional?

> +}
> +
> +static int mchp9352_mii_probe(struct net_device *dev)
> +{
> +	struct mchp9352_data *pdata = netdev_priv(dev);
> +	struct phy_device *phydev = NULL;
> +	int ret;
> +
> +	/* find the first phy */
> +	phydev = phy_find_first(pdata->mii_bus);
> +	if (!phydev) {
> +		netdev_err(dev, "no PHY found\n");
> +		return -ENODEV;
> +	}
> +
> +	MCHP_TRACE(pdata, probe, "PHY: addr %d, phy_id 0x%08X",
> +		   phydev->mdio.addr, phydev->phy_id);
> +
> +	ret = phy_connect_direct(dev, phydev, &mchp9352_phy_adjust_link,
> +				 pdata->config.phy_interface);
> +
> +	if (ret) {
> +		netdev_err(dev, "Could not attach to PHY\n");
> +		return ret;
> +	}
> +
> +	phy_attached_info(phydev);
> +
> +	/* mask with MAC supported features */
> +	phydev->supported &= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
> +			      SUPPORTED_Asym_Pause);
> +	phydev->advertising = phydev->supported;
> +
> +	pdata->phy_dev = phydev;
> +	pdata->last_duplex = -1;
> +	pdata->last_carrier = -1;
> +
> +	if (mchp9352_phy_loopbacktest(dev) < 0) {
> +		MCHP_WARN(pdata, hw, "Failed Loop Back Test");
> +		phy_disconnect(phydev);
> +		return -ENODEV;
> +	}

I would drop that for now, unless this is absolutely needed for proper
operation?

[snip]

> +	if (mdiobus_register(pdata->mii_bus)) {
> +		MCHP_WARN(pdata, probe, "Error registering mii bus");
> +		goto err_out_free_bus_2;
> +	}

I am sure checkpatch.pl would have complained about this style and not
this one:

ret = foo(bar);
if (ret) {
	err(...
}

[snip]

> +/* Reads tx statuses and increments counters where necessary */
> +static void mchp9352_tx_update_txcounters(struct net_device *dev)
> +{
> +	struct mchp9352_data *pdata = netdev_priv(dev);
> +	unsigned int tx_stat;
> +
> +	while ((tx_stat = mchp9352_tx_get_txstatus(pdata)) != 0) {
> +		if (unlikely(tx_stat & 0x80000000)) {
> +			/* In this driver the packet tag is used as the packet
> +			 * length. Since a packet length can never reach the
> +			 * size of 0x8000, this bit is reserved. It is worth
> +			 * noting that the "reserved bit" in the warning above
> +			 * does not reference a hardware defined reserved bit
> +			 * but rather a driver defined one.
> +			 */
> +			MCHP_WARN(pdata, hw, "Packet tag reserved bit is high");

If you have a packet tag format with your switch, then you should
definitively be able to leverage the DSA subsystem by creating a custom
tag parser, which would be a cleaner solution here, rather than having
your Ethernet driver needing to know about the special format, see
net/dsa/tag_*.c

[snip]

> +
> +/* NAPI poll function */
> +static int mchp9352_poll(struct napi_struct *napi, int budget)
> +{
> +	struct mchp9352_data *pdata =
> +		container_of(napi, struct mchp9352_data, napi);
> +	struct net_device *dev = pdata->dev;
> +	int npackets = 0;
> +
> +	while (npackets < budget) {
> +		unsigned int pktlength;
> +		unsigned int pktwords;
> +		struct sk_buff *skb;
> +		unsigned int rxstat = mchp9352_rx_get_rxstatus(pdata);
> +
> +		if (!rxstat) {
> +			unsigned int temp;
> +			/* We processed all packets available.  Tell NAPI it can
> +			 * stop polling then re-enable rx interrupts
> +			 */
> +			mchp9352_reg_write(pdata, INT_STS, INT_STS_RSFL_);
> +			napi_complete(napi);
> +			temp = mchp9352_reg_read(pdata, INT_EN);
> +			temp |= INT_EN_RSFL_EN_;
> +			mchp9352_reg_write(pdata, INT_EN, temp);
> +			break;
> +		}
> +
> +		/* Count packet for NAPI scheduling, even if it has an error.
> +		 * Error packets still require cycles to discard
> +		 */
> +		npackets++;
> +
> +		pktlength = ((rxstat & 0x3FFF0000) >> 16);
> +		pktwords = (pktlength + NET_IP_ALIGN + 3) >> 2;
> +		mchp9352_rx_counterrors(dev, rxstat);
> +
> +		if (unlikely(rxstat & RX_STS_ES_)) {
> +			MCHP_WARN(pdata, rx_err,
> +				  "Discarding packet with error bit set");
> +			/* Packet has an error, discard it and continue with
> +			 * the next
> +			 */
> +			mchp9352_rx_fastforward(pdata, pktwords);
> +			dev->stats.rx_dropped++;
> +			continue;
> +		}
> +
> +		skb = netdev_alloc_skb(dev, pktwords << 2);

No checking of pktwords here to make sure it is not oversized?

> +		if (unlikely(!skb)) {
> +			MCHP_WARN(pdata, rx_err,
> +				  "Unable to allocate skb for rx packet");
> +			/* Drop the packet and stop this polling iteration */
> +			mchp9352_rx_fastforward(pdata, pktwords);
> +			dev->stats.rx_dropped++;

You should actually continue polling and see if there are more packets
coming your way.

> +			break;
> +		}
> +
> +		pdata->ops->rx_readfifo(pdata,
> +				 (unsigned int *)skb->data, pktwords);
> +
> +		/* Align IP on 16B boundary */
> +		skb_reserve(skb, NET_IP_ALIGN);

NET_IP_ALIGN is typically 2bytes, the alignment is already taken care of
by netdev_alloc_skb().

> +		skb_put(skb, pktlength - 4);

What's the 4 for? FCS you could use ETH_FCS_LEN

> +		skb->protocol = eth_type_trans(skb, dev);
> +		skb_checksum_none_assert(skb);
> +		netif_receive_skb(skb);
> +
> +		/* Update counters */
> +		dev->stats.rx_packets++;
> +		dev->stats.rx_bytes += (pktlength - 4);
> +	}
> +
> +	/* Return total received packets */
> +	return npackets;
> +}
[snip]


> +}
> +
> +/* Entry point for transmitting a packet */
> +static int mchp9352_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct mchp9352_data *pdata = netdev_priv(dev);
> +	unsigned int freespace;
> +	unsigned int tx_cmd_a;
> +	unsigned int tx_cmd_b;
> +	unsigned int temp;
> +	u32 wrsz;
> +	ulong bufp;
> +
> +	freespace = mchp9352_reg_read(pdata, TX_FIFO_INF) & TX_FIFO_INF_TDFREE_;
> +
> +	if (unlikely(freespace < TX_FIFO_LOW_THRESHOLD))
> +		MCHP_WARN(pdata, tx_err,
> +			  "Tx data fifo low, space available: %d", freespace);
> +
> +	/* Word alignment adjustment */
> +	tx_cmd_a = (u32)((ulong)skb->data & 0x03) << 16;
> +	tx_cmd_a |= TX_CMD_A_FIRST_SEG_ | TX_CMD_A_LAST_SEG_;
> +	tx_cmd_a |= (unsigned int)skb->len;
> +
> +	tx_cmd_b = ((unsigned int)skb->len) << 16;
> +	tx_cmd_b |= (unsigned int)skb->len;

Is that really needed? Have you met a SKB which was not properly aligned?

> +
> +	mchp9352_reg_write(pdata, TX_DATA_FIFO, tx_cmd_a);
> +	mchp9352_reg_write(pdata, TX_DATA_FIFO, tx_cmd_b);
> +
> +	bufp = (ulong)skb->data & (~0x3);
> +	wrsz = (u32)skb->len + 3;
> +	wrsz += (u32)((ulong)skb->data & 0x3);
> +	wrsz >>= 2;
> +
> +	pdata->ops->tx_writefifo(pdata, (unsigned int *)bufp, wrsz);
> +	freespace -= (skb->len + 32);
> +	skb_tx_timestamp(skb);
> +	dev_consume_skb_any(skb);

You do not have TX completion interrupt in which you could free up SKBs
you have previously transmitted?

> +
> +	if (unlikely(mchp9352_tx_get_txstatcount(pdata) >= 30))
> +		mchp9352_tx_update_txcounters(dev);
> +
> +	if (freespace < TX_FIFO_LOW_THRESHOLD) {
> +		netif_stop_queue(dev);
> +		temp = mchp9352_reg_read(pdata, FIFO_INT);
> +		temp &= 0x00FFFFFF;
> +		temp |= 0x32000000;
> +		mchp9352_reg_write(pdata, FIFO_INT, temp);
> +	}
> +
> +	return NETDEV_TX_OK;
> +}
> +
> +/* Entry point for getting status counters */
> +static struct net_device_stats *mchp9352_get_stats(struct net_device *dev)
> +{
> +	struct mchp9352_data *pdata = netdev_priv(dev);
> +
> +	mchp9352_tx_update_txcounters(dev);
> +	dev->stats.rx_dropped += mchp9352_reg_read(pdata, RX_DROP);

Prefer adding those to custom ethtool stats instead.

[snip]

> +	}
> +	res_size = resource_size(res);
> +
> +	irq = platform_get_irq(pdev, 0);
> +	if (irq == -EPROBE_DEFER) {
> +		retval = -EPROBE_DEFER;
> +		goto out_0;
> +	} else if (irq <= 0) {
> +		pr_warn("Could not allocate irq resource\n");
> +		retval = -ENODEV;
> +		goto out_0;
> +	}
> +
> +	if (!request_mem_region(res->start, res_size, MCHP_CHIPNAME)) {
> +		retval = -EBUSY;
> +		goto out_0;
> +	}

devm_ioremap_resource() would take care of that for you as well.

> +
> +	dev = alloc_etherdev(sizeof(struct mchp9352_data));
> +	if (!dev) {
> +		retval = -ENOMEM;
> +		goto out_release_io_1;
> +	}
> +
> +	SET_NETDEV_DEV(dev, &pdev->dev);
> +
> +	pdata = netdev_priv(dev);
> +	dev->irq = irq;
> +	irq_flags = irq_get_trigger_type(irq);
> +	pdata->ioaddr = ioremap_nocache(res->start, res_size);

No check here?

> +
> +	pdata->dev = dev;
> +	pdata->msg_enable = ((1 << debug) - 1);
> +
> +	platform_set_drvdata(pdev, dev);
> +
> +	retval = mchp9352_request_resources(pdev);
> +	if (retval)
> +		goto out_request_resources_fail;
> +
> +	retval = mchp9352_enable_resources(pdev);
> +	if (retval)
> +		goto out_enable_resources_fail;
> +
> +	if (!pdata->ioaddr) {
> +		MCHP_WARN(pdata, probe, "Error mchp9352 base address invalid");
> +		retval = -ENOMEM;
> +		goto out_disable_resources;
> +	}
> +
> +	retval = mchp9352_probe_config(&pdata->config, &pdev->dev);
> +	if (retval && config) {
> +		/* copy config parameters across to pdata */
> +		memcpy(&pdata->config, config, sizeof(pdata->config));
> +		retval = 0;
> +	}
> +
> +	if (retval) {
> +		MCHP_WARN(pdata, probe, "Error mchp9352 config not found");
> +		goto out_disable_resources;
> +	}
> +
> +	/* assume standard, non-shifted, access to HW registers */
> +	pdata->ops = &standard_mchp9352_ops;
> +	/* apply the right access if shifting is needed */
> +	if (pdata->config.shift)
> +		pdata->ops = &shifted_mchp9352_ops;
> +
> +	pm_runtime_enable(&pdev->dev);
> +	pm_runtime_get_sync(&pdev->dev);
> +
> +	retval = mchp9352_init(dev);
> +	if (retval < 0)
> +		goto out_disable_resources;
> +
> +	/* configure irq polarity and type before connecting isr */
> +	if (pdata->config.irq_polarity == MCHP9352_IRQ_POLARITY_ACTIVE_HIGH)
> +		intcfg |= INT_CFG_IRQ_POL_;
> +
> +	if (pdata->config.irq_type == MCHP9352_IRQ_TYPE_PUSH_PULL)
> +		intcfg |= INT_CFG_IRQ_TYPE_;
> +
> +	if (mchp9352_wait_till_ready(pdata) != 0)
> +		goto out_disable_resources;
> +
> +	mchp9352_reg_write(pdata, INT_CFG, intcfg);
> +
> +	/* Ensure interrupts are globally disabled before connecting ISR */
> +	mchp9352_disable_irq_chip(dev);
> +
> +	retval = request_irq(dev->irq, mchp9352_irqhandler,
> +			     irq_flags | IRQF_SHARED, dev->name, dev);
> +	if (retval) {
> +		MCHP_WARN(pdata, probe,
> +			  "Unable to claim requested irq: %d", dev->irq);
> +		goto out_disable_resources;
> +	}
> +
> +	netif_carrier_off(dev);
> +
> +	retval = register_netdev(dev);
> +	if (retval) {
> +		MCHP_WARN(pdata, probe, "Error %i registering device", retval);
> +		goto out_free_irq;
> +	} else {
> +		MCHP_TRACE(pdata, probe,
> +			   "Network interface: \"%s\"", dev->name);
> +	}
> +
> +	retval = mchp9352_mii_init(pdev, dev);
> +	if (retval) {
> +		MCHP_WARN(pdata, probe, "Error %i initialising mii", retval);
> +		goto out_unregister_netdev_5;
> +	}

You would want to swap both calls here, past register_netdev(), the
interface can be used by a netdev notifier, and that could oops or fail
initializing properly if you are missing MII bus registration.

> +
> +	spin_lock_irq(&pdata->mac_lock);
> +
> +	/* Check if mac address has been specified when bringing interface up */
> +	if (is_valid_ether_addr(dev->dev_addr)) {
> +		mchp9352_set_hw_mac_address(pdata, dev->dev_addr);
> +		MCHP_TRACE(pdata, probe,
> +			   "MAC Address is specified by configuration");
> +	} else if (is_valid_ether_addr(pdata->config.mac)) {
> +		ether_addr_copy(dev->dev_addr, pdata->config.mac);
> +		MCHP_TRACE(pdata, probe,
> +			   "MAC Address specified by platform data");
> +	} else {
> +		/* Try reading mac address from device. if EEPROM is present
> +		 * it will already have been set
> +		 */
> +		mchp_get_mac(dev);
> +
> +		if (is_valid_ether_addr(dev->dev_addr)) {
> +			/* eeprom values are valid  so use them */
> +			MCHP_TRACE(pdata, probe,
> +				   "Mac Address is read from LAN9352 EEPROM");
> +		} else {
> +			/* eeprom values are invalid, generate random MAC */
> +			eth_hw_addr_random(dev);
> +			mchp9352_set_hw_mac_address(pdata, dev->dev_addr);
> +			MCHP_TRACE(pdata, probe,
> +				   "MAC Address is set to eth_random_addr");
> +		}
> +	}
> +
> +	spin_unlock_irq(&pdata->mac_lock);
> +
> +	netdev_info(dev, "MAC Address: %pM\n", dev->dev_addr);
> +	return 0;
> +
> +out_unregister_netdev_5:
> +	unregister_netdev(dev);
> +out_free_irq:
> +	free_irq(dev->irq, dev);
> +out_disable_resources:
> +	pm_runtime_put(&pdev->dev);
> +	pm_runtime_disable(&pdev->dev);
> +	(void)mchp9352_disable_resources(pdev);
> +out_enable_resources_fail:
> +	mchp9352_free_resources(pdev);
> +out_request_resources_fail:
> +	iounmap(pdata->ioaddr);
> +	free_netdev(dev);
> +out_release_io_1:
> +	release_mem_region(res->start, resource_size(res));
> +out_0:
> +
> +	return retval;
> +}
> +
> +#ifdef CONFIG_PM
> +/* This implementation assumes the devices remains powered on its VDDVARIO
> + * pins during suspend.
> + */
> +
> +/* TODO: implement freeze/thaw callbacks for hibernation.*/
> +
> +static int mchp9352_suspend(struct device *dev)
> +{
> +	struct net_device *ndev = dev_get_drvdata(dev);
> +	struct mchp9352_data *pdata = netdev_priv(ndev);
> +
> +	/* enable wake on LAN, energy detection and the external PME
> +	 * signal.
> +	 */
> +	mchp9352_reg_write(pdata, PMT_CTRL,
> +			   PMT_CTRL_PM_MODE_D1_ | PMT_CTRL_WOL_EN_ |
> +			   PMT_CTRL_ED_EN_ | PMT_CTRL_PME_EN_);

Wake-on-LAN is something that is controllable through ethtool, if an
user has it disabled, you should not allow it here. You do not seem to
be hooking properly to the device PM framework either (not seeing
device_set_wakeup_capable, etc.).

> +
> +	return 0;
> +}
> +
> +static int mchp9352_resume(struct device *dev)
> +{
> +	struct net_device *ndev = dev_get_drvdata(dev);
> +	struct mchp9352_data *pdata = netdev_priv(ndev);
> +	unsigned int to = 100;
> +
> +	/* Writing any data to the BYTE_TEST register will wake-up the device.
> +	 */
> +	mchp9352_reg_write(pdata, BYTE_TEST, 0);
> +
> +	/* poll the READY bit in PMT_CTRL. Any other access to the device is
> +	 * forbidden while this bit isn't set. Try for 100ms and return -EIO
> +	 * if it failed.
> +	 */
> +	while (!(mchp9352_reg_read(pdata, PMT_CTRL) & PMT_CTRL_READY_) && --to)
> +		usleep_range(1000, 2000);
> +
> +	return (to == 0) ? -EIO : 0;

And that's it? No need to resume the network device, or re-initialize
buffer pointers or anything?

> +}
> +
> +static const struct dev_pm_ops mchp9352_pm_ops = {
> +	.suspend	= mchp9352_suspend,
> +	.resume		= mchp9352_resume,
> +};
> +
> +#define MCHP9352_PM_OPS (&mchp9352_pm_ops)
> +
> +#else
> +#define MCHP9352_PM_OPS NULL
> +#endif
> +
> +#ifdef CONFIG_OF
> +static const struct of_device_id mchp9352_dt_ids[] = {
> +	{ .compatible = "microchip,lan9352", },
> +	{ /* sentinel */ }
> +};
> +MODULE_DEVICE_TABLE(of, mchp9352_dt_ids);
> +#endif
> +
> +static const struct acpi_device_id mchp9352_acpi_match[] = {
> +	{ "ARMH9352", 0 },
> +	{ }
> +};
> +MODULE_DEVICE_TABLE(acpi, mchp9352_acpi_match);
> +
> +static struct platform_driver mchp9352_driver = {
> +	.probe = mchp9352_drv_probe,
> +	.remove = mchp9352_drv_remove,
> +	.driver = {
> +		.name	= MCHP_CHIPNAME,
> +		.pm	= MCHP9352_PM_OPS,
> +		.of_match_table = of_match_ptr(mchp9352_dt_ids),
> +		.acpi_match_table = ACPI_PTR(mchp9352_acpi_match),
> +	},
> +};
> +
> +/* Entry point for loading the module */
> +static int __init mchp9352_init_module(void)
> +{
> +	MCHP_INITIALIZE();
> +	return platform_driver_register(&mchp9352_driver);
> +}
> +
> +/* entry point for unloading the module */
> +static void __exit mchp9352_cleanup_module(void)
> +{
> +	platform_driver_unregister(&mchp9352_driver);
> +}

module_platform_driver() can be used to reduce the boilerplate code here.
-- 
Florian
