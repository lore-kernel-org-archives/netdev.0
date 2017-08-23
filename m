From: Pavel Machek <pavel@ucw.cz>
Subject: Re: DSA support for Micrel KSZ8895
Date: Wed, 23 Aug 2017 11:09:41 +0200
Message-ID: <20170823090941.GA27570@amd>
References: <20170816075524.GA18532@amd>
 <20170816140451.GA13006@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="Qxx1br4bt0+wmkIi"
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tristram.Ha@micrel.com, andrew@lunn.ch
To: Woojung.Huh@microchip.com, nathan.leigh.conrad@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:56763 "EHLO
        atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753681AbdHWJJo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 05:09:44 -0400
Content-Disposition: inline
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Qxx1br4bt0+wmkIi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> > Woojung is the expert here. His DSA driver for the 9477 is a nice
> > clean driver.
> >=20
> > Have you compared the 8895 to the 9477. Are they similar? Could the
> > existing 9477 be extended to support the 8895?
> >=20
> > 	 Andrew
>=20
> Hi Pavel,
>=20
> I'll forward your email to our support.
> AFAIK, KSZ8895 has different register mapping from KSZ9477,
> it will be more than ID changes in current driver.

More than ID changes, indeed. As layout is completely different, it
looks like different source file will be needed for support.

I'm not nearly there; but I can ifconfig lanX up, already, and perform
some pings.

Any ideas how to do the work in a way to minimize code duplication are
welcome...

Best regards,
								Pavel

diff --git a/drivers/net/dsa/microchip/ksz_8895_reg.h b/drivers/net/dsa/mic=
rochip/ksz_8895_reg.h
new file mode 100644
index 000000000000..dd3e0e738c68
--- /dev/null
+++ b/drivers/net/dsa/microchip/ksz_8895_reg.h
@@ -0,0 +1,41 @@
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
+#define FAMILY_ID			0x95
+#define FAMILY_ID_94			0x94
+#define FAMILY_ID_95			0x95
+#define FAMILY_ID_85			0x85
+#define FAMILY_ID_98			0x98
+#define FAMILY_ID_88			0x88
+
+#define TOTAL_SWITCH_COUNTER_NUM	0x24 /* FIXME */
+#define PORT_CTRL_ADDR(port, addr)	((addr) | (((port) + 1) << 4))
+
+
+#endif /* KSZ9477_REGS_H */
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
index b313ecdf2919..6117dbea92d5 100644
--- a/drivers/net/dsa/microchip/ksz_common.c
+++ b/drivers/net/dsa/microchip/ksz_common.c
@@ -2,6 +2,7 @@
  * Microchip switch driver main logic
  *
  * Copyright (C) 2017
+ * Copyright (C) 2017 Pavel Machek <pavel@denx.de>
  *
  * Permission to use, copy, modify, and/or distribute this software for any
  * purpose with or without fee is hereby granted, provided that the above
@@ -29,6 +30,7 @@
 #include <net/switchdev.h>
=20
 #include "ksz_priv.h"
