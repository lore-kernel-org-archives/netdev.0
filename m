From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/2] net/bonding: correctly proxy slave neigh param setup ndo function
Date: Mon,  2 Apr 2012 19:17:10 +0300
Message-ID: <1333383430-17456-3-git-send-email-ogerlitz@mellanox.com>
References: <1333383430-17456-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, fubar@us.ibm.com,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:37258 "HELO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752391Ab2DBQRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 12:17:24 -0400
In-Reply-To: <1333383430-17456-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shlomo Pongratz <shlomop@mellanox.com>

The current implemenation was buggy for slaves who use ndo_neigh_setup,
since the networking stack invokes the bonding device ndo entry (from
neigh_params_alloc) before any devices are enslaved, and the bonding
driver can't further delegate the call at that point in time. As a
result when bonding IPoIB devices, the neigh_cleanup hasn't been called.

Fix that by deferring the actual call into the slave ndo_neigh_setup
from the time the bonding neigh_setup is called.

Signed-off-by: Shlomo Pongratz <shlomop@mellanox.com>
---
 drivers/net/bonding/bond_main.c |   51 ++++++++++++++++++++++++++++++++------
 1 files changed, 43 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b0a278d..2eed155 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3707,17 +3707,52 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
 	read_unlock(&bond->lock);
 }
 
-static int bond_neigh_setup(struct net_device *dev, struct neigh_parms *parms)
+static int bond_neigh_init(struct neighbour *n)
 {
-	struct bonding *bond = netdev_priv(dev);
+	struct bonding *bond = netdev_priv(n->dev);
 	struct slave *slave = bond->first_slave;
+	const struct net_device_ops *slave_ops;
+	struct neigh_parms parms;
+	int ret;
+
+	if (!slave)
+		return 0;
+
+	slave_ops = slave->dev->netdev_ops;
+
+	if (!slave_ops->ndo_neigh_setup)
+		return 0;
+
+	parms.neigh_setup = NULL;
+	parms.neigh_cleanup = NULL;
+	ret = slave_ops->ndo_neigh_setup(slave->dev, &parms);
+	if (ret)
+		return ret;
+
+	/*
+	 * must bind here to the slave clenaup. Since when last slave is removed
+	 * there will be no slave device to dereference in a bonding
+	 * neigh_cleanup function that we have could add.
+	 */
+	n->parms->neigh_cleanup = parms.neigh_cleanup;
+
+	/* Does slave implement neigh_setup ? */
+	if (!parms.neigh_setup)
+		return 0;
+
+	return parms.neigh_setup(n);
+}
+
+/*
+ * The bonding ndo_neigh_setup is called at init time beofre any
+ * slave exists. So we must declare proxy setup function which will
+ * be used at run time to resolve the actual slave neigh param setup.
+ */
+static int bond_neigh_setup(struct net_device *dev,
+			    struct neigh_parms *parms)
+{
+	parms->neigh_setup   = bond_neigh_init;
 
-	if (slave) {
-		const struct net_device_ops *slave_ops
-			= slave->dev->netdev_ops;
-		if (slave_ops->ndo_neigh_setup)
-			return slave_ops->ndo_neigh_setup(slave->dev, parms);
-	}
 	return 0;
 }
 
-- 
1.7.1
