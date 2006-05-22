From: Jiri Benc <jbenc@suse.cz>
Subject: Re: wireless-dev updated
Date: Mon, 22 May 2006 14:42:14 +0200
Message-ID: <20060522144214.02f0adb2@griffin.suse.cz>
References: <20060519191549.GF30177@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:15514 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1750801AbWEVMmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 May 2006 08:42:19 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060519191549.GF30177@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 19 May 2006 15:15:54 -0400, John W. Linville wrote:
> Jiri Benc:
>       d80211: switching management interface on/off

This patch is wrong, it uses incorrect ioctl number (collides with
userspace MLME).

As I discovered some bugs and I'm still working on some of them, I
haven't sent pull request yet. Bad idea, unfortunately.

>       d80211: use alloc_netdev
>       d80211: fix is_ieee80211_device

Would it be possible to drop these patches and pull from 'up' branch of
my tree?

If not, I will try to rebase my tree (I have another patches before
them) and send corrections to already applied patches as new patches.

---

git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git up

Jiri Benc:
      d80211: don't config uninitialized interface
      d80211: fix recursive locking
      d80211: switching management interface on/off
      d80211: use alloc_netdev
      d80211: fix is_ieee80211_device

Jouni Malinen:
      d80211: Add support for user space client MLME

Michael Wu:
      d80211: Don't discriminate against 802.11b drivers

 net/d80211/hostapd_ioctl.h   |    2 
 net/d80211/ieee80211.c       |  169 ++++++++++++++++++++-----------------------
 net/d80211/ieee80211_i.h     |   16 ++--
 net/d80211/ieee80211_iface.c |   94 ++++++++++++++++++-----
 net/d80211/ieee80211_ioctl.c |   66 ++++++++++++++--
 net/d80211/ieee80211_sta.c   |   10 +-
 6 files changed, 224 insertions(+), 133 deletions(-)

