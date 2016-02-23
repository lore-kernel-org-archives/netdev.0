From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/3] net: dsa: add port_vlan_dump routine
Date: Tue, 23 Feb 2016 12:13:54 -0500
Message-ID: <1456247636-4706-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1456247636-4706-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456247636-4706-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Similar to port_fdb_dump, add a port_vlan_dump function to DSA drivers
which gets passed the switchdev VLAN object and callback.

This function, if implemented, takes precedence over the soon legacy
vlan_getnext/port_pvid_get approach.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 Documentation/networking/dsa/dsa.txt | 4 ++++
 include/net/dsa.h                    | 3 +++
 net/dsa/slave.c                      | 3 +++
 3 files changed, 10 insertions(+)

diff --git a/Documentation/networking/dsa/dsa.txt b/Documentation/networking/dsa/dsa.txt
index ebf2153..350a502 100644
--- a/Documentation/networking/dsa/dsa.txt
+++ b/Documentation/networking/dsa/dsa.txt
@@ -554,6 +554,10 @@ Bridge VLAN filtering
 - port_vlan_del: bridge layer function invoked when a VLAN is removed from the
   given switch port
 
+- port_vlan_dump: bridge layer function invoked with a switchdev callback
+  function that the driver has to call for each VLAN the given port is a member
+  of. A switchdev object is used to carry the VID and bridge flags.
+
 - vlan_getnext: bridge layer function invoked to query the next configured VLAN
   in the switch, i.e. returns the bitmaps of members and untagged ports
 
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 1c845d7..ebc0d9e 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -313,6 +313,9 @@ struct dsa_switch_driver {
 				 struct switchdev_trans *trans);
 	int	(*port_vlan_del)(struct dsa_switch *ds, int port,
 				 const struct switchdev_obj_port_vlan *vlan);
+	int	(*port_vlan_dump)(struct dsa_switch *ds, int port,
+				  struct switchdev_obj_port_vlan *vlan,
+				  int (*cb)(struct switchdev_obj *obj));
 	int	(*port_pvid_get)(struct dsa_switch *ds, int port, u16 *pvid);
 	int	(*vlan_getnext)(struct dsa_switch *ds, u16 *vid,
 				unsigned long *ports, unsigned long *untagged);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 14ca978..a9cbb72 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -248,6 +248,9 @@ static int dsa_slave_port_vlan_dump(struct net_device *dev,
 	u16 pvid, vid = 0;
 	int err;
 
+	if (ds->drv->port_vlan_dump)
+		return ds->drv->port_vlan_dump(ds, p->port, vlan, cb);
+
 	if (!ds->drv->vlan_getnext || !ds->drv->port_pvid_get)
 		return -EOPNOTSUPP;
 
-- 
2.7.1
