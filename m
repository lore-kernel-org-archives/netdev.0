From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/4] net: dsa: Do not clobber PHY link outside of state machine
Date: Mon,  6 Feb 2017 15:55:23 -0800
Message-ID: <20170206235523.23216-5-f.fainelli@gmail.com>
References: <20170206235523.23216-1-f.fainelli@gmail.com>
Cc: zefir.kurtisi@neratec.com, Florian Fainelli <f.fainelli@gmail.com>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Jisheng Zhang <jszhang@marvell.com>,
        Jarod Wilson <jarod@redhat.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170206235523.23216-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Calling phy_read_status() means that we may call into
genphy_read_status() which in turn will use genphy_update_link() which
can make changes to phydev->link outside of the state machine's state
transitions. This is an invalid behavior that is now caught as of
811a919135b9 ("phy state machine: failsafe leave invalid RUNNING state")

Reported-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/slave.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 09fc3e9462c1..4b6fb6b14de4 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -651,14 +651,10 @@ dsa_slave_get_link_ksettings(struct net_device *dev,
 			     struct ethtool_link_ksettings *cmd)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
-	int err;
+	int err = -EOPNOTSUPP;
 
-	err = -EOPNOTSUPP;
-	if (p->phy != NULL) {
-		err = phy_read_status(p->phy);
-		if (err == 0)
-			err = phy_ethtool_ksettings_get(p->phy, cmd);
-	}
+	if (p->phy != NULL)
+		err = phy_ethtool_ksettings_get(p->phy, cmd);
 
 	return err;
 }
-- 
2.9.3
