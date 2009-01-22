From: =?utf-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] am79c961a: fix spin_lock usage
Date: Thu, 22 Jan 2009 23:29:42 +0100
Message-ID: <1232663382-10503-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roel Kluin <12o3l@tiscali.nl>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Steven Rostedt <srostedt@redhat.com>, netdev@vger.kernel.org
To: linux-arm-kernel@lists.arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52356 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752897AbZAVWaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 17:30:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

spin_lock functions take a pointer to the lock, not the lock itself.
This error was noticed by compiling ebsa110_defconfig for linux-rt wher=
e
the locking functions obviously are more picky about their arguments.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
Cc: Roel Kluin <12o3l@tiscali.nl>
Cc: Russell King <rmk+kernel@arm.linux.org.uk>
Cc: Steven Rostedt <srostedt@redhat.com>
Cc: netdev@vger.kernel.org
---
Hello,

unrelated to that, with arm-linux-gnu-gcc 4.3.2 I get some warnings whe=
n
compiling am79c961a.c:

/tmp/ccAfRLG9.s: Assembler messages:
/tmp/ccAfRLG9.s:77: Warning: register range not in ascending order
/tmp/ccAfRLG9.s:615: Warning: register range not in ascending order
/tmp/ccAfRLG9.s:1242: Warning: register range not in ascending order

These correspond to lines 107[1] and 144 in am79c961a.c where inline
assembly is used.  E.g

	stm%?ia        %1!, {%2, %3}

so the order depends on the compilers choice for %2 and %3.

Best regards
Uwe

[1] 77 and 615 in the .s file both correspond to 107 in am79c961a.c.

 drivers/net/arm/am79c961a.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/arm/am79c961a.c b/drivers/net/arm/am79c961a.c
index 0c628a9..c2d012f 100644
--- a/drivers/net/arm/am79c961a.c
+++ b/drivers/net/arm/am79c961a.c
@@ -208,9 +208,9 @@ am79c961_init_for_open(struct net_device *dev)
 	/*
 	 * Stop the chip.
 	 */
-	spin_lock_irqsave(priv->chip_lock, flags);
+	spin_lock_irqsave(&priv->chip_lock, flags);
 	write_rreg (dev->base_addr, CSR0, CSR0_BABL|CSR0_CERR|CSR0_MISS|CSR0_=
MERR|CSR0_TINT|CSR0_RINT|CSR0_STOP);
-	spin_unlock_irqrestore(priv->chip_lock, flags);
+	spin_unlock_irqrestore(&priv->chip_lock, flags);
=20
 	write_ireg (dev->base_addr, 5, 0x00a0); /* Receive address LED */
 	write_ireg (dev->base_addr, 6, 0x0081); /* Collision LED */
@@ -332,10 +332,10 @@ am79c961_close(struct net_device *dev)
 	netif_stop_queue(dev);
 	netif_carrier_off(dev);
=20
-	spin_lock_irqsave(priv->chip_lock, flags);
+	spin_lock_irqsave(&priv->chip_lock, flags);
 	write_rreg (dev->base_addr, CSR0, CSR0_STOP);
 	write_rreg (dev->base_addr, CSR3, CSR3_MASKALL);
-	spin_unlock_irqrestore(priv->chip_lock, flags);
+	spin_unlock_irqrestore(&priv->chip_lock, flags);
=20
 	free_irq (dev->irq, dev);
=20
@@ -391,7 +391,7 @@ static void am79c961_setmulticastlist (struct net_d=
evice *dev)
 			am79c961_mc_hash(dmi, multi_hash);
 	}
=20
-	spin_lock_irqsave(priv->chip_lock, flags);
+	spin_lock_irqsave(&priv->chip_lock, flags);
=20
 	stopped =3D read_rreg(dev->base_addr, CSR0) & CSR0_STOP;
=20
@@ -405,9 +405,9 @@ static void am79c961_setmulticastlist (struct net_d=
evice *dev)
 		 * Spin waiting for chip to report suspend mode
 		 */
 		while ((read_rreg(dev->base_addr, CTRL1) & CTRL1_SPND) =3D=3D 0) {
-			spin_unlock_irqrestore(priv->chip_lock, flags);
+			spin_unlock_irqrestore(&priv->chip_lock, flags);
 			nop();
-			spin_lock_irqsave(priv->chip_lock, flags);
+			spin_lock_irqsave(&priv->chip_lock, flags);
 		}
 	}
=20
@@ -429,7 +429,7 @@ static void am79c961_setmulticastlist (struct net_d=
evice *dev)
 		write_rreg(dev->base_addr, CTRL1, 0);
 	}
=20
-	spin_unlock_irqrestore(priv->chip_lock, flags);
+	spin_unlock_irqrestore(&priv->chip_lock, flags);
 }
=20
 static void am79c961_timeout(struct net_device *dev)
@@ -467,10 +467,10 @@ am79c961_sendpacket(struct sk_buff *skb, struct n=
et_device *dev)
 	am_writeword (dev, hdraddr + 2, TMD_OWN|TMD_STP|TMD_ENP);
 	priv->txhead =3D head;
=20
-	spin_lock_irqsave(priv->chip_lock, flags);
+	spin_lock_irqsave(&priv->chip_lock, flags);
 	write_rreg (dev->base_addr, CSR0, CSR0_TDMD|CSR0_IENA);
 	dev->trans_start =3D jiffies;
-	spin_unlock_irqrestore(priv->chip_lock, flags);
+	spin_unlock_irqrestore(&priv->chip_lock, flags);
=20
 	/*
 	 * If the next packet is owned by the ethernet device,
--=20
tg: (cdba4b7..) t/armmisc/spinlock-am79c961a (depends on: rmk/master)
