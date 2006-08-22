From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch 5/5] d80211: add ioctl to stop data frame tx
Date: Tue, 22 Aug 2006 10:34:19 -0700
Message-ID: <20060822173419.GF12500@devicescape.com>
References: <20060822173241.313859000@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-64.dex002.intermedia.net ([64.78.20.13]:61248 "EHLO
	dhost002-64.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751401AbWHVRe1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 13:34:27 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="stop_data_frame_tx.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This ioctl is used when radar is delected on a channel.  Data frames must stop
but management frames must be allowed to continue for some time to communicate
the channel switch to stations.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: linux-2.6.16/net/d80211/hostapd_ioctl.h
===================================================================
--- linux-2.6.16.orig/net/d80211/hostapd_ioctl.h
+++ linux-2.6.16/net/d80211/hostapd_ioctl.h
@@ -93,6 +93,7 @@ enum {
 	PRISM2_PARAM_SPECTRUM_MGMT = 1044,
 	PRISM2_PARAM_USER_SPACE_MLME = 1045,
 	PRISM2_PARAM_MGMT_IF = 1046,
+	PRISM2_PARAM_STOP_DATA_FRAME_TX = 1047,
 	/* NOTE: Please try to coordinate with other active development
 	 * branches before allocating new param numbers so that each new param
 	 * will be unique within all branches and the allocated number will not
Index: linux-2.6.16/net/d80211/ieee80211.c
===================================================================
--- linux-2.6.16.orig/net/d80211/ieee80211.c
+++ linux-2.6.16/net/d80211/ieee80211.c
@@ -1240,6 +1240,15 @@ static int ieee80211_tx(struct net_devic
 		return 0;
 	}
 
+	if (unlikely(local->stop_data_frame_tx)) {
+		struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
+		u16 fc = le16_to_cpu(hdr->frame_control);
+		if ((fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA) {
+			dev_kfree_skb(skb);
+			return 0;
+		}
+	}
+
 	__ieee80211_tx_prepare(&tx, skb, dev, control);
 	sta = tx.sta;
 	tx.u.tx.mgmt_interface = mgmt;
Index: linux-2.6.16/net/d80211/ieee80211_i.h
===================================================================
--- linux-2.6.16.orig/net/d80211/ieee80211_i.h
+++ linux-2.6.16/net/d80211/ieee80211_i.h
@@ -532,6 +532,8 @@ struct ieee80211_local {
 				* (1 << MODE_*) */
 
 	int user_space_mlme;
+	int stop_data_frame_tx; /* Set to 1 to stop transmission
+				 * of data frames. */
 };
 
 enum ieee80211_link_state_t {
Index: linux-2.6.16/net/d80211/ieee80211_ioctl.c
===================================================================
--- linux-2.6.16.orig/net/d80211/ieee80211_ioctl.c
+++ linux-2.6.16/net/d80211/ieee80211_ioctl.c
@@ -1300,6 +1300,14 @@ static int ieee80211_ioctl_set_radio_ena
         return ieee80211_hw_config(dev);
 }
 
+static int ieee80211_ioctl_set_stop_data_frame_tx(struct net_device *dev,
+					  	  int val)
+{
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+        local->stop_data_frame_tx = val;
+        return 0;
+}
+
 static int
 ieee80211_ioctl_set_tx_queue_params(struct net_device *dev,
 				    struct prism2_hostapd_param *param)
@@ -2612,6 +2620,9 @@ static int ieee80211_ioctl_prism2_param(
 	case PRISM2_PARAM_USER_SPACE_MLME:
 		local->user_space_mlme = value;
 		break;
+	case PRISM2_PARAM_STOP_DATA_FRAME_TX:
+                ret = ieee80211_ioctl_set_stop_data_frame_tx(dev, value);
+		break;
 	default:
 		ret = -EOPNOTSUPP;
 		break;

--
