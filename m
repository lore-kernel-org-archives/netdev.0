From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] r8169: Add 64bit statistics
Date: Thu, 17 Nov 2011 14:02:01 +0100
Message-ID: <1321534921.2751.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111117064826.GA4429@Desktop-Junchang>
	 <0a41dc06-15ab-4cf6-9bbd-3a1556993854@tahiti.vyatta.com>
	 <CABoNC82RO2uvn9TfToAygEspUZnNrefXgO6SGpZoSAayCp3QiA@mail.gmail.com>
	 <1321517516.3274.40.camel@edumazet-laptop>
	 <CABoNC83U2k=-6-BkJEyWBXfSnEbb-+K8CD1ffqhjA613Tk04tQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org, romieu@fr.zoreil.com,
	nic swsd <nic_swsd@realtek.com>
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:53887 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755675Ab1KQNCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 08:02:06 -0500
Received: by bke11 with SMTP id 11so1945441bke.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 05:02:04 -0800 (PST)
In-Reply-To: <CABoNC83U2k=-6-BkJEyWBXfSnEbb-+K8CD1ffqhjA613Tk04tQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 novembre 2011 =C3=A0 18:59 +0800, Junchang Wang a =C3=A9cri=
t :
> > Yes, look at sky2.c for a template
> >
> > drivers/net/ethernet/marvell/sky2.c contains code like that
> > (different syncp for rx/tx)
> >
> > TX path:
> >                        u64_stats_update_begin(&sky2->tx_stats.syncp=
);
> >                        ++sky2->tx_stats.packets;
> >                        sky2->tx_stats.bytes +=3D skb->len;
> >                        u64_stats_update_end(&sky2->tx_stats.syncp);
> >
> >
> > RX path:
> >
> >        u64_stats_update_begin(&sky2->rx_stats.syncp);
> >        sky2->rx_stats.packets +=3D packets;
> >        sky2->rx_stats.bytes +=3D bytes;
> >        u64_stats_update_end(&sky2->rx_stats.syncp);
> >
>=20
> Thanks, Eric.
>=20
> I'm still confused about why we need two sync entries. Please correct
> me if I'm wrong.
>=20
> Take r8169 for example, All statistic entries are updated in
> rtl8169_rx_interrupt() or rtl8169_tx_interrupt(). Those two functions
> are called in rtl8169_poll().
> As far as I know, rtl8169_poll() is protected by NAPI_STATE_SCHED bit
> to run on a single core at one moment. So there is not compulsory to
> use two sync entries.
>=20
> One benefit from two sync is that readers can avoid many retries.
>=20

Oh well...

Dont try to optimize all this stuff, I spent some time on it already,
just use the infrastructure and forget about races and bugs.

The short answer is :

CPU1                    CPU2                 =20
TX path                 RX path              =20


since CPU1 & CPU2 will do the update_begin(), and the memory increment
is not atomic, we might lose one increment, and block a stat reader
forever.
