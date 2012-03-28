From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/ethernet: ks8851_mll fix rx frame buffer overflow
Date: Wed, 28 Mar 2012 09:39:51 +0200
Message-ID: <1332920391.3547.46.camel@edumazet-glaptop>
References: <20120327130144.GA555@recalcati>
	 <1332859171.10620.0.camel@edumazet-laptop>
	 <20120328070540.GA4892@recalcati>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Davide Ciminaghi <ciminaghi@gnudd.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Thomas Meyer <thomas@m3y3r.de>,
	Wan ZongShun <mcuos.com@gmail.com>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	netdev@vger.kernel.org
To: Raffaele Recalcati <raffaele.recalcati@bticino.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:40223 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754688Ab2C1Hj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 03:39:57 -0400
Received: by eaaq12 with SMTP id q12so162316eaa.19
        for <netdev@vger.kernel.org>; Wed, 28 Mar 2012 00:39:56 -0700 (PDT)
In-Reply-To: <20120328070540.GA4892@recalcati>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-03-28 at 09:05 +0200, Raffaele Recalcati wrote:
> Hi Eric,
>=20
> On 07:39 Tue 27 Mar     , Eric Dumazet wrote:
> > Le mardi 27 mars 2012 =C3=A0 15:01 +0200, Davide Ciminaghi a =C3=A9=
crit :
> > > If interrupts are disabled long enough to allow for more than
> > > 32 frames to accumulate in the MAC's internal buffers, a buffer
> > > overflow occurs. This patch fixes the problem by making the
> > > driver's frame_head_info buffer bigger enough.
> > >=20
> > > Signed-off-by: Davide Ciminaghi <ciminaghi@gnudd.com>
> > > Signed-off-by: Raffaele Recalcati <raffaele.recalcati@bticino.it>
> > > ---
> > >  drivers/net/ethernet/micrel/ks8851_mll.c |    2 +-
> > >  1 files changed, 1 insertions(+), 1 deletions(-)
> > >=20
> > > diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/n=
et/ethernet/micrel/ks8851_mll.c
> > > index 2784bc7..a158e89 100644
> > > --- a/drivers/net/ethernet/micrel/ks8851_mll.c
> > > +++ b/drivers/net/ethernet/micrel/ks8851_mll.c
> > > @@ -40,7 +40,7 @@
> > >  #define	DRV_NAME	"ks8851_mll"
> > > =20
> > >  static u8 KS_DEFAULT_MAC_ADDRESS[] =3D { 0x00, 0x10, 0xA1, 0x86,=
 0x95, 0x11 };
> > > -#define MAX_RECV_FRAMES			32
> > > +#define MAX_RECV_FRAMES			256
> > >  #define MAX_BUF_SIZE			2048
> > >  #define TX_BUF_SIZE			2000
> > >  #define RX_BUF_SIZE			2000
> >=20
> > How can this fix the problem for good ?
>=20
> You can see in ks_rcv function,=20
> ks->frame_cnt =3D ks_rdreg16(ks, KS_RXFCTR) >> 8;
> so "RXFC RX Frame Count" is a byte, maximum 256 total frames.
> but we have the threshold ..
>=20
> As you can see also in ks_setup the=20
> /* Setup Receive Frame Threshold - 1 frame (RXFCTFC) */
> ks_wrreg16(ks, KS_RXFCTR, 1 & RXFCTR_THRESHOLD_MASK);
>=20
> In conclusion what happen is that if we stop system interrupts for a =
while,
> when we are back the ks_rcv function starts reading the frames, and=20
> the=20
> while (ks->frame_cnt--) {
> ..
> 	frame_hdr++;
> }
> loop goes out of the malloc'ed area.
>=20
> We experienced so strange bugs in the last weeks that we are so happy=
 that it seems fixed, but I need
> some weeks to confirm it is robust enough.
> The 'load setup' is like the following:
> - nfs rootfs
> - host $ sudo ping -f $TARGET_IP_ADDRESS
> - host $ scp -r BIG_DIR user@$TARGET_IP_ADDRESS:
> But I'm not sure to create the bug in a mathematical way, it seems to=
 depend on packets on the corporate lan.
>=20
> Surely if I stop with jtag and restart after some seconds I have buff=
er overflow, with same errors in ram that I
> obtain randomically with 'load setup'.
>=20
> Hoping it helps,

Sure it does.

So the limit should be 255, not 256.
(0xFFFF >> 8 -> 0xFF)

ks->frame_cnt =3D ks_rdreg16(ks, KS_RXFCTR) >> 8;

I cant see how 256 can be stored in a 8bit field ?

You see, explaining things in Changelog can actually help a lot, since
we now understand chip has this 8bit limit for the frame counter.

Thanks
