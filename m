From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 3/12] d80211: separate allocation of ieee80211_local
Date: Thu,  8 Jun 2006 09:49:07 +0200 (CEST)
Message-ID: <20060608074907.2CB5B48391@silver.suse.cz>
References: <20060608094822.014829000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:52120 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964774AbWFHHr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 03:47:57 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060608094822.014829000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ieee80211_local has a separate class_device. That means it has reference
counting independent of master net_device and can be freed at a different
time, therefore these two structures cannot be allocated together.

Solve this by adding ieee80211_ptr pointer to net_device structure (similar
to other pointers already presented there) and using it as a pointer to
independently allocated ieee80211_local.

This also allows is_ieee80211_device function to be nice finally.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 include/linux/netdevice.h    |    1 
 net/d80211/ieee80211.c       |  100 +++++++++++++++++++++---------------------
 net/d80211/ieee80211_dev.c   |   17 +++++++
 net/d80211/ieee80211_i.h     |    9 +++-
 net/d80211/ieee80211_iface.c |   20 ++++----
 net/d80211/ieee80211_ioctl.c |   92 +++++++++++++++++++--------------------
 net/d80211/ieee80211_proc.c  |    6 +--
 net/d80211/ieee80211_scan.c  |   10 ++--
 net/d80211/ieee80211_sta.c   |   58 ++++++++++++------------
 net/d80211/ieee80211_sysfs.c |   26 ++++++++---
 net/d80211/rate_control.c    |    4 +-
 net/d80211/rate_control.h    |    4 +-
 net/d80211/wme.c             |   26 +++++------
 13 files changed, 206 insertions(+), 167 deletions(-)

3085d33e38881f0987329c4258514f60ffe824af
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f4169bb..037e63a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -371,6 +371,7 @@ #define NETIF_F_UFO             8192    
 	void                    *ip6_ptr;       /* IPv6 specific data */
 	void			*ec_ptr;	/* Econet specific data	*/
 	void			*ax25_ptr;	/* AX.25 specific data */
+	void			*ieee80211_ptr;	/* IEEE 802.11 specific data */
 
 /*
  * Cache line mostly used on receive path (including eth_type_trans())
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 9724a49..4fc2e7d 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -110,7 +110,7 @@ static int rate_list_match(int *rate_lis
 
 void ieee80211_prepare_rates(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	int i;
 
 	for (i = 0; i < local->num_curr_rates; i++) {
@@ -1059,7 +1059,7 @@ __ieee80211_tx_prepare(struct ieee80211_
 		       struct net_device *dev,
 		       struct ieee80211_tx_control *control)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 	int hdrlen;
 
@@ -1095,12 +1095,9 @@ __ieee80211_tx_prepare(struct ieee80211_
 
 }
 
-/* FIXME: This is not nice but currently there doesn't exist more elegant way */
 static int inline is_ieee80211_device(struct net_device *dev)
 {
-	return (dev->wireless_handlers ==
-		(struct iw_handler_def *) &ieee80211_iw_handler_def) ||
-	       (dev->hard_start_xmit == ieee80211_mgmt_start_xmit);
+	return (dev->ieee80211_ptr != NULL);
 }
 
 /* Device in tx->dev has a reference added; use dev_put(tx->dev) when
@@ -1131,7 +1128,7 @@ static void inline ieee80211_tx_prepare(
 static int ieee80211_tx(struct net_device *dev, struct sk_buff *skb,
 			struct ieee80211_tx_control *control, int mgmt)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sta_info *sta;
 	ieee80211_tx_handler *handler;
 	struct ieee80211_txrx_data tx;
@@ -1307,7 +1304,7 @@ #endif
 static int ieee80211_subif_start_xmit(struct sk_buff *skb,
 				      struct net_device *dev)
 {
-        struct ieee80211_local *local = (struct ieee80211_local *) dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_tx_packet_data *pkt_data;
         struct ieee80211_sub_if_data *sdata;
 	int ret = 1, head_need;
@@ -1613,7 +1610,7 @@ static void ieee80211_beacon_add_tim(str
 struct sk_buff * ieee80211_beacon_get(struct net_device *dev, int if_id,
 				      struct ieee80211_tx_control *control)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sk_buff *skb;
 	struct net_device *bdev;
 	struct ieee80211_sub_if_data *sdata = NULL;
@@ -1690,7 +1687,7 @@ struct sk_buff *
 ieee80211_get_buffered_bc(struct net_device *dev, int if_id,
 			  struct ieee80211_tx_control *control)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sk_buff *skb;
 	struct sta_info *sta;
 	ieee80211_tx_handler *handler;
@@ -1754,7 +1751,7 @@ ieee80211_get_buffered_bc(struct net_dev
 int ieee80211_if_config(struct net_device *dev)
 {
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_if_conf conf;
 
 	if (!local->hw->config_interface || !netif_running(dev))
@@ -1780,7 +1777,7 @@ int ieee80211_if_config(struct net_devic
 
 int ieee80211_hw_config(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	int i, ret = 0;
 
 #ifdef CONFIG_D80211_VERBOSE_DEBUG
@@ -1811,7 +1808,7 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 
 struct ieee80211_conf *ieee80211_get_hw_conf(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
         return &local->conf;
 }
 
@@ -1854,7 +1851,7 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 
 static void ieee80211_tx_timeout(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	printk(KERN_WARNING "%s: resetting interface.\n", dev->name);
 
@@ -1878,7 +1875,7 @@ static int ieee80211_set_mac_address(str
 
 static void ieee80211_set_multicast_list(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
         struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	unsigned short flags;
 
@@ -1920,7 +1917,7 @@ struct dev_mc_list *ieee80211_get_mc_lis
 					       struct dev_mc_list *prev,
 					       void **ptr)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sub_if_data *sdata = *ptr;
 	struct dev_mc_list *mc;
 
@@ -1966,7 +1963,7 @@ static inline int identical_mac_addr_all
 
 static int ieee80211_master_open(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sub_if_data *sdata;
 	int res = -EOPNOTSUPP;
 
@@ -1981,7 +1978,7 @@ static int ieee80211_master_open(struct 
 
 static int ieee80211_master_stop(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sub_if_data *sdata;
 
 	list_for_each_entry(sdata, &local->sub_if_list, list) {
@@ -1993,7 +1990,7 @@ static int ieee80211_master_stop(struct 
 
 static int ieee80211_mgmt_open(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	if (!netif_running(local->mdev))
 		return -EOPNOTSUPP;
@@ -2038,7 +2035,7 @@ static void ieee80211_start_hard_monitor
 static int ieee80211_open(struct net_device *dev)
 {
 	struct ieee80211_sub_if_data *sdata, *nsdata;
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_if_init_conf conf;
 	int res;
 
@@ -2117,7 +2114,7 @@ static int ieee80211_open(struct net_dev
 static int ieee80211_stop(struct net_device *dev)
 {
 	struct ieee80211_sub_if_data *sdata;
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
@@ -2381,7 +2378,7 @@ void
 ieee80211_rx_mgmt(struct net_device *dev, struct sk_buff *skb,
 		  struct ieee80211_rx_status *status, u32 msg_type)
 {
-        struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
         struct ieee80211_frame_info *fi;
         size_t hlen;
         struct ieee80211_sub_if_data *sdata;
@@ -2545,7 +2542,7 @@ #endif /* IEEE80211_VERBOSE_DEBUG_PS */
 
 static int ap_sta_ps_end(struct net_device *dev, struct sta_info *sta)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sk_buff *skb;
 	int sent = 0;
 	struct ieee80211_sub_if_data *sdata;
