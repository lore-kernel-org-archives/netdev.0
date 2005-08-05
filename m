From: Mateusz Berezecki <mateuszb@gmail.com>
Subject: atheros driver (5/8)
Date: Fri, 05 Aug 2005 04:59:38 +0200
Message-ID: <42F2D61A.303@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080407030104090403010407"
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
--------------080407030104090403010407
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit



--------------080407030104090403010407
Content-Type: text/x-patch;
 name="atheros5212-5.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="atheros5212-5.patch"

diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/init.c netdev-atheros/drivers/net/wireless/atheros/atheros5212/init.c
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/init.c	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/init.c	2005-08-05 03:48:36.000000000 +0200
@@ -0,0 +1,788 @@
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
+ * rest of the code has been reversed by me are under copyright too... should they?:P
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
+#include "regops.h"
+#include "powermodes.h"
+#include "transmit_receive.h"
+#include "chans.h"
+
+struct net_device *atheros_card = NULL;
+
+unsigned int ath_radio(struct net_device *netdev)
+{
+	unsigned int ret = 0,val = 0;
+	unsigned int i;
+	
+	ath_reg_write(netdev, 0x9800 + (0x34 << 2), 0x1c16);
+	
+	for (i = 0; i < 8; i++)
+		ath_reg_write(netdev, 0x9800 + (0x20 << 2), 0x10000);
+
+	val = ath_reg_read(netdev, 0x9800 + (256 << 2));
+	val = (val >> 24) & 0xff;
+	val = (val & 0xf0) >> 4;
+	val |= ((val & 0x0f) << 4);
+	
+	for (i = 0; i < 8; i++) {
+		ret = (ret << 1) | (val & 1);
+		val = val >> 1;
+	}
+	
+	return ret;
+}
+
+unsigned int ath_selftest(struct net_device *netdev)
+{
+	unsigned int i, j;
+	unsigned int regs[2] = { 0x8000, 0x9800 + (8 << 2) };
+	unsigned int vals[2];
+	unsigned int values[4] = { 
+		0x55555555, 0xaaaaaaaa,
+		0x66666666, 0x99999999 
+	};
+	
+	for (i = 0; i < 2; i++) {
+		unsigned int addr = regs[i];
+		unsigned int wdata, rdata;
+		
+		vals[i] = ath_reg_read(netdev, addr);
+		
+		for (j = 0; j < 256; j++) {
+			wdata = (j << 16) | j;
+			ath_reg_write(netdev, addr, wdata);
+			rdata = ath_reg_read(netdev, addr);
+			if (wdata != rdata) {
+				printk(KERN_DEBUG"atheros:(%d) read %x exp. %x\n",
+					j, rdata, wdata);
+				return 0;
+			}
+		}
+
+		for (j = 0; j < 4; j++) {
+			unsigned int tmp;
+			ath_reg_write(netdev, regs[i], values[j]);
+			tmp = ath_reg_read(netdev, regs[i]);
+			if (values[j] != tmp) {
+				printk(KERN_DEBUG"atheros: 2nd loop\n");
+				return 0;
+			}
+		}
+		ath_reg_write(netdev, regs[i], vals[i]);
+	}
+	udelay(100);
+	return 1;
+}
+
+unsigned int ath_set_reset_register(struct net_device *netdev, 
+				    unsigned int rmask)
+{
+	unsigned int mask = rmask ? rmask : ~0;
+	unsigned int t;
+	
+	
+	ath_reg_read(netdev, 0x000c);
+	ath_reg_write(netdev, 0x4000, rmask);
+	udelay(15);
+
+	mask &= (0x0001 | 0x0002);
+	rmask &= (0x0001 | 0x0002);
+	t = ath_timed_read(netdev, 0x4000, mask, rmask);
+	
+	if ((rmask & 1) == 0) {
+		ath_reg_write(netdev, 0x14, 0);
+		if (!ath_set_power_mode(netdev, 2, 1, 0))
+			return t;
+		ath_reg_read(netdev, 0xc0);
+	}
+	return t;
+}
+
+unsigned int ath_prep_reset(struct net_device *netdev)
+{
+	return 1;
+}
+
+unsigned int ath_chip_reset(struct net_device *netdev, void *unused)
+{
+	
+	if (!ath_set_reset_register(netdev, 0x13)) {
+		printk(KERN_DEBUG"atheros: if 1 (warm reset)\n");
+		return 0;
+	}
+
+	if (!ath_set_power_mode(netdev, 2, 1, 0)) {
+		printk(KERN_DEBUG"atheros: if #2 (power mode)\n");
+		return 0;
+	}
+
+	if (!ath_set_reset_register(netdev, 0)) {
+		printk(KERN_DEBUG"atheros: if 3 (cold reset)\n");
+		return 0;
+	}
+
+	if (unused == NULL)
+		return 1;
+
+	return 0;
+}
+
+unsigned int ath_reset(struct net_device *netdev)
+{
+	return 0;
+}
+
+struct chip_gain_desc athgaindesc = {
+	.entrycnt = 9,
+	.defentry = 4,
+	.deltas[0] = { {4, 1, 1, 1, 0, 0, 0},  6, "FG8" },
+	.deltas[1] = { {4, 0, 1, 1, 0, 0, 0},  4, "FG7" },
+	.deltas[2] = { {3, 1, 1, 1, 0, 0, 0},  3, "FG6" },
+	.deltas[3] = { {4, 0, 0, 1, 0, 0, 0},  1, "FG5" },
+	.deltas[4] = { {4, 1, 1, 0, 0, 0, 0},  0, "FG4" },
+	.deltas[5] = { {4, 0, 1, 0, 0, 0, 0}, -2, "FG3" },
+	.deltas[6] = { {3, 1, 1, 0, 0, 0, 0}, -3, "FG2" },
+	.deltas[7] = { {4, 0, 0, 0, 0, 0, 0}, -4, "FG1" },
+	.deltas[8] = { {2, 1, 1, 0, 0, 0, 0}, -6, "FG0" },
+};
+
+struct chip_gain_desc ath5112gaindesc = {
+	.entrycnt = 8,
+	.defentry = 1,
+	.deltas[0] = { {3, 0, 0, 0, 0, 0, 0},  6, "FG7" },
+	.deltas[1] = { {2, 0, 0, 0, 0, 0, 0},  0, "FG6" },
+	.deltas[2] = { {1, 0, 0, 0, 0, 0, 0}, -3, "FG5" },
+	.deltas[3] = { {0, 0, 0, 0, 0, 0, 0},  0, "FG4" },
+	.deltas[4] = { {0, 1, 1, 0, 0, 0, 0}, -8, "FG3" },
+	.deltas[5] = { {0, 1, 1, 0, 1, 1, 0},-10, "FG2" },
+	.deltas[6] = { {0, 1, 0, 1, 1, 1, 0},-13, "FG1" },
+	.deltas[7] = { {0, 1, 0, 1, 1, 0, 1},-16, "FG0" },
+};
+ 
+void ath_init_gain(struct net_device *netdev)
+{
+	struct atheros_priv *p = ieee80211_priv(netdev);
+
+	if ((p->rev_5ghz & 0xf0) >= (0x10|0x20)) {
+		p->gaindesc.number = ath5112gaindesc.defentry;
+		p->gaindesc.delta = 
+			&ath5112gaindesc.deltas[ath5112gaindesc.defentry];
+		p->gaindesc.active = 1;
+		p->gaindesc.low = 20;
+		p->gaindesc.high = 85;
+	} else {
+		p->gaindesc.number = athgaindesc.defentry;
+		p->gaindesc.delta = 
+			&athgaindesc.deltas[athgaindesc.defentry];
+		p->gaindesc.active = 1;
+		p->gaindesc.low = 20;
+		p->gaindesc.high = 35;
+	}
+}
+
+unsigned int ath_alloc_rf(struct net_device *netdev)
+{
+	/*
+	struct atheros_priv *p = ieee80211_priv(netdev);
+	*/
+	return 1;
+}
+
+unsigned short chans11b[] = {
+	2412, 2447, 2484
+};
+
+unsigned short chans11g[] = {
+	2312, 2412, 2484
+};
+
+int ath_dev_attach(unsigned short devid, struct net_device *netdev)
+{
+	unsigned int val;
+	struct atheros_priv *pdata;
+	unsigned int i;
+
+	pdata = ieee80211_priv(netdev);
+
+	pdata->tpc = 16;
+	pdata->atim_win = 0;
+	pdata->cts = 4;
+	pdata->divctrl = 0;
+	pdata->iqcal = 0;
+	pdata->scaletpfactor = 0;
+	pdata->aifs = 2;
+	pdata->enableqos = 0;
+	pdata->swretry = 0;
+	pdata->hwtxtrycount = 10;
+	pdata->txlimit = 10;
+	pdata->beacon_interval = 100;
+	pdata->pwroverride = 0;
+	pdata->enable32clk = 0;
+
+	printk(KERN_DEBUG"atheros: devid is %x\n", devid);
+	
+	/* first, power on the device... */
+	if (!ath_set_power_mode(netdev, PMODE_AWAKE, 1, 0)) {
+		printk(KERN_DEBUG"atheros: failed to wake up the device\n");
+		return 0;
+	}
+	
+	/* ...reset the radio chip afterwards */	
+	if (!ath_chip_reset(netdev, NULL)) {
+		printk(KERN_DEBUG"atheros: failed to reset the chip\n");
+		return -1;
+	}
+	
+	pdata->mac_version = (ath_reg_read(netdev, 0x4020) & 0xff) >> 4;
+	pdata->mac_revision = ath_reg_read(netdev, 0x4020) & 0x0f;
+	
+	printk(KERN_DEBUG"atheros: mac version %d\n", pdata->mac_version);
+	printk(KERN_DEBUG"atheros: mac revision %d\n", pdata->mac_revision);
+	
+	if (pdata->mac_version != 5 || pdata->mac_revision < 2) {
+		printk(KERN_ERR"atheros: chip not supported\n");
+		return 0;
+	}
+
+	pdata->phy_revision = ath_reg_read(netdev, 0x9818);
+	
+	if (ath_selftest(netdev) == 0) {
+		printk(KERN_ERR"atheros: POST test failed!\n");
+		return 0;
+	}
+	
+	ath_reg_write(netdev, 0x9800, 0x00000007);
+	
+	pdata->rev_5ghz = ath_radio(netdev);
+	
+	/* XXX TODO: add some checks here fo chipset versioning */
+
+	printk(KERN_DEBUG"atheros: 2ghz radio revision %x\n",
+			pdata->rev_5ghz);
+
+	if (!eeprom_init(netdev)) {
+		printk(KERN_DEBUG"atheros: eeprom init failed!\n");
+		return 0;
+	}
+
+	/* ustawic kanaly i inne takie gadzety */
+	pdata->eeinfo.num_ch5 = 10;
+	pdata->eeinfo.num_ch2 = 3;
+	
+	for (i = 0; i < 10; i++)
+		pdata->eeinfo.chans_11a[i].count = 11;
+
+	for (i = 0; i < 3; i++) {
+		pdata->eeinfo.ch_11b[i] = chans11b[i];
+		pdata->eeinfo.ch_11g[i] = chans11g[i];
+		pdata->eeinfo.chans_11b[i].count = 3;
+		pdata->eeinfo.chans_11g[i].count = 3;
+	}
+
+
+	if (!eeprom_read_caps(netdev))
+		return 0;
+
+	if (pdata->eeinfo.mode_b && (pdata->rev_5ghz & 0xf0) == 0x10) {
+		unsigned int tmpval;
+		ath_reg_write(netdev, 0x9800, 0x00004007);
+		udelay(2000);
+		pdata->rev_2ghz = ath_radio(netdev);
+		ath_reg_write(netdev, 0x9800, 0x00000007);
+		udelay(2000);
+		
+		tmpval = pdata->rev_2ghz & 0xf0;
+		
+		if (tmpval != 0x20) {
+			return 0;
+		}
+	}
+	
+	printk(KERN_DEBUG"atheros: 5GHz radio revision %x\n",pdata->rev_2ghz);
+	eeprom_read(netdev, 0xbf, &val);
+	printk(KERN_DEBUG"atheros: regulatory domain -> %x(%d)\n",val, val);
+
+	pdata->domain = val;
+
+	ath_init_gain(netdev);
+	
+	if (!ath_alloc_rf(netdev)) {
+		return 0;
+	}
+
+	if (!eeprom_read_mac(netdev, pdata->mac)) {
+		printk(KERN_DEBUG"atheros: MAC reading failed\n");
+	}
+	printk(KERN_DEBUG"atheros: MAC is %x.%x.%x.%x.%x.%x\n",
+			pdata->mac[0],pdata->mac[1],pdata->mac[2],
+			pdata->mac[3],pdata->mac[4],pdata->mac[5]);
+	
+	return 1;	
+}
+
+int ath_attach(unsigned short devid, struct net_device *netdev)
+{
+	unsigned t, i;
+	struct atheros_priv *p = ieee80211_priv(netdev);
+	
+	if (!ath_dev_attach(devid, netdev))
+		return 0;
+
+	
+	t = ath_setup_xtx_desc(netdev, NULL, 0, 0, 0, 0, 0, 0);
+	p->mretry = t;
+	
+	if (ath_get_cap(netdev, CAP_PHYCOUNTERS, 0, NULL) == 0)
+		p->mib_enabled = 1;
+
+	p->keycache_size = ath_get_keycache_size(netdev);	
+
+	printk(KERN_DEBUG"atheros: resetting key cache\n");
+	for (i = 0; i < p->keycache_size; i++) {
+		ath_reset_keycache(netdev, i);
+	}
+
+	for (i = 0; i < 4; i++) {
+		p->keymap[i/8] |= 1 << (i % 8);
+		/*
+		set_bit(p->keymap, i);
+		set_bit(p->keymap, i+32);
+		set_bit(p->keymap, i+64);
+		set_bit(p->keymap, i+32+64);
+		*/
+	}
+
+	/* XXX this has to be finished yet. its quite complicated
+	 * how it works, etc. */
+	if (!ath_get_channels(netdev, 0, -1, -1))
+		return 0;
+
+	/* XXX rate setup here */
+	
+	ath_rate_setup(netdev, MODE_11A);
+	ath_rate_setup(netdev, MODE_11B);
+	ath_rate_setup(netdev, MODE_11G);
+	
+
+	/* XXX allocate descriptors here */
+	/*
+	if (!ath_desc_alloc(netdev)) {
+		return 0;
+	}
+	*/
+	p->beacon_q = ath_beacon_queue_setup(netdev);
+	if (p->beacon_q == (unsigned int) -1) {
+		printk(KERN_DEBUG"atheros: beacon queue setup failed\n");
+		return 0;
+	}
+	
+	p->cabq = ath_txq_setup(netdev, TX_QUEUE_CAB, 0);
+	if (p->cabq == NULL) {
+		printk(KERN_DEBUG"atheros: unable to setup CAB xmit queue!\n");
+		return 0;
+	}
+	
+	return 1;
+}
+
+int ath_init(struct net_device *netdev)
+{
+	struct atheros_priv *p = ieee80211_priv(netdev);
+	int opmode = 0, status = 0;
+	
+	ath_stop_locked(netdev);
+
+	/* XXX use the proper mode first. Where to get it from?*g* */
+	/*
+	ath_reset(netdev, opmode, chan, 0, &status);
+	*/
+	ath_update_txpow(netdev);
+
+	if (ath_startrecv(netdev) != 0) {
+		printk(KERN_DEBUG"atheros: cant init receieve\n");
+		return -1;
+	}
+
+	p->intr_mask = INT_RX | INT_TX | INT_RXEOL |
+		INT_RXORN | INT_FATAL | INT_GLOBAL;
+
+	ath_set_interruptmask(netdev, p->intr_mask);
+
+	netdev->flags |= IFF_RUNNING;
+	
+	return 1;
+}
+
+int ath_stop(struct net_device *netdev)
+{
+	struct atheros_priv *p = ieee80211_priv(netdev);
+	int error;
+	
+	error = ath_stop_locked(netdev);
+	
+	if (error == 0 && !p->invalid)
+		ath_set_power_mode(netdev, PMODE_FULL_SLEEP, 1, 0);
+	
+	return error;
+}
+
+int ath_stop_locked(struct net_device *netdev)
+{
+	struct atheros_priv *p = ieee80211_priv(netdev);
+
+	if (netdev->flags & IFF_RUNNING) {
+		netif_stop_queue(netdev);
+		netdev->flags &= ~IFF_RUNNING;
+		
+		if (!p->invalid) {
+			/* 
+			if (p->softled) {
+				del_timer(&p->ledtimer);
+				ath_gpioset(netdev, p->ledpin,
+						!p->ledon);
+				p->blinking = 0;
+			}
+			*/
+			ath_set_interruptmask(netdev, 0);
+		}
+		
+		ath_draintxq(netdev);
+		
+		if (!p->invalid) {
+			ath_stoprecv(netdev);
+			ath_phy_disable(netdev);
+		} else
+			p->rxlink = NULL;
+#ifdef NOT_YET
+		ath_beacon_free(netdev);
+#endif
+	}
+	
+	return 0;
+}
+
+void ath_mode_init(struct net_device *netdev)
+{
+}
+
+int ath_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	return -1;
+}
+
+struct net_device_stats *ath_getstats(struct net_device *netdev)
+{
+	struct atheros_priv *p = ieee80211_priv(netdev);
+
+	/* same note as below applies here too */
+	
+	return &p->devstats;
+}
+
+struct iw_statistics *ath_iw_getstats(struct net_device *netdev)
+{
+	/* returning stats from device.
+	 * thats not so correct but will do for testing.
+	 * in future versions use stats from associated
+	 * node */
+	struct atheros_priv *p = ieee80211_priv(netdev);
+
+	/* TODO: update stat counters here and return */
+	
+	return &p->stats;
+}
+
+int ath_set_mac_address(struct net_device *netdev, void *addr)
+{
+	int error;
+	struct atheros_priv *p;
+	struct sockaddr *mac = addr;
+
+	p = ieee80211_priv(netdev);
+	
+	if (netif_running(netdev)) {
+		printk(KERN_DEBUG"atheros: cannot set address; device running\n");
+		return -EBUSY;
+	}
+
+	memcpy(netdev->dev_addr, mac->sa_data, 6);
+	error = -ath_reset(netdev);
+	
+	return error;
+}
+
+int ath_change_mtu(struct net_device *netdev, int mtu)
+{
+	struct atheros_priv *p = ieee80211_priv(netdev);
+	int error;
+	
+	if (!(ATH_MIN_MTU < mtu && mtu <= ATH_MAX_MTU))
+		return -EINVAL;
+	
+	netdev->mtu = mtu;
+	tasklet_disable(&p->rxtq);
+	error = -ath_reset(netdev);
+	tasklet_enable(&p->rxtq);
+	
+	return error;
+}
+
+void ath_netdev_init(struct net_device *netdev)
+{
+	unsigned int size;
+	struct net_device *ieee = netdev_priv(netdev);
+		
+	printk(KERN_DEBUG"atheros pci: initializing netdevice\n");
+	
+	netdev->open = ath_init;
+	netdev->stop = ath_stop;
+	//netdev->hard_start_xmit = ath_hardstart;
+//	netdev->tx_timeout = ath_timeout;
+	netdev->watchdog_timeo = 5 * HZ;
+	netdev->set_multicast_list = ath_mode_init;
+	netdev->do_ioctl = ath_ioctl;
+	netdev->get_stats = ath_getstats;
+	netdev->set_mac_address = ath_set_mac_address;
+	netdev->change_mtu = ath_change_mtu;
+	netdev->tx_queue_len = ATHEROS_TXBUF-1;
+
+//	ieee->hard_start_xmit = ath_hardstart;
+	
+#ifdef CONFIG_NET_WIRELESS
+	netdev->get_wireless_stats = ath_iw_getstats;
+	netdev->wireless_handlers = &ath_iw_handler_def;
+
+#ifdef NOT_YET_BABE
+	/* just because it breaks stuff and its 2:13 am ;-P */
+	ath_iw_handler_def.private_args = 
+		(struct iw_priv_args *) ieee80211_priv_args;
+
+	ath_iw_handler_def.num_private_args = get_priv_size();
+#endif
+#endif
+}
+
+int ath_probe(struct pci_dev *dev, const struct pci_device_id *id)
+{
+	unsigned char cache_sz;
+	unsigned char timer;
+	unsigned int val;
+	struct net_device *netdev;
+	struct atheros_priv *priv;
+	unsigned long phy_mem, virt_mem;
+	
+	if (pci_enable_device(dev))
+		return (-EIO);
+
+	/* atheros chipsets support 32bit addressing mode */
+	if (pci_set_dma_mask(dev, 0xffffffff)) {
+		printk(KERN_ERR"atheros pci: couldn't set 32-bit DMA mode\n");
+		goto disable;
+	}
+	
+	pci_read_config_byte(dev, PCI_CACHE_LINE_SIZE, &cache_sz);
+
+	/* as madwifi source says rx buffer DMA will work if and only if
+	 * we have some alignment set up */
+	
+	if (cache_sz == 0) {
+		cache_sz = L1_CACHE_BYTES / sizeof(unsigned int);
+		pci_write_config_byte(dev, PCI_CACHE_LINE_SIZE, cache_sz);
+	}
+
+	pci_read_config_byte(dev, PCI_LATENCY_TIMER, &timer);
+	if (timer == 0) {
+		/* XXX: Tune this ... */
+		pci_write_config_byte(dev, PCI_LATENCY_TIMER, 0xff);
+	}
+
+	pci_set_master(dev);
+	pci_read_config_dword(dev, 0x40, &val);
+	pci_write_config_dword(dev, 0x40, val & 0xffff00ff);
+	
+	/* grab first memory region address */
+	phy_mem = pci_resource_start(dev, 0);
+
+	if (request_mem_region(phy_mem, pci_resource_len(dev, 0),
+				"atheros") == NULL) {
+		printk(KERN_ERR"atheros pci: couldn't get PCI memory\n");
+		goto disable;
+	}
+	
+	virt_mem = (unsigned long)ioremap(phy_mem,pci_resource_len(dev,0));
+	if (virt_mem == 0x00000000) {
+		printk(KERN_ERR"atheros pci: couldn't remap PCI memory\n");
+		goto release;
+	}
+	printk(KERN_DEBUG"atheros pci: Using IRQ : %d\n", dev->irq);
+	atheros_card = alloc_ieee80211(sizeof(struct atheros_priv));
+
+	ath_netdev_init(atheros_card);
+	atheros_card->irq = dev->irq;
+	atheros_card->mem_start = virt_mem;
+	atheros_card->mem_end = virt_mem + pci_resource_len(dev, 0);
+	printk(KERN_DEBUG"atheros pci: memory spans : %08lx-%08lx\n", 
+			atheros_card->mem_start, atheros_card->mem_end);
+	
+	
+	priv = ieee80211_priv(atheros_card);
+	priv->busdev = dev;
+
+	priv->invalid = 1;
+	
+	
+	SET_MODULE_OWNER(atheros_card);
+	SET_NETDEV_DEV(atheros_card, &dev->dev);
+	
+	printk(KERN_DEBUG"atheros pci: allocated atheros netdevice\n");
+
+	pci_set_drvdata(dev, atheros_card);
+	
+	if (request_irq(atheros_card->irq, 
+			ath_intr, SA_SHIRQ,
+			atheros_card->name,
+			atheros_card)) {
+		printk(KERN_ERR"atheros pci: IRQ request failed.\n");
+		goto netdev_free;
+	}
+
+	if (!ath_attach(id->device, atheros_card))
+		goto freeirq;
+
+
+	eeprom_read_mac(atheros_card, atheros_card->dev_addr);
+
+	if (register_netdev(atheros_card))
+		goto detach;
+
+	priv->invalid = 0;
+
+	return 0;
+
+detach:
+	ath_detach(atheros_card);
+freeirq:
+	free_irq(atheros_card->irq, dev);
+	
+netdev_free:
+	free_ieee80211(atheros_card);
+	atheros_card = NULL;
+
+mem_unmap:
+	iounmap((void *)virt_mem);
+release:
+	release_mem_region(phy_mem, pci_resource_len(dev, 0));
+disable:
+	pci_disable_device(dev);
+	return -ENODEV;
+}
+
+int ath_detach(struct net_device *netdev)
+{
+	struct atheros_priv *pdata = ieee80211_priv(netdev);
+	
+	printk(KERN_DEBUG"atheros pci: detaching\n");
+	
+	ath_stop(netdev);
+	pdata->invalid = 1;
+
+	unregister_netdev(netdev);
+
+	printk(KERN_DEBUG"atheros pci: detached.\n");
+	return 0;
+}
+
+
+void ath_remove(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	ath_detach(dev);
+	if (dev->irq)
+		free_irq(dev->irq, dev);
+
+	iounmap((void *)dev->mem_start);
+	release_mem_region(pci_resource_start(pdev, 0),
+			   pci_resource_len(pdev, 0));
+	pci_disable_device(pdev);
+	free_ieee80211(atheros_card);
+	atheros_card = NULL;
+}
+
+struct pci_device_id atheros_ids[] = {
+	{ PCI_DEVICE(PCI_VENDOR_ID_ATHEROS, ATHEROS_5212) },
+	{ 0 }
+};
+MODULE_DEVICE_TABLE(pci, atheros_ids);
+
+static struct pci_driver atheros5212_id = {
+	.name		=	"Atheros5212",
+	.id_table	=	atheros_ids,
+	.probe		=	ath_probe,
+	.remove		=	ath_remove,
+	.resume		=	NULL,
+	.suspend	=	NULL,
+};
+
+static int __init atheros_init()
+{
+	if (pci_register_driver(&atheros5212_id) != 0)
+		return -1;
+	return 0;
+}
+
+static void __exit atheros_exit()
+{
+	pci_unregister_driver(&atheros5212_id);
+	return;
+}
+
+module_init(atheros_init);
+module_exit(atheros_exit);
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Mateusz Berezecki");
diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/interrupts.c netdev-atheros/drivers/net/wireless/atheros/atheros5212/interrupts.c
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/interrupts.c	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/interrupts.c	2005-08-05 03:48:36.000000000 +0200
@@ -0,0 +1,171 @@
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
+#include "atheros_registers.h"
+#include "atheros.h"
+#include "eeprom.h"
+
+/* check if we got some interrupt pending signal from a device */
+int ath_int_pending(struct net_device *netdev)
+{
+	int val;
+
+	val = ath_reg_read(netdev, AR5212_INTPEND);
+
+	if (val == 1)
+		return 1;
+
+	return 0;
+}
+
+/* get type of pending interrupts from the device */
+int ath_get_pending_ints(struct net_device *netdev, int *imask)
+{
+	unsigned int val;
+
+	val = ath_reg_read(netdev, AR5212_RAC_PISR);
+	if (val == 0xffffffff) {
+		*imask = 0;
+		return 0;
+	}
+
+	*imask = val & INT_COMMON;
+
+	if (val & AR5212_PISR_HIUERR) { /* we got some fatal hw error */
+		*imask |= INT_FATAL;
+		return 0;
+	}
+	
+	if (val & (AR5212_PISR_RXOK|AR5212_PISR_RXERR)) {
+		*imask |= INT_RX;
+	}
+	
+	if (val & (AR5212_PISR_TXOK|AR5212_PISR_TXERR)) {
+		*imask |= INT_TX;
+	}
+
+	if (val & AR5212_PISR_RXORN) {
+		printk(KERN_DEBUG"atheros: receive overrun!\n");
+		*imask |= INT_FATAL;
+	}
+
+	return 1;
+}
+
+/* get current interrupt mask */
+unsigned int ath_get_interrupts(struct net_device *netdev)
+{
+	struct atheros_priv *p = ieee80211_priv(netdev);
+	return p->intr_mask;
+}
+
+/* set new interrupt mask. this is a bit counter-intuitive.
+ * the masked interrupts will BE actually delivered. */
+unsigned int ath_set_interruptmask(struct net_device *netdev,
+		unsigned int mask)
+{
+	struct atheros_priv *p = ieee80211_priv(netdev);
+	unsigned int tmp = p->intr_mask;
+	unsigned int val;
+	
+	if (tmp & INT_GLOBAL) {
+		ath_reg_write(netdev, AR5212_IER, AR5212_IER_DISABLE);
+		ath_reg_read(netdev, AR5212_IER);
+	}
+
+	val = mask & INT_COMMON;
+	if (mask & INT_TX)
+		val |= AR5212_PIMR_TXOK | 
+		       AR5212_PIMR_TXERR | 
+		       AR5212_PIMR_TXDESC;
+
+	if (mask & INT_RX) 
+		val |= AR5212_PIMR_RXOK |
+		       AR5212_PIMR_RXERR |
+		       AR5212_PIMR_RXDESC;
+
+	if (mask & INT_FATAL)
+		val |= AR5212_PISR_HIUERR;
+
+	ath_reg_write(netdev, AR5212_PIMR, val);
+	p->intr_mask = mask;
+	
+	if (mask & INT_GLOBAL) {
+		ath_reg_write(netdev, AR5212_IER, AR5212_IER_ENABLE);
+		ath_reg_read(netdev, AR5212_IER);
+	}
+
+	return tmp;
+}
+
+
+/* just standard interrupt handling stuff goes here */
+irqreturn_t ath_intr(int irq, void *dev_id, struct pt_regs *regs)
+{
+	struct net_device *netdev = (struct net_device *)dev_id;
+	struct atheros_priv *pdata = ieee80211_priv(netdev);
+	//INT status;
+	
+	if (pdata->invalid)
+		return IRQ_NONE;
+
+//	if (ath_intr_pending(netdev) == 0)
+//		return IRQ_NONE;
+
+//	if ((netdev->flags & (IFF_RUNNING | IFF_UP)) 
+//			!= (IFF_RUNNING | IFF_UP)) {
+//		ath_get_pendingIntr(netdev, &status);
+//		ath_set_intr(netdev, 0);
+//		return IRQ_HANDLED;
+//	}
+
+//	/* add support for different hardware interrupts */
+//	ath_get_pendingIntr(netdev, &status);
+//
+	return IRQ_NONE;
+}
+
+
+
diff -uprN -X 'netdev-2.6.git#ieee80211/Documentation/dontdiff' netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/interrupts.h netdev-atheros/drivers/net/wireless/atheros/atheros5212/interrupts.h
--- netdev-2.6.git#ieee80211/drivers/net/wireless/atheros/atheros5212/interrupts.h	1970-01-01 01:00:00.000000000 +0100
+++ netdev-atheros/drivers/net/wireless/atheros/atheros5212/interrupts.h	2005-08-05 03:48:36.000000000 +0200
@@ -0,0 +1,50 @@
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
+#ifndef _H_INT
+#define _H_INT
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
+extern irqreturn_t ath_intr(int, void *, struct pt_regs *);
+
+#endif
+


--------------080407030104090403010407
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Kernel-mentors mailing list
Kernel-mentors@selenic.com
http://selenic.com/mailman/listinfo/kernel-mentors

--------------080407030104090403010407--
