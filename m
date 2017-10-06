From: <Tristram.Ha@microchip.com>
Subject: [PATCH v1 RFC 5/7] Break KSZ9477 DSA driver into two files
Date: Fri, 6 Oct 2017 13:33:03 -0700
Message-ID: <1507321985-15097-6-git-send-email-Tristram.Ha@microchip.com>
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

Break KSZ9477 DSA driver into two files in preparation to add more KSZ
switch drivers.
Add common functions in ksz_common.h so that other KSZ switch drivers
can access code in ksz_common.c.
Add ksz_spi.h for common functions used by KSZ switch SPI drivers.

Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
---
 drivers/net/dsa/microchip/Makefile      |    2 +-
 drivers/net/dsa/microchip/ksz9477.c     | 1328 +++++++++++++++++++++++++++++++
 drivers/net/dsa/microchip/ksz9477_spi.c |  143 ++--
 drivers/net/dsa/microchip/ksz_common.c  | 1133 +++-----------------------
 drivers/net/dsa/microchip/ksz_common.h  |  230 ++++++
 drivers/net/dsa/microchip/ksz_priv.h    |  229 +++---
 drivers/net/dsa/microchip/ksz_spi.h     |   82 ++
 7 files changed, 1926 insertions(+), 1221 deletions(-)
 create mode 100644 drivers/net/dsa/microchip/ksz9477.c
 create mode 100644 drivers/net/dsa/microchip/ksz_common.h
 create mode 100644 drivers/net/dsa/microchip/ksz_spi.h

diff --git a/drivers/net/dsa/microchip/Makefile b/drivers/net/dsa/microchip/Makefile
index 5b6325b..13dd8f0 100644
--- a/drivers/net/dsa/microchip/Makefile
+++ b/drivers/net/dsa/microchip/Makefile
@@ -1,2 +1,2 @@
-obj-$(CONFIG_MICROCHIP_KSZ9477)	        += ksz_common.o
+obj-$(CONFIG_MICROCHIP_KSZ9477)	        += ksz9477.o ksz_common.o
 obj-$(CONFIG_MICROCHIP_KSZ9477_SPI_DRIVER)	+= ksz9477_spi.o
