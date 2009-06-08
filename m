From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Security, resend] Instant crash with rtl8169 and large packets
Date: Mon, 08 Jun 2009 16:27:48 +0200
Message-ID: <4A2D1FE4.5030100@gmail.com>
References: <4A2D1147.8020101@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41138 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753483AbZFHO1s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 10:27:48 -0400
In-Reply-To: <4A2D1147.8020101@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Tokarev a =E9crit :
> [Please excuse me for the resend, --
>  picked the wrong address for netdev again]
>=20
> Hello.
>=20
> This is a resend (sort of) of several months old email.
> Previous email about this issue has been mostly ignored.
>=20
> The situation is very simple: with an RTL8169 (probably
> onboard) GigE card which, by default, is configured to
> have MTU (maximal transmission unit) to be 1500 bytes,
> it's *trivial* to instantly crash the machine by sending
> it a *single* packet of size >1500 bytes (provided the
> network switch can handle jumbo frames).
>=20
> I verified with on several different machines - all I were
> able to find with this card - and all behaves exactly the
> same.
>=20
> When sending a packet of size, say, 3000 bytes (ping -s 3000)
> from another machine to a machine running rtl8169 with no
> MTU configured, kernel OOPSes.
>=20
> I captured one such OOPS (unfortunately without the first
> line few lines) here:
>=20
>  http://www.corpit.ru/mjt/r8169-mtu-oops.jpg
>=20
> (since the network goes boom at that time, no network console
> is working).
>=20
> But for anyone familiar with the driver's internals it
> should be easy to figure the issue out.
>=20
> This is, in my opinion, quite a serious issue.  And I've no
> idea why it is being ignored for several months.

I suppose you use a recent kernel ?

Could you please try following patch ?

Thank you

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index e94316b..c08b97a 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3468,7 +3468,7 @@ static int rtl8169_rx_interrupt(struct net_device=
 *dev,
=20
 		if (status & DescOwn)
 			break;
-		if (unlikely(status & RxRES)) {
+		if (unlikely(status & (RxRES | RxRWT | RxRUNT | RxCRC | RxFOVF))) {
 			if (netif_msg_rx_err(tp)) {
 				printk(KERN_INFO
 				       "%s: Rx ERROR. status =3D %08x\n",

