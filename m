From: Guenter Roeck <linux@roeck-us.net>
Subject: [RFT/RFC PATCH 2/8] net: dsa: mv88e6xxx: Provide function for common port initialization
Date: Mon, 23 Feb 2015 11:35:44 -0800
Message-ID: <1424720150-27564-3-git-send-email-linux@roeck-us.net>
References: <1424720150-27564-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:34255 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbbBWTgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 14:36:01 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YPynQ-003fCp-BA
	for netdev@vger.kernel.org; Mon, 23 Feb 2015 19:36:00 +0000
In-Reply-To: <1424720150-27564-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide mv88e6xxx_setup_port_common() for common port initialization.
Currently only implement VLAN configuration since this will be needed
for hardware bridging. More can be added later if desired/needed.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6xxx.c | 25 +++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  1 +
 2 files changed, 26 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 7b767e3..ca7a9c6 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -704,6 +704,31 @@ int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 	return 0;
 }
 
+int mv88e6xxx_setup_port_common(struct dsa_switch *ds, int port)
+{
+	u16 reg;
+
+	/* Port based VLAN map: give each port its own address
+	 * database, allow the CPU port to talk to each of the 'real'
+	 * ports, and allow each of the 'real' ports to only talk to
+	 * the upstream port.
+	 */
+	reg = (port & 0xf) << 12;
+	if (dsa_is_cpu_port(ds, port))
+		reg |= ds->phys_port_mask;
+	else
+		reg |= 1 << dsa_upstream_port(ds);
+
+	REG_WRITE(REG_PORT(port), 0x06, reg);
+
+	/* Default VLAN ID and priority: don't set a default VLAN
+	 * ID, and set the default packet priority to zero.
+	 */
+	REG_WRITE(REG_PORT(port), 0x07, 0x0000);
+
+	return 0;
+}
+
 int mv88e6xxx_setup_common(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index a02d95a..a4df496 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -57,6 +57,7 @@ struct mv88e6xxx_hw_stat {
 	int reg;
 };
 
+int mv88e6xxx_setup_port_common(struct dsa_switch *ds, int port);
 int mv88e6xxx_setup_common(struct dsa_switch *ds);
 int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg);
 int mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg);
-- 
2.1.0
