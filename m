From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/5] ethernet: add sun8i-emac driver
Date: Sun, 12 Jun 2016 10:46:35 -0700
Message-ID: <575D9FFB.1@gmail.com>
References: <1464947790-22991-1-git-send-email-clabbe.montjoie@gmail.com>
 <1464947790-22991-2-git-send-email-clabbe.montjoie@gmail.com>
 <5755C00B.2040203@gmail.com> <20160609094402.GA14315@Red>
Reply-To: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
 ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
 maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-sunxi+bncBCH67JWTV4DBB7V7625AKGQEXBK66YI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20160609094402.GA14315@Red>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

Le 09/06/2016 02:44, LABBE Corentin a =C3=A9crit :
> Hello
>=20
> I agree to all your comments, but for some I have additionnal questions
>=20
> On Mon, Jun 06, 2016 at 11:25:15AM -0700, Florian Fainelli wrote:
>> On 06/03/2016 02:56 AM, LABBE Corentin wrote:
>>
>> [snip]
>>
>>> +
>>> +/* The datasheet said that each descriptor can transfers up to 4096byt=
es
>>> + * But latter, a register documentation reduce that value to 2048
>>> + * Anyway using 2048 cause strange behaviours and even BSP driver use =
2047
>>> + */
>>> +#define DESC_BUF_MAX 2044
>>> +#if (DESC_BUF_MAX < (ETH_FRAME_LEN + 4))
>>> +#error "DESC_BUF_MAX must be set at minimum to ETH_FRAME_LEN + 4"
>>> +#endif
>>
>> You can probably drop that, it would not make much sense to enable
>> fragments and a buffer size smaller than ETH_FRAME_LEN + ETH_FCS_LEN any=
way.
>>
>=20
> I has added this test for preventing someone who want to "optimize" DESC_=
BUF_MAX to doing mistake.
> But I agree that it is of low use.

It's actually dangerous, and if you don't make sure that the value is
properly rounded to whatever the DMA controller's alignment should be,
performance could be terribel too.

