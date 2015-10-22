From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH v2 2/2] net: mvneta: Fix clearing of MIB statistics
Date: Thu, 22 Oct 2015 18:00:50 +0100
Message-ID: <E1ZpJEQ-0001nh-2w@rmk-PC.arm.linux.org.uk>
References: <20151022170013.GV32532@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Andrew Lunn <andrew@lunn.ch>, Marcin Wojtas <mw@semihalf.com>,
	netdev@vger.kernel.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:56472 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965351AbbJVRAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 13:00:55 -0400
In-Reply-To: <20151022170013.GV32532@n2100.arm.linux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>

The existing function to clear the MIB statatistics was using the
wrong address for the registers. Also, the counters would of been
cleared when the interface was brought up, not during the
probe. Fix both of these.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/marvell/mvneta.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 69d80ca4fba2..8829c481fe1b 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -100,6 +100,8 @@
 #define MVNETA_TXQ_CMD                           0x2448
 #define      MVNETA_TXQ_DISABLE_SHIFT            8
 #define      MVNETA_TXQ_ENABLE_MASK              0x000000ff
+#define MVNETA_RX_DISCARD_FRAME_COUNT		 0x2484
+#define MVNETA_OVERRUN_FRAME_COUNT		 0x2488
 #define MVNETA_GMAC_CLOCK_DIVIDER                0x24f4
 #define      MVNETA_GMAC_1MS_CLOCK_ENABLE        BIT(31)
 #define MVNETA_ACC_MODE                          0x2500
@@ -191,7 +193,7 @@
 #define      MVNETA_GMAC_AN_FLOW_CTRL_EN         BIT(11)
 #define      MVNETA_GMAC_CONFIG_FULL_DUPLEX      BIT(12)
 #define      MVNETA_GMAC_AN_DUPLEX_EN            BIT(13)
-#define MVNETA_MIB_COUNTERS_BASE                 0x3080
+#define MVNETA_MIB_COUNTERS_BASE                 0x3000
 #define      MVNETA_MIB_LATE_COLLISION           0x7c
 #define MVNETA_DA_FILT_SPEC_MCAST                0x3400
 #define MVNETA_DA_FILT_OTH_MCAST                 0x3500
@@ -564,6 +566,8 @@ static void mvneta_mib_counters_clear(struct mvneta_port *pp)
 	/* Perform dummy reads from MIB counters */
 	for (i = 0; i < MVNETA_MIB_LATE_COLLISION; i += 4)
 		dummy = mvreg_read(pp, (MVNETA_MIB_COUNTERS_BASE + i));
+	dummy = mvreg_read(pp, MVNETA_RX_DISCARD_FRAME_COUNT);
+	dummy = mvreg_read(pp, MVNETA_OVERRUN_FRAME_COUNT);
 }
 
 /* Get System Network Statistics */
@@ -792,7 +796,6 @@ static void mvneta_port_up(struct mvneta_port *pp)
 	u32 q_map;
 
 	/* Enable all initialized TXs. */
-	mvneta_mib_counters_clear(pp);
 	q_map = 0;
 	for (queue = 0; queue < txq_number; queue++) {
 		struct mvneta_tx_queue *txq = &pp->txqs[queue];
@@ -1076,6 +1079,8 @@ static void mvneta_defaults_set(struct mvneta_port *pp)
 	mvreg_write(pp, MVNETA_INTR_ENABLE,
 		    (MVNETA_RXQ_INTR_ENABLE_ALL_MASK
 		     | MVNETA_TXQ_INTR_ENABLE_ALL_MASK));
+
+	mvneta_mib_counters_clear(pp);
 }
 
 /* Set max sizes for tx queues */
-- 
2.1.0
