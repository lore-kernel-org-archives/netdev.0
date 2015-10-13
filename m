From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/6] net: dsa: add port_fdb_dump function
Date: Tue, 13 Oct 2015 11:43:00 -0400
Message-ID: <1444750983-14726-4-git-send-email-vivien.didelot@savoirfairelinux.com>
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

Not all switch chips support a Get Next operation to iterate on its FDB.
So add a more simple port_fdb_dump function for them.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h | 5 +++++
 net/dsa/slave.c   | 3 +++
 2 files changed, 8 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index e005886..c5c48c5 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -198,7 +198,9 @@ static inline u8 dsa_upstream_port(struct dsa_switch *ds)
 }
 
 struct switchdev_trans;
+struct switchdev_obj;
 struct switchdev_obj_port_fdb;
+typedef int switchdev_obj_dump_cb_t(struct switchdev_obj *obj);
 
 struct dsa_switch_driver {
 	struct list_head	list;
@@ -330,6 +332,9 @@ struct dsa_switch_driver {
 	int	(*port_fdb_getnext)(struct dsa_switch *ds, int port,
 				    unsigned char *addr, u16 *vid,
 				    bool *is_static);
+	int	(*port_fdb_dump)(struct dsa_switch *ds, int port,
+				 struct switchdev_obj_port_fdb *fdb,
+				 switchdev_obj_dump_cb_t *cb);
 };
 
 void register_switch_driver(struct dsa_switch_driver *type);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 43d7342..a4e3416 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -382,6 +382,9 @@ static int dsa_slave_port_fdb_dump(struct net_device *dev,
 	u16 vid = 0;
 	int ret;
 
+	if (ds->drv->port_fdb_dump)
+		return ds->drv->port_fdb_dump(ds, p->port, fdb, cb);
+
 	if (!ds->drv->port_fdb_getnext)
 		return -EOPNOTSUPP;
 
-- 
2.6.1
