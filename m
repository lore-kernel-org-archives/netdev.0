From: Andrew Lunn <andrew@lunn.ch>
Subject: [Resend PATCHv2 net-next] net: mvneta: Fix clearing of MIB statistics
Date: Thu, 22 Oct 2015 18:11:12 +0200
Message-ID: <1445530272-12608-1-git-send-email-andrew@lunn.ch>
Cc: Russell King <rmk+kernel@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev <netdev@vger.kernel.org>, mw@semihalf.com,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40100 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756978AbbJVQLe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2015 12:11:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The existing function to clear the MIB statatistics was using the
wrong address for the registers. Also, the counters would of been
cleared when the interface was brought up, not during the
probe. Fix both of these.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
v2: Clear two other counters which are outside the normal range of
    registers.

To apply cleanly, this patch requires Russell Kings patch adding
ethtool statistics. Without it, some fuzz will be required.

Resend because i forgot to Cc: netdev.
---
 drivers/net/ethernet/marvell/mvneta.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 9f048ba92d0e..6660793eb94b 100644
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
2.5.1
