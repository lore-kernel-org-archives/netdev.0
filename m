From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 10/13] bcm43xx: update to new d80211 driver API
Date: Sun, 19 Nov 2006 20:31:01 +0100
Message-ID: <1163964661.15473.59.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
	 <1163963898.15473.36.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:33718 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S933066AbWKSTdR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 14:33:17 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1163963898.15473.36.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Updates bcm43xx.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/Makefile	2006-11-19 20:12:47.459275208 +0100
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/Makefile	2006-11-19 20:14:01.189275208 +0100
@@ -7,6 +7,6 @@ bcm43xx-d80211-obj-$(CONFIG_BCM43XX_D802
 bcm43xx-d80211-objs := bcm43xx_main.o bcm43xx_ilt.o \
 		       bcm43xx_radio.o bcm43xx_phy.o \
 		       bcm43xx_power.o bcm43xx_sysfs.o \
-		       bcm43xx_leds.o bcm43xx_ethtool.o \
+		       bcm43xx_leds.o \
 		       bcm43xx_xmit.o \
 		       $(bcm43xx-d80211-obj-y)
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	2006-11-19 20:12:47.539275208 +0100
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx.h	2006-11-19 20:14:01.189275208 +0100
@@ -682,7 +682,6 @@ struct bcm43xx_private {
 	struct ieee80211_hw *ieee;
 	struct ieee80211_low_level_stats ieee_stats;
 
-	struct net_device *net_dev;
 	unsigned int irq;
 
 	spinlock_t irq_lock;
@@ -770,9 +769,9 @@ struct bcm43xx_private {
 
 
 static inline
-struct bcm43xx_private * bcm43xx_priv(struct net_device *dev)
+struct bcm43xx_private * bcm43xx_priv(struct ieee80211_hw *hw)
 {
-	return ieee80211_dev_hw_data(dev);
+	return hw->priv;
 }
 
 static inline
@@ -854,13 +853,7 @@ struct device;
 static inline
 struct bcm43xx_private * dev_to_bcm(struct device *dev)
 {
-	struct net_device *net_dev;
-	struct bcm43xx_private *bcm;
-
-	net_dev = dev_get_drvdata(dev);
-	bcm = bcm43xx_priv(net_dev);
-
-	return bcm;
+	return dev_get_drvdata(dev);
 }
 
 /* Is the device operating in a specified mode (IEEE80211_IF_TYPE_XXX). */
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c	2006-11-19 20:12:47.629275208 +0100
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c	2006-11-19 20:14:01.189275208 +0100
@@ -285,7 +285,7 @@ void bcm43xx_debugfs_add_device(struct b
 {
 	struct bcm43xx_dfsentry *e;
 	struct bcm43xx_txstatus_log *log;
-	char devdir[IFNAMSIZ];
+	char devdir[16];
 
 	assert(bcm);
 	e = kzalloc(sizeof(*e), GFP_KERNEL);
@@ -308,7 +308,7 @@ void bcm43xx_debugfs_add_device(struct b
 
 	bcm->dfsentry = e;
 
-	strncpy(devdir, bcm->net_dev->name, ARRAY_SIZE(devdir));
+	snprintf(devdir, sizeof(devdir), "wiphy%d", bcm->ieee->index);
 	e->subdir = debugfs_create_dir(devdir, fs.root);
 	e->dentry_tsf = debugfs_create_file("tsf", 0666, e->subdir,
 	                                    bcm, &tsf_fops);
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c	2006-11-19 20:12:47.709275208 +0100
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c	2006-11-19 20:14:01.199275208 +0100
@@ -525,7 +525,6 @@ static int setup_rx_descbuffer(struct bc
 				 ring->rx_buffersize, 0);
 	meta->skb = skb;
 	meta->dmaaddr = dmaaddr;
-	skb->dev = ring->bcm->net_dev;
 
 	ring->ops->fill_descriptor(ring, desc, dmaaddr,
 				   ring->rx_buffersize, 0, 0, 0);
@@ -1091,7 +1090,7 @@ int bcm43xx_dma_tx(struct bcm43xx_privat
 	ring->nr_tx_packets++;
 	if (free_slots(ring) < SLOTS_PER_PACKET) {
 		/* FIXME: we currently only have one queue */
-		ieee80211_stop_queue(bcm->net_dev, 0);
+		ieee80211_stop_queue(bcm->ieee, 0);
 		ring->stopped = 1;
 	}
 
@@ -1130,7 +1129,7 @@ void bcm43xx_dma_handle_txstatus(struct 
 			if (status->acked)
 				meta->txstat.flags |= IEEE80211_TX_STATUS_ACK;
 			meta->txstat.retry_count = status->frame_count - 1;
-			ieee80211_tx_status_irqsafe(bcm->net_dev, meta->skb, &(meta->txstat));
+			ieee80211_tx_status_irqsafe(bcm->ieee, meta->skb, &(meta->txstat));
 			/* skb is freed by ieee80211_tx_status_irqsafe() */
 		} else {
 			/* No need to call free_descriptor_buffer here, as
@@ -1151,7 +1150,7 @@ void bcm43xx_dma_handle_txstatus(struct 
 	if (ring->stopped) {
 		assert(free_slots(ring) >= SLOTS_PER_PACKET);
 		/* FIXME: we currently only have one queue */
-		ieee80211_wake_queue(bcm->net_dev, 0);
+		ieee80211_wake_queue(bcm->ieee, 0);
 		ring->stopped = 0;
 	}
 }
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_ethtool.c	2006-11-19 20:12:47.849275208 +0100
+++ /dev/null	1970-01-01 00:00:00.000000000 +0000
@@ -1,51 +0,0 @@
-/*
-
-  Broadcom BCM43xx wireless driver
-
-  ethtool support
-
-  Copyright (c) 2006 Jason Lunz <lunz@falooley.org>
-
-  Some code in this file is derived from the 8139too.c driver
-  Copyright (C) 2002 Jeff Garzik
-
-  This program is free software; you can redistribute it and/or modify
-  it under the terms of the GNU General Public License as published by
-  the Free Software Foundation; either version 2 of the License, or
-  (at your option) any later version.
-
-  This program is distributed in the hope that it will be useful,
-  but WITHOUT ANY WARRANTY; without even the implied warranty of
-  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-  GNU General Public License for more details.
-
-  You should have received a copy of the GNU General Public License
-  along with this program; see the file COPYING.  If not, write to
-  the Free Software Foundation, Inc., 51 Franklin Steet, Fifth Floor,
-  Boston, MA 02110-1301, USA.
-
-*/
-
-#include "bcm43xx.h"
-#include "bcm43xx_ethtool.h"
-
-#include <linux/netdevice.h>
-#include <linux/pci.h>
-#include <linux/string.h>
-#include <linux/version.h>
-#include <linux/utsrelease.h>
-
-
-static void bcm43xx_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
-{
-	struct bcm43xx_private *bcm = bcm43xx_priv(dev);
-
-	strncpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
-	strncpy(info->version, UTS_RELEASE, sizeof(info->version));
-	strncpy(info->bus_info, pci_name(bcm->ssb.pci_dev), ETHTOOL_BUSINFO_LEN);
-}
-
-struct ethtool_ops bcm43xx_ethtool_ops = {
-	.get_drvinfo = bcm43xx_get_drvinfo,
-	.get_link = ethtool_op_get_link,
-};
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_ethtool.h	2006-11-19 20:12:47.869275208 +0100
+++ /dev/null	1970-01-01 00:00:00.000000000 +0000
@@ -1,8 +0,0 @@
-#ifndef BCM43xx_ETHTOOL_H_
-#define BCM43xx_ETHTOOL_H_
-
-#include <linux/ethtool.h>
-
-extern struct ethtool_ops bcm43xx_ethtool_ops;
-
-#endif /* BCM43xx_ETHTOOL_H_ */
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-11-19 20:12:48.009275208 +0100
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c	2006-11-19 20:14:01.199275208 +0100
@@ -50,7 +50,6 @@
 #include "bcm43xx_pio.h"
 #include "bcm43xx_power.h"
 #include "bcm43xx_sysfs.h"
-#include "bcm43xx_ethtool.h"
 #include "bcm43xx_xmit.h"
 #include "bcm43xx_sysfs.h"
 
@@ -114,8 +113,8 @@ MODULE_PARM_DESC(fwpostfix, "Postfix for
 //#define DEBUG_ENABLE_PCILOG
 
 
-static int bcm43xx_net_stop(struct net_device *net_dev);
-static int bcm43xx_net_open(struct net_device *net_dev);
+static int bcm43xx_net_stop(struct ieee80211_hw *hw);
+static int bcm43xx_net_open(struct ieee80211_hw *hw);
 
 /* Detailed list maintained at:
  * http://openfacts.berlios.de/index-en.phtml?title=Bcm43xxDevices
@@ -2573,7 +2572,7 @@ static void bcm43xx_periodic_work_handle
 		/* Periodic work will take a long time, so we want it to
 		 * be preemtible.
 		 */
-		ieee80211_stop_queues(bcm->net_dev);
+		ieee80211_stop_queues(bcm->ieee);
 		spin_lock_irqsave(&bcm->irq_lock, flags);
 		bcm43xx_mac_suspend(bcm);
 		if (bcm43xx_using_pio(bcm))
@@ -2597,7 +2596,7 @@ static void bcm43xx_periodic_work_handle
 		if (bcm43xx_using_pio(bcm))
 			bcm43xx_pio_thaw_txqueues(bcm);
 		bcm43xx_mac_enable(bcm);
-		ieee80211_start_queues(bcm->net_dev);
+		ieee80211_start_queues(bcm->ieee);
 	}
 	mmiowb();
 	spin_unlock_irqrestore(&bcm->irq_lock, flags);
@@ -2848,19 +2847,19 @@ static void bcm43xx_chipset_detach(struc
 
 static void bcm43xx_free_modes(struct bcm43xx_private *bcm)
 {
-	struct ieee80211_hw *ieee = bcm->ieee;
+	struct ieee80211_hw *hw = bcm->ieee;
 	int i;
 
-	for (i = 0; i < ieee->num_modes; i++) {
-		kfree(ieee->modes[i].channels);
-		kfree(ieee->modes[i].rates);
+	for (i = 0; i < hw->num_modes; i++) {
+		kfree(hw->modes[i].channels);
+		kfree(hw->modes[i].rates);
 	}
-	kfree(ieee->modes);
-	ieee->modes = NULL;
-	ieee->num_modes = 0;
+	kfree(hw->modes);
+	hw->modes = NULL;
+	hw->num_modes = 0;
 }
 
-static int bcm43xx_append_mode(struct ieee80211_hw *ieee,
+static int bcm43xx_append_mode(struct ieee80211_hw *hw,
 			       int mode_id,
 			       int nr_channels,
 			       const struct ieee80211_channel *channels,
@@ -2872,7 +2871,7 @@ static int bcm43xx_append_mode(struct ie
 	struct ieee80211_hw_modes *mode;
 	int err = -ENOMEM;
 
-	mode = &(ieee->modes[ieee->num_modes]);
+	mode = &(hw->modes[hw->num_modes]);
 
 	mode->mode = mode_id;
 	mode->num_channels = nr_channels;
@@ -2893,7 +2892,7 @@ static int bcm43xx_append_mode(struct ie
 		       sizeof(*rates2) * nr_rates2);
 	}
 
-	ieee->num_modes++;
+	hw->num_modes++;
 	err = 0;
 out:
 	return err;
@@ -2906,17 +2905,17 @@ err_free_channels:
 static int bcm43xx_setup_modes(struct bcm43xx_private *bcm)
 {
 	int err = -ENOMEM;
-	struct ieee80211_hw *ieee = bcm->ieee;
+	struct ieee80211_hw *hw = bcm->ieee;
 	struct ssb_core *core;
 	struct bcm43xx_corepriv_80211 *wlpriv;
 	int i, nr_modes;
 
 	nr_modes = bcm->nr_80211_available;
-	ieee->modes = kzalloc(sizeof(*(ieee->modes)) * nr_modes,
+	hw->modes = kzalloc(sizeof(*(hw->modes)) * nr_modes,
 			      GFP_KERNEL);
-	if (!ieee->modes)
+	if (!hw->modes)
 		goto out;
-	ieee->num_modes = 0;
+	hw->num_modes = 0;
 
 	for (i = 0; i < bcm->nr_80211_available; i++) {
 		core = bcm->wlcores[i];
@@ -3117,7 +3116,7 @@ int bcm43xx_select_wireless_core(struct 
 		return -ESRCH; /* No such PHYTYPE on this board. */
 
 	/* Disable all network traffic. */
-	ieee80211_stop_queues(bcm->net_dev);
+	ieee80211_stop_queues(bcm->ieee);
 
 	if (bcm->wlcore) {
 		/* We already selected a wl core in the past.
@@ -3180,11 +3179,11 @@ bcm->wlcore = active_core;
 		goto error;
 
 	bcm43xx_macfilter_clear(bcm, BCM43xx_MACFILTER_ASSOC);
-	bcm43xx_macfilter_set(bcm, BCM43xx_MACFILTER_SELF, (u8 *)(bcm->net_dev->dev_addr));
+	bcm43xx_macfilter_set(bcm, BCM43xx_MACFILTER_SELF, (u8 *)(bcm->ieee->perm_addr));
 	bcm43xx_security_init(bcm);
 	bcm43xx_measure_channel_change_time(bcm);
-	ieee80211_update_hw(bcm->net_dev, bcm->ieee);
-	ieee80211_start_queues(bcm->net_dev);
+	ieee80211_update_hw(bcm->ieee);
+	ieee80211_start_queues(bcm->ieee);
 
 	/* Let's go! Be careful after enabling the IRQs.
 	 * Don't switch cores, for example.
@@ -3329,9 +3328,9 @@ static int bcm43xx_ssb_suspend(struct ss
 	int err;
 	struct bcm43xx_private *bcm = ssb_to_bcm43xx(ssb);
 
-	ieee80211_stop_queues(bcm->net_dev);
+	ieee80211_stop_queues(bcm->ieee);
 
-	err = bcm43xx_net_stop(bcm->net_dev);
+	err = bcm43xx_net_stop(bcm->ieee);
 	if (!err)
 		mutex_lock(&bcm->mutex);
 
@@ -3344,7 +3343,7 @@ static int bcm43xx_ssb_resume(struct ssb
 	struct bcm43xx_private *bcm = ssb_to_bcm43xx(ssb);
 
 	mutex_unlock(&bcm->mutex);
-	err = bcm43xx_net_open(bcm->net_dev);
+	err = bcm43xx_net_open(bcm->ieee);
 
 	return err;
 }
@@ -3352,7 +3351,6 @@ static int bcm43xx_ssb_resume(struct ssb
 static int bcm43xx_attach_board(struct bcm43xx_private *bcm,
 				struct pci_dev *pci_dev)
 {
-	struct net_device *net_dev = bcm->net_dev;
 	int err;
 	int i;
 	u32 coremask;
@@ -3376,7 +3374,6 @@ static int bcm43xx_attach_board(struct b
 		err = -EIO;
 		goto err_pci_release;
 	}
-	net_dev->base_addr = (unsigned long)mmio;
 
 	err = ssb_init(&bcm->ssb, pci_dev, mmio,
 		       bcm43xx_ssb_suspend,
@@ -3449,9 +3446,9 @@ bcm->wlcore = bcm->wlcores[i];
 
 	/* Set the MAC address in the networking subsystem */
 	if (is_valid_ether_addr(bcm->sprom.r1.et1mac))
-		memcpy(bcm->net_dev->dev_addr, bcm->sprom.r1.et1mac, 6);
+		memcpy(bcm->ieee->perm_addr, bcm->sprom.r1.et1mac, 6);
 	else
-		memcpy(bcm->net_dev->dev_addr, bcm->sprom.r1.il0mac, 6);
+		memcpy(bcm->ieee->perm_addr, bcm->sprom.r1.il0mac, 6);
 	bcm43xx_setup_modes(bcm);
 
 	assert(err == 0);
@@ -3478,12 +3475,12 @@ err_pci_disable:
 	goto out;
 }
 
-/* hard_start_xmit() callback in struct ieee80211_device */
-static int bcm43xx_net_hard_start_xmit(struct net_device *net_dev,
+/* hard_start_xmit() callback in struct ieee80211_ops */
+static int bcm43xx_net_hard_start_xmit(struct ieee80211_hw *hw,
 				       struct sk_buff *skb,
 				       struct ieee80211_tx_control *ctl)
 {
-	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
+	struct bcm43xx_private *bcm = bcm43xx_priv(hw);
 	int err = -ENODEV;
 	unsigned long flags;
 
@@ -3501,9 +3498,9 @@ static int bcm43xx_net_hard_start_xmit(s
 	return NETDEV_TX_OK;
 }
 
-static int bcm43xx_net_reset(struct net_device *net_dev)
+static int bcm43xx_net_reset(struct ieee80211_hw *hw)
 {
-	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
+	struct bcm43xx_private *bcm = bcm43xx_priv(hw);
 	unsigned long flags;
 
 	spin_lock_irqsave(&bcm->irq_lock, flags);
@@ -3513,10 +3510,10 @@ static int bcm43xx_net_reset(struct net_
 	return 0;
 }
 
-static int bcm43xx_net_config(struct net_device *net_dev,
+static int bcm43xx_net_config(struct ieee80211_hw *hw,
 			      struct ieee80211_conf *conf)
 {
-	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
+	struct bcm43xx_private *bcm = bcm43xx_priv(hw);
 	struct bcm43xx_radioinfo *radio;
 	struct bcm43xx_phyinfo *phy;
 	unsigned long flags;
@@ -3619,13 +3616,13 @@ out_unlock_mutex:
 	return err;
 }
 
-static int bcm43xx_net_set_key(struct net_device *net_dev,
+static int bcm43xx_net_set_key(struct ieee80211_hw *hw,
 			       set_key_cmd cmd,
 			       u8 *addr,
 			       struct ieee80211_key_conf *key,
 			       int aid)
 {
-	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
+	struct bcm43xx_private *bcm = bcm43xx_priv(hw);
 	unsigned long flags;
 	u8 algorithm;
 	u8 index;
@@ -3742,17 +3739,17 @@ out:
 	return err;
 }
 
-static int bcm43xx_net_conf_tx(struct net_device *net_dev,
+static int bcm43xx_net_conf_tx(struct ieee80211_hw *hw,
 			       int queue,
 			       const struct ieee80211_tx_queue_params *params)
 {
 	return 0;
 }
 
-static int bcm43xx_net_get_tx_stats(struct net_device *net_dev,
+static int bcm43xx_net_get_tx_stats(struct ieee80211_hw *hw,
 				    struct ieee80211_tx_queue_stats *stats)
 {
-	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
+	struct bcm43xx_private *bcm = bcm43xx_priv(hw);
 	unsigned long flags;
 	int err = -ENODEV;
 
@@ -3769,10 +3766,10 @@ static int bcm43xx_net_get_tx_stats(stru
 	return err;
 }
 
-static int bcm43xx_net_get_stats(struct net_device *net_dev,
+static int bcm43xx_net_get_stats(struct ieee80211_hw *hw,
 				 struct ieee80211_low_level_stats *stats)
 {
-	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
+	struct bcm43xx_private *bcm = bcm43xx_priv(hw);
 	unsigned long flags;
 
 	spin_lock_irqsave(&bcm->irq_lock, flags);
@@ -3782,29 +3779,16 @@ static int bcm43xx_net_get_stats(struct 
 	return 0;
 }
 
-#ifdef CONFIG_NET_POLL_CONTROLLER
-static void bcm43xx_net_poll_controller(struct net_device *net_dev)
+static int bcm43xx_net_open(struct ieee80211_hw *hw)
 {
-	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
-	unsigned long flags;
-
-	local_irq_save(flags);
-	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)
-		bcm43xx_interrupt_handler(bcm->irq, bcm);
-	local_irq_restore(flags);
-}
-#endif /* CONFIG_NET_POLL_CONTROLLER */
-
-static int bcm43xx_net_open(struct net_device *net_dev)
-{
-	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
+	struct bcm43xx_private *bcm = bcm43xx_priv(hw);
 
 	return bcm43xx_init_board(bcm);
 }
 
-static int bcm43xx_net_stop(struct net_device *net_dev)
+static int bcm43xx_net_stop(struct ieee80211_hw *hw)
 {
-	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
+	struct bcm43xx_private *bcm = bcm43xx_priv(hw);
 	int err;
 
 	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
@@ -3817,10 +3801,10 @@ static int bcm43xx_net_stop(struct net_d
 	return 0;
 }
 
-static int bcm43xx_add_interface(struct net_device *net_dev,
+static int bcm43xx_add_interface(struct ieee80211_hw *hw,
 				 struct ieee80211_if_init_conf *conf)
 {
-	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
+	struct bcm43xx_private *bcm = bcm43xx_priv(hw);
 	unsigned long flags;
 	int err = -EOPNOTSUPP;
 
@@ -3857,10 +3841,10 @@ out_unlock:
 	return err;
 }
 
-static void bcm43xx_remove_interface(struct net_device *net_dev,
+static void bcm43xx_remove_interface(struct ieee80211_hw *hw,
 				     struct ieee80211_if_init_conf *conf)
 {
-	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
+	struct bcm43xx_private *bcm = bcm43xx_priv(hw);
 	unsigned long flags;
 
 	mutex_lock(&bcm->mutex);
@@ -3882,11 +3866,11 @@ static void bcm43xx_remove_interface(str
 		MAC_ARG(conf->mac_addr));
 }
 
-static int bcm43xx_config_interface(struct net_device *net_dev,
+static int bcm43xx_config_interface(struct ieee80211_hw *hw,
 				    int if_id,
 				    struct ieee80211_if_conf *conf)
 {
-	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
+	struct bcm43xx_private *bcm = bcm43xx_priv(hw);
 	unsigned long flags;
 
 	mutex_lock(&bcm->mutex);
@@ -3907,11 +3891,11 @@ static int bcm43xx_config_interface(stru
 	return 0;
 }
 
-static void bcm43xx_set_multicast_list(struct net_device *net_dev,
+static void bcm43xx_set_multicast_list(struct ieee80211_hw *hw,
 				       unsigned short netflags,
 				       int mc_count)
 {
-	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
+	struct bcm43xx_private *bcm = bcm43xx_priv(hw);
 	unsigned long flags;
 
 	spin_lock_irqsave(&bcm->irq_lock, flags);
@@ -3923,22 +3907,11 @@ static void bcm43xx_set_multicast_list(s
 	spin_unlock_irqrestore(&bcm->irq_lock, flags);
 }
 
-/* Initialization of struct net_device, just after allocation. */
-static void bcm43xx_netdev_setup(struct net_device *net_dev)
-{
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	net_dev->poll_controller = bcm43xx_net_poll_controller;
-#endif
-	SET_ETHTOOL_OPS(net_dev, &bcm43xx_ethtool_ops);
-}
-
 static int bcm43xx_init_private(struct bcm43xx_private *bcm,
-				struct net_device *net_dev,
-				struct pci_dev *pci_dev,
-				struct ieee80211_hw *ieee)
+				struct ieee80211_hw *hw,
+				struct pci_dev *pci_dev)
 {
-	bcm->ieee = ieee;
-	bcm->net_dev = net_dev;
+	bcm->ieee = hw;
 	bcm->bad_frames_preempt = modparam_bad_frames_preempt;
 	spin_lock_init(&bcm->irq_lock);
 	spin_lock_init(&bcm->leds_lock);
@@ -3953,12 +3926,27 @@ static int bcm43xx_init_private(struct b
 	return 0;
 }
 
+static struct ieee80211_ops bcm43xx_hw_ops = {
+	.tx = bcm43xx_net_hard_start_xmit,
+	.open = bcm43xx_net_open,
+	.stop = bcm43xx_net_stop,
+	.add_interface = bcm43xx_add_interface,
+	.remove_interface = bcm43xx_remove_interface,
+	.reset = bcm43xx_net_reset,
+	.config = bcm43xx_net_config,
+	.config_interface = bcm43xx_config_interface,
+	.set_multicast_list = bcm43xx_set_multicast_list,
+	.set_key = bcm43xx_net_set_key,
+	.get_stats = bcm43xx_net_get_stats,
+	.get_tx_stats = bcm43xx_net_get_tx_stats,
+	.conf_tx = bcm43xx_net_conf_tx,
+};
+
 static int __devinit bcm43xx_init_one(struct pci_dev *pdev,
 				      const struct pci_device_id *ent)
 {
-	struct net_device *net_dev;
+	struct ieee80211_hw *hw;
 	struct bcm43xx_private *bcm;
-	struct ieee80211_hw *ieee;
 	int err = -ENOMEM;
 
 #ifdef DEBUG_SINGLE_DEVICE_ONLY
@@ -3966,52 +3954,36 @@ static int __devinit bcm43xx_init_one(st
 		return -ENODEV;
 #endif
 
-	ieee = kzalloc(sizeof(*ieee), GFP_KERNEL);
-	if (!ieee)
-		goto out;
-	ieee->version = IEEE80211_VERSION;
-	ieee->name = KBUILD_MODNAME;
-	ieee->flags = IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE |
-		      IEEE80211_HW_MONITOR_DURING_OPER |
-		      IEEE80211_HW_DEVICE_HIDES_WEP |
-		      IEEE80211_HW_WEP_INCLUDE_IV;
-	ieee->maxssi = BCM43xx_RX_MAX_SSI;
-	ieee->tx = bcm43xx_net_hard_start_xmit;
-	ieee->open = bcm43xx_net_open;
-	ieee->stop = bcm43xx_net_stop;
-	ieee->add_interface = bcm43xx_add_interface;
-	ieee->remove_interface = bcm43xx_remove_interface;
-	ieee->reset = bcm43xx_net_reset;
-	ieee->config = bcm43xx_net_config;
-	ieee->config_interface = bcm43xx_config_interface;
-	ieee->set_multicast_list = bcm43xx_set_multicast_list;
-	ieee->set_key = bcm43xx_net_set_key;
-	ieee->get_stats = bcm43xx_net_get_stats;
-	ieee->queues = 1;
-	ieee->get_tx_stats = bcm43xx_net_get_tx_stats;
-	ieee->conf_tx = bcm43xx_net_conf_tx;
-
-	net_dev = ieee80211_alloc_hw(sizeof(*bcm), bcm43xx_netdev_setup);
-	if (!net_dev) {
+	hw = ieee80211_alloc_hw(sizeof(*bcm), &bcm43xx_hw_ops);
+	if (!hw) {
 		printk(KERN_ERR PFX
 		       "could not allocate ieee80211 device %s\n",
 		       pci_name(pdev));
-		goto err_free_ieee;
+		return -ENOMEM;
 	}
+
+	/* fill hw info */
+	hw->flags = IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE |
+		       IEEE80211_HW_MONITOR_DURING_OPER |
+		       IEEE80211_HW_DEVICE_HIDES_WEP |
+		       IEEE80211_HW_WEP_INCLUDE_IV;
+	hw->maxssi = BCM43xx_RX_MAX_SSI;
+	hw->queues = 1;
+	hw->dev = &pdev->dev;
+
 	/* initialize the bcm43xx_private struct */
-	bcm = bcm43xx_priv(net_dev);
+	bcm = bcm43xx_priv(hw);
 	memset(bcm, 0, sizeof(*bcm));
-	err = bcm43xx_init_private(bcm, net_dev, pdev, ieee);
+	err = bcm43xx_init_private(bcm, hw, pdev);
 	if (err)
-		goto err_free_netdev;
+		goto err_free_hw;
 
-	pci_set_drvdata(pdev, net_dev);
-	SET_NETDEV_DEV(net_dev, &pdev->dev);
+	pci_set_drvdata(pdev, bcm);
 
 	err = bcm43xx_attach_board(bcm, pdev);
 	if (err)
-		goto err_free_netdev;
-	err = ieee80211_register_hw(net_dev, ieee);
+		goto err_free_hw;
+	err = ieee80211_register_hw(hw);
 	if (err)
 		goto err_detach_board;
 
@@ -4023,28 +3995,24 @@ out:
 
 err_detach_board:
 	bcm43xx_detach_board(bcm);
-err_free_netdev:
-	ieee80211_free_hw(net_dev);
-err_free_ieee:
-	kfree(ieee);
+err_free_hw:
+	ieee80211_free_hw(hw);
 	goto out;
 }
 
 static void __devexit bcm43xx_remove_one(struct pci_dev *pdev)
 {
-	struct net_device *net_dev = pci_get_drvdata(pdev);
-	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
-	struct ieee80211_hw *ieee = bcm->ieee;
+	struct bcm43xx_private *bcm = pci_get_drvdata(pdev);
+	struct ieee80211_hw *hw = bcm->ieee;
 
 	bcm43xx_debugfs_remove_device(bcm);
 
-	ieee80211_unregister_hw(net_dev);
+	ieee80211_unregister_hw(hw);
 	bcm43xx_detach_board(bcm);
 	if (bcm->cached_beacon)
 		kfree_skb(bcm->cached_beacon);
 	bcm->cached_beacon = NULL;
-	ieee80211_free_hw(net_dev);
-	kfree(ieee);
+	ieee80211_free_hw(hw);
 }
 
 /* Hard-reset the chip. Do not call this directly.
@@ -4088,13 +4056,12 @@ void bcm43xx_controller_restart(struct b
 
 static int bcm43xx_suspend(struct pci_dev *pdev, pm_message_t state)
 {
-	struct net_device *net_dev = pci_get_drvdata(pdev);
-	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
+	struct bcm43xx_private *bcm = pci_get_drvdata(pdev);
 	int err;
 
 	dprintk(KERN_INFO PFX "Suspending...\n");
 
-	ieee80211_stop_queues(bcm->net_dev);
+	ieee80211_stop_queues(bcm->ieee);
 	bcm->was_initialized = 0;
 	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
 		bcm->was_initialized = 1;
@@ -4120,8 +4087,7 @@ static int bcm43xx_suspend(struct pci_de
 
 static int bcm43xx_resume(struct pci_dev *pdev)
 {
-	struct net_device *net_dev = pci_get_drvdata(pdev);
-	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
+	struct bcm43xx_private *bcm = pci_get_drvdata(pdev);
 	int err;
 
 	dprintk(KERN_INFO PFX "Resuming...\n");
@@ -4139,7 +4105,7 @@ static int bcm43xx_resume(struct pci_dev
 		printk(KERN_ERR PFX "Resume failed!\n");
 		return err;
 	}
-	ieee80211_start_queues(bcm->net_dev);
+	ieee80211_start_queues(bcm->ieee);
 
 	dprintk(KERN_INFO PFX "Device resumed.\n");
 
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c	2006-11-19 20:12:48.039275208 +0100
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c	2006-11-19 20:14:01.209275208 +0100
@@ -503,7 +503,7 @@ void bcm43xx_pio_handle_txstatus(struct 
 	if (status->acked)
 		packet->txstat.flags |= IEEE80211_TX_STATUS_ACK;
 	packet->txstat.retry_count = status->frame_count - 1;
-	ieee80211_tx_status_irqsafe(bcm->net_dev, packet->skb,
+	ieee80211_tx_status_irqsafe(bcm->ieee, packet->skb,
 				    &(packet->txstat));
 	packet->skb = NULL;
 
--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c	2006-11-19 20:12:48.199275208 +0100
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c	2006-11-19 20:14:01.209275208 +0100
@@ -714,7 +714,7 @@ void bcm43xx_rx(struct bcm43xx_private *
 	}
 
 	bcm->stats.last_rx = jiffies;
-	ieee80211_rx_irqsafe(bcm->net_dev, skb, &status);
+	ieee80211_rx_irqsafe(bcm->ieee, skb, &status);
 }
 
 void bcm43xx_handle_txstatus(struct bcm43xx_private *bcm,


