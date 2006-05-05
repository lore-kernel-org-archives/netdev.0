From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH] d80211: switching management interface on/off
Date: Fri, 5 May 2006 15:17:34 +0200
Message-ID: <20060505151734.2d2bb31d@griffin.suse.cz>
References: <20060503183524.GD10524@instant802.com>
	<20060504110028.5af3a22a@griffin.suse.cz>
	<20060504164423.GA12204@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:34214 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751108AbWEENRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 May 2006 09:17:38 -0400
To: "Jouni Malinen" <jkm@devicescape.com>
In-Reply-To: <20060504164423.GA12204@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Default management interface (wmasterXap) confuses users. This patch removes
it and gives userspace tools (such as hostapd or wpa_supplicant) possibility
to switch it on/off as needed.

To do this, a new PRISM2_PARAM_MGMT_IF iwpriv ioctl is introduced. When set,
it accepts one parameter: 1 for enabling the interface, 0 for disabling it.
When read, it returns ifindex of the management interface or -ENOENT when
the management interface is switched off.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/hostapd_ioctl.h   |    1 
 net/d80211/ieee80211.c       |  101 ++++++++++++++++++-------------------------
 net/d80211/ieee80211_i.h     |    3 +
 net/d80211/ieee80211_iface.c |   66 ++++++++++++++++++++++++++--
 net/d80211/ieee80211_ioctl.c |   16 ++++++
 5 files changed, 127 insertions(+), 60 deletions(-)

