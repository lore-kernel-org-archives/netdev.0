From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net] net: dsa: fix preparation of a port STP update
Date: Tue, 29 Sep 2015 14:17:54 -0400
Message-ID: <1443550674-26537-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Because of the default 0 value of ret in dsa_slave_port_attr_set, a
driver may return -EOPNOTSUPP from the commit phase of a STP state,
which triggers a WARN() from switchdev.

This happened on a 6185 switch which does not support hardware bridging.

Fixes: 3563606258cf ("switchdev: convert STP update to switchdev attr set")
Reported-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index cce9738..7d91f46 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -458,12 +458,17 @@ static int dsa_slave_stp_update(struct net_device *dev, u8 state)
 static int dsa_slave_port_attr_set(struct net_device *dev,
 				   struct switchdev_attr *attr)
 {
-	int ret = 0;
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	int ret;
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_PORT_STP_STATE:
-		if (attr->trans == SWITCHDEV_TRANS_COMMIT)
-			ret = dsa_slave_stp_update(dev, attr->u.stp_state);
+		if (attr->trans == SWITCHDEV_TRANS_PREPARE)
+			ret = ds->drv->port_stp_update ? 0 : -EOPNOTSUPP;
+		else
+			ret = ds->drv->port_stp_update(ds, p->port,
+						       attr->u.stp_state);
 		break;
 	default:
 		ret = -EOPNOTSUPP;
-- 
2.6.0
