From: Pavel Machek <pavel@denx.de>
Subject: [PATCH] DSA support for Micrel KSZ8895
Date: Sun, 27 Aug 2017 14:36:58 +0200
Message-ID: <20170827123658.GA727@amd>
References: <20170816075524.GA18532@amd>
 <20170816140451.GA13006@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="qMm9M+Fa2AknHoGS"
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tristram.Ha@micrel.com, andrew@lunn.ch, pavel@denx.de
To: Woojung.Huh@microchip.com, nathan.leigh.conrad@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--qMm9M+Fa2AknHoGS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

So I fought with the driver a bit more, and now I have something that
kind-of-works.

"great great hack" belows worries me.

Yeah, disabled code needs to be removed before merge.

No, tag_ksz part probably is not acceptable. Do you see solution
better than just copying it into tag_ksz1 file?

Any more comments, etc?

Help would be welcome.

Best regards,
									Pavel

Signed-off-by: Pavel Machek <pavel@denx.de>

diff --git a/drivers/net/dsa/microchip/Kconfig b/drivers/net/dsa/microchip/=
Kconfig
index a8b8f59099ce..7b7d7ddb3488 100644
--- a/drivers/net/dsa/microchip/Kconfig
+++ b/drivers/net/dsa/microchip/Kconfig
@@ -1,12 +1,25 @@
 menuconfig MICROCHIP_KSZ
-	tristate "Microchip KSZ series switch support"
+	tristate "Microchip KSZ 9477 series switch support"
+	depends on NET_DSA
+	select NET_DSA_TAG_KSZ
+	help
+	  This driver adds support for Microchip KSZ switch chips.
+
+menuconfig MICROCHIP_KSZ_8895
+	tristate "Microchip KSZ 8895 series switch support"
 	depends on NET_DSA
 	select NET_DSA_TAG_KSZ
 	help
 	  This driver adds support for Microchip KSZ switch chips.
=20
 config MICROCHIP_KSZ_SPI_DRIVER
-	tristate "KSZ series SPI connected switch driver"
+	tristate "KSZ 9477 series SPI connected switch driver"
 	depends on MICROCHIP_KSZ && SPI
 	help
 	  Select to enable support for registering switches configured through SP=
I.
+
+config MICROCHIP_KSZ_8895_SPI_DRIVER
+	tristate "KSZ 8895 series SPI connected switch driver"
+	depends on MICROCHIP_KSZ_8895 && SPI
+	help
+	  Select to enable support for registering switches configured through SP=
I.
diff --git a/drivers/net/dsa/microchip/Makefile b/drivers/net/dsa/microchip=
/Makefile
index ed335e29fae8..b6a17f79d2d9 100644
--- a/drivers/net/dsa/microchip/Makefile
+++ b/drivers/net/dsa/microchip/Makefile
@@ -1,2 +1,4 @@
 obj-$(CONFIG_MICROCHIP_KSZ)	        +=3D ksz_common.o
+obj-$(CONFIG_MICROCHIP_KSZ_8895)        +=3D ksz_8895.o
 obj-$(CONFIG_MICROCHIP_KSZ_SPI_DRIVER)	+=3D ksz_spi.o
