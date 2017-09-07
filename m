From: <Tristram.Ha@microchip.com>
Subject: [PATCH RFC 3/5] Add KSZ8795 switch driver
Date: Thu, 7 Sep 2017 21:17:16 +0000
Message-ID: <93AF473E2DA327428DE3D46B72B1E9FD41121A87@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <andrew@lunn.ch>, <muvarov@gmail.com>, <pavel@ucw.cz>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <Woojung.Huh@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tristram Ha <Tristram.Ha@microchip.com>

Add KSZ8795 switch support with function code.

Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
---
diff --git a/drivers/net/dsa/microchip/ksz8795.c b/drivers/net/dsa/microchip/ksz8795.c
new file mode 100644
index 0000000..e4d4e6a
--- /dev/null
+++ b/drivers/net/dsa/microchip/ksz8795.c
@@ -0,0 +1,2066 @@
+/*
+ * Microchip KSZ8795 switch driver
+ *
+ * Copyright (C) 2017 Microchip Technology Inc.
+ *	Tristram Ha <Tristram.Ha@microchip.com>
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
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
+#include "ksz8795.h"
+
+/**
+ * Some counters do not need to be read too often because they are less likely
+ * to increase much.
+ */
+static const struct {
+	int interval;
+	char string[ETH_GSTRING_LEN];
+} mib_names[TOTAL_SWITCH_COUNTER_NUM] = {
+	{ 1, "rx_hi" },
+	{ 4, "rx_undersize" },
+	{ 4, "rx_fragments" },
+	{ 4, "rx_oversize" },
+	{ 4, "rx_jabbers" },
+	{ 4, "rx_symbol_err" },
+	{ 4, "rx_crc_err" },
+	{ 4, "rx_align_err" },
+	{ 4, "rx_mac_ctrl" },
+	{ 1, "rx_pause" },
+	{ 1, "rx_bcast" },
+	{ 1, "rx_mcast" },
+	{ 1, "rx_ucast" },
+	{ 2, "rx_64_or_less" },
+	{ 2, "rx_65_127" },
+	{ 2, "rx_128_255" },
+	{ 2, "rx_256_511" },
+	{ 2, "rx_512_1023" },
+	{ 2, "rx_1024_1522" },
+	{ 2, "rx_1523_2000" },
+	{ 2, "rx_2001" },
+	{ 1, "tx_hi" },
+	{ 4, "tx_late_col" },
+	{ 1, "tx_pause" },
+	{ 1, "tx_bcast" },
+	{ 1, "tx_mcast" },
+	{ 1, "tx_ucast" },
+	{ 4, "tx_deferred" },
+	{ 4, "tx_total_col" },
+	{ 4, "tx_exc_col" },
+	{ 4, "tx_single_col" },
+	{ 4, "tx_mult_col" },
+	{ 1, "rx_total" },
+	{ 1, "tx_total" },
+	{ 2, "rx_discards" },
+	{ 2, "tx_discards" },
+};
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
+	addr = PORT_CTRL_ADDR(port, offset);
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
+static int chk_last_port(struct ksz_device *dev, int p)
+{
+	if (dev->last_port && p == dev->last_port)
+		p = dev->cpu_port;
+	return p;
+}
+
+static int ksz_reset_switch(struct ksz_device *dev)
+{
+	/* reset switch */
+	ksz_write8(dev, REG_POWER_MANAGEMENT_1,
+		   SW_SOFTWARE_POWER_DOWN << SW_POWER_MANAGEMENT_MODE_S);
+	ksz_write8(dev, REG_POWER_MANAGEMENT_1, 0);
+
+	return 0;
+}
+
+static void port_set_prio_queue(struct ksz_device *dev, int port, int queue)
+{
+	u8 hi;
+	u8 lo;
+
+	switch (queue) {
+	case 4:
+	case 3:
+		queue = PORT_QUEUE_SPLIT_4;
+		break;
+	case 2:
+		queue = PORT_QUEUE_SPLIT_2;
+		break;
+	default:
+		queue = PORT_QUEUE_SPLIT_1;
+	}
+	ksz_pread8(dev, port, REG_PORT_CTRL_0, &lo);
+	ksz_pread8(dev, port, P_DROP_TAG_CTRL, &hi);
+	lo &= ~PORT_QUEUE_SPLIT_L;
+	if (queue & 1)
+		lo |= PORT_QUEUE_SPLIT_L;
+	hi &= ~PORT_QUEUE_SPLIT_H;
+	if (queue & 2)
+		hi |= PORT_QUEUE_SPLIT_H;
+	ksz_pwrite8(dev, port, REG_PORT_CTRL_0, lo);
+	ksz_pwrite8(dev, port, P_DROP_TAG_CTRL, hi);
+
+	/* Default is port based for egress rate limit. */
+	if (queue)
+		ksz_cfg(dev, REG_SW_CTRL_19, SW_OUT_RATE_LIMIT_QUEUE_BASED,
+			true);
+}
+
+static void port_r_mib_cnt(struct ksz_device *dev, int port, u16 addr, u64 *cnt)
+{
+	u32 data;
+	u16 ctrl_addr;
+	u8 check;
+	int timeout;
+
+	ctrl_addr = addr + SWITCH_COUNTER_NUM * port;
+
+	ctrl_addr |= IND_ACC_TABLE(TABLE_MIB | TABLE_READ);
+	mutex_lock(&dev->stats_mutex);
+	ksz_write16(dev, REG_IND_CTRL_0, ctrl_addr);
+
+	for (timeout = 1; timeout > 0; timeout--) {
+		ksz_read8(dev, REG_IND_MIB_CHECK, &check);
+
+		if (check & MIB_COUNTER_VALID) {
+			ksz_read32(dev, REG_IND_DATA_LO, &data);
+			if (check & MIB_COUNTER_OVERFLOW)
+				*cnt += MIB_COUNTER_VALUE + 1;
+			*cnt += data & MIB_COUNTER_VALUE;
+			break;
+		}
+	}
+	mutex_unlock(&dev->stats_mutex);
+}
+
+static void port_r_mib_pkt(struct ksz_device *dev, int port, u16 addr, u64 *cnt)
+{
+	u32 data;
+	u16 ctrl_addr;
+	u8 check;
+	int timeout;
+
+	addr -= SWITCH_COUNTER_NUM;
+	ctrl_addr = (KS_MIB_TOTAL_RX_1 - KS_MIB_TOTAL_RX_0) * port;
+	ctrl_addr += addr + KS_MIB_TOTAL_RX_0;
+
+	ctrl_addr |= IND_ACC_TABLE(TABLE_MIB | TABLE_READ);
+	mutex_lock(&dev->stats_mutex);
+	ksz_write16(dev, REG_IND_CTRL_0, ctrl_addr);
+
+	for (timeout = 1; timeout > 0; timeout--) {
+		ksz_read8(dev, REG_IND_MIB_CHECK, &check);
+
+		if (check & MIB_COUNTER_VALID) {
+			ksz_read32(dev, REG_IND_DATA_LO, &data);
+			if (addr < 2) {
+				u64 total;
+
+				total = check & MIB_TOTAL_BYTES_H;
+				total <<= 32;
+				*cnt += total;
+				*cnt += data;
+				if (check & MIB_COUNTER_OVERFLOW) {
+					total = MIB_TOTAL_BYTES_H + 1;
+					total <<= 32;
+					*cnt += total;
+				}
+			} else {
+				if (check & MIB_COUNTER_OVERFLOW)
+					*cnt += MIB_PACKET_DROPPED + 1;
+				*cnt += data & MIB_PACKET_DROPPED;
+			}
+			break;
+		}
+	}
+	mutex_unlock(&dev->stats_mutex);
+}
+
+static int port_r_cnt(struct ksz_device *dev, int port)
+{
+	struct ksz_port_mib *mib = &dev->ports[port].mib;
+	struct ksz_port_mib_info *info;
+
+	/* Some ports may not have MIB counters before SWITCH_COUNTER_NUM. */
+	while (mib->cnt_ptr < SWITCH_COUNTER_NUM) {
+		info = &mib->info[mib->cnt_ptr];
+		spin_lock(&dev->mib_read_lock);
+		++info->read_cnt;
+		if (info->read_cnt >= info->read_max) {
+			info->read_cnt = 0;
+			port_r_mib_cnt(dev, port, mib->cnt_ptr,
+				       &info->counter);
+		}
+		spin_unlock(&dev->mib_read_lock);
+		++mib->cnt_ptr;
+	}
+
+	/* Some ports may not have MIB counters after SWITCH_COUNTER_NUM. */
+	while (mib->cnt_ptr < TOTAL_SWITCH_COUNTER_NUM) {
+		info = &mib->info[mib->cnt_ptr];
+		spin_lock(&dev->mib_read_lock);
+		++info->read_cnt;
+		if (info->read_cnt >= info->read_max) {
+			info->read_cnt = 0;
+			port_r_mib_pkt(dev, port, mib->cnt_ptr,
+				       &info->counter);
+		}
+		spin_unlock(&dev->mib_read_lock);
+		++mib->cnt_ptr;
+	}
+	mib->cnt_ptr = 0;
+	return 0;
+}
+
+static void port_init_cnt(struct ksz_device *dev, int port)
+{
+	struct ksz_port_mib *mib = &dev->ports[port].mib;
+	struct ksz_port_mib_info *info;
+
+	mib->cnt_ptr = 0;
+
+	/* Some ports may not have MIB counters before SWITCH_COUNTER_NUM. */
+	while (mib->cnt_ptr < SWITCH_COUNTER_NUM) {
+		info = &mib->info[mib->cnt_ptr];
+		info->read_cnt = 0;
+		info->read_max = mib_names[mib->cnt_ptr].interval;
+		port_r_mib_cnt(dev, port, mib->cnt_ptr,
+			       &info->counter);
+		info->counter = 0;
+		++mib->cnt_ptr;
+	}
+
+	/* Some ports may not have MIB counters after SWITCH_COUNTER_NUM. */
+	while (mib->cnt_ptr < TOTAL_SWITCH_COUNTER_NUM) {
+		info->read_cnt = 0;
+		info->read_max = mib_names[mib->cnt_ptr].interval;
+		port_r_mib_pkt(dev, port, mib->cnt_ptr,
+			       &info->counter);
+		info->counter = 0;
+		++mib->cnt_ptr;
+	}
+	mib->cnt_ptr = 0;
+	mib->time = jiffies;
+}
+
+static void ksz_r_table_64(struct ksz_device *dev, int table, u16 addr,
+			   u64 *data)
+{
+	u16 ctrl_addr;
+
+	ctrl_addr = IND_ACC_TABLE(table | TABLE_READ) | addr;
+
+	ksz_write16(dev, REG_IND_CTRL_0, ctrl_addr);
+	dev->ops->get(dev, REG_IND_DATA_HI, data, sizeof(u64));
+	*data = be64_to_cpu(*data);
+}
+
+static void ksz_w_table_64(struct ksz_device *dev, int table, u16 addr,
+			   u64 data)
+{
+	u16 ctrl_addr;
+
+	ctrl_addr = IND_ACC_TABLE(table) | addr;
+	data = cpu_to_be64(data);
+
+	dev->ops->set(dev, REG_IND_DATA_HI, &data, sizeof(u64));
+	ksz_write16(dev, REG_IND_CTRL_0, ctrl_addr);
+}
+
+static int valid_dyn_entry(struct ksz_device *dev, u8 *data)
+{
+	int timeout = 100;
+
+	do {
+		ksz_read8(dev, REG_IND_DATA_CHECK, data);
+		timeout--;
+	} while ((*data & DYNAMIC_MAC_TABLE_NOT_READY) && timeout);
+
+	/* Entry is not ready for accessing. */
+	if (*data & DYNAMIC_MAC_TABLE_NOT_READY) {
+		return 1;
+	/* Entry is ready for accessing. */
+	} else {
+		ksz_read8(dev, REG_IND_DATA_8, data);
+
+		/* There is no valid entry in the table. */
+		if (*data & DYNAMIC_MAC_TABLE_MAC_EMPTY)
+			return 2;
+	}
+	return 0;
+}
+
+static int ksz_r_dyn_mac_table(struct ksz_device *dev, u16 addr, u8 *mac_addr,
+			       u8 *fid, u8 *src_port, u8 *timestamp,
+			       u16 *entries)
+{
+	u32 data_hi;
+	u32 data_lo;
+	u16 ctrl_addr;
+	int rc;
+	u8 data;
+
+	ctrl_addr = IND_ACC_TABLE(TABLE_DYNAMIC_MAC | TABLE_READ) | addr;
+
+	ksz_write16(dev, REG_IND_CTRL_0, ctrl_addr);
+
+	rc = valid_dyn_entry(dev, &data);
+	if (rc == 1) {
+		if (addr == 0)
+			*entries = 0;
+	} else if (rc == 2) {
+		*entries = 0;
+	/* At least one valid entry in the table. */
+	} else {
+		u64 buf;
+
+		dev->ops->get(dev, REG_IND_DATA_HI, &buf, sizeof(buf));
+		buf = be64_to_cpu(buf);
+		data_hi = (u32)(buf >> 32);
+		data_lo = (u32)buf;
+
+		/* Check out how many valid entry in the table. */
+		*entries = (u16)(((((u16)
+			data & DYNAMIC_MAC_TABLE_ENTRIES_H) <<
+			DYNAMIC_MAC_ENTRIES_H_S) |
+			(((data_hi & DYNAMIC_MAC_TABLE_ENTRIES) >>
+			DYNAMIC_MAC_ENTRIES_S))) + 1);
+
+		*fid = (u8)((data_hi & DYNAMIC_MAC_TABLE_FID) >>
+			DYNAMIC_MAC_FID_S);
+		*src_port = (u8)((data_hi & DYNAMIC_MAC_TABLE_SRC_PORT) >>
+			DYNAMIC_MAC_SRC_PORT_S);
+		*timestamp = (u8)((
+			data_hi & DYNAMIC_MAC_TABLE_TIMESTAMP) >>
+			DYNAMIC_MAC_TIMESTAMP_S);
+
+		mac_addr[5] = (u8)data_lo;
+		mac_addr[4] = (u8)(data_lo >> 8);
+		mac_addr[3] = (u8)(data_lo >> 16);
+		mac_addr[2] = (u8)(data_lo >> 24);
+
+		mac_addr[1] = (u8)data_hi;
+		mac_addr[0] = (u8)(data_hi >> 8);
+		rc = 0;
+	}
+
+	return rc;
+}
+
+struct alu_struct {
+	u8	is_static:1;
+	u8	prio_age:3;
+	u8	is_override:1;
+	u8	is_use_fid:1;
+	u8	port_forward:5;
+	u8	fid:7;
+	u8	mac[ETH_ALEN];
+};
+
+static int ksz_r_sta_mac_table(struct ksz_device *dev, u16 addr,
+			       struct alu_struct *alu)
+{
+	u64 data;
+	u32 data_hi;
+	u32 data_lo;
+
+	ksz_r_table_64(dev, TABLE_STATIC_MAC, addr, &data);
+	data_hi = data >> 32;
+	data_lo = (u32)data;
+	if (data_hi & (STATIC_MAC_TABLE_VALID | STATIC_MAC_TABLE_OVERRIDE)) {
+		alu->mac[5] = (u8)data_lo;
+		alu->mac[4] = (u8)(data_lo >> 8);
+		alu->mac[3] = (u8)(data_lo >> 16);
+		alu->mac[2] = (u8)(data_lo >> 24);
+		alu->mac[1] = (u8)data_hi;
+		alu->mac[0] = (u8)(data_hi >> 8);
+		alu->port_forward =
+			(u8)((data_hi & STATIC_MAC_TABLE_FWD_PORTS) >>
+			STATIC_MAC_FWD_PORTS_S);
+		alu->is_override =
+			(data_hi & STATIC_MAC_TABLE_OVERRIDE) ? 1 : 0;
+		data_hi >>= 1;
+		alu->is_use_fid = (data_hi & STATIC_MAC_TABLE_USE_FID) ? 1 : 0;
+		alu->fid = (u8)((data_hi & STATIC_MAC_TABLE_FID) >>
+			STATIC_MAC_FID_S);
+		return 0;
+	}
+	return -1;
+}
+
+static void ksz_w_sta_mac_table(struct ksz_device *dev, u16 addr,
+				struct alu_struct *alu)
+{
+	u64 data;
+	u32 data_hi;
+	u32 data_lo;
+
+	data_lo = ((u32)alu->mac[2] << 24) |
+		((u32)alu->mac[3] << 16) |
+		((u32)alu->mac[4] << 8) | alu->mac[5];
+	data_hi = ((u32)alu->mac[0] << 8) | alu->mac[1];
+	data_hi |= (u32)alu->port_forward << STATIC_MAC_FWD_PORTS_S;
+
+	if (alu->is_override)
+		data_hi |= STATIC_MAC_TABLE_OVERRIDE;
+	if (alu->is_use_fid) {
+		data_hi |= STATIC_MAC_TABLE_USE_FID;
+		data_hi |= (u32)alu->fid << STATIC_MAC_FID_S;
+	}
+	if (alu->is_static)
+		data_hi |= STATIC_MAC_TABLE_VALID;
+	else
+		data_hi &= ~STATIC_MAC_TABLE_OVERRIDE;
+
+	data = (u64)data_hi << 32 | data_lo;
+	ksz_w_table_64(dev, TABLE_STATIC_MAC, addr, data);
+}
+
+static inline void from_vlan(u16 vlan, u8 *fid, u8 *member, u8 *valid)
+{
+	*fid = (u8)(vlan & VLAN_TABLE_FID);
+	*member = (u8)(vlan & VLAN_TABLE_MEMBERSHIP) >> VLAN_TABLE_MEMBERSHIP_S;
+	*valid = !!(vlan & VLAN_TABLE_VALID);
+}
+
+static inline void to_vlan(u8 fid, u8 member, u8 valid, u16 *vlan)
+{
+	*vlan = fid;
+	*vlan |= (u16)member << VLAN_TABLE_MEMBERSHIP_S;
+	if (valid)
+		*vlan |= VLAN_TABLE_VALID;
+}
+
+static void ksz_r_vlan_entries(struct ksz_device *dev, u16 addr)
+{
+	u64 data;
+	int i;
+
+	ksz_r_table_64(dev, TABLE_VLAN, addr, &data);
+	addr *= 4;
+	for (i = 0; i < 4; i++) {
+		dev->vlan_cache[addr + i].table[0] = (u16)data;
+		data >>= VLAN_TABLE_S;
+	}
+}
+
+static void ksz_r_vlan_table(struct ksz_device *dev, u16 vid,
+			     u16 *vlan)
+{
+	u64 buf;
+	u16 *data = (u16 *)&buf;
+	u16 addr;
+	int index;
+
+	addr = vid / 4;
+	index = vid & 3;
+	ksz_r_table_64(dev, TABLE_VLAN, addr, &buf);
+	*vlan = data[index];
+}
+
+static void ksz_w_vlan_table(struct ksz_device *dev, u16 vid,
+			     u16 vlan)
+{
+	u64 buf;
+	u16 *data = (u16 *)&buf;
+	u16 addr;
+	int index;
+
+	addr = vid / 4;
+	index = vid & 3;
+	ksz_r_table_64(dev, TABLE_VLAN, addr, &buf);
+	data[index] = vlan;
+	dev->vlan_cache[vid].table[0] = vlan;
+	ksz_w_table_64(dev, TABLE_VLAN, addr, buf);
+}
+
+static enum dsa_tag_protocol ksz_get_tag_protocol(struct dsa_switch *ds)
+{
+	return DSA_TAG_PROTO_KSZ;
+}
+
+static void ksz_r_phy(struct ksz_device *dev, u16 phy, u16 reg, u16 *val)
+{
+	struct ksz_port *port;
+	u8 ctrl;
+	u8 restart;
+	u8 link;
+	u8 speed;
+	u8 force;
+	u8 p = phy;
+	u16 data = 0;
+	int processed = true;
+
+	port = &dev->ports[p];
+	switch (reg) {
+	case PHY_REG_CTRL:
+		ksz_pread8(dev, p, P_LOCAL_CTRL, &ctrl);
+		ksz_pread8(dev, p, P_NEG_RESTART_CTRL, &restart);
+		ksz_pread8(dev, p, P_SPEED_STATUS, &speed);
+		ksz_pread8(dev, p, P_FORCE_CTRL, &force);
+		if (restart & PORT_PHY_LOOPBACK)
+			data |= PHY_LOOPBACK;
+		if (force & PORT_FORCE_100_MBIT)
+			data |= PHY_SPEED_100MBIT;
+		if (!(force & PORT_AUTO_NEG_DISABLE))
+			data |= PHY_AUTO_NEG_ENABLE;
+		if (restart & PORT_POWER_DOWN)
+			data |= PHY_POWER_DOWN;
+		if (restart & PORT_AUTO_NEG_RESTART)
+			data |= PHY_AUTO_NEG_RESTART;
+		if (force & PORT_FORCE_FULL_DUPLEX)
+			data |= PHY_FULL_DUPLEX;
+		if (speed & PORT_HP_MDIX)
+			data |= PHY_HP_MDIX;
+		if (restart & PORT_FORCE_MDIX)
+			data |= PHY_FORCE_MDIX;
+		if (restart & PORT_AUTO_MDIX_DISABLE)
+			data |= PHY_AUTO_MDIX_DISABLE;
+		if (restart & PORT_TX_DISABLE)
+			data |= PHY_TRANSMIT_DISABLE;
+		if (restart & PORT_LED_OFF)
+			data |= PHY_LED_DISABLE;
+		break;
+	case PHY_REG_STATUS:
+		ksz_pread8(dev, p, P_LINK_STATUS, &link);
+		ksz_pread8(dev, p, P_SPEED_STATUS, &speed);
+		data = PHY_100BTX_FD_CAPABLE |
+			PHY_100BTX_CAPABLE |
+			PHY_10BT_FD_CAPABLE |
+			PHY_10BT_CAPABLE |
+			PHY_AUTO_NEG_CAPABLE;
+		if (link & PORT_AUTO_NEG_COMPLETE)
+			data |= PHY_AUTO_NEG_ACKNOWLEDGE;
+		if (link & PORT_STAT_LINK_GOOD) {
+			data |= PHY_LINK_STATUS;
+			if (!port->link_up) {
+				port->link_up = 1;
+				dev->live_ports |= (1 << phy) & dev->on_ports;
+			}
+		} else if (port->link_up) {
+			port->link_down = 1;
+			port->link_up = 0;
+			dev->live_ports &= ~(1 << phy);
+		}
+		break;
+	case PHY_REG_ID_1:
+		data = KSZ8795_ID_HI;
+		break;
+	case PHY_REG_ID_2:
+		data = KSZ8795_ID_LO;
+		break;
+	case PHY_REG_AUTO_NEGOTIATION:
+		ksz_pread8(dev, p, P_LOCAL_CTRL, &ctrl);
+		data = PHY_AUTO_NEG_802_3;
+		if (ctrl & PORT_AUTO_NEG_SYM_PAUSE)
+			data |= PHY_AUTO_NEG_SYM_PAUSE;
+		if (ctrl & PORT_AUTO_NEG_100BTX_FD)
+			data |= PHY_AUTO_NEG_100BTX_FD;
+		if (ctrl & PORT_AUTO_NEG_100BTX)
+			data |= PHY_AUTO_NEG_100BTX;
+		if (ctrl & PORT_AUTO_NEG_10BT_FD)
+			data |= PHY_AUTO_NEG_10BT_FD;
+		if (ctrl & PORT_AUTO_NEG_10BT)
+			data |= PHY_AUTO_NEG_10BT;
+		break;
+	case PHY_REG_REMOTE_CAPABILITY:
+		ksz_pread8(dev, p, P_REMOTE_STATUS, &link);
+		data = PHY_AUTO_NEG_802_3;
+		if (link & PORT_REMOTE_SYM_PAUSE)
+			data |= PHY_AUTO_NEG_SYM_PAUSE;
+		if (link & PORT_REMOTE_100BTX_FD)
+			data |= PHY_AUTO_NEG_100BTX_FD;
+		if (link & PORT_REMOTE_100BTX)
+			data |= PHY_AUTO_NEG_100BTX;
+		if (link & PORT_REMOTE_10BT_FD)
+			data |= PHY_AUTO_NEG_10BT_FD;
+		if (link & PORT_REMOTE_10BT)
+			data |= PHY_AUTO_NEG_10BT;
+		break;
+	default:
+		processed = false;
+		break;
+	}
+	if (processed)
+		*val = data;
+}
+
+static void ksz_w_phy(struct ksz_device *dev, u16 phy, u16 reg, u16 val)
+{
+	u8 ctrl;
+	u8 restart;
+	u8 speed;
+	u8 data;
+	u8 p = phy;
+
+	switch (reg) {
+	case PHY_REG_CTRL:
+
+		/* Do not support PHY reset function. */
+		if (val & PHY_RESET)
+			break;
+		ksz_pread8(dev, p, P_SPEED_STATUS, &speed);
+		data = speed;
+		if (val & PHY_HP_MDIX)
+			data |= PORT_HP_MDIX;
+		else
+			data &= ~PORT_HP_MDIX;
+		if (data != speed)
+			ksz_pwrite8(dev, p, P_SPEED_STATUS, data);
+		ksz_pread8(dev, p, P_FORCE_CTRL, &ctrl);
+		data = ctrl;
+		if (!(val & PHY_AUTO_NEG_ENABLE))
+			data |= PORT_AUTO_NEG_DISABLE;
+		else
+			data &= ~PORT_AUTO_NEG_DISABLE;
+
+		/* Fiber port does not support auto-negotiation. */
+		if (dev->ports[p].fiber)
+			data |= PORT_AUTO_NEG_DISABLE;
+		if (val & PHY_SPEED_100MBIT)
+			data |= PORT_FORCE_100_MBIT;
+		else
+			data &= ~PORT_FORCE_100_MBIT;
+		if (val & PHY_FULL_DUPLEX)
+			data |= PORT_FORCE_FULL_DUPLEX;
+		else
+			data &= ~PORT_FORCE_FULL_DUPLEX;
+		if (data != ctrl)
+			ksz_pwrite8(dev, p, P_FORCE_CTRL, data);
+		ksz_pread8(dev, p, P_NEG_RESTART_CTRL, &restart);
+		data = restart;
+		if (val & PHY_LED_DISABLE)
+			data |= PORT_LED_OFF;
+		else
+			data &= ~PORT_LED_OFF;
+		if (val & PHY_TRANSMIT_DISABLE)
+			data |= PORT_TX_DISABLE;
+		else
+			data &= ~PORT_TX_DISABLE;
+		if (val & PHY_AUTO_NEG_RESTART)
+			data |= PORT_AUTO_NEG_RESTART;
+		else
+			data &= ~(PORT_AUTO_NEG_RESTART);
+		if (val & PHY_POWER_DOWN)
+			data |= PORT_POWER_DOWN;
+		else
+			data &= ~PORT_POWER_DOWN;
+		if (val & PHY_AUTO_MDIX_DISABLE)
+			data |= PORT_AUTO_MDIX_DISABLE;
+		else
+			data &= ~PORT_AUTO_MDIX_DISABLE;
+		if (val & PHY_FORCE_MDIX)
+			data |= PORT_FORCE_MDIX;
+		else
+			data &= ~PORT_FORCE_MDIX;
+		if (val & PHY_LOOPBACK)
+			data |= PORT_PHY_LOOPBACK;
+		else
+			data &= ~PORT_PHY_LOOPBACK;
+		if (data != restart)
+			ksz_pwrite8(dev, p, P_NEG_RESTART_CTRL, data);
+		break;
+	case PHY_REG_AUTO_NEGOTIATION:
+		ksz_pread8(dev, p, P_LOCAL_CTRL, &ctrl);
+		data = ctrl;
+		data &= ~(PORT_AUTO_NEG_SYM_PAUSE |
+			PORT_AUTO_NEG_100BTX_FD |
+			PORT_AUTO_NEG_100BTX |
+			PORT_AUTO_NEG_10BT_FD |
+			PORT_AUTO_NEG_10BT);
+		if (val & PHY_AUTO_NEG_SYM_PAUSE)
+			data |= PORT_AUTO_NEG_SYM_PAUSE;
+		if (val & PHY_AUTO_NEG_100BTX_FD)
+			data |= PORT_AUTO_NEG_100BTX_FD;
+		if (val & PHY_AUTO_NEG_100BTX)
+			data |= PORT_AUTO_NEG_100BTX;
+		if (val & PHY_AUTO_NEG_10BT_FD)
+			data |= PORT_AUTO_NEG_10BT_FD;
+		if (val & PHY_AUTO_NEG_10BT)
+			data |= PORT_AUTO_NEG_10BT;
+		if (data != ctrl)
+			ksz_pwrite8(dev, p, P_LOCAL_CTRL, data);
+		break;
+	default:
+		break;
+	}
+}
+
+static int ksz_phy_read16(struct dsa_switch *ds, int addr, int reg)
+{
+	struct ksz_device *dev = ds->priv;
+	u16 val = 0xffff;
+
+	ksz_r_phy(dev, addr, reg, &val);
+
+	return val;
+}
+
+static int ksz_phy_write16(struct dsa_switch *ds, int addr, int reg, u16 val)
+{
+	struct ksz_device *dev = ds->priv;
+
+	ksz_w_phy(dev, addr, reg, val);
+
+	return 0;
+}
+
+static int ksz_sset_count(struct dsa_switch *ds)
+{
+	return TOTAL_SWITCH_COUNTER_NUM;
+}
+
+static void ksz_get_strings(struct dsa_switch *ds, int port, uint8_t *buf)
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
+	struct ksz_port_mib *mib;
+	struct ksz_port_mib_info *info;
+	int i;
+
+	mib = &dev->ports[port].mib;
+
+	spin_lock(&dev->mib_read_lock);
+	for (i = 0; i < TOTAL_SWITCH_COUNTER_NUM; i++) {
+		info = &mib->info[i];
+		buf[i] = info->counter;
+		info->read_cnt += info->read_max;
+	}
+	spin_unlock(&dev->mib_read_lock);
+
+	mib->ctrl = 1;
+	schedule_work(&dev->mib_read);
+}
+
+static u8 STP_MULTICAST_ADDR[] = {
+	0x01, 0x80, 0xC2, 0x00, 0x00, 0x00
+};
+
+static void ksz_cfg_port_member(struct ksz_device *dev, int port, u8 member)
+{
+	u8 data;
+
+	ksz_pread8(dev, port, P_MIRROR_CTRL, &data);
+	data &= ~PORT_VLAN_MEMBERSHIP;
+	data |= (member & dev->PORT_MASK);
+	ksz_pwrite8(dev, port, P_MIRROR_CTRL, data);
+	dev->ports[port].member = member;
+}
+
+static void ksz_update_port_member(struct ksz_device *dev, int port)
+{
+	struct ksz_port *p;
+	int i;
+
+	for (i = 0; i < dev->port_cnt; i++) {
+		if (i == port)
+			continue;
+		p = &dev->ports[i];
+		if (!(dev->member & (1 << i)))
+			continue;
+
+		/* Port is a member of the bridge and is forwarding. */
+		if (p->stp_state == BR_STATE_FORWARDING)
+			ksz_cfg_port_member(dev, i, dev->member);
+	}
+}
+
+static int ksz_port_bridge_join(struct dsa_switch *ds, int port,
+				struct net_device *br)
+{
+	struct ksz_device *dev = ds->priv;
+
+	dev->br_member |= (1 << port);
+
+	/**
+	 * port_stp_state_set() will be called after to put the port in
+	 * appropriate state so there is no need to do anything.
+	 */
+
+	return 0;
+}
+
+static void ksz_port_bridge_leave(struct dsa_switch *ds, int port,
+				  struct net_device *br)
+{
+	struct ksz_device *dev = ds->priv;
+
+	dev->br_member &= ~(1 << port);
+	dev->member &= ~(1 << port);
+
+	/**
+	 * port_stp_state_set() will be called after to put the port in
+	 * forwarding state so there is no need to do anything.
+	 */
+}
+
+static void ksz_port_stp_state_set(struct dsa_switch *ds, int port, u8 state)
+{
+	struct ksz_device *dev = ds->priv;
+	struct ksz_port *p = &dev->ports[port];
+	u8 data;
+	u16 forward = dev->member;
+	int member = -1;
+
+	ksz_pread8(dev, port, P_STP_CTRL, &data);
+	data &= ~(PORT_TX_ENABLE | PORT_RX_ENABLE | PORT_LEARN_DISABLE);
+
+	switch (state) {
+	case BR_STATE_DISABLED:
+		data |= PORT_LEARN_DISABLE;
+		if (port < SWITCH_PORT_NUM)
+			member = 0;
+		break;
+	case BR_STATE_LISTENING:
+		data |= (PORT_RX_ENABLE | PORT_LEARN_DISABLE);
+		if (port < SWITCH_PORT_NUM &&
+		    p->stp_state == BR_STATE_DISABLED)
+			member = dev->HOST_MASK | p->vid_member;
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
+			member = dev->HOST_MASK | p->vid_member;
+		}
+		break;
+	case BR_STATE_BLOCKING:
+		data |= PORT_LEARN_DISABLE;
+		if (port < SWITCH_PORT_NUM &&
+		    p->stp_state == BR_STATE_DISABLED)
+			member = dev->HOST_MASK | p->vid_member;
+		break;
+	default:
+		dev_err(ds->dev, "invalid STP state: %d\n", state);
+		return;
+	}
+
+	ksz_pwrite8(dev, port, P_STP_CTRL, data);
+	p->stp_state = state;
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
+		ksz_cfg_port_member(dev, port, (u8)member);
+
+	/* Check if forwarding needs to be updated. */
+	if (state != BR_STATE_FORWARDING) {
+		if (dev->br_member & (1 << port))
+			dev->member &= ~(1 << port);
+	}
+
+	/* Topology is changed. */
+	if (forward != dev->member)
+		ksz_update_port_member(dev, port);
+}
+
+static void ksz_flush_dyn_mac_table(struct ksz_device *dev, int port)
+{
+	int cnt;
+	int first;
+	int index;
+	int last;
+	u8 learn[TOTAL_PORT_NUM];
+
+	if ((uint)port < TOTAL_PORT_NUM) {
+		first = port;
+		cnt = port + 1;
+	} else {
+		/* Flush all ports. */
+		first = 0;
+		cnt = dev->mib_port_cnt;
+	}
+	for (index = first; index < cnt; index++) {
+		last = chk_last_port(dev, index);
+		if (last != index)
+			continue;
+		ksz_pread8(dev, index, P_STP_CTRL, &learn[index]);
+		if (!(learn[index] & PORT_LEARN_DISABLE))
+			ksz_pwrite8(dev, index, P_STP_CTRL,
+				    learn[index] | PORT_LEARN_DISABLE);
+	}
+	ksz_cfg(dev, S_FLUSH_TABLE_CTRL, SW_FLUSH_DYN_MAC_TABLE, true);
+	for (index = first; index < cnt; index++) {
+		last = chk_last_port(dev, index);
+		if (last != index)
+			continue;
+		ksz_pwrite8(dev, index, P_STP_CTRL, learn[index]);
+	}
+}
+
+static void ksz_port_fast_age(struct dsa_switch *ds, int port)
+{
+	struct ksz_device *dev = ds->priv;
+
+	ksz_flush_dyn_mac_table(dev, port);
+}
+
+static int ksz_port_vlan_filtering(struct dsa_switch *ds, int port, bool flag)
+{
+	struct ksz_device *dev = ds->priv;
+
+	ksz_cfg(dev, S_MIRROR_CTRL, SW_VLAN_ENABLE, flag);
+
+	return 0;
+}
+
+static int ksz_port_vlan_prepare(struct dsa_switch *ds, int port,
+				 const struct switchdev_obj_port_vlan *vlan,
+				 struct switchdev_trans *trans)
+{
+	/* nothing needed */
+
+	return 0;
+}
+
+static void ksz_port_vlan_add(struct dsa_switch *ds, int port,
+			      const struct switchdev_obj_port_vlan *vlan,
+			      struct switchdev_trans *trans)
+{
+	struct ksz_device *dev = ds->priv;
+	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
+	u16 data;
+	u16 vid;
+	u8 fid;
+	u8 member;
+	u8 valid;
+	u16 new_pvid = 0;
+
+	ksz_port_cfg(dev, port, P_TAG_CTRL, PORT_REMOVE_TAG, untagged);
+
+	for (vid = vlan->vid_begin; vid <= vlan->vid_end; vid++) {
+		ksz_r_vlan_table(dev, vid, &data);
+		from_vlan(data, &fid, &member, &valid);
+
+		/* First time to setup the VLAN entry. */
+		if (!valid) {
+			/* Need to find a way to map VID to FID. */
+			fid = 1;
+			valid = 1;
+		}
+		member |= BIT(port);
+
+		to_vlan(fid, member, valid, &data);
+		ksz_w_vlan_table(dev, vid, data);
+
+		/* change PVID */
+		if (vlan->flags & BRIDGE_VLAN_INFO_PVID)
+			new_pvid = vid;
+	}
+
+	if (new_pvid) {
+		ksz_pread16(dev, port, REG_PORT_CTRL_VID, &vid);
+		vid &= 0xfff;
+		vid |= new_pvid;
+		ksz_pwrite16(dev, port, REG_PORT_CTRL_VID, vid);
+	}
+}
+
+static int ksz_port_vlan_del(struct dsa_switch *ds, int port,
+			     const struct switchdev_obj_port_vlan *vlan)
+{
+	struct ksz_device *dev = ds->priv;
+	bool untagged = vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
+	u16 data;
+	u16 vid;
+	u16 pvid;
+	u8 fid;
+	u8 member;
+	u8 valid;
+	u16 new_pvid = 0;
+
+	ksz_pread16(dev, port, REG_PORT_CTRL_VID, &pvid);
+	pvid = pvid & 0xFFF;
+
+	ksz_port_cfg(dev, port, P_TAG_CTRL, PORT_REMOVE_TAG, untagged);
+
+	for (vid = vlan->vid_begin; vid <= vlan->vid_end; vid++) {
+		ksz_r_vlan_table(dev, vid, &data);
+		from_vlan(data, &fid, &member, &valid);
+
+		member &= ~BIT(port);
+
+		/* Invalidate the entry if no more member. */
+		if (!member) {
+			fid = 0;
+			valid = 0;
+		}
+
+		if (pvid == vid)
+			new_pvid = 1;
+
+		to_vlan(fid, member, valid, &data);
+		ksz_w_vlan_table(dev, vid, data);
+	}
+
+	if (new_pvid != pvid)
+		ksz_pwrite16(dev, port, REG_PORT_CTRL_VID, pvid);
+
+	return 0;
+}
+
+static int ksz_port_fdb_dump(struct dsa_switch *ds, int port,
+			     dsa_fdb_dump_cb_t *cb, void *data)
+{
+	struct ksz_device *dev = ds->priv;
+	int ret = 0;
+	u16 i = 0;
+	u16 entries = 0;
+	u8 timestamp = 0;
+	u8 fid;
+	u8 member;
+	struct alu_struct alu;
+
+	mutex_lock(&dev->alu_mutex);
+	do {
+		alu.is_static = false;
+		ret = ksz_r_dyn_mac_table(dev, i, alu.mac, &fid, &member,
+					  &timestamp, &entries);
+		if (!ret && (member & BIT(port))) {
+			ret = cb(alu.mac, alu.fid, alu.is_static, data);
+			if (ret)
+				break;
+		}
+		i++;
+	} while (i < entries);
+	mutex_unlock(&dev->alu_mutex);
+	if (i >= entries)
+		ret = 0;
+
+	return ret;
+}
+
+static int ksz_port_mdb_prepare(struct dsa_switch *ds, int port,
+				const struct switchdev_obj_port_mdb *mdb,
+				struct switchdev_trans *trans)
+{
+	/* nothing to do */
+	return 0;
+}
+
+static void ksz_port_mdb_add(struct dsa_switch *ds, int port,
+			     const struct switchdev_obj_port_mdb *mdb,
+			     struct switchdev_trans *trans)
+{
+	struct ksz_device *dev = ds->priv;
+	struct alu_struct alu;
+	int index;
+	int empty = 0;
+
+	mutex_lock(&dev->alu_mutex);
+
+	for (index = 0; index < dev->num_statics; index++) {
+		if (!ksz_r_sta_mac_table(dev, index, &alu)) {
+			/* Found one already in static MAC table. */
+			if (!memcmp(alu.mac, mdb->addr, ETH_ALEN) &&
+			    alu.fid == mdb->vid)
+				break;
+		/* Remember the first empty entry. */
+		} else if (!empty) {
+			empty = index + 1;
+		}
+	}
+
+	/* no available entry */
+	if (index == dev->num_statics && !empty)
+		goto exit;
+
+	/* add entry */
+	if (index == dev->num_statics) {
+		index = empty - 1;
+		memset(&alu, 0, sizeof(alu));
+		memcpy(alu.mac, mdb->addr, ETH_ALEN);
+		alu.is_static = true;
+	}
+	alu.port_forward |= BIT(port);
+	if (mdb->vid) {
+		alu.is_use_fid = true;
+
+		/* Need a way to map VID to FID. */
+		alu.fid = mdb->vid;
+	}
+	ksz_w_sta_mac_table(dev, index, &alu);
+
+exit:
+	mutex_unlock(&dev->alu_mutex);
+}
+
+static int ksz_port_mdb_del(struct dsa_switch *ds, int port,
+			    const struct switchdev_obj_port_mdb *mdb)
+{
+	struct ksz_device *dev = ds->priv;
+	struct alu_struct alu;
+	int index;
+	int ret = 0;
+
+	mutex_lock(&dev->alu_mutex);
+
+	for (index = 0; index < dev->num_statics; index++) {
+		if (!ksz_r_sta_mac_table(dev, index, &alu)) {
+			/* Found one already in static MAC table. */
+			if (!memcmp(alu.mac, mdb->addr, ETH_ALEN) &&
+			    alu.fid == mdb->vid)
+				break;
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
+	alu.port_forward &= ~BIT(port);
+	if (!alu.port_forward)
+		alu.is_static = false;
+	ksz_w_sta_mac_table(dev, index, &alu);
+
+exit:
+	mutex_unlock(&dev->alu_mutex);
+
+	return ret;
+}
+
+static int ksz_port_mirror_add(struct dsa_switch *ds, int port,
+			       struct dsa_mall_mirror_tc_entry *mirror,
+			       bool ingress)
+{
+	struct ksz_device *dev = ds->priv;
+
+	if (ingress) {
+		ksz_port_cfg(dev, port, P_MIRROR_CTRL, PORT_MIRROR_RX, true);
+		dev->mirror_rx |= (1 << port);
+	} else {
+		ksz_port_cfg(dev, port, P_MIRROR_CTRL, PORT_MIRROR_TX, true);
+		dev->mirror_tx |= (1 << port);
+	}
+
+	ksz_port_cfg(dev, port, P_MIRROR_CTRL, PORT_MIRROR_SNIFFER, false);
+
+	/* configure mirror port */
+	if (dev->mirror_rx || dev->mirror_tx)
+		ksz_port_cfg(dev, mirror->to_local_port, P_MIRROR_CTRL,
+			     PORT_MIRROR_SNIFFER, true);
+
+	return 0;
+}
+
+static void ksz_port_mirror_del(struct dsa_switch *ds, int port,
+				struct dsa_mall_mirror_tc_entry *mirror)
+{
+	struct ksz_device *dev = ds->priv;
+	u8 data;
+
+	if (mirror->ingress) {
+		ksz_port_cfg(dev, port, P_MIRROR_CTRL, PORT_MIRROR_RX, false);
+		dev->mirror_rx &= ~(1 << port);
+	} else {
+		ksz_port_cfg(dev, port, P_MIRROR_CTRL, PORT_MIRROR_TX, false);
+		dev->mirror_tx &= ~(1 << port);
+	}
+
+	ksz_pread8(dev, port, P_MIRROR_CTRL, &data);
+
+	if (!dev->mirror_rx && !dev->mirror_tx)
+		ksz_port_cfg(dev, mirror->to_local_port, P_MIRROR_CTRL,
+			     PORT_MIRROR_SNIFFER, false);
+}
+
+static u8 ksz_advertised_flow_ctrl(u8 flow_ctrl, u8 ctrl)
+{
+	ctrl &= ~PORT_AUTO_NEG_SYM_PAUSE;
+	switch (flow_ctrl) {
+	case PHY_FLOW_CTRL:
+		ctrl |= PORT_AUTO_NEG_SYM_PAUSE;
+		break;
+
+	/* Not supported. */
+	case PHY_TX_ONLY:
+	case PHY_RX_ONLY:
+	default:
+		break;
+	}
+	return ctrl;
+}
+
+static u8 ksz_determine_flow_ctrl(u8 local, u8 remote, int force)
+{
+	int rx;
+	int tx;
+	u8 flow = 0;
+
+	rx = 0;
+	tx = 0;
+	if (force) {
+		rx = 1;
+		tx = 1;
+	}
+	if (remote & PORT_REMOTE_SYM_PAUSE) {
+		if (local & PORT_AUTO_NEG_SYM_PAUSE) {
+			rx = 1;
+			tx = 1;
+		}
+	}
+	if (rx)
+		flow |= 0x01;
+	if (tx)
+		flow |= 0x02;
+	return flow;
+}
+
+static void port_get_link_speed(struct ksz_device *dev, int port)
+{
+	struct ksz_port *p = &dev->ports[port];
+	u8 data;
+	u8 link;
+	u8 local;
+	u8 remote;
+	u8 status;
+
+	ksz_pread8(dev, port, P_LOCAL_CTRL, &local);
+	ksz_pread8(dev, port, P_REMOTE_STATUS, &remote);
+	ksz_pread8(dev, port, P_SPEED_STATUS, &status);
+	ksz_pread8(dev, port, P_LINK_STATUS, &data);
+
+	/**
+	 * The partner capability register is updated but the
+	 * auto-negotiation is not completed yet.
+	 */
+	link = data & (PORT_AUTO_NEG_COMPLETE | PORT_STAT_LINK_GOOD);
+	link |= status & (PORT_STAT_SPEED_100MBIT | PORT_STAT_FULL_DUPLEX);
+
+	if (local == p->advertised && link == p->link)
+		return;
+
+	if (data & PORT_STAT_LINK_GOOD) {
+		p->speed = SPEED_10;
+		if (status & PORT_STAT_SPEED_100MBIT)
+			p->speed = SPEED_100;
+		p->duplex = 1;
+		if (status & PORT_STAT_FULL_DUPLEX)
+			p->duplex = 2;
+		ksz_port_cfg(dev, port, P_STP_CTRL, PORT_BACK_PRESSURE,
+			     p->duplex == 1);
+		p->flow_ctrl = ksz_determine_flow_ctrl(local, remote,
+						       p->force);
+		if (status & PORT_RX_FLOW_CTRL)
+			p->flow_ctrl |= 0x10;
+		if (status & PORT_TX_FLOW_CTRL)
+			p->flow_ctrl |= 0x20;
+		p->link_up = 1;
+		dev->live_ports |= (1 << port) & dev->on_ports;
+	} else if (p->link_up) {
+		p->link_up = 0;
+		p->link_down = 1;
+		dev->live_ports &= ~(1 << port);
+	}
+	p->advertised = local;
+	p->partner = remote;
+	p->link = link;
+}
+
+static void port_set_link_speed(struct ksz_device *dev, int port, int speed,
+				int duplex)
+{
+	struct ksz_port *p = &dev->ports[port];
+	u8 adv;
+	u8 cfg;
+	u8 data;
+	u8 local;
+	u8 status;
+
+	if (p->fiber)
+		return;
+
+	ksz_pread8(dev, port, P_LOCAL_CTRL, &local);
+	ksz_pread8(dev, port, P_LINK_STATUS, &status);
+	ksz_pread8(dev, port, P_FORCE_CTRL, &data);
+
+	adv = 0;
+	cfg = 0;
+	if (status & PORT_STAT_LINK_GOOD) {
+		cfg = data;
+		adv = local;
+	}
+
+	data &= ~PORT_AUTO_NEG_DISABLE;
+	local = ksz_advertised_flow_ctrl(PHY_FLOW_CTRL, local);
+
+	local |= PORT_AUTO_NEG_100BTX_FD | PORT_AUTO_NEG_100BTX |
+		 PORT_AUTO_NEG_10BT_FD | PORT_AUTO_NEG_10BT;
+
+	if (speed || duplex) {
+		if (speed == SPEED_10)
+			local &= ~(PORT_AUTO_NEG_100BTX_FD |
+				   PORT_AUTO_NEG_100BTX);
+		else if (speed == SPEED_100)
+			local &= ~(PORT_AUTO_NEG_10BT_FD |
+				   PORT_AUTO_NEG_10BT);
+		if (duplex == 1)
+			local &= ~(PORT_AUTO_NEG_100BTX_FD |
+				   PORT_AUTO_NEG_10BT_FD);
+		else if (duplex == 2)
+			local &= ~(PORT_AUTO_NEG_100BTX |
+				   PORT_AUTO_NEG_10BT);
+	}
+	if (data != cfg || local != adv) {
+		ksz_pwrite8(dev, port, P_FORCE_CTRL, data);
+		ksz_pwrite8(dev, port, P_LOCAL_CTRL, local);
+		ksz_pread8(dev, port, P_NEG_RESTART_CTRL, &data);
+		data |= PORT_AUTO_NEG_RESTART;
+		ksz_pwrite8(dev, port, P_NEG_RESTART_CTRL, data);
+
+		/* Link is going down. */
+		if (p->link_up)
+			p->link_down = 1;
+		p->link_up = 0;
+	}
+	p->force = 0;
+}
+
+static void port_force_link_speed(struct ksz_device *dev, int port, int speed,
+				  int duplex)
+{
+	struct ksz_port *p = &dev->ports[port];
+	u8 data;
+
+	ksz_pread8(dev, port, P_FORCE_CTRL, &data);
+	data |= PORT_AUTO_NEG_DISABLE;
+	if (speed == SPEED_10)
+		data &= ~PORT_FORCE_100_MBIT;
+	else
+		data |= PORT_FORCE_100_MBIT;
+	if (duplex == 1)
+		data &= ~PORT_FORCE_FULL_DUPLEX;
+	else
+		data |= PORT_FORCE_FULL_DUPLEX;
+	ksz_pwrite8(dev, port, P_FORCE_CTRL, data);
+	p->force = 1;
+}
+
+static void ksz_mib_read_work(struct work_struct *work)
+{
+	struct ksz_device *dev =
+		container_of(work, struct ksz_device, mib_read);
+	struct ksz_port *p;
+	struct ksz_port_mib *mib;
+	struct ksz_port_mib_info *info;
+	int i;
+	unsigned long next_jiffies;
+
+	/**
+	 * Want to read MIB counters from all ports every second and spread
+	 * the register reading around so that this very low priority
+	 * operation does not affect critical register access like PTP or
+	 * interrupt.  In fact the MIB counter reading may stop when an
+	 * interrupt is triggered.
+	 */
+	next_jiffies = jiffies + dev->MIB_READ_INTERVAL * dev->mib_port_cnt;
+	for (i = 0; i < dev->mib_port_cnt; i++) {
+		p = &dev->ports[i];
+		mib = &p->mib;
+		if (mib->cnt_ptr || 1 == mib->ctrl) {
+			if (port_r_cnt(dev, i))
+				break;
+			mib->ctrl = 0;
+
+			if (mib->cnt_ptr == 0)
+				mib->ctrl = 2;
+		} else if (time_is_before_eq_jiffies(mib->time) &&
+			   (dev->live_ports & (1 << i))) {
+			mib->ctrl = 1;
+			mib->time = next_jiffies;
+			next_jiffies += dev->MIB_READ_INTERVAL;
+		} else if (p->link_down) {
+			int j;
+
+			spin_lock(&dev->mib_read_lock);
+			for (j = 0; j < TOTAL_SWITCH_COUNTER_NUM; j++) {
+				info = &mib->info[j];
+				info->read_cnt += info->read_max;
+			}
+			spin_unlock(&dev->mib_read_lock);
+			p->link_down = 0;
+
+			/* Read counters one last time after link is lost. */
+			mib->ctrl = 1;
+		}
+	}
+	do {
+		u8 intr_status;
+
+		ksz_read8(dev, REG_INT_STATUS, &intr_status);
+		intr_status &= ~INT_PME;
+		if (!intr_status)
+			break;
+		ksz_write8(dev, REG_INT_STATUS, intr_status);
+		for (i = 0; i < dev->port_cnt; i++)
+			port_get_link_speed(dev, i);
+	} while (0);
+}
+
+static void mib_monitor(unsigned long ptr)
+{
+	struct ksz_device *dev = (struct ksz_device *)ptr;
+
+	mod_timer(&dev->mib_read_timer, jiffies + dev->MIB_READ_INTERVAL);
+	schedule_work(&dev->mib_read);
+}
+
+static void port_setup(struct ksz_device *dev, int port, bool cpu_port)
+{
+	u8 data8;
+	u8 member;
+	struct ksz_port *p = &dev->ports[port];
+
+	/* enable broadcast storm limit */
+	ksz_port_cfg(dev, port, P_BCAST_STORM_CTRL, PORT_BROADCAST_STORM, true);
+
+	port_set_prio_queue(dev, port, 4);
+
+	/* disable DiffServ priority */
+	ksz_port_cfg(dev, port, P_PRIO_CTRL, PORT_DIFFSERV_ENABLE, false);
+
+	/* replace priority */
+	ksz_port_cfg(dev, port, P_802_1P_CTRL, PORT_802_1P_REMAPPING, false);
+
+	/* enable 802.1p priority */
+	ksz_port_cfg(dev, port, P_PRIO_CTRL, PORT_802_1P_ENABLE, true);
+
+	if (cpu_port) {
+		/* Configure MII interface for proper network communication. */
+		ksz_read8(dev, REG_PORT_5_CTRL_6, &data8);
+		data8 &= ~PORT_INTERFACE_TYPE;
+		data8 &= ~PORT_GMII_1GPS_MODE;
+		switch (dev->interface) {
+		case PHY_INTERFACE_MODE_MII:
+			break;
+		case PHY_INTERFACE_MODE_RMII:
+			data8 |= PORT_INTERFACE_RMII;
+			break;
+		case PHY_INTERFACE_MODE_GMII:
+			data8 |= PORT_GMII_1GPS_MODE;
+			data8 |= PORT_INTERFACE_GMII;
+			break;
+		default:
+			data8 &= ~PORT_RGMII_ID_IN_ENABLE;
+			data8 &= ~PORT_RGMII_ID_OUT_ENABLE;
+			if (dev->interface == PHY_INTERFACE_MODE_RGMII_ID ||
+			    dev->interface == PHY_INTERFACE_MODE_RGMII_RXID)
+				data8 |= PORT_RGMII_ID_IN_ENABLE;
+			if (dev->interface == PHY_INTERFACE_MODE_RGMII_ID ||
+			    dev->interface == PHY_INTERFACE_MODE_RGMII_TXID)
+				data8 |= PORT_RGMII_ID_OUT_ENABLE;
+			data8 |= PORT_GMII_1GPS_MODE;
+			data8 |= PORT_INTERFACE_RGMII;
+			break;
+		}
+		ksz_write8(dev, REG_PORT_5_CTRL_6, data8);
+
+		member = dev->PORT_MASK;
+		dev->on_ports = dev->HOST_MASK;
+		dev->live_ports = dev->HOST_MASK;
+	} else {
+		member = dev->HOST_MASK | p->vid_member;
+		dev->on_ports |= (1 << port);
+
+		/* Link was detected before port is enabled. */
+		if (p->link_up)
+			dev->live_ports |= (1 << port);
+	}
+	ksz_cfg_port_member(dev, port, member);
+}
+
+static void ksz_config_cpu_port(struct dsa_switch *ds)
+{
+	struct ksz_device *dev = ds->priv;
+	struct ksz_port *p;
+	int i;
+	u8 remote;
+
+	ds->num_ports = dev->port_cnt + 1;
+
+	/* Switch marks the maximum frame with extra byte as oversize. */
+	ksz_cfg(dev, REG_SW_CTRL_2, SW_LEGAL_PACKET_DISABLE, true);
+	ksz_cfg(dev, S_TAIL_TAG_CTRL, SW_TAIL_TAG_ENABLE, true);
+
+	p = &dev->ports[dev->cpu_port];
+	p->vid_member = dev->PORT_MASK;
+	p->on = 1;
+
+	port_setup(dev, dev->cpu_port, true);
+	dev->member = dev->HOST_MASK;
+
+	for (i = 0; i < SWITCH_PORT_NUM; i++) {
+		p = &dev->ports[i];
+
+		/**
+		 * Initialize to non-zero so that ksz_cfg_port_member() will
+		 * be called.
+		 */
+		p->vid_member = (1 << i);
+		p->member = dev->PORT_MASK;
+		ksz_port_stp_state_set(ds, i, BR_STATE_DISABLED);
+		if (i == dev->port_cnt)
+			break;
+		p->on = 1;
+	}
+	for (i = 0; i < dev->port_cnt; i++) {
+		p = &dev->ports[i];
+		if (!p->on)
+			continue;
+		ksz_pread8(dev, i, P_REMOTE_STATUS, &remote);
+		if (remote & PORT_FIBER_MODE)
+			p->fiber = 1;
+		port_get_link_speed(dev, i);
+		if (p->fiber) {
+			ksz_port_cfg(dev, i, P_STP_CTRL, PORT_FORCE_FLOW_CTRL,
+				     true);
+			port_force_link_speed(dev, i, 100, 2);
+		} else {
+			u8 data;
+
+			ksz_port_cfg(dev, i, P_STP_CTRL, PORT_FORCE_FLOW_CTRL,
+				     false);
+			ksz_pread8(dev, i, P_FORCE_CTRL, &data);
+			data &= ~PORT_FORCE_FULL_DUPLEX;
+			ksz_pwrite8(dev, i, P_FORCE_CTRL, data);
+			port_set_link_speed(dev, i, 0, 0);
+		}
+	}
+}
+
+static int ksz_enable_port(struct dsa_switch *ds, int port,
+			   struct phy_device *phy)
+{
+	struct ksz_device *dev = ds->priv;
+
+	/* setup slave port */
+	port_setup(dev, port, false);
+
+	/**
+	 * port_stp_state_set() will be called after to enable the port so
+	 * there is no need to do anything.
+	 */
+
+	return 0;
+}
+
+static void ksz_disable_port(struct dsa_switch *ds, int port,
+			     struct phy_device *phy)
+{
+	struct ksz_device *dev = ds->priv;
+
+	dev->on_ports &= ~(1 << port);
+	dev->live_ports &= ~(1 << port);
+
+	/**
+	 * port_stp_state_set() will be called after to disable the port so
+	 * there is no need to do anything.
+	 */
+}
+
+static int ksz_set_addr(struct dsa_switch *ds, u8 *addr)
+{
+	struct ksz_device *dev = ds->priv;
+
+	mutex_lock(&dev->reg_mutex);
+	dev->ops->set(dev, REG_SW_MAC_ADDR_0, addr, ETH_ALEN);
+	mutex_unlock(&dev->reg_mutex);
+
+	return 0;
+}
+
+static int ksz_setup(struct dsa_switch *ds)
+{
+	u8 data8;
+	u16 data16;
+	u32 value;
+	int i;
+	struct alu_struct alu;
+	struct ksz_device *dev = ds->priv;
+	int ret = 0;
+
+	dev->vlan_cache = devm_kcalloc(dev->dev, sizeof(struct vlan_table),
+				       dev->num_vlans, GFP_KERNEL);
+	if (!dev->vlan_cache)
+		return -ENOMEM;
+
+	ret = ksz_reset_switch(dev);
+	if (ret) {
+		dev_err(ds->dev, "failed to reset switch\n");
+		return ret;
+	}
+
+	spin_lock_init(&dev->mib_read_lock);
+	INIT_WORK(&dev->mib_read, ksz_mib_read_work);
+	setup_timer(&dev->mib_read_timer, mib_monitor, (unsigned long)dev);
+
+	ksz_cfg(dev, S_REPLACE_VID_CTRL, SW_FLOW_CTRL, true);
+
+	/* Enable automatic fast aging when link changed detected. */
+	ksz_cfg(dev, S_LINK_AGING_CTRL, SW_LINK_AUTO_AGING, true);
+
+	ksz_read8(dev, REG_SW_CTRL_1, &data8);
+
+	/* Enable aggressive back off algorithm in half duplex mode. */
+	data8 |= SW_AGGR_BACKOFF;
+	ksz_write8(dev, REG_SW_CTRL_1, data8);
+
+	ksz_read8(dev, REG_SW_CTRL_2, &data8);
+
+	/* Make sure unicast VLAN boundary is set as default. */
+	data8 |= UNICAST_VLAN_BOUNDARY;
+
+	/* Enable no excessive collision drop. */
+	data8 |= NO_EXC_COLLISION_DROP;
+	ksz_write8(dev, REG_SW_CTRL_2, data8);
+
+	ksz_config_cpu_port(ds);
+
+	ksz_cfg(dev, REG_SW_CTRL_2, MULTICAST_STORM_DISABLE, true);
+
+	ksz_cfg(dev, S_REPLACE_VID_CTRL, SW_REPLACE_VID, false);
+
+	ksz_cfg(dev, S_MIRROR_CTRL, SW_MIRROR_RX_TX, false);
+
+	/* set broadcast storm protection 10% rate */
+	data8 = BROADCAST_STORM_PROT_RATE;
+	value = ((u32)BROADCAST_STORM_VALUE * data8) / 100;
+	if (value > BROADCAST_STORM_RATE)
+		value = BROADCAST_STORM_RATE;
+	ksz_read16(dev, S_REPLACE_VID_CTRL, &data16);
+	data16 &= ~BROADCAST_STORM_RATE;
+	data16 |= value;
+	ksz_write16(dev, S_REPLACE_VID_CTRL, data16);
+
+	for (i = 0; i < VLAN_TABLE_ENTRIES; i++)
+		ksz_r_vlan_entries(dev, i);
+
+	for (i = 0; i < dev->mib_port_cnt; i++)
+		port_init_cnt(dev, i);
+
+	/* Setup STP address for STP operation. */
+	memset(&alu, 0, sizeof(alu));
+	memcpy(alu.mac, STP_MULTICAST_ADDR, ETH_ALEN);
+	alu.is_static = true;
+	alu.is_override = true;
+	alu.port_forward = dev->HOST_MASK;
+
+	mutex_lock(&dev->alu_mutex);
+	ksz_w_sta_mac_table(dev, 0, &alu);
+	mutex_unlock(&dev->alu_mutex);
+
+	/* Start the timer 2 seconds later. */
+	dev->mib_read_timer.expires = jiffies + msecs_to_jiffies(2000);
+	add_timer(&dev->mib_read_timer);
+
+	return 0;
+}
+
+static const struct dsa_switch_ops ksz_switch_ops = {
+	.get_tag_protocol	= ksz_get_tag_protocol,
+	.setup			= ksz_setup,
+	.set_addr		= ksz_set_addr,
+	.phy_read		= ksz_phy_read16,
+	.phy_write		= ksz_phy_write16,
+	.port_enable		= ksz_enable_port,
+	.port_disable		= ksz_disable_port,
+	.get_strings		= ksz_get_strings,
+	.get_ethtool_stats	= ksz_get_ethtool_stats,
+	.get_sset_count		= ksz_sset_count,
+	.port_bridge_join	= ksz_port_bridge_join,
+	.port_bridge_leave	= ksz_port_bridge_leave,
+	.port_stp_state_set	= ksz_port_stp_state_set,
+	.port_fast_age		= ksz_port_fast_age,
+	.port_vlan_filtering	= ksz_port_vlan_filtering,
+	.port_vlan_prepare	= ksz_port_vlan_prepare,
+	.port_vlan_add		= ksz_port_vlan_add,
+	.port_vlan_del		= ksz_port_vlan_del,
+	.port_fdb_dump		= ksz_port_fdb_dump,
+	.port_mdb_prepare       = ksz_port_mdb_prepare,
+	.port_mdb_add           = ksz_port_mdb_add,
+	.port_mdb_del           = ksz_port_mdb_del,
+	.port_mirror_add	= ksz_port_mirror_add,
+	.port_mirror_del	= ksz_port_mirror_del,
+};
+
+/* Register access function can be disabled if desired. */
+#if 1
+#define KSZ_REGS_SIZE		0x100
+#endif
+
+#ifdef KSZ_REGS_SIZE
+static ssize_t ksz_registers_read(struct file *filp, struct kobject *kobj,
+				  struct bin_attribute *bin_attr, char *buf,
+				  loff_t off, size_t count)
+{
+	size_t i;
+	u8 reg;
+	struct device *dev;
+	struct ksz_device *swdev;
+
+	if (unlikely(off >= KSZ_REGS_SIZE))
+		return 0;
+
+	if ((off + count) >= KSZ_REGS_SIZE)
+		count = KSZ_REGS_SIZE - off;
+
+	if (unlikely(!count))
+		return count;
+
+	dev = container_of(kobj, struct device, kobj);
+	swdev = dev_get_drvdata(dev);
+
+	reg = off;
+	mutex_lock(&swdev->reg_mutex);
+	i = swdev->ops->get(swdev, reg, buf, count);
+	mutex_unlock(&swdev->reg_mutex);
+	return i;
+}
+
+static ssize_t ksz_registers_write(struct file *filp, struct kobject *kobj,
+				   struct bin_attribute *bin_attr, char *buf,
+				   loff_t off, size_t count)
+{
+	size_t i;
+	u8 reg;
+	struct device *dev;
+	struct ksz_device *swdev;
+
+	if (unlikely(off >= KSZ_REGS_SIZE))
+		return -EFBIG;
+
+	if ((off + count) >= KSZ_REGS_SIZE)
+		count = KSZ_REGS_SIZE - off;
+
+	if (unlikely(!count))
+		return count;
+
+	dev = container_of(kobj, struct device, kobj);
+	swdev = dev_get_drvdata(dev);
+
+	reg = off;
+	mutex_lock(&swdev->reg_mutex);
+	i = swdev->ops->set(swdev, reg, buf, count);
+	mutex_unlock(&swdev->reg_mutex);
+	return i;
+}
+
+static struct bin_attribute ksz_registers_attr = {
+	.attr = {
+		.name	= "registers",
+		.mode	= 00600,
+	},
+	.size	= KSZ_REGS_SIZE,
+	.read	= ksz_registers_read,
+	.write	= ksz_registers_write,
+};
+#endif
+
+static u32 ksz_get_port_addr(int port, int offset)
+{
+	return PORT_CTRL_ADDR(port, offset);
+}
+
+/**
+ * This information needs to be communicated to the MAC driver so that it can
+ * receive the frames correctly from the switch as some MAC drivers adhere to
+ * receive exactly 1518 bytes.
+ */
+static int ksz_get_rx_len(struct ksz_device *dev)
+{
+	return 1;
+}
+
+/**
+ * This information tells how many more bytes need to be allocated to
+ * accommodate the tail tag.
+ */
+static int ksz_get_tx_len(struct ksz_device *dev)
+{
+	return 1;
+}
+
+static void ksz_add_tail_tag(struct ksz_device *dev, struct sk_buff *skb,
+			     int port)
+{
+	u8 *trailer;
+	int len = 1;
+
+	port = 1 << port;
+
+	/* Need override as the port may be transmit disabled. */
+	if (!memcmp(skb->data, STP_MULTICAST_ADDR, ETH_ALEN))
+		port |= TAIL_TAG_OVERRIDE;
+	trailer = skb_put(skb, len);
+	trailer[0] = (u8)port;
+}
+
+static int ksz_get_tail_tag(struct ksz_device *dev, struct sk_buff *skb,
+			    int *port)
+{
+	u8 *trailer;
+	int len = 1;
+
+	trailer = skb_tail_pointer(skb) - len;
+	*port = *trailer;
+	if (*port >= 0 && *port < SWITCH_PORT_NUM) {
+		struct ksz_port *p = &dev->ports[*port];
+
+		/**
+		 * Switch is forwarding when port membership includes other
+		 * ports.
+		 */
+		if (p->member & ~((1 << *port) | dev->HOST_MASK))
+			skb->offload_fwd_mark = 1;
+	}
+	return len;
+}
+
+static int ksz_switch_detect(struct ksz_device *dev)
+{
+	u16 id16;
+	u8 id1;
+	u8 id2;
+	int ret;
+
+	/* read chip id */
+	ret = ksz_read16(dev, REG_CHIP_ID0, &id16);
+	if (ret)
+		return ret;
+
+	id1 = id16 >> 8;
+	id2 = id16 & SW_CHIP_ID_M;
+	if (id1 != FAMILY_ID ||
+	    (id2 != CHIP_ID_94 && id2 != CHIP_ID_95))
+		return -ENODEV;
+
+	dev->mib_port_cnt = TOTAL_PORT_NUM;
+	dev->port_cnt = SWITCH_PORT_NUM;
+
+	if (id2 == CHIP_ID_95) {
+		u8 val;
+
+		id2 = 0x95;
+		ksz_read8(dev, REG_PORT_1_STATUS_0, &val);
+		if (val & PORT_FIBER_MODE)
+			id2 = 0x65;
+	} else if (id2 == CHIP_ID_94) {
+		dev->port_cnt--;
+		dev->last_port = dev->port_cnt;
+		dev->features |= USE_FEWER_PORTS;
+		id2 = 0x94;
+	}
+	id16 &= ~0xff;
+	id16 |= id2;
+	dev->chip_id = id16;
+
+	dev->cpu_port = dev->mib_port_cnt - 1;
+	dev->HOST_MASK = (1 << dev->cpu_port);
+
+	dev->mib_cnt = TOTAL_SWITCH_COUNTER_NUM;
+
+	/* Try to read MIB counters in all ports every second. */
+	dev->MIB_READ_INTERVAL = msecs_to_jiffies(1000 / dev->mib_port_cnt);
+
+	return 0;
+}
+
+struct ksz_chip_data {
+	u16 chip_id;
+	const char *dev_name;
+	int num_vlans;
+	int num_alus;
+	int num_statics;
+	int cpu_ports;
+	int port_cnt;
+};
+
+static const struct ksz_chip_data ksz_switch_chips[] = {
+	{
+		.chip_id = 0x8795,
+		.dev_name = "KSZ8795",
+		.num_vlans = 4096,
+		.num_alus = 0,
+		.num_statics = 8,
+		.cpu_ports = 0x10,	/* can be configured as cpu port */
+		.port_cnt = 4,		/* total physical port count */
+	},
+	{
+		.chip_id = 0x8765,
+		.dev_name = "KSZ8765",
+		.num_vlans = 4096,
+		.num_alus = 0,
+		.num_statics = 8,
+		.cpu_ports = 0x10,	/* can be configured as cpu port */
+		.port_cnt = 4,		/* total physical port count */
+	},
+};
+
+static int ksz_switch_init(struct ksz_device *dev)
+{
+	int i;
+
+	mutex_init(&dev->reg_mutex);
+	mutex_init(&dev->stats_mutex);
+	mutex_init(&dev->alu_mutex);
+	mutex_init(&dev->vlan_mutex);
+
+	dev->ds->ops = &ksz_switch_ops;
+
+	for (i = 0; i < ARRAY_SIZE(ksz_switch_chips); i++) {
+		const struct ksz_chip_data *chip = &ksz_switch_chips[i];
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
+	dev->PORT_MASK = (1 << dev->port_cnt) - 1;
+	dev->PORT_MASK |= dev->HOST_MASK;
+
+	i = dev->mib_port_cnt;
+	dev->ports = devm_kzalloc(dev->dev, sizeof(struct ksz_port) * i,
+				  GFP_KERNEL);
+	if (!dev->ports)
+		return -ENOMEM;
+	for (i = 0; i < dev->mib_port_cnt; i++) {
+		dev->ports[i].mib.info =
+			devm_kzalloc(dev->dev,
+				     sizeof(struct ksz_port_mib_info) *
+				     TOTAL_SWITCH_COUNTER_NUM, GFP_KERNEL);
+		if (!dev->ports[i].mib.info)
+			return -ENOMEM;
+	}
+
+#ifdef KSZ_REGS_SIZE
+	i = sysfs_create_bin_file(&dev->dev->kobj,
+				  &ksz_registers_attr);
+#endif
+
+	return 0;
+}
+
+static void ksz_switch_exit(struct ksz_device *dev)
+{
+	if (dev->mib_read_timer.expires)
+		del_timer_sync(&dev->mib_read_timer);
+
+#ifdef KSZ_REGS_SIZE
+	sysfs_remove_bin_file(&dev->dev->kobj, &ksz_registers_attr);
+#endif
+}
+
+static const struct ksz_dev_ops ksz8795_dev_ops = {
+	.get_port_addr = ksz_get_port_addr,
+	.reset = ksz_reset_switch,
+	.get_rx_len = ksz_get_rx_len,
+	.get_tx_len = ksz_get_tx_len,
+	.add_tail_tag = ksz_add_tail_tag,
+	.get_tail_tag = ksz_get_tail_tag,
+	.detect = ksz_switch_detect,
+	.init = ksz_switch_init,
+	.exit = ksz_switch_exit,
+};
+
+int ksz8795_switch_register(struct ksz_device *dev)
+{
+	return ksz_switch_register(dev, &ksz8795_dev_ops);
+}
+EXPORT_SYMBOL(ksz8795_switch_register);
+
+MODULE_AUTHOR("Tristram Ha <Tristram.Ha@microchip.com>");
+MODULE_DESCRIPTION("Microchip KSZ8795 Series Switch DSA Driver");
+MODULE_LICENSE("GPL");
