From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] bgmac: driver for GBit MAC core on BCMA bus
Date: Sat, 5 Jan 2013 17:57:15 +0100
Message-ID: <20130105165715.GA4906@electric-eye.fr.zoreil.com>
References: <1356363222-16672-1-git-send-email-zajec5@gmail.com> <20121226231721.GA8243@electric-eye.fr.zoreil.com> <CACna6rydCnf9tjsueOQRvxPQz5_u_h6b=q9j_pTQN+j7_+6uLA@mail.gmail.com> <20130103203027.GA4305@electric-eye.fr.zoreil.com> <CACna6ry4fQCvh_hSKooNi1Lq=ftjVD=tNeDijnfW1gnnvGzLeQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: =?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43712 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755802Ab3AERY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2013 12:24:57 -0500
Content-Disposition: inline
In-Reply-To: <CACna6ry4fQCvh_hSKooNi1Lq=ftjVD=tNeDijnfW1gnnvGzLeQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com> :
[...]
> We really need some good explanation for NETDEV_TX_BUSY somewhere
> (documentation!).

It is already explained in Documentation/networking/driver.txt:
<snip>
1) The ndo_start_xmit method must not return NETDEV_TX_BUSY under
   any normal circumstances.  It is considered a hard error unless
   there is no way your device can tell ahead of time when it's
   transmit function will become busy.

   Instead it must maintain the queue properly.  For example,
   for a driver implementing scatter-gather this means:
</snip>

Please compare your V3:bgmac_dma_tx_add and the sample code after the
aforementioned paragraph.

> I've checked some drivers and:
>=20
> 1) b44.c
> In case of:
> > if (unlikely(TX_BUFFS_AVAIL(bp) < 1)) {
> it does netif_stop_queue and returns NETDEV_TX_BUSY

The driver labels it as bug checking and it stops queueing when need
arises at the end of the xmit function.

> 2) sky2.c
> In case of:
> > if (unlikely(tx_avail(sky2) < tx_le_req(skb)))
> it just returns NETDEV_TX_BUSY

Same thing as above. Less documented though.

> 3) jme.2
> In case of:
> > if (unlikely(idx < 0)) {
> it does netif_stop_queue and returns NETDEV_TX_BUSY

The driver labels it as bug checking. It stops queueing when need
arises at the end of the xmit function (see jme_stop_queue_if_full).

> 4) de2104x.c
> In case of:
> > if (tx_free =3D=3D 0) {
> it does netif_stop_queue and returns NETDEV_TX_BUSY

It stops queueing at the end of the start_xmit handler as well.

> So there are many drivers doing the same mistake I did.

After a packet has been handed to hardware, each of these drivers
checks if queueing should be disabled before returning from start_xmit.

V3 bgmac doesn't.

--=20
Ueimor
