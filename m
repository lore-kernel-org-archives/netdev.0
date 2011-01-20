From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH v3] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Thu, 20 Jan 2011 23:54:35 +0800
Message-ID: <AANLkTikpp3pC4BW-1mb7FvPgggAFL31ZDpoo=FRR57yy@mail.gmail.com>
References: <1295256060-2091-1-git-send-email-ratbert.chuang@gmail.com>
 <1295537418-2057-1-git-send-email-ratbert.chuang@gmail.com> <1295538105.2825.308.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, joe@perches.com, dilinger@queued.net,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295538105.2825.308.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Eric,

On Thu, Jan 20, 2011 at 11:41 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le jeudi 20 janvier 2011 =C3=A0 23:30 +0800, Po-Yu Chuang a =C3=A9cri=
t :
>
>> +static bool ftmac100_tx_complete_packet(struct ftmac100 *priv)
>> +{
>> + =C2=A0 =C2=A0 struct net_device *netdev =3D priv->netdev;
>> + =C2=A0 =C2=A0 struct ftmac100_txdes *txdes;
>> + =C2=A0 =C2=A0 struct sk_buff *skb;
>> + =C2=A0 =C2=A0 dma_addr_t map;
>> +
>> + =C2=A0 =C2=A0 if (priv->tx_pending =3D=3D 0)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;
>> +
>> + =C2=A0 =C2=A0 txdes =3D ftmac100_current_clean_txdes(priv);
>> +
>> + =C2=A0 =C2=A0 if (ftmac100_txdes_owned_by_dma(txdes))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;
>> +
>> + =C2=A0 =C2=A0 skb =3D ftmac100_txdes_get_skb(txdes);
>> + =C2=A0 =C2=A0 map =3D ftmac100_txdes_get_dma_addr(txdes);
>> +
>> + =C2=A0 =C2=A0 if (unlikely(ftmac100_txdes_excessive_collision(txde=
s) ||
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ftma=
c100_txdes_late_collision(txdes))) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* packet transmitt=
ed to ethernet lost due to late collision
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* or excessive col=
lision
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 netdev->stats.tx_aborted=
_errors++;
>> + =C2=A0 =C2=A0 } else {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 netdev->stats.tx_packets=
++;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 netdev->stats.tx_bytes +=
=3D skb->len;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 dma_unmap_single(priv->dev, map, skb_headlen(skb), D=
MA_TO_DEVICE);
>> +
>> + =C2=A0 =C2=A0 dev_kfree_skb_irq(skb);
>> +
>> + =C2=A0 =C2=A0 ftmac100_txdes_reset(txdes);
>> +
>> + =C2=A0 =C2=A0 ftmac100_tx_clean_pointer_advance(priv);
>> +
>> + =C2=A0 =C2=A0 priv->tx_pending--;
>> + =C2=A0 =C2=A0 netif_wake_queue(netdev);
>> +
>> + =C2=A0 =C2=A0 return true;
>> +}
>> +
>> +static void ftmac100_tx_complete(struct ftmac100 *priv)
>> +{
>> + =C2=A0 =C2=A0 unsigned long flags;
>> +
>> + =C2=A0 =C2=A0 spin_lock_irqsave(&priv->tx_lock, flags);
>> + =C2=A0 =C2=A0 while (ftmac100_tx_complete_packet(priv))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ;
>> + =C2=A0 =C2=A0 spin_unlock_irqrestore(&priv->tx_lock, flags);
>> +}
>> +
>
> I dont understand why you still block hard IRQS, after full NAPI
> conversion.
>
> Now you run from NAPI, and softirq handler, are you sure you still ne=
ed
> to block hard IRQ and tx_lock ?
>
> It seems to me ftmac100_xmit() could only block softirqs (but they
> already are blocked by caller), so you could use spin_lock() from
> ftmac100_xmit()

I was not quite clear about when to use what kinds of locking.
After your explanation, now I understand.
I will submit v4 tomorrow.

really appreciate,
Po-Yu Chuang
