From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 3/13] d80211: reduce mdev usage
Date: Sun, 19 Nov 2006 20:23:59 +0100
Message-ID: <1163964239.15473.43.camel@johannes.berg>
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
Received: from crystal.sipsolutions.net ([195.210.38.204]:29623 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S933049AbWKSTZq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 14:25:46 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1163963898.15473.36.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch reduces mdev usage by replacing struct net_device *
arguments that are never used except for dereferencing to get
struct ieee80211_local from ieee80211_ptr by struct
ieee80211_local directly. Also removes ->master from sub_if_data.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/ieee80211_i.h	2006-11-19 20:13:55.359275208 +0100
+++ wireless-dev/net/d80211/ieee80211_i.h	2006-11-19 20:13:56.069275208 +0100
@@ -289,7 +289,6 @@ struct ieee80211_sub_if_data {
         unsigned int type;
 
         struct net_device *dev;
-        struct net_device *master;
         struct ieee80211_local *local;
 
 	int mc_count;
--- wireless-dev.orig/net/d80211/ieee80211.c	2006-11-19 20:13:55.359275208 +0100
+++ wireless-dev/net/d80211/ieee80211.c	2006-11-19 20:13:56.079275208 +0100
@@ -1569,7 +1569,7 @@ static int ieee80211_subif_start_xmit(st
 	pkt_data->mgmt_iface = (sdata->type == IEEE80211_IF_TYPE_MGMT);
 	pkt_data->do_not_encrypt = no_encrypt;
 
-	skb->dev = sdata->master;
+	skb->dev = local->mdev;
 	sdata->stats.tx_packets++;
 	sdata->stats.tx_bytes += skb->len;
 
@@ -1625,7 +1625,7 @@ ieee80211_mgmt_start_xmit(struct sk_buff
 		pkt_data->pkt_probe_resp = 1;
 
 	skb->priority = 20; /* use hardcoded priority for mgmt TX queue */
-	skb->dev = sdata->master;
+	skb->dev = sdata->local->mdev;
 
 	/*
 	 * We're using the protocol field of the the frame control header
@@ -2031,12 +2031,12 @@ static void ieee80211_set_multicast_list
 		sdata->mc_count = dev->mc_count;
 	}
 	if (local->hw->set_multicast_list) {
-		flags = sdata->master->flags;
+		flags = local->mdev->flags;
 		if (local->iff_allmultis)
 			flags |= IFF_ALLMULTI;
 		if (local->iff_promiscs)
 			flags |= IFF_PROMISC;
-		local->hw->set_multicast_list(sdata->master, flags,
+		local->hw->set_multicast_list(local->mdev, flags,
 					      local->mc_count);
 	}
 }
@@ -2229,7 +2229,7 @@ static int ieee80211_open(struct net_dev
 		conf.if_id = dev->ifindex;
 		conf.type = sdata->type;
 		conf.mac_addr = dev->dev_addr;
-		res = local->hw->add_interface(sdata->master, &conf);
+		res = local->hw->add_interface(local->mdev, &conf);
 		if (res) {
 			if (sdata->type == IEEE80211_IF_TYPE_MNTR)
 				ieee80211_start_hard_monitor(local);
@@ -2245,12 +2245,12 @@ static int ieee80211_open(struct net_dev
         if (local->open_count == 0) {
 		res = 0;
 		if (local->hw->open)
-			res = local->hw->open(sdata->master);
+			res = local->hw->open(local->mdev);
 		if (res == 0) {
-			res = dev_open(sdata->master);
+			res = dev_open(local->mdev);
 			if (res) {
 				if (local->hw->stop)
-					local->hw->stop(sdata->master);
+					local->hw->stop(local->mdev);
 			} else if (local->apdev)
 				dev_open(local->apdev);
 		}
@@ -2259,7 +2259,7 @@ static int ieee80211_open(struct net_dev
 				local->hw->remove_interface(dev, &conf);
 			return res;
 		}
-		ieee80211_init_scan(sdata->master);
+		ieee80211_init_scan(local->mdev);
 	}
         local->open_count++;
 
@@ -2296,12 +2296,12 @@ static int ieee80211_stop(struct net_dev
 
 	local->open_count--;
         if (local->open_count == 0) {
-		ieee80211_stop_scan(sdata->master);
-		dev_close(sdata->master);
+		ieee80211_stop_scan(local->mdev);
+		dev_close(local->mdev);
 		if (local->apdev)
 			dev_close(local->apdev);
 		if (local->hw->stop)
-			local->hw->stop(sdata->master);
+			local->hw->stop(local->mdev);
         }
 	if (local->hw->remove_interface) {
 		struct ieee80211_if_init_conf conf;
@@ -2309,7 +2309,7 @@ static int ieee80211_stop(struct net_dev
 		conf.if_id = dev->ifindex;
 		conf.type = sdata->type;
 		conf.mac_addr = dev->dev_addr;
-		local->hw->remove_interface(sdata->master, &conf);
+		local->hw->remove_interface(local->mdev, &conf);
 	}
 	ieee80211_if_shutdown(dev);
 
@@ -3660,7 +3660,7 @@ void __ieee80211_rx(struct net_device *d
 						continue;
 					rx.u.rx.ra_match = 0;
 				}
-				if (sdata->dev == sdata->master &&
+				if (sdata->dev == local->mdev &&
 				    !rx.u.rx.in_scan)
 					/* do not receive anything via
 					 * master device when not scanning */
@@ -4438,7 +4438,6 @@ struct net_device *ieee80211_alloc_hw(si
 	sdata = IEEE80211_DEV_TO_SUB_IF(mdev);
 	sdata->type = IEEE80211_IF_TYPE_AP;
         sdata->dev = mdev;
-        sdata->master = mdev;
         sdata->local = local;
 	sdata->u.ap.force_unicast_rateidx = -1;
 	sdata->u.ap.max_ratectrl_rateidx = -1;
@@ -4676,8 +4675,7 @@ void ieee80211_release_hw(struct ieee802
 int ieee80211_netif_oper(struct net_device *sdev, Netif_Oper op)
 {
 	struct ieee80211_local *local = sdev->ieee80211_ptr;
-        struct ieee80211_sub_if_data *sdata =  IEEE80211_DEV_TO_SUB_IF(sdev);
-        struct net_device *dev = sdata->master;
+	struct net_device *dev = local->mdev;
 
 	switch (op) {
 	case NETIF_ATTACH:
--- wireless-dev.orig/net/d80211/ieee80211_iface.c	2006-11-19 20:13:55.359275208 +0100
+++ wireless-dev/net/d80211/ieee80211_iface.c	2006-11-19 20:13:56.079275208 +0100
@@ -80,7 +80,6 @@ int ieee80211_if_add(struct net_device *
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(ndev);
 	sdata->type = IEEE80211_IF_TYPE_AP;
-	sdata->master = local->mdev;
 	sdata->dev = ndev;
 	sdata->local = local;
 	sdata_parent = IEEE80211_DEV_TO_SUB_IF(dev);
@@ -129,7 +128,6 @@ int ieee80211_if_add_mgmt(struct ieee802
 
 	nsdata = IEEE80211_DEV_TO_SUB_IF(ndev);
 	nsdata->type = IEEE80211_IF_TYPE_MGMT;
-	nsdata->master = local->mdev;
 	nsdata->dev = ndev;
 	nsdata->local = local;
 	ieee80211_if_sdata_init(nsdata);
@@ -195,7 +193,7 @@ void ieee80211_if_set_type(struct net_de
 		ifsta->create_ibss = 1;
 		ifsta->wmm_enabled = 1;
 
-		msdata = IEEE80211_DEV_TO_SUB_IF(sdata->master);
+		msdata = IEEE80211_DEV_TO_SUB_IF(sdata->local->mdev);
 		sdata->bss = &msdata->u.ap;
 		break;
 	}
@@ -326,9 +324,6 @@ int ieee80211_if_remove(struct net_devic
 
 	ASSERT_RTNL();
 
-	/* Make sure not to touch sdata->master since it may
-	 * have already been deleted, etc. */
-
 	list_for_each_entry_safe(sdata, n, &local->sub_if_list, list) {
 		if ((sdata->type == id || id == -1) &&
 		    strcmp(name, sdata->dev->name) == 0 &&
--- wireless-dev.orig/net/d80211/ieee80211_sta.c	2006-11-19 20:13:55.369275208 +0100
+++ wireless-dev/net/d80211/ieee80211_sta.c	2006-11-19 20:13:56.079275208 +0100
@@ -390,7 +390,7 @@ static void ieee80211_sta_tx(struct net_
 	struct ieee80211_tx_packet_data *pkt_data;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-	skb->dev = sdata->master;
+	skb->dev = sdata->local->mdev;
 	skb->mac.raw = skb->nh.raw = skb->h.raw = skb->data;
 
 	pkt_data = (struct ieee80211_tx_packet_data *) skb->cb;


