From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 1/3] d80211: get rid of default management interface
Date: Wed,  3 May 2006 17:11:28 +0200 (CEST)
Message-ID: <20060503151128.70354482B3@silver.suse.cz>
References: <20060503171031.304543000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:43648 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965214AbWECPKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 11:10:50 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060503171031.304543000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Default management interface (wmasterXap) confuses users. It is only needed
for AP mode (and only until the new netlink interface between kernel and
hostapd is implemented).

This patch removes default management interface. When first interface is
switched to AP mode, a management interface is created automatically.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c       |  101 ++++++++++++++++++------------------------
 net/d80211/ieee80211_i.h     |    4 +-
 net/d80211/ieee80211_iface.c |   74 +++++++++++++++++++++++++++++--
 3 files changed, 117 insertions(+), 62 deletions(-)

d809b662083c69de844d5fdcf33a8ef149c90b8e
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index ffb7985..1d6e87c 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
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
 
+static int ieee80211_ap_open(struct net_device *dev)
+{
+	struct ieee80211_local *local = dev->priv;
+
+	if (local->ap_open_count == 0)
+		return -EOPNOTSUPP;
+	return 0;
+}
+
+static int ieee80211_ap_stop(struct net_device *dev)
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
@@ -2087,7 +2098,11 @@ static int ieee80211_open(struct net_dev
 	}
         local->open_count++;
 
-	if (sdata->type == IEEE80211_IF_TYPE_MNTR)
+	if (sdata->type == IEEE80211_IF_TYPE_AP) {
+		local->ap_open_count++;
+		if (local->ap_open_count == 1)
+			dev_open(local->apdev);
+	} else if (sdata->type == IEEE80211_IF_TYPE_MNTR)
 		local->monitors++;
 
 	netif_start_queue(dev);
