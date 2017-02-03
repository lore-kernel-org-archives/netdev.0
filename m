From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/6] net: dsa: rollback bridging on error
Date: Fri,  3 Feb 2017 13:20:18 -0500
Message-ID: <20170203182021.14246-4-vivien.didelot@savoirfairelinux.com>
References: <20170203182021.14246-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, cphealy@gmail.com,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:40088 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751865AbdBCSVS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 13:21:18 -0500
In-Reply-To: <20170203182021.14246-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an error is returned during the bridging of a port in a
NETDEV_CHANGEUPPER event, net/core/dev.c rolls back the operation.

Be consistent and unassign dp->bridge_dev when this happens.

In the meantime, add comments to document this behavior.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 332eb234dc21..d726307c7795 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -562,12 +562,21 @@ static int dsa_slave_bridge_port_join(struct net_device *dev,
 	struct dsa_switch *ds = p->dp->ds;
 	int ret = -EOPNOTSUPP;
 
+	/* Here the port is already bridged. Reflect the current configuration
+	 * so that drivers can program their chips accordingly.
+	 */
 	p->dp->bridge_dev = br;
 
 	if (ds->ops->port_bridge_join)
 		ret = ds->ops->port_bridge_join(ds, p->dp->index, br);
 
-	return ret == -EOPNOTSUPP ? 0 : ret;
+	/* The bridging is rolled back on error */
+	if (ret && ret != -EOPNOTSUPP) {
+		p->dp->bridge_dev = NULL;
+		return ret;
+	}
+
+	return 0;
 }
 
 static void dsa_slave_bridge_port_leave(struct net_device *dev,
@@ -576,6 +585,9 @@ static void dsa_slave_bridge_port_leave(struct net_device *dev,
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->dp->ds;
 
+	/* Here the port is already unbridged. Reflect the current configuration
+	 * so that drivers can program their chips accordingly.
+	 */
 	p->dp->bridge_dev = NULL;
 
 	if (ds->ops->port_bridge_leave)
-- 
2.11.0
