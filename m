From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: via-rhine interrupts
Date: Sun, 15 Aug 2010 22:04:31 +0200
Message-ID: <20100815200431.GA4993@del.dom.local>
References: <AANLkTi=xfBSn=FS9=eR=NZa9QwrHAQwGc7Kh1-bUn3aj@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?us-ascii?Q?=3D=3FUTF-8=3FB=3FSmFrdWIgUnXFvmnEjWth=3F=3D?=
	<ruzicka.jakub@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39079 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472Ab0HOUEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Aug 2010 16:04:38 -0400
Received: by wyb32 with SMTP id 32so4880176wyb.19
        for <netdev@vger.kernel.org>; Sun, 15 Aug 2010 13:04:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <AANLkTi=xfBSn=FS9=eR=NZa9QwrHAQwGc7Kh1-bUn3aj@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jakub Ru=C5=BEi=C4=8Dka wrote, On 29.07.2010 13:03:

> Hello,
Hi,

> the via-rhine driver powered cards generate a really big number of
> interrupts, almost one per packet (11429 interrupts for 8210 incoming
> and 2475 outgoing packets per second on full 100 Mbps load). This is
> observed on multiple different machines (embbed and desktop) and
> kernels (2.6.25 with and without NAPI, 2.6.30, 2.6.32 and 2.6.33). Do
> you have any idea why isn't the polling used or what can I try to fin=
d
> out what's wrong?
>=20
> I have tested sending to/from the machines with nc and scp, measured
> interrups and load with atop. Few of these measurements on an embbed
> device (where the interrupt handling is a problem) are attached.

I've just tested it using a simplistic patch below, which skips
some napi receiving by doing it only every second jiffie (on even
ones), and I've got around 30% less interrupts from via-rhine,
which seems to suggest napi works OK, but there is too low
traffic (or too fast soft interrupt handling) to affect hard
interrupts. (Btw, probably CONFIG_HZ can matter here a bit too.
I tested with 1000.)

Cheers,
Jarek P.

--- (patch only for testing)

diff -Nurp a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	2010-08-15 20:29:58.000000000 +0200
+++ b/net/core/dev.c	2010-08-15 21:15:04.000000000 +0200
@@ -3495,6 +3495,9 @@ static void net_rx_action(struct softirq
 		if (unlikely(budget <=3D 0 || time_after(jiffies, time_limit)))
 			goto softnet_break;
=20
+		if (jiffies & 1)
+			goto softnet_break;
+
 		local_irq_enable();
=20
 		/* Even though interrupts have been re-enabled, this

