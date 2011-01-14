From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Fri, 14 Jan 2011 13:37:40 +0800
Message-ID: <AANLkTimNekxXpovXOHW1eNvvdzMfLyhOyum44AKMOmDj@mail.gmail.com>
References: <1294919372-1904-1-git-send-email-ratbert.chuang@gmail.com> <1294927387.3044.76.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:47451 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941Ab1ANFiC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 00:38:02 -0500
In-Reply-To: <1294927387.3044.76.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Ben,

On Thu, Jan 13, 2011 at 10:03 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Thu, 2011-01-13 at 19:49 +0800, Po-Yu Chuang wrote:
>> From: Po-Yu Chuang <ratbert@faraday-tech.com>
>>
>> FTMAC100 Ethernet Media Access Controller supports 10/100 Mbps and
>> MII. =C2=A0This driver has been working on some ARM/NDS32 SoC includ=
ing
>> Faraday A320 and Andes AG101.
> [...]
>> +#define USE_NAPI
>
> All new network drivers should use NAPI only, so please remove the
> definition of USE_NAPI and change the conditional code to use NAPI
> always.

OK, fixed.

> [...]
>> + =C2=A0 =C2=A0 struct net_device_stats stats;
>
> There is a net_device_stats structure in the net_device structure; yo=
u
> should normally use that instead of adding another one.

OK, fixed.

> [...]
>> +static int ftmac100_reset(struct ftmac100 *priv)
>> +{
>> + =C2=A0 =C2=A0 struct device *dev =3D &priv->netdev->dev;
>> + =C2=A0 =C2=A0 unsigned long flags;
>> + =C2=A0 =C2=A0 int i;
>> +
>> + =C2=A0 =C2=A0 /* NOTE: reset clears all registers */
>> +
>> + =C2=A0 =C2=A0 spin_lock_irqsave(&priv->hw_lock, flags);
>> + =C2=A0 =C2=A0 iowrite32(FTMAC100_MACCR_SW_RST, priv->base + FTMAC1=
00_OFFSET_MACCR);
>> + =C2=A0 =C2=A0 spin_unlock_irqrestore(&priv->hw_lock, flags);
>> +
>> + =C2=A0 =C2=A0 for (i =3D 0; i < 5; i++) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int maccr;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock_irqsave(&priv-=
>hw_lock, flags);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 maccr =3D ioread32(priv-=
>base + FTMAC100_OFFSET_MACCR);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock_irqrestore(&=
priv->hw_lock, flags);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!(maccr & FTMAC100_M=
ACCR_SW_RST)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0* FTMAC100_MACCR_SW_RST cleared does not indicate
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0* that hardware reset completed (what the f*ck).
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0* We still need to wait for a while.
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 usleep_range(500, 1000);
>
> Sleeping here means this must be running in process context. =C2=A0Bu=
t you
> used spin_lock_irqsave() above which implies you're not sure what the
> context is. =C2=A0One of these must be wrong.
>
> I wonder whether hw_lock is even needed; you seem to acquire and rele=
ase
> it around each PIO (read or write). =C2=A0This should be unnecessary =
since
> each PIO is atomic.

OK, fixed.

> I think you can also get rid of rx_lock; it's only used in the RX dat=
a
> path which is already serialised by NAPI.

OK, fixed.

> [...]
>> + =C2=A0 =C2=A0 netdev->last_rx =3D jiffies;
>
> Don't set last_rx; the networking core takes care of it now.

OK, fixed.

>> + =C2=A0 =C2=A0 priv->stats.rx_packets++;
>> + =C2=A0 =C2=A0 priv->stats.rx_bytes +=3D skb->len;
>
> This should be done earlier, so that these stats include packets that
> are dropped for any reason.

OK, fixed.

> [...]
>> + =C2=A0 =C2=A0 netdev->trans_start =3D jiffies;
>
> Don't set trans_start; the networking core takes care of it now.

OK, fixed.

> [...]
>> + =C2=A0 =C2=A0 priv->descs =3D dma_alloc_coherent(priv->dev,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sizeof(struct ftmac100_d=
escs), &priv->descs_dma_addr,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 GFP_KERNEL | GFP_DMA);
>
> On x86, GFP_DMA means the memory must be within the ISA DMA range
> (< 16 MB). =C2=A0I don't know quite what it means on ARM but it may n=
ot be
> what you want.

On ARM, all 4G address space can be used by DMA (at least for all the
hardwares I have ever used). All memory pages are in DMA zone AFAIK.
I put GFP_DMA here just to be safe if there were any constraints.

By checking drivers in drivers/net/arm/, ep93xx_eth.c also uses this fl=
ag,
so I guess this is acceptable?

> [...]
>> + =C2=A0 =C2=A0 if (status & (FTMAC100_INT_XPKT_OK | FTMAC100_INT_XP=
KT_LOST)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* FTMAC100_INT_XPK=
T_OK:
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* =C2=A0 =C2=A0 =C2=
=A0 packet transmitted to ethernet successfully
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* FTMAC100_INT_XPK=
T_LOST:
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* =C2=A0 =C2=A0 =C2=
=A0packet transmitted to ethernet lost due to late
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* =C2=A0 =C2=A0 =C2=
=A0collision or excessive collision
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ftmac100_tx_complete(pri=
v);
>> + =C2=A0 =C2=A0 }
>
> TX completions should also be handled through NAPI if possible.

OK, I'll study how to do that.

> [...]
>> + =C2=A0 =C2=A0 priv->rx_pointer =3D 0;
>> + =C2=A0 =C2=A0 priv->tx_clean_pointer =3D 0;
>> + =C2=A0 =C2=A0 priv->tx_pointer =3D 0;
>> + =C2=A0 =C2=A0 spin_lock_init(&priv->hw_lock);
>> + =C2=A0 =C2=A0 spin_lock_init(&priv->rx_lock);
>> + =C2=A0 =C2=A0 spin_lock_init(&priv->tx_lock);
>
> These locks should be initialised in your probe function.

OK, fixed.

> [...]
>> + =C2=A0 =C2=A0 unregister_netdev(netdev);
>
> There should be a netif_napi_del() before this.

OK, fixed.

> A general comment: please use netdev_err(), netdev_info() etc. for
> logging. =C2=A0This ensures that both the platform device address and=
 the
> network device name appears in the log messages.

OK, fixed.

Thanks a lot for your detailed review. I'll submit a new version ASAP.

Thanks,
Po-Yu Chuang
