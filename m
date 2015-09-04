From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/7] net: dsa: mv88e6xxx: rework ATU Flush operation
Date: Fri,  4 Sep 2015 14:34:12 -0400
Message-ID: <1441391656-22574-4-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1441391656-22574-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441391656-22574-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These Marvell switches have 4 operations to flush or (re)move, all or
only non-static MAC addresses, from the entire set of databases or from
just a particular one.

The value of the EntryState bits will determine if the operation is
either a Flush (0x0) or a Move (0xF).

When moving entries from one port to another, entries will be removed if
the destination port is 0xF.

This patch renames these operations for consistency, add a new generic
_mv88e6xxx_atu_flush_move function, and change _mv88e6xxx_flush_fid to
use it.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 53 +++++++++++++++++++++++++++++++++++----------
 drivers/net/dsa/mv88e6xxx.h |  8 +++----
 2 files changed, 46 insertions(+), 15 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 25e103c..c67090f 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1070,19 +1070,50 @@ static int _mv88e6xxx_atu_data_write(struct dsa_switch *ds,
 	return _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_DATA, data);
 }
 
+static int _mv88e6xxx_atu_flush_move(struct dsa_switch *ds,
+				     struct mv88e6xxx_atu_entry *entry,
+				     bool static_too)
+{
+	int op;
+	int err;
+
+	err = _mv88e6xxx_atu_wait(ds);
+	if (err)
+		return err;
+
+	err = _mv88e6xxx_atu_data_write(ds, entry);
+	if (err)
+		return err;
+
+	if (entry->fid) {
+		err = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_FID,
+					   entry->fid);
+		if (err)
+			return err;
+
+		op = static_too ? GLOBAL_ATU_OP_FLUSH_MOVE_ALL_DB :
+			GLOBAL_ATU_OP_FLUSH_MOVE_NON_STATIC_DB;
+	} else {
+		op = static_too ? GLOBAL_ATU_OP_FLUSH_MOVE_ALL :
+			GLOBAL_ATU_OP_FLUSH_MOVE_NON_STATIC;
+	}
+
+	return _mv88e6xxx_atu_cmd(ds, op);
+}
+
+static int _mv88e6xxx_atu_flush(struct dsa_switch *ds, u16 fid, bool static_too)
+{
+	struct mv88e6xxx_atu_entry entry = {
+		.fid = fid,
+		.state = 0, /* EntryState bits must be 0 */
+	};
+
+	return _mv88e6xxx_atu_flush_move(ds, &entry, static_too);
+}
+
 static int _mv88e6xxx_flush_fid(struct dsa_switch *ds, int fid)
 {
-	int ret;
-
-	ret = _mv88e6xxx_atu_wait(ds);
-	if (ret < 0)
-		return ret;
-
-	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_FID, fid);
-	if (ret < 0)
-		return ret;
-
-	return _mv88e6xxx_atu_cmd(ds, GLOBAL_ATU_OP_FLUSH_NON_STATIC_DB);
+	return _mv88e6xxx_atu_flush(ds, fid, false);
 }
 
 static int mv88e6xxx_set_port_state(struct dsa_switch *ds, int port, u8 state)
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 9b6f3d9..1cf3cf8 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -226,12 +226,12 @@
 #define GLOBAL_ATU_OP		0x0b
 #define GLOBAL_ATU_OP_BUSY	BIT(15)
 #define GLOBAL_ATU_OP_NOP		(0 << 12)
-#define GLOBAL_ATU_OP_FLUSH_ALL		((1 << 12) | GLOBAL_ATU_OP_BUSY)
-#define GLOBAL_ATU_OP_FLUSH_NON_STATIC	((2 << 12) | GLOBAL_ATU_OP_BUSY)
+#define GLOBAL_ATU_OP_FLUSH_MOVE_ALL		((1 << 12) | GLOBAL_ATU_OP_BUSY)
+#define GLOBAL_ATU_OP_FLUSH_MOVE_NON_STATIC	((2 << 12) | GLOBAL_ATU_OP_BUSY)
 #define GLOBAL_ATU_OP_LOAD_DB		((3 << 12) | GLOBAL_ATU_OP_BUSY)
 #define GLOBAL_ATU_OP_GET_NEXT_DB	((4 << 12) | GLOBAL_ATU_OP_BUSY)
-#define GLOBAL_ATU_OP_FLUSH_DB		((5 << 12) | GLOBAL_ATU_OP_BUSY)
-#define GLOBAL_ATU_OP_FLUSH_NON_STATIC_DB ((6 << 12) | GLOBAL_ATU_OP_BUSY)
+#define GLOBAL_ATU_OP_FLUSH_MOVE_ALL_DB		((5 << 12) | GLOBAL_ATU_OP_BUSY)
+#define GLOBAL_ATU_OP_FLUSH_MOVE_NON_STATIC_DB ((6 << 12) | GLOBAL_ATU_OP_BUSY)
 #define GLOBAL_ATU_OP_GET_CLR_VIOLATION	  ((7 << 12) | GLOBAL_ATU_OP_BUSY)
 #define GLOBAL_ATU_DATA		0x0c
 #define GLOBAL_ATU_DATA_TRUNK			BIT(15)
-- 
2.5.1
