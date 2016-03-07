From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: mv88e6xxx: read then write PVID
Date: Mon,  7 Mar 2016 18:24:39 -0500
Message-ID: <1457393079-22740-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Kevin Smith <kevin.smith@elecsyscorp.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The port register 0x07 contains more options than just the default VID,
even though they are not used yet. So prefer a read then write operation
over a direct write.

This also allows to keep track of the change through dynamic debug.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 30 ++++++++++++++++++++++++++----
 1 file changed, 26 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 3a58a8a..1aee42d 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1166,23 +1166,45 @@ int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state)
 	return 0;
 }
 
-static int _mv88e6xxx_port_pvid_get(struct dsa_switch *ds, int port, u16 *pvid)
+static int _mv88e6xxx_port_pvid(struct dsa_switch *ds, int port, u16 *new,
+				u16 *old)
 {
+	u16 pvid;
 	int ret;
 
 	ret = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_DEFAULT_VLAN);
 	if (ret < 0)
 		return ret;
 
-	*pvid = ret & PORT_DEFAULT_VLAN_MASK;
+	pvid = ret & PORT_DEFAULT_VLAN_MASK;
+
+	if (new) {
+		ret &= ~PORT_DEFAULT_VLAN_MASK;
+		ret |= *new & PORT_DEFAULT_VLAN_MASK;
+
+		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+					   PORT_DEFAULT_VLAN, ret);
+		if (ret < 0)
+			return ret;
+
+		netdev_dbg(ds->ports[port], "DefaultVID %d (was %d)\n", *new,
+			   pvid);
+	}
+
+	if (old)
+		*old = pvid;
 
 	return 0;
 }
 
+static int _mv88e6xxx_port_pvid_get(struct dsa_switch *ds, int port, u16 *pvid)
+{
+	return _mv88e6xxx_port_pvid(ds, port, NULL, pvid);
+}
+
 static int _mv88e6xxx_port_pvid_set(struct dsa_switch *ds, int port, u16 pvid)
 {
-	return _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_DEFAULT_VLAN,
-				   pvid & PORT_DEFAULT_VLAN_MASK);
+	return _mv88e6xxx_port_pvid(ds, port, &pvid, NULL);
 }
 
 static int _mv88e6xxx_vtu_wait(struct dsa_switch *ds)
-- 
2.7.2
