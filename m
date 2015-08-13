From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/7] net: dsa: mv88e6xxx: flush VTU and STU entries
Date: Thu, 13 Aug 2015 12:52:18 -0400
Message-ID: <1439484743-5126-3-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1439484743-5126-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"Chris Healy" <cphealy@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:53728 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753192AbbHMQw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 12:52:29 -0400
In-Reply-To: <1439484743-5126-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement the VTU Flush operation (which also flushes the STU), so that
warm boots won't preserved old entries.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 34 ++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  2 ++
 2 files changed, 36 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 9978245..175353a 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1182,6 +1182,34 @@ int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state)
 	return 0;
 }
 
+static int _mv88e6xxx_vtu_wait(struct dsa_switch *ds)
+{
+	return _mv88e6xxx_wait(ds, REG_GLOBAL, GLOBAL_VTU_OP,
+			       GLOBAL_VTU_OP_BUSY);
+}
+
+static int _mv88e6xxx_vtu_cmd(struct dsa_switch *ds, u16 op)
+{
+	int ret;
+
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_OP, op);
+	if (ret < 0)
+		return ret;
+
+	return _mv88e6xxx_vtu_wait(ds);
+}
+
+static int _mv88e6xxx_vtu_stu_flush(struct dsa_switch *ds)
+{
+	int ret;
+
+	ret = _mv88e6xxx_vtu_wait(ds);
+	if (ret < 0)
+		return ret;
+
+	return _mv88e6xxx_vtu_cmd(ds, GLOBAL_VTU_OP_FLUSH_ALL);
+}
+
 static int _mv88e6xxx_atu_mac_write(struct dsa_switch *ds,
 				    const unsigned char *addr)
 {
@@ -2071,6 +2099,12 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 	/* Wait for the flush to complete. */
 	mutex_lock(&ps->smi_mutex);
 	ret = _mv88e6xxx_stats_wait(ds);
+	if (ret < 0)
+		goto unlock;
+
+	/* Clear all the VTU and STU entries */
+	ret = _mv88e6xxx_vtu_stu_flush(ds);
+unlock:
 	mutex_unlock(&ps->smi_mutex);
 
 	return ret;
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 10fae32..76139ea 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -188,6 +188,8 @@
 #define GLOBAL_CONTROL_TCAM_EN		BIT(1)
 #define GLOBAL_CONTROL_EEPROM_DONE_EN	BIT(0)
 #define GLOBAL_VTU_OP		0x05
+#define GLOBAL_VTU_OP_BUSY	BIT(15)
+#define GLOBAL_VTU_OP_FLUSH_ALL		((0x01 << 12) | GLOBAL_VTU_OP_BUSY)
 #define GLOBAL_VTU_VID		0x06
 #define GLOBAL_VTU_DATA_0_3	0x07
 #define GLOBAL_VTU_DATA_4_7	0x08
-- 
2.5.0
