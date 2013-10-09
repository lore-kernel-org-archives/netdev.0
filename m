From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/3] can: flexcan: flexcan_chip_start: fix regression, mark one MB for TX and abort pending TX
Date: Wed,  9 Oct 2013 23:11:56 +0200
Message-ID: <1381353118-25111-2-git-send-email-mkl@pengutronix.de>
References: <1381353118-25111-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-stable <stable@vger.kernel.org>,
	=?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52484 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755275Ab3JIVMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 17:12:05 -0400
In-Reply-To: <1381353118-25111-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In patch

    0d1862e can: flexcan: fix flexcan_chip_start() on imx6

the loop in flexcan_chip_start() that iterates over all mailboxes after=
 the
soft reset of the CAN core was removed. This loop put all mailboxes (ev=
en the
ones marked as reserved 1...7) into EMPTY/INACTIVE mode. On mailboxes 8=
=2E..63,
this aborts any pending TX messages.

After a cold boot there is random garbage in the mailboxes, which leads=
 to
spontaneous transmit of CAN frames during first activation. Further if =
the
interface was disabled with a pending message (usually due to an error
condition on the CAN bus), this message is retransmitted after enabling=
 the
interface again.

This patch fixes the regression by:
1) Limiting the maximum number of used mailboxes to 8, 0...7 are used b=
y the RX
=46IFO, 8 is used by TX.
2) Marking the TX mailbox as EMPTY/INACTIVE, so that any pending TX of =
that
mailbox is aborted.

Cc: linux-stable <stable@vger.kernel.org>
Cc: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/flexcan.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 3f21142..f028c5d 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -62,7 +62,7 @@
 #define FLEXCAN_MCR_BCC			BIT(16)
 #define FLEXCAN_MCR_LPRIO_EN		BIT(13)
 #define FLEXCAN_MCR_AEN			BIT(12)
-#define FLEXCAN_MCR_MAXMB(x)		((x) & 0xf)
+#define FLEXCAN_MCR_MAXMB(x)		((x) & 0x1f)
 #define FLEXCAN_MCR_IDAM_A		(0 << 8)
 #define FLEXCAN_MCR_IDAM_B		(1 << 8)
 #define FLEXCAN_MCR_IDAM_C		(2 << 8)
@@ -735,9 +735,11 @@ static int flexcan_chip_start(struct net_device *d=
ev)
 	 *
 	 */
 	reg_mcr =3D flexcan_read(&regs->mcr);
+	reg_mcr &=3D ~FLEXCAN_MCR_MAXMB(0xff);
 	reg_mcr |=3D FLEXCAN_MCR_FRZ | FLEXCAN_MCR_FEN | FLEXCAN_MCR_HALT |
 		FLEXCAN_MCR_SUPV | FLEXCAN_MCR_WRN_EN |
-		FLEXCAN_MCR_IDAM_C | FLEXCAN_MCR_SRX_DIS;
+		FLEXCAN_MCR_IDAM_C | FLEXCAN_MCR_SRX_DIS |
+		FLEXCAN_MCR_MAXMB(FLEXCAN_TX_BUF_ID);
 	netdev_dbg(dev, "%s: writing mcr=3D0x%08x", __func__, reg_mcr);
 	flexcan_write(reg_mcr, &regs->mcr);
=20
@@ -771,6 +773,10 @@ static int flexcan_chip_start(struct net_device *d=
ev)
 	netdev_dbg(dev, "%s: writing ctrl=3D0x%08x", __func__, reg_ctrl);
 	flexcan_write(reg_ctrl, &regs->ctrl);
=20
+	/* Abort any pending TX, mark Mailbox as INACTIVE */
+	flexcan_write(FLEXCAN_MB_CNT_CODE(0x4),
+		      &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_ctrl);
+
 	/* acceptance mask/acceptance code (accept everything) */
 	flexcan_write(0x0, &regs->rxgmask);
 	flexcan_write(0x0, &regs->rx14mask);
--=20
1.8.4.rc3