+#include "ksz_sw_phy.h"
=20
 static const struct {
 	int index;
@@ -130,10 +132,14 @@ static void ksz_port_cfg32(struct ksz_device *dev, in=
t port, int offset,
 	ksz_write32(dev, addr, data);
 }
=20
+#define NOTIMPL() do { NOTIMPLV(); return -EJUKEBOX; } while (0)
+#define NOTIMPLV() do { printk("Not implemented -- %s\n",  __func__); } wh=
ile (0)
+
 static int wait_vlan_ctrl_ready(struct ksz_device *dev, u32 waiton, int ti=
meout)
 {
+#ifdef KSOLD
 	u8 data;
-
+=09
 	do {
 		ksz_read8(dev, REG_SW_VLAN_CTRL, &data);
 		if (!(data & waiton))
@@ -145,10 +151,14 @@ static int wait_vlan_ctrl_ready(struct ksz_device *de=
v, u32 waiton, int timeout)
 		return -ETIMEDOUT;
=20
 	return 0;
+#else
+	NOTIMPL();
+#endif=09
 }
=20
 static int get_vlan_table(struct dsa_switch *ds, u16 vid, u32 *vlan_table)
 {
+#ifdef KSOLD      =20
 	struct ksz_device *dev =3D ds->priv;
 	int ret;
=20
@@ -172,12 +182,15 @@ static int get_vlan_table(struct dsa_switch *ds, u16 =
vid, u32 *vlan_table)
=20
 exit:
 	mutex_unlock(&dev->vlan_mutex);
-
 	return ret;
+#else
+	NOTIMPL();
+#endif=09
 }
=20
 static int set_vlan_table(struct dsa_switch *ds, u16 vid, u32 *vlan_table)
 {
+#ifdef KSOLD
 	struct ksz_device *dev =3D ds->priv;
 	int ret;
=20
@@ -208,30 +221,42 @@ static int set_vlan_table(struct dsa_switch *ds, u16 =
vid, u32 *vlan_table)
 	mutex_unlock(&dev->vlan_mutex);
=20
 	return ret;
+#else
+	NOTIMPL();
+#endif=09
 }
=20
 static void read_table(struct dsa_switch *ds, u32 *table)
 {
+#ifdef KSOLD=09
 	struct ksz_device *dev =3D ds->priv;
=20
 	ksz_read32(dev, REG_SW_ALU_VAL_A, &table[0]);
 	ksz_read32(dev, REG_SW_ALU_VAL_B, &table[1]);
 	ksz_read32(dev, REG_SW_ALU_VAL_C, &table[2]);
 	ksz_read32(dev, REG_SW_ALU_VAL_D, &table[3]);
+#else
+	NOTIMPLV();
+#endif=09
 }
=20
 static void write_table(struct dsa_switch *ds, u32 *table)
 {
+#ifdef KSOLD	=09
 	struct ksz_device *dev =3D ds->priv;
=20
 	ksz_write32(dev, REG_SW_ALU_VAL_A, table[0]);
 	ksz_write32(dev, REG_SW_ALU_VAL_B, table[1]);
 	ksz_write32(dev, REG_SW_ALU_VAL_C, table[2]);
 	ksz_write32(dev, REG_SW_ALU_VAL_D, table[3]);
+#else
+	NOTIMPLV();
+#endif=09
 }
=20
 static int wait_alu_ready(struct ksz_device *dev, u32 waiton, int timeout)
 {
+#ifdef KSOLD=09
 	u32 data;
=20
 	do {
@@ -245,12 +270,15 @@ static int wait_alu_ready(struct ksz_device *dev, u32=
 waiton, int timeout)
 		return -ETIMEDOUT;
=20
 	return 0;
+#else
+	NOTIMPL();
+#endif=09
 }
=20
 static int wait_alu_sta_ready(struct ksz_device *dev, u32 waiton, int time=
out)
 {
+#ifdef KSOLD=09
 	u32 data;
-
 	do {
 		ksz_read32(dev, REG_SW_ALU_STAT_CTRL__4, &data);
 		if (!(data & waiton))
@@ -262,10 +290,14 @@ static int wait_alu_sta_ready(struct ksz_device *dev,=
 u32 waiton, int timeout)
 		return -ETIMEDOUT;
=20
 	return 0;
+#else
+	NOTIMPL();
+#endif=09
 }
=20
 static int ksz_reset_switch(struct dsa_switch *ds)
 {
+#ifdef KSOLD=09
 	struct ksz_device *dev =3D ds->priv;
 	u8 data8;
 	u16 data16;
@@ -295,22 +327,69 @@ static int ksz_reset_switch(struct dsa_switch *ds)
 	data16 &=3D ~BROADCAST_STORM_RATE;
 	data16 |=3D (BROADCAST_STORM_VALUE * BROADCAST_STORM_PROT_RATE) / 100;
 	ksz_write16(dev, REG_SW_MAC_CTRL_2, data16);
+#else
+	/* reset switch */
+	//ksz_cfg(dev, REG_SW_OPERATION, SW_RESET, true);
+
+	/* turn off SPI DO Edge select */
+	//ksz_read8(dev, REG_SW_GLOBAL_SERIAL_CTRL_0, &data8);
+	//data8 &=3D ~SPI_AUTO_EDGE_DETECTION;
+	//ksz_write8(dev, REG_SW_GLOBAL_SERIAL_CTRL_0, data8);
+
+	/* default configuration */
+	//ksz_read8(dev, REG_SW_LUE_CTRL_1, &data8);
+	//data8 =3D SW_AGING_ENABLE | SW_LINK_AUTO_AGING |
+//	      SW_SRC_ADDR_FILTER | SW_FLUSH_STP_TABLE | SW_FLUSH_MSTP_TABLE;
+	//ksz_write8(dev, REG_SW_LUE_CTRL_1, data8);
+
+	/* disable interrupts */
+	//ksz_write32(dev, REG_SW_INT_MASK__4, SWITCH_INT_MASK);
+	//ksz_write32(dev, REG_SW_PORT_INT_MASK__4, 0x7F);
+	//ksz_read32(dev, REG_SW_PORT_INT_STATUS__4, &data32);
+
+	/* set broadcast storm protection 10% rate */
+	//ksz_read16(dev, REG_SW_MAC_CTRL_2, &data16);
+	//data16 &=3D ~BROADCAST_STORM_RATE;
+	//data16 |=3D (BROADCAST_STORM_VALUE * BROADCAST_STORM_PROT_RATE) / 100;
+	//ksz_write16(dev, REG_SW_MAC_CTRL_2, data16);
+#endif=09
=20
 	return 0;
 }
=20
+#define PORT_MAC_LOOPBACK_my 0x80
+#ifdef KSZOLD
+#define REG_PORT_CTRL_LOOPBACK REG_PORT_CTRL_0
+#else
+#define REG_PORT_CTRL_LOOPBACK 0x0f
+#endif
+
 static void port_setup(struct ksz_device *dev, int port, bool cpu_port)
 {
+#ifdef KSZOLD
 	u8 data8;
 	u16 data16;
+#endif
=20
+	printk("Port setup %d, %d\n", port, cpu_port);
+
+#ifndef KSZOLD=09
+	if (cpu_port && port !=3D 4)
+		printk("!!! tail tagging only works on port 5\n");
+	if (cpu_port) {
+		printk("enable tail tagging\n");
+		ksz_cfg(dev, S_TAIL_TAG_CTRL, SW_TAIL_TAG_ENABLE, true);
+	}
+#endif
+#ifdef KSZOLD
 	/* enable tag tail for host port */
 	if (cpu_port)
 		ksz_port_cfg(dev, port, REG_PORT_CTRL_0, PORT_TAIL_TAG_ENABLE,
 			     true);
+#endif
=20
-	ksz_port_cfg(dev, port, REG_PORT_CTRL_0, PORT_MAC_LOOPBACK, false);
-
+	ksz_port_cfg(dev, port, REG_PORT_CTRL_LOOPBACK, PORT_MAC_LOOPBACK_my, fal=
se);
+#ifdef KSZOLD
 	/* set back pressure */
 	ksz_port_cfg(dev, port, REG_PORT_MAC_CTRL_1, PORT_BACK_PRESSURE, true);
=20
@@ -343,6 +422,7 @@ static void port_setup(struct ksz_device *dev, int port=
, bool cpu_port)
=20
 	/* clear pending interrupts */
 	ksz_pread16(dev, port, REG_PORT_PHY_INT_ENABLE, &data16);
+#endif
 }
=20
 static void ksz_config_cpu_port(struct dsa_switch *ds)
@@ -379,18 +459,27 @@ static int ksz_setup(struct dsa_switch *ds)
 	}
=20
 	/* accept packet up to 2000bytes */
-	ksz_cfg(dev, REG_SW_MAC_CTRL_1, SW_LEGAL_PACKET_DISABLE, true);
+	//ksz_cfg(dev, REG_SW_MAC_CTRL_1, SW_LEGAL_PACKET_DISABLE, true);
=20
 	ksz_config_cpu_port(ds);
=20
+#ifdef KSOLD
 	ksz_cfg(dev, REG_SW_MAC_CTRL_1, MULTICAST_STORM_DISABLE, true);
+#else
+	ksz_cfg(dev, REG_SW_CTRL_2, MULTICAST_STORM_DISABLE, true);
+#endif
=20
 	/* queue based egress rate limit */
-	ksz_cfg(dev, REG_SW_MAC_CTRL_5, SW_OUT_RATE_LIMIT_QUEUE_BASED, true);
+	//ksz_cfg(dev, REG_SW_MAC_CTRL_5, SW_OUT_RATE_LIMIT_QUEUE_BASED, true);
=20
 	/* start switch */
+#ifndef KSZOLD
+#define REG_SW_OPERATION 1
+#define SW_START 1
+#endif=09
 	ksz_cfg(dev, REG_SW_OPERATION, SW_START, true);
=20
+
 	return 0;
 }
=20
@@ -399,13 +488,17 @@ static enum dsa_tag_protocol ksz_get_tag_protocol(str=
uct dsa_switch *ds)
 	return DSA_TAG_PROTO_KSZ;
 }
=20
+#ifdef KSZOLD
 static int ksz_phy_read16(struct dsa_switch *ds, int addr, int reg)
 {
 	struct ksz_device *dev =3D ds->priv;
 	u16 val =3D 0;
=20
-	ksz_pread16(dev, addr, 0x100 + (reg << 1), &val);
+	/* "MIIM" registers. */
=20
+	printk("Phy: read16 @ %lx, %lx\n", addr, reg);
+	ksz_pread16(dev, addr, 0x100 + (reg << 1), &val);
+	printk("Phy: read16 @ %lx, %lx -> %lx\n", addr, reg, val);
 	return val;
 }
=20
@@ -413,10 +506,14 @@ static int ksz_phy_write16(struct dsa_switch *ds, int=
 addr, int reg, u16 val)
 {
 	struct ksz_device *dev =3D ds->priv;
=20
+	printk("Phy: write16 @ %lx, %lx, %lx\n", addr, reg, val);=09
 	ksz_pwrite16(dev, addr, 0x100 + (reg << 1), val);
=20
 	return 0;
 }
+#else
+#include "ksz_mdio_emulation.c"
+#endif
=20
 static int ksz_enable_port(struct dsa_switch *ds, int port,
 			   struct phy_device *phy)
@@ -429,13 +526,14 @@ static int ksz_enable_port(struct dsa_switch *ds, int=
 port,
 	return 0;
 }
=20
+
 static void ksz_disable_port(struct dsa_switch *ds, int port,
 			     struct phy_device *phy)
 {
 	struct ksz_device *dev =3D ds->priv;
=20
 	/* there is no port disable */
-	ksz_port_cfg(dev, port, REG_PORT_CTRL_0, PORT_MAC_LOOPBACK, true);
+	ksz_port_cfg(dev, port, REG_PORT_CTRL_LOOPBACK, PORT_MAC_LOOPBACK_my, tru=
e);
 }
=20
 static int ksz_sset_count(struct dsa_switch *ds)
@@ -456,6 +554,7 @@ static void ksz_get_strings(struct dsa_switch *ds, int =
port, uint8_t *buf)
 static void ksz_get_ethtool_stats(struct dsa_switch *ds, int port,
 				  uint64_t *buf)
 {
+#ifdef KSOLD=09
 	struct ksz_device *dev =3D ds->priv;
 	int i;
 	u32 data;
@@ -491,13 +590,35 @@ static void ksz_get_ethtool_stats(struct dsa_switch *=
ds, int port,
 	}
=20
 	mutex_unlock(&dev->stats_mutex);
+#else
+	NOTIMPLV();
+#endif=09
+}
+
+static void ksz_dump(struct ksz_device *dev)
+{
+	int i;
+	u8 v;
+
+	printk("ksz: dumping:\n");
+	for (i =3D 0; i < 0x100; i++) {
+		if (!(i % 0x10))
+			printk("\n %lx: ", i);
+		ksz_read8(dev, i, &v);
+		printk("%02x ", v);
+	}
+	printk("\nksz: dump done\n");
 }
=20
 static void ksz_port_stp_state_set(struct dsa_switch *ds, int port, u8 sta=
te)
 {
 	struct ksz_device *dev =3D ds->priv;
 	u8 data;
+#ifndef KSOLD
+#define P_STP_CTRL 2=09
+#endif
=20
+	printk("port %d state %d\n", port, state);
 	ksz_pread8(dev, port, P_STP_CTRL, &data);
 	data &=3D ~(PORT_TX_ENABLE | PORT_RX_ENABLE | PORT_LEARN_DISABLE);
=20
@@ -512,6 +633,7 @@ static void ksz_port_stp_state_set(struct dsa_switch *d=
s, int port, u8 state)
 		data |=3D PORT_RX_ENABLE;
 		break;
 	case BR_STATE_FORWARDING:
+		printk("port %d state %d forwarding\n", port, state);	=09
 		data |=3D (PORT_TX_ENABLE | PORT_RX_ENABLE);
 		break;
 	case BR_STATE_BLOCKING:
@@ -523,10 +645,18 @@ static void ksz_port_stp_state_set(struct dsa_switch =
*ds, int port, u8 state)
 	}
=20
 	ksz_pwrite8(dev, port, P_STP_CTRL, data);
+=09
+	/* FIXME ! */
+	//ksz_write8(dev, 0x0c, 0x16);
+=09
+	ksz_dump(dev);
+
+
 }
