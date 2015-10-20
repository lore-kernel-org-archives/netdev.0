From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 6/6] net: dsa: remove port_fdb_getnext
Date: Tue, 20 Oct 2015 12:17:26 -0400
Message-ID: <1445357846-25720-7-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1445357846-25720-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445357846-25720-1-git-send-email-vivien.didelot@savoirfairelinux.com>
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
index 0cfa44a..98ccbde 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -328,9 +328,6 @@ struct dsa_switch_driver {
 				struct switchdev_trans *trans);
 	int	(*port_fdb_del)(struct dsa_switch *ds, int port,
 				const struct switchdev_obj_port_fdb *fdb);
-	int	(*port_fdb_getnext)(struct dsa_switch *ds, int port,
-				    unsigned char *addr, u16 *vid,
-				    bool *is_static);
 	int	(*port_fdb_dump)(struct dsa_switch *ds, int port,
 				 struct switchdev_obj_port_fdb *fdb,
 				 int (*cb)(struct switchdev_obj *obj));
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index d76e62b..481754e 100644
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
-		ether_addr_copy(fdb->addr, addr);
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
