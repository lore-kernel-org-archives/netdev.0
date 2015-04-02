From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 12/12] net: dsa: mv88e6xxx: Fix stats counters for 6352 family
Date: Thu,  2 Apr 2015 04:06:40 +0200
Message-ID: <1427940400-12434-13-git-send-email-andrew@lunn.ch>
References: <1427940400-12434-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35850 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753113AbbDBCMF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 22:12:05 -0400
In-Reply-To: <1427940400-12434-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The statistic counters for the mv88e6172 never worked. This device is
a member of the 6352 family of chips, which has a slightly different
layout of the register used for capturing statistics. Add support for
detecting this family and poking the port in the right place in the
register.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Tested-by: Guenter Roeck <linux@roeck-us.net>
Reviewed-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6xxx.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 488b6545dfb5..fc8d3b6ffe8e 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -434,6 +434,19 @@ void mv88e6xxx_poll_link(struct dsa_switch *ds)
 	}
 }
 
+static bool mv88e6xxx_6352_family(struct dsa_switch *ds)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	switch (ps->id) {
+	case PORT_SWITCH_ID_6352:
+	case PORT_SWITCH_ID_6172:
+	case PORT_SWITCH_ID_6176:
+		return true;
+	}
+	return false;
+}
+
 static int mv88e6xxx_stats_wait(struct dsa_switch *ds)
 {
 	int ret;
@@ -452,6 +465,9 @@ static int mv88e6xxx_stats_snapshot(struct dsa_switch *ds, int port)
 {
 	int ret;
 
+	if (mv88e6xxx_6352_family(ds))
+		port = (port + 1) << 5;
+
 	/* Snapshot the hardware statistics counters for this port. */
 	REG_WRITE(REG_GLOBAL, GLOBAL_STATS_OP,
 		  GLOBAL_STATS_OP_CAPTURE_PORT |
-- 
2.1.4
