From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 3/3] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Fri, 23 Oct 2015 10:36:00 -0700
Message-ID: <562A7000.2080502@gmail.com>
References: <1445522558-5808-1-git-send-email-mans@mansr.com>	<1445522558-5808-3-git-send-email-mans@mansr.com>	<56297FF9.4070801@gmail.com> <yw1xa8r9fw6y.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: =?UTF-8?B?TcOlbnMgUnVsbGfDpXJk?= <mans@mansr.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <yw1xa8r9fw6y.fsf@unicorn.mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23/10/15 08:20, M=C3=A5ns Rullg=C3=A5rd wrote:
> Florian Fainelli <f.fainelli@gmail.com> writes:
>=20
>> On 22/10/15 07:02, Mans Rullgard wrote:
>>> This adds a driver for the Aurora VLSI NB8800 Ethernet controller.
>>> It is an almost complete rewrite of a driver originally found in
>>> a Sigma Designs 2.6.22 tree.
>>
>> Some reviews here and there, mostly related to how you use the PHY l=
ibrary.
>=20
> Thanks.
>=20
>>> +	nb8800_tx_dma_start(dev, next);
>>> +
>>> +	if (!skb->xmit_more && !timer_pending(&priv->tx_reclaim_timer))
>>> +		mod_timer(&priv->tx_reclaim_timer, jiffies + HZ / 20);
>>
>> You do not have a TX completion interrupt? Using a timer to reclaim =
TX
>> buffers is really not great for latency.
>=20
> There is an interrupt, but dev_kfree_skb() can't be called from
> interrupt context, and running a tasklet for each packet has too much
> overhead.  Someone suggested I use this approach.  If there's a bette=
r
> way, I'm all ears.

But dev_kfree_skb_irq() works in interrupt context. Typically, what you
would do, depending on your number or RX/TX queue is reclaim transmitte=
d
buffers in NAPI (softirq) context.

In your case, what you could do is use the RX or TX interrupt as an
indication to schedule your napi poll routine and you would cleanup TX
buffers first (cheap, and makes room for RX packets) and if there are R=
X
packets to process, process them. No need for the tasklet then.

