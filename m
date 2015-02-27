From: pmarzo <marzo.pedro@gmail.com>
Subject: Re: [PATCH 1/1] xen-netback: remove compilation warning
Date: Fri, 27 Feb 2015 11:45:52 +0100
Message-ID: <1425033952.3659.23.camel@CEM14014B>
References: <1424939141-30730-1-git-send-email-marzo.pedro@gmail.com>
	 <20150226.113046.199389136864969627.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ian.campbell@citrix.com, wei.liu2@citrix.com,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:45464 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751348AbbB0Kp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 05:45:56 -0500
Received: by wesp10 with SMTP id p10so17073648wes.12
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 02:45:55 -0800 (PST)
In-Reply-To: <20150226.113046.199389136864969627.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On jue, 2015-02-26 at 11:30 -0500, David Miller wrote:
> From: pedro <marzo.pedro@gmail.com>
> Date: Thu, 26 Feb 2015 09:25:41 +0100
>=20
> > From: pmarzo <marzo.pedro@gmail.com>
> >=20
> > offset and size are of type uint16_t so the %lu gives a warning
> > A %u specifier, the same used in size makes gcc happy
> > Not sure if a %x would be more correct
> >=20
> > Signed-off-by: Pedro Marzo Perez <marzo.pedro@gmail.com>
>=20
> This patch actually adds a warning on my machine, and your analysis
> of the types is therefore probably incorrect:
>=20
> drivers/net/xen-netback/netback.c: In function =E2=80=98xenvif_tx_bui=
ld_gops=E2=80=99:
> drivers/net/xen-netback/netback.c:1259:8: warning: format =E2=80=98%u=
=E2=80=99 expects argument of type =E2=80=98unsigned int=E2=80=99, but =
argument 5 has type =E2=80=98long unsigned int=E2=80=99 [-Wformat=3D]

You are right, this patch is completely wrong for i386, it gives me a
warning too. I should have checked that before, sorry.=20

I should also have said I am using a cross compiler, which is the one
that gives the warning compiling the current code:
arm-linux-gnueabi-gcc --version
arm-linux-gnueabi-gcc (Ubuntu/Linaro 4.7.3-12ubuntu1) 4.7.3


>=20
> The issue is probably "~PAGE_MASK" and I think the type of that
> propagates into the type of the overall calculation.
That is what is probably happening, operations must be done to operands
of the same size, and the intel compiler is casting everything to
unsigned long (because I have a 64 bit machine??), but the arm compiler
is casting to unsigned int :-(

PAGE_MASK is defined as a number without any cast, so not sure which
compiler is right
	#define PAGE_SHIFT              12
	#define PAGE_MASK               (~((1 << PAGE_SHIFT) - 1))

This new patch fixes the warning for the arm gcc compiler and the i386
compiler, it just makes sure everything is cast to unsigned long
Could you please forget the previous one and give your opinion about
this one?

--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1248,9 +1248,10 @@ static void xenvif_tx_build_gops(struct
xenvif_queue *queue,
                /* No crossing a page as the payload mustn't fragment.
*/
                if (unlikely((txreq.offset + txreq.size) > PAGE_SIZE)) =
{
                        netdev_err(queue->vif->dev,
-                                  "txreq.offset: %x, size: %u, end: %u
\n",
+                                  "txreq.offset: %x, size: %u, end: %l=
u
\n",
                                   txreq.offset, txreq.size,
-                                  (txreq.offset&~PAGE_MASK) +
txreq.size);
+                                  ((unsigned
long)txreq.offset&~PAGE_MASK)
+                                        + txreq.size);
                        xenvif_fatal_tx_err(queue->vif);
                        break;
                }
--=20
1.9.1




   =20
