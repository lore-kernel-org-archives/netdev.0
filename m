From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2 11/16] net: dsa: mv88e6xxx: Add support for fdb_add, fdb_del, and fdb_getnext
Date: Thu, 26 Mar 2015 18:36:38 -0700
Message-ID: <1427420203-27685-12-git-send-email-linux@roeck-us.net>
References: <1427420203-27685-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:39389 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753514AbbC0BhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 21:37:17 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YbJD2-0020m5-9u
	for netdev@vger.kernel.org; Fri, 27 Mar 2015 01:37:16 +0000
In-Reply-To: <1427420203-27685-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No vlan support at this time.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Tested-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6xxx.c | 136 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  16 ++++++
 2 files changed, 152 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 17aa74f64233..038802229e32 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -9,6 +9,7 @@
  */
 
 #include <linux/delay.h>
+#include <linux/etherdevice.h>
 #include <linux/if_bridge.h>
 #include <linux/jiffies.h>
 #include <linux/list.h>
@@ -953,6 +954,141 @@ int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state)
 	return 0;
 }
 
+static int __mv88e6xxx_write_addr(struct dsa_switch *ds,
+				  const unsigned char *addr)
+{
+	int i, ret;
+
+	for (i = 0; i < 3; i++) {
+		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x0d + i,
+					(addr[i * 2] << 8) | addr[i * 2 + 1]);
+		if (ret < 0)
+			return ret;
+	}
+
+	return 0;
+}
+
+static int __mv88e6xxx_read_addr(struct dsa_switch *ds, unsigned char *addr)
+{
+	int i, ret;
+
+	for (i = 0; i < 3; i++) {
+		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, 0x0d + i);
+		if (ret < 0)
+			return ret;
+		addr[i * 2] = ret >> 8;
+		addr[i * 2 + 1] = ret & 0xff;
+	}
+
+	return 0;
+}
+
+static int __mv88e6xxx_port_fdb_cmd(struct dsa_switch *ds, int port,
+				    const unsigned char *addr, int state)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	u8 fid = ps->fid[port];
+	int ret;
+
+	ret = _mv88e6xxx_atu_wait(ds);
+	if (ret < 0)
+		return ret;
+
+	ret = __mv88e6xxx_write_addr(ds, addr);
+	if (ret < 0)
+		return ret;
+
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x0c,
+				   (0x10 << port) | state);
+	if (ret)
+		return ret;
+
+	ret = _mv88e6xxx_atu_cmd(ds, fid, ATU_CMD_LOAD_FID);
+
+	return ret;
+}
+
+int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
+			   const unsigned char *addr, u16 vid)
+{
+	int state = is_multicast_ether_addr(addr) ?
+					FDB_STATE_MC_STATIC : FDB_STATE_STATIC;
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int ret;
+
+	mutex_lock(&ps->smi_mutex);
+	ret = __mv88e6xxx_port_fdb_cmd(ds, port, addr, state);
+	mutex_unlock(&ps->smi_mutex);
+
+	return ret;
+}
+
+int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
+			   const unsigned char *addr, u16 vid)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int ret;
+
+	mutex_lock(&ps->smi_mutex);
+	ret = __mv88e6xxx_port_fdb_cmd(ds, port, addr, FDB_STATE_UNUSED);
+	mutex_unlock(&ps->smi_mutex);
+
+	return ret;
+}
+
+static int __mv88e6xxx_port_getnext(struct dsa_switch *ds, int port,
+				    unsigned char *addr, bool *is_static)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	u8 fid = ps->fid[port];
+	int ret, state;
+
+	ret = _mv88e6xxx_atu_wait(ds);
+	if (ret < 0)
+		return ret;
+
+	ret = __mv88e6xxx_write_addr(ds, addr);
+	if (ret < 0)
+		return ret;
+
+	do {
+		ret = _mv88e6xxx_atu_cmd(ds, fid, ATU_CMD_GETNEXT_FID);
+		if (ret < 0)
+			return ret;
+
+		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, 0x0c);
+		if (ret < 0)
+			return ret;
+		state = ret & FDB_STATE_MASK;
+		if (state == FDB_STATE_UNUSED)
+			return -ENOENT;
+	} while (!(((ret >> 4) & 0xff) & (1 << port)));
+
+	ret = __mv88e6xxx_read_addr(ds, addr);
+	if (ret < 0)
+		return ret;
+
+	*is_static = state == (is_multicast_ether_addr(addr) ?
+			       FDB_STATE_MC_STATIC : FDB_STATE_STATIC);
+
+	return 0;
+}
+
+/* get next entry for port */
+int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
+			       unsigned char *addr, bool *is_static)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int ret;
+
+	mutex_lock(&ps->smi_mutex);
+	ret = __mv88e6xxx_port_getnext(ds, port, addr, is_static);
+	mutex_unlock(&ps->smi_mutex);
+
+	return ret;
+}
+
 static void mv88e6xxx_bridge_work(struct work_struct *work)
 {
 	struct mv88e6xxx_priv_state *ps;
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 8e215ebc8d34..aaf239aba726 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -19,6 +19,8 @@
 
 #define ATU_BUSY			0x8000
 
+#define ATU_CMD_LOAD_FID		(ATU_BUSY | 0x3000)
+#define ATU_CMD_GETNEXT_FID		(ATU_BUSY | 0x4000)
 #define ATU_CMD_FLUSH_NONSTATIC_FID	(ATU_BUSY | 0x6000)
 
 /* port states */
@@ -29,6 +31,14 @@
 #define PSTATE_LEARNING		0x02
 #define PSTATE_FORWARDING	0x03
 
+/* FDB states */
+
+#define FDB_STATE_MASK			0x0f
+
+#define FDB_STATE_UNUSED		0x00
+#define FDB_STATE_MC_STATIC		0x07	/* static multicast */
+#define FDB_STATE_STATIC		0x0e	/* static unicast */
+
 struct mv88e6xxx_priv_state {
 	/* When using multi-chip addressing, this mutex protects
 	 * access to the indirect access registers.  (In single-chip
@@ -121,6 +131,12 @@ int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 int mv88e6xxx_join_bridge(struct dsa_switch *ds, int port, u32 br_port_mask);
 int mv88e6xxx_leave_bridge(struct dsa_switch *ds, int port, u32 br_port_mask);
 int mv88e6xxx_port_stp_update(struct dsa_switch *ds, int port, u8 state);
+int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
+			   const unsigned char *addr, u16 vid);
+int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
+			   const unsigned char *addr, u16 vid);
+int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
+			       unsigned char *addr, bool *is_static);
 
 extern struct dsa_switch_driver mv88e6131_switch_driver;
 extern struct dsa_switch_driver mv88e6123_61_65_switch_driver;
-- 
2.1.0
