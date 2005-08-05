From: Mateusz Berezecki <mateuszb@gmail.com>
Subject: atheros driver (3/8)
Date: Fri, 05 Aug 2005 04:58:26 +0200
Message-ID: <42F2D5D2.8040105@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------050502070207070401080100"
Cc: netdev <netdev@vger.kernel.org>
Return-path: <kernel-mentors-bounces@selenic.com>
To: kernel-mentors@selenic.com
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

This is a multi-part message in MIME format.
--------------050502070207070401080100
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit



--------------050502070207070401080100
Content-Type: text/x-patch;
 name="atheros5212-3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="atheros5212-3.patch"

diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/beacons.c netdev-atheros/drivers/net/wireless/atheros/atheros5212/beacons.c
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/beacons.c	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/beacons.c	2005-08-05 03:48:36.000000000 +0200
@@ -0,0 +1,235 @@
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
+ * 
+ * rest of the code has been reversed by me and is under copyright too
+ * Copyright (C) 2005  Mateusz Berezecki
+ * 
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ * 
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
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
+
+
+
+
+void ath_beacon_init(struct net_device *netdev, unsigned int nextbtt,
+		unsigned int intval)
+{
+	struct atheros_priv *pdata = ieee80211_priv(netdev);
+	struct ieee80211_device *dev = netdev_priv(netdev);
+	unsigned int val;
+	
+	ath_reg_write(netdev, AR5212_TIMER0, nextbtt);
+
+	switch (dev->iw_mode) {
+		case IW_MODE_MONITOR:
+		case IW_MODE_INFRA:
+			ath_reg_write(netdev,
+				AR5212_TIMER1,
+				0xffff);
+			ath_reg_write(netdev,
+				AR5212_TIMER2, 
+				0x7ffff); 
+			break;
+			
+		case IW_MODE_ADHOC:
+			ath_reg_write(netdev,
+				AR5212_TIMER1, 
+				(nextbtt - 2) << 3);
+			ath_reg_write(netdev,
+				AR5212_TIMER2,
+				(nextbtt - 10) << 3);
+			break;
+			
+		default:
+			break;
+	}
+
+	ath_reg_write(netdev, AR5212_TIMER3, nextbtt + 
+		      (pdata->atim_win ? pdata->atim_win : 1));
+	
+	val = intval & 
+		(AR5212_BEACON_PERIOD | 
+		 AR5212_BEACON_RESET_TSF |
+		 AR5212_BEACON_ENABLE);
+	
+	if (val & AR5212_BEACON_RESET_TSF)
+		ath_reg_write(netdev, AR5212_BEACON, 
+				AR5212_BEACON_RESET_TSF); 
+	
+	ath_reg_write(netdev, AR5212_BEACON, val);
+}
+
+void ath_reset_station_btimers(struct net_device *netdev)
+{
+	int tmp;
+
+	ath_reg_write(netdev, AR5212_TIMER0, 0);
+	tmp = (ath_reg_read(netdev, AR5212_STA_ID1) 
+			| AR5212_STA_ID1_PWR_SV) & 
+			~(AR5212_STA_ID1_DEFAULT_ANTENNA |
+			AR5212_STA_ID1_PCF); 
+	
+	
+	ath_reg_write(netdev, AR5212_BEACON, 0xffff);
+	return;
+}
+
+void ath_set_station_btimers(struct net_device *netdev, 
+		struct beacon_state *state, unsigned int tsf,
+		unsigned int dtcx, unsigned int cfpcx)
+{
+	unsigned int tmp, dtimp, nextt;
+	unsigned int bintval;
+	
+	if (state->bs_cfpperiod) {
+		tmp = ath_reg_read(netdev, AR5212_STA_ID1);
+		tmp |= AR5212_STA_ID1_PCF;
+		
+		ath_reg_write(netdev, AR5212_STA_ID1, tmp);
+		
+		ath_reg_write(netdev, AR5212_CFP_PERIOD, 
+				state->bs_cfpperiod *
+				state->bs_dtimperiod * 
+				state->bs_intval);
+		
+		ath_reg_write(netdev, AR5212_CFP_DUR, 
+				state->bs_cfpmaxduration);
+		
+		ath_reg_write(netdev, AR5212_TIMER2, 
+			((tsf + 
+			((cfpcx * state->bs_dtimperiod + dtcx) *
+			 state->bs_intval))) << 3);
+	} else 
+		ath_reg_disable(netdev, 
+			AR5212_STA_ID1,
+			AR5212_STA_ID1_PCF);
+
+	
+	bintval = state->bs_intval;
+	
+	ath_reg_write(netdev, AR5212_TIMER0, state->bs_nexttbtt);
+
+	tmp = ath_reg_read(netdev, AR5212_BEACON) & 0xff800000;
+	tmp |= state->bs_intval & 0xffff;
+
+	if (state->bs_timoffset) {
+		tmp |= ((state->bs_timoffset + 4) << 16) & 0x7f0000;
+	} else {
+		tmp |= (4 << 16) & 0x7f0000;
+	}
+
+	ath_reg_write(netdev, AR5212_BEACON, tmp);
+
+	
+	if (state->bs_bmissthreshold <= (0xff00 >> 8)) {
+		BUG();
+		return;
+	}
+
+	tmp = ath_reg_read(netdev, AR5212_RSSI_THR) & (~0xff00);
+	tmp |= (state->bs_bmissthreshold << 8) & 0xff00;
+	ath_reg_write(netdev, AR5212_RSSI_THR, tmp);
+
+	
+	bintval = state->bs_intval;
+	if (bintval < state->bs_sleepduration)
+		bintval = state->bs_sleepduration;
+
+	
+	dtimp = state->bs_dtimperiod;
+	if (state->bs_sleepduration > dtimp)
+		dtimp = state->bs_sleepduration;
+
+	if (bintval == dtimp)
+		nextt = state->bs_nextdtim;
+	else 
+		nextt = state->bs_nexttbtt;
+
+	ath_reg_write(netdev, AR5212_SLEEP0, 
+	     ((state->bs_nextdtim - 3) & 0x7ffff) |
+	     ((10 << 24) & 0xff000000) |
+	     0x00080000 | 0x00100000);
+
+	ath_reg_write(netdev, AR5212_SLEEP1,
+	     ( ( (nextt - 3) << 3) & 0x7ffff) | 
+	     ((10 << 24) & 0xff000000));
+
+	ath_reg_write(netdev, AR5212_SLEEP2, 
+		(bintval & 0x0000ffff) | 
+		((dtimp << 16) & 0xffff0000));
+}
+
+
+unsigned int ath_wait_for_beacon_done(struct net_device *netdev)
+{
+	unsigned int i;
+
+	for (i = 0; i < 1000; i++) {
+/* XXX remove this comment
+ * 		if ( !ath_num_tx_pending(netdev, 2) )
+			break;
+*/
+		udelay(10);
+	}
+	
+	if (i < 1000)
+		return 1;
+
+	return 0;	
+}
+
+
+unsigned int ath_beacon_queue_setup(struct net_device *netdev)
+{
+	struct tx_queue_info qi;
+	memset(&qi, 0, sizeof(qi));
+
+	qi.tqi_aifs = 0xffffffff;
+	qi.tqi_cwmin = 0xffffffff;
+	qi.tqi_cwmax = 0xffffffff;
+	qi.tqi_qflags = 0x00000002;
+
+	return ath_setup_tx_queue(netdev, 2, &qi);
+}
+
diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/caps.c netdev-atheros/drivers/net/wireless/atheros/atheros5212/caps.c
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/caps.c	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/caps.c	2005-08-05 03:48:36.000000000 +0200
@@ -0,0 +1,176 @@
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
+ * 
+ * rest of the code has been reversed by me and is under copyright too
+ * Copyright (C) 2005  Mateusz Berezecki
+ * 
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ * 
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
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
+#include "atheros_registers.h"
+#include "atheros.h"
+#include "eeprom.h"
+#include "interrupts.h"
+
+
+unsigned int ath_get_ext_cap(struct net_device *netdev, CAPABILITY_TYPE type,
+			     unsigned int cap, unsigned int *result)
+{
+	switch (type) {
+		case CAP_REG_DMN:
+			*result = 0;
+			return 0;
+	
+		case CAP_KEYCACHE_SIZE:
+			*result = 0x80; /* FIXME this is a default for testing
+					   but we seriously need something better
+					   than a hardcoded value. reversing
+					   that part is quite hard though... :(
+					*/
+			return 0;
+			
+		case CAP_NUM_TXQUEUES:
+			return ENOTSUPP; /* FIXME */
+
+		case CAP_VEOL: /* FIXME */
+			return ENOTSUPP;
+
+		case CAP_COMPRESSION:
+		case CAP_BURST:
+		case CAP_FASTFRAME:
+		case CAP_DIAG:
+		case CAP_PSPOLL:
+			return ENOTSUPP; /* FIXME */
+
+		case CAP_TXPOW:
+			switch (cap) {
+				case 1:
+					/* FIXME */
+					break;
+
+				case 0:
+					return 0;
+
+				case 2:
+					break;
+
+				case 3:
+					break;
+					
+				default:
+					return ENOTSUPP;
+			}
+		
+		default:
+			return EINVAL;
+	}
+}
+
+
+unsigned int ath_get_cap(struct net_device *netdev, CAPABILITY_TYPE type, 
+		         unsigned int cap, unsigned int *result)
+{
+	struct atheros_priv *pdata = ieee80211_priv(netdev);
+
+	switch (type) {
+		case CAP_CIPHER:
+			switch (cap) {
+				case CIPHER_WEP:
+				case CIPHER_AES_OCB:
+					return 0; /* 5212 supports them */
+					
+				case CIPHER_AES_CCM:
+					return ENOTSUPP;
+					
+				case CIPHER_TKIP:
+				case CIPHER_CLR:
+				case CIPHER_MIC:
+					return 0;
+					
+				default:
+					return ENOTSUPP;
+			}
+			break;
+
+		case CAP_TKIP_MIC: /* hardware TKIP MIC ? */
+			/* if blablabla fix IT */
+			return ENOTSUPP; /* not supported for now */
+			
+		case CAP_TKIP_SPLIT: /* TKIP using split keys ? */
+			/* same as above. needs DOING :P */
+			return ENOTSUPP;
+
+		case CAP_PHYCOUNTERS:
+			if (pdata->disable_hw_counters == 0)
+				return 0;
+			return 1;
+
+		case CAP_DIVERSITY:
+			if (!cap) 
+				return 0;
+			
+			if (cap != 1) 
+				return EINVAL;
+
+			if ( (ath_reg_read(netdev, 0xa208) & 0x20) == 0 )
+				return ENXIO;
+			
+			return (ath_reg_read(netdev, 0xa208) & 0x20);
+			
+		case CAP_TPC: /* tx power control (per-packet) */
+			if (!cap)
+				return 0;
+
+			if (cap != 1)
+				return 0;
+		/*
+			if (0x196c+hal == 0)
+				return 1
+			return 0;
+		*/
+			return 0; /* just for now. it can break stuff but we don't care for a moment */	
+			
+		default:
+			return ath_get_ext_cap(netdev, type, cap, result);
+	}
+}
+
+
+
diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/caps.h netdev-atheros/drivers/net/wireless/atheros/atheros5212/caps.h
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/caps.h	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/caps.h	2005-08-05 03:48:36.000000000 +0200
@@ -0,0 +1,61 @@
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
+ * 
+ * rest of the code has been reversed by me and is under copyright too
+ * Copyright (C) 2005  Mateusz Berezecki
+ * 
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ * 
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
+ *
+ */
+
+#ifndef _CAPS_H
+#define _CAPS_H
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
+#include "atheros_registers.h"
+#include "atheros.h"
+#include "eeprom.h"
+#include "interrupts.h"
+
+unsigned int ath_get_cap(struct net_device *, CAPABILITY_TYPE, 
+		         unsigned int, unsigned int *);
+
+
+
+#endif
+
diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/chans.c netdev-atheros/drivers/net/wireless/atheros/atheros5212/chans.c
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/chans.c	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/chans.c	2005-08-05 03:48:36.000000000 +0200
@@ -0,0 +1,213 @@
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
+ * 
+ * rest of the code has been reversed by me and is under copyright too
+ * Copyright (C) 2005  Mateusz Berezecki
+ * 
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ * 
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
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
+#include "atheros_registers.h"
+#include "atheros.h"
+#include "eeprom.h"
+#include "interrupts.h"
+#include "chans.h"
+
+/* THIS IS A KILLER :/ */
+struct domain_table domains[] = {
+	{
+		.domain = WORLD0, 
+		.ahmodes = ADHOC_MODE_11A_DSUPPORT, 
+		.ahchans = NULL, 
+		.chancnt = 10,
+
+		.chans[0] = {
+			.mode = MODE_11A,
+			.freq = { 5260, 5280, 5300, 5320, 5180, 5200, 5220, 5240, 0 },
+		},
+		.chans[1] = {
+			.mode = MODE_11A,
+			.freq = { 5170, 5190, 5210, 5230, 0 },
+		},
+		.chans[2] = {
+			.mode = MODE_11B,
+			.freq = { 2412, 2437, 2462, 2442, 2472, 0 },
+		},
+		.chans[3] = {
+			.mode = MODE_11A,
+			.freq = { 5745, 5765, 5785, 5805, 5825, 0 },
+		},
+		.chans[4] = {
+			.mode = MODE_TURBO,
+			.freq = { 5210, 5250, 5290, 0 },
+		},
+		.chans[5] = {
+			.mode = MODE_TURBO,
+			.freq = { 5760, 5800, 0 },
+		},
+		.chans[6] = {
+			.mode = MODE_11A,
+			.freq = { 5500, 5520, 5540, 5560, 5580, 5600, 5620, 5640, 5660,5680, 5700, 0},
+		},
+		.chans[7] = {
+			.mode = MODE_11B,
+			.freq = { 2417, 2422, 2427, 2432, 2447, 2452, 2457, 2467, 0 },
+		},
+		.chans[8] = {
+			.mode = MODE_11B,
+			.freq = { 2484, 0 },
+		},
+		.chans[9] = {
+			.mode = MODE_108G,
+			.freq = { 2437, 0 },
+		},
+	}
+};
+
+/* just for now, we support one domain. MY DOMAIN :-) */
+#define DOMAIN_TABLE_SIZE	1
+
+unsigned int getdmn(struct net_device *netdev,
+		unsigned int *result, unsigned int *ix)
+{
+	struct atheros_priv *p = ieee80211_priv(netdev);
+	unsigned int d = p->domain;
+
+	if (d & 0x8000)
+		return 0;
+
+	printk(KERN_DEBUG"atheros: getdmn, SKU super domain\n");
+	d &= 0x0fff;
+	if (d != 0) {
+		unsigned int i;
+		for (i = 0; i < DOMAIN_TABLE_SIZE; i++) {
+			if (d == domains[i].domain) {
+				if (result != NULL)
+					*result = d;
+				if (ix != NULL)
+					*ix = i;
+				return 1;
+			}
+		}
+	}
+	return 0;
+}
+
+unsigned int ath_init_channels(struct net_device *netdev,
+		struct channel *ch, unsigned short max, unsigned int *nchans,
+		unsigned int country, unsigned short mode,
+		unsigned int outdoor, unsigned int extchan)
+{
+	struct atheros_priv *p = ieee80211_priv(netdev);
+
+	printk(KERN_DEBUG"atheros: calling getdmn with domain %x\n", country);
+	if (getdmn(netdev, NULL, NULL)) { 
+		printk(KERN_DEBUG"atheros: SKU common mode enabled\n");
+		p->common = 1;
+	}
+
+	if (p->domain & 0x4000) {
+		printk(KERN_DEBUG"atheros: we got roaming to set up\n");
+	}
+	
+	/* XXX */
+	return 1;
+}
+
+unsigned int ath_get_modes(struct net_device *netdev)
+{
+	struct atheros_priv *p = ieee80211_priv(netdev);
+	unsigned int mode = 0;
+	
+	if (p->eeinfo.mode_a) {
+		mode |= MODE_11A;
+		/* XXX ignore turbo for a while */
+	}
+
+	if (p->eeinfo.mode_b)
+		mode |= MODE_11B;
+
+	if (p->eeinfo.mode_g) {
+		mode |= MODE_11G;
+		/* XXX ignore turbo for a while */
+	}
+
+	return mode;
+}
+
+unsigned int ath_getwirelessmodes(struct net_device *netdev,
+		unsigned int country)
+{
+	unsigned int mode;
+
+	mode = ath_get_modes(netdev); /* wtf nonsense ;-) */
+	return mode;
+}
+
+unsigned int ath_get_channels(struct net_device *netdev,
+		unsigned int country, unsigned int outdoor,
+		unsigned int xchanmode)
+{
+	struct channel *chans;
+	unsigned int nchan;
+	unsigned int ix, i;
+	
+	chans = kmalloc(255 * sizeof(struct channel), GFP_KERNEL);
+
+	if (!chans) {
+		printk(KERN_ERR"atheros: no memory left!\n");
+		return 0;
+	}
+	
+	if (!ath_init_channels(netdev, chans, 255, &nchan, 0,
+				0xfff, outdoor, xchanmode)) {
+		printk(KERN_DEBUG"atheros: channel init failed\n");
+		kfree(chans);
+		return 0;
+	}
+
+	printk(KERN_DEBUG"atheros: nchan=%d\n", nchan);
+	for (i = 0; i < nchan; i++) {
+	}
+
+	//kfree(chans);
+	return 1;
+}
+
diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/chans.h netdev-atheros/drivers/net/wireless/atheros/atheros5212/chans.h
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/chans.h	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/chans.h	2005-08-05 03:48:36.000000000 +0200
@@ -0,0 +1,110 @@
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
+ * 
+ * rest of the code has been reversed by me and is under copyright too
+ * Copyright (C) 2005  Mateusz Berezecki
+ * 
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ * 
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
+ *
+ */
+
+enum {
+	ADHOC_MODE_11A_DISABLED,
+	ADHOC_MODE_11A_ENABLED,
+	ADHOC_MODE_11B_ENABLED,
+	ADHOC_MODE_11A_DSUPPORT,
+};
+
+enum {
+	MODE_11A = 1,
+	MODE_11B = 2,
+	MODE_11G = 3,
+	MODE_TURBO = 4,
+	MODE_108G = 5,
+};
+
+enum {
+	NO_ENUMRD	= 0x00,
+	CTRY_11B_ONLY	= 0x03,
+	CTRY_ISRAEL	= 0x07,
+	CTRY_ETSIC1	= 0x08,
+	CTRY_USA1	= 0x10,
+	CTRY_HONGKONG	= 0x11,
+	CTRY_CANADA	= 0x20,
+	CTRY_AUSTRALIA	= 0x21,
+	CTRY_ETSIC2	= 0x22,
+	CTRY_FRANCE	= 0x31,
+	CTRY_USA2	= 0x3A,
+	CTRY_WORLD1	= 0x37,
+	CTRY_FRANCE2	= 0x32,
+	CTRY_HUNGARY	= 0x35,
+	CTRY_FRANCE3	= 0x36,
+	CTRY_WORLD2	= 0x30,
+	CTRY_ETSIC2	= 0x38,
+	CTRY_WORLD3	= 0x39,
+	CTRY_BULGARIA	= 0x34,
+	CTRY_RESERVED	= 0x33,
+	CTRY_JAPAN1	= 0x40,
+	CTRY_JAPAN2	= 0x41,
+	CTRY_SINGAPORE	= 0x42,
+	CTRY_JAPAN3	= 0x43,
+	CTRY_RESERVED2	= 0x44,
+	CTRY_KOREA	= 0x45,
+	CTRY_UNK1	= 0x46,
+	CTRY_UNK2	= 0x47,
+	CTRY_JAPAN4	= 0x48,
+	CTRY_KOREA2	= 0x49,
+	CTRY_JAPAN5	= 0x4A,
+	CTRY_JAPAN6	= 0x4B,
+	CTRY_LATIN	= 0x52,
+	CTRY_UNK3	= 0x53,
+	CTRY_UNK4	= 0x54,
+	CTRY_UNK5	= 0x55,
+	CTRY_VENEZUELA	= 0x56,
+	CTRY_CHILE	= 0x58,
+	WORLD0	= 0x60,
+	WORLD1	= 0x61,
+	WORLD2	= 0x62,
+	WORLD3	= 0x63,
+	WORLD4  = 0x64,
+	WORLD5	= 0x65,
+	DEBUG_REG_DMN	= 0x01ff,
+};
+
+
+struct domain_table {
+	unsigned int domain;
+	unsigned int ahmodes;
+	unsigned short *ahchans;
+	
+	unsigned int chancnt;
+	struct {
+		unsigned short mode;
+		unsigned short freq[14];
+	} chans[10];
+};
+
+struct channel {
+	unsigned short flags;
+	unsigned short freq;
+};
+


--------------050502070207070401080100
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Kernel-mentors mailing list
Kernel-mentors@selenic.com
http://selenic.com/mailman/listinfo/kernel-mentors

--------------050502070207070401080100--
