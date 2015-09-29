From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: fix preparation of a port STP update
Date: Tue, 29 Sep 2015 12:38:36 -0400
Message-ID: <1443544716-9130-1-git-send-email-vivien.didelot@savoirfairelinux.com>
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

Reported-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 0ae427c..02a3af8 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -453,12 +453,17 @@ static int dsa_slave_port_attr_set(struct net_device *dev,
 				   struct switchdev_attr *attr,
 				   struct switchdev_trans *trans)
 {
-	int ret = 0;
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	int ret;
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_PORT_STP_STATE:
-		if (switchdev_trans_ph_commit(trans))
-			ret = dsa_slave_stp_update(dev, attr->u.stp_state);
+		if (switchdev_trans_ph_prepare(trans))
+			ret = ds->drv->port_stp_update ? 0 : -EOPNOTSUPP;
+		else
+			ret = ds->drv->port_stp_update(ds, p->port,
+						       attr->u.stp_state);
 		break;
 	default:
 		ret = -EOPNOTSUPP;
-- 
2.6.0
