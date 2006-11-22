From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH] d80211 ethtool
Date: Wed, 22 Nov 2006 17:59:01 +0100
Message-ID: <200611221759.01579.IvDoorn@gmail.com>
References: <200611221608.09234.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:36303 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1755983AbWKVQ7J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Nov 2006 11:59:09 -0500
Received: by nf-out-0910.google.com with SMTP id o25so586995nfa
        for <netdev@vger.kernel.org>; Wed, 22 Nov 2006 08:59:08 -0800 (PST)
To: netdev <netdev@vger.kernel.org>
In-Reply-To: <200611221608.09234.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Initial patch was flawed in 2 ways, it didn't go to the netdev list,
and it didn't contain a function to allow drivers to get a ieee80211_hw
pointer from the net_device structure.
So this time the correct patch.

During the latest d80211 update the netdevice reference
was removed from the drivers. This also removed the
capability to register ethtool operations for the netdevice.

This patch adds the ethtool_ops reference into the
ieee80211_ops structure, and makes sure that it will
be set on all new interfaces that will be created.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff --git a/include/net/d80211.h b/include/net/d80211.h
index 30980e1..efa52b6 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -704,6 +704,10 @@ struct ieee80211_ops {
 	 * needed only for IBSS mode and the result of this function is used to
 	 * determine whether to reply to Probe Requests. */
 	int (*tx_last_beacon)(struct ieee80211_hw *hw);
+
+	/* Set the ethtool_ops pointer to indicate which ethtool functionality
+	 * is supported by the driver. */
+	struct ethtool_ops *ethtool;
 };
 
 /* Allocate a new hardware device. This must be called once for each
@@ -888,6 +892,15 @@ void ieee80211_start_queues(struct ieee8
 void ieee80211_stop_queues(struct ieee80211_hw *hw);
 
 /**
+ * ieee80211_get_hw - Get ieee80211 pointer
+ * @dev: pointer to the net_device.
+ *
+ * Drivers can use this to convert a net_device pointer to the
+ * pointer to a ieee80211_hw structure.
+ */
+struct ieee80211_hw *ieee80211_get_hw(struct net_device *dev);
+
+/**
  * ieee80211_get_mc_list_item - iteration over items in multicast list
  * @hw: pointer as obtained from ieee80211_alloc_hw().
  * @prev: value returned by previous call to ieee80211_get_mc_list_item() or
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 8a87c73..b55332c 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4814,6 +4814,13 @@ void ieee80211_stop_queues(struct ieee80
 }
 EXPORT_SYMBOL(ieee80211_stop_queues);
 
+struct ieee80211_hw *ieee80211_get_hw(struct net_device *dev)
+{
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	return &local->hw;
+}
+EXPORT_SYMBOL(ieee80211_get_hw);
+
 struct net_device_stats *ieee80211_dev_stats(struct net_device *dev)
 {
 	struct ieee80211_sub_if_data *sdata;
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 4f20bd9..a04ad95 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -77,6 +77,7 @@ int ieee80211_if_add(struct net_device *
 	ndev->mem_end = dev->mem_end;
 	ndev->flags = dev->flags & IFF_MULTICAST;
 	SET_NETDEV_DEV(ndev, dev->class_dev.dev);
+	SET_ETHTOOL_OPS(ndev, local->ops->ethtool);
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(ndev);
 	sdata->type = IEEE80211_IF_TYPE_AP;
@@ -125,6 +126,7 @@ int ieee80211_if_add_mgmt(struct ieee802
 	ndev->ieee80211_ptr = local;
 	memcpy(ndev->dev_addr, local->hw.perm_addr, ETH_ALEN);
 	SET_NETDEV_DEV(ndev, local->mdev->class_dev.dev);
+	SET_ETHTOOL_OPS(ndev, local->ops->ethtool);
 
 	nsdata = IEEE80211_DEV_TO_SUB_IF(ndev);
 	nsdata->type = IEEE80211_IF_TYPE_MGMT;
