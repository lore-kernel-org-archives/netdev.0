From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 01/12] net: dsa: mv88e6131: Use common initialization functions
Date: Thu,  2 Apr 2015 03:21:48 +0200
Message-ID: <1427937719-11630-2-git-send-email-andrew@lunn.ch>
References: <1427937719-11630-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35726 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751735AbbDBB0F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 21:26:05 -0400
In-Reply-To: <1427937719-11630-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>

Common initialization functions will be needed to enable
HW bridging support.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6131.c | 33 +++++----------------------------
 1 file changed, 5 insertions(+), 28 deletions(-)

diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 2540ef0142af..0252d51c0a74 100644
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
@@ -278,20 +256,19 @@ static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
 	 */
 	REG_WRITE(addr, 0x19, 0x7654);
 
-	return 0;
+	return mv88e6xxx_setup_port_common(ds, p);
 }
 
 static int mv88e6131_setup(struct dsa_switch *ds)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
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
2.1.4
