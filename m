From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH 3/3] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Fri, 23 Oct 2015 16:20:37 +0100
Message-ID: <yw1xa8r9fw6y.fsf@unicorn.mansr.com>
References: <1445522558-5808-1-git-send-email-mans@mansr.com>
	<1445522558-5808-3-git-send-email-mans@mansr.com>
	<56297FF9.4070801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56297FF9.4070801@gmail.com> (Florian Fainelli's message of "Thu,
	22 Oct 2015 17:31:53 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46lorian Fainelli <f.fainelli@gmail.com> writes:

> On 22/10/15 07:02, Mans Rullgard wrote:
>> This adds a driver for the Aurora VLSI NB8800 Ethernet controller.
>> It is an almost complete rewrite of a driver originally found in
>> a Sigma Designs 2.6.22 tree.
>
> Some reviews here and there, mostly related to how you use the PHY li=
brary.

Thanks.

>> +	nb8800_tx_dma_start(dev, next);
>> +
>> +	if (!skb->xmit_more && !timer_pending(&priv->tx_reclaim_timer))
>> +		mod_timer(&priv->tx_reclaim_timer, jiffies + HZ / 20);
>
> You do not have a TX completion interrupt? Using a timer to reclaim T=
X
> buffers is really not great for latency.

There is an interrupt, but dev_kfree_skb() can't be called from
interrupt context, and running a tasklet for each packet has too much
overhead.  Someone suggested I use this approach.  If there's a better
way, I'm all ears.

>> +
>> +	if (atomic_read(&priv->tx_free) <=3D NB8800_DESC_LOW)
>> +		netif_stop_queue(dev);
>> +
>> +	return NETDEV_TX_OK;
>> +}
>> +
>> +static void nb8800_tx_reclaim(unsigned long data)
>> +{
>> +	struct net_device *dev =3D (struct net_device *)data;
>> +	struct nb8800_priv *priv =3D netdev_priv(dev);
>> +	int packets =3D 0, bytes =3D 0;
>> +	int reclaimed =3D 0;
>> +	int dirty, limit;
>> +
>> +	dirty =3D xchg(&priv->tx_dirty, -1);
>> +	if (dirty < 0)
>> +		return;
>> +
>> +	limit =3D priv->tx_reclaim_limit;
>> +	if (dirty =3D=3D limit)
>> +		goto end;
>> +
>> +	while (dirty !=3D limit) {
>> +		struct nb8800_dma_desc *tx =3D &priv->tx_descs[dirty];
>> +		struct tx_buf *tx_buf =3D &priv->tx_bufs[dirty];
>> +		struct sk_buff *skb =3D tx_buf->skb;
>> +		struct tx_skb_data *skb_data =3D (struct tx_skb_data *)skb->cb;
>> +		int frags =3D tx_buf->frags;
>> +
>> +		packets++;
>> +		bytes +=3D skb->len;
>> +
>> +		dma_unmap_single(&dev->dev, skb_data->dma_addr,
>> +				 skb_data->dma_len, DMA_TO_DEVICE);
>> +		dev_kfree_skb(skb);
>> +
>> +		tx->report =3D 0;
>> +		tx_buf->skb =3D NULL;
>> +		tx_buf->frags =3D 0;
>> +
>> +		dirty =3D (dirty + frags) & (TX_DESC_COUNT - 1);
>> +		reclaimed +=3D frags;
>> +	}
>> +
>> +	priv->stats.tx_packets +=3D packets;
>> +	priv->stats.tx_bytes +=3D bytes;
>> +
>> +	smp_mb__before_atomic();
>> +	atomic_add(reclaimed, &priv->tx_free);
>> +
>> +	netif_wake_queue(dev);
>
> You can only wake up your queue if you have successfully reclaimed
> transmitted buffers, otherwise this is giving false information to th=
e
> stack that there is room to push more packets.

The code is correct, if a bit unclear.  I'll clean it up so it's obviou=
s.

>> +static void nb8800_mac_config(struct net_device *dev)
>> +{
>> +	struct nb8800_priv *priv =3D netdev_priv(dev);
>> +
>> +	if (priv->duplex)
>> +		nb8800_clear_bits(b, priv, NB8800_MAC_MODE, HALF_DUPLEX);
>> +	else
>> +		nb8800_set_bits(b, priv, NB8800_MAC_MODE, HALF_DUPLEX);
>> +
>> +	if (priv->speed =3D=3D SPEED_1000) {
>> +		nb8800_set_bits(b, priv, NB8800_MAC_MODE,
>> +				RGMII_MODE | GMAC_MODE);
>> +		nb8800_writeb(priv, NB8800_IC_THRESHOLD, 3);
>
> What is the IC_THRESHOLD value for? Is this some form of interrupt
> coalescing? If so, there is a proper ethtool interface to configure t=
hat.

It has something to do with some clocks, and this value is quite
possibly wrong; it's what the original driver did.  I'll do some tests.

>> +		nb8800_writeb(priv, NB8800_SLOT_TIME, 255);
>> +	} else {
>> +		nb8800_clear_bits(b, priv, NB8800_MAC_MODE,
>> +				  RGMII_MODE | GMAC_MODE);
>> +		nb8800_writeb(priv, NB8800_IC_THRESHOLD, 1);
>> +		nb8800_writeb(priv, NB8800_SLOT_TIME, 127);
>
> What about if you link at 10Mbits/sec, would the slot time value stil=
l
> make sense here?

The documentation says the exact meaning on this register is different
between gigabit and 10/100, so using the same value for 10 and 100 make=
s
sense.  Again, the values used here are from the original driver.

>> +static void nb8800_set_rx_mode(struct net_device *dev)
>> +{
>> +	struct nb8800_priv *priv =3D netdev_priv(dev);
>> +	struct netdev_hw_addr *ha;
>> +	int af_en;
>> +
>> +	if ((dev->flags & (IFF_PROMISC | IFF_ALLMULTI)) ||
>> +	    netdev_mc_count(dev) > 64)
>
> 64, that's pretty generous for a perfect match filter, nice.

That's bogus; I forgot to delete it.  The hardware uses a 64-entry hash
table, and whoever wrote the old driver apparently didn't understand ho=
w
it works.

>> +static void nb8800_tangox_init(struct net_device *dev)
>> +{
>> +	struct nb8800_priv *priv =3D netdev_priv(dev);
>> +	u32 val;
>> +
>> +	val =3D nb8800_readb(priv, NB8800_TANGOX_PAD_MODE) & 0x78;
>> +	if (priv->phydev->supported & PHY_1000BT_FEATURES)
>> +		val |=3D 1;
>> +	nb8800_writeb(priv, NB8800_TANGOX_PAD_MODE, val);
>
> Is this possibly a RGMII delay setting? If so, you need to look at
> phydev->interface, not whether Gigabit is supported or not.

This does something to the configuration of the external pins, the
documentation is vague about what.

>> +	phydev =3D phy_find_first(bus);
>> +	if (!phydev || phy_read(phydev, MII_BMSR) <=3D 0) {
>
> What is this additional MII_MBSR read used for?

On one of my boards, phylib misdetects a phy on the second ethernet por=
t
even though there is none.  Perhaps I should revisit that problem and
look for a better solution.

>> +static int nb8800_remove(struct platform_device *pdev)
>> +{
>> +	struct net_device *ndev =3D platform_get_drvdata(pdev);
>> +	struct nb8800_priv *priv =3D netdev_priv(ndev);
>> +
>> +	unregister_netdev(ndev);
>> +	free_irq(ndev->irq, ndev);
>> +
>> +	phy_detach(priv->phydev);
>> +	mdiobus_unregister(priv->mii_bus);
>> +
>> +	clk_disable_unprepare(priv->clk);
>> +
>> +	nb8800_dma_free(ndev);
>> +	free_netdev(ndev);
>
> Should not there be a tangox specific callback here to de-initialize =
the HW?

There's nothing specific to do for this hardware.  It's easy enough to
add a callback should any future hardware require it.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
