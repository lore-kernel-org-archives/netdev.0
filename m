From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 15/22] dsa: Register netdev before phy
Date: Wed,  6 Jan 2016 20:11:20 +0100
Message-ID: <1452107487-475-16-git-send-email-andrew@lunn.ch>
References: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42372 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751998AbcAFTNk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 14:13:40 -0500
In-Reply-To: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the phy is connected, an info message is printed. If the netdev
it is attached to has not been registered yet, the name
'uninitialised' in the output. By registering the netdev first, then
connecting they phy, we can avoid this.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
v2: call netif_carrier_off() before dsa_slave_phy_setup()
---
 net/dsa/slave.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 2771713714f1..40b9ca72aae3 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1189,13 +1189,6 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
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
@@ -1209,6 +1202,13 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 
 	netif_carrier_off(slave_dev);
 
+	ret = dsa_slave_phy_setup(p, slave_dev);
+	if (ret) {
+		netdev_err(master, "error %d setting up slave phy\n", ret);
+		free_netdev(slave_dev);
+		return ret;
+	}
+
 	return 0;
 }
 
-- 
2.6.4
