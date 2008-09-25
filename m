From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 3/4] [NET] dsa: add support for the Marvell 88E6131 switch chip
Date: Thu, 25 Sep 2008 18:42:35 +0200
Message-ID: <20080925164235.GD25190@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Fleming <afleming@freescale.com>,
	Imre Kaloz <kaloz@openwrt.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Nicolas Pitre <nico@cam.org>, Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:37907 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755417AbYIYQmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 12:42:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the older Marvell 88E6131 switch chip.  This chip
only supports the original (ethertype-less) DSA tagging format.

On the 88E6131, there is a PHY Polling Unit (PPU) which has exclusive
access to each of the PHY's MII management registers.  If we want to
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
---
 net/dsa/Kconfig   |   13 ++
 net/dsa/marvell.c |  490 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 503 insertions(+), 0 deletions(-)

diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index e8937f0..90ed791 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -24,6 +24,19 @@ config NET_DSA_MARVELL
 	bool
 	default n
 
+config NET_DSA_MARVELL_HAVE_PPU
+	bool
+	default n
+
+config NET_DSA_ZEPHYR
+	bool "Marvell 88E6131 ethernet switch chip support"
+	select NET_DSA_TAG_DSA
+	select NET_DSA_MARVELL
+	select NET_DSA_MARVELL_HAVE_PPU
+	---help---
+	  This enables support for the Marvell 88E6131 ethernet switch
+	  chip.
+
 config NET_DSA_EMERALD
 	bool "Marvell 88E6123/6161/6165 ethernet switch chip support"
 	select NET_DSA_TAG_EDSA
diff --git a/net/dsa/marvell.c b/net/dsa/marvell.c
index 9b89f0b..d425994 100644
--- a/net/dsa/marvell.c
+++ b/net/dsa/marvell.c
@@ -26,6 +26,15 @@ struct priv_state {
 	struct mutex	smi_mutex;
 
 	/*
+	 * Handles automatic disabling and re-enabling of the PHY
+	 * polling unit.
+	 */
+	struct mutex		ppu_mutex;
+	int			ppu_disabled;
+	struct work_struct	ppu_work;
+	struct timer_list	ppu_timer;
+
+	/*
 	 * This mutex serialises access to the statistics unit.
 	 * Hold this mutex over snapshot + dump sequences.
 	 */
@@ -178,6 +187,146 @@ static int mii_write(struct dsa_switch *ds, int addr, int regnum, u16 val)
 	return reg_write(ds, addr, regnum, val);
 }
 
