From: <Tristram.Ha@microchip.com>
Subject: [PATCH RFC] Add Microchip KSZ8895 DSA driver
Date: Fri, 6 Oct 2017 13:33:53 -0700
Message-ID: <1507322033-15222-2-git-send-email-Tristram.Ha@microchip.com>
References: <1507322033-15222-1-git-send-email-Tristram.Ha@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tristram Ha <Tristram.Ha@microchip.com>, <muvarov@gmail.com>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>,
        <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507322033-15222-1-git-send-email-Tristram.Ha@microchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tristram Ha <Tristram.Ha@microchip.com>

Add Microchip KSZ8895 DSA driver.

Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
---
 drivers/net/dsa/microchip/Kconfig       |   17 +
 drivers/net/dsa/microchip/Makefile      |    2 +
 drivers/net/dsa/microchip/ksz8895.c     | 1288 +++++++++++++++++++++++++++++++
 drivers/net/dsa/microchip/ksz8895_reg.h |  824 ++++++++++++++++++++
 drivers/net/dsa/microchip/ksz8895_spi.c |  157 ++++
 drivers/net/dsa/microchip/ksz_priv.h    |    1 +
 6 files changed, 2289 insertions(+)
 create mode 100644 drivers/net/dsa/microchip/ksz8895.c
 create mode 100644 drivers/net/dsa/microchip/ksz8895_reg.h
 create mode 100644 drivers/net/dsa/microchip/ksz8895_spi.c

diff --git a/drivers/net/dsa/microchip/Kconfig b/drivers/net/dsa/microchip/Kconfig
index cb95d3d..b854c4b 100644
--- a/drivers/net/dsa/microchip/Kconfig
+++ b/drivers/net/dsa/microchip/Kconfig
@@ -27,3 +27,20 @@ config MICROCHIP_KSZ8795_SPI_DRIVER
 
 	  It is required to use the KSZ8795 switch driver as the only access
 	  is through SPI.
+
+menuconfig MICROCHIP_KSZ8895
+	tristate "Microchip KSZ8895 series switch support"
+	depends on NET_DSA
+	select NET_DSA_TAG_KSZ8795
+	help
+	  This driver adds support for Microchip KSZ8895 switch chips.
+
+config MICROCHIP_KSZ8895_SPI_DRIVER
+	tristate "KSZ8895 series SPI connected switch driver"
+	depends on MICROCHIP_KSZ8895 && SPI
+	default y
+	help
+	  This driver accesses KSZ8895 chip through SPI.
+
+	  It is required to use the KSZ8895 switch driver as the only access
+	  is through SPI.
diff --git a/drivers/net/dsa/microchip/Makefile b/drivers/net/dsa/microchip/Makefile
index 99a283e..8dd6312 100644
--- a/drivers/net/dsa/microchip/Makefile
+++ b/drivers/net/dsa/microchip/Makefile
@@ -2,3 +2,5 @@ obj-$(CONFIG_MICROCHIP_KSZ9477)	        += ksz9477.o ksz_common.o
 obj-$(CONFIG_MICROCHIP_KSZ9477_SPI_DRIVER)	+= ksz9477_spi.o
 obj-$(CONFIG_MICROCHIP_KSZ8795)	        += ksz8795.o ksz_common.o
 obj-$(CONFIG_MICROCHIP_KSZ8795_SPI_DRIVER)	+= ksz8795_spi.o
