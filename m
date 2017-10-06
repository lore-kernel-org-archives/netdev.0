From: <Tristram.Ha@microchip.com>
Subject: [PATCH v1 RFC 6/7] Add MIB counter reading support
Date: Fri, 6 Oct 2017 13:33:04 -0700
Message-ID: <1507321985-15097-7-git-send-email-Tristram.Ha@microchip.com>
References: <1507321985-15097-1-git-send-email-Tristram.Ha@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tristram Ha <Tristram.Ha@microchip.com>, <muvarov@gmail.com>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>,
        <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Pavel Machek <pavel@ucw.cz>,
        Ruediger Schmitt <ruediger.schmitt@philips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507321985-15097-1-git-send-email-Tristram.Ha@microchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tristram Ha <Tristram.Ha@microchip.com>

Add MIB counter reading support.
Rename ksz_9477_reg.h to ksz9477_reg.h for consistency as the product
name is always KSZ####.
Header file ksz_priv.h no longer contains any chip specific data.

Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
---
 drivers/net/dsa/microchip/ksz9477.c                | 130 ++++++++++++++-------
 .../microchip/{ksz_9477_reg.h => ksz9477_reg.h}    |   0
 drivers/net/dsa/microchip/ksz_common.c             | 122 +++++++++++++++++++
 drivers/net/dsa/microchip/ksz_common.h             |   4 +
 drivers/net/dsa/microchip/ksz_priv.h               |   8 +-
 5 files changed, 219 insertions(+), 45 deletions(-)
 rename drivers/net/dsa/microchip/{ksz_9477_reg.h => ksz9477_reg.h} (100%)

diff --git a/drivers/net/dsa/microchip/ksz9477.c b/drivers/net/dsa/microchip/ksz9477.c
index 214d380..9579d03 100644
--- a/drivers/net/dsa/microchip/ksz9477.c
+++ b/drivers/net/dsa/microchip/ksz9477.c
@@ -31,7 +31,7 @@
 
 #include "ksz_priv.h"
 #include "ksz_common.h"
-#include "ksz_9477_reg.h"
+#include "ksz9477_reg.h"
 
 static const struct {
 	int index;
@@ -272,6 +272,74 @@ static int ksz9477_reset_switch(struct ksz_device *dev)
 	return 0;
 }
 
+static void ksz9477_r_mib_cnt(struct ksz_device *dev, int port, u16 addr,
+			      u64 *cnt)
+{
+	u32 data;
+	int timeout;
+
+	/* retain the flush/freeze bit */
+	ksz_pread32(dev, port, REG_PORT_MIB_CTRL_STAT__4, &data);
+	data &= MIB_COUNTER_FLUSH_FREEZE;
+
+	data |= MIB_COUNTER_READ;
+	data |= (addr << MIB_COUNTER_INDEX_S);
+	ksz_pwrite32(dev, port, REG_PORT_MIB_CTRL_STAT__4, data);
+
+	timeout = 1000;
+	do {
+		ksz_pread32(dev, port, REG_PORT_MIB_CTRL_STAT__4,
+			    &data);
+		usleep_range(1, 10);
+		if (!(data & MIB_COUNTER_READ))
+			break;
+	} while (timeout-- > 0);
+
+	/* failed to read MIB. get out of loop */
+	if (!timeout) {
+		dev_dbg(dev->dev, "Failed to get MIB\n");
+		return;
+	}
+
+	/* count resets upon read */
+	ksz_pread32(dev, port, REG_PORT_MIB_DATA, &data);
+	*cnt += data;
+}
+
+static void ksz9477_r_mib_pkt(struct ksz_device *dev, int port, u16 addr,
+			      u64 *dropped, u64 *cnt)
+{
+	addr = mib_names[addr].index;
+	ksz9477_r_mib_cnt(dev, port, addr, cnt);
+}
+
+static void ksz9477_freeze_mib(struct ksz_device *dev, int port, bool freeze)
+{
+	/* enable the port for flush/freeze function */
+	if (freeze)
+		ksz_pwrite32(dev, port, REG_PORT_MIB_CTRL_STAT__4,
+			     MIB_COUNTER_FLUSH_FREEZE);
+	ksz_cfg(dev, REG_SW_MAC_CTRL_6, SW_MIB_COUNTER_FREEZE, freeze);
+
+	/* disable the port after freeze is done */
+	if (!freeze)
+		ksz_pwrite32(dev, port, REG_PORT_MIB_CTRL_STAT__4, 0);
+}
+
+static void ksz9477_port_init_cnt(struct ksz_device *dev, int port)
+{
+	struct ksz_port_mib *mib = &dev->ports[port].mib;
+
+	/* flush all enabled port MIB counters */
+	ksz_pwrite32(dev, port, REG_PORT_MIB_CTRL_STAT__4,
+		     MIB_COUNTER_FLUSH_FREEZE);
+	ksz_write8(dev, REG_SW_MAC_CTRL_6, SW_MIB_COUNTER_FLUSH);
+	ksz_pwrite32(dev, port, REG_PORT_MIB_CTRL_STAT__4, 0);
+
+	mib->cnt_ptr = 0;
+	memset(mib->counters, 0, dev->mib_cnt * sizeof(u64));
+}
+
 static enum dsa_tag_protocol ksz9477_get_tag_protocol(struct dsa_switch *ds)
 {
 	return DSA_TAG_PROTO_KSZ;
@@ -350,46 +418,6 @@ static void ksz9477_get_strings(struct dsa_switch *ds, int port, uint8_t *buf)
 	}
 }
 
