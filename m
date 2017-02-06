From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/4] net: pxa168_eth: Do not clobber PHY link outside of state machine
Date: Mon,  6 Feb 2017 15:55:21 -0800
Message-ID: <20170206235523.23216-3-f.fainelli@gmail.com>
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

Since we don't have anything special, switch to the generic
phy_ethtool_get_link_ksettings() function now.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/marvell/pxa168_eth.c | 20 +-------------------
 1 file changed, 1 insertion(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 3376a19f1e19..28cb36d9e50a 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -274,8 +274,6 @@ enum hash_table_entry {
 	HASH_ENTRY_RECEIVE_DISCARD_BIT = 2
 };
 
-static int pxa168_get_link_ksettings(struct net_device *dev,
-				     struct ethtool_link_ksettings *cmd);
 static int pxa168_init_hw(struct pxa168_eth_private *pep);
 static int pxa168_init_phy(struct net_device *dev);
 static void eth_port_reset(struct net_device *dev);
@@ -987,10 +985,6 @@ static int pxa168_init_phy(struct net_device *dev)
 	if (err)
 		return err;
 
-	err = pxa168_get_link_ksettings(dev, &cmd);
-	if (err)
-		return err;
-
 	cmd.base.phy_address = pep->phy_addr;
 	cmd.base.speed = pep->phy_speed;
 	cmd.base.duplex = pep->phy_duplex;
@@ -1370,18 +1364,6 @@ static int pxa168_eth_do_ioctl(struct net_device *dev, struct ifreq *ifr,
 	return -EOPNOTSUPP;
 }
 
-static int pxa168_get_link_ksettings(struct net_device *dev,
-				     struct ethtool_link_ksettings *cmd)
-{
-	int err;
-
-	err = phy_read_status(dev->phydev);
-	if (err == 0)
-		err = phy_ethtool_ksettings_get(dev->phydev, cmd);
-
-	return err;
-}
-
 static void pxa168_get_drvinfo(struct net_device *dev,
 			       struct ethtool_drvinfo *info)
 {
@@ -1396,7 +1378,7 @@ static const struct ethtool_ops pxa168_ethtool_ops = {
 	.nway_reset	= phy_ethtool_nway_reset,
 	.get_link	= ethtool_op_get_link,
 	.get_ts_info	= ethtool_op_get_ts_info,
-	.get_link_ksettings = pxa168_get_link_ksettings,
+	.get_link_ksettings = phy_ethtool_get_link_ksettings,
 	.set_link_ksettings = phy_ethtool_set_link_ksettings,
 };
 
-- 
2.9.3