+#ifdef CONFIG_NET_DSA_MARVELL_HAVE_PPU
+static int ppu_disable(struct dsa_switch *ds)
+{
+	int ret;
+	int i;
+
+	ret = reg_read(ds, REG_GLOBAL, 0x04);
+	if (ret < 0)
+		return ret;
+
+	ret = reg_write(ds, REG_GLOBAL, 0x04, ret & ~0x4000);
+	if (ret < 0)
+		return ret;
+
+	for (i = 0; i < 1000; i++) {
+		ret = reg_read(ds, REG_GLOBAL, 0x00);
+		if (ret < 0)
+			return ret;
+
+		msleep(1);
+		if ((ret & 0xc000) != 0xc000)
+			return 0;
+	}
+
+	return -ETIMEDOUT;
+}
+
+static int ppu_enable(struct dsa_switch *ds)
+{
+	int ret;
+	int i;
+
+	ret = reg_read(ds, REG_GLOBAL, 0x04);
+	if (ret < 0)
+		return ret;
+
+	ret = reg_write(ds, REG_GLOBAL, 0x04, ret | 0x4000);
+	if (ret < 0)
+		return ret;
+
+	for (i = 0; i < 1000; i++) {
+		ret = reg_read(ds, REG_GLOBAL, 0x00);
+		if (ret < 0)
+			return ret;
+
+		msleep(1);
+		if ((ret & 0xc000) == 0xc000)
+			return 0;
+	}
+
+	return -ETIMEDOUT;
+}
+
+static void ppu_reenable_work(struct work_struct *ugly)
+{
+	struct priv_state *ps;
+
+	ps = container_of(ugly, struct priv_state, ppu_work);
+	if (mutex_trylock(&ps->ppu_mutex)) {
+		struct dsa_switch *ds = ((struct dsa_switch *)ps) - 1;
+
+		if (ppu_enable(ds) == 0)
+			ps->ppu_disabled = 0;
+		mutex_unlock(&ps->ppu_mutex);
+	}
+}
+
+static void ppu_reenable_timer(unsigned long _ps)
+{
+	struct priv_state *ps = (void *)_ps;
+
+	schedule_work(&ps->ppu_work);
+}
+
+static int ppu_access_get(struct dsa_switch *ds)
+{
+	struct priv_state *ps = (void *)(ds + 1);
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
+		ret = ppu_disable(ds);
+		if (ret < 0) {
+			mutex_unlock(&ps->ppu_mutex);
+			return ret;
+		}
+		ps->ppu_disabled = 1;
+	} else {
+		del_timer(&ps->ppu_timer);
+		ret = 0;
+	}
+
+	return ret;
+}
+
+static void ppu_access_put(struct dsa_switch *ds)
+{
+	struct priv_state *ps = (void *)(ds + 1);
+
+	/*
+	 * Schedule a timer to re-enable the PHY polling unit.
+	 */
+	mod_timer(&ps->ppu_timer, jiffies + msecs_to_jiffies(10));
+	mutex_unlock(&ps->ppu_mutex);
+}
+
+static int mii_read_ppu(struct dsa_switch *ds, int addr, int regnum)
+{
+	int ret;
+
+	ret = ppu_access_get(ds);
+	if (ret >= 0) {
+		ret = reg_read(ds, addr, regnum);
+		ppu_access_put(ds);
+	}
+
+	return ret;
+}
+
+static int mii_write_ppu(struct dsa_switch *ds, int addr, int regnum, u16 val)
+{
+	int ret;
+
+	ret = ppu_access_get(ds);
+	if (ret >= 0) {
+		ret = reg_write(ds, addr, regnum, val);
+		ppu_access_put(ds);
+	}
+
+	return ret;
+}
+#endif
+
 
 /* shared functions *********************************************************/
 static int marvell_switch_reset(struct dsa_switch *ds)
@@ -483,6 +632,331 @@ static int marvell_get_sset_count(struct dsa_switch *ds)
 }
 
 
