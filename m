From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 6/7] net: dsa: mv88e6xxx: remove addresses when a port leaves a VLAN
Date: Fri,  4 Sep 2015 14:34:15 -0400
Message-ID: <1441391656-22574-7-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1441391656-22574-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-208-88-110-44.savoirfairelinux.net ([208.88.110.44]:57173
	"EHLO mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760355AbbIDSfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2015 14:35:07 -0400
In-Reply-To: <1441391656-22574-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new _mv88e6xxx_atu_move function to prepare the ATU data register
for the move operation. The ports vector will contain the source port
and destination port of the Move operation. If the destination port is
0xF, the MAC addresses mapped to the source port are removed for the
address database(s).

Then add a _mv88e6xxx_atu_remove wrapper to remove the MAC addresses
from a VLAN database that are mapped to a given port, when it leaves it.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 88d669c..63407a1 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1116,6 +1116,31 @@ static int _mv88e6xxx_flush_fid(struct dsa_switch *ds, int fid)
 	return _mv88e6xxx_atu_flush(ds, fid, false);
 }
 
+static int _mv88e6xxx_atu_move(struct dsa_switch *ds, u16 fid, int from_port,
+			       int to_port, bool static_too)
+{
+	struct mv88e6xxx_atu_entry entry = {
+		.trunk = false,
+		.fid = fid,
+	};
+
+	/* EntryState bits must be 0xF */
+	entry.state = GLOBAL_ATU_DATA_STATE_MASK;
+
+	/* ToPort and FromPort are respectively in PortVec bits 7:4 and 3:0 */
+	entry.portv_trunkid = (to_port & 0x0f) << 4;
+	entry.portv_trunkid |= from_port & 0x0f;
+
+	return _mv88e6xxx_atu_flush_move(ds, &entry, static_too);
+}
+
+static int _mv88e6xxx_atu_remove(struct dsa_switch *ds, u16 fid, int port,
+				 bool static_too)
+{
+	/* Destination port 0xF means remove the entries */
+	return _mv88e6xxx_atu_move(ds, fid, port, 0x0f, static_too);
+}
+
 static int mv88e6xxx_set_port_state(struct dsa_switch *ds, int port, u8 state)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -1708,6 +1733,10 @@ int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port, u16 vid)
 	if (err)
 		goto unlock;
 
+	err = _mv88e6xxx_atu_remove(ds, vlan.fid, port, false);
+	if (err)
+		goto unlock;
+
 	if (!keep)
 		clear_bit(vlan.fid, ps->fid_bitmap);
 
-- 
2.5.1
