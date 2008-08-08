From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: Strange tg3 regression with UMP fw. link reporting
Date: Fri, 8 Aug 2008 11:21:30 +0200
Message-ID: <200808081121.30795.arnd@arndb.de>
References: <1218180939.24157.332.camel@pasglop> <31233EB5-037E-4615-95C9-7C816E510752@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Segher Boessenkool <segher@kernel.crashing.org>,
	benh@kernel.crashing.org, Nathan Lynch <ntl@pobox.com>,
	mcarlson@broadcom.com, Michael Chan <mchan@broadcom.com>,
	netdev <netdev@vger.kernel.org>
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.183]:64101 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752298AbYHHJWW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 05:22:22 -0400
In-Reply-To: <31233EB5-037E-4615-95C9-7C816E510752@kernel.crashing.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 08 August 2008, Segher Boessenkool wrote:
> > I don't know yet for sure what happens, but a quick look at the com=
mit
> > seems to show that the driver synchronously spin-waits for up to 2.=
5ms
>=20
> That's what the comment says, but the code says 2.5 _seconds_:
>=20
> + =A0 =A0 =A0 /* Wait for up to 2.5 milliseconds */
> + =A0 =A0 =A0 for (i =3D 0; i < 250000; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(tr32(GRC_RX_CPU_EVENT) & GRC_RX_C=
PU_DRIVER_EVENT))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 udelay(10);
> + =A0 =A0 =A0 }
>=20
> (not that milliseconds wouldn't be bad already...)

It can potentially be even much longer, because each udelay will wait
for *more* than 10 microseconds, and tr32() is an mmio read that takes
additional time, possibly in the order of microseconds as well.

The correct way to implement a timeout like this would be to use
time_before() in the condition, aside from better not doing a busy-loop
in the first place.

	Arnd <><
