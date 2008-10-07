From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCHv3 3/5] [NET] dsa: add support for the Marvell 88E6131 switch chip
Date: Wed, 8 Oct 2008 01:45:18 +0200
Message-ID: <20081007234518.GD23200@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:60978 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755591AbYJGXpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 19:45:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the Marvell 88E6131 switch chip.  This chip only
supports the original (ethertype-less) DSA tagging format.

On the 88E6131, there is a PHY Polling Unit (PPU) which has exclusive
access to each of the PHYs's MII management registers.  If we want to
talk to the PHYs from software, we have to disable the PPU and wait
for it to complete its current transaction before we can do so, and we
need to re-enable the PPU afterwards to make sure that the switch will
notice changes in link state and speed on the individual ports as they
occur.

Since disabling the PPU is rather slow, and since MII management
accesses are typically done in bursts, this patch keeps the PPU disabled
for 10ms after a software access completes.  This makes handling the
PPU slightly more complex, but speeds up something like running ethtool
on one of the switch slave interfaces from ~300ms to ~30ms on typical
hardware.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Tested-by: Nicolas Pitre <nico@marvell.com>
Tested-by: Peter van Valderen <linux@ddcrew.com>
Tested-by: Dirk Teurlings <dirk@upexia.nl>
---
 net/dsa/Kconfig     |   13 ++
 net/dsa/Makefile    |    1 +
 net/dsa/mv88e6131.c |  380 +++++++++++++++++++++++++++++++++++++++++++++++++++
 net/dsa/mv88e6xxx.c |  145 +++++++++++++++++++
 net/dsa/mv88e6xxx.h |   16 ++
 5 files changed, 555 insertions(+), 0 deletions(-)
 create mode 100644 net/dsa/mv88e6131.c

diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index 6b68016..79bcd76 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -24,6 +24,19 @@ config NET_DSA_MV88E6XXX
 	bool
 	default n
 
+config NET_DSA_MV88E6XXX_NEED_PPU
+	bool
+	default n
+
+config NET_DSA_MV88E6131
+	bool "Marvell 88E6131 ethernet switch chip support"
+	select NET_DSA_MV88E6XXX
+	select NET_DSA_MV88E6XXX_NEED_PPU
+	select NET_DSA_TAG_DSA
+	---help---
+	  This enables support for the Marvell 88E6131 ethernet switch
+	  chip.
+
 config NET_DSA_MV88E6123_61_65
 	bool "Marvell 88E6123/6161/6165 ethernet switch chip support"
 	select NET_DSA_MV88E6XXX
diff --git a/net/dsa/Makefile b/net/dsa/Makefile
index 8b92123..7fb6f85 100644
--- a/net/dsa/Makefile
+++ b/net/dsa/Makefile
@@ -5,6 +5,7 @@ obj-$(CONFIG_NET_DSA_TAG_EDSA) += tag_edsa.o
 # switch drivers
 obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx.o
 obj-$(CONFIG_NET_DSA_MV88E6123_61_65) += mv88e6123_61_65.o
+obj-$(CONFIG_NET_DSA_MV88E6131) += mv88e6131.o
 
 # the core
 obj-$(CONFIG_NET_DSA) += dsa.o slave.o
