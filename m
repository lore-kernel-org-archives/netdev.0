From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH 1/5] net: Add davicom wemac ethernet driver found on Allwinner
 A10 SoC's
Date: Tue, 19 Mar 2013 19:39:07 +0100
Message-ID: <5148B0CB.4020605@free-electrons.com>
References: <1363380605-6577-1-git-send-email-maxime.ripard@free-electrons.com> <1363380605-6577-2-git-send-email-maxime.ripard@free-electrons.com> <201303161541.37341.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-kernel@vger.kernel.org,
	Rob Herring <rob.herring@calxeda.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Landley <rob@landley.net>, sunny@allwinnertech.com,
	shuge@allwinnertech.com, Stefan Roese <sr@denx.de>,
	kevin@allwinnertech.com
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201303161541.37341.florian@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

Le 16/03/2013 15:41, Florian Fainelli a =E9crit :
> Hello Maxime, Stefan,
>=20
> Please find below some comments regarding your PHY implementation in =
the driver=20
> as well as the transmit and transmit completion routines.

Stefan implemented the changes you asked about the PHY, it will be in
the next iteration of this patchset.

On a general basis, we don't really know much about this chip, since
we're working without any datasheet on this.

>=20
>> +#define WEMAC_PHY		0x100	/* PHY address 0x01 */
>=20
> This should be made configurable if possible.

Ok

>> +	unsigned		power_gpio;
>=20
> you could make this an int, so that you use gpio_is_valid() on this o=
ne.

Alexander Shiyan suggested to move to the regulator API, so I guess we
will just remove that variable.

>> +
>> +static void wemac_dumpblk_32bit(void __iomem *reg, int count)
>> +{
>> +	int i;
>> +	int tmp;
>> +
>> +	for (i =3D 0; i < (round_up(count, 4) / 4); i++)
>> +		tmp =3D readl(reg);
>> +}
>=20
> This could probably be removed, tmp is a write only location, did you=
 remove=20
> the variable printing that came along this?

Hmmm, it looks that way yes. I'll remove it

>> +
>> +static int wemac_ioctl(struct net_device *dev, struct ifreq *req, i=
nt cmd)
>> +{
>> +	struct wemac_board_info *dm =3D to_wemac_board(dev);
>> +
>> +	if (!netif_running(dev))
>> +		return -EINVAL;
>> +
>> +	return generic_mii_ioctl(&dm->mii, if_mii(req), cmd, NULL);
>> +}
>> +
>> +/* ethtool ops */
>> +static void wemac_get_drvinfo(struct net_device *dev,
>> +			      struct ethtool_drvinfo *info)
>> +{
>> +	strcpy(info->driver, DRV_NAME);
>> +	strcpy(info->version, DRV_VERSION);
>=20
> You should use strlcpy() here to ensure null-termination, and you sho=
uld also=20
> fill in the bus_info member of struct ethtool_drvinfo.

ok, will do.

>> +	/* Init Driver variable */
>> +	db->tx_fifo_stat =3D 0;
>> +	dev->trans_start =3D 0;
>=20
> I do not think this is required you are supposed to update this field=
 only in=20
> the receive path.

Ok, I'll remove that part.

>> +
>> +	channel =3D (channel =3D=3D 1 ? 1 : 0);
>> +
>> +	spin_lock_irqsave(&db->lock, flags);
>> +
>> +	writel(channel, db->membase + EMAC_TX_INS_REG);
>> +
>> +	wemac_outblk_32bit(db->membase + EMAC_TX_IO_DATA_REG,
>> +			skb->data, skb->len);
>> +	dev->stats.tx_bytes +=3D skb->len;
>> +
>> +	db->tx_fifo_stat |=3D 1 << channel;
>> +	/* TX control: First packet immediately send, second packet queue =
*/
>> +	if (channel =3D=3D 0) {
>> +		/* set TX len */
>> +		writel(skb->len, db->membase + EMAC_TX_PL0_REG);
>> +		/* start translate from fifo to phy */
>> +		writel(readl(db->membase + EMAC_TX_CTL0_REG) | 1,
>> +		       db->membase + EMAC_TX_CTL0_REG);
>=20
> Do not you need some write barrier here to ensure your descriptor add=
ress and=20
> control are properly written before the EMAC will see these?

writel has a write barrier, so it shouldn't be a problem I guess.

>=20
>> +
>> +		/* save the time stamp */
>> +		dev->trans_start =3D jiffies;
>> +	} else if (channel =3D=3D 1) {
>> +		/* set TX len */
>> +		writel(skb->len, db->membase + EMAC_TX_PL1_REG);
>> +		/* start translate from fifo to phy */
>> +		writel(readl(db->membase + EMAC_TX_CTL1_REG) | 1,
>> +		       db->membase + EMAC_TX_CTL1_REG);
>> +
>> +		/* save the time stamp */
>> +		dev->trans_start =3D jiffies;
>> +	}
>> +
>> +	if ((db->tx_fifo_stat & 3) =3D=3D 3) {
>> +		/* Second packet */
>> +		netif_stop_queue(dev);
>=20
> Why is that required? Does that mean that your EMAC can only transmit=
 one=20
> packet at a time?

The original driver was working that way, so the hardware can probably
send several packet at a time, but we don't really know how...

>> +static void wemac_tx_done(struct net_device *dev, struct wemac_boar=
d_info
>> *db, +			  unsigned int tx_status)
>> +{
>> +	/* One packet sent complete */
>> +	db->tx_fifo_stat &=3D ~(tx_status & 3);
>> +	if (3 =3D=3D (tx_status & 3))
>> +		dev->stats.tx_packets +=3D 2;
>> +	else
>> +		dev->stats.tx_packets++;
>> +
>> +	if (netif_msg_tx_done(db))
>> +		dev_dbg(db->dev, "tx done, NSR %02x\n", tx_status);
>> +
>> +	netif_wake_queue(dev);
>=20
> Why is that also required? According to your start_xmit function you =
should do=20
> this only when you have transmitted 2 packets no?

I don't know, maybe the code here is more about always having a buffer
of one packet at any point in time. With the current code, when you hav=
e
to send packets, it will:
  - send the packet 1
  - stop the queue
  - wait for the packet 1 to be sent
  - once packet 1 is sent, restart the queue, so that it can load a
    packet 3
  - start transmitting packet 2 if there's one, and loop, or just wait
    for it

Which would make sense, and for this, it looks to me that you should
always restart the queue, no matter what the number of packets to send =
was.

>> +
>> +		reg_val =3D readl(db->membase + EMAC_RX_IO_DATA_REG);
>> +		if (netif_msg_rx_status(db))
>> +			dev_dbg(db->dev, "receive header: %x\n", reg_val);
>> +		if (reg_val !=3D 0x0143414d) {
>=20
> Where is that magic value coming from?

The original code.

Maybe I should define it to something like "UNDOCUMENTED_VOODOO_MAGIC1"=
,
or something like that, but I have no idea what it relates to in the
hardware :S

Thanks for your review,
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
