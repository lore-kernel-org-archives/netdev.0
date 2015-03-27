From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2 02/16] net: dsa: mv88e6xxx: Provide function for common port initialization
Date: Thu, 26 Mar 2015 18:36:29 -0700
Message-ID: <1427420203-27685-3-git-send-email-linux@roeck-us.net>
References: <1427420203-27685-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:39308 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753355AbbC0Bgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 21:36:54 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YbJCf-0020Vl-DZ
	for netdev@vger.kernel.org; Fri, 27 Mar 2015 01:36:53 +0000
In-Reply-To: <1427420203-27685-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide mv88e6xxx_setup_port_common() for common port initialization.
Currently only write Port 1 Control and VLAN configuration since
this will be needed for hardware bridging. More can be added later
if desired/needed.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Tested-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6xxx.c | 39 +++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  1 +
 2 files changed, 40 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 6496beb74510..2052e51edd5d 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -700,6 +700,45 @@ int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 	return 0;
 }
 
+int mv88e6xxx_setup_port_common(struct dsa_switch *ds, int port)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int ret, reg;
+
+	mutex_lock(&ps->smi_mutex);
+
+	/* Port Control 1: disable trunking.  Also, if this is the
+	 * CPU port, enable learn messages to be sent to this port.
+	 */
+	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), 0x05,
+				   dsa_is_cpu_port(ds, port) ? 0x8000 : 0x0000);
+	if (ret)
+		goto abort;
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
+	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), 0x06, reg);
+	if (ret)
+		goto abort;
+
+	/* Default VLAN ID and priority: don't set a default VLAN
+	 * ID, and set the default packet priority to zero.
+	 */
+	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), 0x07, 0x0000);
+abort:
+	mutex_unlock(&ps->smi_mutex);
+	return ret;
+}
+
 int mv88e6xxx_setup_common(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index a02d95a9b313..a4df4968594e 100644
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