diff --git a/net/dsa/mv88e6131.c b/net/dsa/mv88e6131.c
new file mode 100644
index 0000000..36e01eb
--- /dev/null
+++ b/net/dsa/mv88e6131.c
@@ -0,0 +1,380 @@
+/*
+ * net/dsa/mv88e6131.c - Marvell 88e6131 switch chip support
+ * Copyright (c) 2008 Marvell Semiconductor
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+#include "dsa_priv.h"
+#include "mv88e6xxx.h"
+
+static char *mv88e6131_probe(struct mii_bus *bus, int sw_addr)
+{
+	int ret;
+
+	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), 0x03);
+	if (ret >= 0) {
+		ret &= 0xfff0;
+		if (ret == 0x1060)
+			return "Marvell 88E6131";
+	}
+
+	return NULL;
+}
+
+static int mv88e6131_switch_reset(struct dsa_switch *ds)
+{
+	int i;
+	int ret;
+
+	/*
+	 * Set all ports to the disabled state.
+	 */
+	for (i = 0; i < 8; i++) {
+		ret = REG_READ(REG_PORT(i), 0x04);
+		REG_WRITE(REG_PORT(i), 0x04, ret & 0xfffc);
+	}
+
+	/*
+	 * Wait for transmit queues to drain.
+	 */
+	msleep(2);
+
+	/*
+	 * Reset the switch.
+	 */
+	REG_WRITE(REG_GLOBAL, 0x04, 0xc400);
+
+	/*
+	 * Wait up to one second for reset to complete.
+	 */
+	for (i = 0; i < 1000; i++) {
+		ret = REG_READ(REG_GLOBAL, 0x00);
+		if ((ret & 0xc800) == 0xc800)
+			break;
+
+		msleep(1);
+	}
+	if (i == 1000)
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
+static int mv88e6131_setup_global(struct dsa_switch *ds)
+{
+	int ret;
+	int i;
+
+	/*
+	 * Enable the PHY polling unit, don't discard packets with
+	 * excessive collisions, use a weighted fair queueing scheme
+	 * to arbitrate between packet queues, set the maximum frame
+	 * size to 1632, and mask all interrupt sources.
+	 */
+	REG_WRITE(REG_GLOBAL, 0x04, 0x4400);
+
+	/*
+	 * Set the default address aging time to 5 minutes, and
+	 * enable address learn messages to be sent to all message
+	 * ports.
+	 */
+	REG_WRITE(REG_GLOBAL, 0x0a, 0x0148);
+
+	/*
+	 * Configure the priority mapping registers.
+	 */
+	ret = mv88e6xxx_config_prio(ds);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Set the VLAN ethertype to 0x8100.
+	 */
+	REG_WRITE(REG_GLOBAL, 0x19, 0x8100);
+
+	/*
+	 * Disable ARP mirroring, and configure the cpu port as the
+	 * port to which ingress and egress monitor frames are to be
+	 * sent.
+	 */
+	REG_WRITE(REG_GLOBAL, 0x1a, (ds->cpu_port * 0x1100) | 0x00f0);
+
+	/*
+	 * Disable cascade port functionality, and set the switch's
+	 * DSA device number to zero.
+	 */
+	REG_WRITE(REG_GLOBAL, 0x1c, 0xe000);
+
+	/*
+	 * Send all frames with destination addresses matching
+	 * 01:80:c2:00:00:0x to the CPU port.
+	 */
+	REG_WRITE(REG_GLOBAL2, 0x03, 0xffff);
+
+	/*
+	 * Ignore removed tag data on doubly tagged packets, disable
+	 * flow control messages, force flow control priority to the
+	 * highest, and send all special multicast frames to the CPU
+	 * port at the higest priority.
+	 */
+	REG_WRITE(REG_GLOBAL2, 0x05, 0x00ff);
+
+	/*
+	 * Map all DSA device IDs to the CPU port.
+	 */
+	for (i = 0; i < 32; i++)
+		REG_WRITE(REG_GLOBAL2, 0x06, 0x8000 | (i << 8) | ds->cpu_port);
+
+	/*
+	 * Clear all trunk masks.
+	 */
+	for (i = 0; i < 8; i++)
+		REG_WRITE(REG_GLOBAL2, 0x07, 0x8000 | (i << 12) | 0xff);
+
+	/*
+	 * Clear all trunk mappings.
+	 */
+	for (i = 0; i < 16; i++)
+		REG_WRITE(REG_GLOBAL2, 0x08, 0x8000 | (i << 11));
+
+	/*
+	 * Force the priority of IGMP/MLD snoop frames and ARP frames
+	 * to the highest setting.
+	 */
+	REG_WRITE(REG_GLOBAL2, 0x0f, 0x00ff);
+
+	return 0;
+}
+
+static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
+{
+	int addr = REG_PORT(p);
+
+	/*
+	 * MAC Forcing register: don't force link, speed, duplex
+	 * or flow control state to any particular values.
+	 */
+	REG_WRITE(addr, 0x01, 0x0003);
+
+	/*
+	 * Port Control: disable Core Tag, disable Drop-on-Lock,
+	 * transmit frames unmodified, disable Header mode,
+	 * enable IGMP/MLD snoop, disable DoubleTag, disable VLAN
+	 * tunneling, determine priority by looking at 802.1p and
+	 * IP priority fields (IP prio has precedence), and set STP
+	 * state to Forwarding.  Finally, if this is the CPU port,
+	 * additionally enable DSA tagging and forwarding of unknown
+	 * unicast addresses.
+	 */
+	REG_WRITE(addr, 0x04, (p == ds->cpu_port) ? 0x0537 : 0x0433);
+
+	/*
+	 * Port Control 1: disable trunking.  Also, if this is the
+	 * CPU port, enable learn messages to be sent to this port.
+	 */
+	REG_WRITE(addr, 0x05, (p == ds->cpu_port) ? 0x8000 : 0x0000);
+
+	/*
+	 * Port based VLAN map: give each port its own address
+	 * database, allow the CPU port to talk to each of the 'real'
+	 * ports, and allow each of the 'real' ports to only talk to
+	 * the CPU port.
+	 */
+	REG_WRITE(addr, 0x06,
+			((p & 0xf) << 12) |
+			 ((p == ds->cpu_port) ?
+				ds->valid_port_mask :
+				(1 << ds->cpu_port)));
+
+	/*
+	 * Default VLAN ID and priority: don't set a default VLAN
+	 * ID, and set the default packet priority to zero.
+	 */
+	REG_WRITE(addr, 0x07, 0x0000);
+
+	/*
+	 * Port Control 2: don't force a good FCS, don't use
+	 * VLAN-based, source address-based or destination
+	 * address-based priority overrides, don't let the switch
+	 * add or strip 802.1q tags, don't discard tagged or
+	 * untagged frames on this port, do a destination address
+	 * lookup on received packets as usual, don't send a copy
+	 * of all transmitted/received frames on this port to the
+	 * CPU, and configure the CPU port number.  Also, if this
+	 * is the CPU port, enable forwarding of unknown multicast
+	 * addresses.
+	 */
+	REG_WRITE(addr, 0x08,
+			((p == ds->cpu_port) ? 0x00c0 : 0x0080) |
+			 ds->cpu_port);
+
+	/*
+	 * Rate Control: disable ingress rate limiting.
+	 */
+	REG_WRITE(addr, 0x09, 0x0000);
+
+	/*
+	 * Rate Control 2: disable egress rate limiting.
+	 */
+	REG_WRITE(addr, 0x0a, 0x0000);
+
+	/*
+	 * Port Association Vector: when learning source addresses
+	 * of packets, add the address to the address database using
+	 * a port bitmap that has only the bit for this port set and
+	 * the other bits clear.
+	 */
+	REG_WRITE(addr, 0x0b, 1 << p);
+
+	/*
+	 * Tag Remap: use an identity 802.1p prio -> switch prio
+	 * mapping.
+	 */
+	REG_WRITE(addr, 0x18, 0x3210);
+
+	/*
+	 * Tag Remap 2: use an identity 802.1p prio -> switch prio
+	 * mapping.
+	 */
+	REG_WRITE(addr, 0x19, 0x7654);
+
+	return 0;
+}
+
+static int mv88e6131_setup(struct dsa_switch *ds)
+{
+	struct mv88e6xxx_priv_state *ps = (void *)(ds + 1);
+	int i;
+	int ret;
+
+	mutex_init(&ps->smi_mutex);
+	mv88e6xxx_ppu_state_init(ds);
+	mutex_init(&ps->stats_mutex);
+
+	ret = mv88e6131_switch_reset(ds);
+	if (ret < 0)
+		return ret;
+
+	/* @@@ initialise vtu and atu */
+
+	ret = mv88e6131_setup_global(ds);
+	if (ret < 0)
+		return ret;
+
+	for (i = 0; i < 6; i++) {
+		ret = mv88e6131_setup_port(ds, i);
+		if (ret < 0)
+			return ret;
+	}
+
+	return 0;
+}
+
+static int mv88e6131_port_to_phy_addr(int port)
+{
+	if (port >= 0 && port != 3 && port <= 7)
+		return port;
+	return -1;
+}
+
+static int
+mv88e6131_phy_read(struct dsa_switch *ds, int port, int regnum)
+{
+	int addr = mv88e6131_port_to_phy_addr(port);
+	return mv88e6xxx_phy_read_ppu(ds, addr, regnum);
+}
+
+static int
+mv88e6131_phy_write(struct dsa_switch *ds,
+			      int port, int regnum, u16 val)
+{
+	int addr = mv88e6131_port_to_phy_addr(port);
+	return mv88e6xxx_phy_write_ppu(ds, addr, regnum, val);
+}
+
+static struct mv88e6xxx_hw_stat mv88e6131_hw_stats[] = {
+	{ "in_good_octets", 8, 0x00, },
+	{ "in_bad_octets", 4, 0x02, },
+	{ "in_unicast", 4, 0x04, },
+	{ "in_broadcasts", 4, 0x06, },
+	{ "in_multicasts", 4, 0x07, },
+	{ "in_pause", 4, 0x16, },
+	{ "in_undersize", 4, 0x18, },
+	{ "in_fragments", 4, 0x19, },
+	{ "in_oversize", 4, 0x1a, },
+	{ "in_jabber", 4, 0x1b, },
+	{ "in_rx_error", 4, 0x1c, },
+	{ "in_fcs_error", 4, 0x1d, },
+	{ "out_octets", 8, 0x0e, },
+	{ "out_unicast", 4, 0x10, },
+	{ "out_broadcasts", 4, 0x13, },
+	{ "out_multicasts", 4, 0x12, },
+	{ "out_pause", 4, 0x15, },
+	{ "excessive", 4, 0x11, },
+	{ "collisions", 4, 0x1e, },
+	{ "deferred", 4, 0x05, },
+	{ "single", 4, 0x14, },
+	{ "multiple", 4, 0x17, },
+	{ "out_fcs_error", 4, 0x03, },
+	{ "late", 4, 0x1f, },
+	{ "hist_64bytes", 4, 0x08, },
+	{ "hist_65_127bytes", 4, 0x09, },
+	{ "hist_128_255bytes", 4, 0x0a, },
+	{ "hist_256_511bytes", 4, 0x0b, },
+	{ "hist_512_1023bytes", 4, 0x0c, },
+	{ "hist_1024_max_bytes", 4, 0x0d, },
+};
+
+static void
+mv88e6131_get_strings(struct dsa_switch *ds, int port, uint8_t *data)
+{
+	mv88e6xxx_get_strings(ds, ARRAY_SIZE(mv88e6131_hw_stats),
+			      mv88e6131_hw_stats, port, data);
+}
+
+static void
+mv88e6131_get_ethtool_stats(struct dsa_switch *ds,
+				  int port, uint64_t *data)
+{
+	mv88e6xxx_get_ethtool_stats(ds, ARRAY_SIZE(mv88e6131_hw_stats),
+				    mv88e6131_hw_stats, port, data);
+}
+
+static int mv88e6131_get_sset_count(struct dsa_switch *ds)
+{
+	return ARRAY_SIZE(mv88e6131_hw_stats);
+}
+
+static struct dsa_switch_driver mv88e6131_switch_driver = {
+	.tag_protocol		= __constant_htons(ETH_P_DSA),
+	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
+	.probe			= mv88e6131_probe,
+	.setup			= mv88e6131_setup,
+	.set_addr		= mv88e6xxx_set_addr_direct,
+	.phy_read		= mv88e6131_phy_read,
+	.phy_write		= mv88e6131_phy_write,
+	.poll_link		= mv88e6xxx_poll_link,
+	.get_strings		= mv88e6131_get_strings,
+	.get_ethtool_stats	= mv88e6131_get_ethtool_stats,
+	.get_sset_count		= mv88e6131_get_sset_count,
+};
+
+int __init mv88e6131_init(void)
+{
+	register_switch_driver(&mv88e6131_switch_driver);
+	return 0;
+}
+module_init(mv88e6131_init);
+
+void __exit mv88e6131_cleanup(void)
+{
+	unregister_switch_driver(&mv88e6131_switch_driver);
+}
+module_exit(mv88e6131_cleanup);
diff --git a/net/dsa/mv88e6xxx.c b/net/dsa/mv88e6xxx.c
index 13d2328..aa6c609 100644
--- a/net/dsa/mv88e6xxx.c
+++ b/net/dsa/mv88e6xxx.c
@@ -165,6 +165,15 @@ int mv88e6xxx_config_prio(struct dsa_switch *ds)
 	return 0;
 }
 
