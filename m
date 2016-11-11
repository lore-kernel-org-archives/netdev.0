From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 07/11] net: dsa: mv88e6xxx: Add mv88e6390 statistics unit init
Date: Fri, 11 Nov 2016 03:53:39 +0100
Message-ID: <1478832823-31471-8-git-send-email-andrew@lunn.ch>
References: <1478832823-31471-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34659 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964823AbcKKC4Y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 21:56:24 -0500
In-Reply-To: <1478832823-31471-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The statistics unit on the mv88e6390 needs to the configured in a
different register to the others as to what histogram statistics is
should return.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 31 +++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  2 ++
 2 files changed, 33 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 82e57aac00f1..b20732616031 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1031,6 +1031,30 @@ static void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds, int port,
 	mutex_unlock(&chip->reg_lock);
 }
 
+static int mv88e6390_stats_init(struct mv88e6xxx_chip *chip)
+{
+	u16 val;
+	int err;
+
+	err = mv88e6xxx_g1_read(chip, GLOBAL_CONTROL_2, &val);
+	if (err)
+		return err;
+
+	val |= GLOBAL_CONTROL_2_HIST_RX_TX;
+
+	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL_2, val);
+
+	return err;
+}
+
+static int mv88e6xxx_stats_init(struct mv88e6xxx_chip *chip)
+{
+	if (chip->info->ops->stats_init)
+		return chip->info->ops->stats_init(chip);
+
+	return 0;
+}
+
 static int mv88e6xxx_get_regs_len(struct dsa_switch *ds, int port)
 {
 	return 32 * sizeof(u16);
@@ -2819,6 +2843,11 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 	if (err)
 		return err;
 
+	/* Initialize the statistics unit */
+	err = mv88e6xxx_stats_init(chip);
+	if (err)
+		return err;
+
 	/* Clear the statistics counters for all ports */
 	err = mv88e6xxx_g1_write(chip, GLOBAL_STATS_OP,
 				 GLOBAL_STATS_OP_FLUSH_ALL);
@@ -3383,6 +3412,7 @@ static const struct mv88e6xxx_ops mv88e6390_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390_port_set_speed,
+	.stats_init = mv88e6390_stats_init,
 	.stats_snapshot = mv88e6390_stats_snapshot,
 };
 
@@ -3395,6 +3425,7 @@ static const struct mv88e6xxx_ops mv88e6390x_ops = {
 	.port_set_duplex = mv88e6xxx_port_set_duplex,
 	.port_set_rgmii_delay = mv88e6390_port_set_rgmii_delay,
 	.port_set_speed = mv88e6390x_port_set_speed,
+	.stats_init = mv88e6390_stats_init,
 	.stats_snapshot = mv88e6390_stats_snapshot,
 };
 
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 147f1f3a817b..86dbdc957f28 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -796,6 +796,8 @@ struct mv88e6xxx_ops {
 	 */
 	int (*port_set_speed)(struct mv88e6xxx_chip *chip, int port, int speed);
 
+	int (*stats_init)(struct mv88e6xxx_chip *chip);
+
 	/* Snapshot the statistics for a port. The statistics can then
 	 * be read back a leisure but still with a consistent view.
 	 */
-- 
2.10.2
