From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 1/5] net: Add davicom wemac ethernet driver found on Allwinner A10 SoC's
Date: Sat, 16 Mar 2013 15:41:36 +0100
Message-ID: <201303161541.37341.florian@openwrt.org>
References: <1363380605-6577-1-git-send-email-maxime.ripard@free-electrons.com> <1363380605-6577-2-git-send-email-maxime.ripard@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maxime Ripard <maxime.ripard@free-electrons.com>,
	linux-doc@vger.kernel.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	Rob Herring <rob.herring@calxeda.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Landley <rob@landley.net>, sunny@allwinnertech.com,
	shuge@allwinnertech.com, Stefan Roese <sr@denx.de>,
	kevin@allwinnertech.com
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1363380605-6577-2-git-send-email-maxime.ripard@free-electrons.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Maxime, Stefan,

Please find below some comments regarding your PHY implementation in th=
e driver=20
as well as the transmit and transmit completion routines.

Le vendredi 15 mars 2013 21:50:00, Maxime Ripard a =E9crit :
> From: Stefan Roese <sr@denx.de>
>=20
> The Allwinner A10 has an ethernet controller that is advertised as
> coming from Davicom.
>=20
> The exact feature set of this controller is unknown, since there is n=
o
> public documentation for this IP, and this driver is mostly the one
> published by Allwinner that has been heavily cleaned up.
>=20
> Signed-off-by: Stefan Roese <sr@denx.de>
> Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>

[snip]

> +
> +wemac: ethernet@01c0b000 {
> +       compatible =3D "davicom,wemac";
> +       reg =3D <0x01c0b000 0x1000>;
> +       interrupts =3D <55>;
> +       allwinner,power-gpios =3D <&pio 7 19 0>;
> +};

You do not define any handle for the PHY chip, but I think you should m=
ake this=20
configurable and use the standard Device Tree helpers for finding and c=
onnecting=20
a PHY driver to your EMAC adapter driver.
[snip]

> +#define WEMAC_PHY		0x100	/* PHY address 0x01 */

This should be made configurable if possible.

[snip]

> + */
> +
> +struct wemac_board_info {
> +	struct clk		*clk;
> +	struct device		*dev;
> +	spinlock_t		lock;
> +	void __iomem		*membase;
> +	struct mii_if_info	mii;
> +	u32			msg_enable;
> +	struct net_device	*ndev;
> +	struct mutex		phy_lock;
> +	struct delayed_work	phy_poll;

Consider using phylib which should allow you to remove struct mii_if_in=
fo and=20
the mutex and poll delayed workqueue.

> +	unsigned		power_gpio;

you could make this an int, so that you use gpio_is_valid() on this one=
=2E

> +	struct sk_buff		*skb_last;
> +	u16			tx_fifo_stat;
> +};
> +
> +static inline struct wemac_board_info *to_wemac_board(struct net_dev=
ice
> *dev) +{
> +	return netdev_priv(dev);
> +}
> +
> +static int wemac_phy_read(struct net_device *dev, int phyaddr, int r=
eg)
> +{
> +	struct wemac_board_info *db =3D netdev_priv(dev);
> +	unsigned long flags;
> +	int ret;
> +
> +	mutex_lock(&db->phy_lock);
> +
> +	spin_lock_irqsave(&db->lock, flags);
> +	/* issue the phy address and reg */
> +	writel(phyaddr | reg, db->membase + EMAC_MAC_MADR_REG);
> +	/* pull up the phy io line */
> +	writel(0x1, db->membase + EMAC_MAC_MCMD_REG);
> +	spin_unlock_irqrestore(&db->lock, flags);
> +
> +	/* Wait read complete */
> +	mdelay(1);
> +
> +	/* push down the phy io line and read data */
> +	spin_lock_irqsave(&db->lock, flags);
> +	/* push down the phy io line */
> +	writel(0x0, db->membase + EMAC_MAC_MCMD_REG);
> +	/* and read data */
> +	ret =3D readl(db->membase + EMAC_MAC_MRDD_REG);
> +	spin_unlock_irqrestore(&db->lock, flags);
> +
> +	mutex_unlock(&db->phy_lock);

This sounds pretty complicated as a locking scheme, using phylib should=
 make=20
this simpler anyway.

> +
> +	return ret;
> +}
> +
> +/* Write a word to phyxcer */
> +static void wemac_phy_write(struct net_device *dev,
> +			    int phyaddr, int reg, int value)
> +{
> +	struct wemac_board_info *db =3D netdev_priv(dev);
> +	unsigned long flags;
> +
> +	mutex_lock(&db->phy_lock);
> +
> +	spin_lock_irqsave(&db->lock, flags);
> +	/* issue the phy address and reg */
> +	writel(phyaddr | reg, db->membase + EMAC_MAC_MADR_REG);
> +	/* pull up the phy io line */
> +	writel(0x1, db->membase + EMAC_MAC_MCMD_REG);
> +	spin_unlock_irqrestore(&db->lock, flags);
> +
> +	/* Wait write complete */
> +	mdelay(1);
> +
> +	spin_lock_irqsave(&db->lock, flags);
> +	/* push down the phy io line */
> +	writel(0x0, db->membase + EMAC_MAC_MCMD_REG);
> +	/* and write data */
> +	writel(value, db->membase + EMAC_MAC_MWTD_REG);
> +	spin_unlock_irqrestore(&db->lock, flags);
> +
> +	mutex_unlock(&db->phy_lock);

Ditto

> +}
> +
> +static int emacrx_completed_flag =3D 1;

