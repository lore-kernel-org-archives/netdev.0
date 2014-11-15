From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 2/3] net: dsa: mv88e6171: Add support for reading the temperature
Date: Sat, 15 Nov 2014 22:24:52 +0100
Message-ID: <1416086694-15790-3-git-send-email-andrew@lunn.ch>
References: <1416086694-15790-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, linux@roeck-us.net,
	Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:32990 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754707AbaKOVZV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Nov 2014 16:25:21 -0500
In-Reply-To: <1416086694-15790-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This chip also has a temperature sensor which can be read using the
common code. In order to use it, add the needed mutex protection for
accessing registers via the shared code.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6171.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 537eeedece21..ed4c79778823 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -316,6 +316,8 @@ static int mv88e6171_setup(struct dsa_switch *ds)
 			return ret;
 	}
 
+	mutex_init(&ps->phy_mutex);
+
 	return 0;
 }
 
@@ -329,18 +331,28 @@ static int mv88e6171_port_to_phy_addr(int port)
 static int
 mv88e6171_phy_read(struct dsa_switch *ds, int port, int regnum)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int addr = mv88e6171_port_to_phy_addr(port);
+	int ret;
 
-	return mv88e6xxx_phy_read(ds, addr, regnum);
+	mutex_lock(&ps->phy_mutex);
+	ret = mv88e6xxx_phy_read(ds, addr, regnum);
+	mutex_unlock(&ps->phy_mutex);
+	return ret;
 }
 
 static int
 mv88e6171_phy_write(struct dsa_switch *ds,
 		    int port, int regnum, u16 val)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int addr = mv88e6171_port_to_phy_addr(port);
+	int ret;
 
-	return mv88e6xxx_phy_write(ds, addr, regnum, val);
+	mutex_lock(&ps->phy_mutex);
+	ret = mv88e6xxx_phy_write(ds, addr, regnum, val);
+	mutex_unlock(&ps->phy_mutex);
+	return ret;
 }
 
 static struct mv88e6xxx_hw_stat mv88e6171_hw_stats[] = {
@@ -408,6 +420,9 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.get_strings		= mv88e6171_get_strings,
 	.get_ethtool_stats	= mv88e6171_get_ethtool_stats,
 	.get_sset_count		= mv88e6171_get_sset_count,
+#ifdef CONFIG_NET_DSA_HWMON
+	.get_temp               = mv88e6xxx_get_temp,
+#endif
 };
 
 MODULE_ALIAS("platform:mv88e6171");
-- 
2.1.3