+#ifdef CONFIG_NET_DSA_ZEPHYR
+/* zephyr *******************************************************************/
+static int zephyr_probe(struct mii_bus *bus, int sw_addr)
+{
+	if ((__reg_read(bus, sw_addr, REG_PORT(0), 0x03) & 0xfff0) == 0x1060)
+		return 1;
+
+	return 0;
+}
+
+static int zephyr_setup_global(struct dsa_switch *ds)
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
+	ret = reg_write(ds, REG_GLOBAL, 0x04, 0x4400);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Set the default address aging time to 5 minutes, and
+	 * enable address learn messages to be sent to all message
+	 * ports.
+	 */
+	ret = reg_write(ds, REG_GLOBAL, 0x0a, 0x0148);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Configure the priority mapping registers.
+	 */
+	ret = marvell_config_prio(ds);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Set the VLAN ethertype to 0x8100.
+	 */
+	ret = reg_write(ds, REG_GLOBAL, 0x19, 0x8100);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Disable ARP mirroring, and configure the cpu port as the
+	 * port to which ingress and egress monitor frames are to be
+	 * sent.
+	 */
+	ret = reg_write(ds, REG_GLOBAL, 0x1a, (ds->cpu_port * 0x1100) | 0x00f0);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Disable cascade port functionality, and set the switch's
+	 * DSA device number to zero.
+	 */
+	ret = reg_write(ds, REG_GLOBAL, 0x1c, 0xe000);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Send all frames with destination addresses matching
+	 * 01:80:c2:00:00:0x to the CPU port.
+	 */
+	ret = reg_write(ds, REG_GLOBAL2, 0x03, 0xffff);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Ignore removed tag data on doubly tagged packets, disable
+	 * flow control messages, force flow control priority to the
+	 * highest, and send all special multicast frames to the CPU
+	 * port at the higest priority.
+	 */
+	ret = reg_write(ds, REG_GLOBAL2, 0x05, 0x00ff);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Map all DSA device IDs to the CPU port.
+	 */
+	for (i = 0; i < 32; i++) {
+		ret = reg_write(ds, REG_GLOBAL2, 0x06,
+				0x8000 | (i << 8) | ds->cpu_port);
+		if (ret < 0)
+			return ret;
+	}
+
+	/*
+	 * Clear all trunk masks.
+	 */
+	for (i = 0; i < 8; i++) {
+		ret = reg_write(ds, REG_GLOBAL2, 0x07,
+				0x8000 | (i << 12) | 0xff);
+		if (ret < 0)
+			return ret;
+	}
+
+	/*
+	 * Clear all trunk mappings.
+	 */
+	for (i = 0; i < 16; i++) {
+		ret = reg_write(ds, REG_GLOBAL2, 0x08, 0x8000 | (i << 11));
+		if (ret < 0)
+			return ret;
+	}
+
+	/*
+	 * Force the priority of IGMP/MLD snoop frames and ARP frames
+	 * to the highest setting.
+	 */
+	ret = reg_write(ds, REG_GLOBAL2, 0x0f, 0x00ff);
+	if (ret < 0)
+		return ret;
+
+	return 0;
+}
+
+static int zephyr_setup_port(struct dsa_switch *ds, int p)
+{
+	int addr = REG_PORT(p);
+	int ret;
+
+	/*
+	 * MAC Forcing register: don't force link, speed, duplex
+	 * or flow control state to any particular values.
+	 */
+	ret = reg_write(ds, addr, 0x01, 0x0003);
+	if (ret < 0)
+		return ret;
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
+	ret = reg_write(ds, addr, 0x04, (p == ds->cpu_port) ? 0x0537 : 0x0433);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Port Control 1: disable trunking.  Also, if this is the
+	 * CPU port, enable learn messages to be sent to this port.
+	 */
+	ret = reg_write(ds, addr, 0x05, (p == ds->cpu_port) ? 0x8000 : 0x0000);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Port based VLAN map: give each port its own address
+	 * database, allow the CPU port to talk to each of the 'real'
+	 * ports, and allow each of the 'real' ports to only talk to
+	 * the CPU port.
+	 */
+	ret = reg_write(ds, addr, 0x06,
+			((p & 0xf) << 12) |
+			 ((p == ds->cpu_port) ?
+				ds->valid_port_mask :
+				(1 << ds->cpu_port)));
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Default VLAN ID and priority: don't set a default VLAN
+	 * ID, and set the default packet priority to zero.
+	 */
+	ret = reg_write(ds, addr, 0x07, 0x0000);
+	if (ret < 0)
+		return ret;
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
+	ret = reg_write(ds, addr, 0x08,
+			((p == ds->cpu_port) ? 0x00c0 : 0x0080) |
+			 ds->cpu_port);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Rate Control: disable ingress rate limiting.
+	 */
+	ret = reg_write(ds, addr, 0x09, 0x0000);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Rate Control 2: disable egress rate limiting.
+	 */
+	ret = reg_write(ds, addr, 0x0a, 0x0000);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Port Association Vector: when learning source addresses
+	 * of packets, add the address to the address database using
+	 * a port bitmap that has only the bit for this port set and
+	 * the other bits clear.
+	 */
+	ret = reg_write(ds, addr, 0x0b, 1 << p);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Tag Remap: use an identity 802.1p prio -> switch prio
+	 * mapping.
+	 */
+	ret = reg_write(ds, addr, 0x18, 0x3210);
+	if (ret < 0)
+		return ret;
+
+	/*
+	 * Tag Remap 2: use an identity 802.1p prio -> switch prio
+	 * mapping.
+	 */
+	ret = reg_write(ds, addr, 0x19, 0x7654);
+	if (ret < 0)
+		return ret;
+
+	return 0;
+}
+
+static int zephyr_setup(struct dsa_switch *ds)
+{
+	struct priv_state *ps = (void *)(ds + 1);
+	int i;
+	int ret;
+
+	mutex_init(&ps->smi_mutex);
+	mutex_init(&ps->ppu_mutex);
+	INIT_WORK(&ps->ppu_work, ppu_reenable_work);
+	init_timer(&ps->ppu_timer);
+	ps->ppu_timer.data = (unsigned long)ps;
+	ps->ppu_timer.function = ppu_reenable_timer;
+	mutex_init(&ps->stats_mutex);
+
+	ret = marvell_switch_reset(ds);
+	if (ret < 0)
+		return ret;
+
+	/* @@@ initialise vtu and atu */
+
+	ret = zephyr_setup_global(ds);
+	if (ret < 0)
+		return ret;
+
+	for (i = 0; i < 8; i++) {
+		ret = zephyr_setup_port(ds, i);
+		if (ret < 0)
+			return ret;
+	}
+
+	return 0;
+}
+
+static int zephyr_set_addr(struct dsa_switch *ds, u8 *addr)
+{
+	int ret;
+
+	ret = reg_write(ds, REG_GLOBAL, 0x01, (addr[0] << 8) | addr[1]);
+	if (ret < 0)
+		return ret;
+
+	ret = reg_write(ds, REG_GLOBAL, 0x02, (addr[2] << 8) | addr[3]);
+	if (ret < 0)
+		return ret;
+
+	ret = reg_write(ds, REG_GLOBAL, 0x03, (addr[4] << 8) | addr[5]);
+	if (ret < 0)
+		return ret;
+
+	return 0;
+}
+
+static int zephyr_port_to_phy_addr(int port)
+{
+	if (port >= 0 && port != 3 && port <= 7)
+		return port;
+	return -1;
+}
+
+static int zephyr_mii_read(struct dsa_switch *ds, int port, int regnum)
+{
+	int addr;
+
+	addr = zephyr_port_to_phy_addr(port);
+	if (addr == -1)
+		return 0xffff;
+
+	return mii_read_ppu(ds, addr, regnum);
+}
+
+static int
+zephyr_mii_write(struct dsa_switch *ds, int port, int regnum, u16 val)
+{
+	int addr;
+
+	addr = zephyr_port_to_phy_addr(port);
+	if (addr == -1)
+		return 0xffff;
+
+	return mii_write_ppu(ds, addr, regnum, val);
+}
+#endif
+
+
 #ifdef CONFIG_NET_DSA_EMERALD
 /* emerald ******************************************************************/
 static int emerald6123_probe(struct mii_bus *bus, int sw_addr)
@@ -895,6 +1369,22 @@ static int emerald_set_addr(struct dsa_switch *ds, u8 *addr)
 
 /* main *********************************************************************/
 static struct dsa_switch_driver marvell_switch_drivers[] = {
+#ifdef CONFIG_NET_DSA_ZEPHYR
+	{
+		.name			= "Marvell 88E6131",
+		.tag_methods		= TAG_DSA_MASK,
+		.priv_size		= sizeof(struct priv_state),
+		.probe			= zephyr_probe,
+		.setup			= zephyr_setup,
+		.set_addr		= zephyr_set_addr,
+		.mii_read		= zephyr_mii_read,
+		.mii_write		= zephyr_mii_write,
+		.poll_link		= marvell_poll_link,
+		.get_strings		= marvell_get_strings,
+		.get_ethtool_stats	= marvell_get_ethtool_stats,
+		.get_sset_count		= marvell_get_sset_count,
+	},
+#endif
 #ifdef CONFIG_NET_DSA_EMERALD
 	{
 		.name			= "Marvell 88E6123",
-- 
1.5.6.4