-static void ksz_get_ethtool_stats(struct dsa_switch *ds, int port,
-				  uint64_t *buf)
-{
-	struct ksz_device *dev = ds->priv;
-	int i;
-	u32 data;
-	int timeout;
-
-	mutex_lock(&dev->stats_mutex);
-
-	for (i = 0; i < TOTAL_SWITCH_COUNTER_NUM; i++) {
-		data = MIB_COUNTER_READ;
-		data |= ((mib_names[i].index & 0xFF) << MIB_COUNTER_INDEX_S);
-		ksz_pwrite32(dev, port, REG_PORT_MIB_CTRL_STAT__4, data);
-
-		timeout = 1000;
-		do {
-			ksz_pread32(dev, port, REG_PORT_MIB_CTRL_STAT__4,
-				    &data);
-			usleep_range(1, 10);
-			if (!(data & MIB_COUNTER_READ))
-				break;
-		} while (timeout-- > 0);
-
-		/* failed to read MIB. get out of loop */
-		if (!timeout) {
-			dev_dbg(dev->dev, "Failed to get MIB\n");
-			break;
-		}
-
-		/* count resets upon read */
-		ksz_pread32(dev, port, REG_PORT_MIB_DATA, &data);
-
-		dev->mib_value[i] += (uint64_t)data;
-		buf[i] = dev->mib_value[i];
-	}
-
-	mutex_unlock(&dev->stats_mutex);
-}
-
 static void ksz9477_cfg_port_member(struct ksz_device *dev, int port,
 				    u8 member)
 {
@@ -977,6 +1005,17 @@ static void ksz9477_port_mirror_del(struct dsa_switch *ds, int port,
 			     PORT_MIRROR_SNIFFER, false);
 }
 
+static void ksz9477_phy_setup(struct ksz_device *dev, int port,
+			      struct phy_device *phy)
+{
+	if (port < dev->phy_port_cnt) {
+		/* SUPPORTED_Asym_Pause and SUPPORTED_Pause can be removed to
+		 * disable flow control when rate limiting is used.
+		 */
+		phy->advertising = phy->supported;
+	}
+}
+
 static void ksz9477_port_setup(struct ksz_device *dev, int port, bool cpu_port)
 {
 	u8 data8;
@@ -1159,6 +1198,8 @@ static int ksz9477_setup(struct dsa_switch *ds)
 	/* start switch */
 	ksz_cfg(dev, REG_SW_OPERATION, SW_START, true);
 
+	ksz_init_mib_timer(dev);
+
 	return 0;
 }
 