@@ -2112,7 +2127,11 @@ static int ieee80211_stop(struct net_dev
 
         netif_stop_queue(dev);
 
-	if (sdata->type == IEEE80211_IF_TYPE_MNTR)
+	if (sdata->type == IEEE80211_IF_TYPE_AP) {
+		local->ap_open_count--;
+		if (local->ap_open_count == 0)
+			dev_close(local->apdev);
+	} else if (sdata->type == IEEE80211_IF_TYPE_MNTR)
 		local->monitors--;
 
 	local->open_count--;
@@ -2367,6 +2386,10 @@ ieee80211_rx_mgmt(struct net_device *dev
 
 	if (msg_type != ieee80211_msg_monitor)
 		dev = local->apdev;
+	if (!dev) {
+		dev_kfree_skb(skb);
+		return;
+	}
         skb->dev = dev;
 
         sdata = IEEE80211_DEV_TO_SUB_IF(dev);
@@ -3998,6 +4021,19 @@ void ieee80211_if_setup(struct net_devic
 	dev->destructor = ieee80211_if_free;
 }
 
+void ieee80211_if_ap_setup(struct net_device *dev)
+{
+	ether_setup(dev);
+	dev->hard_start_xmit = ieee80211_mgmt_start_xmit;
+	dev->change_mtu = ieee80211_change_mtu_apdev;
+	dev->get_stats = ieee80211_get_stats;
+	dev->open = ieee80211_ap_open;
+	dev->stop = ieee80211_ap_stop;
+	dev->type = ARPHRD_IEEE80211_PRISM;
+	dev->hard_header_parse = header_parse_80211;
+	dev->tx_queue_len = 0;
+	dev->destructor = ieee80211_if_free;
+}
 
 static void ieee80211_precalc_rates(struct ieee80211_hw *hw)
 {
@@ -4018,7 +4054,7 @@ static void ieee80211_precalc_rates(stru
 struct net_device *ieee80211_alloc_hw(size_t priv_data_len,
 				      void (*setup)(struct net_device *))
 {
-	struct net_device *apdev, *mdev;
+	struct net_device *mdev;
         struct ieee80211_local *local;
         struct ieee80211_sub_if_data *sdata;
 	int alloc_size;
@@ -4038,17 +4074,11 @@ struct net_device *ieee80211_alloc_hw(si
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
@@ -4061,15 +4091,10 @@ struct net_device *ieee80211_alloc_hw(si
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
@@ -4104,28 +4129,6 @@ struct net_device *ieee80211_alloc_hw(si
 
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
@@ -4155,10 +4158,6 @@ struct net_device *ieee80211_alloc_hw(si
 		setup(mdev);
 
 	return mdev;
-
- fail:
-	ieee80211_free_hw(mdev);
-	return NULL;
 }
 
 
@@ -4193,15 +4192,11 @@ int ieee80211_register_hw(struct net_dev
 
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
@@ -4226,9 +4221,7 @@ int ieee80211_register_hw(struct net_dev
 
 fail_rate:
 	unregister_netdev(dev);
-fail_2nd_dev:
-	unregister_netdev(local->apdev);
-fail_1st_dev:
+fail_dev:
 	sta_info_stop(local);
 	ieee80211_unregister_sysfs(local);
 fail_sysfs:
@@ -4247,12 +4240,6 @@ int ieee80211_update_hw(struct net_devic
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
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index ee0b399..15dcc95 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -320,6 +320,7 @@ struct ieee80211_local {
 	struct net_device *apdev; /* wlan#ap - management frames (hostapd) */
 	int open_count;
 	int monitors;
+	int ap_count, ap_open_count;
 	struct ieee80211_conf conf;
 
 	int dev_index;
@@ -518,6 +519,7 @@ void ieee80211_prepare_rates(struct net_
 void ieee80211_tx_set_iswep(struct ieee80211_txrx_data *tx);
 int ieee80211_if_update_wds(struct net_device *dev, u8 *remote_addr);
 void ieee80211_if_setup(struct net_device *dev);
+void ieee80211_if_ap_setup(struct net_device *dev);
 
 /* ieee80211_ioctl.c */
 int ieee80211_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
@@ -586,7 +588,7 @@ int ieee80211_dev_find_index(struct ieee
 /* ieee80211_iface.c */
 int ieee80211_if_add(struct net_device *dev, const char *name,
 		     int format, struct net_device **new_dev);
-void ieee80211_if_set_type(struct net_device *dev, int type);
+int ieee80211_if_set_type(struct net_device *dev, int type);
 void ieee80211_if_reinit(struct net_device *dev);
 void __ieee80211_if_del(struct ieee80211_local *local,
 			struct ieee80211_sub_if_data *sdata);
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index f3ce45f..2738c94 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -93,9 +93,64 @@ fail:
 	return ret;
 }
 
-void ieee80211_if_set_type(struct net_device *dev, int type)
+static int ieee80211_if_add_apdev(struct net_device *dev)
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
+	snprintf(ndev->name, IFNAMSIZ, "%sap", dev->name);
+
+	ndev->priv = local;
+	memcpy(ndev->dev_addr, dev->dev_addr, ETH_ALEN);
+	ndev->base_addr = dev->base_addr;
+	ndev->irq = dev->irq;
+	ndev->mem_start = dev->mem_start;
+	ndev->mem_end = dev->mem_end;
+	ieee80211_if_ap_setup(ndev);
+
+	nsdata = IEEE80211_DEV_TO_SUB_IF(ndev);
+	nsdata->type = IEEE80211_IF_TYPE_AP;
+	nsdata->master = local->mdev;
+	nsdata->dev = ndev;
+	nsdata->local = local;
+	ieee80211_if_sdata_init(nsdata);
+
+	ret = register_netdevice(ndev);
+	if (ret) {
+		if (ret == -EEXIST)
+			printk(KERN_DEBUG "%s: apdev name %s already exists\n",
+			       dev->name, ndev->name);
+		kfree(ndev);
+		return ret;
+	}
+	local->apdev = ndev;
+	return 0;
+}
+
+static void ieee80211_if_del_apdev(struct net_device *dev)
+{
+	struct ieee80211_local *local = dev->priv;
+
+	ASSERT_RTNL();
+	unregister_netdevice(local->apdev);
+	local->apdev = NULL;
+}
+
+int ieee80211_if_set_type(struct net_device *dev, int type)
 {
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_local *local = dev->priv;
+	int res = 0;
 
 	sdata->type = type;
 	switch (type) {
@@ -110,7 +165,14 @@ void ieee80211_if_set_type(struct net_de
 		sdata->u.ap.max_ratectrl_rateidx = -1;
 		skb_queue_head_init(&sdata->u.ap.ps_bc_buf);
 		sdata->bss = &sdata->u.ap;
-		break;
+		if (local->ap_count == 0)
+			res = ieee80211_if_add_apdev(sdata->master);
+		if (res == 0) {
+			local->ap_count++;
+			break;
+		}
+		sdata->type = IEEE80211_IF_TYPE_STA;
+		/* fallback to STA, but keep error value in `res' */
 	case IEEE80211_IF_TYPE_STA:
 	case IEEE80211_IF_TYPE_IBSS: {
 		struct ieee80211_sub_if_data *msdata;
@@ -137,7 +199,9 @@ void ieee80211_if_set_type(struct net_de
 	default:
 		printk(KERN_WARNING "%s: %s: Unknown interface type 0x%x",
 		       dev->name, __FUNCTION__, type);
+		res = -EINVAL;
 	}
+	return res;
 }
 
 /* Must be called with rtnl lock held. */
@@ -189,6 +253,9 @@ #endif
 				local->total_ps_buffered--;
 				dev_kfree_skb(skb);
 			}
+			local->ap_count--;
+			if (local->ap_count == 0)
+				ieee80211_if_del_apdev(sdata->master);
 		}
 
 		break;
@@ -263,8 +330,7 @@ int ieee80211_if_remove(struct net_devic
 	list_for_each_entry_safe(sdata, n, &local->sub_if_list, list) {
 		if ((sdata->type == id || id == -1) &&
 		    strcmp(name, sdata->dev->name) == 0 &&
-		    sdata->dev != local->mdev &&
-		    sdata->dev != local->apdev) {
+		    sdata->dev != local->mdev) {
 			__ieee80211_if_del(local, sdata);
 			return 0;
 		}
-- 
1.3.0

