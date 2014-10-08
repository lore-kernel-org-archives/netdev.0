From: Lothar =?UTF-8?B?V2HDn21hbm4=?= <LW@KARO-electronics.de>
Subject: Re: [PATCH] net: fec: fix regression on i.MX28 introduced by
 rx_copybreak support
Date: Wed, 8 Oct 2014 07:01:47 +0200
Message-ID: <20141008070147.2f3b5319@ipc1.ka-ro>
References: <1412687977-11742-1-git-send-email-LW@KARO-electronics.de>
	<1412692034.11091.122.camel@edumazet-glaptop2.roam.corp.google.com>
	<063D6719AE5E284EB5DD2968C1650D6D174C6116@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Frank Li <Frank.Li@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:51650 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752281AbaJHFRu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 01:17:50 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174C6116@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

David Laight wrote:
> From: Eric Dumazet
> > On Tue, 2014-10-07 at 15:19 +0200, Lothar Wamann wrote:
> > > commit 1b7bde6d659d ("net: fec: implement rx_copybreak to improve=
 rx performance")
> > > introduced a regression for i.MX28. The swap_buffer() function do=
ing
> > > the endian conversion of the received data on i.MX28 may access m=
emory
> > > beyond the actual packet size in the DMA buffer. fec_enet_copybre=
ak()
> > > does not copy those bytes, so that the last bytes of a packet may=
 be
> > > filled with invalid data after swapping.
> > > This will likely lead to checksum errors on received packets.
> > > E.g. when trying to mount an NFS rootfs:
> > > UDP: bad checksum. From 192.168.1.225:111 to 192.168.100.73:44662=
 ulen 36
> > >
> > > Do the byte swapping and copying to the new skb in one go if
> > > necessary.
> > >
> > > Signed-off-by: Lothar Wamann <LW@KARO-electronics.de>
> > > ---
> > >  drivers/net/ethernet/freescale/fec_main.c |   25 +++++++++++++++=
++++++----
> > >  1 file changed, 21 insertions(+), 4 deletions(-)
> > >
> > > diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/=
net/ethernet/freescale/fec_main.c
> > > index 87975b5..eaaebad 100644
> > > --- a/drivers/net/ethernet/freescale/fec_main.c
> > > +++ b/drivers/net/ethernet/freescale/fec_main.c
> > > @@ -339,6 +339,18 @@ static void *swap_buffer(void *bufaddr, int =
len)
> > >  	return bufaddr;
> > >  }
> > >
> > > +static void *swap_buffer2(void *dst_buf, void *src_buf, int len)
> > > +{
> > > +	int i;
> > > +	unsigned int *src =3D src_buf;
> > > +	unsigned int *dst =3D dst_buf;
> > > +
> > > +	for (i =3D 0; i < DIV_ROUND_UP(len, 4); i++, src++, dst++)
> > > +		*dst =3D cpu_to_be32(*src);
> >=20
> > No need for the DIV :
> >=20
> > 	for (i =3D 0; i < len; i +=3D sizeof(*dst), src++, dst++)
> > 		*dst =3D cpu_to_be32(*src);
> >=20
> > Also are you sure both src/dst are aligned to word boundaries, or i=
s
> > this architecture OK with possible misalignment ?
>=20
> I wondered about that as well.
> I wouldn't have expected ppc to support misaligned transfers, and you=
'd also
> want to make sure that cpu_to_be(*src) was using a byte-swapping inst=
ruction.
> Hmmm... cpu_to_be() doesn't sound like the right 'swap' macro name.
>=20
??? So what is cpu_to_be32() then?
The new swap function is an exact copy of the original one already in
use except for the fact that it uses distinct source and destination
buffers.


Lothar Wa=C3=9Fmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=C3=9Fe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=C3=A4ftsf=C3=BChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
