From: Lothar =?UTF-8?B?V2HDn21hbm4=?= <LW@KARO-electronics.de>
Subject: Re: [PATCHv2 6/6] net: fec: fix regression on i.MX28 introduced by
 rx_copybreak support
Date: Tue, 28 Oct 2014 13:36:09 +0100
Message-ID: <20141028133609.2bf6c745@ipc1.ka-ro>
References: <1414494104-27943-1-git-send-email-LW@KARO-electronics.de>
	<1414494104-27943-7-git-send-email-LW@KARO-electronics.de>
	<063D6719AE5E284EB5DD2968C1650D6D1C9E04C0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Frank Li <Frank.Li@freescale.com>,
	"Fabio Estevam" <fabio.estevam@freescale.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1C9E04C0@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

David Laight wrote:
> From: Lothar Wa=C3=9Fmann
> > commit 1b7bde6d659d ("net: fec: implement rx_copybreak to improve r=
x performance")
> > introduced a regression for i.MX28. The swap_buffer() function doin=
g
> > the endian conversion of the received data on i.MX28 may access mem=
ory
> > beyond the actual packet size in the DMA buffer. fec_enet_copybreak=
()
> > does not copy those bytes, so that the last bytes of a packet may b=
e
> > filled with invalid data after swapping.
> > This will likely lead to checksum errors on received packets.
> > E.g. when trying to mount an NFS rootfs:
> > UDP: bad checksum. From 192.168.1.225:111 to 192.168.100.73:44662 u=
len 36
> >=20
> > Do the byte swapping and copying to the new skb in one go if
> > necessary.
> >=20
> > Signed-off-by: Lothar Wamann <LW@KARO-electronics.de>
> > ---
> >  drivers/net/ethernet/freescale/fec_main.c |   25 +++++++++++++++++=
++++----
> >  1 file changed, 21 insertions(+), 4 deletions(-)
> >=20
> > @@ -1455,7 +1472,7 @@ fec_enet_rx_queue(struct net_device *ndev, in=
t budget, u16 queue_id)
> >  		prefetch(skb->data - NET_IP_ALIGN);
> >  		skb_put(skb, pkt_len - 4);
> >  		data =3D skb->data;
> > -		if (fep->quirks & FEC_QUIRK_SWAP_FRAME)
> > +		if (!is_copybreak && need_swap)
> >  			swap_buffer(data, pkt_len);
>=20
> It has to be better to set the 'copybreak' limit to be larger than th=
e
> maximum frame size and so always go through the 'copybreak' paths.
>=20
Since the copybreak support is all about performance optimistation, we
should IMO buy the additional advantage for i.MX28 by not having to
access the buffer twice (once for copying and once again for swapping).


Lothar Wa=C3=9Fmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=C3=9Fe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=C3=A4ftsf=C3=BChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