diff --git a/net/d80211/hostapd_ioctl.h b/net/d80211/hostapd_ioctl.h
index a462688..7c7305c 100644
--- a/net/d80211/hostapd_ioctl.h
+++ b/net/d80211/hostapd_ioctl.h
@@ -91,6 +91,8 @@ enum {
 	PRISM2_PARAM_KEY_MGMT = 1040,
 	PRISM2_PARAM_RADAR_DETECT = 1043,
 	PRISM2_PARAM_SPECTRUM_MGMT = 1044,
+	PRISM2_PARAM_USER_SPACE_MLME = 1045,
+	PRISM2_PARAM_MGMT_IF = 1046,
 	/* NOTE: Please try to coordinate with other active development
 	 * branches before allocating new param numbers so that each new param
 	 * will be unique within all branches and the allocated number will not
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index ffb7985..b850fb7 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -59,6 +59,8 @@ static int rate_control_initialize(struc
 
 static u8 * ieee80211_get_bssid(struct ieee80211_hdr *hdr, size_t len);
 
+static int ieee80211_mgmt_start_xmit(struct sk_buff *skb,
+				     struct net_device *dev);
 
 struct ieee80211_key_conf *
 ieee80211_key_data2conf(struct ieee80211_local *local,
@@ -1097,7 +1099,8 @@ __ieee80211_tx_prepare(struct ieee80211_
 static int inline is_ieee80211_device(struct net_device *dev)
 {
 	return (dev->wireless_handlers ==
-		(struct iw_handler_def *) &ieee80211_iw_handler_def);
+		(struct iw_handler_def *) &ieee80211_iw_handler_def) ||
+	       (dev->hard_start_xmit == ieee80211_mgmt_start_xmit);
 }
 
 /* Device in tx->dev has a reference added; use dev_put(tx->dev) when
@@ -1754,7 +1757,7 @@ int ieee80211_if_config(struct net_devic
 	struct ieee80211_local *local = dev->priv;
 	struct ieee80211_if_conf conf;
 
-	if (!local->hw->config_interface)
+	if (!local->hw->config_interface || !netif_running(dev))
 		return 0;
 
 	memset(&conf, 0, sizeof(conf));
@@ -1954,8 +1957,6 @@ static inline int identical_mac_addr_all
 {
 	return (type1 == IEEE80211_IF_TYPE_MNTR ||
 		type2 == IEEE80211_IF_TYPE_MNTR ||
-		type1 == IEEE80211_IF_TYPE_MGMT ||
-		type2 == IEEE80211_IF_TYPE_MGMT ||
 		(type1 == IEEE80211_IF_TYPE_AP &&
 		 type2 == IEEE80211_IF_TYPE_WDS) ||
 		(type1 == IEEE80211_IF_TYPE_WDS &&
@@ -1990,6 +1991,20 @@ static int ieee80211_master_stop(struct 
 	return 0;
 }
 
+static int ieee80211_mgmt_open(struct net_device *dev)
+{
+	struct ieee80211_local *local = dev->priv;
+
+	if (!netif_running(local->mdev))
+		return -EOPNOTSUPP;
+	return 0;
+}
+
+static int ieee80211_mgmt_stop(struct net_device *dev)
+{
+	return 0;
+}
+
 /* Check if running monitor interfaces should go to a "soft monitor" mode
  * and switch them if necessary. */
 static inline void ieee80211_start_soft_monitor(struct ieee80211_local *local)
@@ -2032,7 +2047,6 @@ static int ieee80211_open(struct net_dev
 		struct net_device *ndev = nsdata->dev;
 
 		if (ndev != dev && ndev != local->mdev &&
-		    ndev != local->apdev &&
 		    netif_running(ndev) &&
 		    memcmp(dev->dev_addr, ndev->dev_addr, ETH_ALEN) == 0 &&
 		    !identical_mac_addr_allowed(sdata->type, nsdata->type)) {
@@ -2075,8 +2089,11 @@ static int ieee80211_open(struct net_dev
 			res = local->hw->open(sdata->master);
 		if (res == 0) {
 			res = dev_open(sdata->master);
-			if (res && local->hw->stop)
-				local->hw->stop(sdata->master);
+			if (res) {
+				if (local->hw->stop)
+					local->hw->stop(sdata->master);
+			} else if (local->apdev)
+				dev_open(local->apdev);
 		}
 		if (res) {
 			if (local->hw->remove_interface)
@@ -2089,6 +2106,8 @@ static int ieee80211_open(struct net_dev
 
 	if (sdata->type == IEEE80211_IF_TYPE_MNTR)
 		local->monitors++;
+	else
+		ieee80211_if_config(dev);
 
 	netif_start_queue(dev);
 	return 0;
@@ -2119,6 +2138,8 @@ static int ieee80211_stop(struct net_dev
         if (local->open_count == 0) {
 		ieee80211_stop_scan(sdata->master);
 		dev_close(sdata->master);
+		if (local->apdev)
+			dev_close(local->apdev);
 		if (local->hw->stop)
 			local->hw->stop(sdata->master);
         }
@@ -2367,6 +2388,10 @@ ieee80211_rx_mgmt(struct net_device *dev
 
 	if (msg_type != ieee80211_msg_monitor)
 		dev = local->apdev;
+	if (!dev) {
+		dev_kfree_skb(skb);
+		return;
+	}
         skb->dev = dev;
 
         sdata = IEEE80211_DEV_TO_SUB_IF(dev);
@@ -3116,8 +3141,9 @@ ieee80211_rx_h_mgmt(struct ieee80211_txr
 {
         struct ieee80211_sub_if_data *sdata;
 	sdata = IEEE80211_DEV_TO_SUB_IF(rx->dev);
-	if (sdata->type == IEEE80211_IF_TYPE_STA ||
-	    sdata->type == IEEE80211_IF_TYPE_IBSS) {
+	if ((sdata->type == IEEE80211_IF_TYPE_STA ||
+	     sdata->type == IEEE80211_IF_TYPE_IBSS) &&
+	    !rx->local->user_space_mlme) {
 		ieee80211_sta_rx_mgmt(rx->dev, rx->skb, rx->u.rx.status);
 	} else {
 		/* Management frames are sent to hostapd for processing */
@@ -3998,15 +4024,31 @@ void ieee80211_if_setup(struct net_devic
 	dev->destructor = ieee80211_if_free;
 }
 
+void ieee80211_if_mgmt_setup(struct net_device *dev)
+{
+	ether_setup(dev);
+	dev->hard_start_xmit = ieee80211_mgmt_start_xmit;
+	dev->change_mtu = ieee80211_change_mtu_apdev;
+	dev->get_stats = ieee80211_get_stats;
+	dev->open = ieee80211_mgmt_open;
+	dev->stop = ieee80211_mgmt_stop;
+	dev->type = ARPHRD_IEEE80211_PRISM;
+	dev->hard_header_parse = header_parse_80211;
+	dev->tx_queue_len = 0;
+	dev->destructor = ieee80211_if_free;
+}
 
-static void ieee80211_precalc_rates(struct ieee80211_hw *hw)
+static void ieee80211_precalc_modes(struct ieee80211_hw *hw,
+				    struct ieee80211_local *local)
 {
 	struct ieee80211_hw_modes *mode;
 	struct ieee80211_rate *rate;
 	int m, r;
 
+	local->hw_modes = 0;
 	for (m = 0; m < hw->num_modes; m++) {
 		mode = &hw->modes[m];
+		local->hw_modes |= 1 << mode->mode;
 		for (r = 0; r < mode->num_rates; r++) {
 			rate = &mode->rates[r];
 			rate->rate_inv = CHAN_UTIL_RATE_LCM / rate->rate;
@@ -4018,57 +4060,43 @@ static void ieee80211_precalc_rates(stru
 struct net_device *ieee80211_alloc_hw(size_t priv_data_len,
 				      void (*setup)(struct net_device *))
 {
-	struct net_device *apdev, *mdev;
+	struct net_device *mdev;
         struct ieee80211_local *local;
         struct ieee80211_sub_if_data *sdata;
-	int alloc_size;
+	int priv_size;
 
-	/* Ensure 32-bit alignment of our private data and hw private data.
-	 * Each net_device is followed by a sub_if_data which which is used
-	 * for wds/vlan information; it is aligned as well.
+	/* Ensure 32-byte alignment of our private data and hw private data.
+	 * Each net_device is followed by a sub_if_data which is used for
+	 * interface specific information.
 	 *
          * Sample memory map looks something like:
          *
          * 0000 *****************
          *      * net_dev       *
-         * 015c *****************
+	 * 0160 *****************
          *      * sub_if        *
-         * 017c *****************
+	 * 0180 *****************
          *      * local         *
-         * 0b84 *****************
+	 * 0b80 *****************
          *      * hw_priv       *
          * 1664 *****************
-         *      * ap net_dev    *
-         * 17c0 *****************
-         *      * sub_if        *
-	 *      *****************
          */
-        alloc_size = sizeof(struct net_device) +
-                sizeof(struct ieee80211_sub_if_data) + 3 +
-                sizeof(struct ieee80211_local) + 3 +
-                priv_data_len + 3 +
-                sizeof(struct net_device) + 3 +
-		sizeof(struct ieee80211_sub_if_data) + 3 +
-		4096;
-        mdev = (struct net_device *) kzalloc(alloc_size, GFP_KERNEL);
+	priv_size = ((sizeof(struct ieee80211_sub_if_data) +
+		      NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST) +
+		    ((sizeof(struct ieee80211_local) +
+		      NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST) +
+		    priv_data_len;
+	mdev = alloc_netdev(priv_size, "wmaster%d", ether_setup);
 	if (mdev == NULL)
 		return NULL;
 
-        mdev->priv = (struct net_device *)
-		((char *) mdev +
-		 ((sizeof(struct net_device) + 3) & ~3) +
-		 ((sizeof(struct ieee80211_sub_if_data) + 3) & ~3));
+	mdev->priv = (char *)netdev_priv(mdev) +
+		     ((sizeof(struct ieee80211_sub_if_data) +
+		       NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
 	local = mdev->priv;
-	local->hw_priv = (void *)
-		((char *) local + ((sizeof(struct ieee80211_local) + 3) & ~3));
-	apdev = (struct net_device *)
-		((char *) local->hw_priv + ((priv_data_len + 3) & ~3));
-
-	ether_setup(mdev);
-	memcpy(mdev->name, "wmaster%d", 10);
-
-	if (strlen(mdev->name) + 2 >= sizeof(mdev->name))
-		goto fail;
+	local->hw_priv = (char *)local +
+			 ((sizeof(struct ieee80211_local) +
+			   NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
 
 	local->dev_index = -1;
 	local->mdev = mdev;
@@ -4087,7 +4115,7 @@ struct net_device *ieee80211_alloc_hw(si
 	local->rate_ctrl_num_down = RATE_CONTROL_NUM_DOWN;
 
         local->scan.in_scan = 0;
-	local->hw_modes = (unsigned int) -1;
+	local->enabled_modes = (unsigned int) -1;
 
         init_timer(&local->scan.timer); /* clear it out */
 
@@ -4104,28 +4132,6 @@ struct net_device *ieee80211_alloc_hw(si
 
         ieee80211_if_init(mdev);
 
-        apdev = (struct net_device *)
-		((char *) local->hw_priv + ((priv_data_len + 3) & ~3));
-        local->apdev = apdev;
-	ether_setup(apdev);
-	apdev->priv = local;
-	apdev->hard_start_xmit = ieee80211_mgmt_start_xmit;
-	apdev->change_mtu = ieee80211_change_mtu_apdev;
-	apdev->get_stats = ieee80211_get_stats;
-        apdev->open = ieee80211_open;
-        apdev->stop = ieee80211_stop;
-	apdev->type = ARPHRD_IEEE80211_PRISM;
-        apdev->hard_header_parse = header_parse_80211;
-	apdev->tx_queue_len = 0;
-	sprintf(apdev->name, "%sap", mdev->name);
-
-        sdata = IEEE80211_DEV_TO_SUB_IF(apdev);
-        sdata->type = IEEE80211_IF_TYPE_MGMT;
-        sdata->dev = apdev;
-        sdata->master = mdev;
-        sdata->local = local;
-        list_add_tail(&sdata->list, &local->sub_if_list);
-
 	mdev->hard_start_xmit = ieee80211_master_start_xmit;
 	mdev->wireless_handlers =
 		(struct iw_handler_def *) &ieee80211_iw_handler_def;
@@ -4155,10 +4161,6 @@ struct net_device *ieee80211_alloc_hw(si
 		setup(mdev);
 
 	return mdev;
-
- fail:
-	ieee80211_free_hw(mdev);
-	return NULL;
 }
 
 
@@ -4193,15 +4195,11 @@ int ieee80211_register_hw(struct net_dev
 
 	sta_info_start(local);
 
-	result = register_netdev(local->apdev);
-	if (result < 0)
-		goto fail_1st_dev;
-
 	if (hw->fraglist)
 		dev->features |= NETIF_F_FRAGLIST;
 	result = register_netdev(dev);
 	if (result < 0)
-		goto fail_2nd_dev;
+		goto fail_dev;
 
 	if (rate_control_initialize(local) < 0) {
 		printk(KERN_DEBUG "%s: Failed to initialize rate control "
@@ -4226,9 +4224,7 @@ int ieee80211_register_hw(struct net_dev
 
 fail_rate:
 	unregister_netdev(dev);
-fail_2nd_dev:
-	unregister_netdev(local->apdev);
-fail_1st_dev:
+fail_dev:
 	sta_info_stop(local);
 	ieee80211_unregister_sysfs(local);
 fail_sysfs:
@@ -4247,17 +4243,11 @@ int ieee80211_update_hw(struct net_devic
 	if (hw->queues == 0)
 		hw->queues = 1;
 
-	memcpy(local->apdev->dev_addr, dev->dev_addr, ETH_ALEN);
-	local->apdev->base_addr = dev->base_addr;
-	local->apdev->irq = dev->irq;
-	local->apdev->mem_start = dev->mem_start;
-	local->apdev->mem_end = dev->mem_end;
-
 	if (!hw->modes || !hw->modes->channels || !hw->modes->rates ||
 	    !hw->modes->num_channels || !hw->modes->num_rates)
 		return -1;
 
-	ieee80211_precalc_rates(hw);
+	ieee80211_precalc_modes(hw, local);
 	local->conf.phymode = hw->modes[0].mode;
 	local->curr_rates = hw->modes[0].rates;
 	local->num_curr_rates = hw->modes[0].num_rates;
@@ -4291,6 +4281,9 @@ void ieee80211_unregister_hw(struct net_
 		del_timer_sync(&local->scan_timer);
 	ieee80211_rx_bss_list_deinit(dev);
 
+	if (local->apdev)
+		ieee80211_if_del(local->apdev);
+
 	list_for_each_safe(ptr, n, &local->sub_if_list) {
 		struct ieee80211_sub_if_data *sdata =
 			list_entry(ptr, struct ieee80211_sub_if_data, list);
@@ -4323,7 +4316,7 @@ void ieee80211_unregister_hw(struct net_
 
 void ieee80211_free_hw(struct net_device *dev)
 {
-	kfree(dev);
+	free_netdev(dev);
 }
 
 
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index ee0b399..94e151d 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -307,11 +307,7 @@ #define NUM_DEFAULT_KEYS 4
         int channel_use_raw;
 };
 
-#define IEEE80211_DEV_TO_SUB_IF(dev) ((struct ieee80211_sub_if_data *) \
-		((char *)(dev) + ((sizeof(struct net_device) + 3) & ~3)))
-#define IEEE80211_SUB_IF_TO_DEV(sub_if) ((struct net_device *) \
-		((char *)(sub_if) - ((sizeof(struct net_device) + 3) & ~3)))
-
+#define IEEE80211_DEV_TO_SUB_IF(dev) netdev_priv(dev)
 
 struct ieee80211_local {
 	struct ieee80211_hw *hw;
@@ -409,7 +405,6 @@ #define IEEE80211_IRQSAFE_QUEUE_LIMIT 12
 	int scan_oper_antenna_max;
 	u8 scan_ssid[IEEE80211_MAX_SSID_LEN];
 	size_t scan_ssid_len;
-	int scan_skip_11b;
 	struct list_head sta_bss_list;
 	struct ieee80211_sta_bss *sta_bss_hash[STA_HASH_SIZE];
 	spinlock_t sta_bss_lock;
@@ -500,8 +495,12 @@ #endif /* CONFIG_D80211_DEBUG_COUNTERS *
 	int wifi_wme_noack_test;
 	unsigned int wmm_acm; /* bit field of ACM bits (BIT(802.1D tag)) */
 
-	unsigned int hw_modes; /* bitfield of allowed hardware modes;
+	unsigned int enabled_modes; /* bitfield of allowed modes;
+				      * (1 << MODE_*) */
+	unsigned int hw_modes; /* bitfield of supported hardware modes;
 				* (1 << MODE_*) */
+
+	int user_space_mlme;
 };
 
 
@@ -518,6 +517,7 @@ void ieee80211_prepare_rates(struct net_
 void ieee80211_tx_set_iswep(struct ieee80211_txrx_data *tx);
 int ieee80211_if_update_wds(struct net_device *dev, u8 *remote_addr);
 void ieee80211_if_setup(struct net_device *dev);
+void ieee80211_if_mgmt_setup(struct net_device *dev);
 
 /* ieee80211_ioctl.c */
 int ieee80211_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
@@ -595,6 +595,8 @@ int ieee80211_if_remove(struct net_devic
 void ieee80211_if_free(struct net_device *dev);
 void ieee80211_if_flush(struct net_device *dev);
 void ieee80211_if_sdata_init(struct ieee80211_sub_if_data *sdata);
+int ieee80211_if_add_mgmt(struct net_device *dev);
+void ieee80211_if_del_mgmt(struct net_device *dev);
 
 /* ieee80211_sysfs.c */
 int ieee80211_register_sysfs(struct ieee80211_local *local);
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index f3ce45f..6631738 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -31,16 +31,12 @@ int ieee80211_if_add(struct net_device *
 	struct net_device *ndev, *tmp_dev;
 	struct ieee80211_local *local = dev->priv;
 	struct ieee80211_sub_if_data *sdata = NULL, *sdata_parent;
-	int alloc_size;
 	int ret;
 	int i;
 
 	ASSERT_RTNL();
-	/* ensure 32-bit alignment of our private data and hw private data */
-	alloc_size = sizeof(struct net_device) + 3 +
-		sizeof(struct ieee80211_sub_if_data) + 3;
-
-	ndev = *new_dev = (struct net_device *) kzalloc(alloc_size, GFP_KERNEL);
+	ndev = *new_dev = alloc_netdev(sizeof(struct ieee80211_sub_if_data),
+				       "", ieee80211_if_setup);
 	if (ndev == NULL)
 		return -ENOMEM;
 
@@ -68,7 +64,6 @@ int ieee80211_if_add(struct net_device *
 	ndev->mem_start = dev->mem_start;
 	ndev->mem_end = dev->mem_end;
 	ndev->flags = dev->flags & IFF_MULTICAST;
-	ieee80211_if_setup(ndev);
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(ndev);
 	sdata->type = IEEE80211_IF_TYPE_AP;
@@ -88,11 +83,66 @@ int ieee80211_if_add(struct net_device *
 	return 0;
 
 fail:
-	kfree(ndev);
+	free_netdev(ndev);
 	*new_dev = NULL;
 	return ret;
 }
 
+int ieee80211_if_add_mgmt(struct net_device *dev)
+{
+	struct net_device *ndev;
+	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_sub_if_data *sdata, *nsdata;
+	int ret;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	ASSERT_RTNL();
+
+	ndev = alloc_netdev(sizeof(struct ieee80211_sub_if_data), "",
+			    ieee80211_if_mgmt_setup);
+	if (ndev == NULL)
+		return -ENOMEM;
+	ret = dev_alloc_name(ndev, "wmgmt%d");
+	if (ret)
+		goto fail;
+
+	ndev->priv = local;
+	memcpy(ndev->dev_addr, dev->dev_addr, ETH_ALEN);
+	ndev->base_addr = dev->base_addr;
+	ndev->irq = dev->irq;
+	ndev->mem_start = dev->mem_start;
+	ndev->mem_end = dev->mem_end;
+
+	nsdata = IEEE80211_DEV_TO_SUB_IF(ndev);
+	nsdata->type = IEEE80211_IF_TYPE_MGMT;
+	nsdata->master = local->mdev;
+	nsdata->dev = ndev;
+	nsdata->local = local;
+	ieee80211_if_sdata_init(nsdata);
+
+	ret = register_netdevice(ndev);
+	if (ret)
+		goto fail;
+	if (local->open_count > 0)
+		dev_open(ndev);
+	local->apdev = ndev;
+	return 0;
+fail:
+	free_netdev(ndev);
+	return ret;
+}
+
+void ieee80211_if_del_mgmt(struct net_device *dev)
+{
+	struct ieee80211_local *local = dev->priv;
+	struct net_device *apdev;
+
+	ASSERT_RTNL();
+	apdev = local->apdev;
+	local->apdev = NULL;
+	unregister_netdevice(apdev);
+}
+
 void ieee80211_if_set_type(struct net_device *dev, int type)
 {
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
@@ -244,9 +294,8 @@ void __ieee80211_if_del(struct ieee80211
 	list_del(&sdata->list);
 	ieee80211_proc_deinit_virtual(dev);
 	unregister_netdevice(dev);
-	/* Default data device and management device are allocated with the
-	 * master device. All other devices are separately allocated and will
-	 * be freed by net_device->destructor (i. e. ieee80211_if_free). */
+	/* Except master interface, the net_device will be freed by
+	 * net_device->destructor (i. e. ieee80211_if_free). */
 }
 
 /* Must be called with rtnl lock held. */
@@ -263,8 +312,7 @@ int ieee80211_if_remove(struct net_devic
 	list_for_each_entry_safe(sdata, n, &local->sub_if_list, list) {
 		if ((sdata->type == id || id == -1) &&
 		    strcmp(name, sdata->dev->name) == 0 &&
-		    sdata->dev != local->mdev &&
-		    sdata->dev != local->apdev) {
+		    sdata->dev != local->mdev) {
 			__ieee80211_if_del(local, sdata);
 			return 0;
 		}
@@ -277,7 +325,7 @@ void ieee80211_if_free(struct net_device
 	struct ieee80211_local *local = dev->priv;
 
 	BUG_ON(dev == local->mdev || dev == local->apdev);
-	kfree(dev);
+	free_netdev(dev);
 }
 
 /* Must be called with rtnl lock held. */
@@ -298,6 +346,9 @@ void ieee80211_if_del(struct net_device 
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
 	rtnl_lock();
-	__ieee80211_if_del(local, sdata);
+	if (sdata->type == IEEE80211_IF_TYPE_MGMT)
+		ieee80211_if_del_mgmt(local->mdev);
+	else
+		__ieee80211_if_del(local, sdata);
 	rtnl_unlock();
 }
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 5d31a8f..30dfc76 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -937,7 +937,8 @@ static int ieee80211_ioctl_add_if(struct
 		ieee80211_if_set_type(new_dev, IEEE80211_IF_TYPE_WDS);
 		res = ieee80211_if_update_wds(new_dev, wds->remote_addr);
 		if (res)
-			ieee80211_if_del(new_dev);
+			__ieee80211_if_del(dev->priv,
+					   IEEE80211_DEV_TO_SUB_IF(new_dev));
 		return res;
 	} else if (param->u.if_info.type == HOSTAP_IF_VLAN) {
 		if (left < sizeof(struct hostapd_if_vlan))
@@ -950,7 +951,8 @@ static int ieee80211_ioctl_add_if(struct
 #if 0
 		res = ieee80211_if_update_vlan(new_dev, vlan->id);
 		if (res)
-			ieee80211_if_del(new_dev);
+			__ieee80211_if_del(dev->priv,
+					   IEEE80211_DEV_TO_SUB_IF(new_dev));
 #endif
 		return res;
         } else if (param->u.if_info.type == HOSTAP_IF_BSS) {
@@ -1048,10 +1050,14 @@ static int ieee80211_ioctl_scan_req(stru
 				    struct prism2_hostapd_param *param,
 				    int param_len)
 {
+	struct ieee80211_local *local = dev->priv;
 	u8 *pos = param->u.scan_req.ssid;
 	int left = param_len - ((u8 *) pos - (u8 *) param);
 	int len = param->u.scan_req.ssid_len;
 
+	if (local->user_space_mlme)
+		return -EOPNOTSUPP;
+
 	if (left < len || len > IEEE80211_MAX_SSID_LEN)
 		return -EINVAL;
 
@@ -1076,8 +1082,12 @@ static int ieee80211_ioctl_sta_get_state
 static int ieee80211_ioctl_mlme(struct net_device *dev,
 				struct prism2_hostapd_param *param)
 {
+	struct ieee80211_local *local = dev->priv;
 	struct ieee80211_sub_if_data *sdata;
 
+	if (local->user_space_mlme)
+		return -EOPNOTSUPP;
+
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	if (sdata->type != IEEE80211_IF_TYPE_STA &&
 	    sdata->type != IEEE80211_IF_TYPE_IBSS)
@@ -1136,6 +1146,10 @@ #endif
 static int ieee80211_set_gen_ie(struct net_device *dev, u8 *ie, size_t len)
 {
 	struct ieee80211_sub_if_data *sdata;
+	struct ieee80211_local *local = dev->priv;
+
+	if (local->user_space_mlme)
+		return -EOPNOTSUPP;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	if (sdata->type == IEEE80211_IF_TYPE_STA ||
@@ -1699,7 +1713,7 @@ int ieee80211_ioctl_siwfreq(struct net_d
 			if (chan->flag & IEEE80211_CHAN_W_SCAN &&
 			    ((freq->e == 0 && chan->chan == freq->m) ||
 			     (freq->e > 0 && nfreq == chan->freq)) &&
-			    (local->hw_modes & (1 << mode->mode))) {
+			    (local->enabled_modes & (1 << mode->mode))) {
 				/* Use next_mode as the mode preference to
 				 * resolve non-unique channel numbers. */
 				if (set && mode->mode != local->next_mode)
@@ -1745,6 +1759,7 @@ static int ieee80211_ioctl_siwessid(stru
 				    struct iw_request_info *info,
 				    struct iw_point *data, char *ssid)
 {
+	struct ieee80211_local *local = dev->priv;
 	struct ieee80211_sub_if_data *sdata;
         size_t len = data->length;
 
@@ -1754,8 +1769,16 @@ static int ieee80211_ioctl_siwessid(stru
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	if (sdata->type == IEEE80211_IF_TYPE_STA ||
-	    sdata->type == IEEE80211_IF_TYPE_IBSS)
+	    sdata->type == IEEE80211_IF_TYPE_IBSS) {
+		if (local->user_space_mlme) {
+			if (len > IEEE80211_MAX_SSID_LEN)
+				return -EINVAL;
+			memcpy(sdata->u.sta.ssid, ssid, len);
+			sdata->u.sta.ssid_len = len;
+			return 0;
+		}
 		return ieee80211_sta_set_ssid(dev, ssid, len);
+	}
 
 	if (sdata->type == IEEE80211_IF_TYPE_AP) {
 		memcpy(sdata->u.ap.ssid, ssid, len);
@@ -1804,11 +1827,17 @@ static int ieee80211_ioctl_siwap(struct 
 				 struct iw_request_info *info,
 				 struct sockaddr *ap_addr, char *extra)
 {
+	struct ieee80211_local *local = dev->priv;
 	struct ieee80211_sub_if_data *sdata;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	if (sdata->type == IEEE80211_IF_TYPE_STA ||
 	    sdata->type == IEEE80211_IF_TYPE_IBSS) {
+		if (local->user_space_mlme) {
+			memcpy(sdata->u.sta.bssid, (u8 *) &ap_addr->sa_data,
+			       ETH_ALEN);
+			return 0;
+		}
 		return ieee80211_sta_set_bssid(dev, (u8 *) &ap_addr->sa_data);
 	} else if (sdata->type == IEEE80211_IF_TYPE_WDS) {
 		if (memcmp(sdata->u.wds.remote_addr, (u8 *) &ap_addr->sa_data,
@@ -2447,7 +2476,7 @@ static int ieee80211_ioctl_prism2_param(
 		break;
 
 	case PRISM2_PARAM_HW_MODES:
-		local->hw_modes = value;
+		local->enabled_modes = value;
 		break;
 
 	case PRISM2_PARAM_CREATE_IBSS:
@@ -2469,6 +2498,19 @@ static int ieee80211_ioctl_prism2_param(
 	case PRISM2_PARAM_SPECTRUM_MGMT:
 		local->conf.spect_mgmt = value;
 		break;
+	case PRISM2_PARAM_MGMT_IF:
+		if (value == 1) {
+			if (local->apdev == NULL)
+				ret = ieee80211_if_add_mgmt(local->mdev);
+		} else if (value == 0) {
+			if (local->apdev)
+				ieee80211_if_del_mgmt(local->mdev);
+		} else
+			ret = -EINVAL;
+		break;
+	case PRISM2_PARAM_USER_SPACE_MLME:
+		local->user_space_mlme = value;
+		break;
 	default:
 		ret = -EOPNOTSUPP;
 		break;
@@ -2620,7 +2662,7 @@ static int ieee80211_ioctl_get_prism2_pa
 		break;
 
 	case PRISM2_PARAM_HW_MODES:
-		*param = local->hw_modes;
+		*param = local->enabled_modes;
 		break;
 
 	case PRISM2_PARAM_CREATE_IBSS:
@@ -2651,6 +2693,15 @@ static int ieee80211_ioctl_get_prism2_pa
 		else
 			*param = !!sdata->u.sta.wmm_enabled;
 		break;
+	case PRISM2_PARAM_MGMT_IF:
+		if (local->apdev)
+			*param = local->apdev->ifindex;
+		else
+			ret = -ENOENT;
+		break;
+	case PRISM2_PARAM_USER_SPACE_MLME:
+		*param = local->user_space_mlme;
+		break;
 
 	default:
 		ret = -EOPNOTSUPP;
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 2720f1d..af58013 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -2462,13 +2462,13 @@ static void ieee80211_sta_scan_timer(uns
 			}
 			return;
 		}
-		skip = !(local->hw_modes & (1 << mode->mode));
+		skip = !(local->enabled_modes & (1 << mode->mode));
 		chan = &mode->channels[local->scan_channel_idx];
 		if (!(chan->flag & IEEE80211_CHAN_W_SCAN) ||
 		    (sdata->type == IEEE80211_IF_TYPE_IBSS &&
 		     !(chan->flag & IEEE80211_CHAN_W_IBSS)) ||
-		    (local->hw_modes & (1 << MODE_IEEE80211G) &&
-		     mode->mode == MODE_IEEE80211B && local->scan_skip_11b))
+		    (local->hw_modes & local->enabled_modes &
+		     (1 << MODE_IEEE80211G) && mode->mode == MODE_IEEE80211B))
 			skip = 1;
 
 		if (!skip) {
@@ -2566,7 +2566,6 @@ int ieee80211_sta_req_scan(struct net_de
 		memcpy(local->scan_ssid, ssid, ssid_len);
 	} else
 		local->scan_ssid_len = 0;
-	local->scan_skip_11b = 1; /* FIX: clear this is 11g is not supported */
 	local->scan_state = SCAN_SET_CHANNEL;
 	local->scan_hw_mode_idx = 0;
 	local->scan_channel_idx = 0;
@@ -2592,7 +2591,7 @@ ieee80211_sta_scan_result(struct net_dev
 		       bss->last_update + IEEE80211_SCAN_RESULT_EXPIRE))
 		return current_ev;
 
-	if (!(local->hw_modes & (1 << bss->hw_mode)))
+	if (!(local->enabled_modes & (1 << bss->hw_mode)))
 		return current_ev;
 
 	if (local->scan_flags & IEEE80211_SCAN_WPA_ONLY &&




-- 
Jiri Benc
SUSE Labs