This should be moved to your interface specific private structure, as i=
t won't=20
work when there are two instances of the same driver.

[snip]

> +
> +static void wemac_dumpblk_32bit(void __iomem *reg, int count)
> +{
> +	int i;
> +	int tmp;
> +
> +	for (i =3D 0; i < (round_up(count, 4) / 4); i++)
> +		tmp =3D readl(reg);
> +}

This could probably be removed, tmp is a write only location, did you r=
emove=20
the variable printing that came along this?

> +
> +static void wemac_schedule_poll(struct wemac_board_info *db)
> +{
> +	schedule_delayed_work(&db->phy_poll, HZ * 2);
> +}

phylib takes care of the polling for you.

> +
> +static int wemac_ioctl(struct net_device *dev, struct ifreq *req, in=
t cmd)
> +{
> +	struct wemac_board_info *dm =3D to_wemac_board(dev);
> +
> +	if (!netif_running(dev))
> +		return -EINVAL;
> +
> +	return generic_mii_ioctl(&dm->mii, if_mii(req), cmd, NULL);
> +}
> +
> +/* ethtool ops */
> +static void wemac_get_drvinfo(struct net_device *dev,
> +			      struct ethtool_drvinfo *info)
> +{
> +	strcpy(info->driver, DRV_NAME);
> +	strcpy(info->version, DRV_VERSION);

You should use strlcpy() here to ensure null-termination, and you shoul=
d also=20
fill in the bus_info member of struct ethtool_drvinfo.

> +}
> +

[snip]

> +unsigned int phy_link_check(struct net_device *dev)
> +{
> +	unsigned int reg_val;
> +
> +	reg_val =3D wemac_phy_read(dev, WEMAC_PHY, 1);
> +
> +	if (reg_val & 0x4) {
> +		netdev_info(dev, "EMAC PHY Linked...\n");
> +		return 1;
> +	} else {
> +		netdev_info(dev, "EMAC PHY Link waiting......\n");
> +		return 0;
> +	}
> +}

Please remove this and migrate to phylib.

