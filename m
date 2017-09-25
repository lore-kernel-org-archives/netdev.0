From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: dsa: Fix network device registration order
Date: Mon, 25 Sep 2017 15:55:53 -0700
Message-ID: <20170925225553.566-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We cannot be registering the network device first, then setting its
carrier off and finally connecting it to a PHY, doing that leaves a
window during which the carrier is at best inconsistent, and at worse
the device is not usable without a down/up sequence since the network
device is visible to user space with possibly no PHY device attached.

Re-order steps so that they make logical sense. This fixes some devices
where the port was not usable after e.g: an unbind then bind of the
driver.

Fixes: 0071f56e46da ("dsa: Register netdev before phy")
Fixes: 91da11f870f0 ("net: Distributed Switch Architecture protocol support")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/slave.c | 31 ++++++++++++++++++-------------
 1 file changed, 18 insertions(+), 13 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 2afa99506f8b..865e29e62bad 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1301,28 +1301,33 @@ int dsa_slave_create(struct dsa_port *port, const char *name)
 	p->old_duplex = -1;
 
 	port->netdev = slave_dev;
-	ret = register_netdev(slave_dev);
-	if (ret) {
-		netdev_err(master, "error %d registering interface %s\n",
-			   ret, slave_dev->name);
-		port->netdev = NULL;
-		free_percpu(p->stats64);
-		free_netdev(slave_dev);
-		return ret;
-	}
 
 	netif_carrier_off(slave_dev);
 
 	ret = dsa_slave_phy_setup(p, slave_dev);
 	if (ret) {
 		netdev_err(master, "error %d setting up slave phy\n", ret);
-		unregister_netdev(slave_dev);
-		free_percpu(p->stats64);
-		free_netdev(slave_dev);
-		return ret;
+		goto out_free;
+	}
+
+	ret = register_netdev(slave_dev);
+	if (ret) {
+		netdev_err(master, "error %d registering interface %s\n",
+			   ret, slave_dev->name);
+		goto out_phy;
 	}
 
 	return 0;
+
+out_phy:
+	phy_disconnect(p->phy);
+	if (of_phy_is_fixed_link(p->dp->dn))
+		of_phy_deregister_fixed_link(p->dp->dn);
+out_free:
+	free_percpu(p->stats64);
+	free_netdev(slave_dev);
+	port->netdev = NULL;
+	return ret;
 }
 
 void dsa_slave_destroy(struct net_device *slave_dev)
-- 
2.9.3
