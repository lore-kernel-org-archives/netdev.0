From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch] d80211: remove sub-interface mac address policy
Date: Thu, 14 Sep 2006 07:33:21 -0700
Message-ID: <20060914143321.GA1962@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-56.dex002.intermedia.net ([64.78.21.185]:39811 "EHLO
	dhost002-56.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1750804AbWINOdZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Sep 2006 10:33:25 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="remove_mac_addr_policy.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wireless vlan interfaces need to have the same mac address as
other sub interfaces.  Rather than complicate the kernel here by
adding yet another case where uniqueness is not required, remove
the check on mac address uniqueness altogether.

We should not implement a mac address allocation policy here.  It
is difficult to get it right in all cases and does not belong in
the kernel.  It is better to leave this to be implemented as a
userspace policy.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: linux-2.6.16/net/d80211/ieee80211.c
===================================================================
--- linux-2.6.16.orig/net/d80211/ieee80211.c
+++ linux-2.6.16/net/d80211/ieee80211.c
@@ -2116,17 +2116,6 @@ static struct net_device_stats *ieee8021
 	return &(sdata->stats);
 }
 
-static inline int identical_mac_addr_allowed(int type1, int type2)
-{
-	return (type1 == IEEE80211_IF_TYPE_MNTR ||
-		type2 == IEEE80211_IF_TYPE_MNTR ||
-		(type1 == IEEE80211_IF_TYPE_AP &&
-		 type2 == IEEE80211_IF_TYPE_WDS) ||
-		(type1 == IEEE80211_IF_TYPE_WDS &&
-		 (type2 == IEEE80211_IF_TYPE_WDS ||
-		  type2 == IEEE80211_IF_TYPE_AP)));
-}
-
 static int ieee80211_master_open(struct net_device *dev)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
@@ -2202,22 +2191,12 @@ static void ieee80211_start_hard_monitor
 
 static int ieee80211_open(struct net_device *dev)
 {
-	struct ieee80211_sub_if_data *sdata, *nsdata;
+	struct ieee80211_sub_if_data *sdata;
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct ieee80211_if_init_conf conf;
 	int res;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	list_for_each_entry(nsdata, &local->sub_if_list, list) {
-		struct net_device *ndev = nsdata->dev;
-
-		if (ndev != dev && ndev != local->mdev &&
-		    netif_running(ndev) &&
-		    memcmp(dev->dev_addr, ndev->dev_addr, ETH_ALEN) == 0 &&
-		    !identical_mac_addr_allowed(sdata->type, nsdata->type)) {
-			return -ENOTUNIQ;
-		}
-	}
 	if (sdata->type == IEEE80211_IF_TYPE_WDS &&
 	    memcmp(sdata->u.wds.remote_addr, "\0\0\0\0\0\0", ETH_ALEN) == 0)
 		return -ENOLINK;

--