@@ -1168,6 +1209,7 @@ static int ksz9477_setup(struct dsa_switch *ds)
 	.set_addr		= ksz9477_set_addr,
 	.phy_read		= ksz9477_phy_read16,
 	.phy_write		= ksz9477_phy_write16,
+	.adjust_link		= ksz_adjust_link,
 	.port_enable		= ksz_enable_port,
 	.port_disable		= ksz_disable_port,
 	.get_strings		= ksz9477_get_strings,
@@ -1289,6 +1331,7 @@ static int ksz9477_switch_init(struct ksz_device *dev)
 	if (!dev->ports)
 		return -ENOMEM;
 	for (i = 0; i < dev->mib_port_cnt; i++) {
+		mutex_init(&dev->ports[i].mib.cnt_mutex);
 		dev->ports[i].mib.counters =
 			devm_kzalloc(dev->dev,
 				     sizeof(u64) *
@@ -1310,7 +1353,12 @@ static void ksz9477_switch_exit(struct ksz_device *dev)
 	.get_port_addr = ksz9477_get_port_addr,
 	.cfg_port_member = ksz9477_cfg_port_member,
 	.flush_dyn_mac_table = ksz9477_flush_dyn_mac_table,
+	.phy_setup = ksz9477_phy_setup,
 	.port_setup = ksz9477_port_setup,
+	.r_mib_cnt = ksz9477_r_mib_cnt,
+	.r_mib_pkt = ksz9477_r_mib_pkt,
+	.freeze_mib = ksz9477_freeze_mib,
+	.port_init_cnt = ksz9477_port_init_cnt,
 	.shutdown = ksz9477_reset_switch,
 	.detect = ksz9477_switch_detect,
 	.init = ksz9477_switch_init,
diff --git a/drivers/net/dsa/microchip/ksz_9477_reg.h b/drivers/net/dsa/microchip/ksz9477_reg.h
similarity index 100%
rename from drivers/net/dsa/microchip/ksz_9477_reg.h
rename to drivers/net/dsa/microchip/ksz9477_reg.h
diff --git a/drivers/net/dsa/microchip/ksz_common.c b/drivers/net/dsa/microchip/ksz_common.c
index 1c9c4c5..885b3e3 100644
--- a/drivers/net/dsa/microchip/ksz_common.c
+++ b/drivers/net/dsa/microchip/ksz_common.c
@@ -50,6 +50,81 @@ void ksz_update_port_member(struct ksz_device *dev, int port)
 	}
 }
 