+obj-$(CONFIG_MICROCHIP_KSZ8895)	        += ksz8895.o ksz_common.o
+obj-$(CONFIG_MICROCHIP_KSZ8895_SPI_DRIVER)	+= ksz8895_spi.o
diff --git a/drivers/net/dsa/microchip/ksz8895.c b/drivers/net/dsa/microchip/ksz8895.c
new file mode 100644
index 0000000..947638b
--- /dev/null
+++ b/drivers/net/dsa/microchip/ksz8895.c
@@ -0,0 +1,1288 @@
+/*
+ * Microchip KSZ8895 switch driver
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
+#include "ksz8895_reg.h"
+
+static const struct {
+	char string[ETH_GSTRING_LEN];
+} mib_names[TOTAL_SWITCH_COUNTER_NUM] = {
+	{ "rx" },
+	{ "rx_hi" },
+	{ "rx_undersize" },
+	{ "rx_fragments" },
+	{ "rx_oversize" },
+	{ "rx_jabbers" },
+	{ "rx_symbol_err" },
+	{ "rx_crc_err" },
+	{ "rx_align_err" },
+	{ "rx_mac_ctrl" },
+	{ "rx_pause" },
+	{ "rx_bcast" },
+	{ "rx_mcast" },
+	{ "rx_ucast" },
+	{ "rx_64_or_less" },
+	{ "rx_65_127" },
+	{ "rx_128_255" },
+	{ "rx_256_511" },
+	{ "rx_512_1023" },
+	{ "rx_1024_1522" },
+	{ "tx" },
+	{ "tx_hi" },
+	{ "tx_late_col" },
+	{ "tx_pause" },
+	{ "tx_bcast" },
+	{ "tx_mcast" },
+	{ "tx_ucast" },
+	{ "tx_deferred" },
+	{ "tx_total_col" },
+	{ "tx_exc_col" },
+	{ "tx_single_col" },
+	{ "tx_mult_col" },
+	{ "rx_discards" },
+	{ "tx_discards" },
+};
+
+static int ksz8895_reset_switch(struct ksz_device *dev)
+{
+	/* reset switch */
+	ksz_write8(dev, REG_POWER_MANAGEMENT_1,
+		   SW_SOFTWARE_POWER_DOWN << SW_POWER_MANAGEMENT_MODE_S);
+	ksz_write8(dev, REG_POWER_MANAGEMENT_1, 0);
+
+	return 0;
+}
+
+static void ksz8895_set_prio_queue(struct ksz_device *dev, int port, int queue)
+{
+	u8 hi;
+	u8 lo;
+
+	/* Number of queues can only be 1, 2, or 4. */
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
+	if (queue & PORT_QUEUE_SPLIT_2)
+		lo |= PORT_QUEUE_SPLIT_L;
+	hi &= ~PORT_QUEUE_SPLIT_H;
+	if (queue & PORT_QUEUE_SPLIT_4)
+		hi |= PORT_QUEUE_SPLIT_H;
+	ksz_pwrite8(dev, port, REG_PORT_CTRL_0, lo);
+	ksz_pwrite8(dev, port, P_DROP_TAG_CTRL, hi);
+
+	/* Default is port based for egress rate limit. */
+	if (queue != PORT_QUEUE_SPLIT_1)
+		ksz_cfg(dev, REG_SW_CTRL_19, SW_OUT_RATE_LIMIT_QUEUE_BASED,
+			true);
+}
+
+static void ksz8895_r_mib_cnt(struct ksz_device *dev, int port, u16 addr,
+			      u64 *cnt)
+{
+	u32 data;
+	u16 ctrl_addr;
+	u8 check;
+	int loop;
+
+	ctrl_addr = addr + SWITCH_COUNTER_NUM * port;
+	ctrl_addr |= IND_ACC_TABLE(TABLE_MIB | TABLE_READ);
+
+	mutex_lock(&dev->alu_mutex);
+	ksz_write16(dev, REG_IND_CTRL_0, ctrl_addr);
+
+	/* It is almost guaranteed to always read the valid bit because of
+	 * slow SPI speed.
+	 */
+	for (loop = 2; loop > 0; loop--) {
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
+	mutex_unlock(&dev->alu_mutex);
+}
+
+static void ksz8895_r_mib_pkt(struct ksz_device *dev, int port, u16 addr,
+			      u64 *dropped, u64 *cnt)
+{
+	u32 cur;
+	u32 data;
+	u16 ctrl_addr;
+	u32 *last = (u32 *)dropped;
+
+	addr -= SWITCH_COUNTER_NUM;
+	ctrl_addr = addr ? KS_MIB_PACKET_DROPPED_TX_0 :
+			   KS_MIB_PACKET_DROPPED_RX_0;
+	ctrl_addr += port;
+	ctrl_addr |= IND_ACC_TABLE(TABLE_MIB | TABLE_READ);
+
+	mutex_lock(&dev->alu_mutex);
+	ksz_write16(dev, REG_IND_CTRL_0, ctrl_addr);
+	ksz_read32(dev, REG_IND_DATA_LO, &data);
+	mutex_unlock(&dev->alu_mutex);
+
+	data &= MIB_PACKET_DROPPED;
+	cur = last[addr];
+	if (data != cur) {
+		last[addr] = data;
+		if (data < cur)
+			data += MIB_PACKET_DROPPED + 1;
+		data -= cur;
+		*cnt += data;
+	}
+}
+
+static void ksz8895_port_init_cnt(struct ksz_device *dev, int port)
+{
+	struct ksz_port_mib *mib = &dev->ports[port].mib;
+	u64 *dropped;
+
+	mib->cnt_ptr = 0;
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
+	memset(mib->counters, 0, dev->mib_cnt * sizeof(u64));
+}
+
+static void ksz8895_r_table(struct ksz_device *dev, int table, u16 addr,
+			    u64 *data)
+{
+	u16 ctrl_addr;
+
+	ctrl_addr = IND_ACC_TABLE(table | TABLE_READ) | addr;
+
+	mutex_lock(&dev->alu_mutex);
+	ksz_write16(dev, REG_IND_CTRL_0, ctrl_addr);
+	ksz_get(dev, REG_IND_DATA_HI, data, sizeof(u64));
+	mutex_unlock(&dev->alu_mutex);
+	*data = be64_to_cpu(*data);
+}
+
+static void ksz8895_w_table(struct ksz_device *dev, int table, u16 addr,
+			    u64 data)
+{
+	u16 ctrl_addr;
+
+	ctrl_addr = IND_ACC_TABLE(table) | addr;
+	data = cpu_to_be64(data);
+
+	mutex_lock(&dev->alu_mutex);
+	ksz_set(dev, REG_IND_DATA_HI, &data, sizeof(u64));
+	ksz_write16(dev, REG_IND_CTRL_0, ctrl_addr);
+	mutex_unlock(&dev->alu_mutex);
+}
+
+static int ksz8895_valid_dyn_entry(struct ksz_device *dev, u8 *data)
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
+		return -EAGAIN;
+	/* Entry is ready for accessing. */
+	} else {
+		ksz_read8(dev, REG_IND_DATA_8, data);
+
+		/* There is no valid entry in the table. */
+		if (*data & DYNAMIC_MAC_TABLE_MAC_EMPTY)
+			return -ENXIO;
+	}
+	return 0;
+}
+
+static int ksz8895_r_dyn_mac_table(struct ksz_device *dev, u16 addr,
+				   u8 *mac_addr, u8 *fid, u8 *src_port,
+				   u8 *timestamp, u16 *entries)
+{
+	u32 data_hi;
+	u32 data_lo;
+	u16 ctrl_addr;
+	int rc;
+	u8 data;
+
+	ctrl_addr = IND_ACC_TABLE(TABLE_DYNAMIC_MAC | TABLE_READ) | addr;
+
+	mutex_lock(&dev->alu_mutex);
+	ksz_write16(dev, REG_IND_CTRL_0, ctrl_addr);
+
+	rc = ksz8895_valid_dyn_entry(dev, &data);
+	if (rc == -EAGAIN) {
+		if (addr == 0)
+			*entries = 0;
+	} else if (rc == -ENXIO) {
+		*entries = 0;
+	/* At least one valid entry in the table. */
+	} else {
+		u64 buf;
+		int cnt;
+
+		ksz_get(dev, REG_IND_DATA_HI, &buf, sizeof(buf));
+		buf = be64_to_cpu(buf);
+		data_hi = (u32)(buf >> 32);
+		data_lo = (u32)buf;
+
+		/* Check out how many valid entry in the table. */
+		cnt = data & DYNAMIC_MAC_TABLE_ENTRIES_H;
+		cnt <<= DYNAMIC_MAC_ENTRIES_H_S;
+		cnt |= (data_hi & DYNAMIC_MAC_TABLE_ENTRIES) >>
+			DYNAMIC_MAC_ENTRIES_S;
+		*entries = cnt + 1;
+
+		*fid = (data_hi & DYNAMIC_MAC_TABLE_FID) >>
+			DYNAMIC_MAC_FID_S;
+		*src_port = (data_hi & DYNAMIC_MAC_TABLE_SRC_PORT) >>
+			DYNAMIC_MAC_SRC_PORT_S;
+		*timestamp = (data_hi & DYNAMIC_MAC_TABLE_TIMESTAMP) >>
+			DYNAMIC_MAC_TIMESTAMP_S;
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
+	mutex_unlock(&dev->alu_mutex);
+
+	return rc;
+}
+
+static int ksz8895_r_sta_mac_table(struct ksz_device *dev, u16 addr,
+				   struct alu_struct *alu)
+{
+	u64 data;
+	u32 data_hi;
+	u32 data_lo;
+
+	ksz8895_r_table(dev, TABLE_STATIC_MAC, addr, &data);
+	data_hi = data >> 32;
+	data_lo = (u32)data;
+	if (data_hi & (STATIC_MAC_TABLE_VALID | STATIC_MAC_TABLE_OVERRIDE)) {
+		alu->mac[5] = (u8)data_lo;
+		alu->mac[4] = (u8)(data_lo >> 8);
+		alu->mac[3] = (u8)(data_lo >> 16);
+		alu->mac[2] = (u8)(data_lo >> 24);
+		alu->mac[1] = (u8)data_hi;
+		alu->mac[0] = (u8)(data_hi >> 8);
+		alu->port_forward = (data_hi & STATIC_MAC_TABLE_FWD_PORTS) >>
+			STATIC_MAC_FWD_PORTS_S;
+		alu->is_override =
+			(data_hi & STATIC_MAC_TABLE_OVERRIDE) ? 1 : 0;
+		data_hi >>= 1;
+		alu->is_use_fid = (data_hi & STATIC_MAC_TABLE_USE_FID) ? 1 : 0;
+		alu->fid = (data_hi & STATIC_MAC_TABLE_FID) >>
+			STATIC_MAC_FID_S;
+		return 0;
+	}
+	return -ENXIO;
+}
+
+static void ksz8895_w_sta_mac_table(struct ksz_device *dev, u16 addr,
+				    struct alu_struct *alu)
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
+	ksz8895_w_table(dev, TABLE_STATIC_MAC, addr, data);
+}
+
+static inline void ksz8895_from_vlan(u16 vlan, u8 *fid, u8 *member, u8 *valid)
+{
+	*fid = vlan & VLAN_TABLE_FID;
+	*member = (vlan & VLAN_TABLE_MEMBERSHIP) >> VLAN_TABLE_MEMBERSHIP_S;
+	*valid = !!(vlan & VLAN_TABLE_VALID);
+}
+
+static inline void ksz8895_to_vlan(u8 fid, u8 member, u8 valid, u16 *vlan)
+{
+	*vlan = fid;
+	*vlan |= (u16)member << VLAN_TABLE_MEMBERSHIP_S;
+	if (valid)
+		*vlan |= VLAN_TABLE_VALID;
+}
+
+static void ksz8895_r_vlan_entries(struct ksz_device *dev, u16 addr)
+{
+	u64 data;
+	int i;
+
+	ksz8895_r_table(dev, TABLE_VLAN, addr, &data);
+	addr *= 4;
+	for (i = 0; i < 4; i++) {
+		dev->vlan_cache[addr + i].table[0] = data & VLAN_TABLE_M;
+		data >>= VLAN_TABLE_S;
+	}
+}
+
+static void ksz8895_r_vlan_table(struct ksz_device *dev, u16 vid, u16 *vlan)
+{
+	u64 buf;
+	u16 addr;
+	int index;
+
+	addr = vid / 4;
+	index = vid & 3;
+	ksz8895_r_table(dev, TABLE_VLAN, addr, &buf);
+	buf >>= VLAN_TABLE_S * index;
+	*vlan = buf & VLAN_TABLE_M;
+}
+
+static void ksz8895_w_vlan_table(struct ksz_device *dev, u16 vid, u16 vlan)
+{
+	u64 buf;
+	u16 addr;
+	int index;
+
+	addr = vid / 4;
+	index = vid & 3;
+	ksz8895_r_table(dev, TABLE_VLAN, addr, &buf);
+	index *= VLAN_TABLE_S;
+	buf &= ~(VLAN_TABLE_M << index);
+	buf |= (u64)vlan << index;
+	dev->vlan_cache[vid].table[0] = vlan;
+	ksz8895_w_table(dev, TABLE_VLAN, addr, buf);
+}
+
+static void ksz8895_r_phy(struct ksz_device *dev, u16 phy, u16 reg, u16 *val)
+{
+	struct ksz_port *port;
+	u8 ctrl;
+	u8 restart;
+	u8 link;
+	u8 speed;
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
+		if (restart & PORT_PHY_LOOPBACK)
+			data |= PHY_LOOPBACK;
+		if (ctrl & PORT_FORCE_100_MBIT)
+			data |= PHY_SPEED_100MBIT;
+		if (!(ctrl & PORT_AUTO_NEG_DISABLE))
+			data |= PHY_AUTO_NEG_ENABLE;
+		if (restart & PORT_POWER_DOWN)
+			data |= PHY_POWER_DOWN;
+		if (restart & PORT_AUTO_NEG_RESTART)
+			data |= PHY_AUTO_NEG_RESTART;
+		if (ctrl & PORT_FORCE_FULL_DUPLEX)
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
+		data = PHY_100BTX_FD_CAPABLE |
+		       PHY_100BTX_CAPABLE |
+		       PHY_10BT_FD_CAPABLE |
+		       PHY_10BT_CAPABLE |
+		       PHY_AUTO_NEG_CAPABLE;
+		if (link & PORT_AUTO_NEG_COMPLETE)
+			data |= PHY_AUTO_NEG_ACKNOWLEDGE;
+		if (link & PORT_STAT_LINK_GOOD)
+			data |= PHY_LINK_STATUS;
+		break;
+	case PHY_REG_ID_1:
+		data = KSZ8895_ID_HI;
+		break;
+	case PHY_REG_ID_2:
+		data = KSZ8895_ID_LO;
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
+		if (data & ~PHY_AUTO_NEG_802_3)
+			data |= PHY_REMOTE_ACKNOWLEDGE_NOT;
+		break;
+	default:
+		processed = false;
+		break;
+	}
+	if (processed)
+		*val = data;
+}
+
+static void ksz8895_w_phy(struct ksz_device *dev, u16 phy, u16 reg, u16 val)
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
+			  PORT_AUTO_NEG_100BTX_FD |
+			  PORT_AUTO_NEG_100BTX |
+			  PORT_AUTO_NEG_10BT_FD |
+			  PORT_AUTO_NEG_10BT);
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
+static enum dsa_tag_protocol ksz8895_get_tag_protocol(struct dsa_switch *ds)
+{
+	/* Use KSZ8795 tail tagging code. */
+	return DSA_TAG_PROTO_KSZ8795;
+}
+
+static void ksz8895_get_strings(struct dsa_switch *ds, int port, uint8_t *buf)
+{
+	int i;
+
+	for (i = 0; i < TOTAL_SWITCH_COUNTER_NUM; i++) {
+		memcpy(buf + i * ETH_GSTRING_LEN, mib_names[i].string,
+		       ETH_GSTRING_LEN);
+	}
+}
+
+static const u8 stp_multicast_addr[] = {
+	0x01, 0x80, 0xC2, 0x00, 0x00, 0x00
+};
+
+static void ksz8895_cfg_port_member(struct ksz_device *dev, int port,
+				    u8 member)
+{
+	u8 data;
+
+	ksz_pread8(dev, port, P_MIRROR_CTRL, &data);
+	data &= ~PORT_VLAN_MEMBERSHIP;
+	data |= (member & dev->port_mask);
+	ksz_pwrite8(dev, port, P_MIRROR_CTRL, data);
+	dev->ports[port].member = member;
+}
+
+static void ksz8895_port_stp_state_set(struct dsa_switch *ds, int port,
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
+		if (port < SWITCH_PORT_NUM)
+			member = 0;
+		break;
+	case BR_STATE_LISTENING:
+		data |= (PORT_RX_ENABLE | PORT_LEARN_DISABLE);
+		if (port < SWITCH_PORT_NUM &&
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
+		if (port < SWITCH_PORT_NUM &&
+		    p->stp_state == BR_STATE_DISABLED)
+			member = dev->host_mask | p->vid_member;
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
+		ksz8895_cfg_port_member(dev, port, (u8)member);
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
+static void ksz8895_flush_dyn_mac_table(struct ksz_device *dev, int port)
+{
+	int cnt;
+	int first;
+	int index;
+	u8 learn[TOTAL_PORT_NUM];
+
+	if ((uint)port < TOTAL_PORT_NUM) {
+		first = port;
+		cnt = port + 1;
+	} else {
+		/* Flush all ports. */
+		first = 0;
+		if (dev->chip_id == 0x8864)
+			first = 1;
+		cnt = dev->mib_port_cnt;
+	}
+	for (index = first; index < cnt; index++) {
+		ksz_pread8(dev, index, P_STP_CTRL, &learn[index]);
+		if (!(learn[index] & PORT_LEARN_DISABLE))
+			ksz_pwrite8(dev, index, P_STP_CTRL,
+				    learn[index] | PORT_LEARN_DISABLE);
+	}
+	ksz_cfg(dev, S_FLUSH_TABLE_CTRL, SW_FLUSH_DYN_MAC_TABLE, true);
+	for (index = first; index < cnt; index++) {
+		if (!(learn[index] & PORT_LEARN_DISABLE))
+			ksz_pwrite8(dev, index, P_STP_CTRL, learn[index]);
+	}
+}
+
+static int ksz8895_port_vlan_filtering(struct dsa_switch *ds, int port,
+				       bool flag)
+{
+	struct ksz_device *dev = ds->priv;
+
+	ksz_cfg(dev, S_MIRROR_CTRL, SW_VLAN_ENABLE, flag);
+
+	return 0;
+}
+
+static void ksz8895_port_vlan_add(struct dsa_switch *ds, int port,
+				  const struct switchdev_obj_port_vlan *vlan,
+				  struct switchdev_trans *trans)
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
+		ksz8895_r_vlan_table(dev, vid, &data);
+		ksz8895_from_vlan(data, &fid, &member, &valid);
+
+		/* First time to setup the VLAN entry. */
+		if (!valid) {
+			/* Need to find a way to map VID to FID. */
+			fid = 1;
+			valid = 1;
+		}
+		member |= BIT(port);
+
+		ksz8895_to_vlan(fid, member, valid, &data);
+		ksz8895_w_vlan_table(dev, vid, data);
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
+static int ksz8895_port_vlan_del(struct dsa_switch *ds, int port,
+				 const struct switchdev_obj_port_vlan *vlan)
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
+		ksz8895_r_vlan_table(dev, vid, &data);
+		ksz8895_from_vlan(data, &fid, &member, &valid);
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
+		ksz8895_to_vlan(fid, member, valid, &data);
+		ksz8895_w_vlan_table(dev, vid, data);
+	}
+
+	if (new_pvid != pvid)
+		ksz_pwrite16(dev, port, REG_PORT_CTRL_VID, pvid);
+
+	return 0;
+}
+
+static int ksz8895_port_mirror_add(struct dsa_switch *ds, int port,
+				   struct dsa_mall_mirror_tc_entry *mirror,
+				   bool ingress)
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
+static void ksz8895_port_mirror_del(struct dsa_switch *ds, int port,
+				    struct dsa_mall_mirror_tc_entry *mirror)
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
+static void ksz8895_phy_setup(struct ksz_device *dev, int port,
+			      struct phy_device *phy)
+{
+	/* SUPPORTED_Pause can be removed to disable flow control when
+	 * rate limiting is used.
+	 */
+	phy->supported &= ~SUPPORTED_Asym_Pause;
+	phy->advertising = phy->supported;
+}
+
+static void ksz8895_port_setup(struct ksz_device *dev, int port, bool cpu_port)
+{
+	u8 member;
+	struct ksz_port *p = &dev->ports[port];
+
+	/* enable broadcast storm limit */
+	ksz_port_cfg(dev, port, P_BCAST_STORM_CTRL, PORT_BROADCAST_STORM, true);
+
+	ksz8895_set_prio_queue(dev, port, 4);
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
+	ksz8895_cfg_port_member(dev, port, member);
+}
+
+static void ksz8895_config_cpu_port(struct dsa_switch *ds)
+{
+	struct ksz_device *dev = ds->priv;
+	struct ksz_port *p;
+	int i;
+	u8 remote;
+
+	ds->num_ports = dev->port_cnt + 1;
+
+	ksz_cfg(dev, S_TAIL_TAG_CTRL, SW_TAIL_TAG_ENABLE, true);
+
+	p = &dev->ports[dev->cpu_port];
+	p->vid_member = dev->port_mask;
+	p->on = 1;
+
+	ksz8895_port_setup(dev, dev->cpu_port, true);
+	dev->member = dev->host_mask;
+
+	for (i = 0; i < SWITCH_PORT_NUM; i++) {
+		p = &dev->ports[i];
+
+		/* Initialize to non-zero so that ksz_cfg_port_member() will
+		 * be called.
+		 */
+		p->vid_member = (1 << i);
+		p->member = dev->port_mask;
+		ksz8895_port_stp_state_set(ds, i, BR_STATE_DISABLED);
+
+		/* First port is disabled in KSZ8864. */
+		if (dev->chip_id == 0x8864 && i == 0)
+			break;
+		p->on = 1;
+		p->phy = 1;
+	}
+	ksz_read8(dev, REG_SW_CFG, &remote);
+	if (remote & SW_PORT_3_FIBER)
+		dev->ports[2].fiber = 1;
+	for (i = 0; i < dev->phy_port_cnt; i++) {
+		p = &dev->ports[i];
+		if (!p->on)
+			continue;
+		if (p->fiber)
+			ksz_port_cfg(dev, i, P_STP_CTRL, PORT_FORCE_FLOW_CTRL,
+				     true);
+		else
+			ksz_port_cfg(dev, i, P_STP_CTRL, PORT_FORCE_FLOW_CTRL,
+				     false);
+	}
+}
+
+static int ksz8895_set_addr(struct dsa_switch *ds, u8 *addr)
+{
+	/* Setting the switch MAC address is required for the self-address
+	 * filtering feature.  However, there is a flaw in the feature and
+	 * so it cannot be used.
+	 * The dynamic MAC table also does not learn the address so unicast
+	 * forwarding is not operating correctly for the host.
+	 */
+	return 0;
+}
+
+static int ksz8895_setup(struct dsa_switch *ds)
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
+	ret = ksz8895_reset_switch(dev);
+	if (ret) {
+		dev_err(ds->dev, "failed to reset switch\n");
+		return ret;
+	}
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
+	ksz8895_config_cpu_port(ds);
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
+		ksz8895_r_vlan_entries(dev, i);
+
+	/* Setup STP address for STP operation. */
+	memset(&alu, 0, sizeof(alu));
+	memcpy(alu.mac, stp_multicast_addr, ETH_ALEN);
+	alu.is_static = true;
+	alu.is_override = true;
+	alu.port_forward = dev->host_mask;
+
+	ksz8895_w_sta_mac_table(dev, 0, &alu);
+
+	ksz_write8(dev, REG_CHIP_ID1, SW_START);
+
+	ksz_init_mib_timer(dev);
+
+	return 0;
+}
+
+static const struct dsa_switch_ops ksz8895_switch_ops = {
+	.get_tag_protocol	= ksz8895_get_tag_protocol,
+	.setup			= ksz8895_setup,
+	.set_addr		= ksz8895_set_addr,
+	.phy_read		= ksz_phy_read16,
+	.phy_write		= ksz_phy_write16,
+	.adjust_link		= ksz_adjust_link,
+	.port_enable		= ksz_enable_port,
+	.port_disable		= ksz_disable_port,
+	.get_strings		= ksz8895_get_strings,
+	.get_ethtool_stats	= ksz_get_ethtool_stats,
+	.get_sset_count		= ksz_sset_count,
+	.port_bridge_join	= ksz_port_bridge_join,
+	.port_bridge_leave	= ksz_port_bridge_leave,
+	.port_stp_state_set	= ksz8895_port_stp_state_set,
+	.port_fast_age		= ksz_port_fast_age,
+	.port_vlan_filtering	= ksz8895_port_vlan_filtering,
+	.port_vlan_prepare	= ksz_port_vlan_prepare,
+	.port_vlan_add		= ksz8895_port_vlan_add,
+	.port_vlan_del		= ksz8895_port_vlan_del,
+	.port_fdb_dump		= ksz_port_fdb_dump,
+	.port_mdb_prepare       = ksz_port_mdb_prepare,
+	.port_mdb_add           = ksz_port_mdb_add,
+	.port_mdb_del           = ksz_port_mdb_del,
+	.port_mirror_add	= ksz8895_port_mirror_add,
+	.port_mirror_del	= ksz8895_port_mirror_del,
+};
+
+static u32 ksz8895_get_port_addr(int port, int offset)
+{
+	return PORT_CTRL_ADDR(port, offset);
+}
+
+static int ksz8895_switch_detect(struct ksz_device *dev)
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
+	    (id2 != CHIP_ID_95 && id2 != CHIP_ID_95R))
+		return -ENODEV;
+
+	dev->mib_port_cnt = TOTAL_PORT_NUM;
+	dev->phy_port_cnt = SWITCH_PORT_NUM;
+	dev->port_cnt = SWITCH_PORT_NUM;
+
+	ksz_read8(dev, REG_KSZ8864_CHIP_ID, &id2);
+	if (id2 & SW_KSZ8864) {
+		dev->port_cnt--;
+		id2 = 0x64;
+	} else {
+		id2 = 0x95;
+	}
+	id16 = 0x8800;
+	id16 |= id2;
+	dev->chip_id = id16;
+
+	dev->cpu_port = dev->mib_port_cnt - 1;
+	dev->host_mask = (1 << dev->cpu_port);
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
+static const struct ksz_chip_data ksz8895_switch_chips[] = {
+	{
+		.chip_id = 0x8895,
+		.dev_name = "KSZ8895",
+		.num_vlans = 4096,
+		.num_alus = 0,
+		.num_statics = 8,
+		.cpu_ports = 0x10,	/* can be configured as cpu port */
+		.port_cnt = 4,		/* total physical port count */
+	},
+	{
+		.chip_id = 0x8864,
+		.dev_name = "KSZ8864",
+		.num_vlans = 4096,
+		.num_alus = 0,
+		.num_statics = 8,
+		.cpu_ports = 0x10,	/* can be configured as cpu port */
+		.port_cnt = 3,		/* total physical port count */
+	},
+};
+
+static int ksz8895_switch_init(struct ksz_device *dev)
+{
+	int i;
+
+	mutex_init(&dev->reg_mutex);
+	mutex_init(&dev->stats_mutex);
+	mutex_init(&dev->alu_mutex);
+	mutex_init(&dev->vlan_mutex);
+
+	dev->ds->ops = &ksz8895_switch_ops;
+
+	for (i = 0; i < ARRAY_SIZE(ksz8895_switch_chips); i++) {
+		const struct ksz_chip_data *chip = &ksz8895_switch_chips[i];
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
+	if (!dev->cpu_ports)
+		return -ENODEV;
+
+	dev->port_mask = (1 << dev->port_cnt) - 1;
+	dev->port_mask |= dev->host_mask;
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
+		mutex_init(&dev->ports[i].mib.cnt_mutex);
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
+static void ksz8895_switch_exit(struct ksz_device *dev)
+{
+	ksz8895_reset_switch(dev);
+	ksz_write8(dev, REG_CHIP_ID1, SW_START);
+}
+
+static const struct ksz_dev_ops ksz8895_dev_ops = {
+	.get_port_addr = ksz8895_get_port_addr,
+	.cfg_port_member = ksz8895_cfg_port_member,
+	.flush_dyn_mac_table = ksz8895_flush_dyn_mac_table,
+	.phy_setup = ksz8895_phy_setup,
+	.port_setup = ksz8895_port_setup,
+	.r_phy = ksz8895_r_phy,
+	.w_phy = ksz8895_w_phy,
+	.r_dyn_mac_table = ksz8895_r_dyn_mac_table,
+	.r_sta_mac_table = ksz8895_r_sta_mac_table,
+	.w_sta_mac_table = ksz8895_w_sta_mac_table,
+	.r_mib_cnt = ksz8895_r_mib_cnt,
+	.r_mib_pkt = ksz8895_r_mib_pkt,
+	.port_init_cnt = ksz8895_port_init_cnt,
+	.shutdown = ksz8895_reset_switch,
+	.detect = ksz8895_switch_detect,
+	.init = ksz8895_switch_init,
+	.exit = ksz8895_switch_exit,
+};
+
+int ksz8895_switch_register(struct ksz_device *dev)
+{
+	return ksz_switch_register(dev, &ksz8895_dev_ops);
+}
+EXPORT_SYMBOL(ksz8895_switch_register);
+
+MODULE_AUTHOR("Tristram Ha <Tristram.Ha@microchip.com>");
+MODULE_DESCRIPTION("Microchip KSZ8895 Series Switch DSA Driver");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/dsa/microchip/ksz8895_reg.h b/drivers/net/dsa/microchip/ksz8895_reg.h
new file mode 100644
index 0000000..1d6ffb1
--- /dev/null
+++ b/drivers/net/dsa/microchip/ksz8895_reg.h
@@ -0,0 +1,824 @@
+/**
+ * Microchip KSZ8895 register definitions
+ *
+ * Copyright (c) 2017 Microchip Technology Inc.
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
+#ifndef __KSZ8895_REG_H
+#define __KSZ8895_REG_H
+
+#define KS_PORT_M			0x1F
+
+#define KS_PRIO_M			0x3
+#define KS_PRIO_S			2
+
+#define REG_CHIP_ID0			0x00
+
+#define FAMILY_ID			0x95
+
+#define REG_CHIP_ID1			0x01
+
+#define SW_CHIP_ID_M			0xF0
+#define SW_CHIP_ID_S			4
+#define SW_REVISION_M			0x0E
+#define SW_REVISION_S			1
+#define SW_START			0x01
+
+#define CHIP_ID_95			0x40
+#define CHIP_ID_95R			0x60
+
+#define REG_SW_CTRL_0			0x02
+
+#define SW_NEW_BACKOFF			BIT(7)
+#define SW_FLUSH_DYN_MAC_TABLE		BIT(5)
+#define SW_FLUSH_STA_MAC_TABLE		BIT(4)
+#define SW_UNH_MODE			BIT(1)
+#define SW_LINK_AUTO_AGING		BIT(0)
+
+#define REG_SW_CTRL_1			0x03
+
+#define SW_PASS_ALL			BIT(7)
+#define SW_2K_PACKET			BIT(6)
+#define SW_TX_FLOW_CTRL_DISABLE		BIT(5)
+#define SW_RX_FLOW_CTRL_DISABLE		BIT(4)
+#define SW_CHECK_LENGTH			BIT(3)
+#define SW_AGING_ENABLE			BIT(2)
+#define SW_FAST_AGING			BIT(1)
+#define SW_AGGR_BACKOFF			BIT(0)
+
+#define REG_SW_CTRL_2			0x04
+
+#define UNICAST_VLAN_BOUNDARY		BIT(7)
+#define MULTICAST_STORM_DISABLE		BIT(6)
+#define SW_BACK_PRESSURE		BIT(5)
+#define FAIR_FLOW_CTRL			BIT(4)
+#define NO_EXC_COLLISION_DROP		BIT(3)
+#define SW_HUGE_PACKET			BIT(2)
+#define SW_LEGAL_PACKET			BIT(1)
+
+#define REG_SW_CTRL_3			0x05
+#define SW_VLAN_ENABLE			BIT(7)
+#define SW_IGMP_SNOOP			BIT(6)
+#define SW_DIRECT			BIT(5)
+#define SW_PRE_TAG			BIT(4)
+#define SW_VLAN_TAG			BIT(1)
+#define SW_MIRROR_RX_TX			BIT(0)
+
+#define REG_SW_CTRL_4			0x06
+
+#define SW_HALF_DUPLEX_FLOW_CTRL	BIT(7)
+#define SW_HALF_DUPLEX			BIT(6)
+#define SW_FLOW_CTRL			BIT(5)
+#define SW_10_MBIT			BIT(4)
+#define SW_REPLACE_VID			BIT(3)
+#define BROADCAST_STORM_RATE_HI		0x07
+
+#define REG_SW_CTRL_5			0x07
+
+#define BROADCAST_STORM_RATE_LO		0xFF
+#define BROADCAST_STORM_RATE		0x07FF
+
+#define REG_SW_CTRL_9			0x0B
+
+#define SW_DATA_SAMPLING_NEG		BIT(6)
+#define SW_PHY_POWER_SAVE_DISABLE	BIT(3)
+#define SW_LED_MODE_1			BIT(1)
+#define SW_SPI_SAMPLING_RISING		BIT(0)
+
+#define REG_SW_CTRL_10			0x0C
+
+#define SPI_CLK_125_MHZ			0x20
+#define SPI_CLK_83_33_MHZ		0x10
+#define SPI_CLK_41_67_MHZ		0x00
+#define SW_TAIL_TAG_ENABLE		BIT(1)
+#define SW_PASS_PAUSE			BIT(0)
+
+#define REG_SW_CTRL_11			0x0D
+
+#define REG_POWER_MANAGEMENT_1		0x0E
+
+#define SW_PLL_POWER_DOWN		BIT(5)
+#define SW_POWER_MANAGEMENT_MODE_M	0x3
+#define SW_POWER_MANAGEMENT_MODE_S	3
+#define SW_POWER_NORMAL			0
+#define SW_ENERGY_DETECTION		1
+#define SW_SOFTWARE_POWER_DOWN		2
+#define SW_POWER_SAVING			3
+
+#define REG_POWER_MANAGEMENT_2		0x0F
+
+#define REG_PORT_1_CTRL_0		0x10
+#define REG_PORT_2_CTRL_0		0x20
+#define REG_PORT_3_CTRL_0		0x30
+#define REG_PORT_4_CTRL_0		0x40
+#define REG_PORT_5_CTRL_0		0x50
+
+#define PORT_BROADCAST_STORM		BIT(7)
+#define PORT_DIFFSERV_ENABLE		BIT(6)
+#define PORT_802_1P_ENABLE		BIT(5)
+#define PORT_BASED_PRIO_S		3
+#define PORT_BASED_PRIO_M		KS_PRIO_M
+#define PORT_PORT_PRIO_0		0
+#define PORT_PORT_PRIO_1		1
+#define PORT_PORT_PRIO_2		2
+#define PORT_PORT_PRIO_3		3
+#define PORT_INSERT_TAG			BIT(2)
+#define PORT_REMOVE_TAG			BIT(1)
+#define PORT_QUEUE_SPLIT_L		BIT(0)
+
+#define REG_PORT_1_CTRL_1		0x11
+#define REG_PORT_2_CTRL_1		0x21
+#define REG_PORT_3_CTRL_1		0x31
+#define REG_PORT_4_CTRL_1		0x41
+#define REG_PORT_5_CTRL_1		0x51
+
+#define PORT_MIRROR_SNIFFER		BIT(7)
+#define PORT_MIRROR_RX			BIT(6)
+#define PORT_MIRROR_TX			BIT(5)
+#define PORT_VLAN_MEMBERSHIP		KS_PORT_M
+
+#define REG_PORT_1_CTRL_2		0x12
+#define REG_PORT_2_CTRL_2		0x22
+#define REG_PORT_3_CTRL_2		0x32
+#define REG_PORT_4_CTRL_2		0x42
+#define REG_PORT_5_CTRL_2		0x52
+
+#define PORT_802_1P_REMAPPING		BIT(7)
+#define PORT_INGRESS_FILTER		BIT(6)
+#define PORT_DISCARD_NON_VID		BIT(5)
+#define PORT_FORCE_FLOW_CTRL		BIT(4)
+#define PORT_BACK_PRESSURE		BIT(3)
+#define PORT_TX_ENABLE			BIT(2)
+#define PORT_RX_ENABLE			BIT(1)
+#define PORT_LEARN_DISABLE		BIT(0)
+
+#define REG_PORT_1_CTRL_3		0x13
+#define REG_PORT_2_CTRL_3		0x23
+#define REG_PORT_3_CTRL_3		0x33
+#define REG_PORT_4_CTRL_3		0x43
+#define REG_PORT_5_CTRL_3		0x53
+#define REG_PORT_1_CTRL_4		0x14
+#define REG_PORT_2_CTRL_4		0x24
+#define REG_PORT_3_CTRL_4		0x34
+#define REG_PORT_4_CTRL_4		0x44
+#define REG_PORT_5_CTRL_4		0x54
+
+#define PORT_DEFAULT_VID		0x0001
+
+#define REG_PORT_1_STATUS_0		0x19
+#define REG_PORT_2_STATUS_0		0x29
+#define REG_PORT_3_STATUS_0		0x39
+#define REG_PORT_4_STATUS_0		0x49
+#define REG_PORT_5_STATUS_0		0x59
+
+#define PORT_HP_MDIX			BIT(7)
+#define PORT_REVERSED_POLARITY		BIT(5)
+#define PORT_TX_FLOW_CTRL		BIT(4)
+#define PORT_RX_FLOW_CTRL		BIT(3)
+#define PORT_STAT_SPEED_100MBIT		BIT(2)
+#define PORT_STAT_FULL_DUPLEX		BIT(1)
+
+#define REG_PORT_1_LINK_MD_CTRL		0x1A
+#define REG_PORT_2_LINK_MD_CTRL		0x2A
+#define REG_PORT_3_LINK_MD_CTRL		0x3A
+#define REG_PORT_4_LINK_MD_CTRL		0x4A
+#define REG_PORT_5_LINK_MD_CTRL		0x5A
+
+#define PORT_CABLE_10M_SHORT		BIT(7)
+#define PORT_CABLE_DIAG_RESULT_M	0x3
+#define PORT_CABLE_DIAG_RESULT_S	5
+#define PORT_CABLE_STAT_NORMAL		0
+#define PORT_CABLE_STAT_OPEN		1
+#define PORT_CABLE_STAT_SHORT		2
+#define PORT_CABLE_STAT_FAILED		3
+#define PORT_START_CABLE_DIAG		BIT(4)
+#define PORT_FORCE_LINK			BIT(3)
+#define PORT_POWER_SAVING		BIT(2)
+#define PORT_PHY_REMOTE_LOOPBACK	BIT(1)
+#define PORT_CABLE_FAULT_COUNTER_H	0x01
+
+#define REG_PORT_1_LINK_MD_RESULT	0x1B
+#define REG_PORT_2_LINK_MD_RESULT	0x2B
+#define REG_PORT_3_LINK_MD_RESULT	0x3B
+#define REG_PORT_4_LINK_MD_RESULT	0x4B
+#define REG_PORT_5_LINK_MD_RESULT	0x5B
+
+#define PORT_CABLE_FAULT_COUNTER_L	0xFF
+#define PORT_CABLE_FAULT_COUNTER	0x1FF
+
+#define REG_PORT_1_CTRL_5		0x1C
+#define REG_PORT_2_CTRL_5		0x2C
+#define REG_PORT_3_CTRL_5		0x3C
+#define REG_PORT_4_CTRL_5		0x4C
+#define REG_PORT_5_CTRL_5		0x5C
+
+#define PORT_AUTO_NEG_DISABLE		BIT(7)
+#define PORT_FORCE_100_MBIT		BIT(6)
+#define PORT_FORCE_FULL_DUPLEX		BIT(5)
+#define PORT_AUTO_NEG_SYM_PAUSE		BIT(4)
+#define PORT_AUTO_NEG_100BTX_FD		BIT(3)
+#define PORT_AUTO_NEG_100BTX		BIT(2)
+#define PORT_AUTO_NEG_10BT_FD		BIT(1)
+#define PORT_AUTO_NEG_10BT		BIT(0)
+
+#define REG_PORT_1_CTRL_6		0x1D
+#define REG_PORT_2_CTRL_6		0x2D
+#define REG_PORT_3_CTRL_6		0x3D
+#define REG_PORT_4_CTRL_6		0x4D
+#define REG_PORT_5_CTRL_6		0x5D
+
+#define PORT_LED_OFF			BIT(7)
+#define PORT_TX_DISABLE			BIT(6)
+#define PORT_AUTO_NEG_RESTART		BIT(5)
+#define PORT_POWER_DOWN			BIT(3)
+#define PORT_AUTO_MDIX_DISABLE		BIT(2)
+#define PORT_FORCE_MDIX			BIT(1)
+#define PORT_MAC_LOOPBACK		BIT(0)
+
+#define REG_PORT_1_STATUS_1		0x1E
+#define REG_PORT_2_STATUS_1		0x2E
+#define REG_PORT_3_STATUS_1		0x3E
+#define REG_PORT_4_STATUS_1		0x4E
+#define REG_PORT_5_STATUS_1		0x5E
+
+#define PORT_MDIX_STATUS		BIT(7)
+#define PORT_AUTO_NEG_COMPLETE		BIT(6)
+#define PORT_STAT_LINK_GOOD		BIT(5)
+#define PORT_REMOTE_SYM_PAUSE		BIT(4)
+#define PORT_REMOTE_100BTX_FD		BIT(3)
+#define PORT_REMOTE_100BTX		BIT(2)
+#define PORT_REMOTE_10BT_FD		BIT(1)
+#define PORT_REMOTE_10BT		BIT(0)
+
+#define REG_PORT_1_STATUS_2		0x1F
+#define REG_PORT_2_STATUS_2		0x2F
+#define REG_PORT_3_STATUS_2		0x3F
+#define REG_PORT_4_STATUS_2		0x4F
+#define REG_PORT_5_STATUS_2		0x5F
+
+#define PORT_PHY_LOOPBACK		BIT(7)
+#define PORT_PHY_ISOLATE		BIT(5)
+#define PORT_PHY_SOFT_RESET		BIT(4)
+#define PORT_PHY_FORCE_LINK		BIT(3)
+#define PORT_PHY_MODE_M			0x7
+#define PHY_MODE_IN_AUTO_NEG		1
+#define PHY_MODE_10BT_HALF		2
+#define PHY_MODE_100BT_HALF		3
+#define PHY_MODE_10BT_FULL		5
+#define PHY_MODE_100BT_FULL		6
+#define PHY_MODE_ISOLDATE		7
+
+#define REG_PORT_CTRL_0			0x00
+#define REG_PORT_CTRL_1			0x01
+#define REG_PORT_CTRL_2			0x02
+#define REG_PORT_CTRL_VID		0x03
+
+#define REG_PORT_STATUS_0		0x09
+#define REG_PORT_LINK_MD_CTRL		0x0A
+#define REG_PORT_LINK_MD_RESULT		0x0B
+#define REG_PORT_CTRL_5			0x0C
+#define REG_PORT_CTRL_6			0x0D
+#define REG_PORT_STATUS_1		0x0E
+#define REG_PORT_STATUS_2		0x0F
+
+#define REG_PORT_CTRL_8			0xA0
+#define REG_PORT_CTRL_9			0xA1
+#define REG_PORT_RATE_CTRL_3		0xA2
+#define REG_PORT_RATE_CTRL_2		0xA3
+#define REG_PORT_RATE_CTRL_1		0xA4
+#define REG_PORT_RATE_CTRL_0		0xA5
+#define REG_PORT_RATE_LIMIT		0xA6
+#define REG_PORT_IN_RATE_0		0xA7
+#define REG_PORT_IN_RATE_1		0xA8
+#define REG_PORT_IN_RATE_2		0xA9
+#define REG_PORT_IN_RATE_3		0xAA
+#define REG_PORT_OUT_RATE_0		0xAB
+#define REG_PORT_OUT_RATE_1		0xAC
+#define REG_PORT_OUT_RATE_2		0xAD
+#define REG_PORT_OUT_RATE_3		0xAE
+
+#define PORT_CTRL_ADDR(port, addr)		\
+	((addr) + REG_PORT_1_CTRL_0 + (port) *	\
+		(REG_PORT_2_CTRL_0 - REG_PORT_1_CTRL_0))
+
+#define REG_SW_MAC_ADDR_0		0x68
+#define REG_SW_MAC_ADDR_1		0x69
+#define REG_SW_MAC_ADDR_2		0x6A
+#define REG_SW_MAC_ADDR_3		0x6B
+#define REG_SW_MAC_ADDR_4		0x6C
+#define REG_SW_MAC_ADDR_5		0x6D
+
+#define REG_IND_CTRL_0			0x6E
+
+#define TABLE_READ			BIT(4)
+#define TABLE_SELECT_S			2
+#define TABLE_STATIC_MAC_V		0
+#define TABLE_VLAN_V			1
+#define TABLE_DYNAMIC_MAC_V		2
+#define TABLE_MIB_V			3
+#define TABLE_STATIC_MAC		(TABLE_STATIC_MAC_V << TABLE_SELECT_S)
+#define TABLE_VLAN			(TABLE_VLAN_V << TABLE_SELECT_S)
+#define TABLE_DYNAMIC_MAC		(TABLE_DYNAMIC_MAC_V << TABLE_SELECT_S)
+#define TABLE_MIB			(TABLE_MIB_V << TABLE_SELECT_S)
+
+#define REG_IND_CTRL_1			0x6F
+
+#define TABLE_ENTRY_MASK		0x03FF
+
+#define REG_IND_DATA_8			0x70
+#define REG_IND_DATA_7			0x71
+#define REG_IND_DATA_6			0x72
+#define REG_IND_DATA_5			0x73
+#define REG_IND_DATA_4			0x74
+#define REG_IND_DATA_3			0x75
+#define REG_IND_DATA_2			0x76
+#define REG_IND_DATA_1			0x77
+#define REG_IND_DATA_0			0x78
+
+#define REG_IND_DATA_CHECK		REG_IND_DATA_6
+#define REG_IND_MIB_CHECK		REG_IND_DATA_3
+#define REG_IND_DATA_HI			REG_IND_DATA_7
+#define REG_IND_DATA_LO			REG_IND_DATA_3
+
+#define REG_INT_STATUS			0x7C
+#define REG_INT_ENABLE			0x7D
+
+#define INT_PORT_5			BIT(4)
+#define INT_PORT_4			BIT(3)
+#define INT_PORT_3			BIT(2)
+#define INT_PORT_2			BIT(1)
+#define INT_PORT_1			BIT(0)
+
+#define REG_SW_CTRL_12			0x80
+#define REG_SW_CTRL_13			0x81
+
+#define SWITCH_802_1P_MASK		3
+#define SWITCH_802_1P_BASE		3
+#define SWITCH_802_1P_SHIFT		2
+
+#define SW_802_1P_MAP_M			KS_PRIO_M
+#define SW_802_1P_MAP_S			KS_PRIO_S
+
+#define REG_SWITCH_CTRL_14		0x82
+
+#define SW_PRIO_MAPPING_M		KS_PRIO_M
+#define SW_PRIO_MAPPING_S		6
+#define SW_PRIO_MAP_3_HI		0
+#define SW_PRIO_MAP_2_HI		2
+#define SW_PRIO_MAP_0_LO		3
+
+#define REG_SW_CTRL_15			0x83
+#define REG_SW_CTRL_16			0x84
+
+#define SW_DRIVE_STRENGTH_M		0x3
+#define SW_DRIVE_STRENGTH_4MA		0
+#define SW_DRIVE_STRENGTH_8MA		1
+#define SW_DRIVE_STRENGTH_10MA		2
+#define SW_DRIVE_STRENGTH_14MA		3
+#define SW_MII_DRIVE_STRENGTH_S		6
+
+#define REG_SW_CTRL_17			0x85
+#define REG_SW_CTRL_18			0x86
+
+#define SW_SELF_ADDR_FILTER_ENABLE	BIT(6)
+
+#define REG_SW_UNK_UCAST_CTRL		0x83
+#define REG_SW_UNK_MCAST_CTRL		0x84
+#define REG_SW_UNK_VID_CTRL		0x85
+#define REG_SW_UNK_IP_MCAST_CTRL	0x86
+
+#define SW_UNK_FWD_ENABLE		BIT(5)
+#define SW_UNK_FWD_MAP			KS_PORT_M
+
+#define REG_SW_CTRL_19			0x87
+
+#define SW_IN_RATE_LIMIT_PERIOD_M	0x3
+#define SW_IN_RATE_LIMIT_PERIOD_S	4
+#define SW_IN_RATE_LIMIT_16_MS		0
+#define SW_IN_RATE_LIMIT_64_MS		1
+#define SW_IN_RATE_LIMIT_256_MS		2
+#define SW_OUT_RATE_LIMIT_QUEUE_BASED	BIT(3)
+#define SW_INS_TAG_ENABLE		BIT(2)
+
+#define REG_TOS_PRIO_CTRL_0		0x90
+#define REG_TOS_PRIO_CTRL_1		0x91
+#define REG_TOS_PRIO_CTRL_2		0x92
+#define REG_TOS_PRIO_CTRL_3		0x93
+#define REG_TOS_PRIO_CTRL_4		0x94
+#define REG_TOS_PRIO_CTRL_5		0x95
+#define REG_TOS_PRIO_CTRL_6		0x96
+#define REG_TOS_PRIO_CTRL_7		0x97
+#define REG_TOS_PRIO_CTRL_8		0x98
+#define REG_TOS_PRIO_CTRL_9		0x99
+#define REG_TOS_PRIO_CTRL_10		0x9A
+#define REG_TOS_PRIO_CTRL_11		0x9B
+#define REG_TOS_PRIO_CTRL_12		0x9C
+#define REG_TOS_PRIO_CTRL_13		0x9D
+#define REG_TOS_PRIO_CTRL_14		0x9E
+#define REG_TOS_PRIO_CTRL_15		0x9F
+
+#define TOS_PRIO_M			KS_PRIO_M
+#define TOS_PRIO_S			KS_PRIO_S
+
+#define REG_PORT_1_CTRL_8		0xB0
+#define REG_PORT_2_CTRL_8		0xC0
+#define REG_PORT_3_CTRL_8		0xD0
+#define REG_PORT_4_CTRL_8		0xE0
+#define REG_PORT_5_CTRL_8		0xF0
+
+#define PORT_INS_TAG_FOR_PORT_5_S	3
+#define PORT_INS_TAG_FOR_PORT_5		BIT(3)
+#define PORT_INS_TAG_FOR_PORT_4		BIT(2)
+#define PORT_INS_TAG_FOR_PORT_3		BIT(1)
+#define PORT_INS_TAG_FOR_PORT_2		BIT(0)
+
+#define REG_PORT_1_CTRL_9		0xB1
+#define REG_PORT_2_CTRL_9		0xC1
+#define REG_PORT_3_CTRL_9		0xD1
+#define REG_PORT_4_CTRL_9		0xE1
+#define REG_PORT_5_CTRL_9		0xF1
+
+#define PORT_QUEUE_SPLIT_H		BIT(1)
+#define PORT_QUEUE_SPLIT_1		0
+#define PORT_QUEUE_SPLIT_2		1
+#define PORT_QUEUE_SPLIT_4		2
+#define PORT_DROP_TAG			BIT(0)
+
+#define REG_PORT_1_CTRL_10		0xB2
+#define REG_PORT_2_CTRL_10		0xC2
+#define REG_PORT_3_CTRL_10		0xD2
+#define REG_PORT_4_CTRL_10		0xE2
+#define REG_PORT_5_CTRL_10		0xF2
+#define REG_PORT_1_CTRL_11		0xB3
+#define REG_PORT_2_CTRL_11		0xC3
+#define REG_PORT_3_CTRL_11		0xD3
+#define REG_PORT_4_CTRL_11		0xE3
+#define REG_PORT_5_CTRL_11		0xF3
+#define REG_PORT_1_CTRL_12		0xB4
+#define REG_PORT_2_CTRL_12		0xC4
+#define REG_PORT_3_CTRL_12		0xD4
+#define REG_PORT_4_CTRL_12		0xE4
+#define REG_PORT_5_CTRL_12		0xF4
+#define REG_PORT_1_CTRL_13		0xB5
+#define REG_PORT_2_CTRL_13		0xC5
+#define REG_PORT_3_CTRL_13		0xD5
+#define REG_PORT_4_CTRL_13		0xE5
+#define REG_PORT_5_CTRL_13		0xF5
+
+#define REG_PORT_1_RATE_CTRL_3		0xB2
+#define REG_PORT_1_RATE_CTRL_2		0xB3
+#define REG_PORT_1_RATE_CTRL_1		0xB4
+#define REG_PORT_1_RATE_CTRL_0		0xB5
+#define REG_PORT_2_RATE_CTRL_3		0xC2
+#define REG_PORT_2_RATE_CTRL_2		0xC3
+#define REG_PORT_2_RATE_CTRL_1		0xC4
+#define REG_PORT_2_RATE_CTRL_0		0xC5
+#define REG_PORT_3_RATE_CTRL_3		0xD2
+#define REG_PORT_3_RATE_CTRL_2		0xD3
+#define REG_PORT_3_RATE_CTRL_1		0xD4
+#define REG_PORT_3_RATE_CTRL_0		0xD5
+#define REG_PORT_4_RATE_CTRL_3		0xE2
+#define REG_PORT_4_RATE_CTRL_2		0xE3
+#define REG_PORT_4_RATE_CTRL_1		0xE4
+#define REG_PORT_4_RATE_CTRL_0		0xE5
+#define REG_PORT_5_RATE_CTRL_3		0xF2
+#define REG_PORT_5_RATE_CTRL_2		0xF3
+#define REG_PORT_5_RATE_CTRL_1		0xF4
+#define REG_PORT_5_RATE_CTRL_0		0xF5
+
+#define RATE_CTRL_ENABLE		BIT(7)
+#define RATE_RATIO_M			(BIT(7) - 1)
+
+#define REG_PORT_1_RATE_LIMIT		0xB6
+#define REG_PORT_2_RATE_LIMIT		0xC6
+#define REG_PORT_3_RATE_LIMIT		0xD6
+#define REG_PORT_4_RATE_LIMIT		0xE6
+#define REG_PORT_5_RATE_LIMIT		0xF6
+
+#define PORT_IN_FLOW_CTRL_S		4
+#define PORT_IN_LIMIT_MODE_M		0x3
+#define PORT_IN_LIMIT_MODE_S		2
+#define PORT_COUNT_IFG_S		1
+#define PORT_COUNT_PREAMBLE_S		0
+#define PORT_IN_FLOW_CTRL		BIT(PORT_IN_FLOW_CTRL_S)
+#define PORT_IN_ALL			0
+#define PORT_IN_UNICAST			1
+#define PORT_IN_MULTICAST		2
+#define PORT_IN_BROADCAST		3
+#define PORT_COUNT_IFG			BIT(PORT_COUNT_IFG_S)
+#define PORT_COUNT_PREAMBLE		BIT(PORT_COUNT_PREAMBLE_S)
+
+#define REG_PORT_1_IN_RATE_0		0xB7
+#define REG_PORT_2_IN_RATE_0		0xC7
+#define REG_PORT_3_IN_RATE_0		0xD7
+#define REG_PORT_4_IN_RATE_0		0xE7
+#define REG_PORT_5_IN_RATE_0		0xF7
+#define REG_PORT_1_IN_RATE_1		0xB8
+#define REG_PORT_2_IN_RATE_1		0xC8
+#define REG_PORT_3_IN_RATE_1		0xD8
+#define REG_PORT_4_IN_RATE_1		0xE8
+#define REG_PORT_5_IN_RATE_1		0xF8
+#define REG_PORT_1_IN_RATE_2		0xB9
+#define REG_PORT_2_IN_RATE_2		0xC9
+#define REG_PORT_3_IN_RATE_2		0xD9
+#define REG_PORT_4_IN_RATE_2		0xE9
+#define REG_PORT_5_IN_RATE_2		0xF9
+#define REG_PORT_1_IN_RATE_3		0xBA
+#define REG_PORT_2_IN_RATE_3		0xCA
+#define REG_PORT_3_IN_RATE_3		0xDA
+#define REG_PORT_4_IN_RATE_3		0xEA
+#define REG_PORT_5_IN_RATE_3		0xFA
+
+#define PORT_RATE_LIMIT_M		(BIT(7) - 1)
+
+#define REG_PORT_1_OUT_RATE_0		0xBB
+#define REG_PORT_2_OUT_RATE_0		0xCB
+#define REG_PORT_3_OUT_RATE_0		0xDB
+#define REG_PORT_4_OUT_RATE_0		0xEB
+#define REG_PORT_5_OUT_RATE_0		0xFB
+#define REG_PORT_1_OUT_RATE_1		0xBC
+#define REG_PORT_2_OUT_RATE_1		0xCC
+#define REG_PORT_3_OUT_RATE_1		0xDC
+#define REG_PORT_4_OUT_RATE_1		0xEC
+#define REG_PORT_5_OUT_RATE_1		0xFC
+#define REG_PORT_1_OUT_RATE_2		0xBD
+#define REG_PORT_2_OUT_RATE_2		0xCD
+#define REG_PORT_3_OUT_RATE_2		0xDD
+#define REG_PORT_4_OUT_RATE_2		0xED
+#define REG_PORT_5_OUT_RATE_2		0xFD
+#define REG_PORT_1_OUT_RATE_3		0xBE
+#define REG_PORT_2_OUT_RATE_3		0xCE
+#define REG_PORT_3_OUT_RATE_3		0xDE
+#define REG_PORT_4_OUT_RATE_3		0xEE
+#define REG_PORT_5_OUT_RATE_3		0xFE
+
+#define REG_SW_CFG			0xEF
+
+#define SW_PORT_3_FIBER			BIT(7)
+
+/* KSZ8864 */
+
+#define REG_PHY_PORT_CTRL_1		0xCF
+
+#define PORT_HALF_DUPLEX		BIT(7)
+#define PORT_FLOW_CTRL			BIT(6)
+#define PORT_10_MBIT			BIT(5)
+
+#define REG_PHY_PORT_CTRL_2		0xDF
+
+#define PORT_MII_MAC_MODE		BIT(6)
+
+#define REG_KSZ8864_CHIP_ID		0xFE
+
+#define SW_KSZ8864			BIT(7)
+
+#ifndef PHY_REG_CTRL
+#define PHY_REG_CTRL			0
+
+#define PHY_RESET			BIT(15)
+#define PHY_LOOPBACK			BIT(14)
+#define PHY_SPEED_100MBIT		BIT(13)
+#define PHY_AUTO_NEG_ENABLE		BIT(12)
+#define PHY_POWER_DOWN			BIT(11)
+#define PHY_MII_DISABLE			BIT(10)
+#define PHY_AUTO_NEG_RESTART		BIT(9)
+#define PHY_FULL_DUPLEX			BIT(8)
+#define PHY_COLLISION_TEST_NOT		BIT(7)
+#define PHY_HP_MDIX			BIT(5)
+#define PHY_FORCE_MDIX			BIT(4)
+#define PHY_AUTO_MDIX_DISABLE		BIT(3)
+#define PHY_REMOTE_FAULT_DISABLE	BIT(2)
+#define PHY_TRANSMIT_DISABLE		BIT(1)
+#define PHY_LED_DISABLE			BIT(0)
+
+#define PHY_REG_STATUS			1
+
+#define PHY_100BT4_CAPABLE		BIT(15)
+#define PHY_100BTX_FD_CAPABLE		BIT(14)
+#define PHY_100BTX_CAPABLE		BIT(13)
+#define PHY_10BT_FD_CAPABLE		BIT(12)
+#define PHY_10BT_CAPABLE		BIT(11)
+#define PHY_MII_SUPPRESS_CAPABLE_NOT	BIT(6)
+#define PHY_AUTO_NEG_ACKNOWLEDGE	BIT(5)
+#define PHY_REMOTE_FAULT		BIT(4)
+#define PHY_AUTO_NEG_CAPABLE		BIT(3)
+#define PHY_LINK_STATUS			BIT(2)
+#define PHY_JABBER_DETECT_NOT		BIT(1)
+#define PHY_EXTENDED_CAPABILITY		BIT(0)
+
+#define PHY_REG_ID_1			2
+#define PHY_REG_ID_2			3
+
+#define PHY_REG_AUTO_NEGOTIATION	4
+
+#define PHY_AUTO_NEG_NEXT_PAGE_NOT	BIT(15)
+#define PHY_AUTO_NEG_REMOTE_FAULT_NOT	BIT(13)
+#define PHY_AUTO_NEG_SYM_PAUSE		BIT(10)
+#define PHY_AUTO_NEG_100BT4		BIT(9)
+#define PHY_AUTO_NEG_100BTX_FD		BIT(8)
+#define PHY_AUTO_NEG_100BTX		BIT(7)
+#define PHY_AUTO_NEG_10BT_FD		BIT(6)
+#define PHY_AUTO_NEG_10BT		BIT(5)
+#define PHY_AUTO_NEG_SELECTOR		0x001F
+#define PHY_AUTO_NEG_802_3		0x0001
+
+#define PHY_REG_REMOTE_CAPABILITY	5
+
+#define PHY_REMOTE_NEXT_PAGE_NOT	BIT(15)
+#define PHY_REMOTE_ACKNOWLEDGE_NOT	BIT(14)
+#define PHY_REMOTE_REMOTE_FAULT_NOT	BIT(13)
+#define PHY_REMOTE_SYM_PAUSE		BIT(10)
+#define PHY_REMOTE_100BTX_FD		BIT(8)
+#define PHY_REMOTE_100BTX		BIT(7)
+#define PHY_REMOTE_10BT_FD		BIT(6)
+#define PHY_REMOTE_10BT			BIT(5)
+#endif
+
+#define KSZ8895_ID_HI			0x0022
+
+/* The PHY id 0x1450 is not recognized by the Micrel PHY drivers.
+ * Use 0x1550 from KSZ8795, which is also recognized as KSZ8051 PHY.
+ */
+#define KSZ8895_ID_LO			0x1550
+
+#define PHY_REG_LINK_MD			0x1D
+
+#define PHY_START_CABLE_DIAG		BIT(15)
+#define PHY_CABLE_DIAG_RESULT		0x6000
+#define PHY_CABLE_STAT_NORMAL		0x0000
+#define PHY_CABLE_STAT_OPEN		0x2000
+#define PHY_CABLE_STAT_SHORT		0x4000
+#define PHY_CABLE_STAT_FAILED		0x6000
+#define PHY_CABLE_10M_SHORT		BIT(12)
+#define PHY_CABLE_FAULT_COUNTER		0x01FF
+
+#define PHY_REG_PHY_CTRL		0x1F
+
+#define PHY_MODE_M			0x7
+#define PHY_MODE_S			8
+#define PHY_STAT_REVERSED_POLARITY	BIT(5)
+#define PHY_STAT_MDIX			BIT(4)
+#define PHY_FORCE_LINK			BIT(3)
+#define PHY_POWER_SAVING_ENABLE		BIT(2)
+#define PHY_REMOTE_LOOPBACK		BIT(1)
+
+/* Chip resource */
+
+#define PRIO_QUEUES			4
+
+#define KS_PRIO_IN_REG			4
+
+#define TOTAL_PORT_NUM			5
+
+/* Host port can only be last of them. */
+#define SWITCH_PORT_NUM			(TOTAL_PORT_NUM - 1)
+
+#define KSZ8895_COUNTER_NUM		0x20
+#define TOTAL_KSZ8895_COUNTER_NUM	(KSZ8895_COUNTER_NUM + 2)
+
+#define SWITCH_COUNTER_NUM		KSZ8895_COUNTER_NUM
+#define TOTAL_SWITCH_COUNTER_NUM	TOTAL_KSZ8895_COUNTER_NUM
+
+/* Common names used by other drivers */
+
+#define P_BCAST_STORM_CTRL		REG_PORT_CTRL_0
+#define P_PRIO_CTRL			REG_PORT_CTRL_0
+#define P_TAG_CTRL			REG_PORT_CTRL_0
+#define P_MIRROR_CTRL			REG_PORT_CTRL_1
+#define P_802_1P_CTRL			REG_PORT_CTRL_2
+#define P_STP_CTRL			REG_PORT_CTRL_2
+#define P_LOCAL_CTRL			REG_PORT_CTRL_5
+#define P_REMOTE_STATUS			REG_PORT_STATUS_1
+#define P_FORCE_CTRL			REG_PORT_CTRL_5
+#define P_NEG_RESTART_CTRL		REG_PORT_CTRL_6
+#define P_SPEED_STATUS			REG_PORT_STATUS_0
+#define P_LINK_STATUS			REG_PORT_STATUS_1
+#define P_INS_SRC_PVID_CTRL		REG_PORT_CTRL_8
+#define P_DROP_TAG_CTRL			REG_PORT_CTRL_9
+#define P_RATE_LIMIT_CTRL		REG_PORT_RATE_LIMIT
+
+#define S_FLUSH_TABLE_CTRL		REG_SW_CTRL_0
+#define S_LINK_AGING_CTRL		REG_SW_CTRL_0
+#define S_HUGE_PACKET_CTRL		REG_SW_CTRL_2
+#define S_MIRROR_CTRL			REG_SW_CTRL_3
+#define S_REPLACE_VID_CTRL		REG_SW_CTRL_4
+#define S_PASS_PAUSE_CTRL		REG_SW_CTRL_10
+#define S_TAIL_TAG_CTRL			REG_SW_CTRL_10
+#define S_802_1P_PRIO_CTRL		REG_SW_CTRL_12
+#define S_TOS_PRIO_CTRL			REG_TOS_PRIO_CTRL_0
+#define S_IPV6_MLD_CTRL			REG_SW_CTRL_21
+
+#define IND_ACC_TABLE(table)		((table) << 8)
+
+/* Driver set switch broadcast storm protection at 10% rate. */
+#define BROADCAST_STORM_PROT_RATE	10
+
+/* 148,800 frames * 67 ms / 100 */
+#define BROADCAST_STORM_VALUE		9969
+
+/**
+ * STATIC_MAC_TABLE_ADDR		00-0000FFFF-FFFFFFFF
+ * STATIC_MAC_TABLE_FWD_PORTS		00-001F0000-00000000
+ * STATIC_MAC_TABLE_VALID		00-00200000-00000000
+ * STATIC_MAC_TABLE_OVERRIDE		00-00400000-00000000
+ * STATIC_MAC_TABLE_USE_FID		00-00800000-00000000
+ * STATIC_MAC_TABLE_FID			00-7F000000-00000000
+ */
+
+#define STATIC_MAC_TABLE_ADDR		0x0000FFFF
+#define STATIC_MAC_TABLE_FWD_PORTS	0x001F0000
+#define STATIC_MAC_TABLE_VALID		0x00200000
+#define STATIC_MAC_TABLE_OVERRIDE	0x00400000
+#define STATIC_MAC_TABLE_USE_FID	0x00800000
+#define STATIC_MAC_TABLE_FID		0x7F000000
+
+#define STATIC_MAC_FWD_PORTS_S		16
+#define STATIC_MAC_FID_S		24
+
+/**
+ * VLAN_TABLE_FID			00-00003F81-FC0FE07F
+ * VLAN_TABLE_MEMBERSHIP		00-0007C03E-01F00F80
+ * VLAN_TABLE_VALID			00-00080040-02001000
+ */
+
+#define VLAN_TABLE_FID			0x007F
+#define VLAN_TABLE_MEMBERSHIP		0x0F80
+#define VLAN_TABLE_VALID		0x1000
+
+#define VLAN_TABLE_MEMBERSHIP_S		7
+#define VLAN_TABLE_S			13
+#define VLAN_TABLE_M			(BIT(VLAN_TABLE_S) - 1)
+
+/**
+ * DYNAMIC_MAC_TABLE_ADDR		00-0000FFFF-FFFFFFFF
+ * DYNAMIC_MAC_TABLE_FID		00-007F0000-00000000
+ * DYNAMIC_MAC_TABLE_NOT_READY		00-00800000-00000000
+ * DYNAMIC_MAC_TABLE_SRC_PORT		00-07000000-00000000
+ * DYNAMIC_MAC_TABLE_TIMESTAMP		00-18000000-00000000
+ * DYNAMIC_MAC_TABLE_ENTRIES		7F-E0000000-00000000
+ * DYNAMIC_MAC_TABLE_MAC_EMPTY		80-00000000-00000000
+ */
+
+#define DYNAMIC_MAC_TABLE_ADDR		0x0000FFFF
+#define DYNAMIC_MAC_TABLE_FID		0x007F0000
+#define DYNAMIC_MAC_TABLE_SRC_PORT	0x07000000
+#define DYNAMIC_MAC_TABLE_TIMESTAMP	0x18000000
+#define DYNAMIC_MAC_TABLE_ENTRIES	0xE0000000
+
+#define DYNAMIC_MAC_TABLE_NOT_READY	0x80
+
+#define DYNAMIC_MAC_TABLE_ENTRIES_H	0x7F
+#define DYNAMIC_MAC_TABLE_MAC_EMPTY	0x80
+
+#define DYNAMIC_MAC_FID_S		16
+#define DYNAMIC_MAC_SRC_PORT_S		24
+#define DYNAMIC_MAC_TIMESTAMP_S		27
+#define DYNAMIC_MAC_ENTRIES_S		29
+#define DYNAMIC_MAC_ENTRIES_H_S		3
+
+/**
+ * MIB_COUNTER_VALUE			00-00000000-3FFFFFFF
+ * MIB_PACKET_DROPPED			00-00000000-0000FFFF
+ * MIB_COUNTER_VALID			00-00000000-40000000
+ * MIB_COUNTER_OVERFLOW			00-00000000-80000000
+ */
+
+#define MIB_COUNTER_OVERFLOW		BIT(7)
+#define MIB_COUNTER_VALID		BIT(6)
+
+#define MIB_COUNTER_VALUE		0x3FFFFFFF
+
+#define KS_MIB_PACKET_DROPPED_TX_0	0x100
+#define KS_MIB_PACKET_DROPPED_TX_1	0x101
+#define KS_MIB_PACKET_DROPPED_TX_2	0x102
+#define KS_MIB_PACKET_DROPPED_TX_3	0x103
+#define KS_MIB_PACKET_DROPPED_TX_4	0x104
+#define KS_MIB_PACKET_DROPPED_RX_0	0x105
+#define KS_MIB_PACKET_DROPPED_RX_1	0x106
+#define KS_MIB_PACKET_DROPPED_RX_2	0x107
+#define KS_MIB_PACKET_DROPPED_RX_3	0x108
+#define KS_MIB_PACKET_DROPPED_RX_4	0x109
+
+#define MIB_PACKET_DROPPED		0x0000FFFF
+
+#define TAIL_TAG_OVERRIDE		BIT(6)
+#define TAIL_TAG_LOOKUP			BIT(7)
+
+#define VLAN_TABLE_ENTRIES		(4096 / 4)
+#define FID_ENTRIES			128
+
+#endif
diff --git a/drivers/net/dsa/microchip/ksz8895_spi.c b/drivers/net/dsa/microchip/ksz8895_spi.c
new file mode 100644
index 0000000..b9564e7
--- /dev/null
+++ b/drivers/net/dsa/microchip/ksz8895_spi.c
@@ -0,0 +1,157 @@
+/*
+ * Microchip KSZ8895 series register access through SPI
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
+#include <asm/unaligned.h>
+
+#include <linux/delay.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/spi/spi.h>
+
+#include "ksz_priv.h"
+#include "ksz_spi.h"
+
+/* SPI frame opcodes */
+#define KS_SPIOP_RD			3
+#define KS_SPIOP_WR			2
+
+/* Enough to read all switch registers. */
+#define SPI_TX_BUF_LEN			0x100
+
+static int ksz8895_spi_read_reg(struct spi_device *spi, u8 reg, u8 *val,
+				unsigned int len)
+{
+	u8 txbuf[2];
+	int ret;
+
+	txbuf[0] = KS_SPIOP_RD;
+	txbuf[1] = (u8)reg;
+
+	ret = spi_write_then_read(spi, txbuf, 2, val, len);
+	return ret;
+}
+
+static int ksz8895_spi_write_reg(struct spi_device *spi, u32 reg, u8 *val,
+				 unsigned int len)
+{
+	u8 *txbuf = (u8 *)val;
+
+	txbuf[0] = KS_SPIOP_WR;
+	txbuf[1] = (u8)reg;
+
+	return spi_write(spi, txbuf, 2 + len);
+}
+
+static int ksz_spi_read(struct ksz_device *dev, u32 reg, u8 *data,
+			unsigned int len)
+{
+	struct spi_device *spi = dev->priv;
+
+	return ksz8895_spi_read_reg(spi, reg, data, len);
+}
+
+static int ksz_spi_write(struct ksz_device *dev, u32 reg, void *data,
+			 unsigned int len)
+{
+	struct spi_device *spi = dev->priv;
+
+	if (len > SPI_TX_BUF_LEN)
+		len = SPI_TX_BUF_LEN;
+	memcpy(&dev->txbuf[2], data, len);
+	return ksz8895_spi_write_reg(spi, reg, dev->txbuf, len);
+}
+
+static const struct ksz_io_ops ksz8895_spi_ops = {
+	.read8 = ksz_spi_read8,
+	.read16 = ksz_spi_read16,
+	.read32 = ksz_spi_read32,
+	.write8 = ksz_spi_write8,
+	.write16 = ksz_spi_write16,
+	.write32 = ksz_spi_write32,
+	.get = ksz_spi_get,
+	.set = ksz_spi_set,
+};
+
+static int ksz8895_spi_probe(struct spi_device *spi)
+{
+	struct ksz_device *dev;
+	int ret;
+
+	dev = ksz_switch_alloc(&spi->dev, &ksz8895_spi_ops, spi);
+	if (!dev)
+		return -ENOMEM;
+
+	if (spi->dev.platform_data)
+		dev->pdata = spi->dev.platform_data;
+
+	dev->txbuf = devm_kzalloc(dev->dev, 2 + SPI_TX_BUF_LEN, GFP_KERNEL);
+
+	ret = ksz8895_switch_register(dev);
+
+	/* Main DSA driver may not be started yet. */
+	if (ret)
+		return ret;
+
+	spi_set_drvdata(spi, dev);
+
+	return 0;
+}
+
+static int ksz8895_spi_remove(struct spi_device *spi)
+{
+	struct ksz_device *dev = spi_get_drvdata(spi);
+
+	if (dev)
+		ksz_switch_remove(dev);
+
+	return 0;
+}
+
+static void ksz8895_spi_shutdown(struct spi_device *spi)
+{
+	struct ksz_device *dev = spi_get_drvdata(spi);
+
+	if (dev && dev->dev_ops->shutdown)
+		dev->dev_ops->shutdown(dev);
+}
+
+static const struct of_device_id ksz8895_dt_ids[] = {
+	{ .compatible = "microchip,ksz8895" },
+	{ .compatible = "microchip,ksz8864" },
+	{},
+};
+MODULE_DEVICE_TABLE(of, ksz8895_dt_ids);
+
+static struct spi_driver ksz8895_spi_driver = {
+	.driver = {
+		.name	= "ksz8895-switch",
+		.owner	= THIS_MODULE,
+		.of_match_table = of_match_ptr(ksz8895_dt_ids),
+	},
+	.probe	= ksz8895_spi_probe,
+	.remove	= ksz8895_spi_remove,
+	.shutdown = ksz8895_spi_shutdown,
+};
+
+module_spi_driver(ksz8895_spi_driver);
+
+MODULE_AUTHOR("Tristram Ha <Tristram.Ha@microchip.com>");
+MODULE_DESCRIPTION("Microchip KSZ8895 Series Switch SPI Driver");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/dsa/microchip/ksz_priv.h b/drivers/net/dsa/microchip/ksz_priv.h
index 6cc92ea..6593cb0 100644
--- a/drivers/net/dsa/microchip/ksz_priv.h
+++ b/drivers/net/dsa/microchip/ksz_priv.h
@@ -178,6 +178,7 @@ int ksz_switch_register(struct ksz_device *dev,
 void ksz_switch_remove(struct ksz_device *dev);
 
 int ksz8795_switch_register(struct ksz_device *dev);
+int ksz8895_switch_register(struct ksz_device *dev);
 int ksz9477_switch_register(struct ksz_device *dev);
 
 #endif
-- 
1.9.1