=20
 static void ksz_port_fast_age(struct dsa_switch *ds, int port)
 {
+#ifdef KSOLD
 	struct ksz_device *dev =3D ds->priv;
 	u8 data8;
=20
@@ -536,10 +666,15 @@ static void ksz_port_fast_age(struct dsa_switch *ds, =
int port)
=20
 	data8 &=3D ~SW_FAST_AGING;
 	ksz_write8(dev, REG_SW_LUE_CTRL_1, data8);
+#else
+	NOTIMPLV();
+#endif=09
+=09
 }
=20
 static int ksz_port_vlan_filtering(struct dsa_switch *ds, int port, bool f=
lag)
 {
+#ifdef KSOLD=09
 	struct ksz_device *dev =3D ds->priv;
=20
 	if (flag) {
@@ -553,7 +688,9 @@ static int ksz_port_vlan_filtering(struct dsa_switch *d=
s, int port, bool flag)
 		ksz_port_cfg(dev, port, REG_PORT_LUE_CTRL,
 			     PORT_VLAN_LOOKUP_VID_0, false);
 	}
-
+#else
+	NOTIMPL();
+#endif=09
 	return 0;
 }
=20
@@ -570,6 +707,7 @@ static void ksz_port_vlan_add(struct dsa_switch *ds, in=
t port,
 			      const struct switchdev_obj_port_vlan *vlan,
 			      struct switchdev_trans *trans)
 {
+#ifdef KSOLD=09
 	struct ksz_device *dev =3D ds->priv;
 	u32 vlan_table[3];
 	u16 vid;
@@ -599,11 +737,15 @@ static void ksz_port_vlan_add(struct dsa_switch *ds, =
int port,
 		if (vlan->flags & BRIDGE_VLAN_INFO_PVID)
 			ksz_pwrite16(dev, port, REG_PORT_DEFAULT_VID, vid);
 	}
+#else
+	NOTIMPLV();
+#endif=09
 }
