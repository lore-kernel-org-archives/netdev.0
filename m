From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: add port fdb dump
Date: Wed, 20 Sep 2017 19:32:14 -0400
Message-ID: <20170920233214.6936-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dumping a DSA port's FDB entries is not specific to a DSA slave, so add
a dsa_port_fdb_dump function, similarly to dsa_port_fdb_add and
dsa_port_fdb_del.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa_priv.h |  1 +
 net/dsa/port.c     | 11 +++++++++++
 net/dsa/slave.c    |  9 ++-------
 3 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index f616b3444418..9803952a5b40 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -128,6 +128,7 @@ int dsa_port_fdb_add(struct dsa_port *dp, const unsigned char *addr,
 		     u16 vid);
 int dsa_port_fdb_del(struct dsa_port *dp, const unsigned char *addr,
 		     u16 vid);
+int dsa_port_fdb_dump(struct dsa_port *dp, dsa_fdb_dump_cb_t *cb, void *data);
 int dsa_port_mdb_add(struct dsa_port *dp,
 		     const struct switchdev_obj_port_mdb *mdb,
 		     struct switchdev_trans *trans);
diff --git a/net/dsa/port.c b/net/dsa/port.c
index 659676ba3f8b..76d43a82d397 100644
--- a/net/dsa/port.c
+++ b/net/dsa/port.c
@@ -173,6 +173,17 @@ int dsa_port_fdb_del(struct dsa_port *dp, const unsigned char *addr,
 	return dsa_port_notify(dp, DSA_NOTIFIER_FDB_DEL, &info);
 }
 
+int dsa_port_fdb_dump(struct dsa_port *dp, dsa_fdb_dump_cb_t *cb, void *data)
+{
+	struct dsa_switch *ds = dp->ds;
+	int port = dp->index;
+
+	if (!ds->ops->port_fdb_dump)
+		return -EOPNOTSUPP;
+
+	return ds->ops->port_fdb_dump(ds, port, cb, data);
+}
+
 int dsa_port_mdb_add(struct dsa_port *dp,
 		     const struct switchdev_obj_port_mdb *mdb,
 		     struct switchdev_trans *trans)
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index bc376fc1bbe7..b87ed29b5b55 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -263,16 +263,11 @@ dsa_slave_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 	};
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_port *dp = p->dp;
-	struct dsa_switch *ds = dp->ds;
 	int err;
 
-	if (!ds->ops->port_fdb_dump)
-		return -EOPNOTSUPP;
-
-	err = ds->ops->port_fdb_dump(ds, dp->index,
-				     dsa_slave_port_fdb_do_dump,
-				     &dump);
+	err = dsa_port_fdb_dump(dp, dsa_slave_port_fdb_do_dump, &dump);
 	*idx = dump.idx;
+
 	return err;
 }
 
-- 
2.14.1