> +
> +unsigned int emac_setup(struct net_device *ndev)
> +{
> +	unsigned int reg_val;
> +	unsigned int phy_val;
> +	unsigned int duplex_flag;
> +	struct wemac_board_info *db =3D netdev_priv(ndev);
> +
> +	/* set up TX */
> +	reg_val =3D readl(db->membase + EMAC_TX_MODE_REG);
> +
> +	writel(reg_val | EMAC_TX_MODE_ABORTED_FRAME_EN,
> +		db->membase + EMAC_TX_MODE_REG);
> +
> +	/* set up RX */
> +	reg_val =3D readl(db->membase + EMAC_RX_CTL_REG);
> +
> +	writel(reg_val | EMAC_RX_CTL_PASS_LEN_OOR_EN |
> +		EMAC_RX_CTL_ACCEPT_UNICAST_EN | EMAC_RX_CTL_DA_FILTER_EN |
> +		EMAC_RX_CTL_ACCEPT_MULTICAST_EN |
> +		EMAC_RX_CTL_ACCEPT_BROADCAST_EN,
> +		db->membase + EMAC_RX_CTL_REG);
> +
> +	/* set MAC */
> +	/* set MAC CTL0 */
> +	reg_val =3D readl(db->membase + EMAC_MAC_CTL0_REG);
> +	writel(reg_val | EMAC_MAC_CTL0_RX_FLOW_CTL_EN |
> +		EMAC_MAC_CTL0_TX_FLOW_CTL_EN,
> +		db->membase + EMAC_MAC_CTL0_REG);
> +
> +	/* set MAC CTL1 */
> +	reg_val =3D readl(db->membase + EMAC_MAC_CTL1_REG);
> +	phy_val =3D wemac_phy_read(ndev, WEMAC_PHY, 0);
> +	dev_dbg(db->dev, "PHY SETUP, reg 0 value: %x\n", phy_val);
> +	duplex_flag =3D !!(phy_val & EMAC_PHY_DUPLEX);
> +
> +	if (duplex_flag)
> +		reg_val |=3D EMAC_MAC_CTL1_DUPLEX_EN;
> +
> +	reg_val |=3D EMAC_MAC_CTL1_LEN_CHECK_EN;
> +	reg_val |=3D EMAC_MAC_CTL1_CRC_EN;
> +	reg_val |=3D EMAC_MAC_CTL1_PAD_EN;
> +	writel(reg_val, db->membase + EMAC_MAC_CTL1_REG);
> +
> +	/* set up IPGT */
> +	writel(EMAC_MAC_IPGT_FULL_DUPLEX, db->membase + EMAC_MAC_IPGT_REG);
> +
> +	/* set up IPGR */
> +	writel((EMAC_MAC_IPGR_IPG1 << 8) | EMAC_MAC_IPGR_IPG2,
> +		db->membase + EMAC_MAC_IPGR_REG);
> +
> +	/* set up Collison window */
> +	writel((EMAC_MAC_CLRT_COLLISION_WINDOW << 8) | EMAC_MAC_CLRT_RM,
> +		db->membase + EMAC_MAC_CLRT_REG);
> +
> +	/* set up Max Frame Length */
> +	writel(WEMAC_MAX_FRAME_LEN,
> +		db->membase + EMAC_MAC_MAXF_REG);
> +
> +	return 0;
> +}
> +
> +unsigned int wemac_powerup(struct net_device *ndev)
> +{
> +	struct wemac_board_info *db =3D netdev_priv(ndev);
> +	unsigned int reg_val;
> +
> +	/* initial EMAC */
> +	/* flush RX FIFO */
> +	reg_val =3D readl(db->membase + EMAC_RX_CTL_REG);
> +	reg_val |=3D 0x8;
> +	writel(reg_val, db->membase + EMAC_RX_CTL_REG);
> +	udelay(1);
> +
> +	/* initial MAC */
> +	/* soft reset MAC */
> +	reg_val =3D readl(db->membase + EMAC_MAC_CTL0_REG);
> +	reg_val &=3D ~EMAC_MAC_CTL0_SOFT_RESET;
> +	writel(reg_val, db->membase + EMAC_MAC_CTL0_REG);
> +
> +	/* set MII clock */
> +	reg_val =3D readl(db->membase + EMAC_MAC_MCFG_REG);
> +	reg_val &=3D (~(0xf << 2));
> +	reg_val |=3D (0xD << 2);
> +	writel(reg_val, db->membase + EMAC_MAC_MCFG_REG);
> +
> +	/* clear RX counter */
> +	writel(0x0, db->membase + EMAC_RX_FBC_REG);
> +
> +	/* disable all interrupt and clear interrupt status */
> +	writel(0, db->membase + EMAC_INT_CTL_REG);
> +	reg_val =3D readl(db->membase + EMAC_INT_STA_REG);
> +	writel(reg_val, db->membase + EMAC_INT_STA_REG);
> +
> +	udelay(1);
> +
> +	/* set up EMAC */
> +	emac_setup(ndev);
> +
> +	/* set mac_address to chip */
> +	writel(ndev->dev_addr[0] << 16 | ndev->dev_addr[1] << 8 | ndev->
> +	       dev_addr[2], db->membase + EMAC_MAC_A1_REG);
> +	writel(ndev->dev_addr[3] << 16 | ndev->dev_addr[4] << 8 | ndev->
> +	       dev_addr[5], db->membase + EMAC_MAC_A0_REG);
> +
> +	mdelay(1);
> +
> +	return 1;
> +}
> +
> +static void wemac_poll_work(struct work_struct *w)
> +{
> +	struct delayed_work *dw =3D container_of(w, struct delayed_work, wo=
rk);
> +	struct wemac_board_info *db =3D container_of(dw,
> +						struct wemac_board_info,
> +						phy_poll);
> +	struct net_device *ndev =3D db->ndev;
> +
> +	mii_check_media(&db->mii, netif_msg_link(db), 0);
> +
> +	if (netif_running(ndev))
> +		wemac_schedule_poll(db);
> +}
> +
> +static int wemac_set_mac_address(struct net_device *dev, void *p)
> +{
> +	struct sockaddr *addr =3D p;
> +	struct wemac_board_info *db =3D netdev_priv(dev);
> +
> +	if (netif_running(dev))
> +		return -EBUSY;
> +
> +	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
> +
> +	writel(dev->dev_addr[0] << 16 | dev->dev_addr[1] << 8 | dev->
> +	       dev_addr[2], db->membase + EMAC_MAC_A1_REG);
> +	writel(dev->dev_addr[3] << 16 | dev->dev_addr[4] << 8 | dev->
> +	       dev_addr[5], db->membase + EMAC_MAC_A0_REG);
> +
> +	return 0;
> +}
> +
> +/* Initialize wemac board */
> +static void wemac_init_wemac(struct net_device *dev)
> +{
> +	struct wemac_board_info *db =3D netdev_priv(dev);
> +	unsigned int phy_reg;
> +	unsigned int reg_val;
> +
> +	if (gpio_is_valid(db->power_gpio))
> +		gpio_set_value(db->power_gpio, 1);
> +
> +	/* PHY POWER UP */
> +	phy_reg =3D wemac_phy_read(dev, WEMAC_PHY, 0);
> +	wemac_phy_write(dev, WEMAC_PHY, 0, phy_reg & (~(1 << 11)));
> +	mdelay(1);
> +
> +	phy_reg =3D wemac_phy_read(dev, WEMAC_PHY, 0);
> +
> +	/* set EMAC SPEED, depend on PHY  */
> +	reg_val =3D readl(db->membase + EMAC_MAC_SUPP_REG);
> +	reg_val &=3D (~(0x1 << 8));
> +	reg_val |=3D (((phy_reg & (1 << 13)) >> 13) << 8);
> +	writel(reg_val, db->membase + EMAC_MAC_SUPP_REG);
> +
> +	/* set duplex depend on phy */
> +	reg_val =3D readl(db->membase + EMAC_MAC_CTL1_REG);
> +	reg_val &=3D (~(0x1 << 0));
> +	reg_val |=3D (((phy_reg & (1 << 8)) >> 8) << 0);
> +	writel(reg_val, db->membase + EMAC_MAC_CTL1_REG);
> +
> +	/* enable RX/TX */
> +	reg_val =3D readl(db->membase + EMAC_CTL_REG);
> +	writel(reg_val | EMAC_CTL_RESET | EMAC_CTL_TX_EN | EMAC_CTL_RX_EN,
> +		db->membase + EMAC_CTL_REG);
> +
> +	/* enable RX/TX0/RX Hlevel interrup */
> +	reg_val =3D readl(db->membase + EMAC_INT_CTL_REG);
> +	reg_val |=3D (0xf << 0) | (0x01 << 8);
> +	writel(reg_val, db->membase + EMAC_INT_CTL_REG);
> +
> +	/* Init Driver variable */
> +	db->tx_fifo_stat =3D 0;
> +	dev->trans_start =3D 0;

I do not think this is required you are supposed to update this field o=
nly in=20
the receive path.

> +}
> +
> +/* Our watchdog timed out. Called by the networking layer */
> +static void wemac_timeout(struct net_device *dev)
> +{
> +	struct wemac_board_info *db =3D netdev_priv(dev);
> +	unsigned long flags;
> +
> +	if (netif_msg_timer(db))
> +		dev_err(db->dev, "tx time out.\n");
> +
> +	/* Save previous register address */
> +	spin_lock_irqsave(&db->lock, flags);
> +
> +	netif_stop_queue(dev);
> +	wemac_reset(db);
> +	wemac_init_wemac(dev);
> +	/* We can accept TX packets again */
> +	dev->trans_start =3D jiffies;
> +	netif_wake_queue(dev);
> +
> +	/* Restore previous register address */
> +	spin_unlock_irqrestore(&db->lock, flags);
> +}
> +
> +/* Hardware start transmission.
> + * Send a packet to media from the upper layer.
> + */
> +static int wemac_start_xmit(struct sk_buff *skb, struct net_device *=
dev)
> +{
> +	struct wemac_board_info *db =3D netdev_priv(dev);
> +	unsigned long channel;
> +	unsigned long flags;
> +
> +	channel =3D db->tx_fifo_stat & 3;
> +	if (channel =3D=3D 3)
> +		return 1;

start_xmit expects standardized return values such as NETDEV_TX_BUSY an=
d=20
NETDEV_TX_COMPLETE, please use them.

> +
> +	channel =3D (channel =3D=3D 1 ? 1 : 0);
> +
> +	spin_lock_irqsave(&db->lock, flags);
> +
> +	writel(channel, db->membase + EMAC_TX_INS_REG);
> +
> +	wemac_outblk_32bit(db->membase + EMAC_TX_IO_DATA_REG,
> +			skb->data, skb->len);
> +	dev->stats.tx_bytes +=3D skb->len;
> +
> +	db->tx_fifo_stat |=3D 1 << channel;
> +	/* TX control: First packet immediately send, second packet queue *=
/
> +	if (channel =3D=3D 0) {
> +		/* set TX len */
> +		writel(skb->len, db->membase + EMAC_TX_PL0_REG);
> +		/* start translate from fifo to phy */
> +		writel(readl(db->membase + EMAC_TX_CTL0_REG) | 1,
> +		       db->membase + EMAC_TX_CTL0_REG);

Do not you need some write barrier here to ensure your descriptor addre=
ss and=20
control are properly written before the EMAC will see these?

> +
> +		/* save the time stamp */
> +		dev->trans_start =3D jiffies;
> +	} else if (channel =3D=3D 1) {
> +		/* set TX len */
> +		writel(skb->len, db->membase + EMAC_TX_PL1_REG);
> +		/* start translate from fifo to phy */
> +		writel(readl(db->membase + EMAC_TX_CTL1_REG) | 1,
> +		       db->membase + EMAC_TX_CTL1_REG);
> +
> +		/* save the time stamp */
> +		dev->trans_start =3D jiffies;
> +	}
> +
> +	if ((db->tx_fifo_stat & 3) =3D=3D 3) {
> +		/* Second packet */
> +		netif_stop_queue(dev);

Why is that required? Does that mean that your EMAC can only transmit o=
ne=20
packet at a time?

> +	}
> +
> +	spin_unlock_irqrestore(&db->lock, flags);
> +
> +	/* free this SKB */
> +	dev_kfree_skb(skb);
> +
> +	return 0;
> +}
> +
> +/* WEMAC interrupt handler
> + * receive the packet to upper layer, free the transmitted packet
> + */
> +static void wemac_tx_done(struct net_device *dev, struct wemac_board=
_info
> *db, +			  unsigned int tx_status)
> +{
> +	/* One packet sent complete */
> +	db->tx_fifo_stat &=3D ~(tx_status & 3);
> +	if (3 =3D=3D (tx_status & 3))
> +		dev->stats.tx_packets +=3D 2;
> +	else
> +		dev->stats.tx_packets++;
> +
> +	if (netif_msg_tx_done(db))
> +		dev_dbg(db->dev, "tx done, NSR %02x\n", tx_status);
> +
> +	netif_wake_queue(dev);

Why is that also required? According to your start_xmit function you sh=
ould do=20
this only when you have transmitted 2 packets no?

[snip]

> +
> +		reg_val =3D readl(db->membase + EMAC_RX_IO_DATA_REG);
> +		if (netif_msg_rx_status(db))
> +			dev_dbg(db->dev, "receive header: %x\n", reg_val);
> +		if (reg_val !=3D 0x0143414d) {

Where is that magic value coming from?
--=20
=46lorian