--- dscape.orig/net/d80211/hostapd_ioctl.h
+++ dscape/net/d80211/hostapd_ioctl.h
@@ -91,6 +91,7 @@ enum {
 	PRISM2_PARAM_KEY_MGMT = 1040,
 	PRISM2_PARAM_RADAR_DETECT = 1043,
 	PRISM2_PARAM_SPECTRUM_MGMT = 1044,
+	PRISM2_PARAM_MGMT_IF = 1045,
 	/* NOTE: Please try to coordinate with other active development
 	 * branches before allocating new param numbers so that each new param
 	 * will be unique within all branches and the allocated number will not
--- dscape.orig/net/d80211/ieee80211.c
+++ dscape/net/d80211/ieee80211.c
@@ -1954,8 +1954,6 @@ static inline int identical_mac_addr_all
 {
 	return (type1 == IEEE80211_IF_TYPE_MNTR ||
 		type2 == IEEE80211_IF_TYPE_MNTR ||
-		type1 == IEEE80211_IF_TYPE_MGMT ||
-		type2 == IEEE80211_IF_TYPE_MGMT ||
 		(type1 == IEEE80211_IF_TYPE_AP &&
 		 type2 == IEEE80211_IF_TYPE_WDS) ||
 		(type1 == IEEE80211_IF_TYPE_WDS &&
@@ -1990,6 +1988,20 @@ static int ieee80211_master_stop(struct 
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
@@ -2032,7 +2044,6 @@ static int ieee80211_open(struct net_dev
 		struct net_device *ndev = nsdata->dev;
 
 		if (ndev != dev && ndev != local->mdev &&
-		    ndev != local->apdev &&
 		    netif_running(ndev) &&
 		    memcmp(dev->dev_addr, ndev->dev_addr, ETH_ALEN) == 0 &&
 		    !identical_mac_addr_allowed(sdata->type, nsdata->type)) {
@@ -2075,8 +2086,11 @@ static int ieee80211_open(struct net_dev
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
@@ -2119,6 +2133,8 @@ static int ieee80211_stop(struct net_dev
         if (local->open_count == 0) {
 		ieee80211_stop_scan(sdata->master);
 		dev_close(sdata->master);
+		if (local->apdev)
+			dev_close(local->apdev);
 		if (local->hw->stop)
 			local->hw->stop(sdata->master);
         }
@@ -2367,6 +2383,10 @@ ieee80211_rx_mgmt(struct net_device *dev
 
 	if (msg_type != ieee80211_msg_monitor)
 		dev = local->apdev;
+	if (!dev) {
+		dev_kfree_skb(skb);
+		return;
+	}
         skb->dev = dev;
 
         sdata = IEEE80211_DEV_TO_SUB_IF(dev);
@@ -3998,6 +4018,19 @@ void ieee80211_if_setup(struct net_devic
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
 
 static void ieee80211_precalc_rates(struct ieee80211_hw *hw)
 {
@@ -4018,7 +4051,7 @@ static void ieee80211_precalc_rates(stru
 struct net_device *ieee80211_alloc_hw(size_t priv_data_len,
 				      void (*setup)(struct net_device *))
 {
-	struct net_device *apdev, *mdev;
+	struct net_device *mdev;
         struct ieee80211_local *local;
         struct ieee80211_sub_if_data *sdata;
 	int alloc_size;
@@ -4038,17 +4071,11 @@ struct net_device *ieee80211_alloc_hw(si
          * 0b84 *****************
          *      * hw_priv       *
          * 1664 *****************
-         *      * ap net_dev    *
-         * 17c0 *****************
-         *      * sub_if        *
-	 *      *****************
          */
         alloc_size = sizeof(struct net_device) +
                 sizeof(struct ieee80211_sub_if_data) + 3 +
                 sizeof(struct ieee80211_local) + 3 +
                 priv_data_len + 3 +
-                sizeof(struct net_device) + 3 +
-		sizeof(struct ieee80211_sub_if_data) + 3 +
 		4096;
         mdev = (struct net_device *) kzalloc(alloc_size, GFP_KERNEL);
 	if (mdev == NULL)
@@ -4061,15 +4088,10 @@ struct net_device *ieee80211_alloc_hw(si
 	local = mdev->priv;
 	local->hw_priv = (void *)
 		((char *) local + ((sizeof(struct ieee80211_local) + 3) & ~3));
-	apdev = (struct net_device *)
-		((char *) local->hw_priv + ((priv_data_len + 3) & ~3));
 
 	ether_setup(mdev);
 	memcpy(mdev->name, "wmaster%d", 10);
 
-	if (strlen(mdev->name) + 2 >= sizeof(mdev->name))
-		goto fail;
-
 	local->dev_index = -1;
 	local->mdev = mdev;
         local->rx_handlers = ieee80211_rx_handlers;
@@ -4104,28 +4126,6 @@ struct net_device *ieee80211_alloc_hw(si
 
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
@@ -4155,10 +4155,6 @@ struct net_device *ieee80211_alloc_hw(si
 		setup(mdev);
 
 	return mdev;
-
- fail:
-	ieee80211_free_hw(mdev);
-	return NULL;
 }
 
 
@@ -4193,15 +4189,11 @@ int ieee80211_register_hw(struct net_dev
 
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
@@ -4226,9 +4218,7 @@ int ieee80211_register_hw(struct net_dev
 
 fail_rate:
 	unregister_netdev(dev);
-fail_2nd_dev:
-	unregister_netdev(local->apdev);
-fail_1st_dev:
+fail_dev:
 	sta_info_stop(local);
 	ieee80211_unregister_sysfs(local);
 fail_sysfs:
@@ -4247,12 +4237,6 @@ int ieee80211_update_hw(struct net_devic
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
@@ -4291,6 +4275,9 @@ void ieee80211_unregister_hw(struct net_
 		del_timer_sync(&local->scan_timer);
 	ieee80211_rx_bss_list_deinit(dev);
 
+	if (local->apdev)
+		ieee80211_if_del(local->apdev);
+
 	list_for_each_safe(ptr, n, &local->sub_if_list) {
 		struct ieee80211_sub_if_data *sdata =
 			list_entry(ptr, struct ieee80211_sub_if_data, list);
--- dscape.orig/net/d80211/ieee80211_i.h
+++ dscape/net/d80211/ieee80211_i.h
@@ -518,6 +518,7 @@ void ieee80211_prepare_rates(struct net_
 void ieee80211_tx_set_iswep(struct ieee80211_txrx_data *tx);
 int ieee80211_if_update_wds(struct net_device *dev, u8 *remote_addr);
 void ieee80211_if_setup(struct net_device *dev);
+void ieee80211_if_mgmt_setup(struct net_device *dev);
 
 /* ieee80211_ioctl.c */
 int ieee80211_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
@@ -595,6 +596,8 @@ int ieee80211_if_remove(struct net_devic
 void ieee80211_if_free(struct net_device *dev);
 void ieee80211_if_flush(struct net_device *dev);
 void ieee80211_if_sdata_init(struct ieee80211_sub_if_data *sdata);
+int ieee80211_if_add_mgmt(struct net_device *dev);
+void ieee80211_if_del_mgmt(struct net_device *dev);
 
 /* ieee80211_sysfs.c */
 int ieee80211_register_sysfs(struct ieee80211_local *local);
--- dscape.orig/net/d80211/ieee80211_iface.c
+++ dscape/net/d80211/ieee80211_iface.c
@@ -93,6 +93,63 @@ fail:
 	return ret;
 }
 
+int ieee80211_if_add_mgmt(struct net_device *dev)
+{
+	struct net_device *ndev;
+	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_sub_if_data *sdata, *nsdata;
+	int alloc_size, ret;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	ASSERT_RTNL();
+	alloc_size = sizeof(struct net_device) + 3 +
+		sizeof(struct ieee80211_sub_if_data) + 3;
+
+	ndev = (struct net_device *) kzalloc(alloc_size, GFP_KERNEL);
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
+	ieee80211_if_mgmt_setup(ndev);
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
+	kfree(ndev);
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
@@ -110,6 +167,7 @@ void ieee80211_if_set_type(struct net_de
 		sdata->u.ap.max_ratectrl_rateidx = -1;
 		skb_queue_head_init(&sdata->u.ap.ps_bc_buf);
 		sdata->bss = &sdata->u.ap;
+		sdata->type = IEEE80211_IF_TYPE_STA;
 		break;
 	case IEEE80211_IF_TYPE_STA:
 	case IEEE80211_IF_TYPE_IBSS: {
@@ -263,8 +321,7 @@ int ieee80211_if_remove(struct net_devic
 	list_for_each_entry_safe(sdata, n, &local->sub_if_list, list) {
 		if ((sdata->type == id || id == -1) &&
 		    strcmp(name, sdata->dev->name) == 0 &&
-		    sdata->dev != local->mdev &&
-		    sdata->dev != local->apdev) {
+		    sdata->dev != local->mdev) {
 			__ieee80211_if_del(local, sdata);
 			return 0;
 		}
@@ -298,6 +355,9 @@ void ieee80211_if_del(struct net_device 
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
 	rtnl_lock();
-	__ieee80211_if_del(local, sdata);
+	if (sdata->type == IEEE80211_IF_TYPE_MGMT)
+		ieee80211_if_del_mgmt(local->mdev);
+	else
+		__ieee80211_if_del(local, sdata);
 	rtnl_unlock();
 }
--- dscape.orig/net/d80211/ieee80211_ioctl.c
+++ dscape/net/d80211/ieee80211_ioctl.c
@@ -2471,6 +2471,16 @@ static int ieee80211_ioctl_prism2_param(
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
 	default:
 		ret = -EOPNOTSUPP;
 		break;
@@ -2653,6 +2663,12 @@ static int ieee80211_ioctl_get_prism2_pa
 		else
 			*param = !!sdata->u.sta.wmm_enabled;
 		break;
+	case PRISM2_PARAM_MGMT_IF:
+		if (local->apdev)
+			*param = local->apdev->ifindex;
+		else
+			ret = -ENOENT;
+		break;
 
 	default:
 		ret = -EOPNOTSUPP;