diff --git a/drivers/net/dsa/microchip/ksz9477.c b/drivers/net/dsa/microchip/ksz9477.c
new file mode 100644
index 0000000..214d380
--- /dev/null
+++ b/drivers/net/dsa/microchip/ksz9477.c
@@ -0,0 +1,1328 @@
+/*
+ * Microchip KSZ9477 switch driver main logic
+ *
+ * Copyright (C) 2017 Microchip Technology Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include <linux/delay.h>
+#include <linux/export.h>
+#include <linux/gpio.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/platform_data/microchip-ksz.h>
+#include <linux/phy.h>
+#include <linux/etherdevice.h>
+#include <linux/if_bridge.h>
+#include <net/dsa.h>
+#include <net/switchdev.h>
+
+#include "ksz_priv.h"
+#include "ksz_common.h"
+#include "ksz_9477_reg.h"
+
+static const struct {
+	int index;
+	char string[ETH_GSTRING_LEN];
+} mib_names[TOTAL_SWITCH_COUNTER_NUM] = {
+	{ 0x00, "rx_hi" },
+	{ 0x01, "rx_undersize" },
+	{ 0x02, "rx_fragments" },
+	{ 0x03, "rx_oversize" },
+	{ 0x04, "rx_jabbers" },
+	{ 0x05, "rx_symbol_err" },
+	{ 0x06, "rx_crc_err" },
+	{ 0x07, "rx_align_err" },
+	{ 0x08, "rx_mac_ctrl" },
+	{ 0x09, "rx_pause" },
+	{ 0x0A, "rx_bcast" },
+	{ 0x0B, "rx_mcast" },
+	{ 0x0C, "rx_ucast" },
+	{ 0x0D, "rx_64_or_less" },
+	{ 0x0E, "rx_65_127" },
+	{ 0x0F, "rx_128_255" },
+	{ 0x10, "rx_256_511" },
+	{ 0x11, "rx_512_1023" },
+	{ 0x12, "rx_1024_1522" },
+	{ 0x13, "rx_1523_2000" },
+	{ 0x14, "rx_2001" },
+	{ 0x15, "tx_hi" },
+	{ 0x16, "tx_late_col" },
+	{ 0x17, "tx_pause" },
+	{ 0x18, "tx_bcast" },
+	{ 0x19, "tx_mcast" },
+	{ 0x1A, "tx_ucast" },
+	{ 0x1B, "tx_deferred" },
+	{ 0x1C, "tx_total_col" },
+	{ 0x1D, "tx_exc_col" },
+	{ 0x1E, "tx_single_col" },
+	{ 0x1F, "tx_mult_col" },
+	{ 0x80, "rx_total" },
+	{ 0x81, "tx_total" },
+	{ 0x82, "rx_discards" },
+	{ 0x83, "tx_discards" },
+};
+
+static void ksz_cfg32(struct ksz_device *dev, u32 addr, u32 bits, bool set)
+{
+	u32 data;
+
+	ksz_read32(dev, addr, &data);
+	if (set)
+		data |= bits;
+	else
+		data &= ~bits;
+	ksz_write32(dev, addr, data);
+}
+
+static void ksz_port_cfg32(struct ksz_device *dev, int port, int offset,
+			   u32 bits, bool set)
+{
+	u32 addr;
+	u32 data;
+
+	addr = PORT_CTRL_ADDR(port, offset);
+	ksz_read32(dev, addr, &data);
+
+	if (set)
+		data |= bits;
+	else
+		data &= ~bits;
+
+	ksz_write32(dev, addr, data);
+}
+
+static int wait_vlan_ctrl_ready(struct ksz_device *dev, u32 waiton, int timeout)
+{
+	u8 data;
+
+	do {
+		ksz_read8(dev, REG_SW_VLAN_CTRL, &data);
+		if (!(data & waiton))
+			break;
+		usleep_range(1, 10);
+	} while (timeout-- > 0);
+
+	if (timeout <= 0)
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
+static int get_vlan_table(struct dsa_switch *ds, u16 vid, u32 *vlan_table)
+{
+	struct ksz_device *dev = ds->priv;
+	int ret;
+
+	mutex_lock(&dev->vlan_mutex);
+
+	ksz_write16(dev, REG_SW_VLAN_ENTRY_INDEX__2, vid & VLAN_INDEX_M);
+	ksz_write8(dev, REG_SW_VLAN_CTRL, VLAN_READ | VLAN_START);
+
+	/* wait to be cleared */
+	ret = wait_vlan_ctrl_ready(dev, VLAN_START, 1000);
+	if (ret < 0) {
+		dev_dbg(dev->dev, "Failed to read vlan table\n");
+		goto exit;
+	}
+
+	ksz_read32(dev, REG_SW_VLAN_ENTRY__4, &vlan_table[0]);
+	ksz_read32(dev, REG_SW_VLAN_ENTRY_UNTAG__4, &vlan_table[1]);
+	ksz_read32(dev, REG_SW_VLAN_ENTRY_PORTS__4, &vlan_table[2]);
+
+	ksz_write8(dev, REG_SW_VLAN_CTRL, 0);
+
+exit:
+	mutex_unlock(&dev->vlan_mutex);
+
+	return ret;
+}
+
+static int set_vlan_table(struct dsa_switch *ds, u16 vid, u32 *vlan_table)
+{
+	struct ksz_device *dev = ds->priv;
+	int ret;
+
+	mutex_lock(&dev->vlan_mutex);
+
+	ksz_write32(dev, REG_SW_VLAN_ENTRY__4, vlan_table[0]);
+	ksz_write32(dev, REG_SW_VLAN_ENTRY_UNTAG__4, vlan_table[1]);
+	ksz_write32(dev, REG_SW_VLAN_ENTRY_PORTS__4, vlan_table[2]);
+
+	ksz_write16(dev, REG_SW_VLAN_ENTRY_INDEX__2, vid & VLAN_INDEX_M);
+	ksz_write8(dev, REG_SW_VLAN_CTRL, VLAN_START | VLAN_WRITE);
+
+	/* wait to be cleared */
+	ret = wait_vlan_ctrl_ready(dev, VLAN_START, 1000);
+	if (ret < 0) {
+		dev_dbg(dev->dev, "Failed to write vlan table\n");
+		goto exit;
+	}
+
+	ksz_write8(dev, REG_SW_VLAN_CTRL, 0);
+
+	/* update vlan cache table */
+	dev->vlan_cache[vid].table[0] = vlan_table[0];
+	dev->vlan_cache[vid].table[1] = vlan_table[1];
+	dev->vlan_cache[vid].table[2] = vlan_table[2];
+
+exit:
+	mutex_unlock(&dev->vlan_mutex);
+
+	return ret;
+}
+
+static void read_table(struct dsa_switch *ds, u32 *table)
+{
+	struct ksz_device *dev = ds->priv;
+
+	ksz_read32(dev, REG_SW_ALU_VAL_A, &table[0]);
+	ksz_read32(dev, REG_SW_ALU_VAL_B, &table[1]);
+	ksz_read32(dev, REG_SW_ALU_VAL_C, &table[2]);
+	ksz_read32(dev, REG_SW_ALU_VAL_D, &table[3]);
+}
+
+static void write_table(struct dsa_switch *ds, u32 *table)
+{
+	struct ksz_device *dev = ds->priv;
+
+	ksz_write32(dev, REG_SW_ALU_VAL_A, table[0]);
+	ksz_write32(dev, REG_SW_ALU_VAL_B, table[1]);
+	ksz_write32(dev, REG_SW_ALU_VAL_C, table[2]);
+	ksz_write32(dev, REG_SW_ALU_VAL_D, table[3]);
+}
+
+static int wait_alu_ready(struct ksz_device *dev, u32 waiton, int timeout)
+{
+	u32 data;
+
+	do {
+		ksz_read32(dev, REG_SW_ALU_CTRL__4, &data);
+		if (!(data & waiton))
+			break;
+		usleep_range(1, 10);
+	} while (timeout-- > 0);
+
+	if (timeout <= 0)
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
+static int wait_alu_sta_ready(struct ksz_device *dev, u32 waiton, int timeout)
+{
+	u32 data;
+
+	do {
+		ksz_read32(dev, REG_SW_ALU_STAT_CTRL__4, &data);
+		if (!(data & waiton))
+			break;
+		usleep_range(1, 10);
+	} while (timeout-- > 0);
+
+	if (timeout <= 0)
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
+static int ksz9477_reset_switch(struct ksz_device *dev)
+{
+	u8 data8;
+	u16 data16;
+	u32 data32;
+
+	/* reset switch */
+	ksz_cfg(dev, REG_SW_OPERATION, SW_RESET, true);
+
+	/* turn off SPI DO Edge select */
+	ksz_read8(dev, REG_SW_GLOBAL_SERIAL_CTRL_0, &data8);
+	data8 &= ~SPI_AUTO_EDGE_DETECTION;
+	ksz_write8(dev, REG_SW_GLOBAL_SERIAL_CTRL_0, data8);
+
+	/* default configuration */
+	ksz_read8(dev, REG_SW_LUE_CTRL_1, &data8);
+	data8 = SW_AGING_ENABLE | SW_LINK_AUTO_AGING |
+	      SW_SRC_ADDR_FILTER | SW_FLUSH_STP_TABLE | SW_FLUSH_MSTP_TABLE;
+	ksz_write8(dev, REG_SW_LUE_CTRL_1, data8);
+
+	/* disable interrupts */
+	ksz_write32(dev, REG_SW_INT_MASK__4, SWITCH_INT_MASK);
+	ksz_write32(dev, REG_SW_PORT_INT_MASK__4, 0x7F);
+	ksz_read32(dev, REG_SW_PORT_INT_STATUS__4, &data32);
+
+	/* set broadcast storm protection 10% rate */
+	ksz_read16(dev, REG_SW_MAC_CTRL_2, &data16);
+	data16 &= ~BROADCAST_STORM_RATE;
+	data16 |= (BROADCAST_STORM_VALUE * BROADCAST_STORM_PROT_RATE) / 100;
+	ksz_write16(dev, REG_SW_MAC_CTRL_2, data16);
+
+	return 0;
+}
+
+static enum dsa_tag_protocol ksz9477_get_tag_protocol(struct dsa_switch *ds)
+{
+	return DSA_TAG_PROTO_KSZ;
+}
+
+static int ksz9477_phy_read16(struct dsa_switch *ds, int addr, int reg)
+{
+	struct ksz_device *dev = ds->priv;
+	u16 val = 0xffff;
+
+	/* No real PHY after this. Simulate the PHY.
+	 * A fixed PHY can be setup in the device tree, but this function is
+	 * still called for that port during initialization.
+	 * For RGMII PHY there is no way to access it so the fixed PHY should
+	 * be used.  For SGMII PHY the supporting code will be added later.
+	 */
+	if (addr >= dev->phy_port_cnt) {
+		struct ksz_port *p = &dev->ports[addr];
+
+		switch (reg) {
+		case MII_BMCR:
+			val = 0x1140;
+			break;
+		case MII_BMSR:
+			val = 0x796d;
+			break;
+		case MII_PHYSID1:
+			val = 0x0022;
+			break;
+		case MII_PHYSID2:
+			val = 0x1631;
+			break;
+		case MII_ADVERTISE:
+			val = 0x05e1;
+			break;
+		case MII_LPA:
+			val = 0xc5e1;
+			break;
+		case MII_CTRL1000:
+			val = 0x0700;
+			break;
+		case MII_STAT1000:
+			if (p->speed == SPEED_1000)
+				val = 0x3800;
+			else
+				val = 0;
+			break;
+		}
+	} else {
+		ksz_pread16(dev, addr, 0x100 + (reg << 1), &val);
+	}
+
+	return val;
+}
+
+static int ksz9477_phy_write16(struct dsa_switch *ds, int addr, int reg,
+			       u16 val)
+{
+	struct ksz_device *dev = ds->priv;
+
+	/* No real PHY after this. */
+	if (addr >= dev->phy_port_cnt)
+		return 0;
+	ksz_pwrite16(dev, addr, 0x100 + (reg << 1), val);
+
+	return 0;
+}
+
+static void ksz9477_get_strings(struct dsa_switch *ds, int port, uint8_t *buf)
+{
+	int i;
+
+	for (i = 0; i < TOTAL_SWITCH_COUNTER_NUM; i++) {
+		memcpy(buf + i * ETH_GSTRING_LEN, mib_names[i].string,
+		       ETH_GSTRING_LEN);
+	}
+}
+
+static void ksz_get_ethtool_stats(struct dsa_switch *ds, int port,
+				  uint64_t *buf)
+{
+	struct ksz_device *dev = ds->priv;
+	int i;
+	u32 data;
+	int timeout;
+
+	mutex_lock(&dev->stats_mutex);
+
+	for (i = 0; i < TOTAL_SWITCH_COUNTER_NUM; i++) {
+		data = MIB_COUNTER_READ;
+		data |= ((mib_names[i].index & 0xFF) << MIB_COUNTER_INDEX_S);
+		ksz_pwrite32(dev, port, REG_PORT_MIB_CTRL_STAT__4, data);
+
+		timeout = 1000;
+		do {
+			ksz_pread32(dev, port, REG_PORT_MIB_CTRL_STAT__4,
+				    &data);
+			usleep_range(1, 10);
+			if (!(data & MIB_COUNTER_READ))
+				break;
+		} while (timeout-- > 0);
+
+		/* failed to read MIB. get out of loop */
+		if (!timeout) {
+			dev_dbg(dev->dev, "Failed to get MIB\n");
+			break;
+		}
+
+		/* count resets upon read */
+		ksz_pread32(dev, port, REG_PORT_MIB_DATA, &data);
+
+		dev->mib_value[i] += (uint64_t)data;
+		buf[i] = dev->mib_value[i];
+	}
+
+	mutex_unlock(&dev->stats_mutex);
+}
+
+static void ksz9477_cfg_port_member(struct ksz_device *dev, int port,
+				    u8 member)
+{
+	ksz_pwrite32(dev, port, REG_PORT_VLAN_MEMBERSHIP__4, member);
+	dev->ports[port].member = member;
+}
+
+static void ksz9477_port_stp_state_set(struct dsa_switch *ds, int port,
+				       u8 state)
+{
+	struct ksz_device *dev = ds->priv;
+	struct ksz_port *p = &dev->ports[port];
+	u8 data;
+	int member = -1;
+
+	ksz_pread8(dev, port, P_STP_CTRL, &data);
+	data &= ~(PORT_TX_ENABLE | PORT_RX_ENABLE | PORT_LEARN_DISABLE);
+
+	switch (state) {
+	case BR_STATE_DISABLED:
+		data |= PORT_LEARN_DISABLE;
+		if (port != dev->cpu_port)
+			member = 0;
+		break;
+	case BR_STATE_LISTENING:
+		data |= (PORT_RX_ENABLE | PORT_LEARN_DISABLE);
+		if (port != dev->cpu_port &&
+		    p->stp_state == BR_STATE_DISABLED)
+			member = dev->host_mask | p->vid_member;
+		break;
+	case BR_STATE_LEARNING:
+		data |= PORT_RX_ENABLE;
+		break;
+	case BR_STATE_FORWARDING:
+		data |= (PORT_TX_ENABLE | PORT_RX_ENABLE);
+
+		/* This function is also used internally. */
+		if (port == dev->cpu_port)
+			break;
+
+		/* Port is a member of a bridge. */
+		if (dev->br_member & (1 << port)) {
+			dev->member |= (1 << port);
+			member = dev->member;
+		} else {
+			member = dev->host_mask | p->vid_member;
+		}
+		break;
+	case BR_STATE_BLOCKING:
+		data |= PORT_LEARN_DISABLE;
+		if (port != dev->cpu_port &&
+		    p->stp_state == BR_STATE_DISABLED)
+			member = dev->host_mask | p->vid_member;
+		break;
+	default:
+		dev_err(ds->dev, "invalid STP state: %d\n", state);
+		return;
+	}
+
+	ksz_pwrite8(dev, port, P_STP_CTRL, data);
+	if (data & PORT_RX_ENABLE)
+		dev->rx_ports |= (1 << port);
+	else
+		dev->rx_ports &= ~(1 << port);
+	if (data & PORT_TX_ENABLE)
+		dev->tx_ports |= (1 << port);
+	else
+		dev->tx_ports &= ~(1 << port);
+
+	/* Port membership may share register with STP state. */
+	if (member >= 0 && member != p->member)
+		ksz9477_cfg_port_member(dev, port, (u8)member);
+
+	/* Check if forwarding needs to be updated. */
+	if (state != BR_STATE_FORWARDING) {
+		if (dev->br_member & (1 << port))
+			dev->member &= ~(1 << port);
+	}
+
+	/* When topology has changed the function ksz_update_port_member
+	 * should be called to modify port forwarding behavior.  However
+	 * as the offload_fwd_mark indication cannot be reported here
+	 * the switch forwarding function is not enabled.
+	 */
+}
+
+static void ksz9477_flush_dyn_mac_table(struct ksz_device *dev, int port)
+{
+	u8 data;
+
+	ksz_read8(dev, REG_SW_LUE_CTRL_2, &data);
+	data &= ~(SW_FLUSH_OPTION_M << SW_FLUSH_OPTION_S);
+	data |= (SW_FLUSH_OPTION_DYN_MAC << SW_FLUSH_OPTION_S);
+	ksz_write8(dev, REG_SW_LUE_CTRL_2, data);
+	if (port < dev->mib_port_cnt) {
+		/* flush individual port */
+		ksz_pread8(dev, port, P_STP_CTRL, &data);
+		if (!(data & PORT_LEARN_DISABLE))
+			ksz_pwrite8(dev, port, P_STP_CTRL,
+				    data | PORT_LEARN_DISABLE);
+		ksz_cfg(dev, S_FLUSH_TABLE_CTRL, SW_FLUSH_DYN_MAC_TABLE, true);
+		ksz_pwrite8(dev, port, P_STP_CTRL, data);
+	} else {
+		/* flush all */
+		ksz_cfg(dev, S_FLUSH_TABLE_CTRL, SW_FLUSH_STP_TABLE, true);
+	}
+}
+
+static int ksz9477_port_vlan_filtering(struct dsa_switch *ds, int port,
+				       bool flag)
+{
+	struct ksz_device *dev = ds->priv;
+
+	if (flag) {
+		ksz_port_cfg(dev, port, REG_PORT_LUE_CTRL,
+			     PORT_VLAN_LOOKUP_VID_0, true);
+		ksz_cfg32(dev, REG_SW_QM_CTRL__4, UNICAST_VLAN_BOUNDARY, true);
+		ksz_cfg(dev, REG_SW_LUE_CTRL_0, SW_VLAN_ENABLE, true);
+	} else {
+		ksz_cfg(dev, REG_SW_LUE_CTRL_0, SW_VLAN_ENABLE, false);
+		ksz_cfg32(dev, REG_SW_QM_CTRL__4, UNICAST_VLAN_BOUNDARY, false);
+		ksz_port_cfg(dev, port, REG_PORT_LUE_CTRL,
+			     PORT_VLAN_LOOKUP_VID_0, false);
+	}
+
+	return 0;
+}
+
+static void ksz9477_port_vlan_add(struct dsa_switch *ds, int port,
+				  const struct switchdev_obj_port_vlan *vlan,
+				  struct switchdev_trans *trans)
+{
+	struct ksz_device *dev = ds->priv;
+	u32 vlan_table[3];
+	u16 vid;
+	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
+
+	for (vid = vlan->vid_begin; vid <= vlan->vid_end; vid++) {
+		if (get_vlan_table(ds, vid, vlan_table)) {
+			dev_dbg(dev->dev, "Failed to get vlan table\n");
+			return;
+		}
+
+		vlan_table[0] = VLAN_VALID | (vid & VLAN_FID_M);
+		if (untagged)
+			vlan_table[1] |= BIT(port);
+		else
+			vlan_table[1] &= ~BIT(port);
+		vlan_table[1] &= ~(BIT(dev->cpu_port));
+
+		vlan_table[2] |= BIT(port) | BIT(dev->cpu_port);
+
+		if (set_vlan_table(ds, vid, vlan_table)) {
+			dev_dbg(dev->dev, "Failed to set vlan table\n");
+			return;
+		}
+
+		/* change PVID */
+		if (vlan->flags & BRIDGE_VLAN_INFO_PVID)
+			ksz_pwrite16(dev, port, REG_PORT_DEFAULT_VID, vid);
+	}
+}
+
+static int ksz9477_port_vlan_del(struct dsa_switch *ds, int port,
+				 const struct switchdev_obj_port_vlan *vlan)
+{
+	struct ksz_device *dev = ds->priv;
+	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
+	u32 vlan_table[3];
+	u16 vid;
+	u16 pvid;
+
+	ksz_pread16(dev, port, REG_PORT_DEFAULT_VID, &pvid);
+	pvid = pvid & 0xFFF;
+
+	for (vid = vlan->vid_begin; vid <= vlan->vid_end; vid++) {
+		if (get_vlan_table(ds, vid, vlan_table)) {
+			dev_dbg(dev->dev, "Failed to get vlan table\n");
+			return -ETIMEDOUT;
+		}
+
+		vlan_table[2] &= ~BIT(port);
+
+		if (pvid == vid)
+			pvid = 1;
+
+		if (untagged)
+			vlan_table[1] &= ~BIT(port);
+
+		if (set_vlan_table(ds, vid, vlan_table)) {
+			dev_dbg(dev->dev, "Failed to set vlan table\n");
+			return -ETIMEDOUT;
+		}
+	}
+
+	ksz_pwrite16(dev, port, REG_PORT_DEFAULT_VID, pvid);
+
+	return 0;
+}
+
+static int ksz9477_port_fdb_add(struct dsa_switch *ds, int port,
+				const unsigned char *addr, u16 vid)
+{
+	struct ksz_device *dev = ds->priv;
+	u32 alu_table[4];
+	u32 data;
+	int ret = 0;
+
+	mutex_lock(&dev->alu_mutex);
+
+	/* find any entry with mac & vid */
+	data = vid << ALU_FID_INDEX_S;
+	data |= ((addr[0] << 8) | addr[1]);
+	ksz_write32(dev, REG_SW_ALU_INDEX_0, data);
+
+	data = ((addr[2] << 24) | (addr[3] << 16));
+	data |= ((addr[4] << 8) | addr[5]);
+	ksz_write32(dev, REG_SW_ALU_INDEX_1, data);
+
+	/* start read operation */
+	ksz_write32(dev, REG_SW_ALU_CTRL__4, ALU_READ | ALU_START);
+
+	/* wait to be finished */
+	ret = wait_alu_ready(dev, ALU_START, 1000);
+	if (ret < 0) {
+		dev_dbg(dev->dev, "Failed to read ALU\n");
+		goto exit;
+	}
+
+	/* read ALU entry */
+	read_table(ds, alu_table);
+
+	/* update ALU entry */
+	alu_table[0] = ALU_V_STATIC_VALID;
+	alu_table[1] |= BIT(port);
+	if (vid)
+		alu_table[1] |= ALU_V_USE_FID;
+	alu_table[2] = (vid << ALU_V_FID_S);
+	alu_table[2] |= ((addr[0] << 8) | addr[1]);
+	alu_table[3] = ((addr[2] << 24) | (addr[3] << 16));
+	alu_table[3] |= ((addr[4] << 8) | addr[5]);
+
+	write_table(ds, alu_table);
+
+	ksz_write32(dev, REG_SW_ALU_CTRL__4, ALU_WRITE | ALU_START);
+
+	/* wait to be finished */
+	ret = wait_alu_ready(dev, ALU_START, 1000);
+	if (ret < 0)
+		dev_dbg(dev->dev, "Failed to write ALU\n");
+
+exit:
+	mutex_unlock(&dev->alu_mutex);
+
+	return ret;
+}
+
+static int ksz9477_port_fdb_del(struct dsa_switch *ds, int port,
+				const unsigned char *addr, u16 vid)
+{
+	struct ksz_device *dev = ds->priv;
+	u32 alu_table[4];
+	u32 data;
+	int ret = 0;
+
+	mutex_lock(&dev->alu_mutex);
+
+	/* read any entry with mac & vid */
+	data = vid << ALU_FID_INDEX_S;
+	data |= ((addr[0] << 8) | addr[1]);
+	ksz_write32(dev, REG_SW_ALU_INDEX_0, data);
+
+	data = ((addr[2] << 24) | (addr[3] << 16));
+	data |= ((addr[4] << 8) | addr[5]);
+	ksz_write32(dev, REG_SW_ALU_INDEX_1, data);
+
+	/* start read operation */
+	ksz_write32(dev, REG_SW_ALU_CTRL__4, ALU_READ | ALU_START);
+
+	/* wait to be finished */
+	ret = wait_alu_ready(dev, ALU_START, 1000);
+	if (ret < 0) {
+		dev_dbg(dev->dev, "Failed to read ALU\n");
+		goto exit;
+	}
+
+	ksz_read32(dev, REG_SW_ALU_VAL_A, &alu_table[0]);
+	if (alu_table[0] & ALU_V_STATIC_VALID) {
+		ksz_read32(dev, REG_SW_ALU_VAL_B, &alu_table[1]);
+		ksz_read32(dev, REG_SW_ALU_VAL_C, &alu_table[2]);
+		ksz_read32(dev, REG_SW_ALU_VAL_D, &alu_table[3]);
+
+		/* clear forwarding port */
+		alu_table[2] &= ~BIT(port);
+
+		/* if there is no port to forward, clear table */
+		if ((alu_table[2] & ALU_V_PORT_MAP) == 0) {
+			alu_table[0] = 0;
+			alu_table[1] = 0;
+			alu_table[2] = 0;
+			alu_table[3] = 0;
+		}
+	} else {
+		alu_table[0] = 0;
+		alu_table[1] = 0;
+		alu_table[2] = 0;
+		alu_table[3] = 0;
+	}
+
+	write_table(ds, alu_table);
+
+	ksz_write32(dev, REG_SW_ALU_CTRL__4, ALU_WRITE | ALU_START);
+
+	/* wait to be finished */
+	ret = wait_alu_ready(dev, ALU_START, 1000);
+	if (ret < 0)
+		dev_dbg(dev->dev, "Failed to write ALU\n");
+
+exit:
+	mutex_unlock(&dev->alu_mutex);
+
+	return ret;
+}
+
+static void convert_alu(struct alu_struct *alu, u32 *alu_table)
+{
+	alu->is_static = !!(alu_table[0] & ALU_V_STATIC_VALID);
+	alu->is_src_filter = !!(alu_table[0] & ALU_V_SRC_FILTER);
+	alu->is_dst_filter = !!(alu_table[0] & ALU_V_DST_FILTER);
+	alu->prio_age = (alu_table[0] >> ALU_V_PRIO_AGE_CNT_S) &
+			ALU_V_PRIO_AGE_CNT_M;
+	alu->mstp = alu_table[0] & ALU_V_MSTP_M;
+
+	alu->is_override = !!(alu_table[1] & ALU_V_OVERRIDE);
+	alu->is_use_fid = !!(alu_table[1] & ALU_V_USE_FID);
+	alu->port_forward = alu_table[1] & ALU_V_PORT_MAP;
+
+	alu->fid = (alu_table[2] >> ALU_V_FID_S) & ALU_V_FID_M;
+
+	alu->mac[0] = (alu_table[2] >> 8) & 0xFF;
+	alu->mac[1] = alu_table[2] & 0xFF;
+	alu->mac[2] = (alu_table[3] >> 24) & 0xFF;
+	alu->mac[3] = (alu_table[3] >> 16) & 0xFF;
+	alu->mac[4] = (alu_table[3] >> 8) & 0xFF;
+	alu->mac[5] = alu_table[3] & 0xFF;
+}
+
+static int ksz9477_port_fdb_dump(struct dsa_switch *ds, int port,
+				 dsa_fdb_dump_cb_t *cb, void *data)
+{
+	struct ksz_device *dev = ds->priv;
+	int ret = 0;
+	u32 ksz_data;
+	u32 alu_table[4];
+	struct alu_struct alu;
+	int timeout;
+
+	mutex_lock(&dev->alu_mutex);
+
+	/* start ALU search */
+	ksz_write32(dev, REG_SW_ALU_CTRL__4, ALU_START | ALU_SEARCH);
+
+	do {
+		timeout = 1000;
+		do {
+			ksz_read32(dev, REG_SW_ALU_CTRL__4, &ksz_data);
+			if ((ksz_data & ALU_VALID) || !(ksz_data & ALU_START))
+				break;
+			usleep_range(1, 10);
+		} while (timeout-- > 0);
+
+		if (!timeout) {
+			dev_dbg(dev->dev, "Failed to search ALU\n");
+			ret = -ETIMEDOUT;
+			goto exit;
+		}
+
+		/* read ALU table */
+		read_table(ds, alu_table);
+
+		convert_alu(&alu, alu_table);
+
+		if (alu.port_forward & BIT(port)) {
+			ret = cb(alu.mac, alu.fid, alu.is_static, data);
+			if (ret)
+				goto exit;
+		}
+	} while (ksz_data & ALU_START);
+
+exit:
+
+	/* stop ALU search */
+	ksz_write32(dev, REG_SW_ALU_CTRL__4, 0);
+
+	mutex_unlock(&dev->alu_mutex);
+
+	return ret;
+}
+
+static void ksz9477_port_mdb_add(struct dsa_switch *ds, int port,
+				 const struct switchdev_obj_port_mdb *mdb,
+				 struct switchdev_trans *trans)
+{
+	struct ksz_device *dev = ds->priv;
+	u32 static_table[4];
+	u32 data;
+	int index;
+	u32 mac_hi, mac_lo;
+
+	mac_hi = ((mdb->addr[0] << 8) | mdb->addr[1]);
+	mac_lo = ((mdb->addr[2] << 24) | (mdb->addr[3] << 16));
+	mac_lo |= ((mdb->addr[4] << 8) | mdb->addr[5]);
+
+	mutex_lock(&dev->alu_mutex);
+
+	for (index = 0; index < dev->num_statics; index++) {
+		/* find empty slot first */
+		data = (index << ALU_STAT_INDEX_S) |
+			ALU_STAT_READ | ALU_STAT_START;
+		ksz_write32(dev, REG_SW_ALU_STAT_CTRL__4, data);
+
+		/* wait to be finished */
+		if (wait_alu_sta_ready(dev, ALU_STAT_START, 1000) < 0) {
+			dev_dbg(dev->dev, "Failed to read ALU STATIC\n");
+			goto exit;
+		}
+
+		/* read ALU static table */
+		read_table(ds, static_table);
+
+		if (static_table[0] & ALU_V_STATIC_VALID) {
+			/* check this has same vid & mac address */
+			if (((static_table[2] >> ALU_V_FID_S) == mdb->vid) &&
+			    ((static_table[2] & ALU_V_MAC_ADDR_HI) == mac_hi) &&
+			    static_table[3] == mac_lo) {
+				/* found matching one */
+				break;
+			}
+		} else {
+			/* found empty one */
+			break;
+		}
+	}
+
+	/* no available entry */
+	if (index == dev->num_statics)
+		goto exit;
+
+	/* add entry */
+	static_table[0] = ALU_V_STATIC_VALID;
+	static_table[1] |= BIT(port);
+	if (mdb->vid)
+		static_table[1] |= ALU_V_USE_FID;
+	static_table[2] = (mdb->vid << ALU_V_FID_S);
+	static_table[2] |= mac_hi;
+	static_table[3] = mac_lo;
+
+	write_table(ds, static_table);
+
+	data = (index << ALU_STAT_INDEX_S) | ALU_STAT_START;
+	ksz_write32(dev, REG_SW_ALU_STAT_CTRL__4, data);
+
+	/* wait to be finished */
+	if (wait_alu_sta_ready(dev, ALU_STAT_START, 1000) < 0)
+		dev_dbg(dev->dev, "Failed to read ALU STATIC\n");
+
+exit:
+	mutex_unlock(&dev->alu_mutex);
+}
+
+static int ksz9477_port_mdb_del(struct dsa_switch *ds, int port,
+				const struct switchdev_obj_port_mdb *mdb)
+{
+	struct ksz_device *dev = ds->priv;
+	u32 static_table[4];
+	u32 data;
+	int index;
+	int ret = 0;
+	u32 mac_hi, mac_lo;
+
+	mac_hi = ((mdb->addr[0] << 8) | mdb->addr[1]);
+	mac_lo = ((mdb->addr[2] << 24) | (mdb->addr[3] << 16));
+	mac_lo |= ((mdb->addr[4] << 8) | mdb->addr[5]);
+
+	mutex_lock(&dev->alu_mutex);
+
+	for (index = 0; index < dev->num_statics; index++) {
+		/* find empty slot first */
+		data = (index << ALU_STAT_INDEX_S) |
+			ALU_STAT_READ | ALU_STAT_START;
+		ksz_write32(dev, REG_SW_ALU_STAT_CTRL__4, data);
+
+		/* wait to be finished */
+		ret = wait_alu_sta_ready(dev, ALU_STAT_START, 1000);
+		if (ret < 0) {
+			dev_dbg(dev->dev, "Failed to read ALU STATIC\n");
+			goto exit;
+		}
+
+		/* read ALU static table */
+		read_table(ds, static_table);
+
+		if (static_table[0] & ALU_V_STATIC_VALID) {
+			/* check this has same vid & mac address */
+
+			if (((static_table[2] >> ALU_V_FID_S) == mdb->vid) &&
+			    ((static_table[2] & ALU_V_MAC_ADDR_HI) == mac_hi) &&
+			    static_table[3] == mac_lo) {
+				/* found matching one */
+				break;
+			}
+		}
+	}
+
+	/* no available entry */
+	if (index == dev->num_statics) {
+		ret = -EINVAL;
+		goto exit;
+	}
+
+	/* clear port */
+	static_table[1] &= ~BIT(port);
+
+	if ((static_table[1] & ALU_V_PORT_MAP) == 0) {
+		/* delete entry */
+		static_table[0] = 0;
+		static_table[1] = 0;
+		static_table[2] = 0;
+		static_table[3] = 0;
+	}
+
+	write_table(ds, static_table);
+
+	data = (index << ALU_STAT_INDEX_S) | ALU_STAT_START;
+	ksz_write32(dev, REG_SW_ALU_STAT_CTRL__4, data);
+
+	/* wait to be finished */
+	ret = wait_alu_sta_ready(dev, ALU_STAT_START, 1000);
+	if (ret < 0)
+		dev_dbg(dev->dev, "Failed to read ALU STATIC\n");
+
+exit:
+	mutex_unlock(&dev->alu_mutex);
+
+	return ret;
+}
+
+static int ksz9477_port_mirror_add(struct dsa_switch *ds, int port,
+				   struct dsa_mall_mirror_tc_entry *mirror,
+				   bool ingress)
+{
+	struct ksz_device *dev = ds->priv;
+
+	if (ingress)
+		ksz_port_cfg(dev, port, P_MIRROR_CTRL, PORT_MIRROR_RX, true);
+	else
+		ksz_port_cfg(dev, port, P_MIRROR_CTRL, PORT_MIRROR_TX, true);
+
+	ksz_port_cfg(dev, port, P_MIRROR_CTRL, PORT_MIRROR_SNIFFER, false);
+
+	/* configure mirror port */
+	ksz_port_cfg(dev, mirror->to_local_port, P_MIRROR_CTRL,
+		     PORT_MIRROR_SNIFFER, true);
+
+	ksz_cfg(dev, S_MIRROR_CTRL, SW_MIRROR_RX_TX, false);
+
+	return 0;
+}
+
+static void ksz9477_port_mirror_del(struct dsa_switch *ds, int port,
+				    struct dsa_mall_mirror_tc_entry *mirror)
+{
+	struct ksz_device *dev = ds->priv;
+	u8 data;
+
+	if (mirror->ingress)
+		ksz_port_cfg(dev, port, P_MIRROR_CTRL, PORT_MIRROR_RX, false);
+	else
+		ksz_port_cfg(dev, port, P_MIRROR_CTRL, PORT_MIRROR_TX, false);
+
+	ksz_pread8(dev, port, P_MIRROR_CTRL, &data);
+
+	if (!(data & (PORT_MIRROR_RX | PORT_MIRROR_TX)))
+		ksz_port_cfg(dev, mirror->to_local_port, P_MIRROR_CTRL,
+			     PORT_MIRROR_SNIFFER, false);
+}
+
+static void ksz9477_port_setup(struct ksz_device *dev, int port, bool cpu_port)
+{
+	u8 data8;
+	u8 member;
+	u16 data16;
+	struct ksz_port *p = &dev->ports[port];
+
+	/* enable tag tail for host port */
+	if (cpu_port)
+		ksz_port_cfg(dev, port, REG_PORT_CTRL_0, PORT_TAIL_TAG_ENABLE,
+			     true);
+
+	ksz_port_cfg(dev, port, REG_PORT_CTRL_0, PORT_MAC_LOOPBACK, false);
+
+	/* set back pressure */
+	ksz_port_cfg(dev, port, REG_PORT_MAC_CTRL_1, PORT_BACK_PRESSURE, true);
+
+	/* enable broadcast storm limit */
+	ksz_port_cfg(dev, port, P_BCAST_STORM_CTRL, PORT_BROADCAST_STORM, true);
+
+	/* disable DiffServ priority */
+	ksz_port_cfg(dev, port, P_PRIO_CTRL, PORT_DIFFSERV_PRIO_ENABLE, false);
+
+	/* replace priority */
+	ksz_port_cfg(dev, port, REG_PORT_MRI_MAC_CTRL, PORT_USER_PRIO_CEILING,
+		     false);
+	ksz_port_cfg32(dev, port, REG_PORT_MTI_QUEUE_CTRL_0__4,
+		       MTI_PVID_REPLACE, false);
+
+	/* enable 802.1p priority */
+	ksz_port_cfg(dev, port, P_PRIO_CTRL, PORT_802_1P_PRIO_ENABLE, true);
+
+	if (port < dev->phy_port_cnt) {
+		/* do not force flow control */
+		ksz_port_cfg(dev, port, REG_PORT_CTRL_0,
+			     PORT_FORCE_TX_FLOW_CTRL | PORT_FORCE_RX_FLOW_CTRL,
+			     false);
+
+	} else {
+		/* force flow control */
+		ksz_port_cfg(dev, port, REG_PORT_CTRL_0,
+			     PORT_FORCE_TX_FLOW_CTRL | PORT_FORCE_RX_FLOW_CTRL,
+			     true);
+
+		/* configure MAC to 1G & RGMII mode */
+		ksz_pread8(dev, port, REG_PORT_XMII_CTRL_1, &data8);
+		data8 &= ~PORT_MII_NOT_1GBIT;
+		data8 &= ~PORT_MII_SEL_M;
+		switch (dev->interface) {
+		case PHY_INTERFACE_MODE_MII:
+			data8 |= PORT_MII_NOT_1GBIT;
+			data8 |= PORT_MII_SEL;
+			p->speed = SPEED_100;
+			break;
+		case PHY_INTERFACE_MODE_RMII:
+			data8 |= PORT_MII_NOT_1GBIT;
+			data8 |= PORT_RMII_SEL;
+			p->speed = SPEED_100;
+			break;
+		case PHY_INTERFACE_MODE_GMII:
+			data8 |= PORT_GMII_SEL;
+			p->speed = SPEED_1000;
+			break;
+		default:
+			data8 &= ~PORT_RGMII_ID_IG_ENABLE;
+			data8 &= ~PORT_RGMII_ID_EG_ENABLE;
+			if (dev->interface == PHY_INTERFACE_MODE_RGMII_ID ||
+			    dev->interface == PHY_INTERFACE_MODE_RGMII_RXID)
+				data8 |= PORT_RGMII_ID_IG_ENABLE;
+			if (dev->interface == PHY_INTERFACE_MODE_RGMII_ID ||
+			    dev->interface == PHY_INTERFACE_MODE_RGMII_TXID)
+				data8 |= PORT_RGMII_ID_EG_ENABLE;
+			data8 |= PORT_RGMII_SEL;
+			p->speed = SPEED_1000;
+			break;
+		}
+		ksz_pwrite8(dev, port, REG_PORT_XMII_CTRL_1, data8);
+		p->duplex = 1;
+	}
+	if (cpu_port) {
+		member = dev->port_mask;
+		dev->on_ports = dev->host_mask;
+		dev->live_ports = dev->host_mask;
+	} else {
+		member = dev->host_mask | p->vid_member;
+		dev->on_ports |= (1 << port);
+
+		/* Link was detected before port is enabled. */
+		if (p->link_up)
+			dev->live_ports |= (1 << port);
+	}
+	ksz9477_cfg_port_member(dev, port, member);
+
+	/* clear pending interrupts */
+	ksz_pread16(dev, port, REG_PORT_PHY_INT_ENABLE, &data16);
+}
+
+static void ksz9477_config_cpu_port(struct dsa_switch *ds)
+{
+	struct ksz_device *dev = ds->priv;
+	struct ksz_port *p;
+	int i;
+
+	ds->num_ports = dev->port_cnt;
+
+	for (i = 0; i < ds->num_ports; i++) {
+		if (dsa_is_cpu_port(ds, i) && (dev->cpu_ports & (1 << i))) {
+			dev->cpu_port = i;
+			dev->host_mask = (1 << dev->cpu_port);
+			dev->port_mask |= dev->host_mask;
+
+			/* enable cpu port */
+			ksz9477_port_setup(dev, i, true);
+			p = &dev->ports[dev->cpu_port];
+			p->vid_member = dev->port_mask;
+			p->on = 1;
+		}
+	}
+
+	dev->member = dev->host_mask;
+
+	for (i = 0; i < dev->mib_port_cnt; i++) {
+		if (i == dev->cpu_port)
+			continue;
+		p = &dev->ports[i];
+
+		/* Initialize to non-zero so that ksz_cfg_port_member() will
+		 * be called.
+		 */
+		p->vid_member = (1 << i);
+		p->member = dev->port_mask;
+		ksz9477_port_stp_state_set(ds, i, BR_STATE_DISABLED);
+		p->on = 1;
+		if (i < dev->phy_port_cnt)
+			p->phy = 1;
+		if (dev->chip_id == 0x00947700 && i == 6) {
+			p->sgmii = 1;
+
+			/* SGMII PHY detection code is not implemented yet. */
+			p->phy = 0;
+		}
+	}
+}
+
+static int ksz9477_set_addr(struct dsa_switch *ds, u8 *addr)
+{
+	struct ksz_device *dev = ds->priv;
+
+	ksz_set(dev, REG_SW_MAC_ADDR_0, addr, ETH_ALEN);
+
+	return 0;
+}
+
+static int ksz9477_setup(struct dsa_switch *ds)
+{
+	struct ksz_device *dev = ds->priv;
+	int ret = 0;
+
+	dev->vlan_cache = devm_kcalloc(dev->dev, sizeof(struct vlan_table),
+				       dev->num_vlans, GFP_KERNEL);
+	if (!dev->vlan_cache)
+		return -ENOMEM;
+
+	ret = ksz9477_reset_switch(dev);
+	if (ret) {
+		dev_err(ds->dev, "failed to reset switch\n");
+		return ret;
+	}
+
+	/* accept packet up to 2000bytes */
+	ksz_cfg(dev, REG_SW_MAC_CTRL_1, SW_LEGAL_PACKET_DISABLE, true);
+
+	ksz9477_config_cpu_port(ds);
+
+	ksz_cfg(dev, REG_SW_MAC_CTRL_1, MULTICAST_STORM_DISABLE, true);
+
+	/* queue based egress rate limit */
+	ksz_cfg(dev, REG_SW_MAC_CTRL_5, SW_OUT_RATE_LIMIT_QUEUE_BASED, true);
+
+	/* start switch */
+	ksz_cfg(dev, REG_SW_OPERATION, SW_START, true);
+
+	return 0;
+}
+
+static const struct dsa_switch_ops ksz9477_switch_ops = {
+	.get_tag_protocol	= ksz9477_get_tag_protocol,
+	.setup			= ksz9477_setup,
+	.set_addr		= ksz9477_set_addr,
+	.phy_read		= ksz9477_phy_read16,
+	.phy_write		= ksz9477_phy_write16,
+	.port_enable		= ksz_enable_port,
+	.port_disable		= ksz_disable_port,
+	.get_strings		= ksz9477_get_strings,
+	.get_ethtool_stats	= ksz_get_ethtool_stats,
+	.get_sset_count		= ksz_sset_count,
+	.port_bridge_join	= ksz_port_bridge_join,
+	.port_bridge_leave	= ksz_port_bridge_leave,
+	.port_stp_state_set	= ksz9477_port_stp_state_set,
+	.port_fast_age		= ksz_port_fast_age,
+	.port_vlan_filtering	= ksz9477_port_vlan_filtering,
+	.port_vlan_prepare	= ksz_port_vlan_prepare,
+	.port_vlan_add		= ksz9477_port_vlan_add,
+	.port_vlan_del		= ksz9477_port_vlan_del,
+	.port_fdb_dump		= ksz9477_port_fdb_dump,
+	.port_fdb_add		= ksz9477_port_fdb_add,
+	.port_fdb_del		= ksz9477_port_fdb_del,
+	.port_mdb_prepare       = ksz_port_mdb_prepare,
+	.port_mdb_add           = ksz9477_port_mdb_add,
+	.port_mdb_del           = ksz9477_port_mdb_del,
+	.port_mirror_add	= ksz9477_port_mirror_add,
+	.port_mirror_del	= ksz9477_port_mirror_del,
+};
+
+static u32 ksz9477_get_port_addr(int port, int offset)
+{
+	return PORT_CTRL_ADDR(port, offset);
+}
+
+static int ksz9477_switch_detect(struct ksz_device *dev)
+{
+	u8 data8;
+	u32 id32;
+	int ret;
+
+	/* turn off SPI DO Edge select */
+	ret = ksz_read8(dev, REG_SW_GLOBAL_SERIAL_CTRL_0, &data8);
+	if (ret)
+		return ret;
+
+	data8 &= ~SPI_AUTO_EDGE_DETECTION;
+	ret = ksz_write8(dev, REG_SW_GLOBAL_SERIAL_CTRL_0, data8);
+	if (ret)
+		return ret;
+
+	/* read chip id */
+	ret = ksz_read32(dev, REG_CHIP_ID0__1, &id32);
+	if (ret)
+		return ret;
+
+	/* Number of ports can be reduced depending on chip. */
+	dev->mib_port_cnt = TOTAL_PORT_NUM;
+	dev->phy_port_cnt = 5;
+
+	dev->chip_id = id32;
+
+	return 0;
+}
+
+struct ksz_chip_data {
+	u32 chip_id;
+	const char *dev_name;
+	int num_vlans;
+	int num_alus;
+	int num_statics;
+	int cpu_ports;
+	int port_cnt;
+};
+
+static const struct ksz_chip_data ksz9477_switch_chips[] = {
+	{
+		.chip_id = 0x00947700,
+		.dev_name = "KSZ9477",
+		.num_vlans = 4096,
+		.num_alus = 4096,
+		.num_statics = 16,
+		.cpu_ports = 0x7F,	/* can be configured as cpu port */
+		.port_cnt = 7,		/* total physical port count */
+	},
+};
+
+static int ksz9477_switch_init(struct ksz_device *dev)
+{
+	int i;
+
+	mutex_init(&dev->reg_mutex);
+	mutex_init(&dev->stats_mutex);
+	mutex_init(&dev->alu_mutex);
+	mutex_init(&dev->vlan_mutex);
+
+	dev->ds->ops = &ksz9477_switch_ops;
+
+	for (i = 0; i < ARRAY_SIZE(ksz9477_switch_chips); i++) {
+		const struct ksz_chip_data *chip = &ksz9477_switch_chips[i];
+
+		if (dev->chip_id == chip->chip_id) {
+			dev->name = chip->dev_name;
+			dev->num_vlans = chip->num_vlans;
+			dev->num_alus = chip->num_alus;
+			dev->num_statics = chip->num_statics;
+			dev->port_cnt = chip->port_cnt;
+			dev->cpu_ports = chip->cpu_ports;
+
+			break;
+		}
+	}
+
+	/* no switch found */
+	if (!dev->port_cnt)
+		return -ENODEV;
+
+	dev->port_mask = (1 << dev->port_cnt) - 1;
+
+	dev->reg_mib_cnt = SWITCH_COUNTER_NUM;
+	dev->mib_cnt = TOTAL_SWITCH_COUNTER_NUM;
+
+	i = dev->mib_port_cnt;
+	dev->ports = devm_kzalloc(dev->dev, sizeof(struct ksz_port) * i,
+				  GFP_KERNEL);
+	if (!dev->ports)
+		return -ENOMEM;
+	for (i = 0; i < dev->mib_port_cnt; i++) {
+		dev->ports[i].mib.counters =
+			devm_kzalloc(dev->dev,
+				     sizeof(u64) *
+				     (TOTAL_SWITCH_COUNTER_NUM + 1),
+				     GFP_KERNEL);
+		if (!dev->ports[i].mib.counters)
+			return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static void ksz9477_switch_exit(struct ksz_device *dev)
+{
+	ksz9477_reset_switch(dev);
+}
+
+static const struct ksz_dev_ops ksz9477_dev_ops = {
+	.get_port_addr = ksz9477_get_port_addr,
+	.cfg_port_member = ksz9477_cfg_port_member,
+	.flush_dyn_mac_table = ksz9477_flush_dyn_mac_table,
+	.port_setup = ksz9477_port_setup,
+	.shutdown = ksz9477_reset_switch,
+	.detect = ksz9477_switch_detect,
+	.init = ksz9477_switch_init,
+	.exit = ksz9477_switch_exit,
+};
+
+int ksz9477_switch_register(struct ksz_device *dev)
+{
+	return ksz_switch_register(dev, &ksz9477_dev_ops);
+}
+EXPORT_SYMBOL(ksz9477_switch_register);
+
+MODULE_AUTHOR("Woojung Huh <Woojung.Huh@microchip.com>");
+MODULE_DESCRIPTION("Microchip KSZ9477 Series Switch DSA Driver");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/dsa/microchip/ksz9477_spi.c b/drivers/net/dsa/microchip/ksz9477_spi.c
index d0d6920..966981a 100644
--- a/drivers/net/dsa/microchip/ksz9477_spi.c
+++ b/drivers/net/dsa/microchip/ksz9477_spi.c
@@ -1,5 +1,5 @@
 /*
- * Microchip KSZ series register access through SPI
+ * Microchip KSZ9477 series register access through SPI
  *
  * Copyright (C) 2017 Microchip Technology Inc.
  *
@@ -25,6 +25,7 @@
 #include <linux/spi/spi.h>
 
 #include "ksz_priv.h"
+#include "ksz_spi.h"
 
 /* SPI frame opcodes */
 #define KS_SPIOP_RD			3
@@ -34,8 +35,11 @@
 #define SPI_ADDR_MASK			(BIT(SPI_ADDR_SHIFT) - 1)
 #define SPI_TURNAROUND_SHIFT		5
 
-static int ksz_spi_read_reg(struct spi_device *spi, u32 reg, u8 *val,
-			    unsigned int len)
+/* Enough to read all switch port registers. */
+#define SPI_TX_BUF_LEN			0x100
+
+static int ksz9477_spi_read_reg(struct spi_device *spi, u32 reg, u8 *val,
+				unsigned int len)
 {
 	u32 txbuf;
 	int ret;
@@ -49,27 +53,36 @@ static int ksz_spi_read_reg(struct spi_device *spi, u32 reg, u8 *val,
 	return ret;
 }
 
-static int ksz_spi_read(struct ksz_device *dev, u32 reg, u8 *data,
-			unsigned int len)
+static int ksz9477_spi_write_reg(struct spi_device *spi, u32 reg, u8 *val,
+				 unsigned int len)
 {
-	struct spi_device *spi = dev->priv;
+	u32 *txbuf = (u32 *)val;
 
-	return ksz_spi_read_reg(spi, reg, data, len);
+	*txbuf = reg & SPI_ADDR_MASK;
+	*txbuf |= (KS_SPIOP_WR << SPI_ADDR_SHIFT);
+	*txbuf <<= SPI_TURNAROUND_SHIFT;
+	*txbuf = cpu_to_be32(*txbuf);
+
+	return spi_write(spi, txbuf, 4 + len);
 }
 
-static int ksz_spi_read8(struct ksz_device *dev, u32 reg, u8 *val)
+static int ksz_spi_read(struct ksz_device *dev, u32 reg, u8 *data,
+			unsigned int len)
 {
-	return ksz_spi_read(dev, reg, val, 1);
+	struct spi_device *spi = dev->priv;
+
+	return ksz9477_spi_read_reg(spi, reg, data, len);
 }
 
-static int ksz_spi_read16(struct ksz_device *dev, u32 reg, u16 *val)
+static int ksz_spi_write(struct ksz_device *dev, u32 reg, void *data,
+			 unsigned int len)
 {
-	int ret = ksz_spi_read(dev, reg, (u8 *)val, 2);
-
-	if (!ret)
-		*val = be16_to_cpu(*val);
+	struct spi_device *spi = dev->priv;
 
-	return ret;
+	if (len > SPI_TX_BUF_LEN)
+		len = SPI_TX_BUF_LEN;
+	memcpy(&dev->txbuf[4], data, len);
+	return ksz9477_spi_write_reg(spi, reg, dev->txbuf, len);
 }
 
 static int ksz_spi_read24(struct ksz_device *dev, u32 reg, u32 *val)
@@ -87,72 +100,15 @@ static int ksz_spi_read24(struct ksz_device *dev, u32 reg, u32 *val)
 	return ret;
 }
 
-static int ksz_spi_read32(struct ksz_device *dev, u32 reg, u32 *val)
-{
-	int ret = ksz_spi_read(dev, reg, (u8 *)val, 4);
-
-	if (!ret)
-		*val = be32_to_cpu(*val);
-
-	return ret;
-}
-
-static int ksz_spi_write_reg(struct spi_device *spi, u32 reg, u8 *val,
-			     unsigned int len)
-{
-	u32 txbuf;
-	u8 data[12];
-	int i;
-
-	txbuf = reg & SPI_ADDR_MASK;
-	txbuf |= (KS_SPIOP_WR << SPI_ADDR_SHIFT);
-	txbuf <<= SPI_TURNAROUND_SHIFT;
-	txbuf = cpu_to_be32(txbuf);
-
-	data[0] = txbuf & 0xFF;
-	data[1] = (txbuf & 0xFF00) >> 8;
-	data[2] = (txbuf & 0xFF0000) >> 16;
-	data[3] = (txbuf & 0xFF000000) >> 24;
-	for (i = 0; i < len; i++)
-		data[i + 4] = val[i];
-
-	return spi_write(spi, &data, 4 + len);
-}
-
-static int ksz_spi_write8(struct ksz_device *dev, u32 reg, u8 value)
-{
-	struct spi_device *spi = dev->priv;
-
-	return ksz_spi_write_reg(spi, reg, &value, 1);
-}
-
-static int ksz_spi_write16(struct ksz_device *dev, u32 reg, u16 value)
-{
-	struct spi_device *spi = dev->priv;
-
-	value = cpu_to_be16(value);
-	return ksz_spi_write_reg(spi, reg, (u8 *)&value, 2);
-}
-
 static int ksz_spi_write24(struct ksz_device *dev, u32 reg, u32 value)
 {
-	struct spi_device *spi = dev->priv;
-
 	/* make it to big endian 24bit from MSB */
 	value <<= 8;
 	value = cpu_to_be32(value);
-	return ksz_spi_write_reg(spi, reg, (u8 *)&value, 3);
+	return ksz_spi_write(dev, reg, &value, 3);
 }
 
-static int ksz_spi_write32(struct ksz_device *dev, u32 reg, u32 value)
-{
-	struct spi_device *spi = dev->priv;
-
-	value = cpu_to_be32(value);
-	return ksz_spi_write_reg(spi, reg, (u8 *)&value, 4);
-}
-
-static const struct ksz_io_ops ksz_spi_ops = {
+static const struct ksz_io_ops ksz9477_spi_ops = {
 	.read8 = ksz_spi_read8,
 	.read16 = ksz_spi_read16,
 	.read24 = ksz_spi_read24,
@@ -161,21 +117,27 @@ static int ksz_spi_write32(struct ksz_device *dev, u32 reg, u32 value)
 	.write16 = ksz_spi_write16,
 	.write24 = ksz_spi_write24,
 	.write32 = ksz_spi_write32,
+	.get = ksz_spi_get,
+	.set = ksz_spi_set,
 };
 
-static int ksz_spi_probe(struct spi_device *spi)
+static int ksz9477_spi_probe(struct spi_device *spi)
 {
 	struct ksz_device *dev;
 	int ret;
 
-	dev = ksz_switch_alloc(&spi->dev, &ksz_spi_ops, spi);
+	dev = ksz_switch_alloc(&spi->dev, &ksz9477_spi_ops, spi);
 	if (!dev)
 		return -ENOMEM;
 
 	if (spi->dev.platform_data)
 		dev->pdata = spi->dev.platform_data;
 
-	ret = ksz_switch_register(dev);
+	dev->txbuf = devm_kzalloc(dev->dev, 4 + SPI_TX_BUF_LEN, GFP_KERNEL);
+
+	ret = ksz9477_switch_register(dev);
+
+	/* Main DSA driver may not be started yet. */
 	if (ret)
 		return ret;
 
@@ -184,7 +146,7 @@ static int ksz_spi_probe(struct spi_device *spi)
 	return 0;
 }
 
-static int ksz_spi_remove(struct spi_device *spi)
+static int ksz9477_spi_remove(struct spi_device *spi)
 {
 	struct ksz_device *dev = spi_get_drvdata(spi);
 
@@ -194,24 +156,33 @@ static int ksz_spi_remove(struct spi_device *spi)
 	return 0;
 }
 
-static const struct of_device_id ksz_dt_ids[] = {
+static void ksz9477_spi_shutdown(struct spi_device *spi)
+{
+	struct ksz_device *dev = spi_get_drvdata(spi);
+
+	if (dev && dev->dev_ops->shutdown)
+		dev->dev_ops->shutdown(dev);
+}
+
+static const struct of_device_id ksz9477_dt_ids[] = {
 	{ .compatible = "microchip,ksz9477" },
 	{},
 };
-MODULE_DEVICE_TABLE(of, ksz_dt_ids);
+MODULE_DEVICE_TABLE(of, ksz9477_dt_ids);
 
-static struct spi_driver ksz_spi_driver = {
+static struct spi_driver ksz9477_spi_driver = {
 	.driver = {
 		.name	= "ksz9477-switch",
 		.owner	= THIS_MODULE,
-		.of_match_table = of_match_ptr(ksz_dt_ids),
+		.of_match_table = of_match_ptr(ksz9477_dt_ids),
 	},
-	.probe	= ksz_spi_probe,
-	.remove	= ksz_spi_remove,
+	.probe	= ksz9477_spi_probe,
+	.remove	= ksz9477_spi_remove,
+	.shutdown = ksz9477_spi_shutdown,
 };
 
-module_spi_driver(ksz_spi_driver);
+module_spi_driver(ksz9477_spi_driver);
 
 MODULE_AUTHOR("Woojung Huh <Woojung.Huh@microchip.com>");
-MODULE_DESCRIPTION("Microchip KSZ Series Switch SPI access Driver");
+MODULE_DESCRIPTION("Microchip KSZ9477 Series Switch SPI access Driver");
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/dsa/microchip/ksz_common.c b/drivers/net/dsa/microchip/ksz_common.c
index 7a0d10f..1c9c4c5 100644
--- a/drivers/net/dsa/microchip/ksz_common.c
+++ b/drivers/net/dsa/microchip/ksz_common.c
@@ -26,959 +26,202 @@
 #include <linux/phy.h>
 #include <linux/etherdevice.h>
 #include <linux/if_bridge.h>
+#include <linux/of_net.h>
 #include <net/dsa.h>
 #include <net/switchdev.h>
 
 #include "ksz_priv.h"
 
-static const struct {
-	int index;
-	char string[ETH_GSTRING_LEN];
-} mib_names[TOTAL_SWITCH_COUNTER_NUM] = {
-	{ 0x00, "rx_hi" },
-	{ 0x01, "rx_undersize" },
-	{ 0x02, "rx_fragments" },
-	{ 0x03, "rx_oversize" },
-	{ 0x04, "rx_jabbers" },
-	{ 0x05, "rx_symbol_err" },
-	{ 0x06, "rx_crc_err" },
-	{ 0x07, "rx_align_err" },
-	{ 0x08, "rx_mac_ctrl" },
-	{ 0x09, "rx_pause" },
-	{ 0x0A, "rx_bcast" },
-	{ 0x0B, "rx_mcast" },
-	{ 0x0C, "rx_ucast" },
-	{ 0x0D, "rx_64_or_less" },
-	{ 0x0E, "rx_65_127" },
-	{ 0x0F, "rx_128_255" },
-	{ 0x10, "rx_256_511" },
-	{ 0x11, "rx_512_1023" },
-	{ 0x12, "rx_1024_1522" },
-	{ 0x13, "rx_1523_2000" },
-	{ 0x14, "rx_2001" },
-	{ 0x15, "tx_hi" },
-	{ 0x16, "tx_late_col" },
-	{ 0x17, "tx_pause" },
-	{ 0x18, "tx_bcast" },
-	{ 0x19, "tx_mcast" },
-	{ 0x1A, "tx_ucast" },
-	{ 0x1B, "tx_deferred" },
-	{ 0x1C, "tx_total_col" },
-	{ 0x1D, "tx_exc_col" },
-	{ 0x1E, "tx_single_col" },
-	{ 0x1F, "tx_mult_col" },
-	{ 0x80, "rx_total" },
-	{ 0x81, "tx_total" },
-	{ 0x82, "rx_discards" },
-	{ 0x83, "tx_discards" },
-};
-
-static void ksz_cfg(struct ksz_device *dev, u32 addr, u8 bits, bool set)
-{
-	u8 data;
-
-	ksz_read8(dev, addr, &data);
-	if (set)
-		data |= bits;
-	else
-		data &= ~bits;
-	ksz_write8(dev, addr, data);
-}
-
-static void ksz_cfg32(struct ksz_device *dev, u32 addr, u32 bits, bool set)
-{
-	u32 data;
-
-	ksz_read32(dev, addr, &data);
-	if (set)
-		data |= bits;
-	else
-		data &= ~bits;
-	ksz_write32(dev, addr, data);
-}
-
-static void ksz_port_cfg(struct ksz_device *dev, int port, int offset, u8 bits,
-			 bool set)
-{
-	u32 addr;
-	u8 data;
-
-	addr = PORT_CTRL_ADDR(port, offset);
-	ksz_read8(dev, addr, &data);
-
-	if (set)
-		data |= bits;
-	else
-		data &= ~bits;
-
-	ksz_write8(dev, addr, data);
-}
-
-static void ksz_port_cfg32(struct ksz_device *dev, int port, int offset,
-			   u32 bits, bool set)
-{
-	u32 addr;
-	u32 data;
-
-	addr = PORT_CTRL_ADDR(port, offset);
-	ksz_read32(dev, addr, &data);
-
-	if (set)
-		data |= bits;
-	else
-		data &= ~bits;
-
-	ksz_write32(dev, addr, data);
-}
-
-static int wait_vlan_ctrl_ready(struct ksz_device *dev, u32 waiton, int timeout)
-{
-	u8 data;
-
-	do {
-		ksz_read8(dev, REG_SW_VLAN_CTRL, &data);
-		if (!(data & waiton))
-			break;
-		usleep_range(1, 10);
-	} while (timeout-- > 0);
-
-	if (timeout <= 0)
-		return -ETIMEDOUT;
-
-	return 0;
-}
-
-static int get_vlan_table(struct dsa_switch *ds, u16 vid, u32 *vlan_table)
-{
-	struct ksz_device *dev = ds->priv;
-	int ret;
-
-	mutex_lock(&dev->vlan_mutex);
-
-	ksz_write16(dev, REG_SW_VLAN_ENTRY_INDEX__2, vid & VLAN_INDEX_M);
-	ksz_write8(dev, REG_SW_VLAN_CTRL, VLAN_READ | VLAN_START);
-
-	/* wait to be cleared */
-	ret = wait_vlan_ctrl_ready(dev, VLAN_START, 1000);
-	if (ret < 0) {
-		dev_dbg(dev->dev, "Failed to read vlan table\n");
-		goto exit;
-	}
-
-	ksz_read32(dev, REG_SW_VLAN_ENTRY__4, &vlan_table[0]);
-	ksz_read32(dev, REG_SW_VLAN_ENTRY_UNTAG__4, &vlan_table[1]);
-	ksz_read32(dev, REG_SW_VLAN_ENTRY_PORTS__4, &vlan_table[2]);
-
-	ksz_write8(dev, REG_SW_VLAN_CTRL, 0);
-
-exit:
-	mutex_unlock(&dev->vlan_mutex);
-
-	return ret;
-}
-
-static int set_vlan_table(struct dsa_switch *ds, u16 vid, u32 *vlan_table)
-{
-	struct ksz_device *dev = ds->priv;
-	int ret;
-
-	mutex_lock(&dev->vlan_mutex);
-
-	ksz_write32(dev, REG_SW_VLAN_ENTRY__4, vlan_table[0]);
-	ksz_write32(dev, REG_SW_VLAN_ENTRY_UNTAG__4, vlan_table[1]);
-	ksz_write32(dev, REG_SW_VLAN_ENTRY_PORTS__4, vlan_table[2]);
-
-	ksz_write16(dev, REG_SW_VLAN_ENTRY_INDEX__2, vid & VLAN_INDEX_M);
-	ksz_write8(dev, REG_SW_VLAN_CTRL, VLAN_START | VLAN_WRITE);
-
-	/* wait to be cleared */
-	ret = wait_vlan_ctrl_ready(dev, VLAN_START, 1000);
-	if (ret < 0) {
-		dev_dbg(dev->dev, "Failed to write vlan table\n");
-		goto exit;
-	}
-
-	ksz_write8(dev, REG_SW_VLAN_CTRL, 0);
-
-	/* update vlan cache table */
-	dev->vlan_cache[vid].table[0] = vlan_table[0];
-	dev->vlan_cache[vid].table[1] = vlan_table[1];
-	dev->vlan_cache[vid].table[2] = vlan_table[2];
-
-exit:
-	mutex_unlock(&dev->vlan_mutex);
-
-	return ret;
-}
-
-static void read_table(struct dsa_switch *ds, u32 *table)
-{
-	struct ksz_device *dev = ds->priv;
-
-	ksz_read32(dev, REG_SW_ALU_VAL_A, &table[0]);
-	ksz_read32(dev, REG_SW_ALU_VAL_B, &table[1]);
-	ksz_read32(dev, REG_SW_ALU_VAL_C, &table[2]);
-	ksz_read32(dev, REG_SW_ALU_VAL_D, &table[3]);
-}
-
-static void write_table(struct dsa_switch *ds, u32 *table)
-{
-	struct ksz_device *dev = ds->priv;
-
-	ksz_write32(dev, REG_SW_ALU_VAL_A, table[0]);
-	ksz_write32(dev, REG_SW_ALU_VAL_B, table[1]);
-	ksz_write32(dev, REG_SW_ALU_VAL_C, table[2]);
-	ksz_write32(dev, REG_SW_ALU_VAL_D, table[3]);
-}
-
-static int wait_alu_ready(struct ksz_device *dev, u32 waiton, int timeout)
-{
-	u32 data;
-
-	do {
-		ksz_read32(dev, REG_SW_ALU_CTRL__4, &data);
-		if (!(data & waiton))
-			break;
-		usleep_range(1, 10);
-	} while (timeout-- > 0);
-
-	if (timeout <= 0)
-		return -ETIMEDOUT;
-
-	return 0;
-}
-
-static int wait_alu_sta_ready(struct ksz_device *dev, u32 waiton, int timeout)
+void ksz_update_port_member(struct ksz_device *dev, int port)
 {
-	u32 data;
-
-	do {
-		ksz_read32(dev, REG_SW_ALU_STAT_CTRL__4, &data);
-		if (!(data & waiton))
-			break;
-		usleep_range(1, 10);
-	} while (timeout-- > 0);
-
-	if (timeout <= 0)
-		return -ETIMEDOUT;
-
-	return 0;
-}
-
-static int ksz9477_reset_switch(struct ksz_device *dev)
-{
-	u8 data8;
-	u16 data16;
-	u32 data32;
-
-	/* reset switch */
-	ksz_cfg(dev, REG_SW_OPERATION, SW_RESET, true);
-
-	/* turn off SPI DO Edge select */
-	ksz_read8(dev, REG_SW_GLOBAL_SERIAL_CTRL_0, &data8);
-	data8 &= ~SPI_AUTO_EDGE_DETECTION;
-	ksz_write8(dev, REG_SW_GLOBAL_SERIAL_CTRL_0, data8);
-
-	/* default configuration */
-	ksz_read8(dev, REG_SW_LUE_CTRL_1, &data8);
-	data8 = SW_AGING_ENABLE | SW_LINK_AUTO_AGING |
-	      SW_SRC_ADDR_FILTER | SW_FLUSH_STP_TABLE | SW_FLUSH_MSTP_TABLE;
-	ksz_write8(dev, REG_SW_LUE_CTRL_1, data8);
-
-	/* disable interrupts */
-	ksz_write32(dev, REG_SW_INT_MASK__4, SWITCH_INT_MASK);
-	ksz_write32(dev, REG_SW_PORT_INT_MASK__4, 0x7F);
-	ksz_read32(dev, REG_SW_PORT_INT_STATUS__4, &data32);
-
-	/* set broadcast storm protection 10% rate */
-	ksz_read16(dev, REG_SW_MAC_CTRL_2, &data16);
-	data16 &= ~BROADCAST_STORM_RATE;
-	data16 |= (BROADCAST_STORM_VALUE * BROADCAST_STORM_PROT_RATE) / 100;
-	ksz_write16(dev, REG_SW_MAC_CTRL_2, data16);
-
-	return 0;
-}
-
-static void ksz9477_port_setup(struct ksz_device *dev, int port, bool cpu_port)
-{
-	u8 data8;
-	u16 data16;
-
-	/* enable tag tail for host port */
-	if (cpu_port)
-		ksz_port_cfg(dev, port, REG_PORT_CTRL_0, PORT_TAIL_TAG_ENABLE,
-			     true);
-
-	ksz_port_cfg(dev, port, REG_PORT_CTRL_0, PORT_MAC_LOOPBACK, false);
-
-	/* set back pressure */
-	ksz_port_cfg(dev, port, REG_PORT_MAC_CTRL_1, PORT_BACK_PRESSURE, true);
-
-	/* set flow control */
-	ksz_port_cfg(dev, port, REG_PORT_CTRL_0,
-		     PORT_FORCE_TX_FLOW_CTRL | PORT_FORCE_RX_FLOW_CTRL, true);
-
-	/* enable broadcast storm limit */
-	ksz_port_cfg(dev, port, P_BCAST_STORM_CTRL, PORT_BROADCAST_STORM, true);
-
-	/* disable DiffServ priority */
-	ksz_port_cfg(dev, port, P_PRIO_CTRL, PORT_DIFFSERV_PRIO_ENABLE, false);
-
-	/* replace priority */
-	ksz_port_cfg(dev, port, REG_PORT_MRI_MAC_CTRL, PORT_USER_PRIO_CEILING,
-		     false);
-	ksz_port_cfg32(dev, port, REG_PORT_MTI_QUEUE_CTRL_0__4,
-		       MTI_PVID_REPLACE, false);
-
-	/* enable 802.1p priority */
-	ksz_port_cfg(dev, port, P_PRIO_CTRL, PORT_802_1P_PRIO_ENABLE, true);
-
-	/* configure MAC to 1G & RGMII mode */
-	ksz_pread8(dev, port, REG_PORT_XMII_CTRL_1, &data8);
-	data8 |= PORT_RGMII_ID_EG_ENABLE;
-	data8 &= ~PORT_MII_NOT_1GBIT;
-	data8 &= ~PORT_MII_SEL_M;
-	data8 |= PORT_RGMII_SEL;
-	ksz_pwrite8(dev, port, REG_PORT_XMII_CTRL_1, data8);
-
-	/* clear pending interrupts */
-	ksz_pread16(dev, port, REG_PORT_PHY_INT_ENABLE, &data16);
-}
-
-static void ksz9477_config_cpu_port(struct dsa_switch *ds)
-{
-	struct ksz_device *dev = ds->priv;
+	struct ksz_port *p;
 	int i;
 
-	ds->num_ports = dev->port_cnt;
-
-	for (i = 0; i < ds->num_ports; i++) {
-		if (dsa_is_cpu_port(ds, i) && (dev->cpu_ports & (1 << i))) {
-			dev->cpu_port = i;
+	for (i = 0; i < dev->port_cnt; i++) {
+		if (i == port || i == dev->cpu_port)
+			continue;
+		p = &dev->ports[i];
+		if (!(dev->member & (1 << i)))
+			continue;
 
-			/* enable cpu port */
-			ksz9477_port_setup(dev, i, true);
-		}
+		/* Port is a member of the bridge and is forwarding. */
+		if (p->stp_state == BR_STATE_FORWARDING)
+			dev->dev_ops->cfg_port_member(dev, i, dev->member);
 	}
 }
 
-static int ksz9477_setup(struct dsa_switch *ds)
+int ksz_phy_read16(struct dsa_switch *ds, int addr, int reg)
 {
 	struct ksz_device *dev = ds->priv;
-	int ret = 0;
-
-	dev->vlan_cache = devm_kcalloc(dev->dev, sizeof(struct vlan_table),
-				       dev->num_vlans, GFP_KERNEL);
-	if (!dev->vlan_cache)
-		return -ENOMEM;
-
-	ret = ksz9477_reset_switch(dev);
-	if (ret) {
-		dev_err(ds->dev, "failed to reset switch\n");
-		return ret;
-	}
-
-	/* accept packet up to 2000bytes */
-	ksz_cfg(dev, REG_SW_MAC_CTRL_1, SW_LEGAL_PACKET_DISABLE, true);
-
-	ksz9477_config_cpu_port(ds);
-
-	ksz_cfg(dev, REG_SW_MAC_CTRL_1, MULTICAST_STORM_DISABLE, true);
-
-	/* queue based egress rate limit */
-	ksz_cfg(dev, REG_SW_MAC_CTRL_5, SW_OUT_RATE_LIMIT_QUEUE_BASED, true);
+	u16 val = 0xffff;
 
-	/* start switch */
-	ksz_cfg(dev, REG_SW_OPERATION, SW_START, true);
-
-	return 0;
-}
-
-static enum dsa_tag_protocol ksz9477_get_tag_protocol(struct dsa_switch *ds)
-{
-	return DSA_TAG_PROTO_KSZ;
-}
-
-static int ksz9477_phy_read16(struct dsa_switch *ds, int addr, int reg)
-{
-	struct ksz_device *dev = ds->priv;
-	u16 val = 0;
-
-	ksz_pread16(dev, addr, 0x100 + (reg << 1), &val);
+	dev->dev_ops->r_phy(dev, addr, reg, &val);
 
 	return val;
 }
 
-static int ksz9477_phy_write16(struct dsa_switch *ds, int addr, int reg,
-			       u16 val)
+int ksz_phy_write16(struct dsa_switch *ds, int addr, int reg, u16 val)
 {
 	struct ksz_device *dev = ds->priv;
 
-	ksz_pwrite16(dev, addr, 0x100 + (reg << 1), val);
+	dev->dev_ops->w_phy(dev, addr, reg, val);
 
 	return 0;
 }
 
-static int ksz_enable_port(struct dsa_switch *ds, int port,
-			   struct phy_device *phy)
+int ksz_sset_count(struct dsa_switch *ds)
 {
 	struct ksz_device *dev = ds->priv;
 
-	/* setup slave port */
-	ksz9477_port_setup(dev, port, false);
-
-	return 0;
-}
-
-static void ksz_disable_port(struct dsa_switch *ds, int port,
-			     struct phy_device *phy)
-{
-	struct ksz_device *dev = ds->priv;
-
-	/* there is no port disable */
-	ksz_port_cfg(dev, port, REG_PORT_CTRL_0, PORT_MAC_LOOPBACK, true);
-}
-
-static int ksz_sset_count(struct dsa_switch *ds)
-{
-	return TOTAL_SWITCH_COUNTER_NUM;
-}
-
-static void ksz9477_get_strings(struct dsa_switch *ds, int port, uint8_t *buf)
-{
-	int i;
-
-	for (i = 0; i < TOTAL_SWITCH_COUNTER_NUM; i++) {
-		memcpy(buf + i * ETH_GSTRING_LEN, mib_names[i].string,
-		       ETH_GSTRING_LEN);
-	}
+	return dev->mib_cnt;
 }
 
-static void ksz_get_ethtool_stats(struct dsa_switch *ds, int port,
-				  uint64_t *buf)
+int ksz_port_bridge_join(struct dsa_switch *ds, int port,
+			 struct net_device *br)
 {
 	struct ksz_device *dev = ds->priv;
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
 
-		/* failed to read MIB. get out of loop */
-		if (!timeout) {
-			dev_dbg(dev->dev, "Failed to get MIB\n");
-			break;
-		}
-
-		/* count resets upon read */
-		ksz_pread32(dev, port, REG_PORT_MIB_DATA, &data);
+	dev->br_member |= (1 << port);
 
-		dev->mib_value[i] += (uint64_t)data;
-		buf[i] = dev->mib_value[i];
-	}
-
-	mutex_unlock(&dev->stats_mutex);
-}
-
-static void ksz9477_port_stp_state_set(struct dsa_switch *ds, int port,
-				       u8 state)
-{
-	struct ksz_device *dev = ds->priv;
-	u8 data;
-
-	ksz_pread8(dev, port, P_STP_CTRL, &data);
-	data &= ~(PORT_TX_ENABLE | PORT_RX_ENABLE | PORT_LEARN_DISABLE);
-
-	switch (state) {
-	case BR_STATE_DISABLED:
-		data |= PORT_LEARN_DISABLE;
-		break;
-	case BR_STATE_LISTENING:
-		data |= (PORT_RX_ENABLE | PORT_LEARN_DISABLE);
-		break;
-	case BR_STATE_LEARNING:
-		data |= PORT_RX_ENABLE;
-		break;
-	case BR_STATE_FORWARDING:
-		data |= (PORT_TX_ENABLE | PORT_RX_ENABLE);
-		break;
-	case BR_STATE_BLOCKING:
-		data |= PORT_LEARN_DISABLE;
-		break;
-	default:
-		dev_err(ds->dev, "invalid STP state: %d\n", state);
-		return;
-	}
+	/* port_stp_state_set() will be called after to put the port in
+	 * appropriate state so there is no need to do anything.
+	 */
 
-	ksz_pwrite8(dev, port, P_STP_CTRL, data);
+	return 0;
 }
 
-static void ksz_port_fast_age(struct dsa_switch *ds, int port)
+void ksz_port_bridge_leave(struct dsa_switch *ds, int port,
+			   struct net_device *br)
 {
 	struct ksz_device *dev = ds->priv;
-	u8 data8;
 
-	ksz_read8(dev, REG_SW_LUE_CTRL_1, &data8);
-	data8 |= SW_FAST_AGING;
-	ksz_write8(dev, REG_SW_LUE_CTRL_1, data8);
+	dev->br_member &= ~(1 << port);
+	dev->member &= ~(1 << port);
 
-	data8 &= ~SW_FAST_AGING;
-	ksz_write8(dev, REG_SW_LUE_CTRL_1, data8);
+	/* port_stp_state_set() will be called after to put the port in
+	 * forwarding state so there is no need to do anything.
+	 */
 }
 
-static int ksz9477_port_vlan_filtering(struct dsa_switch *ds, int port,
-				       bool flag)
+void ksz_port_fast_age(struct dsa_switch *ds, int port)
 {
 	struct ksz_device *dev = ds->priv;
 
-	if (flag) {
-		ksz_port_cfg(dev, port, REG_PORT_LUE_CTRL,
-			     PORT_VLAN_LOOKUP_VID_0, true);
-		ksz_cfg32(dev, REG_SW_QM_CTRL__4, UNICAST_VLAN_BOUNDARY, true);
-		ksz_cfg(dev, REG_SW_LUE_CTRL_0, SW_VLAN_ENABLE, true);
-	} else {
-		ksz_cfg(dev, REG_SW_LUE_CTRL_0, SW_VLAN_ENABLE, false);
-		ksz_cfg32(dev, REG_SW_QM_CTRL__4, UNICAST_VLAN_BOUNDARY, false);
-		ksz_port_cfg(dev, port, REG_PORT_LUE_CTRL,
-			     PORT_VLAN_LOOKUP_VID_0, false);
-	}
-
-	return 0;
+	dev->dev_ops->flush_dyn_mac_table(dev, port);
 }
 
-static int ksz_port_vlan_prepare(struct dsa_switch *ds, int port,
-				 const struct switchdev_obj_port_vlan *vlan,
-				 struct switchdev_trans *trans)
+int ksz_port_vlan_prepare(struct dsa_switch *ds, int port,
+			  const struct switchdev_obj_port_vlan *vlan,
+			  struct switchdev_trans *trans)
 {
 	/* nothing needed */
 
 	return 0;
 }
 
-static void ksz9477_port_vlan_add(struct dsa_switch *ds, int port,
-				  const struct switchdev_obj_port_vlan *vlan,
-				  struct switchdev_trans *trans)
-{
-	struct ksz_device *dev = ds->priv;
-	u32 vlan_table[3];
-	u16 vid;
-	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
-
-	for (vid = vlan->vid_begin; vid <= vlan->vid_end; vid++) {
-		if (get_vlan_table(ds, vid, vlan_table)) {
-			dev_dbg(dev->dev, "Failed to get vlan table\n");
-			return;
-		}
-
-		vlan_table[0] = VLAN_VALID | (vid & VLAN_FID_M);
-		if (untagged)
-			vlan_table[1] |= BIT(port);
-		else
-			vlan_table[1] &= ~BIT(port);
-		vlan_table[1] &= ~(BIT(dev->cpu_port));
-
-		vlan_table[2] |= BIT(port) | BIT(dev->cpu_port);
-
-		if (set_vlan_table(ds, vid, vlan_table)) {
-			dev_dbg(dev->dev, "Failed to set vlan table\n");
-			return;
-		}
-
-		/* change PVID */
-		if (vlan->flags & BRIDGE_VLAN_INFO_PVID)
-			ksz_pwrite16(dev, port, REG_PORT_DEFAULT_VID, vid);
-	}
-}
-
-static int ksz9477_port_vlan_del(struct dsa_switch *ds, int port,
-				 const struct switchdev_obj_port_vlan *vlan)
-{
-	struct ksz_device *dev = ds->priv;
-	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
-	u32 vlan_table[3];
-	u16 vid;
-	u16 pvid;
-
-	ksz_pread16(dev, port, REG_PORT_DEFAULT_VID, &pvid);
-	pvid = pvid & 0xFFF;
-
-	for (vid = vlan->vid_begin; vid <= vlan->vid_end; vid++) {
-		if (get_vlan_table(ds, vid, vlan_table)) {
-			dev_dbg(dev->dev, "Failed to get vlan table\n");
-			return -ETIMEDOUT;
-		}
-
-		vlan_table[2] &= ~BIT(port);
-
-		if (pvid == vid)
-			pvid = 1;
-
-		if (untagged)
-			vlan_table[1] &= ~BIT(port);
-
-		if (set_vlan_table(ds, vid, vlan_table)) {
-			dev_dbg(dev->dev, "Failed to set vlan table\n");
-			return -ETIMEDOUT;
-		}
-	}
-
-	ksz_pwrite16(dev, port, REG_PORT_DEFAULT_VID, pvid);
-
-	return 0;
-}
-
-struct alu_struct {
-	/* entry 1 */
-	u8	is_static:1;
-	u8	is_src_filter:1;
-	u8	is_dst_filter:1;
-	u8	prio_age:3;
-	u32	_reserv_0_1:23;
-	u8	mstp:3;
-	/* entry 2 */
-	u8	is_override:1;
-	u8	is_use_fid:1;
-	u32	_reserv_1_1:23;
-	u8	port_forward:7;
-	/* entry 3 & 4*/
-	u32	_reserv_2_1:9;
-	u8	fid:7;
-	u8	mac[ETH_ALEN];
-};
-
-static int ksz9477_port_fdb_add(struct dsa_switch *ds, int port,
-				const unsigned char *addr, u16 vid)
-{
-	struct ksz_device *dev = ds->priv;
-	u32 alu_table[4];
-	u32 data;
-	int ret = 0;
-
-	mutex_lock(&dev->alu_mutex);
-
-	/* find any entry with mac & vid */
-	data = vid << ALU_FID_INDEX_S;
-	data |= ((addr[0] << 8) | addr[1]);
-	ksz_write32(dev, REG_SW_ALU_INDEX_0, data);
-
-	data = ((addr[2] << 24) | (addr[3] << 16));
-	data |= ((addr[4] << 8) | addr[5]);
-	ksz_write32(dev, REG_SW_ALU_INDEX_1, data);
-
-	/* start read operation */
-	ksz_write32(dev, REG_SW_ALU_CTRL__4, ALU_READ | ALU_START);
-
-	/* wait to be finished */
-	ret = wait_alu_ready(dev, ALU_START, 1000);
-	if (ret < 0) {
-		dev_dbg(dev->dev, "Failed to read ALU\n");
-		goto exit;
-	}
-
-	/* read ALU entry */
-	read_table(ds, alu_table);
-
-	/* update ALU entry */
-	alu_table[0] = ALU_V_STATIC_VALID;
-	alu_table[1] |= BIT(port);
-	if (vid)
-		alu_table[1] |= ALU_V_USE_FID;
-	alu_table[2] = (vid << ALU_V_FID_S);
-	alu_table[2] |= ((addr[0] << 8) | addr[1]);
-	alu_table[3] = ((addr[2] << 24) | (addr[3] << 16));
-	alu_table[3] |= ((addr[4] << 8) | addr[5]);
-
-	write_table(ds, alu_table);
-
-	ksz_write32(dev, REG_SW_ALU_CTRL__4, ALU_WRITE | ALU_START);
-
-	/* wait to be finished */
-	ret = wait_alu_ready(dev, ALU_START, 1000);
-	if (ret < 0)
-		dev_dbg(dev->dev, "Failed to write ALU\n");
-
-exit:
-	mutex_unlock(&dev->alu_mutex);
-
-	return ret;
-}
-
-static int ksz9477_port_fdb_del(struct dsa_switch *ds, int port,
-				const unsigned char *addr, u16 vid)
-{
-	struct ksz_device *dev = ds->priv;
-	u32 alu_table[4];
-	u32 data;
-	int ret = 0;
-
-	mutex_lock(&dev->alu_mutex);
-
-	/* read any entry with mac & vid */
-	data = vid << ALU_FID_INDEX_S;
-	data |= ((addr[0] << 8) | addr[1]);
-	ksz_write32(dev, REG_SW_ALU_INDEX_0, data);
-
-	data = ((addr[2] << 24) | (addr[3] << 16));
-	data |= ((addr[4] << 8) | addr[5]);
-	ksz_write32(dev, REG_SW_ALU_INDEX_1, data);
-
-	/* start read operation */
-	ksz_write32(dev, REG_SW_ALU_CTRL__4, ALU_READ | ALU_START);
-
-	/* wait to be finished */
-	ret = wait_alu_ready(dev, ALU_START, 1000);
-	if (ret < 0) {
-		dev_dbg(dev->dev, "Failed to read ALU\n");
-		goto exit;
-	}
-
-	ksz_read32(dev, REG_SW_ALU_VAL_A, &alu_table[0]);
-	if (alu_table[0] & ALU_V_STATIC_VALID) {
-		ksz_read32(dev, REG_SW_ALU_VAL_B, &alu_table[1]);
-		ksz_read32(dev, REG_SW_ALU_VAL_C, &alu_table[2]);
-		ksz_read32(dev, REG_SW_ALU_VAL_D, &alu_table[3]);
-
-		/* clear forwarding port */
-		alu_table[2] &= ~BIT(port);
-
-		/* if there is no port to forward, clear table */
-		if ((alu_table[2] & ALU_V_PORT_MAP) == 0) {
-			alu_table[0] = 0;
-			alu_table[1] = 0;
-			alu_table[2] = 0;
-			alu_table[3] = 0;
-		}
-	} else {
-		alu_table[0] = 0;
-		alu_table[1] = 0;
-		alu_table[2] = 0;
-		alu_table[3] = 0;
-	}
-
-	write_table(ds, alu_table);
-
-	ksz_write32(dev, REG_SW_ALU_CTRL__4, ALU_WRITE | ALU_START);
-
-	/* wait to be finished */
-	ret = wait_alu_ready(dev, ALU_START, 1000);
-	if (ret < 0)
-		dev_dbg(dev->dev, "Failed to write ALU\n");
-
-exit:
-	mutex_unlock(&dev->alu_mutex);
-
-	return ret;
-}
-
-static void convert_alu(struct alu_struct *alu, u32 *alu_table)
-{
-	alu->is_static = !!(alu_table[0] & ALU_V_STATIC_VALID);
-	alu->is_src_filter = !!(alu_table[0] & ALU_V_SRC_FILTER);
-	alu->is_dst_filter = !!(alu_table[0] & ALU_V_DST_FILTER);
-	alu->prio_age = (alu_table[0] >> ALU_V_PRIO_AGE_CNT_S) &
-			ALU_V_PRIO_AGE_CNT_M;
-	alu->mstp = alu_table[0] & ALU_V_MSTP_M;
-
-	alu->is_override = !!(alu_table[1] & ALU_V_OVERRIDE);
-	alu->is_use_fid = !!(alu_table[1] & ALU_V_USE_FID);
-	alu->port_forward = alu_table[1] & ALU_V_PORT_MAP;
-
-	alu->fid = (alu_table[2] >> ALU_V_FID_S) & ALU_V_FID_M;
-
-	alu->mac[0] = (alu_table[2] >> 8) & 0xFF;
-	alu->mac[1] = alu_table[2] & 0xFF;
-	alu->mac[2] = (alu_table[3] >> 24) & 0xFF;
-	alu->mac[3] = (alu_table[3] >> 16) & 0xFF;
-	alu->mac[4] = (alu_table[3] >> 8) & 0xFF;
-	alu->mac[5] = alu_table[3] & 0xFF;
-}
-
-static int ksz9477_port_fdb_dump(struct dsa_switch *ds, int port,
-				 dsa_fdb_dump_cb_t *cb, void *data)
+int ksz_port_fdb_dump(struct dsa_switch *ds, int port, dsa_fdb_dump_cb_t *cb,
+		      void *data)
 {
 	struct ksz_device *dev = ds->priv;
 	int ret = 0;
-	u32 ksz_data;
-	u32 alu_table[4];
+	u16 i = 0;
+	u16 entries = 0;
+	u8 timestamp = 0;
+	u8 fid;
+	u8 member;
 	struct alu_struct alu;
-	int timeout;
 
 	mutex_lock(&dev->alu_mutex);
-
-	/* start ALU search */
-	ksz_write32(dev, REG_SW_ALU_CTRL__4, ALU_START | ALU_SEARCH);
-
 	do {
-		timeout = 1000;
-		do {
-			ksz_read32(dev, REG_SW_ALU_CTRL__4, &ksz_data);
-			if ((ksz_data & ALU_VALID) || !(ksz_data & ALU_START))
-				break;
-			usleep_range(1, 10);
-		} while (timeout-- > 0);
-
-		if (!timeout) {
-			dev_dbg(dev->dev, "Failed to search ALU\n");
-			ret = -ETIMEDOUT;
-			goto exit;
-		}
-
-		/* read ALU table */
-		read_table(ds, alu_table);
-
-		convert_alu(&alu, alu_table);
-
-		if (alu.port_forward & BIT(port)) {
+		alu.is_static = false;
+		ret = dev->dev_ops->r_dyn_mac_table(dev, i, alu.mac, &fid,
+						    &member, &timestamp,
+						    &entries);
+		if (!ret && (member & BIT(port))) {
 			ret = cb(alu.mac, alu.fid, alu.is_static, data);
 			if (ret)
-				goto exit;
+				break;
 		}
-	} while (ksz_data & ALU_START);
-
-exit:
-
-	/* stop ALU search */
-	ksz_write32(dev, REG_SW_ALU_CTRL__4, 0);
-
+		i++;
+	} while (i < entries);
 	mutex_unlock(&dev->alu_mutex);
+	if (i >= entries)
+		ret = 0;
 
 	return ret;
 }
 
-static int ksz_port_mdb_prepare(struct dsa_switch *ds, int port,
-				const struct switchdev_obj_port_mdb *mdb,
-				struct switchdev_trans *trans)
+int ksz_port_mdb_prepare(struct dsa_switch *ds, int port,
+			 const struct switchdev_obj_port_mdb *mdb,
+			 struct switchdev_trans *trans)
 {
 	/* nothing to do */
 	return 0;
 }
 
-static void ksz9477_port_mdb_add(struct dsa_switch *ds, int port,
-				 const struct switchdev_obj_port_mdb *mdb,
-				 struct switchdev_trans *trans)
+void ksz_port_mdb_add(struct dsa_switch *ds, int port,
+		      const struct switchdev_obj_port_mdb *mdb,
+		      struct switchdev_trans *trans)
 {
 	struct ksz_device *dev = ds->priv;
-	u32 static_table[4];
-	u32 data;
+	struct alu_struct alu;
 	int index;
-	u32 mac_hi, mac_lo;
-
-	mac_hi = ((mdb->addr[0] << 8) | mdb->addr[1]);
-	mac_lo = ((mdb->addr[2] << 24) | (mdb->addr[3] << 16));
-	mac_lo |= ((mdb->addr[4] << 8) | mdb->addr[5]);
+	int empty = 0;
 
 	mutex_lock(&dev->alu_mutex);
 
 	for (index = 0; index < dev->num_statics; index++) {
-		/* find empty slot first */
-		data = (index << ALU_STAT_INDEX_S) |
-			ALU_STAT_READ | ALU_STAT_START;
-		ksz_write32(dev, REG_SW_ALU_STAT_CTRL__4, data);
-
-		/* wait to be finished */
-		if (wait_alu_sta_ready(dev, ALU_STAT_START, 1000) < 0) {
-			dev_dbg(dev->dev, "Failed to read ALU STATIC\n");
-			goto exit;
-		}
-
-		/* read ALU static table */
-		read_table(ds, static_table);
-
-		if (static_table[0] & ALU_V_STATIC_VALID) {
-			/* check this has same vid & mac address */
-			if (((static_table[2] >> ALU_V_FID_S) == mdb->vid) &&
-			    ((static_table[2] & ALU_V_MAC_ADDR_HI) == mac_hi) &&
-			    static_table[3] == mac_lo) {
-				/* found matching one */
+		if (!dev->dev_ops->r_sta_mac_table(dev, index, &alu)) {
+			/* Found one already in static MAC table. */
+			if (!memcmp(alu.mac, mdb->addr, ETH_ALEN) &&
+			    alu.fid == mdb->vid)
 				break;
-			}
-		} else {
-			/* found empty one */
-			break;
+		/* Remember the first empty entry. */
+		} else if (!empty) {
+			empty = index + 1;
 		}
 	}
 
 	/* no available entry */
-	if (index == dev->num_statics)
+	if (index == dev->num_statics && !empty)
 		goto exit;
 
 	/* add entry */
-	static_table[0] = ALU_V_STATIC_VALID;
-	static_table[1] |= BIT(port);
-	if (mdb->vid)
-		static_table[1] |= ALU_V_USE_FID;
-	static_table[2] = (mdb->vid << ALU_V_FID_S);
-	static_table[2] |= mac_hi;
-	static_table[3] = mac_lo;
-
-	write_table(ds, static_table);
-
-	data = (index << ALU_STAT_INDEX_S) | ALU_STAT_START;
-	ksz_write32(dev, REG_SW_ALU_STAT_CTRL__4, data);
+	if (index == dev->num_statics) {
+		index = empty - 1;
+		memset(&alu, 0, sizeof(alu));
+		memcpy(alu.mac, mdb->addr, ETH_ALEN);
+		alu.is_static = true;
+	}
+	alu.port_forward |= BIT(port);
+	if (mdb->vid) {
+		alu.is_use_fid = true;
 
-	/* wait to be finished */
-	if (wait_alu_sta_ready(dev, ALU_STAT_START, 1000) < 0)
-		dev_dbg(dev->dev, "Failed to read ALU STATIC\n");
+		/* Need a way to map VID to FID. */
+		alu.fid = mdb->vid;
+	}
+	dev->dev_ops->w_sta_mac_table(dev, index, &alu);
 
 exit:
 	mutex_unlock(&dev->alu_mutex);
 }
 
-static int ksz9477_port_mdb_del(struct dsa_switch *ds, int port,
-				const struct switchdev_obj_port_mdb *mdb)
+int ksz_port_mdb_del(struct dsa_switch *ds, int port,
+		     const struct switchdev_obj_port_mdb *mdb)
 {
 	struct ksz_device *dev = ds->priv;
-	u32 static_table[4];
-	u32 data;
+	struct alu_struct alu;
 	int index;
 	int ret = 0;
-	u32 mac_hi, mac_lo;
-
-	mac_hi = ((mdb->addr[0] << 8) | mdb->addr[1]);
-	mac_lo = ((mdb->addr[2] << 24) | (mdb->addr[3] << 16));
-	mac_lo |= ((mdb->addr[4] << 8) | mdb->addr[5]);
 
 	mutex_lock(&dev->alu_mutex);
 
 	for (index = 0; index < dev->num_statics; index++) {
-		/* find empty slot first */
-		data = (index << ALU_STAT_INDEX_S) |
-			ALU_STAT_READ | ALU_STAT_START;
-		ksz_write32(dev, REG_SW_ALU_STAT_CTRL__4, data);
-
-		/* wait to be finished */
-		ret = wait_alu_sta_ready(dev, ALU_STAT_START, 1000);
-		if (ret < 0) {
-			dev_dbg(dev->dev, "Failed to read ALU STATIC\n");
-			goto exit;
-		}
-
-		/* read ALU static table */
-		read_table(ds, static_table);
-
-		if (static_table[0] & ALU_V_STATIC_VALID) {
-			/* check this has same vid & mac address */
-
-			if (((static_table[2] >> ALU_V_FID_S) == mdb->vid) &&
-			    ((static_table[2] & ALU_V_MAC_ADDR_HI) == mac_hi) &&
-			    static_table[3] == mac_lo) {
-				/* found matching one */
+		if (!dev->dev_ops->r_sta_mac_table(dev, index, &alu)) {
+			/* Found one already in static MAC table. */
+			if (!memcmp(alu.mac, mdb->addr, ETH_ALEN) &&
+			    alu.fid == mdb->vid)
 				break;
-			}
 		}
 	}
 
@@ -989,25 +232,10 @@ static int ksz9477_port_mdb_del(struct dsa_switch *ds, int port,
 	}
 
 	/* clear port */
-	static_table[1] &= ~BIT(port);
-
-	if ((static_table[1] & ALU_V_PORT_MAP) == 0) {
-		/* delete entry */
-		static_table[0] = 0;
-		static_table[1] = 0;
-		static_table[2] = 0;
-		static_table[3] = 0;
-	}
-
-	write_table(ds, static_table);
-
-	data = (index << ALU_STAT_INDEX_S) | ALU_STAT_START;
-	ksz_write32(dev, REG_SW_ALU_STAT_CTRL__4, data);
-
-	/* wait to be finished */
-	ret = wait_alu_sta_ready(dev, ALU_STAT_START, 1000);
-	if (ret < 0)
-		dev_dbg(dev->dev, "Failed to read ALU STATIC\n");
+	alu.port_forward &= ~BIT(port);
+	if (!alu.port_forward)
+		alu.is_static = false;
+	dev->dev_ops->w_sta_mac_table(dev, index, &alu);
 
 exit:
 	mutex_unlock(&dev->alu_mutex);
@@ -1015,125 +243,30 @@ static int ksz9477_port_mdb_del(struct dsa_switch *ds, int port,
 	return ret;
 }
 
-static int ksz9477_port_mirror_add(struct dsa_switch *ds, int port,
-				   struct dsa_mall_mirror_tc_entry *mirror,
-				   bool ingress)
+int ksz_enable_port(struct dsa_switch *ds, int port, struct phy_device *phy)
 {
 	struct ksz_device *dev = ds->priv;
 
-	if (ingress)
-		ksz_port_cfg(dev, port, P_MIRROR_CTRL, PORT_MIRROR_RX, true);
-	else
-		ksz_port_cfg(dev, port, P_MIRROR_CTRL, PORT_MIRROR_TX, true);
-
-	ksz_port_cfg(dev, port, P_MIRROR_CTRL, PORT_MIRROR_SNIFFER, false);
-
-	/* configure mirror port */
-	ksz_port_cfg(dev, mirror->to_local_port, P_MIRROR_CTRL,
-		     PORT_MIRROR_SNIFFER, true);
+	/* setup slave port */
+	dev->dev_ops->port_setup(dev, port, false);
 
-	ksz_cfg(dev, S_MIRROR_CTRL, SW_MIRROR_RX_TX, false);
+	/* port_stp_state_set() will be called after to enable the port so
+	 * there is no need to do anything.
+	 */
 
 	return 0;
 }
 
-static void ksz9477_port_mirror_del(struct dsa_switch *ds, int port,
-				    struct dsa_mall_mirror_tc_entry *mirror)
+void ksz_disable_port(struct dsa_switch *ds, int port, struct phy_device *phy)
 {
 	struct ksz_device *dev = ds->priv;
-	u8 data;
-
-	if (mirror->ingress)
-		ksz_port_cfg(dev, port, P_MIRROR_CTRL, PORT_MIRROR_RX, false);
-	else
-		ksz_port_cfg(dev, port, P_MIRROR_CTRL, PORT_MIRROR_TX, false);
 
-	ksz_pread8(dev, port, P_MIRROR_CTRL, &data);
+	dev->on_ports &= ~(1 << port);
+	dev->live_ports &= ~(1 << port);
 
-	if (!(data & (PORT_MIRROR_RX | PORT_MIRROR_TX)))
-		ksz_port_cfg(dev, mirror->to_local_port, P_MIRROR_CTRL,
-			     PORT_MIRROR_SNIFFER, false);
-}
-
-static const struct dsa_switch_ops ksz_switch_ops = {
-	.get_tag_protocol	= ksz9477_get_tag_protocol,
-	.setup			= ksz9477_setup,
-	.phy_read		= ksz9477_phy_read16,
-	.phy_write		= ksz9477_phy_write16,
-	.port_enable		= ksz_enable_port,
-	.port_disable		= ksz_disable_port,
-	.get_strings		= ksz9477_get_strings,
-	.get_ethtool_stats	= ksz_get_ethtool_stats,
-	.get_sset_count		= ksz_sset_count,
-	.port_stp_state_set	= ksz9477_port_stp_state_set,
-	.port_fast_age		= ksz_port_fast_age,
-	.port_vlan_filtering	= ksz9477_port_vlan_filtering,
-	.port_vlan_prepare	= ksz_port_vlan_prepare,
-	.port_vlan_add		= ksz9477_port_vlan_add,
-	.port_vlan_del		= ksz9477_port_vlan_del,
-	.port_fdb_dump		= ksz9477_port_fdb_dump,
-	.port_fdb_add		= ksz9477_port_fdb_add,
-	.port_fdb_del		= ksz9477_port_fdb_del,
-	.port_mdb_prepare       = ksz_port_mdb_prepare,
-	.port_mdb_add           = ksz9477_port_mdb_add,
-	.port_mdb_del           = ksz9477_port_mdb_del,
-	.port_mirror_add	= ksz9477_port_mirror_add,
-	.port_mirror_del	= ksz9477_port_mirror_del,
-};
-
-struct ksz_chip_data {
-	u32 chip_id;
-	const char *dev_name;
-	int num_vlans;
-	int num_alus;
-	int num_statics;
-	int cpu_ports;
-	int port_cnt;
-};
-
-static const struct ksz_chip_data ksz9477_switch_chips[] = {
-	{
-		.chip_id = 0x00947700,
-		.dev_name = "KSZ9477",
-		.num_vlans = 4096,
-		.num_alus = 4096,
-		.num_statics = 16,
-		.cpu_ports = 0x7F,	/* can be configured as cpu port */
-		.port_cnt = 7,		/* total physical port count */
-	},
-};
-
-static int ksz9477_switch_init(struct ksz_device *dev)
-{
-	int i;
-
-	mutex_init(&dev->reg_mutex);
-	mutex_init(&dev->stats_mutex);
-	mutex_init(&dev->alu_mutex);
-	mutex_init(&dev->vlan_mutex);
-
-	dev->ds->ops = &ksz_switch_ops;
-
-	for (i = 0; i < ARRAY_SIZE(ksz9477_switch_chips); i++) {
-		const struct ksz_chip_data *chip = &ksz9477_switch_chips[i];
-
-		if (dev->chip_id == chip->chip_id) {
-			dev->name = chip->dev_name;
-			dev->num_vlans = chip->num_vlans;
-			dev->num_alus = chip->num_alus;
-			dev->num_statics = chip->num_statics;
-			dev->port_cnt = chip->port_cnt;
-			dev->cpu_ports = chip->cpu_ports;
-
-			break;
-		}
-	}
-
-	/* no switch found */
-	if (!dev->port_cnt)
-		return -ENODEV;
-
-	return 0;
+	/* port_stp_state_set() will be called after to disable the port so
+	 * there is no need to do anything.
+	 */
 }
 
 struct ksz_device *ksz_switch_alloc(struct device *base,
@@ -1162,53 +295,43 @@ struct ksz_device *ksz_switch_alloc(struct device *base,
 }
 EXPORT_SYMBOL(ksz_switch_alloc);
 
-int ksz_switch_detect(struct ksz_device *dev)
-{
-	u8 data8;
-	u32 id32;
-	int ret;
-
-	/* turn off SPI DO Edge select */
-	ret = ksz_read8(dev, REG_SW_GLOBAL_SERIAL_CTRL_0, &data8);
-	if (ret)
-		return ret;
-
-	data8 &= ~SPI_AUTO_EDGE_DETECTION;
-	ret = ksz_write8(dev, REG_SW_GLOBAL_SERIAL_CTRL_0, data8);
-	if (ret)
-		return ret;
-
-	/* read chip id */
-	ret = ksz_read32(dev, REG_CHIP_ID0__1, &id32);
-	if (ret)
-		return ret;
-
-	dev->chip_id = id32;
-
-	return 0;
-}
-EXPORT_SYMBOL(ksz_switch_detect);
-
-int ksz_switch_register(struct ksz_device *dev)
+int ksz_switch_register(struct ksz_device *dev,
+			const struct ksz_dev_ops *ops)
 {
 	int ret;
 
 	if (dev->pdata)
 		dev->chip_id = dev->pdata->chip_id;
 
-	if (ksz_switch_detect(dev))
+	dev->dev_ops = ops;
+
+	if (dev->dev_ops->detect(dev))
 		return -EINVAL;
 
-	ret = ksz9477_switch_init(dev);
+	ret = dev->dev_ops->init(dev);
 	if (ret)
 		return ret;
 
-	return dsa_register_switch(dev->ds);
+	dev->interface = PHY_INTERFACE_MODE_MII;
+	if (dev->dev->of_node) {
+		ret = of_get_phy_mode(dev->dev->of_node);
+		if (ret >= 0)
+			dev->interface = ret;
+	}
+
+	ret = dsa_register_switch(dev->ds);
+	if (ret) {
+		dev->dev_ops->exit(dev);
+		return ret;
+	}
+
+	return 0;
 }
 EXPORT_SYMBOL(ksz_switch_register);
 
 void ksz_switch_remove(struct ksz_device *dev)
 {
+	dev->dev_ops->exit(dev);
 	dsa_unregister_switch(dev->ds);
 }
 EXPORT_SYMBOL(ksz_switch_remove);
diff --git a/drivers/net/dsa/microchip/ksz_common.h b/drivers/net/dsa/microchip/ksz_common.h
new file mode 100644
index 0000000..1c1cbad
--- /dev/null
+++ b/drivers/net/dsa/microchip/ksz_common.h
@@ -0,0 +1,230 @@
+/*
+ * Microchip switch driver common header
+ *
+ * Copyright (C) 2017 Microchip Technology Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
+ */
+
+#ifndef __KSZ_COMMON_H
+#define __KSZ_COMMON_H
+
+void ksz_update_port_member(struct ksz_device *dev, int port);
+
+/* Common DSA access functions */
+
+int ksz_phy_read16(struct dsa_switch *ds, int addr, int reg);
+int ksz_phy_write16(struct dsa_switch *ds, int addr, int reg, u16 val);
+int ksz_sset_count(struct dsa_switch *ds);
+int ksz_port_bridge_join(struct dsa_switch *ds, int port,
+			 struct net_device *br);
+void ksz_port_bridge_leave(struct dsa_switch *ds, int port,
+			   struct net_device *br);
+void ksz_port_fast_age(struct dsa_switch *ds, int port);
+int ksz_port_vlan_prepare(struct dsa_switch *ds, int port,
+			  const struct switchdev_obj_port_vlan *vlan,
+			  struct switchdev_trans *trans);
+int ksz_port_fdb_dump(struct dsa_switch *ds, int port, dsa_fdb_dump_cb_t *cb,
+		      void *data);
+int ksz_port_mdb_prepare(struct dsa_switch *ds, int port,
+			 const struct switchdev_obj_port_mdb *mdb,
+			 struct switchdev_trans *trans);
+void ksz_port_mdb_add(struct dsa_switch *ds, int port,
+		      const struct switchdev_obj_port_mdb *mdb,
+		      struct switchdev_trans *trans);
+int ksz_port_mdb_del(struct dsa_switch *ds, int port,
+		     const struct switchdev_obj_port_mdb *mdb);
+int ksz_enable_port(struct dsa_switch *ds, int port, struct phy_device *phy);
+void ksz_disable_port(struct dsa_switch *ds, int port, struct phy_device *phy);
+
+/* Common register access functions */
+
+static inline int ksz_read8(struct ksz_device *dev, u32 reg, u8 *val)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->read8(dev, reg, val);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int ksz_read16(struct ksz_device *dev, u32 reg, u16 *val)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->read16(dev, reg, val);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int ksz_read24(struct ksz_device *dev, u32 reg, u32 *val)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->read24(dev, reg, val);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int ksz_read32(struct ksz_device *dev, u32 reg, u32 *val)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->read32(dev, reg, val);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int ksz_write8(struct ksz_device *dev, u32 reg, u8 value)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->write8(dev, reg, value);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int ksz_write16(struct ksz_device *dev, u32 reg, u16 value)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->write16(dev, reg, value);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int ksz_write24(struct ksz_device *dev, u32 reg, u32 value)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->write24(dev, reg, value);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int ksz_write32(struct ksz_device *dev, u32 reg, u32 value)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->write32(dev, reg, value);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int ksz_get(struct ksz_device *dev, u32 reg, void *data,
+			  size_t len)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->get(dev, reg, data, len);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline int ksz_set(struct ksz_device *dev, u32 reg, void *data,
+			  size_t len)
+{
+	int ret;
+
+	mutex_lock(&dev->reg_mutex);
+	ret = dev->ops->set(dev, reg, data, len);
+	mutex_unlock(&dev->reg_mutex);
+
+	return ret;
+}
+
+static inline void ksz_pread8(struct ksz_device *dev, int port, int offset,
+			      u8 *data)
+{
+	ksz_read8(dev, dev->dev_ops->get_port_addr(port, offset), data);
+}
+
+static inline void ksz_pread16(struct ksz_device *dev, int port, int offset,
+			       u16 *data)
+{
+	ksz_read16(dev, dev->dev_ops->get_port_addr(port, offset), data);
+}
+
+static inline void ksz_pread32(struct ksz_device *dev, int port, int offset,
+			       u32 *data)
+{
+	ksz_read32(dev, dev->dev_ops->get_port_addr(port, offset), data);
+}
+
+static inline void ksz_pwrite8(struct ksz_device *dev, int port, int offset,
+			       u8 data)
+{
+	ksz_write8(dev, dev->dev_ops->get_port_addr(port, offset), data);
+}
+
+static inline void ksz_pwrite16(struct ksz_device *dev, int port, int offset,
+				u16 data)
+{
+	ksz_write16(dev, dev->dev_ops->get_port_addr(port, offset), data);
+}
+
+static inline void ksz_pwrite32(struct ksz_device *dev, int port, int offset,
+				u32 data)
+{
+	ksz_write32(dev, dev->dev_ops->get_port_addr(port, offset), data);
+}
+
+static void ksz_cfg(struct ksz_device *dev, u32 addr, u8 bits, bool set)
+{
+	u8 data;
+
+	ksz_read8(dev, addr, &data);
+	if (set)
+		data |= bits;
+	else
+		data &= ~bits;
+	ksz_write8(dev, addr, data);
+}
+
+static void ksz_port_cfg(struct ksz_device *dev, int port, int offset, u8 bits,
+			 bool set)
+{
+	u32 addr;
+	u8 data;
+
+	addr = dev->dev_ops->get_port_addr(port, offset);
+	ksz_read8(dev, addr, &data);
+
+	if (set)
+		data |= bits;
+	else
+		data &= ~bits;
+
+	ksz_write8(dev, addr, data);
+}
+
+#endif
diff --git a/drivers/net/dsa/microchip/ksz_priv.h b/drivers/net/dsa/microchip/ksz_priv.h
index d461468..4126749 100644
--- a/drivers/net/dsa/microchip/ksz_priv.h
+++ b/drivers/net/dsa/microchip/ksz_priv.h
@@ -34,6 +34,30 @@ struct vlan_table {
 	u32 table[3];
 };
 
+struct ksz_port_mib {
+	u8 cnt_ptr;
+	u64 *counters;
+};
+
+struct ksz_port {
+	u16 member;
+	u16 vid_member;
+	int stp_state;
+	u16 speed;
+	u8 duplex;
+	u8 flow_ctrl;
+
+	u32 on:1;			/* port is not disabled by hardware */
+	u32 phy:1;			/* port has a PHY */
+	u32 fiber:1;			/* port is fiber */
+	u32 sgmii:1;			/* port is SGMII */
+	u32 force:1;
+	u32 link_down:1;		/* link just goes down */
+	u32 link_up:1;			/* link is up */
+
+	struct ksz_port_mib mib;
+};
+
 struct ksz_device {
 	struct dsa_switch *ds;
 	struct ksz_platform_data *pdata;
@@ -44,6 +68,7 @@ struct ksz_device {
 	struct mutex alu_mutex;		/* ALU access */
 	struct mutex vlan_mutex;	/* vlan access */
 	const struct ksz_io_ops *ops;
+	const struct ksz_dev_ops *dev_ops;
 
 	struct device *dev;
 
@@ -56,11 +81,37 @@ struct ksz_device {
 	int num_statics;
 	int cpu_port;			/* port connected to CPU */
 	int cpu_ports;			/* port bitmap can be cpu port */
+	int phy_port_cnt;
 	int port_cnt;
+	int reg_mib_cnt;
+	int mib_cnt;
+	int mib_port_cnt;
+	int last_port;			/* ports after that not used */
+	int interface;
+	u32 regs_size;
 
 	struct vlan_table *vlan_cache;
 
 	u64 mib_value[TOTAL_SWITCH_COUNTER_NUM];
+
+	u8 *txbuf;
+
+	struct ksz_port *ports;
+	struct timer_list mib_read_timer;
+	struct work_struct mib_read;
+	unsigned long mib_read_interval;
+	u16 br_member;
+	u16 member;
+	u16 live_ports;
+	u16 on_ports;			/* ports enabled by DSA */
+	u16 rx_ports;
+	u16 tx_ports;
+	u16 mirror_rx;
+	u16 mirror_tx;
+	u32 features;			/* chip specific features */
+	u32 overrides;			/* chip functions set by user */
+	u16 host_mask;
+	u16 port_mask;
 };
 
 struct ksz_io_ops {
@@ -72,140 +123,60 @@ struct ksz_io_ops {
 	int (*write16)(struct ksz_device *dev, u32 reg, u16 value);
 	int (*write24)(struct ksz_device *dev, u32 reg, u32 value);
 	int (*write32)(struct ksz_device *dev, u32 reg, u32 value);
-	int (*phy_read16)(struct ksz_device *dev, int addr, int reg,
-			  u16 *value);
-	int (*phy_write16)(struct ksz_device *dev, int addr, int reg,
-			   u16 value);
+	int (*get)(struct ksz_device *dev, u32 reg, void *data, size_t len);
+	int (*set)(struct ksz_device *dev, u32 reg, void *data, size_t len);
+};
+
+struct alu_struct {
+	/* entry 1 */
+	u8	is_static:1;
+	u8	is_src_filter:1;
+	u8	is_dst_filter:1;
+	u8	prio_age:3;
+	u32	_reserv_0_1:23;
+	u8	mstp:3;
+	/* entry 2 */
+	u8	is_override:1;
+	u8	is_use_fid:1;
+	u32	_reserv_1_1:23;
+	u8	port_forward:7;
+	/* entry 3 & 4*/
+	u32	_reserv_2_1:9;
+	u8	fid:7;
+	u8	mac[ETH_ALEN];
+};
+
+struct ksz_dev_ops {
+	u32 (*get_port_addr)(int port, int offset);
+	void (*cfg_port_member)(struct ksz_device *dev, int port, u8 member);
+	void (*flush_dyn_mac_table)(struct ksz_device *dev, int port);
+	void (*port_setup)(struct ksz_device *dev, int port, bool cpu_port);
+	void (*r_phy)(struct ksz_device *dev, u16 phy, u16 reg, u16 *val);
+	void (*w_phy)(struct ksz_device *dev, u16 phy, u16 reg, u16 val);
+	int (*r_dyn_mac_table)(struct ksz_device *dev, u16 addr, u8 *mac_addr,
+			       u8 *fid, u8 *src_port, u8 *timestamp,
+			       u16 *entries);
+	int (*r_sta_mac_table)(struct ksz_device *dev, u16 addr,
+			       struct alu_struct *alu);
+	void (*w_sta_mac_table)(struct ksz_device *dev, u16 addr,
+				struct alu_struct *alu);
+	void (*r_mib_cnt)(struct ksz_device *dev, int port, u16 addr,
+			  u64 *cnt);
+	void (*r_mib_pkt)(struct ksz_device *dev, int port, u16 addr,
+			  u64 *dropped, u64 *cnt);
+	void (*port_init_cnt)(struct ksz_device *dev, int port);
+	int (*shutdown)(struct ksz_device *dev);
+	int (*detect)(struct ksz_device *dev);
+	int (*init)(struct ksz_device *dev);
+	void (*exit)(struct ksz_device *dev);
 };
 
 struct ksz_device *ksz_switch_alloc(struct device *base,
 				    const struct ksz_io_ops *ops, void *priv);
-int ksz_switch_detect(struct ksz_device *dev);
-int ksz_switch_register(struct ksz_device *dev);
+int ksz_switch_register(struct ksz_device *dev,
+			const struct ksz_dev_ops *ops);
 void ksz_switch_remove(struct ksz_device *dev);
 
-static inline int ksz_read8(struct ksz_device *dev, u32 reg, u8 *val)
-{
-	int ret;
-
-	mutex_lock(&dev->reg_mutex);
-	ret = dev->ops->read8(dev, reg, val);
-	mutex_unlock(&dev->reg_mutex);
-
-	return ret;
-}
-
-static inline int ksz_read16(struct ksz_device *dev, u32 reg, u16 *val)
-{
-	int ret;
-
-	mutex_lock(&dev->reg_mutex);
-	ret = dev->ops->read16(dev, reg, val);
-	mutex_unlock(&dev->reg_mutex);
-
-	return ret;
-}
-
-static inline int ksz_read24(struct ksz_device *dev, u32 reg, u32 *val)
-{
-	int ret;
-
-	mutex_lock(&dev->reg_mutex);
-	ret = dev->ops->read24(dev, reg, val);
-	mutex_unlock(&dev->reg_mutex);
-
-	return ret;
-}
-
-static inline int ksz_read32(struct ksz_device *dev, u32 reg, u32 *val)
-{
-	int ret;
-
-	mutex_lock(&dev->reg_mutex);
-	ret = dev->ops->read32(dev, reg, val);
-	mutex_unlock(&dev->reg_mutex);
-
-	return ret;
-}
-
-static inline int ksz_write8(struct ksz_device *dev, u32 reg, u8 value)
-{
-	int ret;
-
-	mutex_lock(&dev->reg_mutex);
-	ret = dev->ops->write8(dev, reg, value);
-	mutex_unlock(&dev->reg_mutex);
-
-	return ret;
-}
-
-static inline int ksz_write16(struct ksz_device *dev, u32 reg, u16 value)
-{
-	int ret;
-
-	mutex_lock(&dev->reg_mutex);
-	ret = dev->ops->write16(dev, reg, value);
-	mutex_unlock(&dev->reg_mutex);
-
-	return ret;
-}
-
-static inline int ksz_write24(struct ksz_device *dev, u32 reg, u32 value)
-{
-	int ret;
-
-	mutex_lock(&dev->reg_mutex);
-	ret = dev->ops->write24(dev, reg, value);
-	mutex_unlock(&dev->reg_mutex);
-
-	return ret;
-}
-
-static inline int ksz_write32(struct ksz_device *dev, u32 reg, u32 value)
-{
-	int ret;
-
-	mutex_lock(&dev->reg_mutex);
-	ret = dev->ops->write32(dev, reg, value);
-	mutex_unlock(&dev->reg_mutex);
-
-	return ret;
-}
-
-static inline void ksz_pread8(struct ksz_device *dev, int port, int offset,
-			      u8 *data)
-{
-	ksz_read8(dev, PORT_CTRL_ADDR(port, offset), data);
-}
-
-static inline void ksz_pread16(struct ksz_device *dev, int port, int offset,
-			       u16 *data)
-{
-	ksz_read16(dev, PORT_CTRL_ADDR(port, offset), data);
-}
-
-static inline void ksz_pread32(struct ksz_device *dev, int port, int offset,
-			       u32 *data)
-{
-	ksz_read32(dev, PORT_CTRL_ADDR(port, offset), data);
-}
-
-static inline void ksz_pwrite8(struct ksz_device *dev, int port, int offset,
-			       u8 data)
-{
-	ksz_write8(dev, PORT_CTRL_ADDR(port, offset), data);
-}
-
-static inline void ksz_pwrite16(struct ksz_device *dev, int port, int offset,
-				u16 data)
-{
-	ksz_write16(dev, PORT_CTRL_ADDR(port, offset), data);
-}
-
-static inline void ksz_pwrite32(struct ksz_device *dev, int port, int offset,
-				u32 data)
-{
-	ksz_write32(dev, PORT_CTRL_ADDR(port, offset), data);
-}
+int ksz9477_switch_register(struct ksz_device *dev);
 
 #endif
diff --git a/drivers/net/dsa/microchip/ksz_spi.h b/drivers/net/dsa/microchip/ksz_spi.h
new file mode 100644
index 0000000..a05d404
--- /dev/null
+++ b/drivers/net/dsa/microchip/ksz_spi.h
@@ -0,0 +1,82 @@
+/*
+ * Microchip KSZ series SPI access common header
+ *
+ * Copyright (C) 2017 Microchip Technology Inc.
+ *	Tristram Ha <Tristram.Ha@microchip.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
+ */
+
+#ifndef __KSZ_SPI_H
+#define __KSZ_SPI_H
+
+/* Chip dependent SPI access */
+static int ksz_spi_read(struct ksz_device *dev, u32 reg, u8 *data,
+			unsigned int len);
+static int ksz_spi_write(struct ksz_device *dev, u32 reg, void *data,
+			 unsigned int len);
+
+static int ksz_spi_read8(struct ksz_device *dev, u32 reg, u8 *val)
+{
+	return ksz_spi_read(dev, reg, val, 1);
+}
+
+static int ksz_spi_read16(struct ksz_device *dev, u32 reg, u16 *val)
+{
+	int ret = ksz_spi_read(dev, reg, (u8 *)val, 2);
+
+	if (!ret)
+		*val = be16_to_cpu(*val);
+
+	return ret;
+}
+
+static int ksz_spi_read32(struct ksz_device *dev, u32 reg, u32 *val)
+{
+	int ret = ksz_spi_read(dev, reg, (u8 *)val, 4);
+
+	if (!ret)
+		*val = be32_to_cpu(*val);
+
+	return ret;
+}
+
+static int ksz_spi_write8(struct ksz_device *dev, u32 reg, u8 value)
+{
+	return ksz_spi_write(dev, reg, &value, 1);
+}
+
+static int ksz_spi_write16(struct ksz_device *dev, u32 reg, u16 value)
+{
+	value = cpu_to_be16(value);
+	return ksz_spi_write(dev, reg, &value, 2);
+}
+
+static int ksz_spi_write32(struct ksz_device *dev, u32 reg, u32 value)
+{
+	value = cpu_to_be32(value);
+	return ksz_spi_write(dev, reg, &value, 4);
+}
+
+static int ksz_spi_get(struct ksz_device *dev, u32 reg, void *data, size_t len)
+{
+	return ksz_spi_read(dev, reg, data, len);
+}
+
+static int ksz_spi_set(struct ksz_device *dev, u32 reg, void *data, size_t len)
+{
+	return ksz_spi_write(dev, reg, data, len);
+}
+
+#endif
-- 
1.9.1
