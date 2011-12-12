From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH] can: flexcan: fix irq flooding by clearing all interrupt
 sources
Date: Mon, 12 Dec 2011 16:09:28 +0100
Message-ID: <4EE61928.10608@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-can@vger.kernel.org, Reuben Dowle <Reuben.Dowle@navico.com>,
	=?ISO-8859-1?Q?Lothar_Wa=DFmann?= <LW@KARO-electronics.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As pointed out by Reuben Dowle and Lothar Wa=DFmann, the TWRN_INT,
RWRN_INT, BOFF_INT interrupt sources need to be cleared as well
to avoid interrupt flooding, at least for the Flexcan on i.MX28
SOCs. Furthermore, the interrupts are only cleared, if really one
of those interrupt sources are pending (which is not the case for
rx and tx done).

CC: Reuben Dowle <Reuben.Dowle@navico.com>
CC: Lothar Wa=DFmann <LW@KARO-electronics.de>
Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/flexcan.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 165a4c7..111f154 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -118,6 +118,9 @@
 	(FLEXCAN_ESR_TWRN_INT | FLEXCAN_ESR_RWRN_INT | FLEXCAN_ESR_BOFF_INT)
 #define FLEXCAN_ESR_ERR_ALL \
 	(FLEXCAN_ESR_ERR_BUS | FLEXCAN_ESR_ERR_STATE)
+#define FLEXCAN_ESR_ALL_INT \
+	(FLEXCAN_ESR_TWRN_INT | FLEXCAN_ESR_RWRN_INT | \
+	 FLEXCAN_ESR_BOFF_INT | FLEXCAN_ESR_ERR_INT)
=20
 /* FLEXCAN interrupt flag register (IFLAG) bits */
 #define FLEXCAN_TX_BUF_ID		8
@@ -577,7 +580,9 @@ static irqreturn_t flexcan_irq(int irq, void *dev_i=
d)
=20
 	reg_iflag1 =3D flexcan_read(&regs->iflag1);
 	reg_esr =3D flexcan_read(&regs->esr);
-	flexcan_write(FLEXCAN_ESR_ERR_INT, &regs->esr);	/* ACK err IRQ */
+	/* ACK all bus error and state change IRQ sources */
+	if (reg_esr & FLEXCAN_ESR_ALL_INT)
+		flexcan_write(reg_esr & FLEXCAN_ESR_ALL_INT, &regs->esr);
=20
 	/*
 	 * schedule NAPI in case of:
--=20
1.7.4.1

