From: Guenter Roeck <linux@roeck-us.net>
Subject: [RFT PATCH 17/18] net: dsa: mv88e6131: Use common initialization functions
Date: Sat, 21 Mar 2015 08:46:54 -0700
Message-ID: <1426952815-4642-18-git-send-email-linux@roeck-us.net>
References: <1426952815-4642-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:40429 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510AbbCUPsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 11:48:10 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YZLdB-0001ra-IF
	for netdev@vger.kernel.org; Sat, 21 Mar 2015 15:48:09 +0000
In-Reply-To: <1426952815-4642-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Common initialization functions will be needed to enable
HW bridging support.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6131.c | 32 +++++---------------------------
 1 file changed, 5 insertions(+), 27 deletions(-)

diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 2540ef0..98a3668 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -208,28 +208,6 @@ static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
 		val |= 0x0100;
 	REG_WRITE(addr, 0x04, val);
 
-	/* Port Control 1: disable trunking.  Also, if this is the
-	 * CPU port, enable learn messages to be sent to this port.
-	 */
-	REG_WRITE(addr, 0x05, dsa_is_cpu_port(ds, p) ? 0x8000 : 0x0000);
-
-	/* Port based VLAN map: give each port its own address
-	 * database, allow the CPU port to talk to each of the 'real'
-	 * ports, and allow each of the 'real' ports to only talk to
-	 * the upstream port.
-	 */
-	val = (p & 0xf) << 12;
-	if (dsa_is_cpu_port(ds, p))
-		val |= ds->phys_port_mask;
-	else
-		val |= 1 << dsa_upstream_port(ds);
-	REG_WRITE(addr, 0x06, val);
-
-	/* Default VLAN ID and priority: don't set a default VLAN
-	 * ID, and set the default packet priority to zero.
-	 */
-	REG_WRITE(addr, 0x07, 0x0000);
-
 	/* Port Control 2: don't force a good FCS, don't use
 	 * VLAN-based, source address-based or destination
 	 * address-based priority overrides, don't let the switch
@@ -278,7 +256,7 @@ static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
 	 */
 	REG_WRITE(addr, 0x19, 0x7654);
 
-	return 0;
+	return mv88e6xxx_setup_port_common(ds, p);
 }
 
 static int mv88e6131_setup(struct dsa_switch *ds)
@@ -287,11 +265,11 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 	int i;
 	int ret;
 
-	mutex_init(&ps->smi_mutex);
-	mv88e6xxx_ppu_state_init(ds);
-	mutex_init(&ps->stats_mutex);
+	ret = mv88e6xxx_setup_common(ds);
+	if (ret < 0)
+		return ret;
 
-	ps->id = REG_READ(REG_PORT(0), 0x03) & 0xfff0;
+	mv88e6xxx_ppu_state_init(ds);
 
 	ret = mv88e6131_switch_reset(ds);
 	if (ret < 0)
-- 
2.1.0
