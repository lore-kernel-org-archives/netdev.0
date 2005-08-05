From: Mateusz Berezecki <mateuszb@gmail.com>
Subject: [patch 4/8] atheros driver - eeprom routines
Date: Fri, 5 Aug 2005 16:23:59 +0200
Message-ID: <20050805142359.GA2576@ntjohd.mshome.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="KFztAG8eRSV9hGtP"
Cc: netdev@vger.kernel.org
Return-path: <kernel-mentors-bounces@selenic.com>
To: kernel-mentors@selenic.com
Content-Disposition: inline
List-Unsubscribe: <http://selenic.com/mailman/listinfo/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=unsubscribe>
List-Archive: <http://www.selenic.com/pipermail/kernel-mentors>
List-Post: <mailto:kernel-mentors@selenic.com>
List-Help: <mailto:kernel-mentors-request@selenic.com?subject=help>
List-Subscribe: <http://selenic.com/mailman/listinfo/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=subscribe>
Sender: kernel-mentors-bounces@selenic.com
Errors-To: kernel-mentors-bounces@selenic.com
List-Id: netdev.vger.kernel.org


--KFztAG8eRSV9hGtP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

resending patch 4/8 as it was reported missing

--KFztAG8eRSV9hGtP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline; filename="atheros5212-4.patch"
Content-Transfer-Encoding: quoted-printable

diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.=
git#ieee80211/drivers/net/wireless/atheros/atheros5212/eeprom.c netdev-athe=
ros/drivers/net/wireless/atheros/atheros5212/eeprom.c
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/eepro=
m.c	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/eeprom.c	2005-0=
8-05 03:48:36.000000000 +0200
@@ -0,0 +1,501 @@
+/*
+ * All the work was created by reverse engineering and porting
+ * for interoperability. The creator is Mateusz Berezecki,
+ * unless explicitly marked ( some parts are derived
+ * from GPL'ed parts of madwifi project located at http://madwifi.sf.net)
+ *
+ * the original assembly code has been created by Sam Leffler
+ * Copyright (c) 2002-2005 Sam Leffler, Errno Consulting
+ * All rights reserved.
+ *=20
+ * rest of the code has been reversed by me and is under copyright too
+ * Copyright (C) 2005  Mateusz Berezecki
+ *=20
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *=20
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-13=
01, USA.
+ *
+ */
+
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+
+#include <net/ieee80211.h>
+
+#include <linux/wireless.h>
+#include <net/iw_handler.h>
+
+#include "atheros_id.h"
+#include "atheros_dev.h"
+#include "atheros_defs.h"
+//#include "atheros_devops.h"
+//#include "atheros_regops.h"
+#include "atheros_registers.h"
+#include "atheros.h"
+#include "eeprom.h"
+
+/* XXX add calibration info */
+unsigned int get_cal(struct eeprom_info *e, unsigned int val)
+{
+	return 0;
+}
+
+
+/* should be called poll_read. waits some time for a specific value
+ * being read */
+unsigned int ath_timed_read(struct net_device *netdev,
+		unsigned int reg, unsigned int mask,
+		unsigned int val)
+{
+	unsigned int i, tmp;
+	for (i =3D 0; i < 1000; i++) {
+		tmp =3D ath_reg_read(netdev, reg) & mask;
+		if ((tmp & mask) =3D=3D val)
+			return 1;
+		udelay(15);
+	}
+=09
+	printk(KERN_DEBUG"atheros: timed read failing: mask:%x val:%x\n",
+			mask, val);
+	return 0;
+}
+
+/* read from EEPROM */
+unsigned int eeprom_read(struct net_device *netdev,=20
+		unsigned int x, unsigned int *val)
+{
+=09
+	ath_reg_write(netdev, 0x6000, x);
+	ath_reg_write(netdev, 0x6008, 1);
+
+	if (!ath_timed_read(netdev, 0x600c, 3, 2))
+		return 0;
+
+	*val =3D ath_reg_read(netdev, 0x6004) & 0xffff;
+=09
+	return 1;=09
+}
+
+/* read antenna control stuff while initializing the chipset */
+void eeprom_read_ant_control(struct net_device *netdev, unsigned int reg, =
unsigned int idx)
+{
+	struct atheros_priv *pdata =3D ieee80211_priv(netdev);
+	struct eeprom_info *e =3D &pdata->eeinfo;
+	unsigned int val;
+=09
+	eeprom_read(netdev, reg++, &val);
+	e->switchval[idx] =3D (val >> 8) & 0x7f;
+	e->txrx[idx] =3D (val >> 2) & 0x3f;
+
+	e->antctrl[0][idx] =3D (val << 4) & 0x3f;
+	e->antctrl[0][idx] |=3D (val >> 12) & 0x0f;
+	e->antctrl[1][idx] =3D (val >> 6) & 0x3f;
+	e->antctrl[2][idx] =3D val & 0x3f;
+
+	eeprom_read(netdev, reg++, &val);
+	e->antctrl[3][idx] =3D (val >> 10) & 0x3f;
+	e->antctrl[4][idx] =3D (val >> 4) & 0x3f;
+	e->antctrl[5][idx] =3D (val << 2) & 0x3f;
+
+	eeprom_read(netdev, reg++, &val);
+	e->antctrl[5][idx] |=3D (val >> 14) & 3;
+	e->antctrl[6][idx] =3D (val >> 8) & 0x3f;
+	e->antctrl[7][idx] =3D (val >> 2) & 0x3f;
+	e->antctrl[8][idx] =3D (val << 4) & 0x3f;
+
+	eeprom_read(netdev, reg++, &val);
+	e->antctrl[8][idx] |=3D (val >> 12) & 0xf;
+	e->antctrl[9][idx] =3D (val >> 6) & 0x3f;
+	e->antctrl[10][idx] =3D val & 0x3f;
+
+=09
+}
+
+/* read wireless mode info from EEPROM=20
+ * XXX: this needs splitting to be more readable.
+ * though i have no idea how to do it yet
+ *
+ * this is UGLY UGLY UGLY
+ */
+void eeprom_read_mode(struct net_device *netdev, unsigned int reg, int k)
+{
+	struct atheros_priv *pdata =3D ieee80211_priv(netdev);
+	struct eeprom_info *e =3D &pdata->eeinfo;
+	unsigned int val;
+=09
+	eeprom_read_ant_control(netdev, reg, k);
+	reg +=3D 4;
+=09
+	eeprom_read(netdev, reg++, &val);
+	e->adcsize[k] =3D (val >> 8) & 0xff;
+
+	switch (k) {
+		case 0:
+			e->g5_k4 =3D (val >> 5) & 7;
+			e->g5_v4 =3D (val >> 2) & 7;
+			e->g5_k3 =3D (val << 1) & 7;
+			break;
+		=09
+		case 1:
+			e->g2_k1 =3D (val >> 4) & 7;
+			e->g2_v1 =3D val & 7;
+			break;
+		=09
+		case 2:
+			e->g2_k2g =3D (val >> 4) & 7;
+			e->g2_v2g =3D val & 7;
+			break;
+	}
+
+	if (k =3D=3D 0) {
+		eeprom_read(netdev, reg++, &val);
+		e->g5_k3 |=3D (val >> 15) & 1;
+		e->g5_v3 =3D (val >> 12) & 7;
+		e->g5_k2 =3D (val >> 9) & 7;
+		e->g5_v2 =3D (val >> 6) & 7;
+		e->g5_k1 =3D (val >> 3) & 7;
+		e->g5_v1 =3D val & 7;
+	}
+
+	eeprom_read(netdev, reg++, &val);
+	e->txendon[k] =3D (val >> 8) & 0xff;
+	e->thresh[k] =3D val & 0xff;
+
+	eeprom_read(netdev, reg++, &val);
+	e->txendoff[k] =3D (val >> 8) & 0xff;
+	e->txfrmctrl[k] =3D val & 0xff;
+
+	eeprom_read(netdev, reg++, &val);
+	e->pgasize[k] =3D (val >> 8) & 0xff;
+	e->noise_floor[k] =3D val & 0xff;
+
+	if (e->noise_floor[k] & 0x80) {
+		e->noise_floor[k] =3D 0 -=20
+			((e->noise_floor[k] ^ 0xff) + 1);
+	}
+
+	eeprom_read(netdev, reg++, &val);
+	e->xlna_gain[k] =3D (val >> 5) & 0xff;
+	e->xgain[k] =3D (val >> 1) & 0x0f;
+	e->xpd[k] =3D val & 1;
+
+	if (e->version >=3D 0x4000) {
+		switch (k) {
+			case 0:
+				e->fixed5 =3D (val >> 13) & 1;
+				break;
+			case 2:
+				e->fixed2 =3D (val >> 13) & 1;
+		}
+	}
+
+	if (e->version >=3D 0x3003) {
+		eeprom_read(netdev, reg++, &val);
+		e->detbkoff[k] =3D (val >> 6) & 0x7f;
+
+		switch (k) {
+			case 0:
+				e->xr5_pwr_limit =3D val & 0x3f;
+				break;
+			case 1:
+				e->g2_k3[0] =3D val & 7;
+				e->g2_v3[0] =3D (val >> 3) & 7;
+				break;
+			case 2:
+				e->g2_k3[1] =3D val & 7;
+				e->g2_v3[1] =3D (val >> 3) & 7;
+				break;
+		}
+	}
+=09
+	if (e->version >=3D 0x3004) {
+		e->igain[k] =3D (val >> 13) & 7;
+		eeprom_read(netdev, reg++, &val);
+		e->igain[k] |=3D (val << 3) & 0x38;
+	=09
+		switch (k) {
+			case 0:
+				if (e->version >=3D 0x4000) {
+					e->ical[0] =3D=20
+						(val >> 8) & 0x3f;
+					e->qcal[0] =3D
+						(val >> 3) & 0x1f;
+				}
+				break;
+			case 2:
+				e->pwr_diff =3D (val >> 3) & 0xff;
+				if (e->version >=3D 0x4006)
+					e->scale_14 =3D=20
+						(val >> 11) & 0x1f;
+				break;=09
+		}
+	} else {
+		e->igain[k] =3D 10;
+		e->pwr_diff =3D 10;
+	}
+=09
+	if (e->version >=3D 0x4000) {
+		switch (k) {
+			case 0:
+				if (e->version < 0x4001)
+					break;
+				eeprom_read(netdev,reg++, &val);
+				e->rxtx_epsilon[0] =3D val & 0x3f;
+				break;
+
+			case 1:
+				eeprom_read(netdev,reg++,&val);
+				e->cal11b[0] =3D=20
+					get_cal(e, val & 0xff);
+				e->cal11b[1] =3D=20
+					get_cal(e, (val >> 8) & 0xff);
+				eeprom_read(netdev,reg++,&val);
+				e->cal11b[2] =3D=20
+					get_cal(e, val & 0xff);
+
+				if (e->version < 0x4001)
+					break;
+
+				e->rxtx_epsilon[1] =3D=20
+					(val >> 8) & 0x3f;
+				break;
+
+			case 2:
+				eeprom_read(netdev,reg++,&val);
+				e->cal11g[0] =3D=20
+					get_cal(e, val & 0xff);
+				e->cal11g[1] =3D=20
+					get_cal(e,=20
+					(val >> 8) & 0xff);
+				eeprom_read(netdev,reg++,&val);
+				e->turbo2_pwr_limit =3D
+					val & 0x7f;
+				e->xr2_pwr_limit =3D=20
+					(val >> 7) & 0x3f;
+				eeprom_read(netdev,reg++,&val);
+				e->cal11g[2] =3D=20
+					get_cal(e, val & 0xff);
+
+				if (e->version >=3D 0x4001) {
+					e->rxtx_epsilon[2] =3D
+						(val >> 8)&0x3f;
+				}
+				eeprom_read(netdev,reg++,&val);
+				e->ical[1] =3D (val >> 8) & 0x3f;
+				e->qcal[1] =3D (val >> 3) & 0x1f;
+
+				if (e->version < 0x4002)
+					break;
+
+				eeprom_read(netdev,reg++,&val);
+				e->pwr_diff =3D val & 0xff;
+				break;
+		}
+	}
+}
+
+void eeprom_read_info3_3(struct net_device *netdev)
+{
+	struct atheros_priv *pdata =3D ieee80211_priv(netdev);
+	struct eeprom_info *e =3D &pdata->eeinfo;
+	unsigned int val, tmp, i;
+=09
+	eeprom_read(netdev, 0xc2, &val);
+	e->disabled_turbo5 =3D (val >> 15) & 1;
+	e->disabled_turbo2 =3D (val >> 3) & 1;
+	e->turbo2_pwr_limit =3D (val >> 4) & 0x7f;
+
+	e->rfkill =3D (val >> 14) & 1;
+	e->devtyp =3D (val >> 11) & 1;
+
+	e->mode_a =3D (val & 1);
+	e->mode_b =3D (val >> 1) & 1;
+	e->mode_g =3D (val >> 2) & 1;
+	printk(KERN_DEBUG"atheros: modes [A:%x B:%x G:%x]\n",
+			e->mode_a, e->mode_b, e->mode_g);
+=09
+	eeprom_read(netdev, 0xc3, &val);
+	e->antgain_limit[0] =3D (char) (val >> 8) & 0xff;
+	e->antgain_limit[1] =3D (char) (val >> 8);
+
+	if (e->version >=3D 0x4000) {
+		eeprom_read(netdev, 0xc4, &val);
+		e->mp =3D (val >> 14) & 3;
+		e->ear =3D (val & 0xfff);
+	=09
+		eeprom_read(netdev, 0xc5, &val);
+		e->pwr_start =3D val & 0xfff;
+		e->clk_32khz =3D (val >> 14) & val;
+	}
+=09
+	eeprom_read_mode(netdev, 0xd4, 0);
+	eeprom_read_mode(netdev, 0xf2, 1);
+	eeprom_read_mode(netdev, 0x10d, 2);
+
+	if (e->version < 0x3003) {
+		eeprom_read(netdev, 0xec, &val);
+		e->g2_k3[0] =3D val & 7;
+		e->g2_v3[0] =3D (val >> 3) & 7;
+
+		eeprom_read(netdev, 0xed, &val);
+		e->g2_k3[1] =3D val & 7;
+		e->g2_v3[1] =3D (val >> 3) & 7;
+	}
+
+	e->cal.val3 =3D 4;
+	e->cal.val2 =3D 1;
+	e->cal.val1 =3D 1;
+	e->cal.sel =3D 0;
+
+	tmp =3D 0x128;
+	for(i =3D 0; i < e->count; i +=3D 2) {
+		eeprom_read(netdev, tmp++, &val);
+		e->controls[i] =3D (val >> 8) & 0xff;
+		e->controls[i+1] =3D val & 0xff;
+	}
+
+	if (e->version <=3D 0x3002) {
+		e->noise_floor[0] =3D -54;
+		e->noise_floor[1] =3D -1;
+		e->noise_floor[2] =3D -1;
+
+		e->thresh[0] =3D 15;
+		e->thresh[1] =3D 28;
+		e->thresh[2] =3D 28;
+	}
+=09
+	return;
+}
+
+unsigned int eeprom_read_info(struct net_device *netdev)
+{
+	struct atheros_priv *pdata =3D ieee80211_priv(netdev);
+	struct eeprom_info *e =3D &pdata->eeinfo;
+
+	e->pwr_diff =3D 15;
+	e->scale_14 =3D 15;
+
+	printk(KERN_DEBUG"atheros: eeprom version %x\n",
+			e->version);
+	if (e->version >=3D 0x3003) {
+		printk(KERN_DEBUG"atheros: >=3D 3.3\n");
+		eeprom_read_info3_3(netdev);
+		return 1;
+	} else {
+		/* to be added yet XXX
+		eeprom_read_info3(netdev);
+		*/
+		return 0;
+	}
+=09
+	return 1;
+}
+
+
+/* validates EEPROM checksum */
+unsigned int eeprom_chksum(struct net_device *netdev)
+{
+	unsigned int sum =3D 0, i, val;
+=09
+	for (i =3D 0; i < 832; i++) {
+		if (!eeprom_read(netdev, 0xc0 + i, &val))
+			return 0;
+		sum ^=3D val;
+	}
+
+	if (sum !=3D 0xffff)
+		return 0;
+
+	return 1;
+}
+
+/* initialize EEPROM and prepare the chipset */
+unsigned int eeprom_init(struct net_device *netdev)
+{
+	unsigned int size;
+	unsigned int v;
+	struct atheros_priv *pdata =3D ieee80211_priv(netdev);
+
+	if (!eeprom_read(netdev, 0xc1, &v)) {
+		printk(KERN_ERR"atheros: eeprom version read failed!\n");
+		return 0;
+	}
+	pdata->eeinfo.version =3D v;
+
+	printk(KERN_DEBUG"atheros: eeprom_init eeprom version %x\n",
+			pdata->eeinfo.version);
+	if (pdata->eeinfo.version < 0x3002) {
+		printk(KERN_ERR"atheros: unsupported eeprom version\n");
+		return 0;
+	}
+
+	size =3D ath_reg_read(netdev, 0x4010);
+	size =3D (size & 0x18) >> 3;
+
+	if (size !=3D 2) {
+		printk(KERN_ERR"atheros: invalid eeprom size!\n");
+		return 0;
+	}
+	if (eeprom_read(netdev, 0x3f, &v) =3D=3D 0) {
+		printk(KERN_ERR"atheros: cant read eeprom 3f bit\n");
+		return 0;
+	}
+	pdata->eeinfo.rdonly =3D v;
+	printk(KERN_DEBUG"atheros: eeprom rdonly flag : %x\n", v);=09
+	if (!eeprom_chksum(netdev)) {
+		printk(KERN_ERR"atheros: bad eeprom checksum!\n");
+		return 0;
+	}
+
+=09
+	return 1;
+}
+
+/* read chipset capabilities */
+unsigned int eeprom_read_caps(struct net_device *netdev)
+{
+	if (!eeprom_read_info(netdev))
+		return 0;
+
+	/* TODO: read calibration info here */
+	return 1;
+}
+
+/* just as the name says. reads hardware MAC address directly from
+ * EEPROM */
+unsigned int eeprom_read_mac(struct net_device *netdev, unsigned char *mac)
+{
+	unsigned int total =3D 0, i, val;
+
+	if (mac =3D=3D NULL)
+		return 0;
+
+	for (i =3D 0; i < 3; i++) {
+		if (!eeprom_read(netdev, 0x1f - i, &val))=20
+			return 0;
+		total +=3D val;
+		mac[2*i] =3D val >> 8;
+		mac[2*i + 1] =3D val & 0xff;
+	}
+
+	if (total =3D=3D 0 || total =3D=3D 3*0xffff)
+		return 0;
+=09
+	return 1;
+}
+
diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.=
git#ieee80211/drivers/net/wireless/atheros/atheros5212/eeprom.h netdev-athe=
ros/drivers/net/wireless/atheros/atheros5212/eeprom.h
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/eepro=
m.h	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/eeprom.h	2005-0=
8-05 03:48:36.000000000 +0200
@@ -0,0 +1,209 @@
+/*
+ * All the work was created by reverse engineering and porting
+ * for interoperability. The creator is Mateusz Berezecki,
+ * unless explicitly marked ( some parts are derived
+ * from GPL'ed parts of madwifi project located at http://madwifi.sf.net)
+ *
+ * derived or copied parts of code licensed under
+ * dual GPL/BSD license
+ * Copyright (c) 2002-2005 Sam Leffler, Errno Consulting
+ * All rights reserved.
+ *=20
+ * rest of the code has been reversed by me and is under copyright too
+ * Copyright (C) 2005  Mateusz Berezecki
+ *=20
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *=20
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-13=
01, USA.
+ *
+ */
+
+#ifndef _EEPROM_H
+#define _EEPROM_H
+
+struct cal_info {
+	unsigned short sel;
+	unsigned short val1;
+	unsigned short val2;
+	unsigned short val3;
+};
+
+struct chan_data {
+	unsigned short chan_val;
+	unsigned short lower_limit;
+	unsigned short upper_limit;
+	unsigned short count;
+	unsigned short clk_values[11];
+	short pwr_values[11];
+};
+
+struct power_info {
+	unsigned short pwr1;
+	unsigned short pwr2;
+	unsigned short pwr3;
+	unsigned short pwr4;
+	unsigned short pwr5;
+};
+
+struct power_modes {
+	unsigned short num11a;
+	unsigned short num11b;
+	unsigned short num11g;
+=09
+	struct power_info pwr11a[8];
+	struct power_info pwr11b[2];
+	struct power_info pwr11g[3];
+};
+
+struct eestrct {
+	unsigned short val1;
+	unsigned short val2;
+	unsigned char flg;
+};
+
+struct chip_data {
+	unsigned short val1;
+	unsigned short val2;
+	unsigned short vals[4];
+	short vals2[4];
+};
+
+struct chip_chan_data {
+	unsigned short chanval;
+	short pwr_upper_limit;
+	struct chip_data cdata[4];
+};
+
+struct chip_chan_pwr_data {
+	unsigned short *pchans;
+	unsigned short chcount;
+	unsigned short val;
+	struct chip_chan_data *pchandata;
+};
+
+struct eeprom_info {
+	unsigned short version;
+	unsigned short rdonly;
+	unsigned short regdomain;
+	unsigned short devtyp;
+=09
+	unsigned short mode_a;
+	unsigned short mode_b;
+	unsigned short mode_g;
+=09
+	unsigned short turbo5_pwr_limit;
+	unsigned short turbo2_pwr_limit;
+=09
+	unsigned short ext5g;
+	unsigned short xr5_pwr_limit;
+	unsigned short xr2_pwr_limit;
+=09
+	unsigned short disabled_turbo5;
+	unsigned short disabled_turbo2;
+	unsigned short rfkill;
+=09
+	unsigned char antgain_limit[2];
+
+	unsigned char pwr_diff; /* cck ofdm delta */
+	unsigned short pwr_gain;
+=09
+	unsigned char clk_32khz;
+=09
+	unsigned short pwr_start;
+	unsigned short fixed5;
+	unsigned short fixed2;
+	unsigned short scale_14;
+	unsigned short mp;
+	unsigned short ear;
+
+
+	unsigned short switchval[3];
+	unsigned short txrx[3];
+	unsigned short txendon[3];
+	unsigned short thresh[3];
+	unsigned short txendoff[3];
+	unsigned short txfrmctrl[3];
+	char adcsize[3];
+	char pgasize[3];
+	unsigned short noise_floor[3];
+=09
+	unsigned short xlna_gain[3];
+	unsigned short xgain[3];
+	unsigned short xpd[3];
+	unsigned short antctrl[11][3];
+	unsigned short detbkoff[3];
+	unsigned short igain[3];
+	unsigned short rxtx_epsilon[3]; /* error margin */
+
+=09
+	unsigned short g5_k1;
+	unsigned short g5_v1;
+	unsigned short g5_k2;
+	unsigned short g5_v2;
+	unsigned short g5_k3;
+	unsigned short g5_v3;
+	unsigned short g5_k4;
+	unsigned short g5_v4;
+
+	unsigned short g2_k1;
+	unsigned short g2_v1;
+	unsigned short g2_k2g;
+	unsigned short g2_v2g;
+	unsigned short g2_k3[2];
+	unsigned short g2_v3[2];
+=09
+	unsigned short count;
+	unsigned short controls[32];
+=09
+	unsigned short ical[2];
+	unsigned short qcal[2];
+=09
+	unsigned short cal11g[3];
+	unsigned short cal11b[3];
+
+
+	struct cal_info cal;
+
+	unsigned short num_ch5;
+	unsigned short ch_11a[10];
+	struct chan_data chans_11a[10];
+
+	unsigned short num_ch2;
+	unsigned short ch_11g[3];
+	unsigned short ch_11b[3];
+	struct chan_data chans_11g[3];
+	struct chan_data chans_11b[3];
+
+	struct power_modes pmodes;
+
+	struct eestrct rsomething[128];
+	struct chip_chan_pwr_data pvals[3];
+};
+
+unsigned int ath_eeprom_read(struct net_device *,
+		unsigned int x, unsigned int *);
+
+unsigned int ath_timed_read(struct net_device *,
+		unsigned int, unsigned int, unsigned int);
+
+unsigned int eeprom_read(struct net_device *,=20
+		unsigned int, unsigned int *);
+
+unsigned int eeprom_init(struct net_device *);
+
+unsigned int eeprom_read_mac(struct net_device *, unsigned char *);
+
+unsigned int eeprom_read_caps(struct net_device *);
+
+
+#endif
+


--KFztAG8eRSV9hGtP
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Kernel-mentors mailing list
Kernel-mentors@selenic.com
http://selenic.com/mailman/listinfo/kernel-mentors

--KFztAG8eRSV9hGtP--
