From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 6/6] net: dsa: remove port_fdb_getnext
Date: Tue, 13 Oct 2015 11:43:03 -0400
Message-ID: <1444750983-14726-7-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1444750983-14726-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444750983-14726-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No driver implements port_fdb_getnext anymore, and port_fdb_dump is
preferred anyway, so remove this function from DSA.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h |  3 ---
 net/dsa/slave.c   | 25 +------------------------
 2 files changed, 1 insertion(+), 27 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index c5c48c5..d8ab2f9 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -329,9 +329,6 @@ struct dsa_switch_driver {
 				struct switchdev_trans *trans);
 	int	(*port_fdb_del)(struct dsa_switch *ds, int port,
 				const struct switchdev_obj_port_fdb *fdb);
-	int	(*port_fdb_getnext)(struct dsa_switch *ds, int port,
-				    unsigned char *addr, u16 *vid,
-				    bool *is_static);
 	int	(*port_fdb_dump)(struct dsa_switch *ds, int port,
 				 struct switchdev_obj_port_fdb *fdb,
 				 switchdev_obj_dump_cb_t *cb);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index a4e3416..5908893 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -378,34 +378,11 @@ static int dsa_slave_port_fdb_dump(struct net_device *dev,
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
-	unsigned char addr[ETH_ALEN] = { 0 };
-	u16 vid = 0;
-	int ret;
 
 	if (ds->drv->port_fdb_dump)
 		return ds->drv->port_fdb_dump(ds, p->port, fdb, cb);
 
-	if (!ds->drv->port_fdb_getnext)
-		return -EOPNOTSUPP;
-
-	for (;;) {
-		bool is_static;
-
-		ret = ds->drv->port_fdb_getnext(ds, p->port, addr, &vid,
-						&is_static);
-		if (ret < 0)
-			break;
-
-		fdb->addr = addr;
-		fdb->vid = vid;
-		fdb->ndm_state = is_static ? NUD_NOARP : NUD_REACHABLE;
-
-		ret = cb(&fdb->obj);
-		if (ret < 0)
-			break;
-	}
-
-	return ret == -ENOENT ? 0 : ret;
+	return -EOPNOTSUPP;
 }
 
 static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
-- 
2.6.1
