From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH net-next 15/24] dsa: Register netdev before phy
Date: Mon,  4 Jan 2016 18:36:53 +0100
Message-ID: <1451929022-5580-16-git-send-email-andrew@lunn.ch>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35010 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752839AbcADRjW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 12:39:22 -0500
In-Reply-To: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the phy is connected, an info message is printed. If the netdev
it is attached to has not been registered yet, the name
'uninitialised' in the output. By registering the netdev first, then
connecting they phy, we can avoid this.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/slave.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 68fae0cf17cd..25606c1b963d 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1187,13 +1187,6 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	p->old_link = -1;
 	p->old_duplex = -1;
 
-	ret = dsa_slave_phy_setup(p, slave_dev);
-	if (ret) {
-		netdev_err(master, "error %d setting up slave phy\n", ret);
-		free_netdev(slave_dev);
-		return ret;
-	}
-
 	ds->ports[port] = slave_dev;
 	ret = register_netdev(slave_dev);
 	if (ret) {
@@ -1205,6 +1198,13 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 		return ret;
 	}
 
+	ret = dsa_slave_phy_setup(p, slave_dev);
+	if (ret) {
+		netdev_err(master, "error %d setting up slave phy\n", ret);
+		free_netdev(slave_dev);
+		return ret;
+	}
+
 	netif_carrier_off(slave_dev);
 
 	return 0;
-- 
2.6.4