+static void port_r_cnt(struct ksz_device *dev, int port)
+{
+	struct ksz_port_mib *mib = &dev->ports[port].mib;
+	u64 *dropped;
+
+	/* Some ports may not have MIB counters before SWITCH_COUNTER_NUM. */
+	while (mib->cnt_ptr < dev->reg_mib_cnt) {
+		dev->dev_ops->r_mib_cnt(dev, port, mib->cnt_ptr,
+					&mib->counters[mib->cnt_ptr]);
+		++mib->cnt_ptr;
+	}
+
+	/* last one in storage */
+	dropped = &mib->counters[dev->mib_cnt];
+
+	/* Some ports may not have MIB counters after SWITCH_COUNTER_NUM. */
+	while (mib->cnt_ptr < dev->mib_cnt) {
+		dev->dev_ops->r_mib_pkt(dev, port, mib->cnt_ptr,
+					dropped, &mib->counters[mib->cnt_ptr]);
+		++mib->cnt_ptr;
+	}
+	mib->cnt_ptr = 0;
+}
+
+static void ksz_mib_read_work(struct work_struct *work)
+{
+	struct ksz_device *dev =
+		container_of(work, struct ksz_device, mib_read);
+	struct ksz_port *p;
+	struct ksz_port_mib *mib;
+	int i;
+
+	for (i = 0; i < dev->mib_port_cnt; i++) {
+		p = &dev->ports[i];
+		if (!p->on)
+			continue;
+		mib = &p->mib;
+		mutex_lock(&mib->cnt_mutex);
+
+		/* read only dropped counters when link is not up */
+		if (p->link_down)
+			p->link_down = 0;
+		else if (!p->link_up)
+			mib->cnt_ptr = dev->reg_mib_cnt;
+		port_r_cnt(dev, i);
+		mutex_unlock(&mib->cnt_mutex);
+	}
+}
+
+static void mib_monitor(unsigned long ptr)
+{
+	struct ksz_device *dev = (struct ksz_device *)ptr;
+
+	mod_timer(&dev->mib_read_timer, jiffies + dev->mib_read_interval);
+	schedule_work(&dev->mib_read);
+}
+
+void ksz_init_mib_timer(struct ksz_device *dev)
+{
+	int i;
+
+	/* Read MIB counters every 30 seconds to avoid overflow. */
+	dev->mib_read_interval = msecs_to_jiffies(30000);
+
+	INIT_WORK(&dev->mib_read, ksz_mib_read_work);
+	setup_timer(&dev->mib_read_timer, mib_monitor, (unsigned long)dev);
+
+	for (i = 0; i < dev->mib_port_cnt; i++)
+		dev->dev_ops->port_init_cnt(dev, i);
+
+	/* Start the timer 2 seconds later. */
+	dev->mib_read_timer.expires = jiffies + msecs_to_jiffies(2000);
+	add_timer(&dev->mib_read_timer);
+}
+
 int ksz_phy_read16(struct dsa_switch *ds, int addr, int reg)
 {
 	struct ksz_device *dev = ds->priv;
@@ -69,6 +144,25 @@ int ksz_phy_write16(struct dsa_switch *ds, int addr, int reg, u16 val)
 	return 0;
 }
 
+void ksz_adjust_link(struct dsa_switch *ds, int port,
+		     struct phy_device *phydev)
+{
+	struct ksz_device *dev = ds->priv;
+	struct ksz_port *p = &dev->ports[port];
+
+	if (phydev->link) {
+		p->speed = phydev->speed;
+		p->duplex = phydev->duplex;
+		p->flow_ctrl = phydev->pause;
+		p->link_up = 1;
+		dev->live_ports |= (1 << port) & dev->on_ports;
+	} else if (p->link_up) {
+		p->link_up = 0;
+		p->link_down = 1;
+		dev->live_ports &= ~(1 << port);
+	}
+}
+
 int ksz_sset_count(struct dsa_switch *ds)
 {
 	struct ksz_device *dev = ds->priv;
@@ -76,6 +170,27 @@ int ksz_sset_count(struct dsa_switch *ds)
 	return dev->mib_cnt;
 }
 
+void ksz_get_ethtool_stats(struct dsa_switch *ds, int port, uint64_t *buf)
+{
+	struct ksz_device *dev = ds->priv;
+	struct ksz_port_mib *mib;
+
+	mib = &dev->ports[port].mib;
+
+	mutex_lock(&dev->stats_mutex);
+
+	/* freeze MIB counters if supported */
+	if (dev->dev_ops->freeze_mib)
+		dev->dev_ops->freeze_mib(dev, port, true);
+	mutex_lock(&mib->cnt_mutex);
+	port_r_cnt(dev, port);
+	mutex_unlock(&mib->cnt_mutex);
+	if (dev->dev_ops->freeze_mib)
+		dev->dev_ops->freeze_mib(dev, port, false);
+	memcpy(buf, mib->counters, dev->mib_cnt * sizeof(u64));
+	mutex_unlock(&dev->stats_mutex);
+}
+
 int ksz_port_bridge_join(struct dsa_switch *ds, int port,
 			 struct net_device *br)
 {
@@ -249,6 +364,7 @@ int ksz_enable_port(struct dsa_switch *ds, int port, struct phy_device *phy)
 
 	/* setup slave port */
 	dev->dev_ops->port_setup(dev, port, false);
+	dev->dev_ops->phy_setup(dev, port, phy);
 
 	/* port_stp_state_set() will be called after to enable the port so
 	 * there is no need to do anything.
@@ -331,6 +447,12 @@ int ksz_switch_register(struct ksz_device *dev,
 
 void ksz_switch_remove(struct ksz_device *dev)
 {
+	/* timer started */
+	if (dev->mib_read_timer.expires) {
+		del_timer_sync(&dev->mib_read_timer);
+		flush_work(&dev->mib_read);
+	}
+
 	dev->dev_ops->exit(dev);
 	dsa_unregister_switch(dev->ds);
 }
