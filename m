From: Pantelis Koukousoulas <pktoss@gmail.com>
Subject: Fwd: [PATCH] b44: Unconditionally enable interrupt routing on reset
Date: Sun, 15 Feb 2009 16:17:19 +0200
Message-ID: <1295ed070902150617m2ed1a4b4ja7d2bf471b941f26@mail.gmail.com>
References: <200811161537.30404.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:48849 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752449AbZBOORW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2009 09:17:22 -0500
Received: by fxm13 with SMTP id 13so4916373fxm.13
        for <netdev@vger.kernel.org>; Sun, 15 Feb 2009 06:17:19 -0800 (PST)
In-Reply-To: <200811161537.30404.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

There's been 3 months since the last time this was posted so I assume
it was somehow lost.
This patch helps with pxe booting b44 laptops where the BIOS leaves
the card in a slightly
broken state causing nfsroot mount to hang indefinitely (due to no
interrupts coming).

Note that without the patch, one could say that it is the fragility of
the linux driver code
that turns a slight BIOS PXE bug into a broken card with no
interrupts, so the change
is imho worthy from a correctness point of view (more robust code).

I understand that it is a bit late for this patch to get to 2.6.29
(although it's been posted
over 3 months ago at first) but it would be *really* nice if it was at
least picked up into a
maintainer tree for the next merge window if possible.

Again, this patch is very straightforward and it has been tested daily
for the last 3 months
with no problems whatsoever.

Thanks in advance,
Pantelis


---------- Forwarded message ----------
From: Michael Buesch <mb@bu3sch.de>
Date: Sun, Nov 16, 2008 at 4:37 PM
Subject: [PATCH] b44: Unconditionally enable interrupt routing on reset
To: Jeff Garzik <jeff@garzik.org>
Cc: netdev@vger.kernel.org, Pantelis Koukousoulas <pktoss@gmail.com>,
Gary Zambrano <zambrano@broadcom.com>


Unconditionally setup the IRQ routing on chip reset.
It's safe to call ssb_pcicore_dev_irqvecs_enable() unconditionally, because
it has internal checks for redundant calls.

This fixes problems where hardware will not come up properly
due to quirks in the enable-bit hardware.

Reported-by: Pantelis Koukousoulas <pktoss@gmail.com>
Signed-off-by: Michael Buesch <mb@bu3sch.de>

---

I'm not sure if we should push this for 2.6.28.
This fixes quirks when booting from PXE. So only a minority of
the b44 users are affected.

Index: wireless-testing/drivers/net/b44.c
===================================================================
--- wireless-testing.orig/drivers/net/b44.c     2008-11-16
14:47:06.000000000 +0100
+++ wireless-testing/drivers/net/b44.c  2008-11-16 15:03:35.000000000 +0100
@@ -1266,8 +1266,14 @@ static void b44_clear_stats(struct b44 *
 static void b44_chip_reset(struct b44 *bp, int reset_kind)
 {
       struct ssb_device *sdev = bp->sdev;
+       bool was_enabled;

-       if (ssb_device_is_enabled(bp->sdev)) {
+       was_enabled = ssb_device_is_enabled(bp->sdev);
+
+       ssb_device_enable(bp->sdev, 0);
+       ssb_pcicore_dev_irqvecs_enable(&sdev->bus->pcicore, sdev);
+
+       if (was_enabled) {
               bw32(bp, B44_RCV_LAZY, 0);
               bw32(bp, B44_ENET_CTRL, ENET_CTRL_DISABLE);
               b44_wait_bit(bp, B44_ENET_CTRL, ENET_CTRL_DISABLE, 200, 1);
@@ -1279,10 +1285,8 @@ static void b44_chip_reset(struct b44 *b
               }
               bw32(bp, B44_DMARX_CTRL, 0);
               bp->rx_prod = bp->rx_cons = 0;
-       } else
-               ssb_pcicore_dev_irqvecs_enable(&sdev->bus->pcicore, sdev);
+       }

-       ssb_device_enable(bp->sdev, 0);
       b44_clear_stats(bp);

       /*

--
Greetings Michael.
