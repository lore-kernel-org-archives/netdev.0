From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 05/17] net: dsa: mv88e6xxx: enable ATU Learn2All
Date: Sat, 11 Mar 2017 16:12:51 -0500
Message-ID: <20170311211303.24560-6-vivien.didelot@savoirfairelinux.com>
References: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:54970 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753782AbdCKVPD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 16:15:03 -0500
In-Reply-To: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ATU Learn2All feature allows newly learnt addresses to be spanned on
ports marked as "Message Port", currently all DSA ports.

This commit enables this feature which is necessary and quite convenient
for multi-chip switch fabrics.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c        | 15 ++++++---------
 drivers/net/dsa/mv88e6xxx/global1.h     |  1 +
 drivers/net/dsa/mv88e6xxx/global1_atu.c | 17 +++++++++++++++++
 3 files changed, 24 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 5c1b5825fe6c..1ee0c05f624e 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1308,6 +1308,12 @@ static void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port,
 
 static int mv88e6xxx_atu_setup(struct mv88e6xxx_chip *chip)
 {
+	int err;
+
+	err = mv88e6xxx_g1_atu_set_learn2all(chip, true);
+	if (err)
+		return err;
+
 	return mv88e6xxx_g1_atu_set_age_time(chip, 300000);
 }
 
@@ -2756,15 +2762,6 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 	if (err < 0)
 		return err;
 
-	/* Set the default address aging time to 5 minutes, and
-	 * enable address learn messages to be sent to all message
-	 * ports.
-	 */
-	err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_CONTROL,
-				 GLOBAL_ATU_CONTROL_LEARN2ALL);
-	if (err)
-		return err;
-
 	/* Clear all ATU entries */
 	err = _mv88e6xxx_atu_flush(chip, 0, true);
 	if (err)
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index b8d0fb519bab..18322d05225a 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -38,6 +38,7 @@ int mv88e6095_g1_set_cpu_port(struct mv88e6xxx_chip *chip, int port);
 int mv88e6390_g1_set_cpu_port(struct mv88e6xxx_chip *chip, int port);
 int mv88e6390_g1_mgmt_rsvd2cpu(struct mv88e6xxx_chip *chip);
 
+int mv88e6xxx_g1_atu_set_learn2all(struct mv88e6xxx_chip *chip, bool learn2all);
 int mv88e6xxx_g1_atu_set_age_time(struct mv88e6xxx_chip *chip,
 				  unsigned int msecs);
 
diff --git a/drivers/net/dsa/mv88e6xxx/global1_atu.c b/drivers/net/dsa/mv88e6xxx/global1_atu.c
index 4d0ada9efc6d..843a21e05f7b 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_atu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_atu.c
@@ -15,6 +15,23 @@
 
 /* Offset 0x0A: ATU Control Register */
 
+int mv88e6xxx_g1_atu_set_learn2all(struct mv88e6xxx_chip *chip, bool learn2all)
+{
+	u16 val;
+	int err;
+
+	err = mv88e6xxx_g1_read(chip, GLOBAL_ATU_CONTROL, &val);
+	if (err)
+		return err;
+
+	if (learn2all)
+		val |= GLOBAL_ATU_CONTROL_LEARN2ALL;
+	else
+		val &= ~GLOBAL_ATU_CONTROL_LEARN2ALL;
+
+	return mv88e6xxx_g1_write(chip, GLOBAL_ATU_CONTROL, val);
+}
+
 int mv88e6xxx_g1_atu_set_age_time(struct mv88e6xxx_chip *chip,
 				  unsigned int msecs)
 {
-- 
2.12.0