>=20
>>> +
>>> +	if (atomic_read(&priv->tx_free) <=3D NB8800_DESC_LOW)
>>> +		netif_stop_queue(dev);
>>> +
>>> +	return NETDEV_TX_OK;
>>> +}
>>> +
>>> +static void nb8800_tx_reclaim(unsigned long data)
>>> +{
>>> +	struct net_device *dev =3D (struct net_device *)data;
>>> +	struct nb8800_priv *priv =3D netdev_priv(dev);
>>> +	int packets =3D 0, bytes =3D 0;
>>> +	int reclaimed =3D 0;
>>> +	int dirty, limit;
>>> +
>>> +	dirty =3D xchg(&priv->tx_dirty, -1);
>>> +	if (dirty < 0)
>>> +		return;
>>> +
>>> +	limit =3D priv->tx_reclaim_limit;
>>> +	if (dirty =3D=3D limit)
>>> +		goto end;
>>> +
>>> +	while (dirty !=3D limit) {
>>> +		struct nb8800_dma_desc *tx =3D &priv->tx_descs[dirty];
>>> +		struct tx_buf *tx_buf =3D &priv->tx_bufs[dirty];
>>> +		struct sk_buff *skb =3D tx_buf->skb;
>>> +		struct tx_skb_data *skb_data =3D (struct tx_skb_data *)skb->cb;
>>> +		int frags =3D tx_buf->frags;
>>> +
>>> +		packets++;
>>> +		bytes +=3D skb->len;
>>> +
>>> +		dma_unmap_single(&dev->dev, skb_data->dma_addr,
>>> +				 skb_data->dma_len, DMA_TO_DEVICE);
>>> +		dev_kfree_skb(skb);
>>> +
>>> +		tx->report =3D 0;
>>> +		tx_buf->skb =3D NULL;
>>> +		tx_buf->frags =3D 0;
>>> +
>>> +		dirty =3D (dirty + frags) & (TX_DESC_COUNT - 1);
>>> +		reclaimed +=3D frags;
>>> +	}
>>> +
>>> +	priv->stats.tx_packets +=3D packets;
>>> +	priv->stats.tx_bytes +=3D bytes;
>>> +
>>> +	smp_mb__before_atomic();
>>> +	atomic_add(reclaimed, &priv->tx_free);
>>> +
>>> +	netif_wake_queue(dev);
>>
>> You can only wake up your queue if you have successfully reclaimed
>> transmitted buffers, otherwise this is giving false information to t=
he
>> stack that there is room to push more packets.
>=20
> The code is correct, if a bit unclear.  I'll clean it up so it's obvi=
ous.

That's fine as-is, I missed the goto end at the beginning.

>=20
>>> +static void nb8800_mac_config(struct net_device *dev)
>>> +{
>>> +	struct nb8800_priv *priv =3D netdev_priv(dev);
>>> +
>>> +	if (priv->duplex)
>>> +		nb8800_clear_bits(b, priv, NB8800_MAC_MODE, HALF_DUPLEX);
>>> +	else
>>> +		nb8800_set_bits(b, priv, NB8800_MAC_MODE, HALF_DUPLEX);
>>> +
>>> +	if (priv->speed =3D=3D SPEED_1000) {
>>> +		nb8800_set_bits(b, priv, NB8800_MAC_MODE,
>>> +				RGMII_MODE | GMAC_MODE);
>>> +		nb8800_writeb(priv, NB8800_IC_THRESHOLD, 3);
>>
>> What is the IC_THRESHOLD value for? Is this some form of interrupt
>> coalescing? If so, there is a proper ethtool interface to configure =
that.
>=20
> It has something to do with some clocks, and this value is quite
> possibly wrong; it's what the original driver did.  I'll do some test=
s.
>=20
>>> +		nb8800_writeb(priv, NB8800_SLOT_TIME, 255);
>>> +	} else {
>>> +		nb8800_clear_bits(b, priv, NB8800_MAC_MODE,
>>> +				  RGMII_MODE | GMAC_MODE);
>>> +		nb8800_writeb(priv, NB8800_IC_THRESHOLD, 1);
>>> +		nb8800_writeb(priv, NB8800_SLOT_TIME, 127);
>>
>> What about if you link at 10Mbits/sec, would the slot time value sti=
ll
>> make sense here?
>=20
> The documentation says the exact meaning on this register is differen=
t
> between gigabit and 10/100, so using the same value for 10 and 100 ma=
kes
> sense.  Again, the values used here are from the original driver.

=46air enough.

>=20
>>> +static void nb8800_set_rx_mode(struct net_device *dev)
>>> +{
>>> +	struct nb8800_priv *priv =3D netdev_priv(dev);
>>> +	struct netdev_hw_addr *ha;
>>> +	int af_en;
>>> +
>>> +	if ((dev->flags & (IFF_PROMISC | IFF_ALLMULTI)) ||
>>> +	    netdev_mc_count(dev) > 64)
>>
>> 64, that's pretty generous for a perfect match filter, nice.
>=20
> That's bogus; I forgot to delete it.  The hardware uses a 64-entry ha=
sh
> table, and whoever wrote the old driver apparently didn't understand =
how
> it works.

Might be best to put the interface in promiscuous mode until you have
proper multicast support. Since this is for a Set-Top box chip, having
proper multicast support still seems like something highly desirable.

>=20
>>> +	phydev =3D phy_find_first(bus);
>>> +	if (!phydev || phy_read(phydev, MII_BMSR) <=3D 0) {
>>
>> What is this additional MII_MBSR read used for?
>=20
> On one of my boards, phylib misdetects a phy on the second ethernet p=
ort
> even though there is none.  Perhaps I should revisit that problem and
> look for a better solution.

I think that would be best, if you are currently using the Generic PHY
driver, consider writing a specific driver which would take care of
quirky behavior.
--=20
=46lorian