=20
 static int ksz_port_vlan_del(struct dsa_switch *ds, int port,
 			     const struct switchdev_obj_port_vlan *vlan)
 {
+#ifdef KSOLD=09
 	struct ksz_device *dev =3D ds->priv;
 	bool untagged =3D vlan->flags & BRIDGE_VLAN_INFO_UNTAGGED;
 	u32 vlan_table[3];
@@ -634,6 +776,9 @@ static int ksz_port_vlan_del(struct dsa_switch *ds, int=
 port,
 	}
=20
 	ksz_pwrite16(dev, port, REG_PORT_DEFAULT_VID, pvid);
+#else
+	NOTIMPL();
+#endif=09
=20
 	return 0;
 }
@@ -642,6 +787,7 @@ static int ksz_port_vlan_dump(struct dsa_switch *ds, in=
t port,
 			      struct switchdev_obj_port_vlan *vlan,
 			      switchdev_obj_dump_cb_t *cb)
 {
+#ifdef KSOLD=09
 	struct ksz_device *dev =3D ds->priv;
 	u16 vid;
 	u16 data;
@@ -676,6 +822,9 @@ static int ksz_port_vlan_dump(struct dsa_switch *ds, in=
t port,
 	mutex_unlock(&dev->vlan_mutex);
=20
 	return err;
+#else
+	NOTIMPL();
+#endif=09
 }
=20
 static int ksz_port_fdb_prepare(struct dsa_switch *ds, int port,
@@ -710,6 +859,7 @@ static void ksz_port_fdb_add(struct dsa_switch *ds, int=
 port,
 			     const struct switchdev_obj_port_fdb *fdb,
 			     struct switchdev_trans *trans)
 {
+#ifdef KSOLD=09
 	struct ksz_device *dev =3D ds->priv;
 	u32 alu_table[4];
 	u32 data;
@@ -757,11 +907,15 @@ static void ksz_port_fdb_add(struct dsa_switch *ds, i=
nt port,
=20
 exit:
 	mutex_unlock(&dev->alu_mutex);
+#else
+	NOTIMPL();
+#endif=09
 }
=20
 static int ksz_port_fdb_del(struct dsa_switch *ds, int port,
 			    const struct switchdev_obj_port_fdb *fdb)
 {
+#ifdef KSOLD=09
 	struct ksz_device *dev =3D ds->priv;
 	u32 alu_table[4];
 	u32 data;
@@ -822,12 +976,15 @@ static int ksz_port_fdb_del(struct dsa_switch *ds, in=
t port,
=20
 exit:
 	mutex_unlock(&dev->alu_mutex);
-
 	return ret;
+#else
+	NOTIMPL();
+#endif=09
 }
=20
 static void convert_alu(struct alu_struct *alu, u32 *alu_table)
 {
+#ifdef KSOLD=09
 	alu->is_static =3D !!(alu_table[0] & ALU_V_STATIC_VALID);
 	alu->is_src_filter =3D !!(alu_table[0] & ALU_V_SRC_FILTER);
 	alu->is_dst_filter =3D !!(alu_table[0] & ALU_V_DST_FILTER);
@@ -847,12 +1004,16 @@ static void convert_alu(struct alu_struct *alu, u32 =
*alu_table)
 	alu->mac[3] =3D (alu_table[3] >> 16) & 0xFF;
 	alu->mac[4] =3D (alu_table[3] >> 8) & 0xFF;
 	alu->mac[5] =3D alu_table[3] & 0xFF;
+#else
+	NOTIMPLV();
+#endif=09
 }
=20
 static int ksz_port_fdb_dump(struct dsa_switch *ds, int port,
 			     struct switchdev_obj_port_fdb *fdb,
 			     switchdev_obj_dump_cb_t *cb)
 {
+#ifdef KSOLD=09
 	struct ksz_device *dev =3D ds->priv;
 	int ret =3D 0;
 	u32 data;
@@ -860,6 +1021,7 @@ static int ksz_port_fdb_dump(struct dsa_switch *ds, in=
t port,
 	struct alu_struct alu;
 	int timeout;
=20
+
 	mutex_lock(&dev->alu_mutex);
=20
 	/* start ALU search */
@@ -907,6 +1069,9 @@ static int ksz_port_fdb_dump(struct dsa_switch *ds, in=
t port,
 	mutex_unlock(&dev->alu_mutex);
=20
 	return ret;
+#else
+	NOTIMPL();
+#endif=09
 }
=20
 static int ksz_port_mdb_prepare(struct dsa_switch *ds, int port,
@@ -921,6 +1086,7 @@ static void ksz_port_mdb_add(struct dsa_switch *ds, in=
t port,
 			     const struct switchdev_obj_port_mdb *mdb,
 			     struct switchdev_trans *trans)
 {
+#ifdef KSOLD=09
 	struct ksz_device *dev =3D ds->priv;
 	u32 static_table[4];
 	u32 data;
@@ -986,11 +1152,15 @@ static void ksz_port_mdb_add(struct dsa_switch *ds, =
int port,
=20
 exit:
 	mutex_unlock(&dev->alu_mutex);
+#else
+	NOTIMPL();
+#endif=09
 }
=20
 static int ksz_port_mdb_del(struct dsa_switch *ds, int port,
 			    const struct switchdev_obj_port_mdb *mdb)
 {
+#ifdef KSOLD=09
 	struct ksz_device *dev =3D ds->priv;
 	u32 static_table[4];
 	u32 data;
@@ -1063,6 +1233,9 @@ static int ksz_port_mdb_del(struct dsa_switch *ds, in=
t port,
 	mutex_unlock(&dev->alu_mutex);
=20
 	return ret;
+#else
+	NOTIMPL();
+#endif=09
 }
=20
 static int ksz_port_mdb_dump(struct dsa_switch *ds, int port,
@@ -1077,6 +1250,7 @@ static int ksz_port_mirror_add(struct dsa_switch *ds,=
 int port,
 			       struct dsa_mall_mirror_tc_entry *mirror,
 			       bool ingress)
 {
+#ifdef KSOLD=09
 	struct ksz_device *dev =3D ds->priv;
=20
 	if (ingress)
@@ -1093,11 +1267,16 @@ static int ksz_port_mirror_add(struct dsa_switch *d=
s, int port,
 	ksz_cfg(dev, S_MIRROR_CTRL, SW_MIRROR_RX_TX, false);
=20
 	return 0;
+#else
+	NOTIMPL();
+#endif=09
+
 }
=20
 static void ksz_port_mirror_del(struct dsa_switch *ds, int port,
 				struct dsa_mall_mirror_tc_entry *mirror)
 {
+#ifdef KSOLD=09
 	struct ksz_device *dev =3D ds->priv;
 	u8 data;
=20
@@ -1111,6 +1290,10 @@ static void ksz_port_mirror_del(struct dsa_switch *d=
s, int port,
 	if (!(data & (PORT_MIRROR_RX | PORT_MIRROR_TX)))
 		ksz_port_cfg(dev, mirror->to_local_port, P_MIRROR_CTRL,
 			     PORT_MIRROR_SNIFFER, false);
+#else
+	NOTIMPLV();
+#endif=09
+=09
 }
=20
 static const struct dsa_switch_ops ksz_switch_ops =3D {
@@ -1162,6 +1345,15 @@ static const struct ksz_chip_data ksz_switch_chips[]=
 =3D {
 		.cpu_ports =3D 0x7F,	/* can be configured as cpu port */
 		.port_cnt =3D 7,		/* total physical port count */
 	},
+	{
+		.chip_id =3D 0x95600c04,
+		.dev_name =3D "KSZ8895",
+		.num_vlans =3D 4096, /* FIXME ? */
+		.num_alus =3D 4096,
+		.num_statics =3D 16,
+		.cpu_ports =3D 0x10,	/* can be configured as cpu port */
+		.port_cnt =3D 5,		/* total physical port count */
+	},
 };
=20
 static int ksz_switch_init(struct ksz_device *dev)
@@ -1175,9 +1367,13 @@ static int ksz_switch_init(struct ksz_device *dev)
=20
 	dev->ds->ops =3D &ksz_switch_ops;
=20
+	printk("\n\n\nksz_switch_init: detecting\n");
+
 	for (i =3D 0; i < ARRAY_SIZE(ksz_switch_chips); i++) {
 		const struct ksz_chip_data *chip =3D &ksz_switch_chips[i];
=20
+		printk("ksz_switch_init: have id %lx %lx\n", dev->chip_id, chip->chip_id=
);
+
 		if (dev->chip_id =3D=3D chip->chip_id) {
 			dev->name =3D chip->dev_name;
 			dev->num_vlans =3D chip->num_vlans;
@@ -1189,6 +1385,8 @@ static int ksz_switch_init(struct ksz_device *dev)
 			break;
 		}
 	}
+=09
+	printk("ksz_switch_init: detected %s\n", dev->name);
=20
 	/* no switch found */
 	if (!dev->port_cnt)
@@ -1228,7 +1426,7 @@ int ksz_switch_detect(struct ksz_device *dev)
 	u8 data8;
 	u32 id32;
 	int ret;
-
+#ifdef KSOLD
 	/* turn off SPI DO Edge select */
 	ret =3D ksz_read8(dev, REG_SW_GLOBAL_SERIAL_CTRL_0, &data8);
 	if (ret)
@@ -1238,12 +1436,24 @@ int ksz_switch_detect(struct ksz_device *dev)
 	ret =3D ksz_write8(dev, REG_SW_GLOBAL_SERIAL_CTRL_0, data8);
 	if (ret)
 		return ret;
-
+#endif
 	/* read chip id */
 	ret =3D ksz_read32(dev, REG_CHIP_ID0__1, &id32);
-	if (ret)
+	if (ret) {
+		printk("ksz_switch_detect: error\n");
 		return ret;
-
+	}
+	printk("ksz_switch_detect: id %lx\n", id32);
+=09
+	ret =3D ksz_read8(dev, 0, &data8);
+	printk("ksz_switch_detect: byte %lx, ret %d\n", data8, ret);
+	ret =3D ksz_read8(dev, 1, &data8);
+	printk("ksz_switch_detect: byte %lx, ret %d\n", data8, ret);
+	ret =3D ksz_read8(dev, 2, &data8);
+	printk("ksz_switch_detect: byte %lx, ret %d\n", data8, ret);
+	ret =3D ksz_read8(dev, 3, &data8);
+	printk("ksz_switch_detect: byte %lx, ret %d\n", data8, ret);
+=09
 	dev->chip_id =3D id32;
=20
 	return 0;
diff --git a/drivers/net/dsa/microchip/ksz_mdio_emulation.c b/drivers/net/d=
sa/microchip/ksz_mdio_emulation.c
new file mode 100644
index 000000000000..8ed62dc1615e
--- /dev/null
+++ b/drivers/net/dsa/microchip/ksz_mdio_emulation.c
@@ -0,0 +1,373 @@
+/**
+ * Micrel KSZ8895 SPI driver
+ *
+ * Copyright (c) 2015 Micrel, Inc.
+ *
+ * GPLv2
+ */
+
+#include "ksz_sw_phy.h"
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
+#ifdef FIXME     =20
+	if (sw->port_cnt < sw->mib_port_cnt && 1 =3D=3D phy_id)
+		return 0xffff;
+#endif
+
+	addr =3D ksz_mii_addr(&regnum, &bank);
+	BUG_ON(addr >=3D 6);
+
+	switch (addr) {
+#ifdef FIXME	=09
+	case ADDR_8:
+		ret =3D HW_R8(ks, regnum);
+		break;
+	case ADDR_16:
+		ret =3D HW_R16(ks, regnum);
+		break;
+	case ADDR_32:
+		ret =3D HW_R32(ks, regnum);
+		break;
+#endif
+	case ADDR_8:
+	case ADDR_16:
+	case ADDR_32:
+		BUG();
+
+	default:
+		if (regnum < 6) {
+			int id =3D phy_id;
+
+			sw_r_phy(sw, phy_id, regnum, &data);
+			ret =3D data;
+#ifdef FIXME?		=09
+			if (0 =3D=3D id) {
+				switch (regnum) {
+				case 0:
+					ret =3D 0x3120;
+					break;
+				case 1:
+					ret =3D 0x782c;
+					break;
+				case 4:
+				case 5:
+					ret =3D 0x05e1;
+					break;
+				}
+			}
+#endif		=09
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
+	static int last_reg;
+	static int last_val;
+	int addr;
+	int bank;
+	int reg;
+
+	if (phy_id > SWITCH_PORT_NUM + 1)
+		return -EINVAL;
+#ifdef FIXME=09
+	if (sw->port_cnt < sw->mib_port_cnt && 1 =3D=3D phy_id)
+		return -EINVAL;
+#endif=09
+
+	BUG_ON(regnum >=3D 6);
+	reg =3D regnum;
+	addr =3D ksz_mii_addr(&regnum, &bank);
+
+	switch (addr) {
+#ifdef FIXME	=09
+	case ADDR_8:
+		HW_W8(ks, regnum, val);
+		break;
+	case ADDR_16:
+		HW_W16(ks, regnum, val);
+		break;
+	case ADDR_32:
+		/*
+		 * The phy_write interface allows only 16-bit value.  Break
+		 * the 32-bit write into two calls for SPI efficiency.
+		 */
+
+		/* Previous write to high word. */
+		if (last_reg =3D=3D reg + 2) {
+			last_val <<=3D 16;
+			last_val |=3D val;
+			HW_W32(ks, regnum, last_val);
+			last_reg =3D 0;
+		} else {
+			/* Somebody has written to different address! */
+			if (last_reg) {
+				int last_bank;
+
+				addr =3D ksz_mii_addr(&last_reg, &last_bank);
+				HW_W16(ks, last_reg, last_val);
+				last_reg =3D 0;
+			}
+
+			/* Cache the 16-bit write to high word. */
+			if (reg & 3) {
+				last_reg =3D reg;
+				last_val =3D val;
+
+			/* Did not find the previous write to high word.*/
+			} else
+				HW_W16(ks, regnum, val);
+		}
+		break;
+#endif
+	case ADDR_8:
+	case ADDR_16:
+	case ADDR_32:
+		BUG();
+	default:
+		if (regnum < 6) {
+			int i;
+			int p =3D 0;
+
+			/* PHY device driver resets or powers down the PHY. */
+			if (0 =3D=3D regnum &&
+			    (val & (PHY_RESET | PHY_POWER_DOWN)))
+				break;
+#ifdef FIXME		=09
+			if (sw->port_cnt < sw->mib_port_cnt)
+				p =3D 1;
+#endif
+			sw_w_phy(sw, phy_id, regnum, val);
+		}
+		break;
+	}
+
+	return 0;
+}  /* ksz_mii_write */
diff --git a/drivers/net/dsa/microchip/ksz_priv.h b/drivers/net/dsa/microch=
ip/ksz_priv.h
index 2a98dbd51456..2344cc1cde75 100644
--- a/drivers/net/dsa/microchip/ksz_priv.h
+++ b/drivers/net/dsa/microchip/ksz_priv.h
@@ -25,7 +25,7 @@
 #include <linux/etherdevice.h>
 #include <net/dsa.h>
=20
-#include "ksz_9477_reg.h"
+#include "ksz_8895_reg.h"
=20
 struct ksz_io_ops;
=20
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
index c51946983bed..37858d9b8f4f 100644
--- a/drivers/net/dsa/microchip/ksz_spi.c
+++ b/drivers/net/dsa/microchip/ksz_spi.c
@@ -29,22 +29,38 @@
 #define KS_SPIOP_RD			3
 #define KS_SPIOP_WR			2
=20
+#ifdef KSOLD
 #define SPI_ADDR_SHIFT			24
-#define SPI_ADDR_MASK			(BIT(SPI_ADDR_SHIFT) - 1)
 #define SPI_TURNAROUND_SHIFT		5
+#else
+/* FIXME?! */
+#define SPI_ADDR_SHIFT			12
+#define SPI_TURNAROUND_SHIFT		1
+#endif
+#define SPI_ADDR_MASK			(BIT(SPI_ADDR_SHIFT) - 1)
=20
 static int ksz_spi_read_reg(struct spi_device *spi, u32 reg, u8 *val,
 			    unsigned int len)
 {
-	u32 txbuf;
 	int ret;
=20
+#ifdef KSOLD
+	u32 txbuf;
 	txbuf =3D reg & SPI_ADDR_MASK;
 	txbuf |=3D KS_SPIOP_RD << SPI_ADDR_SHIFT;
 	txbuf <<=3D SPI_TURNAROUND_SHIFT;
 	txbuf =3D cpu_to_be32(txbuf);
=20
 	ret =3D spi_write_then_read(spi, &txbuf, 4, val, len);
+#else
+	u8 buf[2];
+
+	buf[0] =3D KS_SPIOP_RD;
+	buf[1] =3D reg;
+
+	ret =3D spi_write_then_read(spi, buf, 2, val, len);
+#endif=09
+
 	return ret;
 }
=20
@@ -99,8 +115,10 @@ static int ksz_spi_read32(struct ksz_device *dev, u32 r=
eg, u32 *val)
 static int ksz_spi_write_reg(struct spi_device *spi, u32 reg, u8 *val,
 			     unsigned int len)
 {
-	u32 txbuf;
 	u8 data[12];
+
+#ifdef KSOLD
+	u32 txbuf;
 	int i;
=20
 	txbuf =3D reg & SPI_ADDR_MASK;
@@ -116,6 +134,16 @@ static int ksz_spi_write_reg(struct spi_device *spi, u=
32 reg, u8 *val,
 		data[i + 4] =3D val[i];
=20
 	return spi_write(spi, &data, 4 + len);
+#else
+	int i;
+=09
+	data[0] =3D KS_SPIOP_WR;
+	data[1] =3D reg;
+	for (i =3D 0; i < len; i++)
+		data[i + 2] =3D val[i];
+
+	return spi_write(spi, &data, 2 + len);
+#endif
 }
=20
 static int ksz_spi_write8(struct ksz_device *dev, u32 reg, u8 value)
@@ -174,6 +202,8 @@ static int ksz_spi_probe(struct spi_device *spi)
 	if (spi->dev.platform_data)
 		dev->pdata =3D spi->dev.platform_data;
=20
+	//printk("Chip variant is %lx\n", spi_get_device_id(spi)->driver_data
+
 	ret =3D ksz_switch_register(dev);
 	if (ret)
 		return ret;
@@ -195,6 +225,7 @@ static int ksz_spi_remove(struct spi_device *spi)
=20
 static const struct of_device_id ksz_dt_ids[] =3D {
 	{ .compatible =3D "microchip,ksz9477" },
+	{ .compatible =3D "microchip,ksz8895" },=09
 	{},
 };
 MODULE_DEVICE_TABLE(of, ksz_dt_ids);
diff --git a/drivers/net/dsa/microchip/ksz_sw_phy.h b/drivers/net/dsa/micro=
chip/ksz_sw_phy.h
new file mode 100644
index 000000000000..bb97613a6c84
--- /dev/null
+++ b/drivers/net/dsa/microchip/ksz_sw_phy.h
@@ -0,0 +1,754 @@
+/**
+ * Micrel switch PHY common header
+ *
+ * Copyright (c) 2012-2015 Micrel, Inc.
+ *	Tristram Ha <Tristram.Ha@micrel.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+
+#ifndef KSZ_PHY_H
+#define KSZ_PHY_H
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
+#define KSZ8895_COUNTER_NUM		0x20
+#define TOTAL_KSZ8895_COUNTER_NUM	(KSZ8895_COUNTER_NUM + 2)
+
+#define SWITCH_COUNTER_NUM		KSZ8895_COUNTER_NUM
+#define TOTAL_SWITCH_COUNTER_NUM	TOTAL_KSZ8895_COUNTER_NUM
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
+#endif
diff --git a/net/dsa/tag_ksz.c b/net/dsa/tag_ksz.c
index de66ca8e6201..4f973723d32a 100644
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
@@ -40,6 +40,7 @@ static struct sk_buff *ksz_xmit(struct sk_buff *skb, stru=
ct net_device *dev)
 	u8 *tag;
=20
 	padlen =3D (skb->len >=3D ETH_ZLEN) ? 0 : ETH_ZLEN - skb->len;
+	printk("ksz_xmit...\n");
=20
 	if (skb_tailroom(skb) >=3D padlen + KSZ_INGRESS_TAG_LEN) {
 		if (skb_put_padto(skb, skb->len + padlen))
@@ -69,8 +70,9 @@ static struct sk_buff *ksz_xmit(struct sk_buff *skb, stru=
ct net_device *dev)
 	}
=20
 	tag =3D skb_put(nskb, KSZ_INGRESS_TAG_LEN);
-	tag[0] =3D 0;
-	tag[1] =3D 1 << p->dp->index; /* destination port */
+	tag[0] =3D 1 << p->dp->index; /* destination port */
+
+	printk("ksz_xmit: tagging with %lx\n", 1 << p->dp->index);
=20
 	return nskb;
 }
@@ -88,6 +90,7 @@ static struct sk_buff *ksz_rcv(struct sk_buff *skb, struc=
t net_device *dev,
 	tag =3D skb_tail_pointer(skb) - KSZ_EGRESS_TAG_LEN;
=20
 	source_port =3D tag[0] & 7;
+	printk("ksz_rcv: got source port %d\n", source_port);
 	if (source_port >=3D ds->num_ports || !ds->ports[source_port].netdev)
 		return NULL;
=20

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--Qxx1br4bt0+wmkIi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmdRlQACgkQMOfwapXb+vIEXACeKq7iaIzZAW7FZr6yzqcz65x1
FvMAn2DGvUYtqEe41TlFhLsaZ3gYZIsz
=bTpz
-----END PGP SIGNATURE-----

--Qxx1br4bt0+wmkIi--