>=20
>>> +/* Return the number of contiguous free descriptors
>>> + * starting from tx_slot
>>> + */
>>> +static int rb_tx_numfreedesc(struct net_device *ndev)
>>> +{
>>> +	struct sun8i_emac_priv *priv =3D netdev_priv(ndev);
>>> +
>>> +	if (priv->tx_slot < priv->tx_dirty)
>>> +		return priv->tx_dirty - priv->tx_slot;
>>
>> Does this work with if tx_dirty wraps around?
>>
>=20
> The tx_dirty cannot wrap since I always keep an empty slot. (tx_slot cann=
ot go equal or after tx_dirty)

OK, fair enough.

>=20
>>> +/* Grab a frame into a skb from descriptor number i */
>>> +static int sun8i_emac_rx_from_ddesc(struct net_device *ndev, int i)
>>> +{
>>> +	struct sk_buff *skb;
>>> +	struct sun8i_emac_priv *priv =3D netdev_priv(ndev);
>>> +	struct dma_desc *ddesc =3D priv->dd_rx + i;
>>> +	int frame_len;
>>> +	int crc_checked =3D 0;
>>> +
>>> +	if (ndev->features & NETIF_F_RXCSUM)
>>> +		crc_checked =3D 1;
>>
>> Assuming CRC here refers to the Ethernet frame's FCS, then this is
>> absolutely not how NETIF_F_RXCSUM works. NETIF_F_RXCSUM is about your
>> Ethernet adapter supporting L3/L4 checksum offloads, while the Ethernet
>> FCS is pretty much mandatory for the frame to be properly received in
>> the first place. Can you clarify which way it is?
>>
>=20
> No CRC here is RXCSUM. I understand the misnaming.
> I will rename the variable to rxcsum_done.

Thanks

>=20
>>> +
>>> +	priv->ndev->stats.rx_packets++;
>>> +	priv->ndev->stats.rx_bytes +=3D frame_len;
>>> +	priv->rx_sk[i] =3D NULL;
>>> +
>>> +	/* this frame is not the last */
>>> +	if ((ddesc->status & BIT(8)) =3D=3D 0) {
>>> +		dev_warn(priv->dev, "Multi frame not implemented currlen=3D%d\n",
>>> +			 frame_len);
>>> +	}
>>> +
>>> +	sun8i_emac_rx_sk(ndev, i);
>>> +
>>> +	netif_rx(skb);
>>
>> netif_receive_skb() at the very least, or if you implement NAPI, like
>> you shoud napi_gro_receive().
>>
>=20
> netif_receive_skb documentation say
> "This function may only be called from softirq context and interrupts sho=
uld be enabled."
> but the calling functions is in hardirq context.

Well, yes, because you are not implementing NAPI, while you should, you
execute in hard interrupt context. Once you move to NAPI, you can and
should use netif_receive_skb().

>=20
>>> +	return 0;
>>> +}
>>> +
>>> +/* Cycle over RX DMA descriptors for finding frame to receive
>>> + */
>>> +static int sun8i_emac_receive_all(struct net_device *ndev)
>>> +{
>>> +	struct sun8i_emac_priv *priv =3D netdev_priv(ndev);
>>> +	struct dma_desc *ddesc;
>>> +
>>> +	ddesc =3D priv->dd_rx + priv->rx_dirty;
>>> +	while (!(ddesc->status & BIT(31))) {
>>> +		sun8i_emac_rx_from_ddesc(ndev, priv->rx_dirty);
>>> +		rb_inc(&priv->rx_dirty, nbdesc_rx);
>>> +		ddesc =3D priv->dd_rx + priv->rx_dirty;
>>> +	};
>>
>> So, what if we ping flood your device here, is not there a remote chance
>> that we keep the RX interrupt so busy we can't break out of this loop,
>> and we are executing from hard IRQ context, that's bad.
>>
>=20
> I have added a start variable for preventing to do more than a full loop.

Which gets you close to a proper NAPI implementation, good.

>=20
>>> +
>>> +	return 0;
>>> +}
>>> +
>>> +/* iterate over dma_desc for finding completed xmit.
>>> + * Called from interrupt context, so no need to spinlock tx
>>
>> Humm, well it depends if what you are doing here may race with
>> ndo_start_xmit(), and usually it does.
>>
>=20
> I believe that how it is designed it cannot race each over (access the sa=
me descriptor slot) since I keep a free slot between each other.
>=20
>> Also, you should consider completing TX packets in NAPI context (soft
>> IRQ) instead of hard IRQs like here.
>>
>=20
> I wanted to finish this driver the "old" way (with hard IRQ) and implemen=
ting NAPI after as a Kconfig choice.
> Does NAPI is mandatory now ? (or really recommended)
> For resuming my understanding, NAPI is good when expecting high traffic. =
(so my Kconfig idea)
> If you say that NAPI is really preferable, I will do it.

It's not preferable it's just mandatory here, no recent network driver
does not implement it, and it works well for both low and high traffic.

>=20
>>> +	/* last descriptor point back to first one */
>>> +	ddesc--;
>>> +	ddesc->next =3D (u32)priv->dd_rx_phy;
>>
>> So is there a limitation of this hardware that can only do DMA within
>> the first 4GB of the system?
>>
>=20
> Yes, I have added all DMA stuff for handling that after apritzel review.

Is your platform_device's DMA mask properly set then, you don't seem to
be taking any precautions in the driver probe's function to force a
32-bits DMA mask anywhere, should not you?

>=20
>>> +static int sun8i_emac_check_if_running(struct net_device *ndev)
>>> +{
>>> +	if (!netif_running(ndev))
>>> +		return -EBUSY;
>>
>> This does not seem like the intended usage of a
>>
>=20
> I have changed the return code after reading other drivers.
> But could you end your sentence for be sure that the problem is that.

Meant to say that it's not the intended usage of an ethtool_opts::begin
function, those would usually turn on a clock (if the clock was turned
off) in preparation for the real operation to program the HW for instance.

>=20
>>> +
>>> +static int sun8i_emac_remove(struct platform_device *pdev)
>>> +{
>>> +	struct net_device *ndev =3D platform_get_drvdata(pdev);
>>> +
>>> +	unregister_netdev(ndev);
>>> +	platform_set_drvdata(pdev, NULL);
>>
>> Missing unregister_netdevice() here.
>>
>=20
> Does I need to replace unregister_netdev by it ?
> They seems to to the same job.

Missed the unregister_netdev(), everything's fine, my bad.
--=20
Florian

--=20
You received this message because you are subscribed to the Google Groups "=
linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.