+obj-$(CONFIG_MICROCHIP_KSZ_8895_SPI_DRIVER)	+=3D ksz_8895_spi.o
diff --git a/drivers/net/dsa/microchip/ksz_8895.c b/drivers/net/dsa/microch=
ip/ksz_8895.c
new file mode 100644
index 000000000000..d546e08b1281
--- /dev/null
+++ b/drivers/net/dsa/microchip/ksz_8895.c
@@ -0,0 +1,721 @@
+/*
+ * Microchip switch driver main logic
+ *
+ * Copyright (C) 2017
+ * Copyright (C) 2017 Pavel Machek <pavel@denx.de>
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
+#include "ksz_8895_reg.h"
+#include "ksz_priv.h"
+
+static const struct {
+	int index;
+	char string[ETH_GSTRING_LEN];
+} mib_names[TOTAL_SWITCH_COUNTER_NUM] =3D {
+	{ 0x00, "???" },
+};
+
+static void ksz_cfg(struct ksz_device *dev, u32 addr, u8 bits, bool set)
+{
+	u8 data;
+
+	ksz_read8(dev, addr, &data);
+	if (set)
+		data |=3D bits;
+	else
+		data &=3D ~bits;
+	ksz_write8(dev, addr, data);
+}
+
+#if 0
+static void ksz_cfg32(struct ksz_device *dev, u32 addr, u32 bits, bool set)
+{
+	u32 data;
+
+	ksz_read32(dev, addr, &data);
+	if (set)
+		data |=3D bits;
+	else
+		data &=3D ~bits;
+	ksz_write32(dev, addr, data);
+}
+#endif
+
+static void ksz_port_cfg(struct ksz_device *dev, int port, int offset, u8 =
bits,
+			 bool set)
+{
+	u32 addr;
+	u8 data;
+
+	addr =3D PORT_CTRL_ADDR(port, offset);
+	ksz_read8(dev, addr, &data);
+
+	if (set)
+		data |=3D bits;
+	else
+		data &=3D ~bits;
+
+	ksz_write8(dev, addr, data);
+}
+
+#if 0
+static void ksz_port_cfg32(struct ksz_device *dev, int port, int offset,
+			   u32 bits, bool set)
+{
+	u32 addr;
+	u32 data;
+
+	addr =3D PORT_CTRL_ADDR(port, offset);
+	ksz_read32(dev, addr, &data);
+
+	if (set)
+		data |=3D bits;
+	else
+		data &=3D ~bits;
+
+	ksz_write32(dev, addr, data);
+}
+#endif
+
+#define NOTIMPL() do { NOTIMPLV(); return -EJUKEBOX; } while (0)
+#define NOTIMPLV() do { printk("Not implemented -- %s\n",  __func__); } wh=
ile (0)
+
+static int ksz_reset_switch(struct dsa_switch *ds)
+{
+	struct ksz_device *dev =3D ds->priv;
+#if 0
+	/* This seems to break the code. */
+	ksz_write8(dev, REG_POWER_MANAGEMENT_1, SW_SOFTWARE_POWER_DOWN << SW_POWE=
R_MANAGEMENT_MODE_S);
+        ksz_write8(dev, REG_POWER_MANAGEMENT_1, 0);
+#endif
+	return 0;
+}
+
+#define PORT_MAC_LOOPBACK_my 0x80
+#define REG_PORT_CTRL_LOOPBACK 0x0f
+
+static void port_setup(struct ksz_device *dev, int port, bool cpu_port)
+{
+	printk("Port setup %d, %d\n", port, cpu_port);
+
+	if (cpu_port && port !=3D 4)
+		printk("!!! tail tagging only works on port 5\n");
+	if (cpu_port) {
+		printk("enable tail tagging\n");
+		ksz_cfg(dev, S_TAIL_TAG_CTRL, SW_TAIL_TAG_ENABLE, true);
+	}
+
+	ksz_port_cfg(dev, port, REG_PORT_CTRL_LOOPBACK, PORT_MAC_LOOPBACK_my, fal=
se);
+#ifdef FIXME
+	/* set back pressure */
+	ksz_port_cfg(dev, port, REG_PORT_MAC_CTRL_1, PORT_BACK_PRESSURE, true);
+
+	/* set flow control */
+	ksz_port_cfg(dev, port, REG_PORT_CTRL_0,
+		     PORT_FORCE_TX_FLOW_CTRL | PORT_FORCE_RX_FLOW_CTRL, true);
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
+	/* configure MAC to 1G & RGMII mode */
+	ksz_pread8(dev, port, REG_PORT_XMII_CTRL_1, &data8);
+	data8 |=3D PORT_RGMII_ID_EG_ENABLE;
+	data8 &=3D ~PORT_MII_NOT_1GBIT;
+	data8 &=3D ~PORT_MII_SEL_M;
+	data8 |=3D PORT_RGMII_SEL;
+	ksz_pwrite8(dev, port, REG_PORT_XMII_CTRL_1, data8);
+
+	/* clear pending interrupts */
+	ksz_pread16(dev, port, REG_PORT_PHY_INT_ENABLE, &data16);
+#endif
+}
+
+static void ksz_config_cpu_port(struct dsa_switch *ds)
+{
+	struct ksz_device *dev =3D ds->priv;
+	int i;
+
+	ds->num_ports =3D dev->port_cnt;
+
+	for (i =3D 0; i < ds->num_ports; i++) {
+		if (dsa_is_cpu_port(ds, i) && (dev->cpu_ports & (1 << i))) {
+			dev->cpu_port =3D i;
+
+			/* enable cpu port */
+			port_setup(dev, i, true);
+		}
+	}
+}
+
+#if 0
+/*
+ * sw_init_vlan - initialize switch VLAN
+ *
+ * Everyone can communicate with CPU, ports do not communicate with each o=
ther
+ */
+static void sw_init_vlan(struct ksz_device *dev)
+{
+	int port;
+=09
+	for (port =3D 0; port < dev->port_cnt; port++) {
+		//port_get_def_vid(sw, port, &info->port_cfg[port].vid);
+		//port_r(sw, port, P_MIRROR_CTRL, &data);
+
+		ksz_port_cfg(dev, port, P_MIRROR_CTRL, PORT_VLAN_MEMBERSHIP, false);
+		ksz_port_cfg(dev, port, P_MIRROR_CTRL, 1<<port, true);	=09
+#if 0
+		port_cfg(sw, port, P_INS_SRC_PVID_CTRL,
+			(PORT_INS_TAG_FOR_PORT_5 | PORT_INS_TAG_FOR_PORT_4 |
+			PORT_INS_TAG_FOR_PORT_3 | PORT_INS_TAG_FOR_PORT_2),
+			true);
+#endif
+	}
+	ksz_port_cfg(dev, dev->port_cnt-1, P_MIRROR_CTRL, PORT_VLAN_MEMBERSHIP, t=
rue);
+}
+
+static void sw_init_bridge(struct ksz_device *dev)
+{
+	int port;
+
+	for (port =3D 0; port < dev->port_cnt; port++) {
+		ksz_port_cfg(dev, port, P_MIRROR_CTRL, PORT_VLAN_MEMBERSHIP, true);
+	}
+}
+#endif
+
+static void br_update(struct dsa_switch *ds)
+{
+	struct ksz_device *dev =3D ds->priv;
+	int i,j;
+	int mask[5];
+	u8 val;
+
+	for (i =3D 0; i < dev->port_cnt; i++) {
+		mask[i] =3D 0;
+	}
+
+	for (i =3D 0; i < dev->port_cnt; i++) {
+		for (j =3D 0; j < dev->port_cnt; j++) {
+			//printk("port %d bridge %lx\n", i, (unsigned long) ds->ports[i].bridge=
_dev);
+			if (ds->ports[i].bridge_dev &&
+			    (ds->ports[i].bridge_dev =3D=3D ds->ports[j].bridge_dev))
+				mask[i] |=3D 1<<j;
+		}
+	}
+
+	for (i =3D 0; i < dev->port_cnt-1; i++) {
+		printk("port %d mask %x\n", i, mask[i]);
+		ksz_pread8(dev, i, P_MIRROR_CTRL, &val);
+		val &=3D ~PORT_VLAN_MEMBERSHIP;
+		val |=3D mask[i] | 0x10 | (1 << i);
+		ksz_pwrite8(dev, i, P_MIRROR_CTRL, val);
+	}
+
+	ksz_pread8(dev, dev->port_cnt-1, P_MIRROR_CTRL, &val);
+	val &=3D ~PORT_VLAN_MEMBERSHIP;
+	val |=3D mask[i] | 0x1f;
+	ksz_pwrite8(dev, dev->port_cnt-1, P_MIRROR_CTRL, val);
+
+}
+
+
+/* bridge_change -- need to get it here */
+
+int ksz_br_join(struct dsa_switch *ds, int port, struct net_device *br)
+{
+	struct ksz_device *dev =3D ds->priv;
+
+	br_update(ds);
+	return 0;
+}
+
+void ksz_br_leave(struct dsa_switch *ds, int port, struct net_device *br)
+{
+	struct ksz_device *dev =3D ds->priv;
+
+//	sw_init_vlan(dev);
+=09
+	br_update(ds);
+}
+
+
+
+static int ksz_setup(struct dsa_switch *ds)
+{
+	struct ksz_device *dev =3D ds->priv;
+	int ret =3D 0;
+
+	dev->vlan_cache =3D devm_kcalloc(dev->dev, sizeof(struct vlan_table),
+				       dev->num_vlans, GFP_KERNEL);
+	if (!dev->vlan_cache)
+		return -ENOMEM;
+
+	ret =3D ksz_reset_switch(ds);
+	if (ret) {
+		dev_err(ds->dev, "failed to reset switch\n");
+		return ret;
+	}
+
+	/* accept packet up to 2000bytes */
+	//ksz_cfg(dev, REG_SW_MAC_CTRL_1, SW_LEGAL_PACKET_DISABLE, true);
+
+	ksz_config_cpu_port(ds);
+
+	ksz_cfg(dev, REG_SW_CTRL_2, MULTICAST_STORM_DISABLE, true);
+
+	/* queue based egress rate limit */
+	//ksz_cfg(dev, REG_SW_MAC_CTRL_5, SW_OUT_RATE_LIMIT_QUEUE_BASED, true);
+
+	//sw_init_broad_storm(sw);
+        //sw_init_prio(sw);
+        //sw_init_prio_rate(sw);
+	//sw_init_vlan(ds); FIXME!!!
+
+	/* start switch */
+	ksz_cfg(dev, REG_CHIP_ID1, SW_START, true);
+
+	return 0;
+}
+
+static enum dsa_tag_protocol ksz_get_tag_protocol(struct dsa_switch *ds)
+{
+	return DSA_TAG_PROTO_KSZ;
+}
+
+#include "ksz_mdio_emulation.c"
+
+static int ksz_enable_port(struct dsa_switch *ds, int port,
+			   struct phy_device *phy)
+{
+	struct ksz_device *dev =3D ds->priv;
+
+	/* setup slave port */
+	port_setup(dev, port, false);
+
+	return 0;
+}
+
+
+static void ksz_disable_port(struct dsa_switch *ds, int port,
+			     struct phy_device *phy)
+{
+	struct ksz_device *dev =3D ds->priv;
+
+	/* there is no port disable */
+	ksz_port_cfg(dev, port, REG_PORT_CTRL_LOOPBACK, PORT_MAC_LOOPBACK_my, tru=
e);
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
+	for (i =3D 0; i < TOTAL_SWITCH_COUNTER_NUM; i++) {
+		memcpy(buf + i * ETH_GSTRING_LEN, mib_names[i].string,
+		       ETH_GSTRING_LEN);
+	}
+}
+
+static void ksz_get_ethtool_stats(struct dsa_switch *ds, int port,
+				  uint64_t *buf)
+{
+	NOTIMPLV();
+}
+
+#if 0
+static void ksz_dump(struct ksz_device *dev)
+{
+	int i;
+	u8 v;
+
+	printk("ksz: dumping:\n");
+	for (i =3D 0; i < 0x100; i++) {
+		if (!(i % 0x10))
+			printk("\n %x: ", i);
+		ksz_read8(dev, i, &v);
+		printk("%02x ", v);
+	}
+	printk("\nksz: dump done\n");
+}
+#endif
+
+static void ksz_port_stp_state_set(struct dsa_switch *ds, int port, u8 sta=
te)
+{
+	struct ksz_device *dev =3D ds->priv;
+	u8 data;
+
+	printk("port %d state %d\n", port, state);
+	ksz_pread8(dev, port, P_STP_CTRL, &data);
+	data &=3D ~(PORT_TX_ENABLE | PORT_RX_ENABLE | PORT_LEARN_DISABLE);
+
+	switch (state) {
+	case BR_STATE_DISABLED:
+		printk("port %d state %d disable\n", port, state);			=09
+		data |=3D PORT_LEARN_DISABLE;
+		break;
+	case BR_STATE_LISTENING:
+		printk("port %d state %d listen\n", port, state);
+		data |=3D (PORT_RX_ENABLE | PORT_LEARN_DISABLE);
+		break;
+	case BR_STATE_LEARNING:
+		printk("port %d state %d learn\n", port, state);
+		data |=3D PORT_RX_ENABLE;
+		break;
+	case BR_STATE_FORWARDING:
+		printk("port %d state %d forwarding\n", port, state);	=09
+		data |=3D (PORT_TX_ENABLE | PORT_RX_ENABLE);
+		break;
+	case BR_STATE_BLOCKING:
+		printk("port %d state %d blocking\n", port, state);
+		data |=3D PORT_LEARN_DISABLE;
+		break;
+	default:
+		dev_err(ds->dev, "invalid STP state: %d\n", state);
+		return;
+	}
+	/* FIXME: great great hack */
+	data |=3D (PORT_RX_ENABLE | PORT_TX_ENABLE);
+=09
+
+	ksz_pwrite8(dev, port, P_STP_CTRL, data);
+	//ksz_dump(dev);
+}
+
+static void ksz_port_fast_age(struct dsa_switch *ds, int port)
+{
+	NOTIMPLV();
+=09
+}
+
+static int ksz_port_vlan_filtering(struct dsa_switch *ds, int port, bool f=
lag)
+{
+	NOTIMPL();
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
+	NOTIMPLV();
+}
+
+static int ksz_port_vlan_del(struct dsa_switch *ds, int port,
+			     const struct switchdev_obj_port_vlan *vlan)
+{
+	NOTIMPL();
+
+	return 0;
+}
+
+static int ksz_port_vlan_dump(struct dsa_switch *ds, int port,
+			      struct switchdev_obj_port_vlan *vlan,
+			      switchdev_obj_dump_cb_t *cb)
+{
+	NOTIMPL();
+}
+
+static int ksz_port_fdb_prepare(struct dsa_switch *ds, int port,
+				const struct switchdev_obj_port_fdb *fdb,
+				struct switchdev_trans *trans)
+{
+	/* nothing needed */
+
+	return 0;
+}
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
+static void ksz_port_fdb_add(struct dsa_switch *ds, int port,
+			     const struct switchdev_obj_port_fdb *fdb,
+			     struct switchdev_trans *trans)
+{
+	NOTIMPLV();
+}
+
+static int ksz_port_fdb_del(struct dsa_switch *ds, int port,
+			    const struct switchdev_obj_port_fdb *fdb)
+{
+	NOTIMPL();
+}
+
+static int ksz_port_fdb_dump(struct dsa_switch *ds, int port,
+			     struct switchdev_obj_port_fdb *fdb,
+			     switchdev_obj_dump_cb_t *cb)
+{
+	NOTIMPL();
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
+	NOTIMPLV();
+}
+
+static int ksz_port_mdb_del(struct dsa_switch *ds, int port,
+			    const struct switchdev_obj_port_mdb *mdb)
+{
+	NOTIMPL();
+}
+
+static int ksz_port_mdb_dump(struct dsa_switch *ds, int port,
+			     struct switchdev_obj_port_mdb *mdb,
+			     switchdev_obj_dump_cb_t *cb)
+{
+	/* this is not called by switch layer */
+	return 0;
+}
+
+static int ksz_port_mirror_add(struct dsa_switch *ds, int port,
+			       struct dsa_mall_mirror_tc_entry *mirror,
+			       bool ingress)
+{
+	NOTIMPL();
+
+}
+
+static void ksz_port_mirror_del(struct dsa_switch *ds, int port,
+				struct dsa_mall_mirror_tc_entry *mirror)
+{
+	NOTIMPLV();
+}
+
+static const struct dsa_switch_ops ksz_switch_ops =3D {
+	.get_tag_protocol	=3D ksz_get_tag_protocol,
+	.setup			=3D ksz_setup,
+	.phy_read		=3D ksz_phy_read16,
+	.phy_write		=3D ksz_phy_write16,
+	.port_enable		=3D ksz_enable_port,
+	.port_disable		=3D ksz_disable_port,
+	.get_strings		=3D ksz_get_strings,
+	.get_ethtool_stats	=3D ksz_get_ethtool_stats,
+	.get_sset_count		=3D ksz_sset_count,
+	.port_bridge_join	=3D ksz_br_join,
+	.port_bridge_leave	=3D ksz_br_leave,
+	.port_stp_state_set	=3D ksz_port_stp_state_set,
+	.port_fast_age		=3D ksz_port_fast_age,
+	.port_vlan_filtering	=3D ksz_port_vlan_filtering,
+	.port_vlan_prepare	=3D ksz_port_vlan_prepare,
+	.port_vlan_add		=3D ksz_port_vlan_add,
+	.port_vlan_del		=3D ksz_port_vlan_del,
+	.port_vlan_dump		=3D ksz_port_vlan_dump,
+	.port_fdb_prepare	=3D ksz_port_fdb_prepare,
+	.port_fdb_dump		=3D ksz_port_fdb_dump,
+	.port_fdb_add		=3D ksz_port_fdb_add,
+	.port_fdb_del		=3D ksz_port_fdb_del,
+	.port_mdb_prepare       =3D ksz_port_mdb_prepare,
+	.port_mdb_add           =3D ksz_port_mdb_add,
+	.port_mdb_del           =3D ksz_port_mdb_del,
+	.port_mdb_dump          =3D ksz_port_mdb_dump,
+	.port_mirror_add	=3D ksz_port_mirror_add,
+	.port_mirror_del	=3D ksz_port_mirror_del,
+};
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
+static const struct ksz_chip_data ksz_switch_chips[] =3D {
+	{
+		.chip_id =3D 0x95600c04,
+		.dev_name =3D "KSZ8895",
+		.num_vlans =3D 4096, /* FIXME ? */
+		.num_alus =3D 4096,
+		.num_statics =3D 16,
+		.cpu_ports =3D 0x10,	/* can be configured as cpu port */
+		.port_cnt =3D 5,		/* total physical port count */
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
+	dev->ds->ops =3D &ksz_switch_ops;
+
+	for (i =3D 0; i < ARRAY_SIZE(ksz_switch_chips); i++) {
+		const struct ksz_chip_data *chip =3D &ksz_switch_chips[i];
+
+		if (dev->chip_id =3D=3D chip->chip_id) {
+			dev->name =3D chip->dev_name;
+			dev->num_vlans =3D chip->num_vlans;
+			dev->num_alus =3D chip->num_alus;
+			dev->num_statics =3D chip->num_statics;
+			dev->port_cnt =3D chip->port_cnt;
+			dev->cpu_ports =3D chip->cpu_ports;
+
+			break;
+		}
+	}
+=09
+	printk("ksz_switch_init: detected %s\n", dev->name);
+
+	/* no switch found */
+	if (!dev->port_cnt)
+		return -ENODEV;
+
+	return 0;
+}
+
+struct ksz_device *ksz_switch_alloc(struct device *base,
+				    const struct ksz_io_ops *ops,
+				    void *priv)
+{
+	struct dsa_switch *ds;
+	struct ksz_device *swdev;
+
+	ds =3D dsa_switch_alloc(base, DSA_MAX_PORTS);
+	if (!ds)
+		return NULL;
+
+	swdev =3D devm_kzalloc(base, sizeof(*swdev), GFP_KERNEL);
+	if (!swdev)
+		return NULL;
+
+	ds->priv =3D swdev;
+	swdev->dev =3D base;
+
+	swdev->ds =3D ds;
+	swdev->priv =3D priv;
+	swdev->ops =3D ops;
+
+	return swdev;
+}
+EXPORT_SYMBOL(ksz_switch_alloc);
+
+int ksz_switch_detect(struct ksz_device *dev)
+{
+	u8 data8;
+	u32 id32;
+	int ret;
+
+	/* read chip id */
+	ret =3D ksz_read32(dev, REG_CHIP_ID0__1, &id32);
+	if (ret)
+		return ret;
+=09
+	ret =3D ksz_read8(dev, 0, &data8);
+	ret =3D ksz_read8(dev, 1, &data8);
+	ret =3D ksz_read8(dev, 2, &data8);
+	ret =3D ksz_read8(dev, 3, &data8);
+=09
+	dev->chip_id =3D id32;
+
+	return 0;
+}
+EXPORT_SYMBOL(ksz_switch_detect);
+
+int ksz_switch_register(struct ksz_device *dev)
+{
+	int ret;
+
+	if (dev->pdata)
+		dev->chip_id =3D dev->pdata->chip_id;
+
+	if (ksz_switch_detect(dev))
+		return -EINVAL;
+
+	ret =3D ksz_switch_init(dev);
+	if (ret)
+		return ret;
+
+
+	return dsa_register_switch(dev->ds);
+}
+EXPORT_SYMBOL(ksz_switch_register);
+
+void ksz_switch_remove(struct ksz_device *dev)
+{
+	dsa_unregister_switch(dev->ds);
+}
+EXPORT_SYMBOL(ksz_switch_remove);
+
+MODULE_AUTHOR("Woojung Huh <Woojung.Huh@microchip.com>");
+MODULE_DESCRIPTION("Microchip KSZ Series Switch DSA Driver");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/dsa/microchip/ksz_8895_reg.h b/drivers/net/dsa/mic=
rochip/ksz_8895_reg.h
new file mode 100644
index 000000000000..b6490c42448e
--- /dev/null
+++ b/drivers/net/dsa/microchip/ksz_8895_reg.h
@@ -0,0 +1,769 @@
+/*
+ * Microchip KSZ9477 register definitions
+ *
+ * Copyright (C) 2017
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
+#ifndef __KSZ9477_REGS_H
+#define __KSZ9477_REGS_H
+
+#define KS_PRIO_M			0x3
+#define KS_PRIO_S			2
+
+/* 0 - Operation */
+#define REG_CHIP_ID0__1			0x0000
+
+#define REG_CHIP_ID1__1			0x0001
+
+#define SW_START 1
+
+#define FAMILY_ID			0x95
+#define FAMILY_ID_94			0x94
+#define FAMILY_ID_95			0x95
+#define FAMILY_ID_85			0x85
+#define FAMILY_ID_98			0x98
+#define FAMILY_ID_88			0x88
+
+#define TOTAL_SWITCH_COUNTER_NUM	1
+#define PORT_CTRL_ADDR(port, addr)	((addr) | (((port) + 1) << 4))
+
+#define ADDR_SHIFT			14
+#define ADDR_8				1
+#define ADDR_16				2
+#define ADDR_24				3
+#define ADDR_32				4
+
+#define BANK_SHIFT			12
+
+#define PHY_REG(addr, reg)		\
+	(((addr) << ADDR_SHIFT) | (reg))
+
+#define PHY_BANK_REG(addr, bank, reg)	\
+	(((addr) << ADDR_SHIFT) | ((bank) << BANK_SHIFT) | (reg))
+
+/* Use PHY access if no direct access. */
+#ifndef SW_R8
+#define SW_R8(s, r)	phy_read(s->phydev, PHY_REG(ADDR_8, r))
+#define SW_W8(s, r, v)	phy_write(s->phydev, PHY_REG(ADDR_8, r), v)
+#define SW_R16(s, r)	phy_read(s->phydev, PHY_REG(ADDR_16, r))
+#define SW_W16(s, r, v)	phy_write(s->phydev, PHY_REG(ADDR_16, r), v)
+#define SW_R32(s, r)	phy_read(s->phydev, PHY_REG(ADDR_32, r))
+#define SW_W32(s, r, v) \
+	do { \
+		phy_write(s->phydev, PHY_REG(ADDR_32, (r) + 2), (v) >> 16); \
+		phy_write(s->phydev, PHY_REG(ADDR_32, r), v); \
+	} while (0)
+#define SW_LOCK(s)				\
+	do {					\
+		mutex_lock(s->hwlock);		\
+	} while (0)
+#define SW_UNLOCK(s)				\
+	do {					\
+		mutex_unlock(s->hwlock);	\
+	} while (0)
+#endif
+
+
+#define KS_PORT_M			0x1F
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
+
+#define CHIP_ID_95			0x40
+#define CHIP_ID_95R			0x60
+
+#define REG_SW_CTRL_0			0x02
+
+#define SW_NEW_BACKOFF			(1 << 7)
+#define SW_FLUSH_DYN_MAC_TABLE		(1 << 5)
+#define SW_FLUSH_STA_MAC_TABLE		(1 << 4)
+#define SW_UNH_MODE			(1 << 1)
+#define SW_LINK_AUTO_AGING		(1 << 0)
+
+#define REG_SW_CTRL_1			0x03
+
+#define SW_PASS_ALL			(1 << 7)
+#define SW_2K_PACKET			(1 << 6)
+#define SW_TX_FLOW_CTRL_DISABLE		(1 << 5)
+#define SW_RX_FLOW_CTRL_DISABLE		(1 << 4)
+#define SW_CHECK_LENGTH			(1 << 3)
+#define SW_AGING_ENABLE			(1 << 2)
+#define SW_FAST_AGING			(1 << 1)
+#define SW_AGGR_BACKOFF			(1 << 0)
+
+#define REG_SW_CTRL_2			0x04
+
+#define UNICAST_VLAN_BOUNDARY		(1 << 7)
+#define MULTICAST_STORM_DISABLE		(1 << 6)
+#define SW_BACK_PRESSURE		(1 << 5)
+#define FAIR_FLOW_CTRL			(1 << 4)
+#define NO_EXC_COLLISION_DROP		(1 << 3)
+#define SW_HUGE_PACKET			(1 << 2)
+#define SW_LEGAL_PACKET			(1 << 1)
+
+#define REG_SW_CTRL_3			0x05
+#define SW_VLAN_ENABLE			(1 << 7)
+#define SW_IGMP_SNOOP			(1 << 6)
+#define SW_DIRECT			(1 << 5)
+#define SW_PRE_TAG			(1 << 4)
+#define SW_VLAN_TAG			(1 << 1)
+#define SW_MIRROR_RX_TX			(1 << 0)
+
+#define REG_SW_CTRL_4			0x06
+
+#define SW_HALF_DUPLEX_FLOW_CTRL	(1 << 7)
+#define SW_HALF_DUPLEX			(1 << 6)
+#define SW_FLOW_CTRL			(1 << 5)
+#define SW_10_MBIT			(1 << 4)
+#define SW_REPLACE_VID			(1 << 3)
+#define BROADCAST_STORM_RATE_HI		0x07
+
+#define REG_SW_CTRL_5			0x07
+
+#define BROADCAST_STORM_RATE_LO		0xFF
+#define BROADCAST_STORM_RATE		0x07FF
+
+#define REG_SW_CTRL_9			0x0B
+
+#define SW_DATA_SAMPLING_NEG		(1 << 6)
+#define SW_PHY_POWER_SAVE_DISABLE	(1 << 3)
+#define SW_LED_MODE_1			(1 << 1)
+#define SW_SPI_SAMPLING_RISING		(1 << 0)
+
+#define REG_SW_CTRL_10			0x0C
+
+#define SPI_CLK_125_MHZ			0x20
+#define SPI_CLK_83_33_MHZ		0x10
+#define SPI_CLK_41_67_MHZ		0x00
+#define SW_TAIL_TAG_ENABLE		(1 << 1)
+#define SW_PASS_PAUSE			(1 << 0)
+
+#define REG_SW_CTRL_11			0x0D
+
+#define REG_POWER_MANAGEMENT_1		0x0E
+
+#define SW_PLL_POWER_DOWN		(1 << 5)
+#define SW_POWER_MANAGEMENT_MODE_M	0x3
+#define SW_POWER_MANAGEMENT_MODE_S	3
+#define SW_POWER_NORMAL			0
+#define SW_ENERGY_DETECTION		1
+#define SW_SOFTWARE_POWER_DOWN		2
+#define SW_POWER_SAVING			3
+
+#define REG_POWER_MANAGEMENT_2		0x0F
+
+
+#define REG_PORT_1_CTRL_0		0x10
+#define REG_PORT_2_CTRL_0		0x20
+#define REG_PORT_3_CTRL_0		0x30
+#define REG_PORT_4_CTRL_0		0x40
+#define REG_PORT_5_CTRL_0		0x50
+
+#define PORT_BROADCAST_STORM		(1 << 7)
+#define PORT_DIFFSERV_ENABLE		(1 << 6)
+#define PORT_802_1P_ENABLE		(1 << 5)
+#define PORT_BASED_PRIO_S		3
+#define PORT_BASED_PRIO_M		(KS_PRIO_M << PORT_BASED_PRIO_S)
+#define PORT_PORT_PRIO_0		0
+#define PORT_PORT_PRIO_1		1
+#define PORT_PORT_PRIO_2		2
+#define PORT_PORT_PRIO_3		3
+#define PORT_INSERT_TAG			(1 << 2)
+#define PORT_REMOVE_TAG			(1 << 1)
+#define PORT_QUEUE_SPLIT_L		(1 << 0)
+
+#define REG_PORT_1_CTRL_1		0x11
+#define REG_PORT_2_CTRL_1		0x21
+#define REG_PORT_3_CTRL_1		0x31
+#define REG_PORT_4_CTRL_1		0x41
+#define REG_PORT_5_CTRL_1		0x51
+
+#define PORT_MIRROR_SNIFFER		(1 << 7)
+#define PORT_MIRROR_RX			(1 << 6)
+#define PORT_MIRROR_TX			(1 << 5)
+#define PORT_VLAN_MEMBERSHIP		KS_PORT_M
+
+#define REG_PORT_1_CTRL_2		0x12
+#define REG_PORT_2_CTRL_2		0x22
+#define REG_PORT_3_CTRL_2		0x32
+#define REG_PORT_4_CTRL_2		0x42
+#define REG_PORT_5_CTRL_2		0x52
+
+#define PORT_802_1P_REMAPPING		(1 << 7)
+#define PORT_INGRESS_FILTER		(1 << 6)
+#define PORT_DISCARD_NON_VID		(1 << 5)
+#define PORT_FORCE_FLOW_CTRL		(1 << 4)
+#define PORT_BACK_PRESSURE		(1 << 3)
+#define PORT_TX_ENABLE			(1 << 2)
+#define PORT_RX_ENABLE			(1 << 1)
+#define PORT_LEARN_DISABLE		(1 << 0)
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
+#define PORT_HP_MDIX			(1 << 7)
+#define PORT_REVERSED_POLARITY		(1 << 5)
+#define PORT_TX_FLOW_CTRL		(1 << 4)
+#define PORT_RX_FLOW_CTRL		(1 << 3)
+#define PORT_STAT_SPEED_100MBIT		(1 << 2)
+#define PORT_STAT_FULL_DUPLEX		(1 << 1)
+
+#define REG_PORT_1_LINK_MD_CTRL		0x1A
+#define REG_PORT_2_LINK_MD_CTRL		0x2A
+#define REG_PORT_3_LINK_MD_CTRL		0x3A
+#define REG_PORT_4_LINK_MD_CTRL		0x4A
+#define REG_PORT_5_LINK_MD_CTRL		0x5A
+
+#define PORT_CABLE_10M_SHORT		(1 << 7)
+#define PORT_CABLE_DIAG_RESULT_M	0x3
+#define PORT_CABLE_DIAG_RESULT_S	5
+#define PORT_CABLE_STAT_NORMAL		0
+#define PORT_CABLE_STAT_OPEN		1
+#define PORT_CABLE_STAT_SHORT		2
+#define PORT_CABLE_STAT_FAILED		3
+#define PORT_START_CABLE_DIAG		(1 << 4)
+#define PORT_FORCE_LINK			(1 << 3)
+#define PORT_POWER_SAVING		(1 << 2)
+#define PORT_PHY_REMOTE_LOOPBACK	(1 << 1)
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
+#define PORT_AUTO_NEG_DISABLE		(1 << 7)
+#define PORT_FORCE_100_MBIT		(1 << 6)
+#define PORT_FORCE_FULL_DUPLEX		(1 << 5)
+#define PORT_AUTO_NEG_SYM_PAUSE		(1 << 4)
+#define PORT_AUTO_NEG_100BTX_FD		(1 << 3)
+#define PORT_AUTO_NEG_100BTX		(1 << 2)
+#define PORT_AUTO_NEG_10BT_FD		(1 << 1)
+#define PORT_AUTO_NEG_10BT		(1 << 0)
+
+#define REG_PORT_1_CTRL_6		0x1D
+#define REG_PORT_2_CTRL_6		0x2D
+#define REG_PORT_3_CTRL_6		0x3D
+#define REG_PORT_4_CTRL_6		0x4D
+#define REG_PORT_5_CTRL_6		0x5D
+
+#define PORT_LED_OFF			(1 << 7)
+#define PORT_TX_DISABLE			(1 << 6)
+#define PORT_AUTO_NEG_RESTART		(1 << 5)
+#define PORT_POWER_DOWN			(1 << 3)
+#define PORT_AUTO_MDIX_DISABLE		(1 << 2)
+#define PORT_FORCE_MDIX			(1 << 1)
+#define PORT_MAC_LOOPBACK		(1 << 0)
+
+#define REG_PORT_1_STATUS_1		0x1E
+#define REG_PORT_2_STATUS_1		0x2E
+#define REG_PORT_3_STATUS_1		0x3E
+#define REG_PORT_4_STATUS_1		0x4E
+#define REG_PORT_5_STATUS_1		0x5E
+
+#define PORT_MDIX_STATUS		(1 << 7)
+#define PORT_AUTO_NEG_COMPLETE		(1 << 6)
+#define PORT_STAT_LINK_GOOD		(1 << 5)
+#define PORT_REMOTE_SYM_PAUSE		(1 << 4)
+#define PORT_REMOTE_100BTX_FD		(1 << 3)
+#define PORT_REMOTE_100BTX		(1 << 2)
+#define PORT_REMOTE_10BT_FD		(1 << 1)
+#define PORT_REMOTE_10BT		(1 << 0)
+
+#define REG_PORT_1_STATUS_2		0x1F
+#define REG_PORT_2_STATUS_2		0x2F
+#define REG_PORT_3_STATUS_2		0x3F
+#define REG_PORT_4_STATUS_2		0x4F
+#define REG_PORT_5_STATUS_2		0x5F
+
+#define PORT_PHY_LOOPBACK		(1 << 7)
+#define PORT_PHY_ISOLATE		(1 << 5)
+#define PORT_PHY_SOFT_RESET		(1 << 4)
+#define PORT_PHY_FORCE_LINK		(1 << 3)
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
+#define REG_SW_MAC_ADDR_0		0x68
+#define REG_SW_MAC_ADDR_1		0x69
+#define REG_SW_MAC_ADDR_2		0x6A
+#define REG_SW_MAC_ADDR_3		0x6B
+#define REG_SW_MAC_ADDR_4		0x6C
+#define REG_SW_MAC_ADDR_5		0x6D
+
+#define REG_IND_CTRL_0			0x6E
+
+#define TABLE_READ			(1 << 4)
+#define TABLE_SELECT_S			2
+#define TABLE_STATIC_MAC		(0 << TABLE_SELECT_S)
+#define TABLE_VLAN			(1 << TABLE_SELECT_S)
+#define TABLE_DYNAMIC_MAC		(2 << TABLE_SELECT_S)
+#define TABLE_MIB			(3 << TABLE_SELECT_S)
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
+#define INT_PORT_5			(1 << 4)
+#define INT_PORT_4			(1 << 3)
+#define INT_PORT_3			(1 << 2)
+#define INT_PORT_2			(1 << 1)
+#define INT_PORT_1			(1 << 0)
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
+#define SW_SELF_ADDR_FILTER_ENABLE	(1 << 6)
+
+#define REG_SW_UNK_UCAST_CTRL		0x83
+#define REG_SW_UNK_MCAST_CTRL		0x84
+#define REG_SW_UNK_VID_CTRL		0x85
+#define REG_SW_UNK_IP_MCAST_CTRL	0x86
+
+#define SW_UNK_FWD_ENABLE		(1 << 5)
+#define SW_UNK_FWD_MAP			KS_PORT_M
+
+#define REG_SW_CTRL_19			0x87
+
+#define SW_IN_RATE_LIMIT_PERIOD_M	0x3
+#define SW_IN_RATE_LIMIT_PERIOD_S	4
+#define SW_IN_RATE_LIMIT_16_MS		0
+#define SW_IN_RATE_LIMIT_64_MS		1
+#define SW_IN_RATE_LIMIT_256_MS		2
+#define SW_QUEUE_BASED_OUT_RATE_LIMIT	(1 << 3)
+#define SW_INS_TAG_ENABLE		(1 << 2)
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
+
+#define REG_PORT_1_CTRL_8		0xB0
+#define REG_PORT_2_CTRL_8		0xC0
+#define REG_PORT_3_CTRL_8		0xD0
+#define REG_PORT_4_CTRL_8		0xE0
+#define REG_PORT_5_CTRL_8		0xF0
+
+#define PORT_INS_TAG_FOR_PORT_5_S	3
+#define PORT_INS_TAG_FOR_PORT_5		(1 << 3)
+#define PORT_INS_TAG_FOR_PORT_4		(1 << 2)
+#define PORT_INS_TAG_FOR_PORT_3		(1 << 1)
+#define PORT_INS_TAG_FOR_PORT_2		(1 << 0)
+
+#define REG_PORT_1_CTRL_9		0xB1
+#define REG_PORT_2_CTRL_9		0xC1
+#define REG_PORT_3_CTRL_9		0xD1
+#define REG_PORT_4_CTRL_9		0xE1
+#define REG_PORT_5_CTRL_9		0xF1
+
+#define PORT_QUEUE_SPLIT_H		(1 << 1)
+#define PORT_QUEUE_SPLIT_1		0
+#define PORT_QUEUE_SPLIT_2		1
+#define PORT_QUEUE_SPLIT_4		2
+#define PORT_DROP_TAG			(1 << 0)
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
+#define RATE_CTRL_ENABLE		(1 << 7)
+#define RATE_RATIO_M			((1 << 7) - 1)
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
+#define PORT_IN_FLOW_CTRL		(1 << PORT_IN_FLOW_CTRL_S)
+#define PORT_IN_ALL			0
+#define PORT_IN_UNICAST			1
+#define PORT_IN_MULTICAST		2
+#define PORT_IN_BROADCAST		3
+#define PORT_COUNT_IFG			(1 << PORT_COUNT_IFG_S)
+#define PORT_COUNT_PREAMBLE		(1 << PORT_COUNT_PREAMBLE_S)
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
+#define PORT_RATE_LIMIT_M		((1 << 7) - 1)
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
+
+#define REG_SW_CFG			0xEF
+
+#define SW_PORT_3_FIBER			(1 << 7)
+
+/* KSZ8864 */
+
+#define REG_PHY_PORT_CTRL_1		0xCF
+
+#define PORT_HALF_DUPLEX		(1 << 7)
+#define PORT_FLOW_CTRL			(1 << 6)
+#define PORT_10_MBIT			(1 << 5)
+
+#define REG_PHY_PORT_CTRL_2		0xDF
+
+#define PORT_MII_MAC_MODE		(1 << 6)
+
+#define REG_KSZ8864_CHIP_ID		0xFE
+
+#define SW_KSZ8864			(1 << 7)
+
+
+#ifndef PHY_REG_CTRL
+#define PHY_REG_CTRL			0
+
+#define PHY_RESET			(1 << 15)
+#define PHY_LOOPBACK			(1 << 14)
+#define PHY_SPEED_100MBIT		(1 << 13)
+#define PHY_AUTO_NEG_ENABLE		(1 << 12)
+#define PHY_POWER_DOWN			(1 << 11)
+#define PHY_MII_DISABLE			(1 << 10)
+#define PHY_AUTO_NEG_RESTART		(1 << 9)
+#define PHY_FULL_DUPLEX			(1 << 8)
+#define PHY_COLLISION_TEST_NOT		(1 << 7)
+#define PHY_HP_MDIX			(1 << 5)
+#define PHY_FORCE_MDIX			(1 << 4)
+#define PHY_AUTO_MDIX_DISABLE		(1 << 3)
+#define PHY_REMOTE_FAULT_DISABLE	(1 << 2)
+#define PHY_TRANSMIT_DISABLE		(1 << 1)
+#define PHY_LED_DISABLE			(1 << 0)
+
+#define PHY_REG_STATUS			1
+
+#define PHY_100BT4_CAPABLE		(1 << 15)
+#define PHY_100BTX_FD_CAPABLE		(1 << 14)
+#define PHY_100BTX_CAPABLE		(1 << 13)
+#define PHY_10BT_FD_CAPABLE		(1 << 12)
+#define PHY_10BT_CAPABLE		(1 << 11)
+#define PHY_MII_SUPPRESS_CAPABLE_NOT	(1 << 6)
+#define PHY_AUTO_NEG_ACKNOWLEDGE	(1 << 5)
+#define PHY_REMOTE_FAULT		(1 << 4)
+#define PHY_AUTO_NEG_CAPABLE		(1 << 3)
+#define PHY_LINK_STATUS			(1 << 2)
+#define PHY_JABBER_DETECT_NOT		(1 << 1)
+#define PHY_EXTENDED_CAPABILITY		(1 << 0)
+
+#define PHY_REG_ID_1			2
+#define PHY_REG_ID_2			3
+
+#define KSZ8895_ID_HI			0x0022
+#define KSZ8895_ID_LO			0x1450
+
+#define PHY_REG_AUTO_NEGOTIATION	4
+
+#define PHY_AUTO_NEG_NEXT_PAGE_NOT	(1 << 15)
+#define PHY_AUTO_NEG_REMOTE_FAULT_NOT	(1 << 13)
+#define PHY_AUTO_NEG_SYM_PAUSE		(1 << 10)
+#define PHY_AUTO_NEG_100BT4		(1 << 9)
+#define PHY_AUTO_NEG_100BTX_FD		(1 << 8)
+#define PHY_AUTO_NEG_100BTX		(1 << 7)
+#define PHY_AUTO_NEG_10BT_FD		(1 << 6)
+#define PHY_AUTO_NEG_10BT		(1 << 5)
+#define PHY_AUTO_NEG_SELECTOR		0x001F
+#define PHY_AUTO_NEG_802_3		0x0001
+
+#define PHY_REG_REMOTE_CAPABILITY	5
+
+#define PHY_REMOTE_NEXT_PAGE_NOT	(1 << 15)
+#define PHY_REMOTE_ACKNOWLEDGE_NOT	(1 << 14)
+#define PHY_REMOTE_REMOTE_FAULT_NOT	(1 << 13)
+#define PHY_REMOTE_SYM_PAUSE		(1 << 10)
+#define PHY_REMOTE_100BTX_FD		(1 << 8)
+#define PHY_REMOTE_100BTX		(1 << 7)
+#define PHY_REMOTE_10BT_FD		(1 << 6)
+#define PHY_REMOTE_10BT			(1 << 5)
+
+#define PHY_REG_LINK_MD			0x1D
+
+#define PHY_START_CABLE_DIAG		(1 << 15)
+#define PHY_CABLE_DIAG_RESULT		0x6000
+#define PHY_CABLE_STAT_NORMAL		0x0000
+#define PHY_CABLE_STAT_OPEN		0x2000
+#define PHY_CABLE_STAT_SHORT		0x4000
+#define PHY_CABLE_STAT_FAILED		0x6000
+#define PHY_CABLE_10M_SHORT		(1 << 12)
+#define PHY_CABLE_FAULT_COUNTER		0x01FF
+
+#define PHY_REG_PHY_CTRL		0x1F
+
+#define PHY_MODE_M			0x7
+#define PHY_MODE_S			8
+#define PHY_STAT_REVERSED_POLARITY	(1 << 5)
+#define PHY_STAT_MDIX			(1 << 4)
+#define PHY_FORCE_LINK			(1 << 3)
+#define PHY_POWER_SAVING_ENABLE		(1 << 2)
+#define PHY_REMOTE_LOOPBACK		(1 << 1)
+#endif
+
+
+/* Default values are used in ksz_sw.h if these are not defined. */
+#define PRIO_QUEUES			4
+
+#define KS_PRIO_IN_REG			4
+
+#define SWITCH_PORT_NUM			4
+
+#define SW_D				u8
+#define SW_R(sw, addr)			(sw)->reg->r8(sw, addr)
+#define SW_W(sw, addr, val)		(sw)->reg->w8(sw, addr, val)
+#define SW_SIZE				(1)
+#define SW_SIZE_STR			"%02x"
+
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
+#define TAIL_TAG_OVERRIDE		(1 << 6)
+#define TAIL_TAG_LOOKUP			(1 << 7)
+
+#endif /* KSZ9477_REGS_H */
diff --git a/drivers/net/dsa/microchip/ksz_8895_spi.c b/drivers/net/dsa/mic=
rochip/ksz_8895_spi.c
new file mode 100644
index 000000000000..b1c9571c8e99
--- /dev/null
+++ b/drivers/net/dsa/microchip/ksz_8895_spi.c
@@ -0,0 +1,275 @@
+/*
+ * Microchip KSZ series register access through SPI
+ *
+ * Copyright (C) 2017 Woojung Huh <Woojung.Huh@microchip.com>
+ * Copyright (C) 2017 Pavel Machek <pavel@denx.de>
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
+#include <asm/unaligned.h>
+
+#include <linux/delay.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/spi/spi.h>
+
+#include "ksz_8895_reg.h"
+#include "ksz_priv.h"
+
+/* SPI frame opcodes */
+#define KS_SPIOP_RD			3
+#define KS_SPIOP_WR			2
+
+static int ksz_spi_read_reg(struct spi_device *spi, u32 reg, u8 *val,
+			    unsigned int len)
+{
+	int ret;
+
+	u8 buf[2];
+
+	buf[0] =3D KS_SPIOP_RD;
+	buf[1] =3D reg;
+
+	ret =3D spi_write_then_read(spi, buf, 2, val, len);
+	return ret;
+}
+
+static int ksz_spi_read(struct ksz_device *dev, u32 reg, u8 *data,
+			unsigned int len)
+{
+	struct spi_device *spi =3D dev->priv;
+
+	return ksz_spi_read_reg(spi, reg, data, len);
+}
+
+static int ksz_spi_read8(struct ksz_device *dev, u32 reg, u8 *val)
+{
+	return ksz_spi_read(dev, reg, val, 1);
+}
+
+static int ksz_spi_read16(struct ksz_device *dev, u32 reg, u16 *val)
+{
+	int ret =3D ksz_spi_read(dev, reg, (u8 *)val, 2);
+
+	if (!ret)
+		*val =3D be16_to_cpu(*val);
+
+	return ret;
+}
+
+static int ksz_spi_read24(struct ksz_device *dev, u32 reg, u32 *val)
+{
+	int ret;
+
+	*val =3D 0;
+	ret =3D ksz_spi_read(dev, reg, (u8 *)val, 3);
+	if (!ret) {
+		*val =3D be32_to_cpu(*val);
+		/* convert to 24bit */
+		*val >>=3D 8;
+	}
+
+	return ret;
+}
+
+static int ksz_spi_read32(struct ksz_device *dev, u32 reg, u32 *val)
+{
+	int ret =3D ksz_spi_read(dev, reg, (u8 *)val, 4);
+
+	if (!ret)
+		*val =3D be32_to_cpu(*val);
+
+	return ret;
+}
+
+static int ksz_spi_write_reg(struct spi_device *spi, u32 reg, u8 *val,
+			     unsigned int len)
+{
+	u8 data[12];
+
+	int i;
+=09
+	data[0] =3D KS_SPIOP_WR;
+	data[1] =3D reg;
+	for (i =3D 0; i < len; i++)
+		data[i + 2] =3D val[i];
+
+	return spi_write(spi, &data, 2 + len);
+}
+
+static int ksz_spi_write8(struct ksz_device *dev, u32 reg, u8 value)
+{
+	struct spi_device *spi =3D dev->priv;
+
+	return ksz_spi_write_reg(spi, reg, &value, 1);
+}
+
+static int ksz_spi_write16(struct ksz_device *dev, u32 reg, u16 value)
+{
+	struct spi_device *spi =3D dev->priv;
+
+	value =3D cpu_to_be16(value);
+	return ksz_spi_write_reg(spi, reg, (u8 *)&value, 2);
+}
+
+static int ksz_spi_write24(struct ksz_device *dev, u32 reg, u32 value)
+{
+	struct spi_device *spi =3D dev->priv;
+
+	/* make it to big endian 24bit from MSB */
+	value <<=3D 8;
+	value =3D cpu_to_be32(value);
+	return ksz_spi_write_reg(spi, reg, (u8 *)&value, 3);
+}
+
+static int ksz_spi_write32(struct ksz_device *dev, u32 reg, u32 value)
+{
+	struct spi_device *spi =3D dev->priv;
+
+	value =3D cpu_to_be32(value);
+	return ksz_spi_write_reg(spi, reg, (u8 *)&value, 4);
+}
+
+static const struct ksz_io_ops ksz_spi_ops =3D {
+	.read8 =3D ksz_spi_read8,
+	.read16 =3D ksz_spi_read16,
+	.read24 =3D ksz_spi_read24,
+	.read32 =3D ksz_spi_read32,
+	.write8 =3D ksz_spi_write8,
+	.write16 =3D ksz_spi_write16,
+	.write24 =3D ksz_spi_write24,
+	.write32 =3D ksz_spi_write32,
+};
+
+static int ksz_spi_sysfs_read(struct ksz_device *dev, char *buf,
+		 unsigned offset, size_t count)
+{
+	int err =3D 0;
+	int i;
+
+	for (i =3D 0; i < count; i++) {
+		ksz_read8(dev, i+offset, buf+i+offset);
+	}
+
+	return err ? err : count;
+}
+
+static int ksz_spi_sysfs_write(struct ksz_device *dev, char *buf,
+		 unsigned offset, size_t count)
+{
+	int err =3D -EINVAL;
+
+	return err ? err : count;
+}
+
+static ssize_t ksz_spi_registers_read(struct file *filp, struct kobject *k=
obj,
+	struct bin_attribute *bin_attr, char *buf, loff_t off, size_t count)
+{
+	struct device *dev;
+	struct ksz_device *ks;
+
+	dev =3D container_of(kobj, struct device, kobj);
+	ks =3D dev_get_drvdata(dev);
+
+	return ksz_spi_sysfs_read(ks, buf, off, count);
+}
+
+static ssize_t ksz_spi_registers_write(struct file *filp, struct kobject *=
kobj,
+	struct bin_attribute *bin_attr, char *buf, loff_t off, size_t count)
+{
+	struct device *dev;
+	struct ksz_device *ks;
+
+	dev =3D container_of(kobj, struct device, kobj);
+	ks =3D dev_get_drvdata(dev);
+
+	return ksz_spi_sysfs_write(ks, buf, off, count);
+}
+
+static const struct bin_attribute ksz_spi_registers_attr =3D {
+	.attr =3D {
+		.name   =3D "registers",
+		.mode   =3D S_IRUSR | S_IWUSR,
+	},
+	.size   =3D 0x100,
+	.read   =3D ksz_spi_registers_read,
+	.write  =3D ksz_spi_registers_write,
+};
+
+static int ksz_spi_probe(struct spi_device *spi)
+{
+	struct ksz_device *dev;
+	int ret;
+
+	dev =3D ksz_switch_alloc(&spi->dev, &ksz_spi_ops, spi);
+	if (!dev)
+		return -ENOMEM;
+
+	if (spi->dev.platform_data)
+		dev->pdata =3D spi->dev.platform_data;
+
+	ret =3D ksz_switch_register(dev);
+	if (ret)
+		return ret;
+
+	memcpy(&dev->regs_attr, &ksz_spi_registers_attr, sizeof(dev->regs_attr));
+        dev->regs_attr.size =3D 0x100;
+
+        sysfs_attr_init(&dev->regs_attr.attr);
+        ret =3D sysfs_create_bin_file(&spi->dev.kobj, &dev->regs_attr);
+
+        if (ret) {
+                dev_err(&spi->dev, "unable to create sysfs file, err=3D%d\=
n",
+                                    ret);
+                return ret;
+        }
+=09
+	spi_set_drvdata(spi, dev);
+
+	return 0;
+}
+
+static int ksz_spi_remove(struct spi_device *spi)
+{
+	struct ksz_device *dev =3D spi_get_drvdata(spi);
+
+	if (dev)
+		ksz_switch_remove(dev);
+
+	sysfs_remove_bin_file(&spi->dev.kobj, &dev->regs_attr);
+=09
+	return 0;
+}
+
+static const struct of_device_id ksz_dt_ids[] =3D {
+	{ .compatible =3D "microchip,ksz8895" },=09
+	{},
+};
+MODULE_DEVICE_TABLE(of, ksz_dt_ids);
+
+static struct spi_driver ksz_spi_driver =3D {
+	.driver =3D {
+		.name	=3D "ksz8895-switch",
+		.owner	=3D THIS_MODULE,
+		.of_match_table =3D of_match_ptr(ksz_dt_ids),
+	},
+	.probe	=3D ksz_spi_probe,
+	.remove	=3D ksz_spi_remove,
+};
+
+module_spi_driver(ksz_spi_driver);
+
+MODULE_AUTHOR("Pavel Machek <pavel@denx.de>");
+MODULE_DESCRIPTION("Microchip KSZ Series Switch SPI access Driver");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/dsa/microchip/ksz_9477_reg.h b/drivers/net/dsa/mic=
rochip/ksz_9477_reg.h
index 6aa6752035a1..af4d29c2ba4f 100644
--- a/drivers/net/dsa/microchip/ksz_9477_reg.h
+++ b/drivers/net/dsa/microchip/ksz_9477_reg.h
@@ -16,6 +16,7 @@
  * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
=20
+#error This is not switch we have
 #ifndef __KSZ9477_REGS_H
 #define __KSZ9477_REGS_H
=20
diff --git a/drivers/net/dsa/microchip/ksz_common.c b/drivers/net/dsa/micro=
chip/ksz_common.c
index b313ecdf2919..6741d05d0ac4 100644
--- a/drivers/net/dsa/microchip/ksz_common.c
+++ b/drivers/net/dsa/microchip/ksz_common.c
@@ -28,6 +28,7 @@
 #include <net/dsa.h>
 #include <net/switchdev.h>
=20
+#include "ksz_9477_reg.h"
 #include "ksz_priv.h"
=20
 static const struct {
diff --git a/drivers/net/dsa/microchip/ksz_mdio_emulation.c b/drivers/net/d=
sa/microchip/ksz_mdio_emulation.c
new file mode 100644
index 000000000000..a4e24506bed8
--- /dev/null
+++ b/drivers/net/dsa/microchip/ksz_mdio_emulation.c
@@ -0,0 +1,286 @@
+/**
+ * Micrel KSZ8895 SPI driver
+ *
+ * Copyright (c) 2015 Micrel, Inc.
+ *
+ * GPLv2
+ */
+
+#define PHY_ID_KSZ8895		((KSZ8895_ID_HI << 16) | KSZ8895_ID_LO)
+
+/**
+ * sw_r_phy - read data from PHY register
+ * @sw:		The switch instance.
+ * @phy:	PHY address to read.
+ * @reg:	PHY register to read.
+ * @val:	Buffer to store the read data.
+ *
+ * This routine reads data from the PHY register.
+ */
+static void sw_r_phy(struct ksz_device *sw, u16 phy, u16 reg, u16 *val)
+{
+	u8 ctrl;
+	u8 restart;
+	u8 link;
+	u8 speed;
+	u8 force;
+	u8 p =3D phy;
+	u16 data =3D 0;
+
+	switch (reg) {
+	case PHY_REG_CTRL:
+		ksz_pread8(sw, p, P_LOCAL_CTRL, &ctrl);
+		ksz_pread8(sw, p, P_NEG_RESTART_CTRL, &restart);
+		ksz_pread8(sw, p, P_SPEED_STATUS, &speed);
+		ksz_pread8(sw, p, P_FORCE_CTRL, &force);
+		if (restart & PORT_PHY_LOOPBACK)
+			data |=3D PHY_LOOPBACK;
+		if (force & PORT_FORCE_100_MBIT)
+			data |=3D PHY_SPEED_100MBIT;
+		if (!(force & PORT_AUTO_NEG_DISABLE))
+			data |=3D PHY_AUTO_NEG_ENABLE;
+		if (restart & PORT_POWER_DOWN)
+			data |=3D PHY_POWER_DOWN;
+		if (restart & PORT_AUTO_NEG_RESTART)
+			data |=3D PHY_AUTO_NEG_RESTART;
+		if (force & PORT_FORCE_FULL_DUPLEX)
+			data |=3D PHY_FULL_DUPLEX;
+		if (speed & PORT_HP_MDIX)
+			data |=3D PHY_HP_MDIX;
+		if (restart & PORT_FORCE_MDIX)
+			data |=3D PHY_FORCE_MDIX;
+		if (restart & PORT_AUTO_MDIX_DISABLE)
+			data |=3D PHY_AUTO_MDIX_DISABLE;
+		if (restart & PORT_TX_DISABLE)
+			data |=3D PHY_TRANSMIT_DISABLE;
+		if (restart & PORT_LED_OFF)
+			data |=3D PHY_LED_DISABLE;
+		break;
+	case PHY_REG_STATUS:
+		ksz_pread8(sw, p, P_LINK_STATUS, &link);
+		ksz_pread8(sw, p, P_SPEED_STATUS, &speed);
+		data =3D PHY_100BTX_FD_CAPABLE |
+			PHY_100BTX_CAPABLE |
+			PHY_10BT_FD_CAPABLE |
+			PHY_10BT_CAPABLE |
+			PHY_AUTO_NEG_CAPABLE;
+		if (link & PORT_AUTO_NEG_COMPLETE)
+			data |=3D PHY_AUTO_NEG_ACKNOWLEDGE;
+		if (link & PORT_STAT_LINK_GOOD)
+			data |=3D PHY_LINK_STATUS;
+		break;
+	case PHY_REG_ID_1:
+		data =3D KSZ8895_ID_HI;
+		break;
+	case PHY_REG_ID_2:
+		data =3D KSZ8895_ID_LO;
+		break;
+	case PHY_REG_AUTO_NEGOTIATION:
+		ksz_pread8(sw, p, P_LOCAL_CTRL, &ctrl);
+		data =3D PHY_AUTO_NEG_802_3;
+		if (ctrl & PORT_AUTO_NEG_SYM_PAUSE)
+			data |=3D PHY_AUTO_NEG_SYM_PAUSE;
+		if (ctrl & PORT_AUTO_NEG_100BTX_FD)
+			data |=3D PHY_AUTO_NEG_100BTX_FD;
+		if (ctrl & PORT_AUTO_NEG_100BTX)
+			data |=3D PHY_AUTO_NEG_100BTX;
+		if (ctrl & PORT_AUTO_NEG_10BT_FD)
+			data |=3D PHY_AUTO_NEG_10BT_FD;
+		if (ctrl & PORT_AUTO_NEG_10BT)
+			data |=3D PHY_AUTO_NEG_10BT;
+		break;
+	case PHY_REG_REMOTE_CAPABILITY:
+		ksz_pread8(sw, p, P_REMOTE_STATUS, &link);
+		data =3D PHY_AUTO_NEG_802_3;
+		if (link & PORT_REMOTE_SYM_PAUSE)
+			data |=3D PHY_AUTO_NEG_SYM_PAUSE;
+		if (link & PORT_REMOTE_100BTX_FD)
+			data |=3D PHY_AUTO_NEG_100BTX_FD;
+		if (link & PORT_REMOTE_100BTX)
+			data |=3D PHY_AUTO_NEG_100BTX;
+		if (link & PORT_REMOTE_10BT_FD)
+			data |=3D PHY_AUTO_NEG_10BT_FD;
+		if (link & PORT_REMOTE_10BT)
+			data |=3D PHY_AUTO_NEG_10BT;
+		break;
+	default:
+		break;
+	}
+	*val =3D data;
+}  /* sw_r_phy */
+
+/**
+ * sw_w_phy - write data to PHY register
+ * @hw:		The switch instance.
+ * @phy:	PHY address to write.
+ * @reg:	PHY register to write.
+ * @val:	Word data to write.
+ *
+ * This routine writes data to the PHY register.
+ */
+static void sw_w_phy(struct ksz_device *sw, u16 phy, u16 reg, u16 val)
+{
+	u8 ctrl;
+	u8 restart;
+	u8 speed;
+	u8 data;
+	u8 p =3D phy;
+
+	switch (reg) {
+	case PHY_REG_CTRL:
+		ksz_pread8(sw, p, P_SPEED_STATUS, &speed);
+		data =3D speed;
+		if (val & PHY_HP_MDIX)
+			data |=3D PORT_HP_MDIX;
+		else
+			data &=3D ~PORT_HP_MDIX;
+		if (data !=3D speed)
+			ksz_pwrite8(sw, p, P_SPEED_STATUS, data);
+		ksz_pread8(sw, p, P_FORCE_CTRL, &ctrl);
+		data =3D ctrl;
+		if (!(val & PHY_AUTO_NEG_ENABLE))
+			data |=3D PORT_AUTO_NEG_DISABLE;
+		else
+			data &=3D ~PORT_AUTO_NEG_DISABLE;
+		if (val & PHY_SPEED_100MBIT)
+			data |=3D PORT_FORCE_100_MBIT;
+		else
+			data &=3D ~PORT_FORCE_100_MBIT;
+		if (val & PHY_FULL_DUPLEX)
+			data |=3D PORT_FORCE_FULL_DUPLEX;
+		else
+			data &=3D ~PORT_FORCE_FULL_DUPLEX;
+		if (data !=3D ctrl)
+			ksz_pwrite8(sw, p, P_FORCE_CTRL, data);
+		ksz_pread8(sw, p, P_NEG_RESTART_CTRL, &restart);
+		data =3D restart;
+		if (val & PHY_LED_DISABLE)
+			data |=3D PORT_LED_OFF;
+		else
+			data &=3D ~PORT_LED_OFF;
+		if (val & PHY_TRANSMIT_DISABLE)
+			data |=3D PORT_TX_DISABLE;
+		else
+			data &=3D ~PORT_TX_DISABLE;
+		if (val & PHY_AUTO_NEG_RESTART)
+			data |=3D PORT_AUTO_NEG_RESTART;
+		else
+			data &=3D ~(PORT_AUTO_NEG_RESTART);
+		if (val & PHY_POWER_DOWN)
+			data |=3D PORT_POWER_DOWN;
+		else
+			data &=3D ~PORT_POWER_DOWN;
+		if (val & PHY_AUTO_MDIX_DISABLE)
+			data |=3D PORT_AUTO_MDIX_DISABLE;
+		else
+			data &=3D ~PORT_AUTO_MDIX_DISABLE;
+		if (val & PHY_FORCE_MDIX)
+			data |=3D PORT_FORCE_MDIX;
+		else
+			data &=3D ~PORT_FORCE_MDIX;
+		if (val & PHY_LOOPBACK)
+			data |=3D PORT_PHY_LOOPBACK;
+		else
+			data &=3D ~PORT_PHY_LOOPBACK;
+		if (data !=3D restart)
+			ksz_pwrite8(sw, p, P_NEG_RESTART_CTRL, data);
+		break;
+	case PHY_REG_AUTO_NEGOTIATION:
+		ksz_pread8(sw, p, P_LOCAL_CTRL, &ctrl);
+		data =3D ctrl;
+		data &=3D ~(PORT_AUTO_NEG_SYM_PAUSE |
+			PORT_AUTO_NEG_100BTX_FD |
+			PORT_AUTO_NEG_100BTX |
+			PORT_AUTO_NEG_10BT_FD |
+			PORT_AUTO_NEG_10BT);
+		if (val & PHY_AUTO_NEG_SYM_PAUSE)
+			data |=3D PORT_AUTO_NEG_SYM_PAUSE;
+		if (val & PHY_AUTO_NEG_100BTX_FD)
+			data |=3D PORT_AUTO_NEG_100BTX_FD;
+		if (val & PHY_AUTO_NEG_100BTX)
+			data |=3D PORT_AUTO_NEG_100BTX;
+		if (val & PHY_AUTO_NEG_10BT_FD)
+			data |=3D PORT_AUTO_NEG_10BT_FD;
+		if (val & PHY_AUTO_NEG_10BT)
+			data |=3D PORT_AUTO_NEG_10BT;
+		if (data !=3D ctrl)
+			ksz_pwrite8(sw, p, P_LOCAL_CTRL, data);
+		break;
+	default:
+		break;
+	}
+}  /* sw_w_phy */
+
+static int ksz_mii_addr(int *reg, int *bank)
+{
+	int ret;
+
+	ret =3D (*reg & 0xC000) >> ADDR_SHIFT;
+	*bank =3D (*reg & 0x3000) >> BANK_SHIFT;
+	*reg &=3D 0x0FFF;
+	return ret;
+}
+
+static int ksz_phy_read16(struct dsa_switch *ds, int phy_id, int regnum)
+{
+	struct ksz_device *sw =3D ds->priv;
+	int addr;
+	int bank;
+	u16 data;
+	int ret =3D 0xffff;
+
+	if (phy_id > SWITCH_PORT_NUM + 1)
+		return 0xffff;
+
+	addr =3D ksz_mii_addr(&regnum, &bank);
+	BUG_ON(addr >=3D 6);
+
+	switch (addr) {
+	case ADDR_8:
+	case ADDR_16:
+	case ADDR_32:
+		BUG();
+
+	default:
+		if (regnum < 6) {
+			sw_r_phy(sw, phy_id, regnum, &data);
+			ret =3D data;
+		} else
+			ret =3D 0;
+	}
+
+	return ret;
+}  /* ksz_mii_read */
+
+static int ksz_phy_write16(struct dsa_switch *ds, int phy_id, int regnum, =
u16 val)
+{
+	struct ksz_device *sw =3D ds->priv;
+	int addr;
+	int bank;
+	int reg;
+
+	if (phy_id > SWITCH_PORT_NUM + 1)
+		return -EINVAL;
+
+	BUG_ON(regnum >=3D 6);
+	reg =3D regnum;
+	addr =3D ksz_mii_addr(&regnum, &bank);
+
+	switch (addr) {
+	case ADDR_8:
+	case ADDR_16:
+	case ADDR_32:
+		BUG();
+	default:
+		if (regnum < 6) {
+			/* PHY device driver resets or powers down the PHY. */
+			if (0 =3D=3D regnum &&
+			    (val & (PHY_RESET | PHY_POWER_DOWN)))
+				break;
+			sw_w_phy(sw, phy_id, regnum, val);
+		}
+		break;
+	}
+
+	return 0;
+}  /* ksz_mii_write */
diff --git a/drivers/net/dsa/microchip/ksz_priv.h b/drivers/net/dsa/microch=
ip/ksz_priv.h
index 2a98dbd51456..1c73cdb8bbca 100644
--- a/drivers/net/dsa/microchip/ksz_priv.h
+++ b/drivers/net/dsa/microchip/ksz_priv.h
@@ -25,8 +25,6 @@
 #include <linux/etherdevice.h>
 #include <net/dsa.h>
=20
-#include "ksz_9477_reg.h"
-
 struct ksz_io_ops;
=20
 struct vlan_table {
@@ -60,6 +58,8 @@ struct ksz_device {
 	struct vlan_table *vlan_cache;
=20
 	u64 mib_value[TOTAL_SWITCH_COUNTER_NUM];
+=09
+	struct bin_attribute regs_attr;
 };
=20
 struct ksz_io_ops {
@@ -174,6 +174,7 @@ static inline int ksz_write32(struct ksz_device *dev, u=
32 reg, u32 value)
 static inline void ksz_pread8(struct ksz_device *dev, int port, int offset,
 			      u8 *data)
 {
+	//printk("pread8 %d %d -> %d\n", port, offset, PORT_CTRL_ADDR(port, offse=
t));
 	ksz_read8(dev, PORT_CTRL_ADDR(port, offset), data);
 }
=20
diff --git a/drivers/net/dsa/microchip/ksz_spi.c b/drivers/net/dsa/microchi=
p/ksz_spi.c
index c51946983bed..22ee313052dc 100644
--- a/drivers/net/dsa/microchip/ksz_spi.c
+++ b/drivers/net/dsa/microchip/ksz_spi.c
@@ -23,6 +23,7 @@
 #include <linux/module.h>
 #include <linux/spi/spi.h>
=20
+#include "ksz_9477_reg.h"
 #include "ksz_priv.h"
=20
 /* SPI frame opcodes */
diff --git a/net/dsa/tag_ksz.c b/net/dsa/tag_ksz.c
index de66ca8e6201..6eb094d5bb02 100644
--- a/net/dsa/tag_ksz.c
+++ b/net/dsa/tag_ksz.c
@@ -29,7 +29,7 @@
  *	  (eg, 0x00=3Dport1, 0x02=3Dport3, 0x06=3Dport7)
  */
=20
-#define	KSZ_INGRESS_TAG_LEN	2
+#define	KSZ_INGRESS_TAG_LEN	1
 #define	KSZ_EGRESS_TAG_LEN	1
=20
 static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *de=
v)
@@ -69,8 +69,7 @@ static struct sk_buff *ksz_xmit(struct sk_buff *skb, stru=
ct net_device *dev)
 	}
=20
 	tag =3D skb_put(nskb, KSZ_INGRESS_TAG_LEN);
-	tag[0] =3D 0;
-	tag[1] =3D 1 << p->dp->index; /* destination port */
+	tag[0] =3D 1 << p->dp->index; /* destination port */
=20
 	return nskb;
 }

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--qMm9M+Fa2AknHoGS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmivOoACgkQMOfwapXb+vKkvQCfdW/VuZAehY+DE+C3Rff7d5OG
yPMAn1ZZ7wgICfYKYovAltzaW0F66nHX
=T10x
-----END PGP SIGNATURE-----

--qMm9M+Fa2AknHoGS--
