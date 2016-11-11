From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 06/11] net: dsa: mv88e6xxx: Add mv88e6390 stats snapshot operation
Date: Fri, 11 Nov 2016 03:53:38 +0100
Message-ID: <1478832823-31471-7-git-send-email-andrew@lunn.ch>
References: <1478832823-31471-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34630 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964823AbcKKCyC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 21:54:02 -0500
In-Reply-To: <1478832823-31471-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MV88E6390 has a control register for what the histogram statistics
actually contain. This means the stat_snapshot method should not set
this information. So implement the 6390 stats_snapshot function without
these bits.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 18 ++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  4 +++-
 2 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index d4fc12d7021a..82e57aac00f1 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -803,6 +803,22 @@ static int mv88e6320_stats_snapshot(struct mv88e6xxx_chip *chip, int port)
 	return _mv88e6xxx_stats_snapshot(chip, port);
 }
 
+static int mv88e6390_stats_snapshot(struct mv88e6xxx_chip *chip, int port)
+{
+	int err;
+
+	port = (port + 1) << 5;
+
+	/* Snapshot the hardware statistics counters for this port. */
+	err = mv88e6xxx_g1_write(chip, GLOBAL_STATS_OP,
+				 GLOBAL_STATS_OP_CAPTURE_PORT | port);
+	if (err)
+		return err;
+
+	/* Wait for the snapshotting to complete. */
+	return _mv88e6xxx_stats_wait(chip);
+}
+
 static int mv88e6xxx_stats_snapshot(struct mv88e6xxx_chip *chip, int port)
 {
 	if (!chip->info->ops->stats_snapshot)
@@ -3367,6 +3383,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390_port_set_speed,
+	.stats_snapshot = mv88e6390_stats_snapshot,
 };
 
 static const struct mv88e6xxx_ops mv88e6390x_ops = {
@@ -3378,6 +3395,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390x_port_set_speed,
+	.stats_snapshot = mv88e6390_stats_snapshot,
 };
 
 static const struct mv88e6xxx_info mv88e6xxx_table[] = {
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index fd5352bf7625..147f1f3a817b 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -283,7 +283,9 @@
 #define GLOBAL_CONTROL_2	0x1c
 #define GLOBAL_CONTROL_2_NO_CASCADE		0xe000
 #define GLOBAL_CONTROL_2_MULTIPLE_CASCADE	0xf000
-
+#define GLOBAL_CONTROL_2_HIST_RX	       (0x1 << 6)
+#define GLOBAL_CONTROL_2_HIST_TX	       (0x2 << 6)
+#define GLOBAL_CONTROL_2_HIST_RX_TX	       (0x3 << 6)
 #define GLOBAL_STATS_OP		0x1d
 #define GLOBAL_STATS_OP_BUSY	BIT(15)
 #define GLOBAL_STATS_OP_NOP		(0 << 12)
-- 
2.10.2
