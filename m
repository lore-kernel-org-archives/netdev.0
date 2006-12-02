From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 05/10] chelsio: add 1G swcixw aupport
Date: Fri, 01 Dec 2006 16:36:17 -0800
Message-ID: <20061202003707.536111000@osdl.org>
References: <20061202003612.573260000@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:55266 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1162425AbWLBAjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 19:39:46 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=chelsio-1g.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for 1G versions of Chelsio devices.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/Kconfig               |    7 
 drivers/net/chelsio/Makefile      |    1 
 drivers/net/chelsio/common.h      |    2 
 drivers/net/chelsio/cxgb2.c       |    1 
 drivers/net/chelsio/ixf1010.c     |  485 +++++++++++++++++++++++++
 drivers/net/chelsio/mac.c         |  368 +++++++++++++++++++
 drivers/net/chelsio/mv88e1xxx.c   |  397 ++++++++++++++++++++
 drivers/net/chelsio/subr.c        |  221 +++++++++++
 drivers/net/chelsio/tp.c          |   33 +
 drivers/net/chelsio/vsc7326.c     |  725 ++++++++++++++++++++++++++++++++++++++
 drivers/net/chelsio/vsc8244.c     |  368 +++++++++++++++++++
 drivers/net/chelsio/vsc8244_reg.h |  172 +++++++++
 12 files changed, 2780 insertions(+)

--- chelsio.orig/drivers/net/chelsio/Makefile
+++ chelsio/drivers/net/chelsio/Makefile
@@ -4,6 +4,7 @@
 
 obj-$(CONFIG_CHELSIO_T1) += cxgb.o
 
+cxgb-$(CONFIG_CHELSIO_T1_1G) += ixf1010.o mac.o mv88e1xxx.o vsc7326.o vsc8244.o
 cxgb-objs := cxgb2.o espi.o tp.o pm3393.o sge.o subr.o \
 	     mv88x201x.o my3126.o $(cxgb-y)
 