@@ -3356,7 +3353,7 @@ static inline void ieee80211_invoke_rx_h
 void __ieee80211_rx(struct net_device *dev, struct sk_buff *skb,
 		    struct ieee80211_rx_status *status)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sub_if_data *sdata;
 	struct sta_info *sta;
 	struct ieee80211_hdr *hdr;
@@ -3629,7 +3626,7 @@ static void ieee80211_stat_refresh(unsig
 void ieee80211_rx_irqsafe(struct net_device *dev, struct sk_buff *skb,
 			  struct ieee80211_rx_status *status)
 {
-        struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_rx_status *saved;
 
         skb->dev = dev;
@@ -3646,7 +3643,7 @@ void ieee80211_rx_irqsafe(struct net_dev
 void ieee80211_tx_status_irqsafe(struct net_device *dev, struct sk_buff *skb,
 				 struct ieee80211_tx_status *status)
 {
-        struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_tx_status *saved;
 	int tmp;
 
@@ -3786,7 +3783,7 @@ void ieee80211_tx_status(struct net_devi
 {
 	struct sk_buff *skb2;
         struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
-        struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	u16 frag, type;
 	u32 msg_type;
 
@@ -3974,7 +3971,7 @@ static ieee80211_tx_handler ieee80211_tx
 
 int ieee80211_if_update_wds(struct net_device *dev, u8 *remote_addr)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct sta_info *sta;
 
@@ -3998,7 +3995,7 @@ int ieee80211_if_update_wds(struct net_d
 
 static void ieee80211_if_init(struct net_device *dev)
 {
-        struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 
         spin_lock_init(&local->sub_if_lock);
         INIT_LIST_HEAD(&local->sub_if_list);
@@ -4065,6 +4062,10 @@ struct net_device *ieee80211_alloc_hw(si
         struct ieee80211_sub_if_data *sdata;
 	int priv_size;
 
+	local = ieee80211_dev_alloc(GFP_KERNEL);
+	if (!local)
+		return NULL;
+
 	/* Ensure 32-byte alignment of our private data and hw private data.
 	 * Each net_device is followed by a sub_if_data which is used for
 	 * interface specific information.
@@ -4075,30 +4076,24 @@ struct net_device *ieee80211_alloc_hw(si
          *      * net_dev       *
 	 * 0160 *****************
          *      * sub_if        *
-	 * 0180 *****************
-         *      * local         *
 	 * 0b80 *****************
          *      * hw_priv       *
          * 1664 *****************
          */
 	priv_size = ((sizeof(struct ieee80211_sub_if_data) +
 		      NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST) +
-		    ((sizeof(struct ieee80211_local) +
-		      NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST) +
 		    priv_data_len;
 	mdev = alloc_netdev(priv_size, "wmaster%d", ether_setup);
-	if (mdev == NULL)
+	if (mdev == NULL) {
+		ieee80211_dev_free(local);
 		return NULL;
+	}
 
-	mdev->priv = (char *)netdev_priv(mdev) +
-		     ((sizeof(struct ieee80211_sub_if_data) +
-		       NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
-	local = mdev->priv;
-	local->hw_priv = (char *)local +
-			 ((sizeof(struct ieee80211_local) +
+	mdev->ieee80211_ptr = local;
+	local->hw_priv = (char *)mdev->priv +
+			 ((sizeof(struct ieee80211_sub_if_data) +
 			   NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
 
-	local->dev_index = -1;
 	local->mdev = mdev;
         local->rx_handlers = ieee80211_rx_handlers;
         local->tx_handlers = ieee80211_tx_handlers;
@@ -4166,7 +4161,7 @@ struct net_device *ieee80211_alloc_hw(si
 
 int ieee80211_register_hw(struct net_device *dev, struct ieee80211_hw *hw)
 {
-        struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct net_device *sta_dev;
 	int result;
 
@@ -4185,7 +4180,7 @@ int ieee80211_register_hw(struct net_dev
 		return -1;
 
 	local->class_dev.dev = dev->class_dev.dev;
-	result = ieee80211_register_sysfs(local);
+	result = ieee80211_dev_sysfs_add(local);
 	if (result < 0)
 		goto fail_sysfs;
 
@@ -4240,7 +4235,7 @@ fail_if_sysfs:
 	unregister_netdev(dev);
 fail_dev:
 	sta_info_stop(local);
-	ieee80211_unregister_sysfs(local);
+	ieee80211_dev_sysfs_del(local);
 fail_sysfs:
 	ieee80211_dev_free_index(local);
 	return result;
@@ -4248,7 +4243,7 @@ fail_sysfs:
 
 int ieee80211_update_hw(struct net_device *dev, struct ieee80211_hw *hw)
 {
-        struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	local->hw = hw;
 
@@ -4280,7 +4275,7 @@ int ieee80211_update_hw(struct net_devic
 
 void ieee80211_unregister_hw(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
         struct list_head *ptr, *n;
 	int i;
 
@@ -4305,7 +4300,7 @@ void ieee80211_unregister_hw(struct net_
 	}
 
 	sta_info_stop(local);
-	ieee80211_unregister_sysfs(local);
+	ieee80211_dev_sysfs_del(local);
 
 	for (i = 0; i < IEEE80211_FRAGMENT_MAX; i++)
 		if (local->fragments[i].skb)
@@ -4330,14 +4325,21 @@ void ieee80211_unregister_hw(struct net_
 
 void ieee80211_free_hw(struct net_device *dev)
 {
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+
 	free_netdev(dev);
+	ieee80211_dev_free(local);
 }
 
+void ieee80211_release_hw(struct ieee80211_local *local)
+{
+	kfree(local);
+}
 
 /* Perform netif operations on all configured interfaces */
 int ieee80211_netif_oper(struct net_device *sdev, Netif_Oper op)
 {
-        struct ieee80211_local *local = sdev->priv;
+	struct ieee80211_local *local = sdev->ieee80211_ptr;
         struct ieee80211_sub_if_data *sdata =  IEEE80211_DEV_TO_SUB_IF(sdev);
         struct net_device *dev = sdata->master;
 
@@ -4377,7 +4379,7 @@ #endif
 
 void * ieee80211_dev_hw_data(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	return local->hw_priv;
 }
 
diff --git a/net/d80211/ieee80211_dev.c b/net/d80211/ieee80211_dev.c
index 6278cfa..6c6ca91 100644
--- a/net/d80211/ieee80211_dev.c
+++ b/net/d80211/ieee80211_dev.c
@@ -99,3 +99,20 @@ int ieee80211_dev_find_index(struct ieee
 	spin_unlock(&dev_list_lock);
 	return index;
 }
+
+struct ieee80211_local *ieee80211_dev_alloc(gfp_t flags)
+{
+	struct ieee80211_local *local;
+
+	local = kzalloc(sizeof(struct ieee80211_local), flags);
+	if (!local)
+		return NULL;
+	local->dev_index = -1;
+	ieee80211_dev_sysfs_init(local);
+	return local;
+}
+
+void ieee80211_dev_free(struct ieee80211_local *local)
+{
+	ieee80211_dev_sysfs_put(local);
+}
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 19d9d98..84cc50e 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -505,6 +505,7 @@ #endif /* CONFIG_D80211_DEBUG_COUNTERS *
 
 
 /* ieee80211.c */
+void ieee80211_release_hw(struct ieee80211_local *local);
 int ieee80211_hw_config(struct net_device *dev);
 int ieee80211_if_config(struct net_device *dev);
 struct ieee80211_key_conf *
@@ -582,6 +583,8 @@ int ieee80211_dev_alloc_index(struct iee
 void ieee80211_dev_free_index(struct ieee80211_local *local);
 struct ieee80211_local *ieee80211_dev_find(int index);
 int ieee80211_dev_find_index(struct ieee80211_local *local);
+struct ieee80211_local *ieee80211_dev_alloc(gfp_t flags);
+void ieee80211_dev_free(struct ieee80211_local *local);
 
 /* ieee80211_iface.c */
 int ieee80211_if_add(struct net_device *dev, const char *name,
@@ -601,8 +604,10 @@ void ieee80211_if_del_mgmt(struct net_de
 /* ieee80211_sysfs.c */
 int ieee80211_sysfs_add_netdevice(struct net_device *dev);
 void ieee80211_sysfs_remove_netdevice(struct net_device *dev);
-int ieee80211_register_sysfs(struct ieee80211_local *local);
-void ieee80211_unregister_sysfs(struct ieee80211_local *local);
+void ieee80211_dev_sysfs_init(struct ieee80211_local *local);
+void ieee80211_dev_sysfs_put(struct ieee80211_local *local);
+int ieee80211_dev_sysfs_add(struct ieee80211_local *local);
+void ieee80211_dev_sysfs_del(struct ieee80211_local *local);
 int ieee80211_sysfs_init(void);
 void ieee80211_sysfs_deinit(void);
 
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index d534fe4..8ab2c07 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -29,7 +29,7 @@ int ieee80211_if_add(struct net_device *
 		     int format, struct net_device **new_dev)
 {
 	struct net_device *ndev, *tmp_dev;
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sub_if_data *sdata = NULL, *sdata_parent;
 	int ret;
 	int i;
@@ -40,7 +40,7 @@ int ieee80211_if_add(struct net_device *
 	if (ndev == NULL)
 		return -ENOMEM;
 
-	ndev->priv = local;
+	ndev->ieee80211_ptr = local;
 	if (strlen(name) == 0) {
 		i = 0;
 		do {
@@ -98,7 +98,7 @@ fail:
 int ieee80211_if_add_mgmt(struct net_device *dev)
 {
 	struct net_device *ndev;
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sub_if_data *sdata, *nsdata;
 	int ret;
 
@@ -113,7 +113,7 @@ int ieee80211_if_add_mgmt(struct net_dev
 	if (ret)
 		goto fail;
 
-	ndev->priv = local;
+	ndev->ieee80211_ptr = local;
 	memcpy(ndev->dev_addr, dev->dev_addr, ETH_ALEN);
 	ndev->base_addr = dev->base_addr;
 	ndev->irq = dev->irq;
@@ -147,7 +147,7 @@ fail:
 
 void ieee80211_if_del_mgmt(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct net_device *apdev;
 
 	ASSERT_RTNL();
@@ -207,7 +207,7 @@ void ieee80211_if_set_type(struct net_de
 /* Must be called with rtnl lock held. */
 void ieee80211_if_reinit(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct sta_info *sta;
 	int i;
@@ -316,7 +316,7 @@ void __ieee80211_if_del(struct ieee80211
 /* Must be called with rtnl lock held. */
 int ieee80211_if_remove(struct net_device *dev, const char *name, int id)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sub_if_data *sdata, *n;
 
 	ASSERT_RTNL();
@@ -337,7 +337,7 @@ int ieee80211_if_remove(struct net_devic
 
 void ieee80211_if_free(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	BUG_ON(dev == local->mdev || dev == local->apdev);
 	free_netdev(dev);
@@ -346,7 +346,7 @@ void ieee80211_if_free(struct net_device
 /* Must be called with rtnl lock held. */
 void ieee80211_if_flush(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sub_if_data *sdata, *n;
 
 	ASSERT_RTNL();
@@ -357,7 +357,7 @@ void ieee80211_if_flush(struct net_devic
 
 void ieee80211_if_del(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
 	rtnl_lock();
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 30dfc76..8d593e8 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -118,7 +118,7 @@ static int ieee80211_ioctl_get_hw_featur
 					   struct prism2_hostapd_param *param,
 					   int param_len)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	u8 *pos = param->u.hw_features.data;
 	int left = param_len - (pos - (u8 *) param);
 	int mode, i;
@@ -169,7 +169,7 @@ static int ieee80211_ioctl_get_hw_featur
 static int ieee80211_ioctl_scan(struct net_device *dev,
                                 struct prism2_hostapd_param *param)
 {
-        struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	if (local->hw->passive_scan == NULL)
 		return -EOPNOTSUPP;
@@ -209,7 +209,7 @@ static int ieee80211_ioctl_scan(struct n
 static int ieee80211_ioctl_flush(struct net_device *dev,
 				 struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	sta_info_flush(local, NULL);
 	return 0;
 }
@@ -218,7 +218,7 @@ static int ieee80211_ioctl_flush(struct 
 static int ieee80211_ioctl_add_sta(struct net_device *dev,
 				   struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sta_info *sta;
 	u32 rates;
 	int i, j;
@@ -303,7 +303,7 @@ static int ieee80211_ioctl_add_sta(struc
 static int ieee80211_ioctl_remove_sta(struct net_device *dev,
 				      struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sta_info *sta;
 
 	sta = sta_info_get(local, param->sta_addr);
@@ -319,7 +319,7 @@ static int ieee80211_ioctl_remove_sta(st
 static int ieee80211_ioctl_get_dot11counterstable(struct net_device *dev,
 					struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
         struct ieee80211_low_level_stats stats;
 
 	memset(&stats, 0, sizeof(stats));
@@ -351,7 +351,7 @@ static int ieee80211_ioctl_get_dot11coun
 static int ieee80211_ioctl_get_info_sta(struct net_device *dev,
 					struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sta_info *sta;
 
 	if (param->sta_addr[0] == 0xff && param->sta_addr[1] == 0xff &&
@@ -402,7 +402,7 @@ static int ieee80211_ioctl_get_info_sta(
 static int ieee80211_ioctl_set_flags_sta(struct net_device *dev,
 					 struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sta_info *sta;
 
 	sta = sta_info_get(local, param->sta_addr);
@@ -433,7 +433,7 @@ int ieee80211_set_hw_encryption(struct n
 				struct ieee80211_key *key)
 {
 	struct ieee80211_key_conf *keyconf = NULL;
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	int rc = 0;
 
 	/* default to sw encryption; this will be cleared by low-level
@@ -467,7 +467,7 @@ static int ieee80211_set_encryption(stru
 				    int idx, int alg, int set_tx_key, int *err,
 				    const u8 *_key, size_t key_len)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	int ret = 0;
 	struct sta_info *sta;
 	struct ieee80211_key **key;
@@ -706,7 +706,7 @@ static int ieee80211_ioctl_get_encryptio
 					  struct prism2_hostapd_param *param,
 					  int param_len)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	int ret = 0;
 	struct sta_info *sta;
 	struct ieee80211_key **key;
@@ -823,7 +823,7 @@ #ifdef CONFIG_HOSTAPD_WPA_TESTING
 static int ieee80211_ioctl_wpa_trigger(struct net_device *dev,
 				       struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sta_info *sta;
 
 	if (param->sta_addr[0] == 0xff && param->sta_addr[1] == 0xff &&
@@ -852,7 +852,7 @@ static int ieee80211_ioctl_set_rate_sets
 					 struct prism2_hostapd_param *param,
 					 int param_len)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	u16 *pos = (u16 *) param->u.set_rate_sets.data;
 	int left = param_len - ((u8 *) pos - (u8 *) param);
 	int i, mode, num_supp, num_basic, *supp, *basic, *prev;
@@ -937,7 +937,7 @@ static int ieee80211_ioctl_add_if(struct
 		ieee80211_if_set_type(new_dev, IEEE80211_IF_TYPE_WDS);
 		res = ieee80211_if_update_wds(new_dev, wds->remote_addr);
 		if (res)
-			__ieee80211_if_del(dev->priv,
+			__ieee80211_if_del(dev->ieee80211_ptr,
 					   IEEE80211_DEV_TO_SUB_IF(new_dev));
 		return res;
 	} else if (param->u.if_info.type == HOSTAP_IF_VLAN) {
@@ -951,7 +951,7 @@ static int ieee80211_ioctl_add_if(struct
 #if 0
 		res = ieee80211_if_update_vlan(new_dev, vlan->id);
 		if (res)
-			__ieee80211_if_del(dev->priv,
+			__ieee80211_if_del(dev->ieee80211_ptr,
 					   IEEE80211_DEV_TO_SUB_IF(new_dev));
 #endif
 		return res;
@@ -1013,7 +1013,7 @@ static int ieee80211_ioctl_update_if(str
 	if (param->u.if_info.type == HOSTAP_IF_WDS) {
 		struct hostapd_if_wds *wds =
 			(struct hostapd_if_wds *) param->u.if_info.data;
-		struct ieee80211_local *local = dev->priv;
+		struct ieee80211_local *local = dev->ieee80211_ptr;
 		struct net_device *wds_dev = NULL;
 		struct ieee80211_sub_if_data *sdata;
 
@@ -1050,7 +1050,7 @@ static int ieee80211_ioctl_scan_req(stru
 				    struct prism2_hostapd_param *param,
 				    int param_len)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	u8 *pos = param->u.scan_req.ssid;
 	int left = param_len - ((u8 *) pos - (u8 *) param);
 	int len = param->u.scan_req.ssid_len;
@@ -1082,7 +1082,7 @@ static int ieee80211_ioctl_sta_get_state
 static int ieee80211_ioctl_mlme(struct net_device *dev,
 				struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sub_if_data *sdata;
 
 	if (local->user_space_mlme)
@@ -1105,7 +1105,7 @@ static int ieee80211_ioctl_mlme(struct n
 static int ieee80211_ioctl_get_load_stats(struct net_device *dev,
 					  struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	param->u.get_load_stats.channel_use = local->channel_use;
 /*	if (param->u.get_load_stats.flags & LOAD_STATS_CLEAR)
@@ -1118,7 +1118,7 @@ static int ieee80211_ioctl_get_load_stat
 static int ieee80211_ioctl_set_sta_vlan(struct net_device *dev,
                                         struct prism2_hostapd_param *param)
 {
-        struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
         struct sta_info *sta;
 
         sta = sta_info_get(local, param->sta_addr);
@@ -1146,7 +1146,7 @@ #endif
 static int ieee80211_set_gen_ie(struct net_device *dev, u8 *ie, size_t len)
 {
 	struct ieee80211_sub_if_data *sdata;
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	if (local->user_space_mlme)
 		return -EOPNOTSUPP;
@@ -1206,7 +1206,7 @@ static int
 ieee80211_ioctl_set_tx_queue_params(struct net_device *dev,
 				    struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_tx_queue_params qparam;
 
 	if (!local->hw->conf_tx) {
@@ -1229,7 +1229,7 @@ ieee80211_ioctl_set_tx_queue_params(stru
 static int ieee80211_ioctl_get_tx_stats(struct net_device *dev,
 					struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_tx_queue_stats stats;
 	int ret, i;
 
@@ -1254,7 +1254,7 @@ static int ieee80211_ioctl_get_tx_stats(
 static int ieee80211_ioctl_set_channel_flag(struct net_device *dev,
 					    struct prism2_hostapd_param *param)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_hw_modes *mode = NULL;
 	struct ieee80211_channel *chan = NULL;
 	int i;
@@ -1445,7 +1445,7 @@ static int ieee80211_ioctl_giwname(struc
 				   struct iw_request_info *info,
 				   char *name, char *extra)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	switch (local->conf.phymode) {
 	case MODE_IEEE80211A:
@@ -1589,7 +1589,7 @@ static void ieee80211_unmask_channel(str
 
 static int ieee80211_unmask_channels(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	int m, c;
 
 	for (m = 0; m < local->hw->num_modes; m++) {
@@ -1690,7 +1690,7 @@ int ieee80211_ioctl_siwfreq(struct net_d
 			    struct iw_request_info *info,
 			    struct iw_freq *freq, char *extra)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	int m, c, nfreq, set = 0;
 
 	/* freq->e == 0: freq->m = channel; otherwise freq = m * 10^e */
@@ -1743,7 +1743,7 @@ static int ieee80211_ioctl_giwfreq(struc
 				   struct iw_request_info *info,
 				   struct iw_freq *freq, char *extra)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	/* TODO: in station mode (Managed/Ad-hoc) might need to poll low-level
 	 * driver for the current channel with firmware-based management */
@@ -1759,7 +1759,7 @@ static int ieee80211_ioctl_siwessid(stru
 				    struct iw_request_info *info,
 				    struct iw_point *data, char *ssid)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sub_if_data *sdata;
         size_t len = data->length;
 
@@ -1827,7 +1827,7 @@ static int ieee80211_ioctl_siwap(struct 
 				 struct iw_request_info *info,
 				 struct sockaddr *ap_addr, char *extra)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sub_if_data *sdata;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
@@ -1876,7 +1876,7 @@ static int ieee80211_ioctl_siwscan(struc
 				   struct iw_request_info *info,
 				   struct iw_point *data, char *extra)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	u8 *ssid = NULL;
 	size_t ssid_len = 0;
@@ -1901,7 +1901,7 @@ static int ieee80211_ioctl_giwscan(struc
 				   struct iw_point *data, char *extra)
 {
 	int res;
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	if (local->sta_scanning)
 		return -EAGAIN;
 	res = ieee80211_sta_scan_results(dev, extra, IW_SCAN_MAX_DATA);
@@ -1918,7 +1918,7 @@ static int ieee80211_ioctl_siwrts(struct
 				  struct iw_request_info *info,
 				  struct iw_param *rts, char *extra)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	if (rts->disabled)
 		local->rts_threshold = IEEE80211_MAX_RTS_THRESHOLD;
@@ -1941,7 +1941,7 @@ static int ieee80211_ioctl_giwrts(struct
 				  struct iw_request_info *info,
 				  struct iw_param *rts, char *extra)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	rts->value = local->rts_threshold;
 	rts->disabled = (rts->value >= IEEE80211_MAX_RTS_THRESHOLD);
@@ -1955,7 +1955,7 @@ static int ieee80211_ioctl_siwfrag(struc
 				   struct iw_request_info *info,
 				   struct iw_param *frag, char *extra)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	if (frag->disabled)
 		local->fragmentation_threshold = IEEE80211_MAX_FRAG_THRESHOLD;
@@ -1982,7 +1982,7 @@ static int ieee80211_ioctl_giwfrag(struc
 				   struct iw_request_info *info,
 				   struct iw_param *frag, char *extra)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	frag->value = local->fragmentation_threshold;
 	frag->disabled = (frag->value >= IEEE80211_MAX_RTS_THRESHOLD);
@@ -1996,7 +1996,7 @@ static int ieee80211_ioctl_siwretry(stru
 				    struct iw_request_info *info,
 				    struct iw_param *retry, char *extra)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	if (retry->disabled ||
 	    (retry->flags & IW_RETRY_TYPE) != IW_RETRY_LIMIT)
@@ -2025,7 +2025,7 @@ static int ieee80211_ioctl_giwretry(stru
 				    struct iw_request_info *info,
 				    struct iw_param *retry, char *extra)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	retry->disabled = 0;
 	if ((retry->flags & IW_RETRY_TYPE) != IW_RETRY_LIMIT)
@@ -2060,7 +2060,7 @@ static void ieee80211_ioctl_unmask_chann
 
 static int ieee80211_ioctl_test_mode(struct net_device *dev, int mode)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	int ret = -EOPNOTSUPP;
 
 	if (mode == IEEE80211_TEST_UNMASK_CHANNELS) {
@@ -2077,7 +2077,7 @@ static int ieee80211_ioctl_test_mode(str
 
 static int ieee80211_ioctl_clear_keys(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_key_conf key;
 	struct list_head *ptr;
 	int i;
@@ -2138,7 +2138,7 @@ ieee80211_ioctl_force_unicast_rate(struc
 				   struct ieee80211_sub_if_data *sdata,
 				   int rate)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	int i;
 
 	if (sdata->type != IEEE80211_IF_TYPE_AP)
@@ -2164,7 +2164,7 @@ ieee80211_ioctl_max_ratectrl_rate(struct
 				  struct ieee80211_sub_if_data *sdata,
 				  int rate)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	int i;
 
 	if (sdata->type != IEEE80211_IF_TYPE_AP)
@@ -2254,7 +2254,7 @@ static int ieee80211_ioctl_prism2_param(
 					struct iw_request_info *info,
 					void *wrqu, char *extra)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sub_if_data *sdata;
 	int *i = (int *) extra;
 	int param = *i;
@@ -2524,7 +2524,7 @@ static int ieee80211_ioctl_get_prism2_pa
 					    struct iw_request_info *info,
 					    void *wrqu, char *extra)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sub_if_data *sdata;
 	int *param = (int *) extra;
 	int ret = 0;
@@ -2716,7 +2716,7 @@ static int ieee80211_ioctl_test_param(st
 				      struct iw_request_info *info,
 				      void *wrqu, char *extra)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	int *i = (int *) extra;
 	int param = *i;
 	int value = *(i + 1);
@@ -2849,7 +2849,7 @@ static int ieee80211_ioctl_siwauth(struc
 				   struct iw_request_info *info,
 				   struct iw_param *data, char *extra)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	int ret = 0;
 
diff --git a/net/d80211/ieee80211_proc.c b/net/d80211/ieee80211_proc.c
index c9f5567..4f3a6b9 100644
--- a/net/d80211/ieee80211_proc.c
+++ b/net/d80211/ieee80211_proc.c
@@ -269,7 +269,7 @@ static int ieee80211_proc_sta_read(char 
 		     sta->tx_fragments, sta->tx_filtered_count);
 	p = ieee80211_proc_key(p, sta->key, 0, 1);
 
-	local = (struct ieee80211_local *) sta->dev->priv;
+	local = (struct ieee80211_local *) sta->dev->ieee80211_ptr;
 	if (sta->txrate >= 0 && sta->txrate < local->num_curr_rates) {
 		p += sprintf(p, "txrate=%d\n",
 			     local->curr_rates[sta->txrate].rate);
@@ -676,7 +676,7 @@ void ieee80211_proc_deinit_sta(struct ie
 void ieee80211_proc_init_virtual(struct net_device *dev)
 {
 	struct proc_dir_entry *entry;
-	struct ieee80211_local *local = (struct ieee80211_local *) dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	if (!local->proc_iface)
 		return;
@@ -690,7 +690,7 @@ void ieee80211_proc_init_virtual(struct 
 
 void ieee80211_proc_deinit_virtual(struct net_device *dev)
 {
-	struct ieee80211_local *local = (struct ieee80211_local *) dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	if (local->proc_iface)
 		remove_proc_entry(dev->name, local->proc_iface);
diff --git a/net/d80211/ieee80211_scan.c b/net/d80211/ieee80211_scan.c
index 9984fd6..4184abf 100644
--- a/net/d80211/ieee80211_scan.c
+++ b/net/d80211/ieee80211_scan.c
@@ -110,7 +110,7 @@ static void next_chan_all_modes(struct i
 static void ieee80211_scan_start(struct net_device *dev,
 				 struct ieee80211_scan_conf *conf)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	int old_mode_idx = local->scan.mode_idx;
 	int old_chan_idx = local->scan.chan_idx;
 	struct ieee80211_hw_modes *mode = NULL;
@@ -209,7 +209,7 @@ #endif
 static void ieee80211_scan_stop(struct net_device *dev,
 				struct ieee80211_scan_conf *conf)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_hw_modes *mode;
 	struct ieee80211_channel *chan;
 	int wait;
@@ -258,7 +258,7 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 static void ieee80211_scan_handler(unsigned long uldev)
 {
         struct net_device *dev = (struct net_device *) uldev;
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_scan_conf conf;
 
 	if (local->scan.interval == 0 && !local->scan.in_scan) {
@@ -286,7 +286,7 @@ static void ieee80211_scan_handler(unsig
 
 void ieee80211_init_scan(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_hdr hdr;
 	u16 fc;
 	int len = 10;
@@ -342,7 +342,7 @@ void ieee80211_init_scan(struct net_devi
 
 void ieee80211_stop_scan(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	if (local->hw->passive_scan != 0) {
 		del_timer_sync(&local->scan.timer);
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index af58013..66a4575 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -234,7 +234,7 @@ static void ieee80211_sta_wmm_params(str
 				     struct ieee80211_if_sta *ifsta,
 				     u8 *wmm_param, size_t wmm_param_len)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_tx_queue_params params;
 	size_t left;
 	int count;
@@ -468,7 +468,7 @@ static void ieee80211_authenticate(struc
 static void ieee80211_send_assoc(struct net_device *dev,
 				 struct ieee80211_if_sta *ifsta)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sk_buff *skb;
 	struct ieee80211_mgmt *mgmt;
 	u8 *pos, *ies;
@@ -688,7 +688,7 @@ static void ieee80211_associate(struct n
 static void ieee80211_associated(struct net_device *dev,
 				 struct ieee80211_if_sta *ifsta)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sta_info *sta;
 	int disassoc;
 
@@ -749,7 +749,7 @@ static void ieee80211_associated(struct 
 static void ieee80211_send_probe_req(struct net_device *dev, u8 *dst,
 				     u8 *ssid, size_t ssid_len)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sk_buff *skb;
 	struct ieee80211_mgmt *mgmt;
 	u8 *pos, *supp_rates, *esupp_rates = NULL;
@@ -1079,7 +1079,7 @@ static void ieee80211_rx_mgmt_assoc_resp
 					 struct ieee80211_rx_status *rx_status,
 					 int reassoc)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sta_info *sta;
 	u32 rates;
 	u16 capab_info, status_code, aid;
@@ -1210,7 +1210,7 @@ static void ieee80211_rx_mgmt_assoc_resp
 static void __ieee80211_rx_bss_hash_add(struct net_device *dev,
 					struct ieee80211_sta_bss *bss)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	bss->hnext = local->sta_bss_hash[STA_HASH(bss->bssid)];
 	local->sta_bss_hash[STA_HASH(bss->bssid)] = bss;
 }
@@ -1220,7 +1220,7 @@ static void __ieee80211_rx_bss_hash_add(
 static void __ieee80211_rx_bss_hash_del(struct net_device *dev,
 					struct ieee80211_sta_bss *bss)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sta_bss *b, *prev = NULL;
 	b = local->sta_bss_hash[STA_HASH(bss->bssid)];
 	while (b) {
@@ -1242,7 +1242,7 @@ static void __ieee80211_rx_bss_hash_del(
 static struct ieee80211_sta_bss *
 ieee80211_rx_bss_add(struct net_device *dev, u8 *bssid)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sta_bss *bss;
 
 	bss = kmalloc(sizeof(*bss), GFP_ATOMIC);
@@ -1265,7 +1265,7 @@ ieee80211_rx_bss_add(struct net_device *
 static struct ieee80211_sta_bss *
 ieee80211_rx_bss_get(struct net_device *dev, u8 *bssid)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sta_bss *bss;
 
 	spin_lock_bh(&local->sta_bss_lock);
@@ -1294,7 +1294,7 @@ static void ieee80211_rx_bss_free(struct
 static void ieee80211_rx_bss_put(struct net_device *dev,
 				 struct ieee80211_sta_bss *bss)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	if (!atomic_dec_and_test(&bss->users))
 		return;
 
@@ -1308,7 +1308,7 @@ static void ieee80211_rx_bss_put(struct 
 
 void ieee80211_rx_bss_list_init(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	spin_lock_init(&local->sta_bss_lock);
 	INIT_LIST_HEAD(&local->sta_bss_list);
 }
@@ -1316,7 +1316,7 @@ void ieee80211_rx_bss_list_init(struct n
 
 void ieee80211_rx_bss_list_deinit(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sta_bss *bss;
 	struct list_head *ptr;
 
@@ -1336,7 +1336,7 @@ static void ieee80211_rx_bss_info(struct
 				  struct ieee80211_rx_status *rx_status,
 				  int beacon)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee802_11_elems elems;
 	size_t baselen;
 	int channel, invalid = 0, clen;
@@ -1587,7 +1587,7 @@ static void ieee80211_rx_mgmt_beacon(str
 				     size_t len,
 				     struct ieee80211_rx_status *rx_status)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sub_if_data *sdata;
 	struct ieee80211_if_sta *ifsta;
 	int use_protection;
@@ -1645,7 +1645,7 @@ static void ieee80211_rx_mgmt_probe_req(
 					size_t len,
 					struct ieee80211_rx_status *rx_status)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	int tx_last_beacon;
 	struct sk_buff *skb;
@@ -1802,7 +1802,7 @@ void ieee80211_sta_rx_scan(struct net_de
 
 static int ieee80211_sta_active_ibss(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct list_head *ptr;
 	int active = 0;
 	struct sta_info *sta;
@@ -1825,7 +1825,7 @@ static int ieee80211_sta_active_ibss(str
 
 static void ieee80211_sta_expire(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct list_head *ptr, *n;
 	struct sta_info *sta;
 
@@ -1911,7 +1911,7 @@ void ieee80211_sta_timer(unsigned long p
 static void ieee80211_sta_new_auth(struct net_device *dev,
 				   struct ieee80211_if_sta *ifsta)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
 	if (sdata->type != IEEE80211_IF_TYPE_STA)
@@ -1972,7 +1972,7 @@ static int ieee80211_sta_join_ibss(struc
 				   struct ieee80211_if_sta *ifsta,
 				   struct ieee80211_sta_bss *bss)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct iw_freq rq;
 	int res, rates, i, j;
 	struct sk_buff *skb;
@@ -2132,7 +2132,7 @@ static int ieee80211_sta_join_ibss(struc
 static int ieee80211_sta_create_ibss(struct net_device *dev,
 				     struct ieee80211_if_sta *ifsta)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sta_bss *bss;
 	struct ieee80211_sub_if_data *sdata;
 	u8 bssid[ETH_ALEN], *pos;
@@ -2189,7 +2189,7 @@ #endif
 static int ieee80211_sta_find_ibss(struct net_device *dev,
 				   struct ieee80211_if_sta *ifsta)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sta_bss *bss;
 	int found = 0;
 	u8 bssid[ETH_ALEN];
@@ -2281,7 +2281,7 @@ int ieee80211_sta_set_ssid(struct net_de
 {
 	struct ieee80211_sub_if_data *sdata;
 	struct ieee80211_if_sta *ifsta;
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	if (len > IEEE80211_MAX_SSID_LEN)
 		return -EINVAL;
@@ -2376,7 +2376,7 @@ int ieee80211_sta_set_bssid(struct net_d
 
 static void ieee80211_sta_save_oper_chan(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	local->scan_oper_channel = local->conf.channel;
 	local->scan_oper_channel_val = local->conf.channel_val;
 	local->scan_oper_power_level = local->conf.power_level;
@@ -2388,7 +2388,7 @@ static void ieee80211_sta_save_oper_chan
 
 static int ieee80211_sta_restore_oper_chan(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	local->conf.channel = local->scan_oper_channel;
 	local->conf.channel_val = local->scan_oper_channel_val;
 	local->conf.power_level = local->scan_oper_power_level;
@@ -2425,7 +2425,7 @@ static int ieee80211_active_scan(struct 
 static void ieee80211_sta_scan_timer(unsigned long ptr)
 {
 	struct net_device *dev = (struct net_device *) ptr;
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
         struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct ieee80211_hw_modes *mode;
 	struct ieee80211_channel *chan;
@@ -2526,7 +2526,7 @@ #endif
 
 int ieee80211_sta_req_scan(struct net_device *dev, u8 *ssid, size_t ssid_len)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	if (ssid_len > IEEE80211_MAX_SSID_LEN)
 		return -EINVAL;
@@ -2584,7 +2584,7 @@ ieee80211_sta_scan_result(struct net_dev
 			  struct ieee80211_sta_bss *bss,
 			  char *current_ev, char *end_buf)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct iw_event iwe;
 
 	if (time_after(jiffies,
@@ -2746,7 +2746,7 @@ ieee80211_sta_scan_result(struct net_dev
 
 int ieee80211_sta_scan_results(struct net_device *dev, char *buf, size_t len)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct list_head *ptr;
 	char *current_ev = buf;
 	char *end_buf = buf + len;
@@ -2791,7 +2791,7 @@ struct sta_info * ieee80211_ibss_add_sta
 					 struct sk_buff *skb, u8 *bssid,
 					 u8 *addr)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct list_head *ptr;
 	struct sta_info *sta;
 	struct ieee80211_sub_if_data *sdata = NULL;
diff --git a/net/d80211/ieee80211_sysfs.c b/net/d80211/ieee80211_sysfs.c
index 5c7af9f..fb95e96 100644
--- a/net/d80211/ieee80211_sysfs.c
+++ b/net/d80211/ieee80211_sysfs.c
@@ -53,6 +53,11 @@ static ssize_t store_remove_iface(struct
 	return res < 0 ? res : len;
 }
 
+static void ieee80211_class_dev_release(struct class_device *dev)
+{
+	ieee80211_release_hw(to_ieee80211_local(dev));
+}
+
 #ifdef CONFIG_HOTPLUG
 static int ieee80211_uevent(struct class_device *cd, char **envp,
 			    int num_envp, char *buf, int size)
@@ -79,28 +84,39 @@ static struct class_device_attribute iee
 static struct class ieee80211_class = {
 	.name = "ieee80211",
 	.class_dev_attrs = ieee80211_class_dev_attrs,
+	.release = ieee80211_class_dev_release,
 #ifdef CONFIG_HOTPLUG
 	.uevent = ieee80211_uevent,
 #endif
 };
 
-int ieee80211_register_sysfs(struct ieee80211_local *local)
+void ieee80211_dev_sysfs_init(struct ieee80211_local *local)
 {
 	local->class_dev.class = &ieee80211_class;
 	local->class_dev.class_data = local;
+	class_device_initialize(&local->class_dev);
+}
+
+void ieee80211_dev_sysfs_put(struct ieee80211_local *local)
+{
+	class_device_put(&local->class_dev);
+}
+
+int ieee80211_dev_sysfs_add(struct ieee80211_local *local)
+{
 	snprintf(local->class_dev.class_id, BUS_ID_SIZE,
 		 "phy%d", local->dev_index);
-	return class_device_register(&local->class_dev);
+	return class_device_add(&local->class_dev);
 }
 
-void ieee80211_unregister_sysfs(struct ieee80211_local *local)
+void ieee80211_dev_sysfs_del(struct ieee80211_local *local)
 {
 	class_device_del(&local->class_dev);
 }
 
 int ieee80211_sysfs_add_netdevice(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 
 	return sysfs_create_link(&dev->class_dev.kobj, &local->class_dev.kobj,
 				 "wiphy");
@@ -108,8 +124,6 @@ int ieee80211_sysfs_add_netdevice(struct
 
 void ieee80211_sysfs_remove_netdevice(struct net_device *dev)
 {
-	struct ieee80211_local *local = dev->priv;
-
 	sysfs_remove_link(&dev->class_dev.kobj, "wiphy");
 }
 
diff --git a/net/d80211/rate_control.c b/net/d80211/rate_control.c
index 429ef2b..3485302 100644
--- a/net/d80211/rate_control.c
+++ b/net/d80211/rate_control.c
@@ -126,7 +126,7 @@ static void rate_control_simple_tx_statu
 					  struct sk_buff *skb,
 					  struct ieee80211_tx_status *status)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 	struct sta_info *sta;
 	struct sta_rate_control *srctrl;
@@ -217,7 +217,7 @@ static struct ieee80211_rate *
 rate_control_simple_get_rate(struct net_device *dev, struct sk_buff *skb,
 			     struct rate_control_extra *extra)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_sub_if_data *sdata;
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 	struct sta_info *sta;
diff --git a/net/d80211/rate_control.h b/net/d80211/rate_control.h
index 26d3c0f..b509539 100644
--- a/net/d80211/rate_control.h
+++ b/net/d80211/rate_control.h
@@ -64,7 +64,7 @@ static inline void rate_control_tx_statu
 					  struct sk_buff *skb,
 					  struct ieee80211_tx_status *status)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	local->rate_ctrl->tx_status(dev, skb, status);
 }
 
@@ -73,7 +73,7 @@ static inline struct ieee80211_rate *
 rate_control_get_rate(struct net_device *dev, struct sk_buff *skb,
 		      struct rate_control_extra *extra)
 {
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	return local->rate_ctrl->get_rate(dev, skb, extra);
 }
 
diff --git a/net/d80211/wme.c b/net/d80211/wme.c
index f20d3e0..138f892 100644
--- a/net/d80211/wme.c
+++ b/net/d80211/wme.c
@@ -175,7 +175,7 @@ static inline int wme_downgrade_ac(struc
  * negative return value indicates to drop the frame */
 static inline int classify80211(struct sk_buff *skb, struct Qdisc *qd)
 {
-	struct ieee80211_local *local = qd->dev->priv;
+	struct ieee80211_local *local = qd->dev->ieee80211_ptr;
 	struct ieee80211_tx_packet_data *pkt_data =
 		(struct ieee80211_tx_packet_data *) skb->cb;
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
@@ -227,7 +227,7 @@ static inline int classify80211(struct s
 
 static int wme_qdiscop_enqueue(struct sk_buff *skb, struct Qdisc* qd)
 {
-	struct ieee80211_local *local = qd->dev->priv;
+	struct ieee80211_local *local = qd->dev->ieee80211_ptr;
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
 	struct ieee80211_tx_packet_data *pkt_data =
 		(struct ieee80211_tx_packet_data *) skb->cb;
@@ -314,7 +314,7 @@ static struct sk_buff *wme_qdiscop_deque
 {
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
 	struct net_device *dev = qd->dev;
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_hw *hw = local->hw;
 	struct ieee80211_tx_queue_stats stats;
 	struct sk_buff *skb;
@@ -351,7 +351,7 @@ static struct sk_buff *wme_qdiscop_deque
 static void wme_qdiscop_reset(struct Qdisc* qd)
 {
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct ieee80211_local *local = qd->dev->priv;
+	struct ieee80211_local *local = qd->dev->ieee80211_ptr;
 	struct ieee80211_hw *hw = local->hw;
 	int queue;
 
@@ -368,7 +368,7 @@ static void wme_qdiscop_reset(struct Qdi
 static void wme_qdiscop_destroy(struct Qdisc* qd)
 {
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct ieee80211_local *local = qd->dev->priv;
+	struct ieee80211_local *local = qd->dev->ieee80211_ptr;
 	struct ieee80211_hw *hw = local->hw;
 	struct tcf_proto *tp;
 	int queue;
@@ -409,7 +409,7 @@ static int wme_qdiscop_init(struct Qdisc
 {
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
 	struct net_device *dev = qd->dev;
-	struct ieee80211_local *local = dev->priv;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	int queues = local->hw->queues;
 	int err = 0, i;
 
@@ -464,7 +464,7 @@ static int wme_classop_graft(struct Qdis
 			     struct Qdisc *new, struct Qdisc **old)
 {
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct ieee80211_local *local = qd->dev->priv;
+	struct ieee80211_local *local = qd->dev->ieee80211_ptr;
 	struct ieee80211_hw *hw = local->hw;
 	unsigned long queue = arg - 1;
 
@@ -488,7 +488,7 @@ static struct Qdisc *
 wme_classop_leaf(struct Qdisc *qd, unsigned long arg)
 {
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct ieee80211_local *local = qd->dev->priv;
+	struct ieee80211_local *local = qd->dev->ieee80211_ptr;
 	struct ieee80211_hw *hw = local->hw;
 	unsigned long queue = arg - 1;
 
@@ -501,7 +501,7 @@ wme_classop_leaf(struct Qdisc *qd, unsig
 
 static unsigned long wme_classop_get(struct Qdisc *qd, u32 classid)
 {
-	struct ieee80211_local *local = qd->dev->priv;
+	struct ieee80211_local *local = qd->dev->ieee80211_ptr;
 	struct ieee80211_hw *hw = local->hw;
 	unsigned long queue = TC_H_MIN(classid);
 
@@ -529,7 +529,7 @@ static int wme_classop_change(struct Qdi
 			      struct rtattr **tca, unsigned long *arg)
 {
 	unsigned long cl = *arg;
-	struct ieee80211_local *local = qd->dev->priv;
+	struct ieee80211_local *local = qd->dev->ieee80211_ptr;
 	struct ieee80211_hw *hw = local->hw;
 	/* printk(KERN_DEBUG "entering %s\n", __func__); */
 
@@ -547,7 +547,7 @@ static int wme_classop_change(struct Qdi
  * when we add WMM-SA support - TSPECs may be deleted here */
 static int wme_classop_delete(struct Qdisc *qd, unsigned long cl)
 {
-	struct ieee80211_local *local = qd->dev->priv;
+	struct ieee80211_local *local = qd->dev->ieee80211_ptr;
 	struct ieee80211_hw *hw = local->hw;
 	/* printk(KERN_DEBUG "entering %s\n", __func__); */
 
@@ -561,7 +561,7 @@ static int wme_classop_dump_class(struct
 				  struct sk_buff *skb, struct tcmsg *tcm)
 {
 	struct ieee80211_sched_data *q = qdisc_priv(qd);
-	struct ieee80211_local *local = qd->dev->priv;
+	struct ieee80211_local *local = qd->dev->ieee80211_ptr;
 	struct ieee80211_hw *hw = local->hw;
 	/* printk(KERN_DEBUG "entering %s\n", __func__); */
 
@@ -576,7 +576,7 @@ static int wme_classop_dump_class(struct
 
 static void wme_classop_walk(struct Qdisc *qd, struct qdisc_walker *arg)
 {
-	struct ieee80211_local *local = qd->dev->priv;
+	struct ieee80211_local *local = qd->dev->ieee80211_ptr;
 	struct ieee80211_hw *hw = local->hw;
 	int queue;
 	/* printk(KERN_DEBUG "entering %s\n", __func__); */
-- 
1.3.0

