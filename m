From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-05-16
Date: Fri, 16 May 2008 17:31:37 -0400
Message-ID: <20080516213137.GA16638@tuxdriver.com>
References: <20080515195341.GB25905@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080515195341.GB25905-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David,

Another quick round of fixes intended for 2.6.26 (including the
corrected version of the "11n hidden ssid" patch)...

Thanks!

John

---

Individual patches are available here:

        http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 066b2118976e6e7cc50eed39e2747c75343a23c4:
  Marcin Slusarz (1):
        isdn/capi: Return proper errnos on module init.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Abhijeet Kolekar (1):
      mac80211 : Association with 11n hidden ssid ap.

Brian Cavagnolo (1):
      libertas: fix command timeout after firmware failure

Ivo van Doorn (1):
      mac80211: Add RTNL version of ieee80211_iterate_active_interfaces

Masakazu Mokuno (1):
      wireless: Create 'device' symlink in sysfs

Mathieu Chouquet-Stringer (1):
      hostap: fix "registers" registration in procfs

Roel Kluin (1):
      wireless, airo: waitbusy() won't delay

 drivers/net/wireless/airo.c             |    3 +-
 drivers/net/wireless/hostap/hostap_hw.c |    9 +++----
 drivers/net/wireless/ipw2200.c          |    1 +
 drivers/net/wireless/libertas/main.c    |    2 +
 include/net/mac80211.h                  |   25 +++++++++++++++++++-
 net/mac80211/mlme.c                     |   14 ++++-------
 net/mac80211/util.c                     |   37 ++++++++++++++++++++++++++++++-
 7 files changed, 73 insertions(+), 18 deletions(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 45f47c1..4e1c690 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -2668,6 +2668,7 @@ static struct net_device *init_wifidev(struct airo_info *ai,
 	dev->irq = ethdev->irq;
 	dev->base_addr = ethdev->base_addr;
 	dev->wireless_data = ethdev->wireless_data;
+	SET_NETDEV_DEV(dev, ethdev->dev.parent);
 	memcpy(dev->dev_addr, ethdev->dev_addr, dev->addr_len);
 	err = register_netdev(dev);
 	if (err<0) {
@@ -2904,7 +2905,7 @@ EXPORT_SYMBOL(init_airo_card);
 
 static int waitbusy (struct airo_info *ai) {
 	int delay = 0;
-	while ((IN4500 (ai, COMMAND) & COMMAND_BUSY) & (delay < 10000)) {
+	while ((IN4500 (ai, COMMAND) & COMMAND_BUSY) && (delay < 10000)) {
 		udelay (10);
 		if ((++delay % 20) == 0)
 			OUT4500(ai, EVACK, EV_CLEARCOMMANDBUSY);
diff --git a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
index 7be68db..cdf90c4 100644
--- a/drivers/net/wireless/hostap/hostap_hw.c
+++ b/drivers/net/wireless/hostap/hostap_hw.c
@@ -3276,11 +3276,6 @@ while (0)
 	}
 	printk(KERN_INFO "%s: Registered netdevice %s\n", dev_info, dev->name);
 
-#ifndef PRISM2_NO_PROCFS_DEBUG
-	create_proc_read_entry("registers", 0, local->proc,
-			       prism2_registers_proc_read, local);
-#endif /* PRISM2_NO_PROCFS_DEBUG */
-
 	hostap_init_data(local);
 	return dev;
 
@@ -3307,6 +3302,10 @@ static int hostap_hw_ready(struct net_device *dev)
 			netif_carrier_off(local->ddev);
 		}
 		hostap_init_proc(local);
+#ifndef PRISM2_NO_PROCFS_DEBUG
+		create_proc_read_entry("registers", 0, local->proc,
+				       prism2_registers_proc_read, local);
+#endif /* PRISM2_NO_PROCFS_DEBUG */
 		hostap_init_ap_proc(local);
 		return 0;
 	}
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index fa87c5c..d74c061 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -11584,6 +11584,7 @@ static int ipw_prom_alloc(struct ipw_priv *priv)
 	priv->prom_net_dev->hard_start_xmit = ipw_prom_hard_start_xmit;
 
 	priv->prom_priv->ieee->iw_mode = IW_MODE_MONITOR;
+	SET_NETDEV_DEV(priv->prom_net_dev, &priv->pci_dev->dev);
 
 	rc = register_netdev(priv->prom_net_dev);
 	if (rc) {
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 406f54d..e1f0660 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -756,6 +756,7 @@ static int lbs_thread(void *data)
 				priv->nr_retries = 0;
 			} else {
 				priv->cur_cmd = NULL;
+				priv->dnld_sent = DNLD_RES_RECEIVED;
 				lbs_pr_info("requeueing command %x due to timeout (#%d)\n",
 					    le16_to_cpu(cmdnode->cmdbuf->command), priv->nr_retries);
 
@@ -1564,6 +1565,7 @@ static int lbs_add_rtap(struct lbs_private *priv)
 	rtap_dev->hard_start_xmit = lbs_rtap_hard_start_xmit;
 	rtap_dev->set_multicast_list = lbs_set_multicast_list;
 	rtap_dev->priv = priv;
+	SET_NETDEV_DEV(rtap_dev, priv->dev->dev.parent);
 
 	ret = register_netdev(rtap_dev);
 	if (ret) {
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 4a80d74..dae3f9e 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -1594,13 +1594,16 @@ void ieee80211_wake_queues(struct ieee80211_hw *hw);
 void ieee80211_scan_completed(struct ieee80211_hw *hw);
 
 /**
- * ieee80211_iterate_active_interfaces - iterate active interfaces
+ * ieee80211_iterate_active_interfaces- iterate active interfaces
  *
  * This function iterates over the interfaces associated with a given
  * hardware that are currently active and calls the callback for them.
+ * This function allows the iterator function to sleep, when the iterator
+ * function is atomic @ieee80211_iterate_active_interfaces_atomic can
+ * be used.
  *
  * @hw: the hardware struct of which the interfaces should be iterated over
- * @iterator: the iterator function to call, cannot sleep
+ * @iterator: the iterator function to call
  * @data: first argument of the iterator function
  */
 void ieee80211_iterate_active_interfaces(struct ieee80211_hw *hw,
@@ -1609,6 +1612,24 @@ void ieee80211_iterate_active_interfaces(struct ieee80211_hw *hw,
 					 void *data);
 
 /**
+ * ieee80211_iterate_active_interfaces_atomic - iterate active interfaces
+ *
+ * This function iterates over the interfaces associated with a given
+ * hardware that are currently active and calls the callback for them.
+ * This function requires the iterator callback function to be atomic,
+ * if that is not desired, use @ieee80211_iterate_active_interfaces instead.
+ *
+ * @hw: the hardware struct of which the interfaces should be iterated over
+ * @iterator: the iterator function to call, cannot sleep
+ * @data: first argument of the iterator function
+ */
+void ieee80211_iterate_active_interfaces_atomic(struct ieee80211_hw *hw,
+						void (*iterator)(void *data,
+						    u8 *mac,
+						    struct ieee80211_vif *vif),
+						void *data);
+
+/**
  * ieee80211_start_tx_ba_session - Start a tx Block Ack session.
  * @hw: pointer as obtained from ieee80211_alloc_hw().
  * @ra: receiver address of the BA session recipient
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 4adba09..e470bf1 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -3446,21 +3446,17 @@ static int ieee80211_sta_config_auth(struct net_device *dev,
 	struct ieee80211_sta_bss *bss, *selected = NULL;
 	int top_rssi = 0, freq;
 
-	if (!(ifsta->flags & (IEEE80211_STA_AUTO_SSID_SEL |
-	    IEEE80211_STA_AUTO_BSSID_SEL | IEEE80211_STA_AUTO_CHANNEL_SEL))) {
-		ifsta->state = IEEE80211_AUTHENTICATE;
-		ieee80211_sta_reset_auth(dev, ifsta);
-		return 0;
-	}
-
 	spin_lock_bh(&local->sta_bss_lock);
 	freq = local->oper_channel->center_freq;
 	list_for_each_entry(bss, &local->sta_bss_list, list) {
 		if (!(bss->capability & WLAN_CAPABILITY_ESS))
 			continue;
 
-		if (!!(bss->capability & WLAN_CAPABILITY_PRIVACY) ^
-		    !!sdata->default_key)
+		if ((ifsta->flags & (IEEE80211_STA_AUTO_SSID_SEL |
+			IEEE80211_STA_AUTO_BSSID_SEL |
+			IEEE80211_STA_AUTO_CHANNEL_SEL)) &&
+		    (!!(bss->capability & WLAN_CAPABILITY_PRIVACY) ^
+		     !!sdata->default_key))
 			continue;
 
 		if (!(ifsta->flags & IEEE80211_STA_AUTO_CHANNEL_SEL) &&
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 24a465c..131e9e6 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -389,6 +389,41 @@ void ieee80211_iterate_active_interfaces(
 	struct ieee80211_local *local = hw_to_local(hw);
 	struct ieee80211_sub_if_data *sdata;
 
+	rtnl_lock();
+
+	list_for_each_entry(sdata, &local->interfaces, list) {
+		switch (sdata->vif.type) {
+		case IEEE80211_IF_TYPE_INVALID:
+		case IEEE80211_IF_TYPE_MNTR:
+		case IEEE80211_IF_TYPE_VLAN:
+			continue;
+		case IEEE80211_IF_TYPE_AP:
+		case IEEE80211_IF_TYPE_STA:
+		case IEEE80211_IF_TYPE_IBSS:
+		case IEEE80211_IF_TYPE_WDS:
+		case IEEE80211_IF_TYPE_MESH_POINT:
+			break;
+		}
+		if (sdata->dev == local->mdev)
+			continue;
+		if (netif_running(sdata->dev))
+			iterator(data, sdata->dev->dev_addr,
+				 &sdata->vif);
+	}
+
+	rtnl_unlock();
+}
+EXPORT_SYMBOL_GPL(ieee80211_iterate_active_interfaces);
+
+void ieee80211_iterate_active_interfaces_atomic(
+	struct ieee80211_hw *hw,
+	void (*iterator)(void *data, u8 *mac,
+			 struct ieee80211_vif *vif),
+	void *data)
+{
+	struct ieee80211_local *local = hw_to_local(hw);
+	struct ieee80211_sub_if_data *sdata;
+
 	rcu_read_lock();
 
 	list_for_each_entry_rcu(sdata, &local->interfaces, list) {
@@ -413,4 +448,4 @@ void ieee80211_iterate_active_interfaces(
 
 	rcu_read_unlock();
 }
-EXPORT_SYMBOL_GPL(ieee80211_iterate_active_interfaces);
+EXPORT_SYMBOL_GPL(ieee80211_iterate_active_interfaces_atomic);
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