--- /dev/null
+++ chelsio/drivers/net/chelsio/ixf1010.c
@@ -0,0 +1,485 @@
+/* $Date: 2005/11/12 02:13:49 $ $RCSfile: ixf1010.c,v $ $Revision: 1.36 $ */
+#include "gmac.h"
+#include "elmer0.h"
+
+/* Update fast changing statistics every 15 seconds */
+#define STATS_TICK_SECS 15
+/* 30 minutes for full statistics update */
+#define MAJOR_UPDATE_TICKS (1800 / STATS_TICK_SECS)
+
+/*
+ * The IXF1010 can handle frames up to 16383 bytes but it's optimized for
+ * frames up to 9831 (0x2667) bytes, so we limit jumbo frame size to this.
+ * This length includes ethernet header and FCS.
+ */
+#define MAX_FRAME_SIZE 0x2667
+
+/* MAC registers */
+enum {
+	/* Per-port registers */
+	REG_MACADDR_LOW = 0,
+	REG_MACADDR_HIGH = 0x4,
+	REG_FDFC_TYPE = 0xC,
+	REG_FC_TX_TIMER_VALUE = 0x1c,
+	REG_IPG_RX_TIME1 = 0x28,
+	REG_IPG_RX_TIME2 = 0x2c,
+	REG_IPG_TX_TIME = 0x30,
+	REG_PAUSE_THRES = 0x38,
+	REG_MAX_FRAME_SIZE = 0x3c,
+	REG_RGMII_SPEED = 0x40,
+	REG_FC_ENABLE = 0x48,
+	REG_DISCARD_CTRL_FRAMES = 0x54,
+	REG_DIVERSE_CONFIG = 0x60,
+	REG_RX_FILTER = 0x64,
+	REG_MC_ADDR_LOW = 0x68,
+	REG_MC_ADDR_HIGH = 0x6c,
+
+	REG_RX_OCTETS_OK = 0x80,
+	REG_RX_OCTETS_BAD = 0x84,
+	REG_RX_UC_PKTS = 0x88,
+	REG_RX_MC_PKTS = 0x8c,
+	REG_RX_BC_PKTS = 0x90,
+	REG_RX_FCS_ERR = 0xb0,
+	REG_RX_TAGGED = 0xb4,
+	REG_RX_DATA_ERR = 0xb8,
+	REG_RX_ALIGN_ERR = 0xbc,
+	REG_RX_LONG_ERR = 0xc0,
+	REG_RX_JABBER_ERR = 0xc4,
+	REG_RX_PAUSE_FRAMES = 0xc8,
+	REG_RX_UNKNOWN_CTRL_FRAMES = 0xcc,
+	REG_RX_VERY_LONG_ERR = 0xd0,
+	REG_RX_RUNT_ERR = 0xd4,
+	REG_RX_SHORT_ERR = 0xd8,
+	REG_RX_SYMBOL_ERR = 0xe4,
+
+	REG_TX_OCTETS_OK = 0x100,
+	REG_TX_OCTETS_BAD = 0x104,
+	REG_TX_UC_PKTS = 0x108,
+	REG_TX_MC_PKTS = 0x10c,
+	REG_TX_BC_PKTS = 0x110,
+	REG_TX_EXCESSIVE_LEN_DROP = 0x14c,
+	REG_TX_UNDERRUN = 0x150,
+	REG_TX_TAGGED = 0x154,
+	REG_TX_PAUSE_FRAMES = 0x15C,
+
+	/* Global registers */
+	REG_PORT_ENABLE = 0x1400,
+
+	REG_JTAG_ID = 0x1430,
+
+	RX_FIFO_HIGH_WATERMARK_BASE = 0x1600,
+	RX_FIFO_LOW_WATERMARK_BASE = 0x1628,
+	RX_FIFO_FRAMES_REMOVED_BASE = 0x1650,
+
+	REG_RX_ERR_DROP = 0x167c,
+	REG_RX_FIFO_OVERFLOW_EVENT = 0x1680,
+
+	TX_FIFO_HIGH_WATERMARK_BASE = 0x1800,
+	TX_FIFO_LOW_WATERMARK_BASE = 0x1828,
+	TX_FIFO_XFER_THRES_BASE = 0x1850,
+
+	REG_TX_FIFO_OVERFLOW_EVENT = 0x1878,
+	REG_TX_FIFO_OOS_EVENT = 0x1884,
+
+	TX_FIFO_FRAMES_REMOVED_BASE = 0x1888,
+
+	REG_SPI_RX_BURST = 0x1c00,
+	REG_SPI_RX_TRAINING = 0x1c04,
+	REG_SPI_RX_CALENDAR = 0x1c08,
+	REG_SPI_TX_SYNC = 0x1c0c
+};
+
+enum {                     /* RMON registers */
+	REG_RxOctetsTotalOK = 0x80,
+	REG_RxOctetsBad = 0x84,
+	REG_RxUCPkts = 0x88,
+	REG_RxMCPkts = 0x8c,
+	REG_RxBCPkts = 0x90,
+	REG_RxJumboPkts = 0xac,
+	REG_RxFCSErrors = 0xb0,
+	REG_RxDataErrors = 0xb8,
+	REG_RxAlignErrors = 0xbc,
+	REG_RxLongErrors = 0xc0,
+	REG_RxJabberErrors = 0xc4,
+	REG_RxPauseMacControlCounter = 0xc8,
+	REG_RxVeryLongErrors = 0xd0,
+	REG_RxRuntErrors = 0xd4,
+	REG_RxShortErrors = 0xd8,
+	REG_RxSequenceErrors = 0xe0,
+	REG_RxSymbolErrors = 0xe4,
+
+	REG_TxOctetsTotalOK = 0x100,
+	REG_TxOctetsBad = 0x104,
+	REG_TxUCPkts = 0x108,
+	REG_TxMCPkts = 0x10c,
+	REG_TxBCPkts = 0x110,
+	REG_TxJumboPkts = 0x12C,
+	REG_TxTotalCollisions = 0x134,
+	REG_TxExcessiveLengthDrop = 0x14c,
+	REG_TxUnderrun = 0x150,
+	REG_TxCRCErrors = 0x158,
+	REG_TxPauseFrames = 0x15c
+};
+
+enum {
+	DIVERSE_CONFIG_PAD_ENABLE = 0x80,
+	DIVERSE_CONFIG_CRC_ADD = 0x40
+};
+
+#define MACREG_BASE            0
+#define MACREG(mac, mac_reg)   ((mac)->instance->mac_base + (mac_reg))
+
+struct _cmac_instance {
+	u32 mac_base;
+	u32 index;
+	u32 version;
+	u32 ticks;
+};
+
+static void disable_port(struct cmac *mac)
+{
+	u32 val;
+
+	t1_tpi_read(mac->adapter, REG_PORT_ENABLE, &val);
+	val &= ~(1 << mac->instance->index);
+	t1_tpi_write(mac->adapter, REG_PORT_ENABLE, val);
+}
+
+#define RMON_UPDATE(mac, name, stat_name) \
+	t1_tpi_read((mac)->adapter, MACREG(mac, REG_##name), &val); \
+	(mac)->stats.stat_name += val;
+
+/*
+ * Read the current values of the RMON counters and add them to the cumulative
+ * port statistics.  The HW RMON counters are cleared by this operation.
+ */
+static void port_stats_update(struct cmac *mac)
+{
+	u32 val;
+
+	/* Rx stats */
+	RMON_UPDATE(mac, RxOctetsTotalOK, RxOctetsOK);
+	RMON_UPDATE(mac, RxOctetsBad, RxOctetsBad);
+	RMON_UPDATE(mac, RxUCPkts, RxUnicastFramesOK);
+	RMON_UPDATE(mac, RxMCPkts, RxMulticastFramesOK);
+	RMON_UPDATE(mac, RxBCPkts, RxBroadcastFramesOK);
+	RMON_UPDATE(mac, RxJumboPkts, RxJumboFramesOK);
+	RMON_UPDATE(mac, RxFCSErrors, RxFCSErrors);
+	RMON_UPDATE(mac, RxAlignErrors, RxAlignErrors);
+	RMON_UPDATE(mac, RxLongErrors, RxFrameTooLongErrors);
+	RMON_UPDATE(mac, RxVeryLongErrors, RxFrameTooLongErrors);
+	RMON_UPDATE(mac, RxPauseMacControlCounter, RxPauseFrames);
+	RMON_UPDATE(mac, RxDataErrors, RxDataErrors);
+	RMON_UPDATE(mac, RxJabberErrors, RxJabberErrors);
+	RMON_UPDATE(mac, RxRuntErrors, RxRuntErrors);
+	RMON_UPDATE(mac, RxShortErrors, RxRuntErrors);
+	RMON_UPDATE(mac, RxSequenceErrors, RxSequenceErrors);
+	RMON_UPDATE(mac, RxSymbolErrors, RxSymbolErrors);
+
+	/* Tx stats (skip collision stats as we are full-duplex only) */
+	RMON_UPDATE(mac, TxOctetsTotalOK, TxOctetsOK);
+	RMON_UPDATE(mac, TxOctetsBad, TxOctetsBad);
+	RMON_UPDATE(mac, TxUCPkts, TxUnicastFramesOK);
+	RMON_UPDATE(mac, TxMCPkts, TxMulticastFramesOK);
+	RMON_UPDATE(mac, TxBCPkts, TxBroadcastFramesOK);
+	RMON_UPDATE(mac, TxJumboPkts, TxJumboFramesOK);
+	RMON_UPDATE(mac, TxPauseFrames, TxPauseFrames);
+	RMON_UPDATE(mac, TxExcessiveLengthDrop, TxLengthErrors);
+	RMON_UPDATE(mac, TxUnderrun, TxUnderrun);
+	RMON_UPDATE(mac, TxCRCErrors, TxFCSErrors);
+}
+
+/* No-op interrupt operation as this MAC does not support interrupts */
+static int mac_intr_op(struct cmac *mac)
+{
+	return 0;
+}
+
+/* Expect MAC address to be in network byte order. */
+static int mac_set_address(struct cmac *mac, u8 addr[6])
+{
+	u32 addr_lo, addr_hi;
+
+	addr_lo = addr[2];
+	addr_lo = (addr_lo << 8) | addr[3];
+	addr_lo = (addr_lo << 8) | addr[4];
+	addr_lo = (addr_lo << 8) | addr[5];
+
+	addr_hi = addr[0];
+	addr_hi = (addr_hi << 8) | addr[1];
+
+	t1_tpi_write(mac->adapter, MACREG(mac, REG_MACADDR_LOW), addr_lo);
+	t1_tpi_write(mac->adapter, MACREG(mac, REG_MACADDR_HIGH), addr_hi);
+	return 0;
+}
+
+static int mac_get_address(struct cmac *mac, u8 addr[6])
+{
+	u32 addr_lo, addr_hi;
+
+	t1_tpi_read(mac->adapter, MACREG(mac, REG_MACADDR_LOW), &addr_lo);
+	t1_tpi_read(mac->adapter, MACREG(mac, REG_MACADDR_HIGH), &addr_hi);
+
+	addr[0] = (u8) (addr_hi >> 8);
+	addr[1] = (u8) addr_hi;
+	addr[2] = (u8) (addr_lo >> 24);
+	addr[3] = (u8) (addr_lo >> 16);
+	addr[4] = (u8) (addr_lo >> 8);
+	addr[5] = (u8) addr_lo;
+	return 0;
+}
+
+/* This is intended to reset a port, not the whole MAC */
+static int mac_reset(struct cmac *mac)
+{
+	return 0;
+}
+
+static int mac_set_rx_mode(struct cmac *mac, struct t1_rx_mode *rm)
+{
+	u32 val, new_mode;
+	adapter_t *adapter = mac->adapter;
+	u32 addr_lo, addr_hi;
+	u8 *addr;
+
+	t1_tpi_read(adapter, MACREG(mac, REG_RX_FILTER), &val);
+	new_mode = val & ~7;
+	if (!t1_rx_mode_promisc(rm) && mac->instance->version > 0)
+		new_mode |= 1;     /* only set if version > 0 due to erratum */
+	if (!t1_rx_mode_promisc(rm) && !t1_rx_mode_allmulti(rm)
+	     && t1_rx_mode_mc_cnt(rm) <= 1)
+		new_mode |= 2;
+	if (new_mode != val)
+		t1_tpi_write(adapter, MACREG(mac, REG_RX_FILTER), new_mode);
+	switch (t1_rx_mode_mc_cnt(rm)) {
+	case 0:
+		t1_tpi_write(adapter, MACREG(mac, REG_MC_ADDR_LOW), 0);
+		t1_tpi_write(adapter, MACREG(mac, REG_MC_ADDR_HIGH), 0);
+		break;
+	case 1:
+		addr = t1_get_next_mcaddr(rm);
+		addr_lo = (addr[2] << 24) | (addr[3] << 16) | (addr[4] << 8) |
+			addr[5];
+		addr_hi = (addr[0] << 8) | addr[1];
+		t1_tpi_write(adapter, MACREG(mac, REG_MC_ADDR_LOW), addr_lo);
+		t1_tpi_write(adapter, MACREG(mac, REG_MC_ADDR_HIGH), addr_hi);
+		break;
+	default:
+		break;
+	}
+	return 0;
+}
+
+static int mac_set_mtu(struct cmac *mac, int mtu)
+{
+	/* MAX_FRAME_SIZE inludes header + FCS, mtu doesn't */
+	if (mtu > (MAX_FRAME_SIZE - 14 - 4)) return -EINVAL;
+	t1_tpi_write(mac->adapter, MACREG(mac, REG_MAX_FRAME_SIZE),
+		     mtu + 14 + 4);
+	return 0;
+}
+
+static int mac_set_speed_duplex_fc(struct cmac *mac, int speed, int duplex,
+				   int fc)
+{
+	u32 val;
+
+	if (speed >= 0 && speed != SPEED_100 && speed != SPEED_1000)
+		return -1;
+	if (duplex >= 0 && duplex != DUPLEX_FULL)
+		return -1;
+
+	if (speed >= 0) {
+		val = speed == SPEED_100 ? 1 : 2;
+		t1_tpi_write(mac->adapter, MACREG(mac, REG_RGMII_SPEED), val);
+	}
+
+	t1_tpi_read(mac->adapter, MACREG(mac, REG_FC_ENABLE), &val);
+	val &= ~3;
+	if (fc & PAUSE_RX)
+		val |= 1;
+	if (fc & PAUSE_TX)
+		val |= 2;
+	t1_tpi_write(mac->adapter, MACREG(mac, REG_FC_ENABLE), val);
+	return 0;
+}
+
+static int mac_get_speed_duplex_fc(struct cmac *mac, int *speed, int *duplex,
+				   int *fc)
+{
+	u32 val;
+
+	if (duplex)
+		*duplex = DUPLEX_FULL;
+	if (speed) {
+		t1_tpi_read(mac->adapter, MACREG(mac, REG_RGMII_SPEED),
+			 &val);
+		*speed = (val & 2) ? SPEED_1000 : SPEED_100;
+	}
+	if (fc) {
+		t1_tpi_read(mac->adapter, MACREG(mac, REG_FC_ENABLE), &val);
+		*fc = 0;
+		if (val & 1)
+			*fc |= PAUSE_RX;
+		if (val & 2)
+			*fc |= PAUSE_TX;
+	}
+	return 0;
+}
+
+static void enable_port(struct cmac *mac)
+{
+	u32 val;
+	u32 index = mac->instance->index;
+	adapter_t *adapter = mac->adapter;
+
+	t1_tpi_read(adapter, MACREG(mac, REG_DIVERSE_CONFIG), &val);
+	val |= DIVERSE_CONFIG_CRC_ADD | DIVERSE_CONFIG_PAD_ENABLE;
+	t1_tpi_write(adapter, MACREG(mac, REG_DIVERSE_CONFIG), val);
+	if (mac->instance->version > 0)
+		t1_tpi_write(adapter, MACREG(mac, REG_RX_FILTER), 3);
+	else /* Don't enable unicast address filtering due to IXF1010 bug */
+		t1_tpi_write(adapter, MACREG(mac, REG_RX_FILTER), 2);
+
+	t1_tpi_read(adapter, REG_RX_ERR_DROP, &val);
+	val |= (1 << index);
+	t1_tpi_write(adapter, REG_RX_ERR_DROP, val);
+
+	/*
+	 * Clear the port RMON registers by adding their current values to the
+	 * cumulatice port stats and then clearing the stats.  Really.
+	 */
+	port_stats_update(mac);
+	memset(&mac->stats, 0, sizeof(struct cmac_statistics));
+	mac->instance->ticks = 0;
+
+	t1_tpi_read(adapter, REG_PORT_ENABLE, &val);
+	val |= (1 << index);
+	t1_tpi_write(adapter, REG_PORT_ENABLE, val);
+
+       	index <<= 2;
+        if (is_T2(adapter)) {
+		/* T204: set the Fifo water level & threshold */
+		t1_tpi_write(adapter, RX_FIFO_HIGH_WATERMARK_BASE + index, 0x740);
+		t1_tpi_write(adapter, RX_FIFO_LOW_WATERMARK_BASE + index, 0x730);
+		t1_tpi_write(adapter, TX_FIFO_HIGH_WATERMARK_BASE + index, 0x600);
+		t1_tpi_write(adapter, TX_FIFO_LOW_WATERMARK_BASE + index, 0x1d0);
+		t1_tpi_write(adapter, TX_FIFO_XFER_THRES_BASE + index, 0x1100);
+	} else {
+	/*
+	 * Set the TX Fifo Threshold to 0x400 instead of 0x100 to work around
+	 * Underrun problem. Intel has blessed this solution.
+	 */
+		t1_tpi_write(adapter, TX_FIFO_XFER_THRES_BASE + index, 0x400);
+	}
+}
+
+/* IXF1010 ports do not have separate enables for TX and RX */
+static int mac_enable(struct cmac *mac, int which)
+{
+	if (which & (MAC_DIRECTION_RX | MAC_DIRECTION_TX))
+		enable_port(mac);
+	return 0;
+}
+
+static int mac_disable(struct cmac *mac, int which)
+{
+	if (which & (MAC_DIRECTION_RX | MAC_DIRECTION_TX))
+		disable_port(mac);
+	return 0;
+}
+
+/*
+ * This function is called periodically to accumulate the current values of the
+ * RMON counters into the port statistics.  Since the counters are only 32 bits
+ * some of them can overflow in less than a minute at GigE speeds, so this
+ * function should be called every 30 seconds or so.
+ *
+ * To cut down on reading costs we update only the octet counters at each tick
+ * and do a full update at major ticks, which can be every 30 minutes or more.
+ */
+static const struct cmac_statistics *mac_update_statistics(struct cmac *mac,
+							   int flag)
+{
+	if (flag == MAC_STATS_UPDATE_FULL ||
+	    MAJOR_UPDATE_TICKS <= mac->instance->ticks) {
+		port_stats_update(mac);
+		mac->instance->ticks = 0;
+	} else {
+		u32 val;
+
+		RMON_UPDATE(mac, RxOctetsTotalOK, RxOctetsOK);
+		RMON_UPDATE(mac, TxOctetsTotalOK, TxOctetsOK);
+		mac->instance->ticks++;
+	}
+	return &mac->stats;
+}
+
+static void mac_destroy(struct cmac *mac)
+{
+	kfree(mac);
+}
+
+static struct cmac_ops ixf1010_ops = {
+	.destroy                  = mac_destroy,
+	.reset                    = mac_reset,
+	.interrupt_enable         = mac_intr_op,
+	.interrupt_disable        = mac_intr_op,
+	.interrupt_clear          = mac_intr_op,
+	.enable                   = mac_enable,
+	.disable                  = mac_disable,
+	.set_mtu                  = mac_set_mtu,
+	.set_rx_mode              = mac_set_rx_mode,
+	.set_speed_duplex_fc      = mac_set_speed_duplex_fc,
+	.get_speed_duplex_fc      = mac_get_speed_duplex_fc,
+	.statistics_update        = mac_update_statistics,
+	.macaddress_get           = mac_get_address,
+	.macaddress_set           = mac_set_address,
+};
+
+static int ixf1010_mac_reset(adapter_t *adapter)
+{
+	u32 val;
+
+	t1_tpi_read(adapter, A_ELMER0_GPO, &val);
+	if ((val & 1) != 0) {
+		val &= ~1;
+		t1_tpi_write(adapter, A_ELMER0_GPO, val);
+		udelay(2);
+	}
+	val |= 1;
+	t1_tpi_write(adapter, A_ELMER0_GPO, val);
+	udelay(2);
+
+	t1_tpi_write(adapter, REG_PORT_ENABLE, 0);
+	return 0;
+}
+
+static struct cmac *ixf1010_mac_create(adapter_t *adapter, int index)
+{
+	struct cmac *mac;
+	u32 val;
+
+	if (index > 9) return NULL;
+
+	mac = kzalloc(sizeof(*mac) + sizeof(cmac_instance), GFP_KERNEL);
+	if (!mac) return NULL;
+
+	mac->ops = &ixf1010_ops;
+	mac->instance = (cmac_instance *)(mac + 1);
+
+	mac->instance->mac_base = MACREG_BASE + (index * 0x200);
+	mac->instance->index    = index;
+	mac->adapter  = adapter;
+	mac->instance->ticks    = 0;
+
+	t1_tpi_read(adapter, REG_JTAG_ID, &val);
+	mac->instance->version = val >> 28;
+	return mac;
+}
+
+struct gmac t1_ixf1010_ops = {
+	STATS_TICK_SECS,
+	ixf1010_mac_create,
+	ixf1010_mac_reset
+};
--- /dev/null
+++ chelsio/drivers/net/chelsio/mac.c
@@ -0,0 +1,368 @@
+/* $Date: 2005/10/22 00:42:59 $ $RCSfile: mac.c,v $ $Revision: 1.32 $ */
+#include "gmac.h"
+#include "regs.h"
+#include "fpga_defs.h"
+
+#define MAC_CSR_INTERFACE_GMII      0x0
+#define MAC_CSR_INTERFACE_TBI       0x1
+#define MAC_CSR_INTERFACE_MII       0x2
+#define MAC_CSR_INTERFACE_RMII      0x3
+
+/* Chelsio's MAC statistics. */
+struct mac_statistics {
+
+	/* Transmit */
+	u32 TxFramesTransmittedOK;
+	u32 TxReserved1;
+	u32 TxReserved2;
+	u32 TxOctetsTransmittedOK;
+	u32 TxFramesWithDeferredXmissions;
+	u32 TxLateCollisions;
+	u32 TxFramesAbortedDueToXSCollisions;
+	u32 TxFramesLostDueToIntMACXmitError;
+	u32 TxReserved3;
+	u32 TxMulticastFrameXmittedOK;
+	u32 TxBroadcastFramesXmittedOK;
+	u32 TxFramesWithExcessiveDeferral;
+	u32 TxPAUSEMACCtrlFramesTransmitted;
+
+	/* Receive */
+	u32 RxFramesReceivedOK;
+	u32 RxFrameCheckSequenceErrors;
+	u32 RxAlignmentErrors;
+	u32 RxOctetsReceivedOK;
+	u32 RxFramesLostDueToIntMACRcvError;
+	u32 RxMulticastFramesReceivedOK;
+	u32 RxBroadcastFramesReceivedOK;
+	u32 RxInRangeLengthErrors;
+	u32 RxTxOutOfRangeLengthField;
+	u32 RxFrameTooLongErrors;
+	u32 RxPAUSEMACCtrlFramesReceived;
+};
+
+static int static_aPorts[] = {
+	FPGA_GMAC_INTERRUPT_PORT0,
+	FPGA_GMAC_INTERRUPT_PORT1,
+	FPGA_GMAC_INTERRUPT_PORT2,
+	FPGA_GMAC_INTERRUPT_PORT3
+};
+
+struct _cmac_instance {
+	u32 index;
+};
+
+static int mac_intr_enable(struct cmac *mac)
+{
+	u32 mac_intr;
+
+	if (t1_is_asic(mac->adapter)) {
+		/* ASIC */
+
+		/* We don't use the on chip MAC for ASIC products. */
+	} else {
+		/* FPGA */
+
+		/* Set parent gmac interrupt. */
+		mac_intr = readl(mac->adapter->regs + A_PL_ENABLE);
+		mac_intr |= FPGA_PCIX_INTERRUPT_GMAC;
+		writel(mac_intr, mac->adapter->regs + A_PL_ENABLE);
+
+		mac_intr = readl(mac->adapter->regs + FPGA_GMAC_ADDR_INTERRUPT_ENABLE);
+		mac_intr |= static_aPorts[mac->instance->index];
+		writel(mac_intr,
+		       mac->adapter->regs + FPGA_GMAC_ADDR_INTERRUPT_ENABLE);
+	}
+
+	return 0;
+}
+
+static int mac_intr_disable(struct cmac *mac)
+{
+	u32 mac_intr;
+
+	if (t1_is_asic(mac->adapter)) {
+		/* ASIC */
+
+		/* We don't use the on chip MAC for ASIC products. */
+	} else {
+		/* FPGA */
+
+		/* Set parent gmac interrupt. */
+		mac_intr = readl(mac->adapter->regs + A_PL_ENABLE);
+		mac_intr &= ~FPGA_PCIX_INTERRUPT_GMAC;
+		writel(mac_intr, mac->adapter->regs + A_PL_ENABLE);
+
+		mac_intr = readl(mac->adapter->regs + FPGA_GMAC_ADDR_INTERRUPT_ENABLE);
+		mac_intr &= ~(static_aPorts[mac->instance->index]);
+		writel(mac_intr,
+		       mac->adapter->regs + FPGA_GMAC_ADDR_INTERRUPT_ENABLE);
+	}
+
+	return 0;
+}
+
+static int mac_intr_clear(struct cmac *mac)
+{
+	u32 mac_intr;
+
+	if (t1_is_asic(mac->adapter)) {
+		/* ASIC */
+
+		/* We don't use the on chip MAC for ASIC products. */
+	} else {
+		/* FPGA */
+
+		/* Set parent gmac interrupt. */
+		writel(FPGA_PCIX_INTERRUPT_GMAC,
+		       mac->adapter->regs +  A_PL_CAUSE);
+		mac_intr = readl(mac->adapter->regs + FPGA_GMAC_ADDR_INTERRUPT_CAUSE);
+		mac_intr |= (static_aPorts[mac->instance->index]);
+		writel(mac_intr,
+		       mac->adapter->regs + FPGA_GMAC_ADDR_INTERRUPT_CAUSE);
+	}
+
+	return 0;
+}
+
+static int mac_get_address(struct cmac *mac, u8 addr[6])
+{
+	u32 data32_lo, data32_hi;
+
+	data32_lo = readl(mac->adapter->regs
+			  + MAC_REG_IDLO(mac->instance->index));
+	data32_hi = readl(mac->adapter->regs
+			  + MAC_REG_IDHI(mac->instance->index));
+
+	addr[0] = (u8) ((data32_hi >> 8) & 0xFF);
+	addr[1] = (u8) ((data32_hi) & 0xFF);
+	addr[2] = (u8) ((data32_lo >> 24) & 0xFF);
+	addr[3] = (u8) ((data32_lo >> 16) & 0xFF);
+	addr[4] = (u8) ((data32_lo >> 8) & 0xFF);
+	addr[5] = (u8) ((data32_lo) & 0xFF);
+	return 0;
+}
+
+static int mac_reset(struct cmac *mac)
+{
+	u32 data32;
+	int mac_in_reset, time_out = 100;
+	int idx = mac->instance->index;
+
+	data32 = readl(mac->adapter->regs + MAC_REG_CSR(idx));
+	writel(data32 | F_MAC_RESET,
+	       mac->adapter->regs + MAC_REG_CSR(idx));
+
+	do {
+		data32 = readl(mac->adapter->regs + MAC_REG_CSR(idx));
+
+		mac_in_reset = data32 & F_MAC_RESET;
+		if (mac_in_reset)
+			udelay(1);
+	} while (mac_in_reset && --time_out);
+
+	if (mac_in_reset) {
+		CH_ERR("%s: MAC %d reset timed out\n",
+		       mac->adapter->name, idx);
+		return 2;
+	}
+
+	return 0;
+}
+
+static int mac_set_rx_mode(struct cmac *mac, struct t1_rx_mode *rm)
+{
+	u32 val;
+
+	val = readl(mac->adapter->regs
+			    + MAC_REG_CSR(mac->instance->index));
+	val &= ~(F_MAC_PROMISC | F_MAC_MC_ENABLE);
+	val |= V_MAC_PROMISC(t1_rx_mode_promisc(rm) != 0);
+	val |= V_MAC_MC_ENABLE(t1_rx_mode_allmulti(rm) != 0);
+	writel(val,
+	       mac->adapter->regs + MAC_REG_CSR(mac->instance->index));
+
+	return 0;
+}
+
+static int mac_set_speed_duplex_fc(struct cmac *mac, int speed, int duplex,
+				   int fc)
+{
+	u32 data32;
+
+	data32 = readl(mac->adapter->regs
+			       + MAC_REG_CSR(mac->instance->index));
+	data32 &= ~(F_MAC_HALF_DUPLEX | V_MAC_SPEED(M_MAC_SPEED) |
+		V_INTERFACE(M_INTERFACE) | F_MAC_TX_PAUSE_ENABLE |
+		F_MAC_RX_PAUSE_ENABLE);
+
+	switch (speed) {
+	case SPEED_10:
+	case SPEED_100:
+		data32 |= V_INTERFACE(MAC_CSR_INTERFACE_MII);
+		data32 |= V_MAC_SPEED(speed == SPEED_10 ? 0 : 1);
+		break;
+	case SPEED_1000:
+		data32 |= V_INTERFACE(MAC_CSR_INTERFACE_GMII);
+		data32 |= V_MAC_SPEED(2);
+		break;
+	}
+
+	if (duplex >= 0)
+		data32 |= V_MAC_HALF_DUPLEX(duplex == DUPLEX_HALF);
+
+	if (fc >= 0) {
+		data32 |= V_MAC_RX_PAUSE_ENABLE((fc & PAUSE_RX) != 0);
+		data32 |= V_MAC_TX_PAUSE_ENABLE((fc & PAUSE_TX) != 0);
+	}
+
+	writel(data32,
+	       mac->adapter->regs + MAC_REG_CSR(mac->instance->index));
+	return 0;
+}
+
+static int mac_enable(struct cmac *mac, int which)
+{
+	u32 val;
+
+	val = readl(mac->adapter->regs
+			    + MAC_REG_CSR(mac->instance->index));
+	if (which & MAC_DIRECTION_RX)
+		val |= F_MAC_RX_ENABLE;
+	if (which & MAC_DIRECTION_TX)
+		val |= F_MAC_TX_ENABLE;
+	writel(val,
+	       mac->adapter->regs + MAC_REG_CSR(mac->instance->index));
+	return 0;
+}
+
+static int mac_disable(struct cmac *mac, int which)
+{
+	u32 val;
+
+	val = readl(mac->adapter->regs
+			    + MAC_REG_CSR(mac->instance->index));
+	if (which & MAC_DIRECTION_RX)
+		val &= ~F_MAC_RX_ENABLE;
+	if (which & MAC_DIRECTION_TX)
+		val &= ~F_MAC_TX_ENABLE;
+	writel(val,
+	       mac->adapter->regs + MAC_REG_CSR(mac->instance->index));
+	return 0;
+}
+
+#if 0
+static int mac_set_ifs(struct cmac *mac, u32 mode)
+{
+	t1_write_reg_4(mac->adapter,
+		       MAC_REG_IFS(mac->instance->index),
+		       mode);
+	return 0;
+}
+
+static int mac_enable_isl(struct cmac *mac)
+{
+	u32 data32 = readl(mac->adapter->regs
+				   + MAC_REG_CSR(mac->instance->index));
+	data32 |= F_MAC_RX_ENABLE | F_MAC_TX_ENABLE;
+	t1_write_reg_4(mac->adapter,
+		       MAC_REG_CSR(mac->instance->index),
+		       data32);
+	return 0;
+}
+#endif
+
+static int mac_set_mtu(struct cmac *mac, int mtu)
+{
+	if (mtu > 9600)
+		return -EINVAL;
+	writel(mtu + ETH_HLEN + VLAN_HLEN,
+	       mac->adapter->regs + MAC_REG_LARGEFRAMELENGTH(mac->instance->index));
+
+	return 0;
+}
+
+static const struct cmac_statistics *mac_update_statistics(struct cmac *mac,
+							   int flag)
+{
+	struct mac_statistics st;
+	u32 *p = (u32 *) & st, i;
+
+	writel(0,
+	       mac->adapter->regs + MAC_REG_RMCNT(mac->instance->index));
+
+	for (i = 0; i < sizeof(st) / sizeof(u32); i++)
+		*p++ = readl(mac->adapter->regs
+			     + MAC_REG_RMDATA(mac->instance->index));
+
+	/* XXX convert stats */
+	return &mac->stats;
+}
+
+static void mac_destroy(struct cmac *mac)
+{
+	kfree(mac);
+}
+
+static struct cmac_ops chelsio_mac_ops = {
+	.destroy                 = mac_destroy,
+	.reset                   = mac_reset,
+	.interrupt_enable        = mac_intr_enable,
+	.interrupt_disable       = mac_intr_disable,
+	.interrupt_clear         = mac_intr_clear,
+	.enable                  = mac_enable,
+	.disable                 = mac_disable,
+	.set_mtu                 = mac_set_mtu,
+	.set_rx_mode             = mac_set_rx_mode,
+	.set_speed_duplex_fc     = mac_set_speed_duplex_fc,
+	.macaddress_get          = mac_get_address,
+	.statistics_update       = mac_update_statistics,
+};
+
+static struct cmac *mac_create(adapter_t *adapter, int index)
+{
+	struct cmac *mac;
+	u32 data32;
+
+	if (index >= 4)
+		return NULL;
+
+	mac = kzalloc(sizeof(*mac) + sizeof(cmac_instance), GFP_KERNEL);
+	if (!mac)
+		return NULL;
+
+	mac->ops = &chelsio_mac_ops;
+	mac->instance = (cmac_instance *) (mac + 1);
+
+	mac->instance->index = index;
+	mac->adapter = adapter;
+
+	data32 = readl(adapter->regs + MAC_REG_CSR(mac->instance->index));
+	data32 &= ~(F_MAC_RESET | F_MAC_PROMISC | F_MAC_PROMISC |
+		    F_MAC_LB_ENABLE | F_MAC_RX_ENABLE | F_MAC_TX_ENABLE);
+	data32 |= F_MAC_JUMBO_ENABLE;
+	writel(data32, adapter->regs + MAC_REG_CSR(mac->instance->index));
+
+	/* Initialize the random backoff seed. */
+	data32 = 0x55aa + (3 * index);
+	writel(data32,
+	       adapter->regs + MAC_REG_GMRANDBACKOFFSEED(mac->instance->index));
+
+	/* Check to see if the mac address needs to be set manually. */
+	data32 = readl(adapter->regs + MAC_REG_IDLO(mac->instance->index));
+	if (data32 == 0 || data32 == 0xffffffff) {
+		/*
+		 * Add a default MAC address if we can't read one.
+		 */
+		writel(0x43FFFFFF - index,
+		       adapter->regs + MAC_REG_IDLO(mac->instance->index));
+		writel(0x0007,
+		       adapter->regs + MAC_REG_IDHI(mac->instance->index));
+	}
+
+	(void) mac_set_mtu(mac, 1500);
+	return mac;
+}
+
+struct gmac t1_chelsio_mac_ops = {
+	.create = mac_create
+};
--- /dev/null
+++ chelsio/drivers/net/chelsio/mv88e1xxx.c
@@ -0,0 +1,397 @@
+/* $Date: 2005/10/24 23:18:13 $ $RCSfile: mv88e1xxx.c,v $ $Revision: 1.49 $ */
+#include "common.h"
+#include "mv88e1xxx.h"
+#include "cphy.h"
+#include "elmer0.h"
+
+/* MV88E1XXX MDI crossover register values */
+#define CROSSOVER_MDI   0
+#define CROSSOVER_MDIX  1
+#define CROSSOVER_AUTO  3
+
+#define INTR_ENABLE_MASK 0x6CA0
+
+/*
+ * Set the bits given by 'bitval' in PHY register 'reg'.
+ */
+static void mdio_set_bit(struct cphy *cphy, int reg, u32 bitval)
+{
+	u32 val;
+
+	(void) simple_mdio_read(cphy, reg, &val);
+	(void) simple_mdio_write(cphy, reg, val | bitval);
+}
+
+/*
+ * Clear the bits given by 'bitval' in PHY register 'reg'.
+ */
+static void mdio_clear_bit(struct cphy *cphy, int reg, u32 bitval)
+{
+	u32 val;
+
+	(void) simple_mdio_read(cphy, reg, &val);
+	(void) simple_mdio_write(cphy, reg, val & ~bitval);
+}
+
+/*
+ * NAME:   phy_reset
+ *
+ * DESC:   Reset the given PHY's port. NOTE: This is not a global
+ *         chip reset.
+ *
+ * PARAMS: cphy     - Pointer to PHY instance data.
+ *
+ * RETURN:  0 - Successfull reset.
+ *         -1 - Timeout.
+ */
+static int mv88e1xxx_reset(struct cphy *cphy, int wait)
+{
+	u32 ctl;
+	int time_out = 1000;
+
+	mdio_set_bit(cphy, MII_BMCR, BMCR_RESET);
+
+	do {
+		(void) simple_mdio_read(cphy, MII_BMCR, &ctl);
+		ctl &= BMCR_RESET;
+		if (ctl)
+			udelay(1);
+	} while (ctl && --time_out);
+
+	return ctl ? -1 : 0;
+}
+
+static int mv88e1xxx_interrupt_enable(struct cphy *cphy)
+{
+	/* Enable PHY interrupts. */
+	(void) simple_mdio_write(cphy, MV88E1XXX_INTERRUPT_ENABLE_REGISTER,
+		   INTR_ENABLE_MASK);
+
+	/* Enable Marvell interrupts through Elmer0. */
+	if (t1_is_asic(cphy->adapter)) {
+		u32 elmer;
+
+		t1_tpi_read(cphy->adapter, A_ELMER0_INT_ENABLE, &elmer);
+		elmer |= ELMER0_GP_BIT1;
+		if (is_T2(cphy->adapter)) {
+		    elmer |= ELMER0_GP_BIT2|ELMER0_GP_BIT3|ELMER0_GP_BIT4;
+                }
+		t1_tpi_write(cphy->adapter, A_ELMER0_INT_ENABLE, elmer);
+	}
+	return 0;
+}
+
+static int mv88e1xxx_interrupt_disable(struct cphy *cphy)
+{
+	/* Disable all phy interrupts. */
+	(void) simple_mdio_write(cphy, MV88E1XXX_INTERRUPT_ENABLE_REGISTER, 0);
+
+	/* Disable Marvell interrupts through Elmer0. */
+	if (t1_is_asic(cphy->adapter)) {
+		u32 elmer;
+
+		t1_tpi_read(cphy->adapter, A_ELMER0_INT_ENABLE, &elmer);
+		elmer &= ~ELMER0_GP_BIT1;
+		if (is_T2(cphy->adapter)) {
+		    elmer &= ~(ELMER0_GP_BIT2|ELMER0_GP_BIT3|ELMER0_GP_BIT4);
+                }
+		t1_tpi_write(cphy->adapter, A_ELMER0_INT_ENABLE, elmer);
+	}
+	return 0;
+}
+
+static int mv88e1xxx_interrupt_clear(struct cphy *cphy)
+{
+	u32 elmer;
+
+	/* Clear PHY interrupts by reading the register. */
+	(void) simple_mdio_read(cphy,
+			MV88E1XXX_INTERRUPT_STATUS_REGISTER, &elmer);
+
+	/* Clear Marvell interrupts through Elmer0. */
+	if (t1_is_asic(cphy->adapter)) {
+		t1_tpi_read(cphy->adapter, A_ELMER0_INT_CAUSE, &elmer);
+		elmer |= ELMER0_GP_BIT1;
+		if (is_T2(cphy->adapter)) {
+		    elmer |= ELMER0_GP_BIT2|ELMER0_GP_BIT3|ELMER0_GP_BIT4;
+                }
+		t1_tpi_write(cphy->adapter, A_ELMER0_INT_CAUSE, elmer);
+	}
+	return 0;
+}
+
+/*
+ * Set the PHY speed and duplex.  This also disables auto-negotiation, except
+ * for 1Gb/s, where auto-negotiation is mandatory.
+ */
+static int mv88e1xxx_set_speed_duplex(struct cphy *phy, int speed, int duplex)
+{
+	u32 ctl;
+
+	(void) simple_mdio_read(phy, MII_BMCR, &ctl);
+	if (speed >= 0) {
+		ctl &= ~(BMCR_SPEED100 | BMCR_SPEED1000 | BMCR_ANENABLE);
+		if (speed == SPEED_100)
+			ctl |= BMCR_SPEED100;
+		else if (speed == SPEED_1000)
+			ctl |= BMCR_SPEED1000;
+	}
+	if (duplex >= 0) {
+		ctl &= ~(BMCR_FULLDPLX | BMCR_ANENABLE);
+		if (duplex == DUPLEX_FULL)
+			ctl |= BMCR_FULLDPLX;
+	}
+	if (ctl & BMCR_SPEED1000)  /* auto-negotiation required for 1Gb/s */
+		ctl |= BMCR_ANENABLE;
+	(void) simple_mdio_write(phy, MII_BMCR, ctl);
+	return 0;
+}
+
+static int mv88e1xxx_crossover_set(struct cphy *cphy, int crossover)
+{
+	u32 data32;
+
+	(void) simple_mdio_read(cphy,
+			MV88E1XXX_SPECIFIC_CNTRL_REGISTER, &data32);
+	data32 &= ~V_PSCR_MDI_XOVER_MODE(M_PSCR_MDI_XOVER_MODE);
+	data32 |= V_PSCR_MDI_XOVER_MODE(crossover);
+	(void) simple_mdio_write(cphy,
+			MV88E1XXX_SPECIFIC_CNTRL_REGISTER, data32);
+	return 0;
+}
+
+static int mv88e1xxx_autoneg_enable(struct cphy *cphy)
+{
+	u32 ctl;
+
+	(void) mv88e1xxx_crossover_set(cphy, CROSSOVER_AUTO);
+
+	(void) simple_mdio_read(cphy, MII_BMCR, &ctl);
+	/* restart autoneg for change to take effect */
+	ctl |= BMCR_ANENABLE | BMCR_ANRESTART;
+	(void) simple_mdio_write(cphy, MII_BMCR, ctl);
+	return 0;
+}
+
+static int mv88e1xxx_autoneg_disable(struct cphy *cphy)
+{
+	u32 ctl;
+
+	/*
+	 * Crossover *must* be set to manual in order to disable auto-neg.
+	 * The Alaska FAQs document highlights this point.
+	 */
+	(void) mv88e1xxx_crossover_set(cphy, CROSSOVER_MDI);
+
+	/*
+	 * Must include autoneg reset when disabling auto-neg. This
+	 * is described in the Alaska FAQ document.
+	 */
+	(void) simple_mdio_read(cphy, MII_BMCR, &ctl);
+	ctl &= ~BMCR_ANENABLE;
+	(void) simple_mdio_write(cphy, MII_BMCR, ctl | BMCR_ANRESTART);
+	return 0;
+}
+
+static int mv88e1xxx_autoneg_restart(struct cphy *cphy)
+{
+	mdio_set_bit(cphy, MII_BMCR, BMCR_ANRESTART);
+	return 0;
+}
+
+static int mv88e1xxx_advertise(struct cphy *phy, unsigned int advertise_map)
+{
+	u32 val = 0;
+
+	if (advertise_map &
+	    (ADVERTISED_1000baseT_Half | ADVERTISED_1000baseT_Full)) {
+		(void) simple_mdio_read(phy, MII_GBCR, &val);
+		val &= ~(GBCR_ADV_1000HALF | GBCR_ADV_1000FULL);
+		if (advertise_map & ADVERTISED_1000baseT_Half)
+			val |= GBCR_ADV_1000HALF;
+		if (advertise_map & ADVERTISED_1000baseT_Full)
+			val |= GBCR_ADV_1000FULL;
+	}
+	(void) simple_mdio_write(phy, MII_GBCR, val);
+
+	val = 1;
+	if (advertise_map & ADVERTISED_10baseT_Half)
+		val |= ADVERTISE_10HALF;
+	if (advertise_map & ADVERTISED_10baseT_Full)
+		val |= ADVERTISE_10FULL;
+	if (advertise_map & ADVERTISED_100baseT_Half)
+		val |= ADVERTISE_100HALF;
+	if (advertise_map & ADVERTISED_100baseT_Full)
+		val |= ADVERTISE_100FULL;
+	if (advertise_map & ADVERTISED_PAUSE)
+		val |= ADVERTISE_PAUSE;
+	if (advertise_map & ADVERTISED_ASYM_PAUSE)
+		val |= ADVERTISE_PAUSE_ASYM;
+	(void) simple_mdio_write(phy, MII_ADVERTISE, val);
+	return 0;
+}
+
+static int mv88e1xxx_set_loopback(struct cphy *cphy, int on)
+{
+	if (on)
+		mdio_set_bit(cphy, MII_BMCR, BMCR_LOOPBACK);
+	else
+		mdio_clear_bit(cphy, MII_BMCR, BMCR_LOOPBACK);
+	return 0;
+}
+
+static int mv88e1xxx_get_link_status(struct cphy *cphy, int *link_ok,
+				     int *speed, int *duplex, int *fc)
+{
+	u32 status;
+	int sp = -1, dplx = -1, pause = 0;
+
+	(void) simple_mdio_read(cphy,
+			MV88E1XXX_SPECIFIC_STATUS_REGISTER, &status);
+	if ((status & V_PSSR_STATUS_RESOLVED) != 0) {
+		if (status & V_PSSR_RX_PAUSE)
+			pause |= PAUSE_RX;
+		if (status & V_PSSR_TX_PAUSE)
+			pause |= PAUSE_TX;
+		dplx = (status & V_PSSR_DUPLEX) ? DUPLEX_FULL : DUPLEX_HALF;
+		sp = G_PSSR_SPEED(status);
+		if (sp == 0)
+			sp = SPEED_10;
+		else if (sp == 1)
+			sp = SPEED_100;
+		else
+			sp = SPEED_1000;
+	}
+	if (link_ok)
+		*link_ok = (status & V_PSSR_LINK) != 0;
+	if (speed)
+		*speed = sp;
+	if (duplex)
+		*duplex = dplx;
+	if (fc)
+		*fc = pause;
+	return 0;
+}
+
+static int mv88e1xxx_downshift_set(struct cphy *cphy, int downshift_enable)
+{
+	u32 val;
+
+	(void) simple_mdio_read(cphy,
+		MV88E1XXX_EXT_PHY_SPECIFIC_CNTRL_REGISTER, &val);
+
+	/*
+	 * Set the downshift counter to 2 so we try to establish Gb link
+	 * twice before downshifting.
+	 */
+	val &= ~(V_DOWNSHIFT_ENABLE | V_DOWNSHIFT_CNT(M_DOWNSHIFT_CNT));
+
+	if (downshift_enable)
+		val |= V_DOWNSHIFT_ENABLE | V_DOWNSHIFT_CNT(2);
+	(void) simple_mdio_write(cphy,
+			MV88E1XXX_EXT_PHY_SPECIFIC_CNTRL_REGISTER, val);
+	return 0;
+}
+
+static int mv88e1xxx_interrupt_handler(struct cphy *cphy)
+{
+	int cphy_cause = 0;
+	u32 status;
+
+	/*
+	 * Loop until cause reads zero. Need to handle bouncing interrupts.
+         */
+	while (1) {
+		u32 cause;
+
+		(void) simple_mdio_read(cphy,
+				MV88E1XXX_INTERRUPT_STATUS_REGISTER,
+				&cause);
+		cause &= INTR_ENABLE_MASK;
+		if (!cause) break;
+
+		if (cause & MV88E1XXX_INTR_LINK_CHNG) {
+			(void) simple_mdio_read(cphy,
+				MV88E1XXX_SPECIFIC_STATUS_REGISTER, &status);
+
+			if (status & MV88E1XXX_INTR_LINK_CHNG) {
+				cphy->state |= PHY_LINK_UP;
+			} else {
+				cphy->state &= ~PHY_LINK_UP;
+				if (cphy->state & PHY_AUTONEG_EN)
+					cphy->state &= ~PHY_AUTONEG_RDY;
+				cphy_cause |= cphy_cause_link_change;
+			}
+		}
+
+		if (cause & MV88E1XXX_INTR_AUTONEG_DONE)
+			cphy->state |= PHY_AUTONEG_RDY;
+
+		if ((cphy->state & (PHY_LINK_UP | PHY_AUTONEG_RDY)) ==
+			(PHY_LINK_UP | PHY_AUTONEG_RDY))
+				cphy_cause |= cphy_cause_link_change;
+	}
+	return cphy_cause;
+}
+
+static void mv88e1xxx_destroy(struct cphy *cphy)
+{
+	kfree(cphy);
+}
+
+static struct cphy_ops mv88e1xxx_ops = {
+	.destroy              = mv88e1xxx_destroy,
+	.reset                = mv88e1xxx_reset,
+	.interrupt_enable     = mv88e1xxx_interrupt_enable,
+	.interrupt_disable    = mv88e1xxx_interrupt_disable,
+	.interrupt_clear      = mv88e1xxx_interrupt_clear,
+	.interrupt_handler    = mv88e1xxx_interrupt_handler,
+	.autoneg_enable       = mv88e1xxx_autoneg_enable,
+	.autoneg_disable      = mv88e1xxx_autoneg_disable,
+	.autoneg_restart      = mv88e1xxx_autoneg_restart,
+	.advertise            = mv88e1xxx_advertise,
+	.set_loopback         = mv88e1xxx_set_loopback,
+	.set_speed_duplex     = mv88e1xxx_set_speed_duplex,
+	.get_link_status      = mv88e1xxx_get_link_status,
+};
+
+static struct cphy *mv88e1xxx_phy_create(adapter_t *adapter, int phy_addr,
+					 struct mdio_ops *mdio_ops)
+{
+	struct cphy *cphy = kzalloc(sizeof(*cphy), GFP_KERNEL);
+
+	if (!cphy) return NULL;
+
+	cphy_init(cphy, adapter, phy_addr, &mv88e1xxx_ops, mdio_ops);
+
+	/* Configure particular PHY's to run in a different mode. */
+	if ((board_info(adapter)->caps & SUPPORTED_TP) &&
+	    board_info(adapter)->chip_phy == CHBT_PHY_88E1111) {
+		/*
+		 * Configure the PHY transmitter as class A to reduce EMI.
+		 */
+		(void) simple_mdio_write(cphy,
+				MV88E1XXX_EXTENDED_ADDR_REGISTER, 0xB);
+		(void) simple_mdio_write(cphy,
+				MV88E1XXX_EXTENDED_REGISTER, 0x8004);
+	}
+	(void) mv88e1xxx_downshift_set(cphy, 1);   /* Enable downshift */
+
+        /* LED */
+	if (is_T2(adapter)) {
+		(void) simple_mdio_write(cphy,
+				MV88E1XXX_LED_CONTROL_REGISTER, 0x1);
+        }
+
+	return cphy;
+}
+
+static int mv88e1xxx_phy_reset(adapter_t* adapter)
+{
+	return 0;
+}
+
+struct gphy t1_mv88e1xxx_ops = {
+	mv88e1xxx_phy_create,
+	mv88e1xxx_phy_reset
+};
--- chelsio.orig/drivers/net/chelsio/subr.c
+++ chelsio/drivers/net/chelsio/subr.c
@@ -185,6 +185,66 @@ static int t1_pci_intr_handler(adapter_t
 	return 0;
 }
 
+#ifdef CONFIG_CHELSIO_T1_COUGAR
+#include "cspi.h"
+#endif
+#ifdef CONFIG_CHELSIO_T1_1G
+#include "fpga_defs.h"
+
+/*
+ * PHY interrupt handler for FPGA boards.
+ */
+static int fpga_phy_intr_handler(adapter_t *adapter)
+{
+	int p;
+	u32 cause = readl(adapter->regs + FPGA_GMAC_ADDR_INTERRUPT_CAUSE);
+
+	for_each_port(adapter, p)
+		if (cause & (1 << p)) {
+			struct cphy *phy = adapter->port[p].phy;
+			int phy_cause = phy->ops->interrupt_handler(phy);
+
+			if (phy_cause & cphy_cause_link_change)
+				t1_link_changed(adapter, p);
+		}
+	writel(cause, adapter->regs + FPGA_GMAC_ADDR_INTERRUPT_CAUSE);
+	return 0;
+}
+
+/*
+ * Slow path interrupt handler for FPGAs.
+ */
+static int fpga_slow_intr(adapter_t *adapter)
+{
+	u32 cause = readl(adapter->regs + A_PL_CAUSE);
+
+	cause &= ~F_PL_INTR_SGE_DATA;
+	if (cause & F_PL_INTR_SGE_ERR)
+		t1_sge_intr_error_handler(adapter->sge);
+
+	if (cause & FPGA_PCIX_INTERRUPT_GMAC)
+                fpga_phy_intr_handler(adapter);
+
+	if (cause & FPGA_PCIX_INTERRUPT_TP) {
+                /*
+		 * FPGA doesn't support MC4 interrupts and it requires
+		 * this odd layer of indirection for MC5.
+                 */
+		u32 tp_cause = readl(adapter->regs + FPGA_TP_ADDR_INTERRUPT_CAUSE);
+
+		/* Clear TP interrupt */
+		writel(tp_cause, adapter->regs + FPGA_TP_ADDR_INTERRUPT_CAUSE);
+	}
+	if (cause & FPGA_PCIX_INTERRUPT_PCIX)
+		t1_pci_intr_handler(adapter);
+
+	/* Clear the interrupts just processed. */
+	if (cause)
+		writel(cause, adapter->regs + A_PL_CAUSE);
+
+	return cause != 0;
+}
+#endif
 
 /*
  * Wait until Elmer's MI1 interface is ready for new operations.
@@ -221,6 +281,56 @@ static void mi1_mdio_init(adapter_t *ada
 	t1_tpi_write(adapter, A_ELMER0_PORT0_MI1_CFG, val);
 }
 
+#if defined(CONFIG_CHELSIO_T1_1G) || defined(CONFIG_CHELSIO_T1_COUGAR)
+/*
+ * Elmer MI1 MDIO read/write operations.
+ */
+static int mi1_mdio_read(adapter_t *adapter, int phy_addr, int mmd_addr,
+			 int reg_addr, unsigned int *valp)
+{
+	u32 addr = V_MI1_REG_ADDR(reg_addr) | V_MI1_PHY_ADDR(phy_addr);
+
+	if (mmd_addr)
+		return -EINVAL;
+
+	spin_lock(&adapter->tpi_lock);
+	__t1_tpi_write(adapter, A_ELMER0_PORT0_MI1_ADDR, addr);
+	__t1_tpi_write(adapter,
+			A_ELMER0_PORT0_MI1_OP, MI1_OP_DIRECT_READ);
+	mi1_wait_until_ready(adapter, A_ELMER0_PORT0_MI1_OP);
+	__t1_tpi_read(adapter, A_ELMER0_PORT0_MI1_DATA, valp);
+	spin_unlock(&adapter->tpi_lock);
+	return 0;
+}
+
+static int mi1_mdio_write(adapter_t *adapter, int phy_addr, int mmd_addr,
+			  int reg_addr, unsigned int val)
+{
+	u32 addr = V_MI1_REG_ADDR(reg_addr) | V_MI1_PHY_ADDR(phy_addr);
+
+	if (mmd_addr)
+		return -EINVAL;
+
+	spin_lock(&adapter->tpi_lock);
+	__t1_tpi_write(adapter, A_ELMER0_PORT0_MI1_ADDR, addr);
+	__t1_tpi_write(adapter, A_ELMER0_PORT0_MI1_DATA, val);
+	__t1_tpi_write(adapter,
+			A_ELMER0_PORT0_MI1_OP, MI1_OP_DIRECT_WRITE);
+	mi1_wait_until_ready(adapter, A_ELMER0_PORT0_MI1_OP);
+	spin_unlock(&adapter->tpi_lock);
+	return 0;
+}
+
+#if defined(CONFIG_CHELSIO_T1_1G) || defined(CONFIG_CHELSIO_T1_COUGAR)
+static struct mdio_ops mi1_mdio_ops = {
+	mi1_mdio_init,
+	mi1_mdio_read,
+	mi1_mdio_write
+};
+#endif
+
+#endif
+
 static int mi1_mdio_ext_read(adapter_t *adapter, int phy_addr, int mmd_addr,
 			     int reg_addr, unsigned int *valp)
 {
@@ -330,6 +440,17 @@ static struct board_info t1_board[] = {
   &t1_my3126_ops, &mi1_mdio_ext_ops,
   "Chelsio T210 1x10GBase-CX4 TOE" },
 
+#ifdef CONFIG_CHELSIO_T1_1G
+{ CHBT_BOARD_CHN204, 4/*ports#*/,
+  SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full | SUPPORTED_100baseT_Half |
+  SUPPORTED_100baseT_Full | SUPPORTED_1000baseT_Full | SUPPORTED_Autoneg |
+  SUPPORTED_PAUSE | SUPPORTED_TP /*caps*/, CHBT_TERM_T2, CHBT_MAC_VSC7321, CHBT_PHY_88E1111,
+  100000000/*clk-core*/, 0/*clk-mc3*/, 0/*clk-mc4*/,
+  4/*espi-ports*/, 0/*clk-cspi*/, 44/*clk-elmer0*/, 0/*mdien*/,
+  0/*mdiinv*/, 1/*mdc*/, 4/*phybaseaddr*/, &t1_vsc7326_ops,
+  &t1_mv88e1xxx_ops, &mi1_mdio_ops,
+  "Chelsio N204 4x100/1000BaseT NIC" },
+#endif
 
 };
 
@@ -483,6 +604,48 @@ int t1_elmer0_ext_intr_handler(adapter_t
 	t1_tpi_read(adapter, A_ELMER0_INT_CAUSE, &cause);
 
 	switch (board_info(adapter)->board) {
+#ifdef CONFIG_CHELSIO_T1_1G
+        case CHBT_BOARD_CHT204:
+        case CHBT_BOARD_CHT204E:
+        case CHBT_BOARD_CHN204:
+        case CHBT_BOARD_CHT204V: {
+                int i, port_bit;
+		for_each_port(adapter, i) {
+			port_bit = i + 1;
+			if (!(cause & (1 << port_bit))) continue;
+
+	                phy = adapter->port[i].phy;
+			phy_cause = phy->ops->interrupt_handler(phy);
+			if (phy_cause & cphy_cause_link_change)
+				t1_link_changed(adapter, i);
+		}
+                break;
+        }
+	case CHBT_BOARD_CHT101:
+		if (cause & ELMER0_GP_BIT1) { /* Marvell 88E1111 interrupt */
+			phy = adapter->port[0].phy;
+			phy_cause = phy->ops->interrupt_handler(phy);
+			if (phy_cause & cphy_cause_link_change)
+				t1_link_changed(adapter, 0);
+		}
+		break;
+	case CHBT_BOARD_7500: {
+		int p;
+    		/*
+		 * Elmer0's interrupt cause isn't useful here because there is
+		 * only one bit that can be set for all 4 ports.  This means
+		 * we are forced to check every PHY's interrupt status
+		 * register to see who initiated the interrupt.
+     		 */
+    		for_each_port(adapter, p) {
+			phy = adapter->port[p].phy;
+			phy_cause = phy->ops->interrupt_handler(phy);
+			if (phy_cause & cphy_cause_link_change)
+			    t1_link_changed(adapter, p);
+		}
+		break;
+	}
+#endif
 	case CHBT_BOARD_CHT210:
 	case CHBT_BOARD_N210:
 	case CHBT_BOARD_N110:
@@ -511,6 +674,30 @@ int t1_elmer0_ext_intr_handler(adapter_t
 			       mod_detect ? "removed" : "inserted");
     		}
 		break;
+#ifdef CONFIG_CHELSIO_T1_COUGAR
+	case CHBT_BOARD_COUGAR:
+		if (adapter->params.nports == 1) {
+			if (cause & ELMER0_GP_BIT1) {         /* Vitesse MAC */
+				struct cmac *mac = adapter->port[0].mac;
+				mac->ops->interrupt_handler(mac);
+			}
+			if (cause & ELMER0_GP_BIT5) {     /* XPAK MOD_DETECT */
+			}
+		} else {
+			int i, port_bit;
+
+			for_each_port(adapter, i) {
+				port_bit = i ? i + 1 : 0;
+				if (!(cause & (1 << port_bit))) continue;
+
+				phy = adapter->port[i].phy;
+				phy_cause = phy->ops->interrupt_handler(phy);
+				if (phy_cause & cphy_cause_link_change)
+					t1_link_changed(adapter, i);
+			}
+		}
+		break;
+#endif
 	}
 	t1_tpi_write(adapter, A_ELMER0_INT_CAUSE, cause);
 	return 0;
@@ -633,6 +820,10 @@ static int asic_slow_intr(adapter_t *ada
 
 int t1_slow_intr_handler(adapter_t *adapter)
 {
+#ifdef CONFIG_CHELSIO_T1_1G
+	if (!t1_is_asic(adapter))
+		return fpga_slow_intr(adapter);
+#endif
 	return asic_slow_intr(adapter);
 }
 
@@ -698,6 +889,21 @@ static int board_init(adapter_t *adapter
      		 */
     		power_sequence_xpak(adapter);
 		break;
+#ifdef CONFIG_CHELSIO_T1_1G
+    case CHBT_BOARD_CHT204E:
+		        /* add config space write here */
+	case CHBT_BOARD_CHT204:
+	case CHBT_BOARD_CHT204V:
+	case CHBT_BOARD_CHN204:
+                t1_tpi_par(adapter, 0xf);
+                t1_tpi_write(adapter, A_ELMER0_GPO, 0x804);
+                break;
+	case CHBT_BOARD_CHT101:
+	case CHBT_BOARD_7500:
+    		t1_tpi_par(adapter, 0xf);
+    		t1_tpi_write(adapter, A_ELMER0_GPO, 0x1804);
+		break;
+#endif
 	}
 	return 0;
 }
@@ -719,6 +925,10 @@ int t1_init_hw_modules(adapter_t *adapte
 		       adapter->regs + A_MC5_CONFIG);
 	}
 
+#ifdef CONFIG_CHELSIO_T1_COUGAR
+	if (adapter->cspi && t1_cspi_init(adapter->cspi))
+		goto out_err;
+#endif
 	if (adapter->espi && t1_espi_init(adapter->espi, bi->chip_mac,
 					  bi->espi_nports))
 		goto out_err;
@@ -772,6 +982,10 @@ void t1_free_sw_modules(adapter_t *adapt
 		t1_tp_destroy(adapter->tp);
 	if (adapter->espi)
 		t1_espi_destroy(adapter->espi);
+#ifdef CONFIG_CHELSIO_T1_COUGAR
+        if (adapter->cspi)
+		t1_cspi_destroy(adapter->cspi);
+#endif
 }
 
 static void __devinit init_link_config(struct link_config *lc,
@@ -791,6 +1005,13 @@ static void __devinit init_link_config(s
 	}
 }
 
+#ifdef CONFIG_CHELSIO_T1_COUGAR
+	if (bi->clock_cspi && !(adapter->cspi = t1_cspi_create(adapter))) {
+		CH_ERR("%s: CSPI initialization failed\n",
+		       adapter->name);
+		goto error;
+        }
+#endif
 
 /*
  * Allocate and initialize the data structures that hold the SW state of
--- chelsio.orig/drivers/net/chelsio/tp.c
+++ chelsio/drivers/net/chelsio/tp.c
@@ -2,6 +2,9 @@
 #include "common.h"
 #include "regs.h"
 #include "tp.h"
+#ifdef CONFIG_CHELSIO_T1_1G
+#include "fpga_defs.h"
+#endif
 
 struct petp {
 	adapter_t *adapter;
@@ -70,6 +73,15 @@ void t1_tp_intr_enable(struct petp *tp)
 {
 	u32 tp_intr = readl(tp->adapter->regs + A_PL_ENABLE);
 
+#ifdef CONFIG_CHELSIO_T1_1G
+	if (!t1_is_asic(tp->adapter)) {
+		/* FPGA */
+		writel(0xffffffff,
+		       tp->adapter->regs + FPGA_TP_ADDR_INTERRUPT_ENABLE);
+		writel(tp_intr | FPGA_PCIX_INTERRUPT_TP,
+		       tp->adapter->regs + A_PL_ENABLE);
+	} else
+#endif
 	{
 		/* We don't use any TP interrupts */
 		writel(0, tp->adapter->regs + A_TP_INT_ENABLE);
@@ -82,6 +94,14 @@ void t1_tp_intr_disable(struct petp *tp)
 {
 	u32 tp_intr = readl(tp->adapter->regs + A_PL_ENABLE);
 
+#ifdef CONFIG_CHELSIO_T1_1G
+	if (!t1_is_asic(tp->adapter)) {
+		/* FPGA */
+		writel(0, tp->adapter->regs + FPGA_TP_ADDR_INTERRUPT_ENABLE);
+		writel(tp_intr & ~FPGA_PCIX_INTERRUPT_TP,
+		       tp->adapter->regs + A_PL_ENABLE);
+	} else
+#endif
 	{
 		writel(0, tp->adapter->regs + A_TP_INT_ENABLE);
 		writel(tp_intr & ~F_PL_INTR_TP,
@@ -91,6 +111,14 @@ void t1_tp_intr_disable(struct petp *tp)
 
 void t1_tp_intr_clear(struct petp *tp)
 {
+#ifdef CONFIG_CHELSIO_T1_1G
+	if (!t1_is_asic(tp->adapter)) {
+		writel(0xffffffff,
+		       tp->adapter->regs + FPGA_TP_ADDR_INTERRUPT_CAUSE);
+		writel(FPGA_PCIX_INTERRUPT_TP, tp->adapter->regs + A_PL_CAUSE);
+		return;
+	}
+#endif
 	writel(0xffffffff, tp->adapter->regs + A_TP_INT_CAUSE);
 	writel(F_PL_INTR_TP, tp->adapter->regs + A_PL_CAUSE);
 }
@@ -99,6 +127,11 @@ int t1_tp_intr_handler(struct petp *tp)
 {
 	u32 cause;
 
+#ifdef CONFIG_CHELSIO_T1_1G
+	/* FPGA doesn't support TP interrupts. */
+	if (!t1_is_asic(tp->adapter))
+		return 1;
+#endif
 
 	cause = readl(tp->adapter->regs + A_TP_INT_CAUSE);
 	writel(cause, tp->adapter->regs + A_TP_INT_CAUSE);
--- /dev/null
+++ chelsio/drivers/net/chelsio/vsc7326.c
@@ -0,0 +1,725 @@
+/* $Date: 2006/04/28 19:20:06 $ $RCSfile: vsc7326.c,v $ $Revision: 1.19 $ */
+
+/* Driver for Vitesse VSC7326 (Schaumburg) MAC */
+
+#include "gmac.h"
+#include "elmer0.h"
+#include "vsc7326_reg.h"
+
+/* Update fast changing statistics every 15 seconds */
+#define STATS_TICK_SECS 15
+/* 30 minutes for full statistics update */
+#define MAJOR_UPDATE_TICKS (1800 / STATS_TICK_SECS)
+
+#define MAX_MTU 9600
+
+/* The egress WM value 0x01a01fff should be used only when the
+ * interface is down (MAC port disabled). This is a workaround
+ * for disabling the T2/MAC flow-control. When the interface is
+ * enabled, the WM value should be set to 0x014a03F0.
+ */
+#define WM_DISABLE	0x01a01fff
+#define WM_ENABLE	0x014a03F0
+
+struct init_table {
+	u32 addr;
+	u32 data;
+};
+
+struct _cmac_instance {
+	u32 index;
+	u32 ticks;
+};
+
+#define INITBLOCK_SLEEP	0xffffffff
+
+static void vsc_read(adapter_t *adapter, u32 addr, u32 *val)
+{
+	u32 status, vlo, vhi;
+	int i;
+
+	spin_lock_bh(&adapter->mac_lock);
+	t1_tpi_read(adapter, (addr << 2) + 4, &vlo);
+	i = 0;
+	do {
+		t1_tpi_read(adapter, (REG_LOCAL_STATUS << 2) + 4, &vlo);
+		t1_tpi_read(adapter, REG_LOCAL_STATUS << 2, &vhi);
+		status = (vhi << 16) | vlo;
+		i++;
+	} while (((status & 1) == 0) && (i < 50));
+	if (i == 50)
+		CH_ERR("Invalid tpi read from MAC, breaking loop.\n");
+
+	t1_tpi_read(adapter, (REG_LOCAL_DATA << 2) + 4, &vlo);
+	t1_tpi_read(adapter, REG_LOCAL_DATA << 2, &vhi);
+
+	*val = (vhi << 16) | vlo;
+
+	/* CH_ERR("rd: block: 0x%x  sublock: 0x%x  reg: 0x%x  data: 0x%x\n",
+		((addr&0xe000)>>13), ((addr&0x1e00)>>9),
+		((addr&0x01fe)>>1), *val); */
+	spin_unlock_bh(&adapter->mac_lock);
+}
+
+static void vsc_write(adapter_t *adapter, u32 addr, u32 data)
+{
+	spin_lock_bh(&adapter->mac_lock);
+	t1_tpi_write(adapter, (addr << 2) + 4, data & 0xFFFF);
+	t1_tpi_write(adapter, addr << 2, (data >> 16) & 0xFFFF);
+	/* CH_ERR("wr: block: 0x%x  sublock: 0x%x  reg: 0x%x  data: 0x%x\n",
+		((addr&0xe000)>>13), ((addr&0x1e00)>>9),
+		((addr&0x01fe)>>1), data); */
+	spin_unlock_bh(&adapter->mac_lock);
+}
+
+/* Hard reset the MAC.  This wipes out *all* configuration. */
+static void vsc7326_full_reset(adapter_t* adapter)
+{
+	u32 val;
+	u32 result = 0xffff;
+
+	t1_tpi_read(adapter, A_ELMER0_GPO, &val);
+	val &= ~1;
+	t1_tpi_write(adapter, A_ELMER0_GPO, val);
+	udelay(2);
+	val |= 0x1;	/* Enable mac MAC itself */
+	val |= 0x800;	/* Turn off the red LED */
+	t1_tpi_write(adapter, A_ELMER0_GPO, val);
+	mdelay(1);
+	vsc_write(adapter, REG_SW_RESET, 0x80000001);
+	do {
+		mdelay(1);
+		vsc_read(adapter, REG_SW_RESET, &result);
+	} while (result != 0x0);
+}
+
+static struct init_table vsc7326_reset[] = {
+	{      REG_IFACE_MODE, 0x00000000 },
+	{         REG_CRC_CFG, 0x00000020 },
+	{   REG_PLL_CLK_SPEED, 0x00050c00 },
+	{   REG_PLL_CLK_SPEED, 0x00050c00 },
+	{            REG_MSCH, 0x00002f14 },
+	{       REG_SPI4_MISC, 0x00040409 },
+	{     REG_SPI4_DESKEW, 0x00080000 },
+	{ REG_SPI4_ING_SETUP2, 0x08080004 },
+	{ REG_SPI4_ING_SETUP0, 0x04111004 },
+	{ REG_SPI4_EGR_SETUP0, 0x80001a04 },
+	{ REG_SPI4_ING_SETUP1, 0x02010000 },
+	{      REG_AGE_INC(0), 0x00000000 },
+	{      REG_AGE_INC(1), 0x00000000 },
+	{     REG_ING_CONTROL, 0x0a200011 },
+	{     REG_EGR_CONTROL, 0xa0010091 },
+};
+
+static struct init_table vsc7326_portinit[4][22] = {
+	{	/* Port 0 */
+			/* FIFO setup */
+		{           REG_DBG(0), 0x000004f0 },
+		{           REG_HDX(0), 0x00073101 },
+		{        REG_TEST(0,0), 0x00000022 },
+		{        REG_TEST(1,0), 0x00000022 },
+		{  REG_TOP_BOTTOM(0,0), 0x003f0000 },
+		{  REG_TOP_BOTTOM(1,0), 0x00120000 },
+		{ REG_HIGH_LOW_WM(0,0), 0x07460757 },
+		{ REG_HIGH_LOW_WM(1,0), WM_DISABLE },
+		{   REG_CT_THRHLD(0,0), 0x00000000 },
+		{   REG_CT_THRHLD(1,0), 0x00000000 },
+		{         REG_BUCKE(0), 0x0002ffff },
+		{         REG_BUCKI(0), 0x0002ffff },
+		{        REG_TEST(0,0), 0x00000020 },
+		{        REG_TEST(1,0), 0x00000020 },
+			/* Port config */
+		{       REG_MAX_LEN(0), 0x00002710 },
+		{     REG_PORT_FAIL(0), 0x00000002 },
+		{    REG_NORMALIZER(0), 0x00000a64 },
+		{        REG_DENORM(0), 0x00000010 },
+		{     REG_STICK_BIT(0), 0x03baa370 },
+		{     REG_DEV_SETUP(0), 0x00000083 },
+		{     REG_DEV_SETUP(0), 0x00000082 },
+		{      REG_MODE_CFG(0), 0x0200259f },
+	},
+	{	/* Port 1 */
+			/* FIFO setup */
+		{           REG_DBG(1), 0x000004f0 },
+		{           REG_HDX(1), 0x00073101 },
+		{        REG_TEST(0,1), 0x00000022 },
+		{        REG_TEST(1,1), 0x00000022 },
+		{  REG_TOP_BOTTOM(0,1), 0x007e003f },
+		{  REG_TOP_BOTTOM(1,1), 0x00240012 },
+		{ REG_HIGH_LOW_WM(0,1), 0x07460757 },
+		{ REG_HIGH_LOW_WM(1,1), WM_DISABLE },
+		{   REG_CT_THRHLD(0,1), 0x00000000 },
+		{   REG_CT_THRHLD(1,1), 0x00000000 },
+		{         REG_BUCKE(1), 0x0002ffff },
+		{         REG_BUCKI(1), 0x0002ffff },
+		{        REG_TEST(0,1), 0x00000020 },
+		{        REG_TEST(1,1), 0x00000020 },
+			/* Port config */
+		{       REG_MAX_LEN(1), 0x00002710 },
+		{     REG_PORT_FAIL(1), 0x00000002 },
+		{    REG_NORMALIZER(1), 0x00000a64 },
+		{        REG_DENORM(1), 0x00000010 },
+		{     REG_STICK_BIT(1), 0x03baa370 },
+		{     REG_DEV_SETUP(1), 0x00000083 },
+		{     REG_DEV_SETUP(1), 0x00000082 },
+		{      REG_MODE_CFG(1), 0x0200259f },
+	},
+	{	/* Port 2 */
+			/* FIFO setup */
+		{           REG_DBG(2), 0x000004f0 },
+		{           REG_HDX(2), 0x00073101 },
+		{        REG_TEST(0,2), 0x00000022 },
+		{        REG_TEST(1,2), 0x00000022 },
+		{  REG_TOP_BOTTOM(0,2), 0x00bd007e },
+		{  REG_TOP_BOTTOM(1,2), 0x00360024 },
+		{ REG_HIGH_LOW_WM(0,2), 0x07460757 },
+		{ REG_HIGH_LOW_WM(1,2), WM_DISABLE },
+		{   REG_CT_THRHLD(0,2), 0x00000000 },
+		{   REG_CT_THRHLD(1,2), 0x00000000 },
+		{         REG_BUCKE(2), 0x0002ffff },
+		{         REG_BUCKI(2), 0x0002ffff },
+		{        REG_TEST(0,2), 0x00000020 },
+		{        REG_TEST(1,2), 0x00000020 },
+			/* Port config */
+		{       REG_MAX_LEN(2), 0x00002710 },
+		{     REG_PORT_FAIL(2), 0x00000002 },
+		{    REG_NORMALIZER(2), 0x00000a64 },
+		{        REG_DENORM(2), 0x00000010 },
+		{     REG_STICK_BIT(2), 0x03baa370 },
+		{     REG_DEV_SETUP(2), 0x00000083 },
+		{     REG_DEV_SETUP(2), 0x00000082 },
+		{      REG_MODE_CFG(2), 0x0200259f },
+	},
+	{	/* Port 3 */
+			/* FIFO setup */
+		{           REG_DBG(3), 0x000004f0 },
+		{           REG_HDX(3), 0x00073101 },
+		{        REG_TEST(0,3), 0x00000022 },
+		{        REG_TEST(1,3), 0x00000022 },
+		{  REG_TOP_BOTTOM(0,3), 0x00fc00bd },
+		{  REG_TOP_BOTTOM(1,3), 0x00480036 },
+		{ REG_HIGH_LOW_WM(0,3), 0x07460757 },
+		{ REG_HIGH_LOW_WM(1,3), WM_DISABLE },
+		{   REG_CT_THRHLD(0,3), 0x00000000 },
+		{   REG_CT_THRHLD(1,3), 0x00000000 },
+		{         REG_BUCKE(3), 0x0002ffff },
+		{         REG_BUCKI(3), 0x0002ffff },
+		{        REG_TEST(0,3), 0x00000020 },
+		{        REG_TEST(1,3), 0x00000020 },
+			/* Port config */
+		{       REG_MAX_LEN(3), 0x00002710 },
+		{     REG_PORT_FAIL(3), 0x00000002 },
+		{    REG_NORMALIZER(3), 0x00000a64 },
+		{        REG_DENORM(3), 0x00000010 },
+		{     REG_STICK_BIT(3), 0x03baa370 },
+		{     REG_DEV_SETUP(3), 0x00000083 },
+		{     REG_DEV_SETUP(3), 0x00000082 },
+		{      REG_MODE_CFG(3), 0x0200259f },
+	},
+};
+
+static void run_table(adapter_t *adapter, struct init_table *ib, int len)
+{
+	int i;
+
+	for (i = 0; i < len; i++) {
+		if (ib[i].addr == INITBLOCK_SLEEP) {
+			udelay( ib[i].data );
+			CH_ERR("sleep %d us\n",ib[i].data);
+		} else {
+			vsc_write( adapter, ib[i].addr, ib[i].data );
+		}
+	}
+}
+
+static int bist_rd(adapter_t *adapter, int moduleid, int address)
+{
+	int data=0;
+	u32 result=0;
+
+	if(	(address != 0x0) &&
+		(address != 0x1) &&
+		(address != 0x2) &&
+		(address != 0xd) &&
+		(address != 0xe))
+			CH_ERR("No bist address: 0x%x\n", address);
+
+	data = ((0x00 << 24) | ((address & 0xff) << 16) | (0x00 << 8) |
+		((moduleid & 0xff) << 0));
+	vsc_write(adapter, REG_RAM_BIST_CMD, data);
+
+	udelay(10);
+
+	vsc_read(adapter, REG_RAM_BIST_RESULT, &result);
+	if((result & (1<<9)) != 0x0)
+		CH_ERR("Still in bist read: 0x%x\n", result);
+	else if((result & (1<<8)) != 0x0)
+		CH_ERR("bist read error: 0x%x\n", result);
+
+	return(result & 0xff);
+}
+
+static int bist_wr(adapter_t *adapter, int moduleid, int address, int value)
+{
+	int data=0;
+	u32 result=0;
+
+	if(	(address != 0x0) &&
+		(address != 0x1) &&
+		(address != 0x2) &&
+		(address != 0xd) &&
+		(address != 0xe))
+			CH_ERR("No bist address: 0x%x\n", address);
+
+	if( value>255 )
+		CH_ERR("Suspicious write out of range value: 0x%x\n", value);
+
+	data = ((0x01 << 24) | ((address & 0xff) << 16) | (value << 8) |
+		((moduleid & 0xff) << 0));
+	vsc_write(adapter, REG_RAM_BIST_CMD, data);
+
+	udelay(5);
+
+	vsc_read(adapter, REG_RAM_BIST_CMD, &result);
+	if((result & (1<<27)) != 0x0)
+		CH_ERR("Still in bist write: 0x%x\n", result);
+	else if((result & (1<<26)) != 0x0)
+		CH_ERR("bist write error: 0x%x\n", result);
+
+	return(0);
+}
+
+static int run_bist(adapter_t *adapter, int moduleid)
+{
+	/*run bist*/
+	(void) bist_wr(adapter,moduleid, 0x00, 0x02);
+	(void) bist_wr(adapter,moduleid, 0x01, 0x01);
+
+	return(0);
+}
+
+static int check_bist(adapter_t *adapter, int moduleid)
+{
+	int result=0;
+	int column=0;
+	/*check bist*/
+	result = bist_rd(adapter,moduleid, 0x02);
+	column = ((bist_rd(adapter,moduleid, 0x0e)<<8) +
+			(bist_rd(adapter,moduleid, 0x0d)));
+	if ((result & 3) != 0x3)
+		CH_ERR("Result: 0x%x  BIST error in ram %d, column: 0x%04x\n",
+			result, moduleid, column);
+	return(0);
+}
+
+static int enable_mem(adapter_t *adapter, int moduleid)
+{
+	/*enable mem*/
+	(void) bist_wr(adapter,moduleid, 0x00, 0x00);
+	return(0);
+}
+
+static int run_bist_all(adapter_t *adapter)
+{
+	int port=0;
+	u32 val=0;
+
+	vsc_write(adapter, REG_MEM_BIST, 0x5);
+	vsc_read(adapter, REG_MEM_BIST, &val);
+
+	for(port=0; port<12; port++){
+		vsc_write(adapter, REG_DEV_SETUP(port), 0x0);
+	}
+
+	udelay(300);
+	vsc_write(adapter, REG_SPI4_MISC, 0x00040409);
+	udelay(300);
+
+	(void) run_bist(adapter,13);
+	(void) run_bist(adapter,14);
+	(void) run_bist(adapter,20);
+	(void) run_bist(adapter,21);
+	mdelay(200);
+	(void) check_bist(adapter,13);
+	(void) check_bist(adapter,14);
+	(void) check_bist(adapter,20);
+	(void) check_bist(adapter,21);
+	udelay(100);
+	(void) enable_mem(adapter,13);
+	(void) enable_mem(adapter,14);
+	(void) enable_mem(adapter,20);
+	(void) enable_mem(adapter,21);
+	udelay(300);
+	vsc_write(adapter, REG_SPI4_MISC, 0x60040400);
+	udelay(300);
+	for(port=0; port<12; port++){
+		vsc_write(adapter, REG_DEV_SETUP(port), 0x1);
+	}
+	udelay(300);
+	vsc_write(adapter, REG_MEM_BIST, 0x0);
+	mdelay(10);
+	return(0);
+}
+
+static int mac_intr_handler(struct cmac *mac)
+{
+	return 0;
+}
+
+static int mac_intr_enable(struct cmac *mac)
+{
+	return 0;
+}
+
+static int mac_intr_disable(struct cmac *mac)
+{
+	return 0;
+}
+
+static int mac_intr_clear(struct cmac *mac)
+{
+	return 0;
+}
+
+/* Expect MAC address to be in network byte order. */
+static int mac_set_address(struct cmac* mac, u8 addr[6])
+{
+	u32 val;
+	int port = mac->instance->index;
+
+	vsc_write(mac->adapter, REG_MAC_LOW_ADDR(port),
+		  (addr[3] << 16) | (addr[4] << 8) | addr[5]);
+	vsc_write(mac->adapter, REG_MAC_HIGH_ADDR(port),
+		  (addr[0] << 16) | (addr[1] << 8) | addr[2]);
+
+	vsc_read(mac->adapter, REG_ING_FFILT_UM_EN, &val);
+	val &= ~0xf0000000;
+	vsc_write(mac->adapter, REG_ING_FFILT_UM_EN, val | (port << 28));
+
+	vsc_write(mac->adapter, REG_ING_FFILT_MASK0,
+		  0xffff0000 | (addr[4] << 8) | addr[5]);
+	vsc_write(mac->adapter, REG_ING_FFILT_MASK1,
+		  0xffff0000 | (addr[2] << 8) | addr[3]);
+	vsc_write(mac->adapter, REG_ING_FFILT_MASK2,
+		  0xffff0000 | (addr[0] << 8) | addr[1]);
+	return 0;
+}
+
+static int mac_get_address(struct cmac *mac, u8 addr[6])
+{
+	u32 addr_lo, addr_hi;
+	int port = mac->instance->index;
+
+	vsc_read(mac->adapter, REG_MAC_LOW_ADDR(port), &addr_lo);
+	vsc_read(mac->adapter, REG_MAC_HIGH_ADDR(port), &addr_hi);
+
+	addr[0] = (u8) (addr_hi >> 16);
+	addr[1] = (u8) (addr_hi >> 8);
+	addr[2] = (u8) addr_hi;
+	addr[3] = (u8) (addr_lo >> 16);
+	addr[4] = (u8) (addr_lo >> 8);
+	addr[5] = (u8) addr_lo;
+	return 0;
+}
+
+/* This is intended to reset a port, not the whole MAC */
+static int mac_reset(struct cmac *mac)
+{
+	int index = mac->instance->index;
+
+	run_table(mac->adapter, vsc7326_portinit[index],
+		  ARRAY_SIZE(vsc7326_portinit[index]));
+
+	return 0;
+}
+
+static int mac_set_rx_mode(struct cmac *mac, struct t1_rx_mode *rm)
+{
+	u32 v;
+	int port = mac->instance->index;
+
+	vsc_read(mac->adapter, REG_ING_FFILT_UM_EN, &v);
+	v |= 1 << 12;
+
+	if (t1_rx_mode_promisc(rm))
+		v &= ~(1 << (port + 16));
+	else
+		v |= 1 << (port + 16);
+
+	vsc_write(mac->adapter, REG_ING_FFILT_UM_EN, v);
+	return 0;
+}
+
+static int mac_set_mtu(struct cmac *mac, int mtu)
+{
+	int port = mac->instance->index;
+
+	if (mtu > MAX_MTU)
+		return -EINVAL;
+
+	/* max_len includes header and FCS */
+	vsc_write(mac->adapter, REG_MAX_LEN(port), mtu + 14 + 4);
+	return 0;
+}
+
+static int mac_set_speed_duplex_fc(struct cmac *mac, int speed, int duplex,
+				   int fc)
+{
+	u32 v;
+	int enable, port = mac->instance->index;
+
+	if (speed >= 0 && speed != SPEED_10 && speed != SPEED_100 &&
+	    speed != SPEED_1000)
+		return -1;
+	if (duplex > 0 && duplex != DUPLEX_FULL)
+		return -1;
+
+	if (speed >= 0) {
+		vsc_read(mac->adapter, REG_MODE_CFG(port), &v);
+		enable = v & 3;             /* save tx/rx enables */
+		v &= ~0xf;
+		v |= 4;                     /* full duplex */
+		if (speed == SPEED_1000)
+			v |= 8;             /* GigE */
+		enable |= v;
+		vsc_write(mac->adapter, REG_MODE_CFG(port), v);
+
+		if (speed == SPEED_1000)
+			v = 0x82;
+		else if (speed == SPEED_100)
+			v = 0x84;
+		else	/* SPEED_10 */
+			v = 0x86;
+		vsc_write(mac->adapter, REG_DEV_SETUP(port), v | 1); /* reset */
+		vsc_write(mac->adapter, REG_DEV_SETUP(port), v);
+		vsc_read(mac->adapter, REG_DBG(port), &v);
+		v &= ~0xff00;
+		if (speed == SPEED_1000)
+			v |= 0x400;
+		else if (speed == SPEED_100)
+			v |= 0x2000;
+		else	/* SPEED_10 */
+			v |= 0xff00;
+		vsc_write(mac->adapter, REG_DBG(port), v);
+
+		vsc_write(mac->adapter, REG_TX_IFG(port),
+			  speed == SPEED_1000 ? 5 : 0x11);
+		if (duplex == DUPLEX_HALF)
+			enable = 0x0;	/* 100 or 10 */
+		else if (speed == SPEED_1000)
+			enable = 0xc;
+		else	/* SPEED_100 or 10 */
+			enable = 0x4;
+		enable |= 0x9 << 10;	/* IFG1 */
+		enable |= 0x6 << 6;	/* IFG2 */
+		enable |= 0x1 << 4;	/* VLAN */
+		enable |= 0x3;		/* RX/TX EN */
+		vsc_write(mac->adapter, REG_MODE_CFG(port), enable);
+
+	}
+
+	vsc_read(mac->adapter, REG_PAUSE_CFG(port), &v);
+	v &= 0xfff0ffff;
+	v |= 0x20000;      /* xon/xoff */
+	if (fc & PAUSE_RX)
+		v |= 0x40000;
+	if (fc & PAUSE_TX)
+		v |= 0x80000;
+	if (fc == (PAUSE_RX | PAUSE_TX))
+		v |= 0x10000;
+	vsc_write(mac->adapter, REG_PAUSE_CFG(port), v);
+	return 0;
+}
+
+static int mac_enable(struct cmac *mac, int which)
+{
+	u32 val;
+	int port = mac->instance->index;
+
+	/* Write the correct WM value when the port is enabled. */
+	vsc_write(mac->adapter, REG_HIGH_LOW_WM(1,port), WM_ENABLE);
+
+	vsc_read(mac->adapter, REG_MODE_CFG(port), &val);
+	if (which & MAC_DIRECTION_RX)
+		val |= 0x2;
+	if (which & MAC_DIRECTION_TX)
+		val |= 1;
+	vsc_write(mac->adapter, REG_MODE_CFG(port), val);
+	return 0;
+}
+
+static int mac_disable(struct cmac *mac, int which)
+{
+	u32 val;
+	int i, port = mac->instance->index;
+
+	/* Reset the port, this also writes the correct WM value */
+	mac_reset(mac);
+
+	vsc_read(mac->adapter, REG_MODE_CFG(port), &val);
+	if (which & MAC_DIRECTION_RX)
+		val &= ~0x2;
+	if (which & MAC_DIRECTION_TX)
+		val &= ~0x1;
+	vsc_write(mac->adapter, REG_MODE_CFG(port), val);
+	vsc_read(mac->adapter, REG_MODE_CFG(port), &val);
+
+	/* Clear stats */
+	for (i = 0; i <= 0x3a; ++i)
+		vsc_write(mac->adapter, CRA(4, port, i), 0);
+
+	/* Clear sofware counters */
+	memset(&mac->stats, 0, sizeof(struct cmac_statistics));
+
+	return 0;
+}
+
+static void rmon_update(struct cmac *mac, unsigned int addr, u64 *stat)
+{
+	u32 v, lo;
+
+	vsc_read(mac->adapter, addr, &v);
+	lo = *stat;
+	*stat = *stat - lo + v;
+
+	if (v == 0)
+		return;
+
+	if (v < lo)
+		*stat += (1ULL << 32);
+}
+
+static void port_stats_update(struct cmac *mac)
+{
+	int port = mac->instance->index;
+
+	/* Rx stats */
+	rmon_update(mac, REG_RX_OK_BYTES(port), &mac->stats.RxOctetsOK);
+	rmon_update(mac, REG_RX_BAD_BYTES(port), &mac->stats.RxOctetsBad);
+	rmon_update(mac, REG_RX_UNICAST(port), &mac->stats.RxUnicastFramesOK);
+	rmon_update(mac, REG_RX_MULTICAST(port),
+		    &mac->stats.RxMulticastFramesOK);
+	rmon_update(mac, REG_RX_BROADCAST(port),
+		    &mac->stats.RxBroadcastFramesOK);
+	rmon_update(mac, REG_CRC(port), &mac->stats.RxFCSErrors);
+	rmon_update(mac, REG_RX_ALIGNMENT(port), &mac->stats.RxAlignErrors);
+	rmon_update(mac, REG_RX_OVERSIZE(port),
+		    &mac->stats.RxFrameTooLongErrors);
+	rmon_update(mac, REG_RX_PAUSE(port), &mac->stats.RxPauseFrames);
+	rmon_update(mac, REG_RX_JABBERS(port), &mac->stats.RxJabberErrors);
+	rmon_update(mac, REG_RX_FRAGMENTS(port), &mac->stats.RxRuntErrors);
+	rmon_update(mac, REG_RX_UNDERSIZE(port), &mac->stats.RxRuntErrors);
+	rmon_update(mac, REG_RX_SYMBOL_CARRIER(port),
+		    &mac->stats.RxSymbolErrors);
+	rmon_update(mac, REG_RX_SIZE_1519_TO_MAX(port),
+            &mac->stats.RxJumboFramesOK);
+
+	/* Tx stats (skip collision stats as we are full-duplex only) */
+	rmon_update(mac, REG_TX_OK_BYTES(port), &mac->stats.TxOctetsOK);
+	rmon_update(mac, REG_TX_UNICAST(port), &mac->stats.TxUnicastFramesOK);
+	rmon_update(mac, REG_TX_MULTICAST(port),
+		    &mac->stats.TxMulticastFramesOK);
+	rmon_update(mac, REG_TX_BROADCAST(port),
+		    &mac->stats.TxBroadcastFramesOK);
+	rmon_update(mac, REG_TX_PAUSE(port), &mac->stats.TxPauseFrames);
+	rmon_update(mac, REG_TX_UNDERRUN(port), &mac->stats.TxUnderrun);
+	rmon_update(mac, REG_TX_SIZE_1519_TO_MAX(port),
+            &mac->stats.TxJumboFramesOK);
+}
+
+/*
+ * This function is called periodically to accumulate the current values of the
+ * RMON counters into the port statistics.  Since the counters are only 32 bits
+ * some of them can overflow in less than a minute at GigE speeds, so this
+ * function should be called every 30 seconds or so.
+ *
+ * To cut down on reading costs we update only the octet counters at each tick
+ * and do a full update at major ticks, which can be every 30 minutes or more.
+ */
+static const struct cmac_statistics *mac_update_statistics(struct cmac *mac,
+							   int flag)
+{
+	if (flag == MAC_STATS_UPDATE_FULL ||
+	    mac->instance->ticks >= MAJOR_UPDATE_TICKS) {
+		port_stats_update(mac);
+		mac->instance->ticks = 0;
+	} else {
+		int port = mac->instance->index;
+
+		rmon_update(mac, REG_RX_OK_BYTES(port),
+			    &mac->stats.RxOctetsOK);
+		rmon_update(mac, REG_RX_BAD_BYTES(port),
+			    &mac->stats.RxOctetsBad);
+		rmon_update(mac, REG_TX_OK_BYTES(port),
+			    &mac->stats.TxOctetsOK);
+		mac->instance->ticks++;
+	}
+	return &mac->stats;
+}
+
+static void mac_destroy(struct cmac *mac)
+{
+	kfree(mac);
+}
+
+static struct cmac_ops vsc7326_ops = {
+	.destroy                  = mac_destroy,
+	.reset                    = mac_reset,
+	.interrupt_handler        = mac_intr_handler,
+	.interrupt_enable         = mac_intr_enable,
+	.interrupt_disable        = mac_intr_disable,
+	.interrupt_clear          = mac_intr_clear,
+	.enable                   = mac_enable,
+	.disable                  = mac_disable,
+	.set_mtu                  = mac_set_mtu,
+	.set_rx_mode              = mac_set_rx_mode,
+	.set_speed_duplex_fc      = mac_set_speed_duplex_fc,
+	.statistics_update        = mac_update_statistics,
+	.macaddress_get           = mac_get_address,
+	.macaddress_set           = mac_set_address,
+};
+
+static struct cmac *vsc7326_mac_create(adapter_t *adapter, int index)
+{
+	struct cmac *mac;
+	u32 val;
+	int i;
+
+	mac = kzalloc(sizeof(*mac) + sizeof(cmac_instance), GFP_KERNEL);
+	if (!mac) return NULL;
+
+	mac->ops = &vsc7326_ops;
+	mac->instance = (cmac_instance *)(mac + 1);
+	mac->adapter  = adapter;
+
+	mac->instance->index = index;
+	mac->instance->ticks = 0;
+
+	i = 0;
+	do {
+		u32 vhi, vlo;
+
+		vhi = vlo = 0;
+		t1_tpi_read(adapter, (REG_LOCAL_STATUS << 2) + 4, &vlo);
+		udelay(1);
+		t1_tpi_read(adapter, REG_LOCAL_STATUS << 2, &vhi);
+		udelay(5);
+		val = (vhi << 16) | vlo;
+	} while ((++i < 10000) && (val == 0xffffffff));
+
+	return mac;
+}
+
+static int vsc7326_mac_reset(adapter_t *adapter)
+{
+	vsc7326_full_reset(adapter);
+	(void) run_bist_all(adapter);
+	run_table(adapter, vsc7326_reset, ARRAY_SIZE(vsc7326_reset));
+	return 0;
+}
+
+struct gmac t1_vsc7326_ops = {
+	.stats_update_period = STATS_TICK_SECS,
+	.create              = vsc7326_mac_create,
+	.reset               = vsc7326_mac_reset,
+};
--- /dev/null
+++ chelsio/drivers/net/chelsio/vsc8244.c
@@ -0,0 +1,368 @@
+/*
+ * This file is part of the Chelsio T2 Ethernet driver.
+ *
+ * Copyright (C) 2005 Chelsio Communications.  All rights reserved.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the LICENSE file included in this
+ * release for licensing terms and conditions.
+ */
+
+#include "common.h"
+#include "cphy.h"
+#include "elmer0.h"
+
+#ifndef ADVERTISE_PAUSE_CAP
+# define ADVERTISE_PAUSE_CAP 0x400
+#endif
+#ifndef ADVERTISE_PAUSE_ASYM
+# define ADVERTISE_PAUSE_ASYM 0x800
+#endif
+
+/* Gigabit MII registers */
+#ifndef MII_CTRL1000
+# define MII_CTRL1000 9
+#endif
+
+#ifndef ADVERTISE_1000FULL
+# define ADVERTISE_1000FULL 0x200
+# define ADVERTISE_1000HALF 0x100
+#endif
+
+/* VSC8244 PHY specific registers. */
+enum {
+	VSC8244_INTR_ENABLE   = 25,
+	VSC8244_INTR_STATUS   = 26,
+	VSC8244_AUX_CTRL_STAT = 28,
+};
+
+enum {
+	VSC_INTR_RX_ERR     = 1 << 0,
+	VSC_INTR_MS_ERR     = 1 << 1,  /* master/slave resolution error */
+	VSC_INTR_CABLE      = 1 << 2,  /* cable impairment */
+	VSC_INTR_FALSE_CARR = 1 << 3,  /* false carrier */
+	VSC_INTR_MEDIA_CHG  = 1 << 4,  /* AMS media change */
+	VSC_INTR_RX_FIFO    = 1 << 5,  /* Rx FIFO over/underflow */
+	VSC_INTR_TX_FIFO    = 1 << 6,  /* Tx FIFO over/underflow */
+	VSC_INTR_DESCRAMBL  = 1 << 7,  /* descrambler lock-lost */
+	VSC_INTR_SYMBOL_ERR = 1 << 8,  /* symbol error */
+	VSC_INTR_NEG_DONE   = 1 << 10, /* autoneg done */
+	VSC_INTR_NEG_ERR    = 1 << 11, /* autoneg error */
+	VSC_INTR_LINK_CHG   = 1 << 13, /* link change */
+	VSC_INTR_ENABLE     = 1 << 15, /* interrupt enable */
+};
+
+#define CFG_CHG_INTR_MASK (VSC_INTR_LINK_CHG | VSC_INTR_NEG_ERR | \
+	 		   VSC_INTR_NEG_DONE)
+#define INTR_MASK (CFG_CHG_INTR_MASK | VSC_INTR_TX_FIFO | VSC_INTR_RX_FIFO | \
+		   VSC_INTR_ENABLE)
+
+/* PHY specific auxiliary control & status register fields */
+#define S_ACSR_ACTIPHY_TMR    0
+#define M_ACSR_ACTIPHY_TMR    0x3
+#define V_ACSR_ACTIPHY_TMR(x) ((x) << S_ACSR_ACTIPHY_TMR)
+
+#define S_ACSR_SPEED    3
+#define M_ACSR_SPEED    0x3
+#define G_ACSR_SPEED(x) (((x) >> S_ACSR_SPEED) & M_ACSR_SPEED)
+
+#define S_ACSR_DUPLEX 5
+#define F_ACSR_DUPLEX (1 << S_ACSR_DUPLEX)
+
+#define S_ACSR_ACTIPHY 6
+#define F_ACSR_ACTIPHY (1 << S_ACSR_ACTIPHY)
+
+/*
+ * Reset the PHY.  This PHY completes reset immediately so we never wait.
+ */
+static int vsc8244_reset(struct cphy *cphy, int wait)
+{
+	int err;
+	unsigned int ctl;
+
+	err = simple_mdio_read(cphy, MII_BMCR, &ctl);
+	if (err)
+		return err;
+
+	ctl &= ~BMCR_PDOWN;
+	ctl |= BMCR_RESET;
+	return simple_mdio_write(cphy, MII_BMCR, ctl);
+}
+
+static int vsc8244_intr_enable(struct cphy *cphy)
+{
+	simple_mdio_write(cphy, VSC8244_INTR_ENABLE, INTR_MASK);
+
+    /* Enable interrupts through Elmer */
+	if (t1_is_asic(cphy->adapter)) {
+		u32 elmer;
+
+		t1_tpi_read(cphy->adapter, A_ELMER0_INT_ENABLE, &elmer);
+		elmer |= ELMER0_GP_BIT1;
+		if (is_T2(cphy->adapter)) {
+		    elmer |= ELMER0_GP_BIT2|ELMER0_GP_BIT3|ELMER0_GP_BIT4;
+                }
+		t1_tpi_write(cphy->adapter, A_ELMER0_INT_ENABLE, elmer);
+	}
+
+    return 0;
+}
+
+static int vsc8244_intr_disable(struct cphy *cphy)
+{
+	simple_mdio_write(cphy, VSC8244_INTR_ENABLE, 0);
+
+	if (t1_is_asic(cphy->adapter)) {
+		u32 elmer;
+
+		t1_tpi_read(cphy->adapter, A_ELMER0_INT_ENABLE, &elmer);
+		elmer &= ~ELMER0_GP_BIT1;
+		if (is_T2(cphy->adapter)) {
+		    elmer &= ~(ELMER0_GP_BIT2|ELMER0_GP_BIT3|ELMER0_GP_BIT4);
+                }
+		t1_tpi_write(cphy->adapter, A_ELMER0_INT_ENABLE, elmer);
+	}
+
+    return 0;
+}
+
+static int vsc8244_intr_clear(struct cphy *cphy)
+{
+	u32 val;
+    u32 elmer;
+
+	/* Clear PHY interrupts by reading the register. */
+	simple_mdio_read(cphy, VSC8244_INTR_ENABLE, &val);
+
+	if (t1_is_asic(cphy->adapter)) {
+		t1_tpi_read(cphy->adapter, A_ELMER0_INT_CAUSE, &elmer);
+		elmer |= ELMER0_GP_BIT1;
+		if (is_T2(cphy->adapter)) {
+		    elmer |= ELMER0_GP_BIT2|ELMER0_GP_BIT3|ELMER0_GP_BIT4;
+                }
+		t1_tpi_write(cphy->adapter, A_ELMER0_INT_CAUSE, elmer);
+	}
+
+    return 0;
+}
+
+/*
+ * Force the PHY speed and duplex.  This also disables auto-negotiation, except
+ * for 1Gb/s, where auto-negotiation is mandatory.
+ */
+static int vsc8244_set_speed_duplex(struct cphy *phy, int speed, int duplex)
+{
+	int err;
+	unsigned int ctl;
+
+	err = simple_mdio_read(phy, MII_BMCR, &ctl);
+	if (err)
+		return err;
+
+	if (speed >= 0) {
+		ctl &= ~(BMCR_SPEED100 | BMCR_SPEED1000 | BMCR_ANENABLE);
+		if (speed == SPEED_100)
+			ctl |= BMCR_SPEED100;
+		else if (speed == SPEED_1000)
+			ctl |= BMCR_SPEED1000;
+	}
+	if (duplex >= 0) {
+		ctl &= ~(BMCR_FULLDPLX | BMCR_ANENABLE);
+		if (duplex == DUPLEX_FULL)
+			ctl |= BMCR_FULLDPLX;
+	}
+	if (ctl & BMCR_SPEED1000)  /* auto-negotiation required for 1Gb/s */
+		ctl |= BMCR_ANENABLE;
+	return simple_mdio_write(phy, MII_BMCR, ctl);
+}
+
+int t1_mdio_set_bits(struct cphy *phy, int mmd, int reg, unsigned int bits)
+{
+    int ret;
+    unsigned int val;
+
+    ret = mdio_read(phy, mmd, reg, &val);
+    if (!ret)
+        ret = mdio_write(phy, mmd, reg, val | bits);
+    return ret;
+}
+
+static int vsc8244_autoneg_enable(struct cphy *cphy)
+{
+	return t1_mdio_set_bits(cphy, 0, MII_BMCR,
+				BMCR_ANENABLE | BMCR_ANRESTART);
+}
+
+static int vsc8244_autoneg_restart(struct cphy *cphy)
+{
+	return t1_mdio_set_bits(cphy, 0, MII_BMCR, BMCR_ANRESTART);
+}
+
+static int vsc8244_advertise(struct cphy *phy, unsigned int advertise_map)
+{
+	int err;
+	unsigned int val = 0;
+
+	err = simple_mdio_read(phy, MII_CTRL1000, &val);
+	if (err)
+		return err;
+
+	val &= ~(ADVERTISE_1000HALF | ADVERTISE_1000FULL);
+	if (advertise_map & ADVERTISED_1000baseT_Half)
+		val |= ADVERTISE_1000HALF;
+	if (advertise_map & ADVERTISED_1000baseT_Full)
+		val |= ADVERTISE_1000FULL;
+
+	err = simple_mdio_write(phy, MII_CTRL1000, val);
+	if (err)
+		return err;
+
+	val = 1;
+	if (advertise_map & ADVERTISED_10baseT_Half)
+		val |= ADVERTISE_10HALF;
+	if (advertise_map & ADVERTISED_10baseT_Full)
+		val |= ADVERTISE_10FULL;
+	if (advertise_map & ADVERTISED_100baseT_Half)
+		val |= ADVERTISE_100HALF;
+	if (advertise_map & ADVERTISED_100baseT_Full)
+		val |= ADVERTISE_100FULL;
+	if (advertise_map & ADVERTISED_PAUSE)
+		val |= ADVERTISE_PAUSE_CAP;
+	if (advertise_map & ADVERTISED_ASYM_PAUSE)
+		val |= ADVERTISE_PAUSE_ASYM;
+	return simple_mdio_write(phy, MII_ADVERTISE, val);
+}
+
+static int vsc8244_get_link_status(struct cphy *cphy, int *link_ok,
+				     int *speed, int *duplex, int *fc)
+{
+	unsigned int bmcr, status, lpa, adv;
+	int err, sp = -1, dplx = -1, pause = 0;
+
+	err = simple_mdio_read(cphy, MII_BMCR, &bmcr);
+	if (!err)
+		err = simple_mdio_read(cphy, MII_BMSR, &status);
+	if (err)
+		return err;
+
+	if (link_ok) {
+		/*
+		 * BMSR_LSTATUS is latch-low, so if it is 0 we need to read it
+		 * once more to get the current link state.
+		 */
+		if (!(status & BMSR_LSTATUS))
+			err = simple_mdio_read(cphy, MII_BMSR, &status);
+		if (err)
+			return err;
+		*link_ok = (status & BMSR_LSTATUS) != 0;
+	}
+	if (!(bmcr & BMCR_ANENABLE)) {
+		dplx = (bmcr & BMCR_FULLDPLX) ? DUPLEX_FULL : DUPLEX_HALF;
+		if (bmcr & BMCR_SPEED1000)
+			sp = SPEED_1000;
+		else if (bmcr & BMCR_SPEED100)
+			sp = SPEED_100;
+		else
+			sp = SPEED_10;
+	} else if (status & BMSR_ANEGCOMPLETE) {
+		err = simple_mdio_read(cphy, VSC8244_AUX_CTRL_STAT, &status);
+		if (err)
+			return err;
+
+		dplx = (status & F_ACSR_DUPLEX) ? DUPLEX_FULL : DUPLEX_HALF;
+		sp = G_ACSR_SPEED(status);
+		if (sp == 0)
+			sp = SPEED_10;
+		else if (sp == 1)
+			sp = SPEED_100;
+		else
+			sp = SPEED_1000;
+
+		if (fc && dplx == DUPLEX_FULL) {
+			err = simple_mdio_read(cphy, MII_LPA, &lpa);
+			if (!err)
+				err = simple_mdio_read(cphy, MII_ADVERTISE,
+						       &adv);
+			if (err)
+				return err;
+
+			if (lpa & adv & ADVERTISE_PAUSE_CAP)
+				pause = PAUSE_RX | PAUSE_TX;
+			else if ((lpa & ADVERTISE_PAUSE_CAP) &&
+				 (lpa & ADVERTISE_PAUSE_ASYM) &&
+				 (adv & ADVERTISE_PAUSE_ASYM))
+				pause = PAUSE_TX;
+			else if ((lpa & ADVERTISE_PAUSE_ASYM) &&
+				 (adv & ADVERTISE_PAUSE_CAP))
+				pause = PAUSE_RX;
+		}
+	}
+	if (speed)
+		*speed = sp;
+	if (duplex)
+		*duplex = dplx;
+	if (fc)
+		*fc = pause;
+	return 0;
+}
+
+static int vsc8244_intr_handler(struct cphy *cphy)
+{
+	unsigned int cause;
+	int err, cphy_cause = 0;
+
+	err = simple_mdio_read(cphy, VSC8244_INTR_STATUS, &cause);
+	if (err)
+		return err;
+
+	cause &= INTR_MASK;
+	if (cause & CFG_CHG_INTR_MASK)
+		cphy_cause |= cphy_cause_link_change;
+	if (cause & (VSC_INTR_RX_FIFO | VSC_INTR_TX_FIFO))
+		cphy_cause |= cphy_cause_fifo_error;
+	return cphy_cause;
+}
+
+static void vsc8244_destroy(struct cphy *cphy)
+{
+	kfree(cphy);
+}
+
+static struct cphy_ops vsc8244_ops = {
+	.destroy              = vsc8244_destroy,
+	.reset                = vsc8244_reset,
+	.interrupt_enable     = vsc8244_intr_enable,
+	.interrupt_disable    = vsc8244_intr_disable,
+	.interrupt_clear      = vsc8244_intr_clear,
+	.interrupt_handler    = vsc8244_intr_handler,
+	.autoneg_enable       = vsc8244_autoneg_enable,
+	.autoneg_restart      = vsc8244_autoneg_restart,
+	.advertise            = vsc8244_advertise,
+	.set_speed_duplex     = vsc8244_set_speed_duplex,
+	.get_link_status      = vsc8244_get_link_status
+};
+
+static struct cphy* vsc8244_phy_create(adapter_t *adapter, int phy_addr, struct mdio_ops *mdio_ops)
+{
+	struct cphy *cphy = kzalloc(sizeof(*cphy), GFP_KERNEL);
+
+	if (!cphy) return NULL;
+
+	cphy_init(cphy, adapter, phy_addr, &vsc8244_ops, mdio_ops);
+
+	return cphy;
+}
+
+
+static int vsc8244_phy_reset(adapter_t* adapter)
+{
+	return 0;
+}
+
+struct gphy t1_vsc8244_ops = {
+	vsc8244_phy_create,
+	vsc8244_phy_reset
+};
+
+
--- /dev/null
+++ chelsio/drivers/net/chelsio/vsc8244_reg.h
@@ -0,0 +1,172 @@
+/* $Date: 2005/11/23 16:28:53 $ $RCSfile: vsc8244_reg.h,v $ $Revision: 1.1 $ */
+#ifndef CHELSIO_MV8E1XXX_H
+#define CHELSIO_MV8E1XXX_H
+
+#ifndef BMCR_SPEED1000
+# define BMCR_SPEED1000 0x40
+#endif
+
+#ifndef ADVERTISE_PAUSE
+# define ADVERTISE_PAUSE 0x400
+#endif
+#ifndef ADVERTISE_PAUSE_ASYM
+# define ADVERTISE_PAUSE_ASYM 0x800
+#endif
+
+/* Gigabit MII registers */
+#define MII_GBMR 1       /* 1000Base-T mode register */
+#define MII_GBCR 9       /* 1000Base-T control register */
+#define MII_GBSR 10      /* 1000Base-T status register */
+
+/* 1000Base-T control register fields */
+#define GBCR_ADV_1000HALF         0x100
+#define GBCR_ADV_1000FULL         0x200
+#define GBCR_PREFER_MASTER        0x400
+#define GBCR_MANUAL_AS_MASTER     0x800
+#define GBCR_MANUAL_CONFIG_ENABLE 0x1000
+
+/* 1000Base-T status register fields */
+#define GBSR_LP_1000HALF  0x400
+#define GBSR_LP_1000FULL  0x800
+#define GBSR_REMOTE_OK    0x1000
+#define GBSR_LOCAL_OK     0x2000
+#define GBSR_LOCAL_MASTER 0x4000
+#define GBSR_MASTER_FAULT 0x8000
+
+/* Vitesse PHY interrupt status bits. */
+#if 0
+#define VSC8244_INTR_JABBER          0x0001
+#define VSC8244_INTR_POLARITY_CHNG   0x0002
+#define VSC8244_INTR_ENG_DETECT_CHNG 0x0010
+#define VSC8244_INTR_DOWNSHIFT       0x0020
+#define VSC8244_INTR_MDI_XOVER_CHNG  0x0040
+#define VSC8244_INTR_FIFO_OVER_UNDER 0x0080
+#define VSC8244_INTR_FALSE_CARRIER   0x0100
+#define VSC8244_INTR_SYMBOL_ERROR    0x0200
+#define VSC8244_INTR_LINK_CHNG       0x0400
+#define VSC8244_INTR_AUTONEG_DONE    0x0800
+#define VSC8244_INTR_PAGE_RECV       0x1000
+#define VSC8244_INTR_DUPLEX_CHNG     0x2000
+#define VSC8244_INTR_SPEED_CHNG      0x4000
+#define VSC8244_INTR_AUTONEG_ERR     0x8000
+#else
+//#define VSC8244_INTR_JABBER          0x0001
+//#define VSC8244_INTR_POLARITY_CHNG   0x0002
+//#define VSC8244_INTR_BIT2            0x0004
+//#define VSC8244_INTR_BIT3            0x0008
+#define VSC8244_INTR_RX_ERR          0x0001
+#define VSC8244_INTR_MASTER_SLAVE    0x0002
+#define VSC8244_INTR_CABLE_IMPAIRED  0x0004
+#define VSC8244_INTR_FALSE_CARRIER   0x0008
+//#define VSC8244_INTR_ENG_DETECT_CHNG 0x0010
+//#define VSC8244_INTR_DOWNSHIFT       0x0020
+//#define VSC8244_INTR_MDI_XOVER_CHNG  0x0040
+//#define VSC8244_INTR_FIFO_OVER_UNDER 0x0080
+#define VSC8244_INTR_BIT4            0x0010
+#define VSC8244_INTR_FIFO_RX         0x0020
+#define VSC8244_INTR_FIFO_OVER_UNDER 0x0040
+#define VSC8244_INTR_LOCK_LOST       0x0080
+//#define VSC8244_INTR_FALSE_CARRIER   0x0100
+//#define VSC8244_INTR_SYMBOL_ERROR    0x0200
+//#define VSC8244_INTR_LINK_CHNG       0x0400
+//#define VSC8244_INTR_AUTONEG_DONE    0x0800
+#define VSC8244_INTR_SYMBOL_ERROR    0x0100
+#define VSC8244_INTR_ENG_DETECT_CHNG 0x0200
+#define VSC8244_INTR_AUTONEG_DONE    0x0400
+#define VSC8244_INTR_AUTONEG_ERR     0x0800
+//#define VSC8244_INTR_PAGE_RECV       0x1000
+//#define VSC8244_INTR_DUPLEX_CHNG     0x2000
+//#define VSC8244_INTR_SPEED_CHNG      0x4000
+//#define VSC8244_INTR_AUTONEG_ERR     0x8000
+#define VSC8244_INTR_DUPLEX_CHNG     0x1000
+#define VSC8244_INTR_LINK_CHNG       0x2000
+#define VSC8244_INTR_SPEED_CHNG      0x4000
+#define VSC8244_INTR_STATUS          0x8000
+#endif
+
+
+/* Vitesse PHY specific registers. */
+#define VSC8244_SPECIFIC_CNTRL_REGISTER               16
+#define VSC8244_SPECIFIC_STATUS_REGISTER              0x1c
+#define VSC8244_INTERRUPT_ENABLE_REGISTER             0x19
+#define VSC8244_INTERRUPT_STATUS_REGISTER             0x1a
+#define VSC8244_EXT_PHY_SPECIFIC_CNTRL_REGISTER       20
+#define VSC8244_RECV_ERR_CNTR_REGISTER                21
+#define VSC8244_RES_REGISTER                          22
+#define VSC8244_GLOBAL_STATUS_REGISTER                23
+#define VSC8244_LED_CONTROL_REGISTER                  24
+#define VSC8244_MANUAL_LED_OVERRIDE_REGISTER          25
+#define VSC8244_EXT_PHY_SPECIFIC_CNTRL_2_REGISTER     26
+#define VSC8244_EXT_PHY_SPECIFIC_STATUS_REGISTER      27
+#define VSC8244_VIRTUAL_CABLE_TESTER_REGISTER         28
+#define VSC8244_EXTENDED_ADDR_REGISTER                29
+#define VSC8244_EXTENDED_REGISTER                     30
+
+/* PHY specific control register fields */
+#define S_PSCR_MDI_XOVER_MODE    5
+#define M_PSCR_MDI_XOVER_MODE    0x3
+#define V_PSCR_MDI_XOVER_MODE(x) ((x) << S_PSCR_MDI_XOVER_MODE)
+#define G_PSCR_MDI_XOVER_MODE(x) (((x) >> S_PSCR_MDI_XOVER_MODE) & M_PSCR_MDI_XOVER_MODE)
+
+/* Extended PHY specific control register fields */
+#define S_DOWNSHIFT_ENABLE 8
+#define V_DOWNSHIFT_ENABLE (1 << S_DOWNSHIFT_ENABLE)
+
+#define S_DOWNSHIFT_CNT    9
+#define M_DOWNSHIFT_CNT    0x7
+#define V_DOWNSHIFT_CNT(x) ((x) << S_DOWNSHIFT_CNT)
+#define G_DOWNSHIFT_CNT(x) (((x) >> S_DOWNSHIFT_CNT) & M_DOWNSHIFT_CNT)
+
+/* PHY specific status register fields */
+#define S_PSSR_JABBER 0
+#define V_PSSR_JABBER (1 << S_PSSR_JABBER)
+
+#define S_PSSR_POLARITY 1
+#define V_PSSR_POLARITY (1 << S_PSSR_POLARITY)
+
+#define S_PSSR_RX_PAUSE 2
+#define V_PSSR_RX_PAUSE (1 << S_PSSR_RX_PAUSE)
+
+#define S_PSSR_TX_PAUSE 3
+#define V_PSSR_TX_PAUSE (1 << S_PSSR_TX_PAUSE)
+
+#define S_PSSR_ENERGY_DETECT 4
+#define V_PSSR_ENERGY_DETECT (1 << S_PSSR_ENERGY_DETECT)
+
+#define S_PSSR_DOWNSHIFT_STATUS 5
+#define V_PSSR_DOWNSHIFT_STATUS (1 << S_PSSR_DOWNSHIFT_STATUS)
+
+#define S_PSSR_MDI 6
+#define V_PSSR_MDI (1 << S_PSSR_MDI)
+
+#define S_PSSR_CABLE_LEN    7
+#define M_PSSR_CABLE_LEN    0x7
+#define V_PSSR_CABLE_LEN(x) ((x) << S_PSSR_CABLE_LEN)
+#define G_PSSR_CABLE_LEN(x) (((x) >> S_PSSR_CABLE_LEN) & M_PSSR_CABLE_LEN)
+
+//#define S_PSSR_LINK 10
+//#define S_PSSR_LINK 13
+#define S_PSSR_LINK 2
+#define V_PSSR_LINK (1 << S_PSSR_LINK)
+
+//#define S_PSSR_STATUS_RESOLVED 11
+//#define S_PSSR_STATUS_RESOLVED 10
+#define S_PSSR_STATUS_RESOLVED 15
+#define V_PSSR_STATUS_RESOLVED (1 << S_PSSR_STATUS_RESOLVED)
+
+#define S_PSSR_PAGE_RECEIVED 12
+#define V_PSSR_PAGE_RECEIVED (1 << S_PSSR_PAGE_RECEIVED)
+
+//#define S_PSSR_DUPLEX 13
+//#define S_PSSR_DUPLEX 12
+#define S_PSSR_DUPLEX 5
+#define V_PSSR_DUPLEX (1 << S_PSSR_DUPLEX)
+
+//#define S_PSSR_SPEED    14
+//#define S_PSSR_SPEED    14
+#define S_PSSR_SPEED    3
+#define M_PSSR_SPEED    0x3
+#define V_PSSR_SPEED(x) ((x) << S_PSSR_SPEED)
+#define G_PSSR_SPEED(x) (((x) >> S_PSSR_SPEED) & M_PSSR_SPEED)
+
+#endif
--- chelsio.orig/drivers/net/chelsio/common.h
+++ chelsio/drivers/net/chelsio/common.h
@@ -283,6 +283,8 @@ struct adapter {
 
 	spinlock_t tpi_lock;
 	spinlock_t work_lock;
+	spinlock_t mac_lock;
+
 	/* guards async operations */
 	spinlock_t async_lock ____cacheline_aligned;
 	u32 slow_intr_mask;
--- chelsio.orig/drivers/net/chelsio/cxgb2.c
+++ chelsio/drivers/net/chelsio/cxgb2.c
@@ -1094,6 +1094,7 @@ static int __devinit init_one(struct pci
 			spin_lock_init(&adapter->tpi_lock);
 			spin_lock_init(&adapter->work_lock);
 			spin_lock_init(&adapter->async_lock);
+			spin_lock_init(&adapter->mac_lock);
 
 			INIT_WORK(&adapter->ext_intr_handler_task,
 				  ext_intr_task, adapter);
--- chelsio.orig/drivers/net/Kconfig
+++ chelsio/drivers/net/Kconfig
@@ -2376,6 +2376,13 @@ config CHELSIO_T1
           To compile this driver as a module, choose M here: the module
           will be called cxgb.
 
+config CHELSIO_T1_1G
+        bool "Chelsio gigabit Ethernet support"
+        depends on CHELSIO_T1
+        help
+          Enables support for Chelsio's gigabit Ethernet PCI cards.  If you
+          are using only 10G cards say 'N' here.
+
 config EHEA
 	tristate "eHEA Ethernet support"
 	depends on IBMEBUS

-- 

