From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 2/3] net: dsa: make slave close symmetrical to open
Date: Fri, 22 Sep 2017 15:40:44 -0400
Message-ID: <20170922194045.18814-3-vivien.didelot@savoirfairelinux.com>
References: <20170922194045.18814-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170922194045.18814-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The DSA slave open function configures the unicast MAC addresses on the
master device, enable the switch port, change its STP state, then start
the PHY device.

Make the close function symmetric, by first stopping the PHY device,
then changing the STP state, disabling the switch port and restore the
master device.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/slave.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 3760472bf41d..0aab29928152 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -133,6 +133,11 @@ static int dsa_slave_close(struct net_device *dev)
 	if (dev->phydev)
 		phy_stop(dev->phydev);
 
+	dsa_port_set_state_now(p->dp, BR_STATE_DISABLED);
+
+	if (ds->ops->port_disable)
+		ds->ops->port_disable(ds, p->dp->index, dev->phydev);
+
 	dev_mc_unsync(master, dev);
 	dev_uc_unsync(master, dev);
 	if (dev->flags & IFF_ALLMULTI)
@@ -143,11 +148,6 @@ static int dsa_slave_close(struct net_device *dev)
 	if (!ether_addr_equal(dev->dev_addr, master->dev_addr))
 		dev_uc_del(master, dev->dev_addr);
 
-	if (ds->ops->port_disable)
-		ds->ops->port_disable(ds, p->dp->index, dev->phydev);
-
-	dsa_port_set_state_now(p->dp, BR_STATE_DISABLED);
-
 	return 0;
 }
 
-- 
2.14.1