diff --git a/drivers/net/dsa/microchip/ksz_common.h b/drivers/net/dsa/microchip/ksz_common.h
index 1c1cbad..20afea3f 100644
--- a/drivers/net/dsa/microchip/ksz_common.h
+++ b/drivers/net/dsa/microchip/ksz_common.h
@@ -21,12 +21,16 @@
 #define __KSZ_COMMON_H
 
 void ksz_update_port_member(struct ksz_device *dev, int port);
+void ksz_init_mib_timer(struct ksz_device *dev);
 
 /* Common DSA access functions */
 
 int ksz_phy_read16(struct dsa_switch *ds, int addr, int reg);
 int ksz_phy_write16(struct dsa_switch *ds, int addr, int reg, u16 val);
+void ksz_adjust_link(struct dsa_switch *ds, int port,
+		     struct phy_device *phydev);
 int ksz_sset_count(struct dsa_switch *ds);
+void ksz_get_ethtool_stats(struct dsa_switch *ds, int port, uint64_t *buf);
 int ksz_port_bridge_join(struct dsa_switch *ds, int port,
 			 struct net_device *br);
 void ksz_port_bridge_leave(struct dsa_switch *ds, int port,
diff --git a/drivers/net/dsa/microchip/ksz_priv.h b/drivers/net/dsa/microchip/ksz_priv.h
index 4126749..0e1ccd3 100644
--- a/drivers/net/dsa/microchip/ksz_priv.h
+++ b/drivers/net/dsa/microchip/ksz_priv.h
@@ -26,8 +26,6 @@
 #include <linux/etherdevice.h>
 #include <net/dsa.h>
 
-#include "ksz_9477_reg.h"
-
 struct ksz_io_ops;
 
 struct vlan_table {
@@ -35,6 +33,7 @@ struct vlan_table {
 };
 
 struct ksz_port_mib {
+	struct mutex cnt_mutex;		/* structure access */
 	u8 cnt_ptr;
 	u64 *counters;
 };
@@ -92,8 +91,6 @@ struct ksz_device {
 
 	struct vlan_table *vlan_cache;
 
-	u64 mib_value[TOTAL_SWITCH_COUNTER_NUM];
-
 	u8 *txbuf;
 
 	struct ksz_port *ports;
@@ -150,6 +147,8 @@ struct ksz_dev_ops {
 	u32 (*get_port_addr)(int port, int offset);
 	void (*cfg_port_member)(struct ksz_device *dev, int port, u8 member);
 	void (*flush_dyn_mac_table)(struct ksz_device *dev, int port);
+	void (*phy_setup)(struct ksz_device *dev, int port,
+			  struct phy_device *phy);
 	void (*port_setup)(struct ksz_device *dev, int port, bool cpu_port);
 	void (*r_phy)(struct ksz_device *dev, u16 phy, u16 reg, u16 *val);
 	void (*w_phy)(struct ksz_device *dev, u16 phy, u16 reg, u16 val);
@@ -164,6 +163,7 @@ struct ksz_dev_ops {
 			  u64 *cnt);
 	void (*r_mib_pkt)(struct ksz_device *dev, int port, u16 addr,
 			  u64 *dropped, u64 *cnt);
+	void (*freeze_mib)(struct ksz_device *dev, int port, bool freeze);
 	void (*port_init_cnt)(struct ksz_device *dev, int port);
 	int (*shutdown)(struct ksz_device *dev);
 	int (*detect)(struct ksz_device *dev);
-- 
1.9.1
