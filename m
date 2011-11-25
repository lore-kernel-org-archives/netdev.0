From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [bug?] r8169: hangs under heavy load
Date: Sat, 26 Nov 2011 00:05:57 +0100
Message-ID: <1322262357.2550.12.camel@edumazet-laptop>
References: <4E7F4D45.7040902@wolke7.net>
	 <1316978632.4122.103.camel@deadeye> <4E82C0B5.1050902@wolke7.net>
	 <1317254171.4068.12.camel@deadeye>
	 <20111124044137.GA18262@elie.hsd1.il.comcast.net>
	 <4ECFE7A7.5070300@wolke7.net>
	 <20111125201936.GA26692@elie.hsd1.il.comcast.net>
	 <1322253122.2550.3.camel@edumazet-laptop>
	 <20111125222211.GA13719@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jonathan Nieder <jrnieder@gmail.com>, netdev@vger.kernel.org,
	nic_swsd@realtek.com, linux-kernel@vger.kernel.org,
	Armin Kazmi <armin.kazmi@tu-dortmund.de>,
	Gerd <booster@wolke7.net>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111125222211.GA13719@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 25 novembre 2011 =C3=A0 23:22 +0100, Francois Romieu a =C3=A9=
crit :
> Eric Dumazet <eric.dumazet@gmail.com> :
> [...]
> > rtl8169_rx_interrupt(..., budget) can return budget + 1 sometimes
> > because of :
> >=20
> >                 /* Work around for AMD plateform. */
> >                 if ((desc->opts2 & cpu_to_le32(0xfffe000)) &&
> >                     (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_05)) {
> >                         desc->opts2 =3D 0;
> >                         cur_rx++;
> >                 }
>=20
> It needs fixing but RTL_GIGA_MAC_VER_05 is an old PCI 8169sc while
> debian's bug #642911 is about a 8168c (aka RTL_GIGA_MAC_VER_{19 .. 22=
}).
>=20
> This path is not used.
>=20

OK, then we receive a RxFIFOOver indication while napi handler is
running (quite possible if machine under network load)

This (hard) interrupt calls rtl8169_tx_timeout()
	-> rtl8169_hw_reset()
		-> rtl_hw_reset()
			-> rtl8169_init_ring_indexes()

tp->dirty_tx =3D tp->dirty_rx =3D tp->cur_tx =3D tp->cur_rx =3D 0;

When control returns to softirq handler (rtl8169_rx_interrupt())
it can then catch tp->cur_rx being now 0 instead of value at start of
handler.

count =3D cur_rx - tp->cur_rx; // too big


Really, calling rtl8169_init_ring_indexes() from hardirq is killing us.
