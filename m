From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [bug?] r8169: hangs under heavy load
Date: Fri, 25 Nov 2011 22:05:03 +0100
Message-ID: <1322255103.2550.4.camel@edumazet-laptop>
References: <4E7F4D45.7040902@wolke7.net>
	 <1316978632.4122.103.camel@deadeye> <4E82C0B5.1050902@wolke7.net>
	 <1317254171.4068.12.camel@deadeye>
	 <20111124044137.GA18262@elie.hsd1.il.comcast.net>
	 <4ECFE7A7.5070300@wolke7.net>
	 <20111125201936.GA26692@elie.hsd1.il.comcast.net>
	 <1322253122.2550.3.camel@edumazet-laptop>
	 <20111125205451.GG26692@elie.hsd1.il.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	Francois Romieu <romieu@fr.zoreil.com>,
	linux-kernel@vger.kernel.org,
	Armin Kazmi <armin.kazmi@tu-dortmund.de>,
	Gerd <booster@wolke7.net>
To: Jonathan Nieder <jrnieder@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:47114 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151Ab1KYVFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 16:05:09 -0500
In-Reply-To: <20111125205451.GG26692@elie.hsd1.il.comcast.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 25 novembre 2011 =C3=A0 14:54 -0600, Jonathan Nieder a =C3=A9=
crit :
> Eric Dumazet wrote:
>=20
> > rtl8169_rx_interrupt(..., budget) can return budget + 1 sometimes
> > because of :
> >
> >                 /* Work around for AMD plateform. */
> >                 if ((desc->opts2 & cpu_to_le32(0xfffe000)) &&
> >                     (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_05)) {
> >                         desc->opts2 =3D 0;
> >                         cur_rx++;
> >                 }
> >
> > Sorry, I wont patch this today, its black Friday, and David said to
> > patch submitters :
> >
> > "stick to turkey and wine you're better at it"=20
>=20
> :)  Sensible enough.  Thanks for the quick response!

;)

You could try this non official patch, if you are in a hurry ;)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/etherne=
t/realtek/r8169.c
index 6f06aa1..b8a537f 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5710,6 +5710,7 @@ static int rtl8169_rx_interrupt(struct net_device=
 *dev,
 {
 	unsigned int cur_rx, rx_left;
 	unsigned int count;
+	unsigned int workaround =3D 0;
=20
 	cur_rx =3D tp->cur_rx;
 	rx_left =3D NUM_RX_DESC + tp->dirty_rx - cur_rx;
@@ -5780,6 +5781,7 @@ static int rtl8169_rx_interrupt(struct net_device=
 *dev,
 		    (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_05)) {
 			desc->opts2 =3D 0;
 			cur_rx++;
+			workaround++;
 		}
 	}
=20
@@ -5788,7 +5790,7 @@ static int rtl8169_rx_interrupt(struct net_device=
 *dev,
=20
 	tp->dirty_rx +=3D count;
=20
-	return count;
+	return count - workaround;
 }
=20
 static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