+int mv88e6xxx_set_addr_direct(struct dsa_switch *ds, u8 *addr)
+{
+	REG_WRITE(REG_GLOBAL, 0x01, (addr[0] << 8) | addr[1]);
+	REG_WRITE(REG_GLOBAL, 0x02, (addr[2] << 8) | addr[3]);
+	REG_WRITE(REG_GLOBAL, 0x03, (addr[4] << 8) | addr[5]);
+
+	return 0;
+}
+
 int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr)
 {
 	int i;
@@ -207,6 +216,142 @@ int mv88e6xxx_phy_write(struct dsa_switch *ds, int addr, int regnum, u16 val)
 	return 0;
 }
 
+#ifdef CONFIG_NET_DSA_MV88E6XXX_NEED_PPU
+static int mv88e6xxx_ppu_disable(struct dsa_switch *ds)
+{
+	int ret;
+	int i;
+
+	ret = REG_READ(REG_GLOBAL, 0x04);
+	REG_WRITE(REG_GLOBAL, 0x04, ret & ~0x4000);
+
+	for (i = 0; i < 1000; i++) {
+	        ret = REG_READ(REG_GLOBAL, 0x00);
+	        msleep(1);
+	        if ((ret & 0xc000) != 0xc000)
+	                return 0;
+	}
+
+	return -ETIMEDOUT;
+}
+
+static int mv88e6xxx_ppu_enable(struct dsa_switch *ds)
+{
+	int ret;
+	int i;
+
+	ret = REG_READ(REG_GLOBAL, 0x04);
+	REG_WRITE(REG_GLOBAL, 0x04, ret | 0x4000);
+
+	for (i = 0; i < 1000; i++) {
+	        ret = REG_READ(REG_GLOBAL, 0x00);
+	        msleep(1);
+	        if ((ret & 0xc000) == 0xc000)
+	                return 0;
+	}
+
+	return -ETIMEDOUT;
+}
+
+static void mv88e6xxx_ppu_reenable_work(struct work_struct *ugly)
+{
+	struct mv88e6xxx_priv_state *ps;
+
+	ps = container_of(ugly, struct mv88e6xxx_priv_state, ppu_work);
+	if (mutex_trylock(&ps->ppu_mutex)) {
+	        struct dsa_switch *ds = ((struct dsa_switch *)ps) - 1;
+
+	        if (mv88e6xxx_ppu_enable(ds) == 0)
+	                ps->ppu_disabled = 0;
+	        mutex_unlock(&ps->ppu_mutex);
+	}
+}
+
+static void mv88e6xxx_ppu_reenable_timer(unsigned long _ps)
+{
+	struct mv88e6xxx_priv_state *ps = (void *)_ps;
+
+	schedule_work(&ps->ppu_work);
+}
+
+static int mv88e6xxx_ppu_access_get(struct dsa_switch *ds)
+{
+	struct mv88e6xxx_priv_state *ps = (void *)(ds + 1);
+	int ret;
+
+	mutex_lock(&ps->ppu_mutex);
+
+	/*
+	 * If the PHY polling unit is enabled, disable it so that
+	 * we can access the PHY registers.  If it was already
+	 * disabled, cancel the timer that is going to re-enable
+	 * it.
+	 */
+	if (!ps->ppu_disabled) {
+	        ret = mv88e6xxx_ppu_disable(ds);
+	        if (ret < 0) {
+	                mutex_unlock(&ps->ppu_mutex);
+	                return ret;
+	        }
+	        ps->ppu_disabled = 1;
+	} else {
+	        del_timer(&ps->ppu_timer);
+	        ret = 0;
+	}
+
+	return ret;
+}
+
+static void mv88e6xxx_ppu_access_put(struct dsa_switch *ds)
+{
+	struct mv88e6xxx_priv_state *ps = (void *)(ds + 1);
+
+	/*
+	 * Schedule a timer to re-enable the PHY polling unit.
+	 */
+	mod_timer(&ps->ppu_timer, jiffies + msecs_to_jiffies(10));
+	mutex_unlock(&ps->ppu_mutex);
+}
+
+void mv88e6xxx_ppu_state_init(struct dsa_switch *ds)
+{
+	struct mv88e6xxx_priv_state *ps = (void *)(ds + 1);
+
+	mutex_init(&ps->ppu_mutex);
+	INIT_WORK(&ps->ppu_work, mv88e6xxx_ppu_reenable_work);
+	init_timer(&ps->ppu_timer);
+	ps->ppu_timer.data = (unsigned long)ps;
+	ps->ppu_timer.function = mv88e6xxx_ppu_reenable_timer;
+}
+
+int mv88e6xxx_phy_read_ppu(struct dsa_switch *ds, int addr, int regnum)
+{
+	int ret;
+
+	ret = mv88e6xxx_ppu_access_get(ds);
+	if (ret >= 0) {
+	        ret = mv88e6xxx_reg_read(ds, addr, regnum);
+	        mv88e6xxx_ppu_access_put(ds);
+	}
+
+	return ret;
+}
+
+int mv88e6xxx_phy_write_ppu(struct dsa_switch *ds, int addr,
+			    int regnum, u16 val)
+{
+	int ret;
+
+	ret = mv88e6xxx_ppu_access_get(ds);
+	if (ret >= 0) {
+	        ret = mv88e6xxx_reg_write(ds, addr, regnum, val);
+	        mv88e6xxx_ppu_access_put(ds);
+	}
+
+	return ret;
+}
+#endif
+
 void mv88e6xxx_poll_link(struct dsa_switch *ds)
 {
 	int i;
diff --git a/net/dsa/mv88e6xxx.h b/net/dsa/mv88e6xxx.h
index a004d4d..eb0e0aa 100644
--- a/net/dsa/mv88e6xxx.h
+++ b/net/dsa/mv88e6xxx.h
@@ -23,6 +23,17 @@ struct mv88e6xxx_priv_state {
 	 */
 	struct mutex	smi_mutex;
 
+#ifdef CONFIG_NET_DSA_MV88E6XXX_NEED_PPU
+	/*
+	 * Handles automatic disabling and re-enabling of the PHY
+	 * polling unit.
+	 */
+	struct mutex		ppu_mutex;
+	int			ppu_disabled;
+	struct work_struct	ppu_work;
+	struct timer_list	ppu_timer;
+#endif
+
 	/*
 	 * This mutex serialises access to the statistics unit.
 	 * Hold this mutex over snapshot + dump sequences.
@@ -42,9 +53,14 @@ int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
                           int reg, u16 val);
 int mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg, u16 val);
 int mv88e6xxx_config_prio(struct dsa_switch *ds);
+int mv88e6xxx_set_addr_direct(struct dsa_switch *ds, u8 *addr);
 int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr);
 int mv88e6xxx_phy_read(struct dsa_switch *ds, int addr, int regnum);
 int mv88e6xxx_phy_write(struct dsa_switch *ds, int addr, int regnum, u16 val);
+void mv88e6xxx_ppu_state_init(struct dsa_switch *ds);
+int mv88e6xxx_phy_read_ppu(struct dsa_switch *ds, int addr, int regnum);
+int mv88e6xxx_phy_write_ppu(struct dsa_switch *ds, int addr,
+			    int regnum, u16 val);
 void mv88e6xxx_poll_link(struct dsa_switch *ds);
 void mv88e6xxx_get_strings(struct dsa_switch *ds,
 			   int nr_stats, struct mv88e6xxx_hw_stat *stats,
-- 
1.5.6.4
