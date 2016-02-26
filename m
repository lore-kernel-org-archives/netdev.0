From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 6/9] net: dsa: mv88e6xxx: assign dynamic FDB to bridges
Date: Fri, 26 Feb 2016 13:16:05 -0500
Message-ID: <1456510568-13679-7-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1456510568-13679-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Kevin Smith <kevin.smith@elecsyscorp.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456510568-13679-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Give a new bridge a fresh FDB, assign it to its members, and restore a
fresh FDB to a port leaving a bridge.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 41 +++++++++++++++++++++++++++++++++++++++--
 1 file changed, 39 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 0f06488..0f16911 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2093,19 +2093,56 @@ int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
 			       struct net_device *bridge)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	u16 fid;
+	int i, err;
+
+	mutex_lock(&ps->smi_mutex);
+
+	/* Get or create the bridge FID and assign it to the port */
+	for (i = 0; i < ps->num_ports; ++i)
+		if (ps->ports[i].bridge_dev == bridge)
+			break;
+
+	if (i < ps->num_ports)
+		err = _mv88e6xxx_port_fid_get(ds, i, &fid);
+	else
+		err = _mv88e6xxx_fid_new(ds, &fid);
+	if (err)
+		goto unlock;
+
+	err = _mv88e6xxx_port_fid_set(ds, port, fid);
+	if (err)
+		goto unlock;
 
 	ps->ports[port].bridge_dev = bridge;
+unlock:
+	mutex_unlock(&ps->smi_mutex);
 
-	return 0;
+	return err;
 }
 
 int mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	u16 fid;
+	int err;
+
+	mutex_lock(&ps->smi_mutex);
+
+	/* Give the port a fresh Filtering Information Database */
+	err = _mv88e6xxx_fid_new(ds, &fid);
+	if (err)
+		goto unlock;
+
+	err = _mv88e6xxx_port_fid_set(ds, port, fid);
+	if (err)
+		goto unlock;
 
 	ps->ports[port].bridge_dev = NULL;
+unlock:
+	mutex_unlock(&ps->smi_mutex);
 
-	return 0;
+	return err;
 }
 
 static int mv88e6xxx_setup_port_default_vlan(struct dsa_switch *ds, int port)
-- 
2.7.1
