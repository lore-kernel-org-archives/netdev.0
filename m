From: Mateusz Berezecki <mateuszb@gmail.com>
Subject: atheros driver (7/8)
Date: Fri, 05 Aug 2005 05:00:54 +0200
Message-ID: <42F2D666.2090602@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000705030305080808020607"
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
--------------000705030305080808020607
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit



--------------000705030305080808020607
Content-Type: text/x-patch;
 name="atheros5212-7.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="atheros5212-7.patch"

diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/keys.c netdev-atheros/drivers/net/wireless/atheros/atheros5212/keys.c
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/keys.c	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/keys.c	2005-08-05 03:48:36.000000000 +0200
@@ -0,0 +1,268 @@
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
+unsigned int ath_keycache_valid(struct net_device *netdev,
+		unsigned short entry)
+{
+	struct atheros_priv *pdata;
+	unsigned int val;
+	
+	pdata = ieee80211_priv(netdev);
+	
+	if (entry > pdata->max_keycache)
+		return 0;
+	
+	val = ath_reg_read(netdev, 0x8800 + entry * 32 + 28);
+
+	if (val & 0x8000)
+		return 1;
+	
+	return 0;
+}
+
+unsigned int ath_reset_keycache(struct net_device *netdev,
+		unsigned short entry)
+{
+	struct atheros_priv *pdata;
+	unsigned int keytype;
+	
+	pdata = ieee80211_priv(netdev);
+	
+	if (entry > pdata->keycache_size)
+		return 0;
+
+	keytype = ath_reg_read(netdev, (entry * 32) + 0x8814);
+
+	ath_reg_write(netdev, (entry * 32) + 0x8800, 0);
+	ath_reg_write(netdev, (entry * 32) + 0x8804, 0);
+	ath_reg_write(netdev, (entry * 32) + 0x8808, 0);
+	ath_reg_write(netdev, (entry * 32) + 0x880c, 0);
+	ath_reg_write(netdev, (entry * 32) + 0x8810, 0);
+	ath_reg_write(netdev, (entry * 32) + 0x8814, 7);
+	ath_reg_write(netdev, (entry * 32) + 0x8818, 0);
+	ath_reg_write(netdev, (entry * 32) + 0x881c, 0);
+	
+	if (keytype != 4)
+		return 1;
+
+	if (!pdata->ext_keycache)
+		return 1;
+
+	ath_reg_write(netdev, ((entry + 64) * 32) + 0x8800, 0);
+	ath_reg_write(netdev, ((entry + 64) * 32) + 0x8804, 0);
+	ath_reg_write(netdev, ((entry + 64) * 32) + 0x8808, 0);
+	ath_reg_write(netdev, ((entry + 64) * 32) + 0x880c, 0);
+
+	return 1;
+}
+
+unsigned int ath_set_keycache_entry_mac(struct net_device *netdev,
+		unsigned short entry, unsigned char *mac)
+{
+	struct atheros_priv *pdata;
+	unsigned int mac1, mac2;
+	
+	pdata = ieee80211_priv(netdev);
+
+	if (entry > pdata->max_keycache)
+		return 0;
+
+	if (mac == NULL) {
+		mac1 = 0;
+		mac2 = 0;
+	} else {
+		mac1  = mac[5] << 8;
+		mac1 |= mac[4];
+		
+		mac2  = mac[3] << 24;
+		mac2 |= mac[2] << 16;
+		mac2 |= mac[1] << 8;
+		mac2 |= mac[0];
+		
+		mac2 = mac2 >> 1;
+		mac2 |= ((mac1 & 1)<< 31);
+		
+		mac1 = mac1 >> 1;
+	}
+
+	ath_reg_write(netdev, (entry * 32) + 0x8800 + 24, mac2);
+	ath_reg_write(netdev, (entry * 32) + 0x8800 + 28, mac1 | 0x80);
+
+	return 1;
+}
+
+unsigned int ath_set_keycache_entry(struct net_device *netdev,
+		unsigned short entry, struct keyval *kv,
+		unsigned char *mac, int num)
+{
+	int flg = (num == 1) ? 0xffffffff : 0;
+	int cipher_opt;
+	int newentry;
+	struct atheros_priv *pdata = ieee80211_priv(netdev);
+	unsigned int part1, part2, part3, part4, part5;
+
+
+	flg &= 0xaaaaaaaa;
+
+	if (entry > pdata->max_keycache)
+		return 0;
+
+	switch (kv->kv_type) {
+		case CIPHER_AES_OCB:
+			cipher_opt = 5;
+			break;
+
+		case CIPHER_AES_CCM:
+			/* fixme TODO FIXME */
+			return 0;
+//			break;
+
+		case CIPHER_TKIP:
+			cipher_opt = 4;
+
+			if ((entry + 0x40) > pdata->max_keycache)
+				return 0;
+
+			break;
+
+		case CIPHER_WEP:
+			if (kv->kv_len <= 4)
+				return 0;
+			
+			cipher_opt = 0;
+
+			if (kv->kv_len <= 5) 
+				break;
+
+			cipher_opt = (kv->kv_len == 14) ? 0 : 0xffffffff;
+			cipher_opt &= 0xfffffffe;
+			cipher_opt += 3;
+
+			break;
+
+		case CIPHER_CLR:
+			cipher_opt = 7;
+			break;
+			
+		default:
+			return 0;
+	}
+
+	part1 = (kv->kv_val[0] | (kv->kv_val[1] << 8) | 
+		(kv->kv_val[2] << 16) | (kv->kv_val[3] << 24)) ^ flg;
+
+
+	part2 = ((kv->kv_val[4] | (kv->kv_val[5] << 8)) ^ flg) & 0xffff;
+	
+	part4 = ((kv->kv_val[6] | (kv->kv_val[7] << 8) |
+	  (kv->kv_val[8] << 16) | (kv->kv_val[9] << 24)) ^ flg);
+
+	part3 = ((kv->kv_val[10] | (kv->kv_val[11] << 8)) ^ flg) & 0xffff;
+
+	part5 = (kv->kv_val[12] | (kv->kv_val[13] << 8) | 
+	      (kv->kv_val[14] << 16) | (kv->kv_val[15] << 24)) ^ flg;
+
+	if (kv->kv_len <= 13)
+		 part5 &= 0xff;
+
+
+	/* if statement needs fixing */
+	if (cipher_opt == 4 && pdata->turbo != 0) {
+		newentry = (entry << 5);
+
+		ath_reg_write(netdev, 0x8800 + (entry << 5), ~part1);
+		ath_reg_write(netdev, 0x8804 + newentry,  ~part2);
+		ath_reg_write(netdev, 0x8808 + newentry, part4);
+		ath_reg_write(netdev, 0x880c + newentry, part3);
+		ath_reg_write(netdev, 0x8810 + newentry, part5);
+		ath_reg_write(netdev, 0x8814 + newentry, 4);
+
+		ath_set_keycache_entry_mac(netdev, entry, mac);
+
+		ath_reg_write(netdev, 0x8800 + ((entry + 0x40) << 5), 
+			(kv->kv_mic[0] | (kv->kv_mic[1] << 8) |
+			(kv->kv_mic[2] << 16) | (kv->kv_mic[3] << 24)));
+		
+		ath_reg_write(netdev, 0x8804 + ((entry + 0x40) << 5), 0);
+		
+		ath_reg_write(netdev, 0x8808 + ((entry + 0x40) << 5), 
+			( kv->kv_mic[4] | (kv->kv_mic[5] << 8) |
+			  (kv->kv_mic[6] << 16) | (kv->kv_mic[7] << 24) ) );
+		
+		ath_reg_write(netdev, 0x880c + ((entry + 0x40) << 5), 0);
+		ath_reg_write(netdev, 0x8810 + ((entry + 0x40) << 5), 0);
+		ath_reg_write(netdev, 0x8814 + ((entry + 0x40) << 5), 7);
+		ath_reg_write(netdev, 0x8818 + ((entry + 0x40) << 5), 0);
+		ath_reg_write(netdev, 0x881c + ((entry + 0x40) << 5), 0);
+		
+		ath_reg_write(netdev, 0x8800 + newentry, part1);
+		ath_reg_write(netdev, 0x8800 + newentry, part2);
+
+		return 1;
+	} else {
+		ath_reg_write(netdev, 0x8800 + (entry << 5), part1);
+		ath_reg_write(netdev, 0x8804 + (entry << 5), part2);
+		ath_reg_write(netdev, 0x8808 + (entry << 5), part4);
+		ath_reg_write(netdev, 0x880c + (entry << 5), part3);
+		ath_reg_write(netdev, 0x8810 + (entry << 5), part5);
+		ath_reg_write(netdev, 0x8814 + (entry << 5), cipher_opt);
+
+		ath_set_keycache_entry_mac(netdev, entry, mac);
+		return 1;
+	}
+		
+	return 0;
+}
+unsigned int ath_get_keycache_size(struct net_device *netdev)
+{
+	return 128;
+}
+
diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/mode_tables.c netdev-atheros/drivers/net/wireless/atheros/atheros5212/mode_tables.c
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/mode_tables.c	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/mode_tables.c	2005-08-05 03:48:36.000000000 +0200
@@ -0,0 +1,309 @@
+/*
+ * All the work was created by reverse engineering and porting
+ * for interoperability. The creator is Mateusz Berezecki,
+ * unless explicitly marked ( some parts are derived
+ * from GPL'ed parts of madwifi project located at http://madwifi.sf.net)
+ *
+ * the original binary and source code created by
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
+#include "mode_tables.h"
+#include "chans.h"
+#include "atheros_defs.h"
+#include "atheros.h"
+#include "atheros_dev.h"
+
+
+/*
+ * ripping it out from madwifi is ... @#*$&@#&@%#$*$@# HARD!!! 
+ */
+
+struct rate_table mode_a = {
+	.rate_count	=	8,
+        .code_to_idx    =       {
+		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
+		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
+	},
+	.info[0]	=	{		/* 6 MB */
+		.valid		=	1,
+		.phy		=	IEEE80211_OFDM_MODULATION,
+		.rateKbps	=	6000,
+		.rateCode	=	11,
+		.shortPreamble	=	0,
+		.dot11Rate	=	(12 | 0x80),
+		.controlRate	=	0,
+		.lpAckDuration	=	0,
+		.spAckDuration	=	0,
+	},
+	.info[1]	=	{		/* 9 MB */
+		.valid		=	1,
+		.phy		=	IEEE80211_OFDM_MODULATION,
+		.rateKbps	=	9000,
+		.rateCode	=	15,
+		.shortPreamble	=	0,
+		.dot11Rate	=	18,
+		.controlRate	=	0,
+		.lpAckDuration	=	0,
+		.spAckDuration	=	0,
+	},
+	.info[2]	=	{		/* 12 MB */
+		.valid		=	1,
+		.phy		=	IEEE80211_OFDM_MODULATION,
+		.rateKbps	=	12000,
+		.rateCode	=	10,
+		.shortPreamble	=	0,
+		.dot11Rate	=	(0x80|24),
+		.controlRate	=	2,
+		.lpAckDuration	=	0,
+		.spAckDuration	=	0,
+	},
+	.info[3]	=	{		/* 18 MB */
+		.valid		=	1,
+		.phy		=	IEEE80211_OFDM_MODULATION,
+		.rateKbps	=	18000,
+		.rateCode	=	14,
+		.shortPreamble	=	0,
+		.dot11Rate	=	36,
+		.controlRate	=	2,
+		.lpAckDuration	=	0,
+		.spAckDuration	=	0,
+	},
+	.info[4]	=	{		/* 24 MB */
+		.valid		=	1,
+		.phy		=	IEEE80211_OFDM_MODULATION,
+		.rateKbps	=	24000,
+		.rateCode	=	9,
+		.shortPreamble	=	0,
+		.dot11Rate	=	(0x80|48),
+		.controlRate	=	4,
+		.lpAckDuration	=	0,
+		.spAckDuration	=	0,
+	},
+	.info[5]	=	{		/* 36 MB */
+		.valid		=	1,
+		.phy		=	IEEE80211_OFDM_MODULATION,
+		.rateKbps	=	36000,
+		.rateCode	=	13,
+		.shortPreamble	=	0,
+		.dot11Rate	=	72,
+		.controlRate	=	4,
+		.lpAckDuration	=	0,
+		.spAckDuration	=	0,
+	},
+	.info[6]	=	{		/* 48 MB */
+		.valid		=	1,
+		.phy		=	IEEE80211_OFDM_MODULATION,
+		.rateKbps	=	48000,
+		.rateCode	=	8,
+		.shortPreamble	=	0,
+		.dot11Rate	=	96,
+		.controlRate	=	4,
+		.lpAckDuration	=	0,
+		.spAckDuration	=	0,
+	},
+	.info[7]	=	{
+		.valid		=	1,	/* 54 MB */
+		.phy		=	IEEE80211_OFDM_MODULATION,
+		.rateKbps	=	54000,
+		.rateCode	=	12,
+		.shortPreamble	=	0,
+		.dot11Rate	=	108,
+		.controlRate	=	4,
+		.lpAckDuration	=	0,
+		.spAckDuration	=	0,
+	},
+};
+
+struct rate_table mode_b = {
+	.rate_count     =       4,		/* +0 */
+	.code_to_idx    =       {		/* +4 */
+		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
+		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
+	},
+	.info[0]	=	{		/* +32 */
+		.valid		=	1,	/* 0 - 1 */
+		.phy		=	0,	/* 1 - 2 */
+		.rateKbps	=	1000,	/* 2 - 4 */
+		.rateCode	=	27,	/* 4 - 5 */
+		.shortPreamble	=	0,	/* 5 - 6 */    /* 12 bytes */
+		.dot11Rate	=	130,	/* 6 - 7 */
+		.controlRate	=	0,	/* 7 - 8 */
+		.lpAckDuration	=	0,	/* 8 - 10 */
+		.spAckDuration	=	0,	/* 10 - 12 */
+	},
+	.info[1]	=	{
+		.valid		=	1,
+		.phy            =       0,
+		.rateKbps       =       2000,	/* 2 MBps */
+		.rateCode       =       26,
+		.shortPreamble  =       4,
+		.dot11Rate      =       132,
+		.controlRate    =       1,
+		.lpAckDuration  =       0,
+		.spAckDuration  =       0,
+	},
+	.info[2]	=	{
+		.valid		=	1,
+		.phy		=	0,
+		.rateKbps	=	5500,	/* 5.5 MBps */
+		.rateCode	=	25,
+		.shortPreamble	=	4,
+		.dot11Rate	=	139,
+		.controlRate	=	1,
+		.lpAckDuration 	=	0,
+		.spAckDuration	=	0,
+	},
+	.info[3]	=	{
+		.valid		=	1,
+		.phy		=	0,
+		.rateKbps	=	11000,	/* 11 MBps */
+		.rateCode	=	24,
+		.shortPreamble	=	4,
+		.dot11Rate	=	150,
+		.controlRate	=	1,
+		.lpAckDuration	=	0,
+		.spAckDuration	=	0
+	},
+};
+
+
+struct rate_table mode_g = {
+	.rate_count		=	12,
+	.code_to_idx		=	{ 0 },
+	.info[0]		=	{ 1, IEEE80211_CCK_MODULATION,     1000, 0x1b, 0,  2, 0 },
+	.info[1]		=	{ 1, IEEE80211_CCK_MODULATION,     2000, 0x1a, 4,  4, 1 },
+	.info[2]		=	{ 1, IEEE80211_CCK_MODULATION,     5500, 0x19, 4, 11, 1 },
+	.info[3]		=	{ 1, IEEE80211_CCK_MODULATION,    11000, 0x18, 4, 22, 1 },
+	.info[4]		=	{ 0, IEEE80211_OFDM_MODULATION,   6000, 0x0b, 0, 12, 4 },
+	.info[5] 		=	{ 0, IEEE80211_OFDM_MODULATION,   9000, 0x0f, 0, 18, 4 },
+	.info[6]		=	{ 1, IEEE80211_OFDM_MODULATION,  12000, 0x0a, 0, 24, 6 },
+	.info[7]		=	{ 1, IEEE80211_OFDM_MODULATION,  18000, 0x0e, 0, 36, 6 },
+	.info[8]		=	{ 1, IEEE80211_OFDM_MODULATION,  24000, 0x09, 0, 48, 8 },
+	.info[9]		=	{ 1, IEEE80211_OFDM_MODULATION,  36000, 0x0d, 0, 72, 8 },
+	.info[10]		=	{ 1, IEEE80211_OFDM_MODULATION,  48000, 0x08, 0, 96, 8 },
+	.info[11]		=	{ 1, IEEE80211_OFDM_MODULATION,  54000, 0x0c, 0,108, 8 },
+};
+
+
+/* TODO: add Atheros eXtended Range rate table and also turbo g rates */
+
+
+struct rate_table *ath_get_rates(struct net_device *netdev, unsigned int mode)
+{
+	struct rate_table *rates = NULL;
+		
+	switch (mode) {
+		case MODE_11A:
+			rates = &mode_a;
+			break;
+		case MODE_11B:
+			rates = &mode_b;
+			break;
+		case MODE_11G:
+			rates = &mode_g;
+
+		default:
+			printk(KERN_DEBUG"atheros: unsupported rate\n");
+			return NULL;
+	}
+
+	ath_setup_rates(netdev, rates);
+	return rates;	
+}
+
+void ath_setup_rates(struct net_device *netdev,struct rate_table  *r)
+{
+	int i;
+	
+	if (r->code_to_idx[0] != 0)
+		return;
+	
+	for (i = 0; i < 32; i++)
+		r->code_to_idx[i] = 0xff;
+	
+	for (i = 0; i < r->rate_count; i++) {
+		unsigned char code = r->info[i].rateCode;
+		r->code_to_idx[code] = i;
+		r->code_to_idx[code | r->info[i].shortPreamble] = i;
+	}
+}
+
+int ath_rate_setup(struct net_device *netdev, unsigned int mode)
+{
+	struct atheros_priv *p = ieee80211_priv(netdev);
+	struct rate_table *rt;
+	int i, maxrates;
+	
+	switch (mode) {
+		case MODE_11A:
+			p->rates[mode] = ath_get_rates(netdev, MODE_11A);
+			break;
+		case MODE_11B:
+			printk(KERN_DEBUG"MODE 802.11B\n");
+			p->rates[mode] = ath_get_rates(netdev, MODE_11B);
+			break;
+			
+		case MODE_11G:
+			p->rates[mode] = ath_get_rates(netdev, MODE_11G);
+			break;
+	/*
+		case IEEE80211_MODE_TURBO_A:
+			p->rates[mode] = ath_getratetable(netdev, HAL_MODE_TURBO);
+			break;
+		case IEEE80211_MODE_TURBO_G: 
+			p->rates[mode] = ath_getratetable(netdev, HAL_MODE_108G);
+			break; */
+		default:
+			return 0;
+	}
+	rt = p->rates[mode];
+	
+	if (rt == NULL)
+		return 0; 
+	
+	if (rt->rate_count > IEEE80211_RATE_MAXSIZE) {
+		maxrates = IEEE80211_RATE_MAXSIZE;
+	} else  
+		maxrates = rt->rate_count;
+	/*
+	rs = &ic->ic_sup_rates[mode];
+	for (i = 0; i < maxrates; i++)
+		rs->rs_rates[i] = rt->info[i].dot11Rate;
+	rs->rs_nrates = maxrates;
+	*/
+	return 1;
+}
+
diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/mode_tables.h netdev-atheros/drivers/net/wireless/atheros/atheros5212/mode_tables.h
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/mode_tables.h	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/mode_tables.h	2005-08-05 03:48:36.000000000 +0200
@@ -0,0 +1,60 @@
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
+
+#ifndef _MODE_TABLES_H
+#define _MODE_TABLES_H
+
+struct rate_info {
+	unsigned char        valid;
+	unsigned char        phy;
+	unsigned short       rateKbps;
+	unsigned char        rateCode;
+	unsigned char        shortPreamble;
+	unsigned char        dot11Rate;
+	unsigned char        controlRate;
+	unsigned short       lpAckDuration;
+	unsigned short       spAckDuration;
+};
+
+struct rate_table {
+	int              rate_count;
+	unsigned char    code_to_idx[32];    /* back mapping */
+	struct rate_info info[32];
+};
+
+extern struct rate_table mode_a;
+extern struct rate_table mode_b;
+
+void ath_setup_rates(struct net_device *,struct rate_table *);
+struct rate_table *ath_get_rates(struct net_device *, unsigned int);
+int ath_rate_setup(struct net_device *, unsigned int);
+#endif
+
+


--------------000705030305080808020607
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Kernel-mentors mailing list
Kernel-mentors@selenic.com
http://selenic.com/mailman/listinfo/kernel-mentors

--------------000705030305080808020607--
