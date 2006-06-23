From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 2/3] d80211: host_gen_beacon_template flag
Date: Fri, 23 Jun 2006 20:16:35 +0200 (CEST)
Message-ID: <20060623181635.5E1A4483AC@silver.suse.cz>
References: <20060623201604.835047000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mbuesch@freenet.de>,
	Alexander Tsvyashchenko <lists@ndl.kiev.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:52394 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1751866AbWFWSPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 14:15:12 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060623201604.835047000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a partial support for devices requiring beacon template. Please note
that there is no support for PS mode for such cards yet.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---
 include/net/d80211.h         |    6 ++++++
 net/d80211/ieee80211.c       |   22 +++++++++++++++++++++-
 net/d80211/ieee80211_i.h     |    1 +
 net/d80211/ieee80211_ioctl.c |    2 +-
 4 files changed, 29 insertions(+), 2 deletions(-)

--- dscape.orig/include/net/d80211.h
+++ dscape/include/net/d80211.h
@@ -349,6 +349,9 @@ struct ieee80211_if_init_conf {
  *	only during config_interface() callback (so copy the value somewhere
  *	if you need it).
  * @generic_elem_len: length of the generic element.
+ * @beacon: beacon template. Valid only if @host_gen_beacon_template in
+ *	&struct ieee80211_hw is set. The driver is responsible of freeing
+ *	the sk_buff.
  *
  * This structure is passed to config_interface() callback of
  * &struct ieee80211_hw.
@@ -360,6 +363,7 @@ struct ieee80211_if_conf {
 	size_t ssid_len;
 	u8 *generic_elem;
 	size_t generic_elem_len;
+	struct sk_buff *beacon;
 };
 
 typedef enum { ALG_NONE, ALG_WEP, ALG_TKIP, ALG_CCMP, ALG_NULL }
@@ -439,6 +443,8 @@ struct ieee80211_hw {
 	 * beacon frame. */
 	int host_gen_beacon:1;
 
+	/* The device needs to be supplied with a beacon template only. */
+	int host_gen_beacon_template:1;
 
 	/* Some devices handle decryption internally and do not
 	 * indicate whether the frame was encrypted (unencrypted frames
--- dscape.orig/net/d80211/ieee80211.c
+++ dscape/net/d80211/ieee80211.c
@@ -1902,7 +1902,8 @@ ieee80211_get_buffered_bc(struct net_dev
 	return skb;
 }
 
-int ieee80211_if_config(struct net_device *dev)
+static int __ieee80211_if_config(struct net_device *dev,
+				 struct sk_buff *beacon)
 {
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct ieee80211_local *local = dev->ieee80211_ptr;
@@ -1925,10 +1926,29 @@ int ieee80211_if_config(struct net_devic
 		conf.ssid_len = sdata->u.ap.ssid_len;
 		conf.generic_elem = sdata->u.ap.generic_elem;
 		conf.generic_elem_len = sdata->u.ap.generic_elem_len;
+		conf.beacon = beacon;
 	}
 	return local->hw->config_interface(local->mdev, dev->ifindex, &conf);
 }
 
+int ieee80211_if_config(struct net_device *dev)
+{
+	return __ieee80211_if_config(dev, NULL);
+}
+
+int ieee80211_if_config_beacon(struct net_device *dev)
+{
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct sk_buff *skb;
+
+	if (!local->hw->host_gen_beacon_template)
+		return 0;
+	skb = ieee80211_beacon_get(local->mdev, dev->ifindex, NULL);
+	if (!skb)
+		return -ENOMEM;
+	return __ieee80211_if_config(dev, skb);
+}
+
 int ieee80211_hw_config(struct net_device *dev)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
--- dscape.orig/net/d80211/ieee80211_i.h
+++ dscape/net/d80211/ieee80211_i.h
@@ -545,6 +545,7 @@ struct sta_attribute {
 void ieee80211_release_hw(struct ieee80211_local *local);
 int ieee80211_hw_config(struct net_device *dev);
 int ieee80211_if_config(struct net_device *dev);
+int ieee80211_if_config_beacon(struct net_device *dev);
 struct ieee80211_key_conf *
 ieee80211_key_data2conf(struct ieee80211_local *local,
 			struct ieee80211_key *data);
--- dscape.orig/net/d80211/ieee80211_ioctl.c
+++ dscape/net/d80211/ieee80211_ioctl.c
@@ -110,7 +110,7 @@ static int ieee80211_ioctl_set_beacon(st
 		}
 	}
 
-	return 0;
+	return ieee80211_if_config_beacon(dev);
 }
 
 
