From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 2/13] d80211: reduce mdev usage
Date: Sun, 19 Nov 2006 20:23:02 +0100
Message-ID: <1163964182.15473.41.camel@johannes.berg>
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
Received: from crystal.sipsolutions.net ([195.210.38.204]:53642 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S933058AbWKSTYr
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 14:24:47 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1163963898.15473.36.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch reduces mdev usage by replacing struct net_device *
arguments that are never used except for dereferencing to get
struct ieee80211_local from ieee80211_ptr by struct
ieee80211_local directly.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/ieee80211.c	2006-11-19 20:13:51.869275208 +0100
+++ wireless-dev/net/d80211/ieee80211.c	2006-11-19 20:13:55.359275208 +0100
@@ -130,9 +130,8 @@ static int rate_list_match(int *rate_lis
 }
 
 
-void ieee80211_prepare_rates(struct net_device *dev)
+void ieee80211_prepare_rates(struct ieee80211_local *local)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
 	int i;
 
 	for (i = 0; i < local->num_curr_rates; i++) {
@@ -1905,9 +1904,8 @@ int ieee80211_if_config_beacon(struct ne
 	return __ieee80211_if_config(dev, skb);
 }
 
-int ieee80211_hw_config(struct net_device *dev)
+int ieee80211_hw_config(struct ieee80211_local *local)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
 	int i, ret = 0;
 
 #ifdef CONFIG_D80211_VERBOSE_DEBUG
@@ -1917,7 +1915,7 @@ int ieee80211_hw_config(struct net_devic
 #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 
 	if (local->hw->config)
-		ret = local->hw->config(dev, &local->conf);
+		ret = local->hw->config(local->mdev, &local->conf);
 
 	for (i = 0; i < local->hw->num_modes; i++) {
 		struct ieee80211_hw_modes *mode = &local->hw->modes[i];
@@ -1927,7 +1925,7 @@ int ieee80211_hw_config(struct net_devic
 			}
 			local->curr_rates = mode->rates;
 			local->num_curr_rates = mode->num_rates;
-			ieee80211_prepare_rates(dev);
+			ieee80211_prepare_rates(local);
 			break;
 		}
 	}
@@ -4251,16 +4249,6 @@ int ieee80211_if_update_wds(struct net_d
 	return 0;
 }
 
-
-static void ieee80211_if_init(struct net_device *dev)
-{
-	struct ieee80211_local *local = dev->ieee80211_ptr;
-
-        spin_lock_init(&local->sub_if_lock);
-        INIT_LIST_HEAD(&local->sub_if_list);
-}
-
-
 /* Must not be called for mdev and apdev */
 void ieee80211_if_setup(struct net_device *dev)
 {
@@ -4424,6 +4412,9 @@ struct net_device *ieee80211_alloc_hw(si
 
         init_timer(&local->scan.timer); /* clear it out */
 
+	spin_lock_init(&local->sub_if_lock);
+	INIT_LIST_HEAD(&local->sub_if_list);
+
         spin_lock_init(&local->generic_lock);
 	init_timer(&local->stat_timer);
 	local->stat_timer.function = ieee80211_stat_refresh;
@@ -4432,8 +4423,6 @@ struct net_device *ieee80211_alloc_hw(si
 
         sta_info_init(local);
 
-        ieee80211_if_init(mdev);
-
 	mdev->hard_start_xmit = ieee80211_master_start_xmit;
 	mdev->wireless_handlers =
 		(struct iw_handler_def *) &ieee80211_iw_master_handler_def;
@@ -4600,7 +4589,7 @@ int ieee80211_update_hw(struct net_devic
 	local->conf.phymode = hw->modes[0].mode;
 	local->curr_rates = hw->modes[0].rates;
 	local->num_curr_rates = hw->modes[0].num_rates;
-	ieee80211_prepare_rates(dev);
+	ieee80211_prepare_rates(local);
 
 	local->conf.freq = local->hw->modes[0].channels[0].freq;
 	local->conf.channel = local->hw->modes[0].channels[0].chan;
@@ -4625,7 +4614,7 @@ void ieee80211_unregister_hw(struct net_
 	rtnl_lock();
 	local->reg_state = IEEE80211_DEV_UNREGISTERED;
 	if (local->apdev)
-		ieee80211_if_del_mgmt(local->apdev);
+		ieee80211_if_del_mgmt(local);
 
 	sysfs_remove_link(&local->class_dev.kobj, "master");
 
--- wireless-dev.orig/net/d80211/ieee80211_i.h	2006-11-19 20:13:51.889275208 +0100
+++ wireless-dev/net/d80211/ieee80211_i.h	2006-11-19 20:13:55.359275208 +0100
@@ -562,7 +562,7 @@ static inline void bss_tim_clear(struct 
 
 /* ieee80211.c */
 void ieee80211_release_hw(struct ieee80211_local *local);
-int ieee80211_hw_config(struct net_device *dev);
+int ieee80211_hw_config(struct ieee80211_local *local);
 int ieee80211_if_config(struct net_device *dev);
 int ieee80211_if_config_beacon(struct net_device *dev);
 struct ieee80211_key_conf *
@@ -574,7 +574,7 @@ void ieee80211_key_free(struct ieee80211
 void ieee80211_key_release(struct kobject *kobj);
 void ieee80211_rx_mgmt(struct net_device *dev, struct sk_buff *skb,
 		       struct ieee80211_rx_status *status, u32 msg_type);
-void ieee80211_prepare_rates(struct net_device *dev);
+void ieee80211_prepare_rates(struct ieee80211_local *local);
 void ieee80211_tx_set_iswep(struct ieee80211_txrx_data *tx);
 int ieee80211_if_update_wds(struct net_device *dev, u8 *remote_addr);
 void ieee80211_if_setup(struct net_device *dev);
@@ -662,8 +662,8 @@ int ieee80211_if_remove(struct net_devic
 void ieee80211_if_free(struct net_device *dev);
 void ieee80211_if_flush(struct net_device *dev);
 void ieee80211_if_sdata_init(struct ieee80211_sub_if_data *sdata);
-int ieee80211_if_add_mgmt(struct net_device *dev);
-void ieee80211_if_del_mgmt(struct net_device *dev);
+int ieee80211_if_add_mgmt(struct ieee80211_local *local);
+void ieee80211_if_del_mgmt(struct ieee80211_local *local);
 
 /* ieee80211_sysfs.c */
 int ieee80211_sysfs_add_netdevice(struct net_device *dev);
--- wireless-dev.orig/net/d80211/ieee80211_iface.c	2006-11-19 20:13:51.929275208 +0100
+++ wireless-dev/net/d80211/ieee80211_iface.c	2006-11-19 20:13:55.359275208 +0100
@@ -107,14 +107,12 @@ fail:
 	return ret;
 }
 
-int ieee80211_if_add_mgmt(struct net_device *dev)
+int ieee80211_if_add_mgmt(struct ieee80211_local *local)
 {
 	struct net_device *ndev;
-	struct ieee80211_local *local = dev->ieee80211_ptr;
-	struct ieee80211_sub_if_data *sdata, *nsdata;
+	struct ieee80211_sub_if_data *nsdata;
 	int ret;
 
-	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	ASSERT_RTNL();
 
 	ndev = alloc_netdev(sizeof(struct ieee80211_sub_if_data), "",
@@ -126,12 +124,8 @@ int ieee80211_if_add_mgmt(struct net_dev
 		goto fail;
 
 	ndev->ieee80211_ptr = local;
-	memcpy(ndev->dev_addr, dev->dev_addr, ETH_ALEN);
-	ndev->base_addr = dev->base_addr;
-	ndev->irq = dev->irq;
-	ndev->mem_start = dev->mem_start;
-	ndev->mem_end = dev->mem_end;
-	SET_NETDEV_DEV(ndev, dev->class_dev.dev);
+	memcpy(ndev->dev_addr, local->mdev->dev_addr, ETH_ALEN);
+	SET_NETDEV_DEV(ndev, local->mdev->class_dev.dev);
 
 	nsdata = IEEE80211_DEV_TO_SUB_IF(ndev);
 	nsdata->type = IEEE80211_IF_TYPE_MGMT;
@@ -158,9 +152,8 @@ fail:
 	return ret;
 }
 
-void ieee80211_if_del_mgmt(struct net_device *dev)
+void ieee80211_if_del_mgmt(struct ieee80211_local *local)
 {
-	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct net_device *apdev;
 
 	ASSERT_RTNL();
@@ -377,7 +370,7 @@ void ieee80211_if_del(struct net_device 
 
 	rtnl_lock();
 	if (sdata->type == IEEE80211_IF_TYPE_MGMT)
-		ieee80211_if_del_mgmt(local->mdev);
+		ieee80211_if_del_mgmt(local);
 	else
 		__ieee80211_if_del(local, sdata);
 	rtnl_unlock();
--- wireless-dev.orig/net/d80211/ieee80211_ioctl.c	2006-11-19 20:13:51.979275208 +0100
+++ wireless-dev/net/d80211/ieee80211_ioctl.c	2006-11-19 20:13:55.369275208 +0100
@@ -411,7 +411,7 @@ static int ieee80211_ioctl_get_info_sta(
 		struct net_device_stats *stats;
 
 		sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-		stats = ieee80211_dev_stats(sdata->master);
+		stats = ieee80211_dev_stats(local->mdev);
 		param->u.get_info_sta.rx_bytes = stats->rx_bytes;
 		param->u.get_info_sta.tx_bytes = stats->tx_bytes;
 		/* go through all STAs and get STA with lowest max. rate */
@@ -992,7 +992,7 @@ static int ieee80211_ioctl_set_rate_sets
 		/* TODO: should update STA TX rates and remove STAs if they
 		 * do not have any remaining supported rates after the change
 		 */
-		ieee80211_prepare_rates(dev);
+		ieee80211_prepare_rates(local);
 	}
 
 	return 0;
@@ -1298,7 +1298,7 @@ static int ieee80211_ioctl_set_radio_ena
 {
         struct ieee80211_conf *conf = ieee80211_get_hw_conf(dev);
 	conf->radio_enabled = val;
-        return ieee80211_hw_config(dev);
+	return ieee80211_hw_config(dev->ieee80211_ptr);
 }
 
 static int
@@ -1841,7 +1841,7 @@ int ieee80211_ioctl_siwfreq(struct net_d
 
 	if (set) {
 		local->sta_scanning = 0; /* Abort possible scan */
-		return ieee80211_hw_config(dev);
+		return ieee80211_hw_config(local);
 	}
 
 	return -EINVAL;
@@ -2378,7 +2378,7 @@ static int ieee80211_ioctl_prism2_param(
 
 	case PRISM2_PARAM_BEACON_INT:
 		local->conf.beacon_int = value;
-		if (ieee80211_hw_config(dev))
+		if (ieee80211_hw_config(local))
 			ret = -EINVAL;
 		break;
 
@@ -2437,7 +2437,7 @@ static int ieee80211_ioctl_prism2_param(
 			local->conf.flags |= IEEE80211_CONF_SHORT_SLOT_TIME;
 		else
 			local->conf.flags &= ~IEEE80211_CONF_SHORT_SLOT_TIME;
-		if (ieee80211_hw_config(dev))
+		if (ieee80211_hw_config(local))
 			ret = -EINVAL;
 		break;
 
@@ -2464,19 +2464,19 @@ static int ieee80211_ioctl_prism2_param(
 
 	case PRISM2_PARAM_ANTENNA_SEL:
 		local->conf.antenna_sel = value;
-		if (ieee80211_hw_config(dev))
+		if (ieee80211_hw_config(local))
 			ret = -EINVAL;
 		break;
 
 	case PRISM2_PARAM_CALIB_INT:
 		local->conf.calib_int = value;
-		if (ieee80211_hw_config(dev))
+		if (ieee80211_hw_config(local))
 			ret = -EINVAL;
 		break;
 
 	case PRISM2_PARAM_ANTENNA_MODE:
 		local->conf.antenna_mode = value;
-		if (ieee80211_hw_config(dev))
+		if (ieee80211_hw_config(local))
 			ret = -EINVAL;
 		break;
 
@@ -2590,10 +2590,10 @@ static int ieee80211_ioctl_prism2_param(
 	case PRISM2_PARAM_MGMT_IF:
 		if (value == 1) {
 			if (!local->apdev)
-				ret = ieee80211_if_add_mgmt(local->mdev);
+				ret = ieee80211_if_add_mgmt(local);
 		} else if (value == 0) {
 			if (local->apdev)
-				ieee80211_if_del_mgmt(local->mdev);
+				ieee80211_if_del_mgmt(local);
 		} else
 			ret = -EINVAL;
 		break;
--- wireless-dev.orig/net/d80211/ieee80211_sta.c	2006-11-19 20:13:54.109275208 +0100
+++ wireless-dev/net/d80211/ieee80211_sta.c	2006-11-19 20:13:55.369275208 +0100
@@ -2372,7 +2372,7 @@ static int ieee80211_sta_restore_oper_ch
 	local->conf.freq = local->scan_oper_freq;
 	local->conf.phymode = local->scan_oper_phymode;
 	local->conf.antenna_max = local->scan_oper_antenna_max;
-	return ieee80211_hw_config(dev);
+	return ieee80211_hw_config(local);
 }
 
 
@@ -2471,7 +2471,7 @@ static void ieee80211_sta_scan_work(void
 			local->conf.freq = chan->freq;
 			local->conf.phymode = mode->mode;
 			local->conf.antenna_max = chan->antenna_max;
-			if (ieee80211_hw_config(dev)) {
+			if (ieee80211_hw_config(local)) {
 				printk(KERN_DEBUG "%s: failed to set channel "
 				       "%d (%d MHz) for scan\n", dev->name,
 				       chan->chan, chan->freq);


