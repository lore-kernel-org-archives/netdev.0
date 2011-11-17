From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] r8169: Add 64bit statistics
Date: Thu, 17 Nov 2011 09:11:56 +0100
Message-ID: <1321517516.3274.40.camel@edumazet-laptop>
References: <20111117064826.GA4429@Desktop-Junchang>
	 <0a41dc06-15ab-4cf6-9bbd-3a1556993854@tahiti.vyatta.com>
	 <CABoNC82RO2uvn9TfToAygEspUZnNrefXgO6SGpZoSAayCp3QiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org, romieu@fr.zoreil.com,
	nic swsd <nic_swsd@realtek.com>
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43693 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947Ab1KQIMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 03:12:01 -0500
Received: by wyh11 with SMTP id 11so1615338wyh.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 00:12:00 -0800 (PST)
In-Reply-To: <CABoNC82RO2uvn9TfToAygEspUZnNrefXgO6SGpZoSAayCp3QiA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 novembre 2011 =C3=A0 15:46 +0800, Junchang Wang a =C3=A9cri=
t :
> > You dont need per-cpu since Tx is locked by dev->xmit_lock and
> > rx is implicitly single threaded by NAPI.
>=20
> Thanks.
>=20
> >You do need to have
> > two u64_stat_sync entries (one for Tx and one for Rx).
>=20
> You mean Rx and Tx will perform on different cores at one moment.
> So I need a sync for Tx to protect tx_xxx, and another for Rx to
> protect rx_xxx. Is that right?
>=20

Yes, look at sky2.c for a template

drivers/net/ethernet/marvell/sky2.c contains code like that
(different syncp for rx/tx)

TX path:
                        u64_stats_update_begin(&sky2->tx_stats.syncp);
                        ++sky2->tx_stats.packets;
                        sky2->tx_stats.bytes +=3D skb->len;
                        u64_stats_update_end(&sky2->tx_stats.syncp);


RX path:

        u64_stats_update_begin(&sky2->rx_stats.syncp);
        sky2->rx_stats.packets +=3D packets;
        sky2->rx_stats.bytes +=3D bytes;
        u64_stats_update_end(&sky2->rx_stats.syncp);
