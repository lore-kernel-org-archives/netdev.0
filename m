From: Raffaele Recalcati <raffaele.recalcati@bticino.it>
Subject: Re: [PATCH] net/ethernet: ks8851_mll fix rx frame buffer overflow
Date: Wed, 28 Mar 2012 09:05:40 +0200
Message-ID: <20120328070540.GA4892@recalcati>
References: <20120327130144.GA555@recalcati>
 <1332859171.10620.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Davide Ciminaghi <ciminaghi@gnudd.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Thomas Meyer <thomas@m3y3r.de>,
	Wan ZongShun <mcuos.com@gmail.com>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.bticino.it ([91.208.195.91]:55150 "EHLO bticino.it"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1749667Ab2C1HJr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 03:09:47 -0400
In-Reply-To: <1332859171.10620.0.camel@edumazet-laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,=0D
=0D
On 07:39 Tue 27 Mar     , Eric Dumazet wrote:=0D
> Le mardi 27 mars 2012 =C3=A0 15:01 +0200, Davide Ciminaghi a =C3=A9cr=
it :=0D
> > If interrupts are disabled long enough to allow for more than=0D
> > 32 frames to accumulate in the MAC's internal buffers, a buffer=0D
> > overflow occurs. This patch fixes the problem by making the=0D
> > driver's frame_head_info buffer bigger enough.=0D
> > =0D
> > Signed-off-by: Davide Ciminaghi <ciminaghi@gnudd.com>=0D
> > Signed-off-by: Raffaele Recalcati <raffaele.recalcati@bticino.it>=0D
> > ---=0D
> >  drivers/net/ethernet/micrel/ks8851_mll.c |    2 +-=0D
> >  1 files changed, 1 insertions(+), 1 deletions(-)=0D
> > =0D
> > diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net=
/ethernet/micrel/ks8851_mll.c=0D
> > index 2784bc7..a158e89 100644=0D
> > --- a/drivers/net/ethernet/micrel/ks8851_mll.c=0D
> > +++ b/drivers/net/ethernet/micrel/ks8851_mll.c=0D
> > @@ -40,7 +40,7 @@=0D
> >  #define	DRV_NAME	"ks8851_mll"=0D
> >  =0D
> >  static u8 KS_DEFAULT_MAC_ADDRESS[] =3D { 0x00, 0x10, 0xA1, 0x86, 0=
x95, 0x11 };=0D
> > -#define MAX_RECV_FRAMES			32=0D
> > +#define MAX_RECV_FRAMES			256=0D
> >  #define MAX_BUF_SIZE			2048=0D
> >  #define TX_BUF_SIZE			2000=0D
> >  #define RX_BUF_SIZE			2000=0D
> =0D
> How can this fix the problem for good ?=0D
=0D
You can see in ks_rcv function, =0D
ks->frame_cnt =3D ks_rdreg16(ks, KS_RXFCTR) >> 8;=0D
so "RXFC RX Frame Count" is a byte, maximum 256 total frames.=0D
but we have the threshold ..=0D
=0D
As you can see also in ks_setup the =0D
/* Setup Receive Frame Threshold - 1 frame (RXFCTFC) */=0D
ks_wrreg16(ks, KS_RXFCTR, 1 & RXFCTR_THRESHOLD_MASK);=0D
=0D
In conclusion what happen is that if we stop system interrupts for a wh=
ile,=0D
when we are back the ks_rcv function starts reading the frames, and =0D
the =0D
while (ks->frame_cnt--) {=0D
=2E.=0D
	frame_hdr++;=0D
}=0D
loop goes out of the malloc'ed area.=0D
=0D
We experienced so strange bugs in the last weeks that we are so happy t=
hat it seems fixed, but I need=0D
some weeks to confirm it is robust enough.=0D
The 'load setup' is like the following:=0D
- nfs rootfs=0D
- host $ sudo ping -f $TARGET_IP_ADDRESS=0D
- host $ scp -r BIG_DIR user@$TARGET_IP_ADDRESS:=0D
But I'm not sure to create the bug in a mathematical way, it seems to d=
epend on packets on the corporate lan.=0D
=0D
Surely if I stop with jtag and restart after some seconds I have buffer=
 overflow, with same errors in ram that I=0D
obtain randomically with 'load setup'.=0D
=0D
Hoping it helps,=0D
=0D
Raffaele=0D
=0D
> =0D
> =0D
> =0D
=0D
Ce message, ainsi que tous les fichiers joints =C3=A0 ce message,=0D
peuvent contenir des informations sensibles et/ ou confidentielles=0D
ne devant pas =C3=AAtre divulgu=C3=A9es. Si vous n'=C3=AAtes pas le des=
tinataire=0D
de ce message (ou que vous recevez ce message par erreur), nous=0D
vous remercions de le notifier imm=C3=A9diatement =C3=A0 son exp=C3=A9d=
iteur, et=0D
de d=C3=A9truire ce message. Toute copie, divulgation, modification,=0D
utilisation ou diffusion, non autoris=C3=A9e, directe ou indirecte, de=0D
tout ou partie de ce message, est strictement interdite.=0D
=0D
This e-mail, and any document attached hereby, may contain=0D
confidential and/or privileged information. If you are not the=0D
intended recipient (or have received this e-mail in error) please=0D
notify the sender immediately and destroy this e-mail. Any=0D
unauthorized, direct or indirect, copying, disclosure, distribution=0D
or other use of the material or parts thereof is strictly=0D
forbidden.
