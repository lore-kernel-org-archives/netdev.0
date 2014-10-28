From: Lothar =?UTF-8?B?V2HDn21hbm4=?= <LW@KARO-electronics.de>
Subject: Re: [PATCHv2 6/6] net: fec: fix regression on i.MX28 introduced by
 rx_copybreak support
Date: Tue, 28 Oct 2014 13:10:51 +0100
Message-ID: <20141028131051.6d214ae0@ipc1.ka-ro>
References: <1414494104-27943-1-git-send-email-LW@KARO-electronics.de>
	<1414494104-27943-7-git-send-email-LW@KARO-electronics.de>
	<063D6719AE5E284EB5DD2968C1650D6D1C9E04DB@AcuExch.aculab.com>
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
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1C9E04DB@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

David Laight wrote:
> From:  Lothar Wa=C3=9Fmann
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
> > diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/ne=
t/ethernet/freescale/fec_main.c
> > index 404fb9d..b92324c 100644
> > --- a/drivers/net/ethernet/freescale/fec_main.c
> > +++ b/drivers/net/ethernet/freescale/fec_main.c
> > @@ -339,6 +339,18 @@ static void *swap_buffer(void *bufaddr, int le=
n)
> >  	return bufaddr;
> >  }
> >=20
> > +static void *swap_buffer2(void *dst_buf, void *src_buf, int len)
> > +{
> > +	int i;
> > +	unsigned int *src =3D src_buf;
> > +	unsigned int *dst =3D dst_buf;
> > +
> > +	for (i =3D 0; i < len; i +=3D 4, src++, dst++)
> > +		swab32s(src);
> > +
> > +	return dst_buf;
> > +}
> > +
>=20
> Actually that is completely f*cked....
>=20
Yeah, noticed that shortly after sending out. :(
One change too many...


Lothar Wa=C3=9Fmann
