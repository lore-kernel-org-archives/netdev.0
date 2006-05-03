From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 2/3] d80211: use alloc_netdev
Date: Wed,  3 May 2006 17:11:29 +0200 (CEST)
Message-ID: <20060503151129.7A1B9482B5@silver.suse.cz>
References: <20060503171031.304543000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:44160 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965215AbWECPKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 11:10:51 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060503171031.304543000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now when there are no interfaces allocated together anymore, let's use
alloc_netdev for allocation of interfaces. We save some code and also
the structures are really aligned finally.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c       |   43 ++++++++++++++++++++----------------------
 net/d80211/ieee80211_i.h     |    6 +-----
 net/d80211/ieee80211_iface.c |   28 ++++++++++-----------------
 3 files changed, 31 insertions(+), 46 deletions(-)

df3a812091d971e8cec93d51b5a54b6d2ecfb400
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 1d6e87c..fc56450 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4057,43 +4057,40 @@ struct net_device *ieee80211_alloc_hw(si
 	struct net_device *mdev;
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
          */
-        alloc_size = sizeof(struct net_device) +
-                sizeof(struct ieee80211_sub_if_data) + 3 +
-                sizeof(struct ieee80211_local) + 3 +
-                priv_data_len + 3 +
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
-
-	ether_setup(mdev);
-	memcpy(mdev->name, "wmaster%d", 10);
+	local->hw_priv = (char *)local +
+			 ((sizeof(struct ieee80211_local) +
+			   NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
 
 	local->dev_index = -1;
 	local->mdev = mdev;
@@ -4310,7 +4307,7 @@ void ieee80211_unregister_hw(struct net_
 
 void ieee80211_free_hw(struct net_device *dev)
 {
-	kfree(dev);
+	free_netdev(dev);
 }
 
 
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 15dcc95..5bf81ff 100644
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
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 2738c94..3e3e5ca 100644
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
@@ -88,7 +83,7 @@ int ieee80211_if_add(struct net_device *
 	return 0;
 
 fail:
-	kfree(ndev);
+	free_netdev(ndev);
 	*new_dev = NULL;
 	return ret;
 }
@@ -98,14 +93,13 @@ static int ieee80211_if_add_apdev(struct
 	struct net_device *ndev;
 	struct ieee80211_local *local = dev->priv;
 	struct ieee80211_sub_if_data *sdata, *nsdata;
-	int alloc_size, ret;
+	int ret;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	ASSERT_RTNL();
-	alloc_size = sizeof(struct net_device) + 3 +
-		sizeof(struct ieee80211_sub_if_data) + 3;
 
-	ndev = (struct net_device *) kzalloc(alloc_size, GFP_KERNEL);
+	ndev = alloc_netdev(sizeof(struct ieee80211_sub_if_data), "",
+			    ieee80211_if_ap_setup);
 	if (ndev == NULL)
 		return -ENOMEM;
 	snprintf(ndev->name, IFNAMSIZ, "%sap", dev->name);
@@ -116,7 +110,6 @@ static int ieee80211_if_add_apdev(struct
 	ndev->irq = dev->irq;
 	ndev->mem_start = dev->mem_start;
 	ndev->mem_end = dev->mem_end;
-	ieee80211_if_ap_setup(ndev);
 
 	nsdata = IEEE80211_DEV_TO_SUB_IF(ndev);
 	nsdata->type = IEEE80211_IF_TYPE_AP;
@@ -130,7 +123,7 @@ static int ieee80211_if_add_apdev(struct
 		if (ret == -EEXIST)
 			printk(KERN_DEBUG "%s: apdev name %s already exists\n",
 			       dev->name, ndev->name);
-		kfree(ndev);
+		free_netdev(ndev);
 		return ret;
 	}
 	local->apdev = ndev;
@@ -311,9 +304,8 @@ void __ieee80211_if_del(struct ieee80211
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
@@ -343,7 +335,7 @@ void ieee80211_if_free(struct net_device
 	struct ieee80211_local *local = dev->priv;
 
 	BUG_ON(dev == local->mdev || dev == local->apdev);
-	kfree(dev);
+	free_netdev(dev);
 }
 
 /* Must be called with rtnl lock held. */
-- 
1.3.0

