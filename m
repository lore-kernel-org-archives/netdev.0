From: Matteo Fortini <matteo.fortini@gmail.com>
Subject: [PATCH] iMX: Fix for missed MII interrupts and MDIO timeouts when FEC
 is in STOP
Date: Fri, 22 Apr 2011 00:17:12 +0200
Message-ID: <BANLkTikRknZtjgDhCeNJv1FkhnWySwedUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:53763 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752998Ab1DUWRe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 18:17:34 -0400
Received: by iyb14 with SMTP id 14so124892iyb.19
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 15:17:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are experiencing unrecoverable timeouts if we disconnect a cable fro=
m the
=46EC. This patch solves the issue by keeping the Ethernet enabled even=
 in
STOP. The RM doesn't state it, but i seems that if disabled, the Ethern=
et is
not issuing interrupts to the core.
(See
http://forums.freescale.com/t5/i-MX-Microprocessors/iMX28-Network-MDIO-=
timeout-recovery-and-lost-IRQs/td-p/73309
)

The patch is against Freescale iMX tree from opensource.freescale.com/g=
it

---
=A0drivers/net/fec.c | =A0 =A07 ++++++-
=A01 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index d0e2e69..26ea72d 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -121,8 +121,10 @@
=A0#if defined(CONFIG_FEC_1588) && defined(CONFIG_ARCH_MX28)
=A0#define FEC_DEFAULT_IMASK (FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MI=
I | \
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 FEC_ENET_TS_AVAIL | FEC_ENET_TS_TIMER)
+#define FEC_STOP_IMASK (FEC_ENET_MII)
=A0#else
=A0#define FEC_DEFAULT_IMASK (FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MI=
I)
+#define FEC_STOP_IMASK (FEC_ENET_MII)
=A0#endif

=A0/* The FEC stores dest/src/type, data, and checksum for receive pack=
ets.
@@ -1409,6 +1411,9 @@ fec_stop(struct net_device *dev)
=A0 =A0 writel(1, fep->hwp + FEC_ECNTRL);
=A0 =A0 udelay(10);

+ =A0 =A0/* Reactivate the controller to get the IRQs */
+ =A0 =A0writel(0x00000002, fep->hwp + FEC_ECNTRL);
+
=A0#ifdef CONFIG_ARCH_MXS
=A0 =A0 /* Check MII or RMII */
=A0 =A0 if (fep->phy_interface =3D=3D PHY_INTERFACE_MODE_RMII)
@@ -1423,7 +1428,7 @@ fec_stop(struct net_device *dev)
=A0 =A0 writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
=A0 =A0 if (fep->ptimer_present)
=A0 =A0 =A0 =A0 fec_ptp_stop(fep->ptp_priv);
- =A0 =A0writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
+ =A0 =A0writel(FEC_STOP_IMASK, fep->hwp + FEC_IMASK);

=A0 =A0 netif_stop_queue(dev);
=A0 =A0 fep->link =3D 0;
--
1.7.4.2
