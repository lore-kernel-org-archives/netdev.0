From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH v3] d80211: Add control structure for beacontemplates
Date: Tue, 6 Feb 2007 17:03:59 +0100
Message-ID: <200702061704.00190.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	Michael Wu <flamingice@sourmilk.net>, netdev@vger.kernel.org
To: Jiri Benc <jbenc@suse.cz>, "John Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:38485 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932663AbXBFQEY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Feb 2007 11:04:24 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1645823uga
        for <netdev@vger.kernel.org>; Tue, 06 Feb 2007 08:04:23 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Previous send v2 had a null pointer error in it.

When rt2500usb and rt73usb will start using beacontemplates,
they would also need a control structure to be passed along to
correctly set the tx parameters.
This patch will add a ieee80211_tx_control pointer to the
ieee80211_if_init_conf structure. This pointer is only a reference
to a local variable so drivers will not need to call kfree() on it.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rpU3 dscape/include/net/d80211.h dscape.control/include/net/d80211.h
--- dscape/include/net/d80211.h	2007-02-06 00:19:37.000000000 +0100
+++ dscape.control/include/net/d80211.h	2007-02-06 16:57:35.000000000 +0100
@@ -374,6 +374,8 @@ struct ieee80211_if_init_conf {
  * @beacon: beacon template. Valid only if @host_gen_beacon_template in
  *	&struct ieee80211_hw is set. The driver is responsible of freeing
  *	the sk_buff.
+ * @beacon_control: tx_control for the beacon template, this field is only
+ *	valid when the @beacon field was set.
  *
  * This structure is passed to the config_interface() callback of
  * &struct ieee80211_hw.
@@ -386,6 +388,7 @@ struct ieee80211_if_conf {
 	u8 *generic_elem;
 	size_t generic_elem_len;
 	struct sk_buff *beacon;
+	struct ieee80211_tx_control *beacon_control;
 };
 
 typedef enum { ALG_NONE, ALG_WEP, ALG_TKIP, ALG_CCMP, ALG_NULL }
diff -rpU3 dscape/net/d80211/ieee80211.c dscape.control/net/d80211/ieee80211.c
--- dscape/net/d80211/ieee80211.c	2007-02-06 00:19:38.000000000 +0100
+++ dscape.control/net/d80211/ieee80211.c	2007-02-06 16:58:04.000000000 +0100
@@ -1857,7 +1857,8 @@ ieee80211_get_buffered_bc(struct ieee802
 EXPORT_SYMBOL(ieee80211_get_buffered_bc);
 
 static int __ieee80211_if_config(struct net_device *dev,
-				 struct sk_buff *beacon)
+				 struct sk_buff *beacon,
+				 struct ieee80211_tx_control *control)
 {
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct ieee80211_local *local = dev->ieee80211_ptr;
@@ -1881,6 +1882,7 @@ static int __ieee80211_if_config(struct 
 		conf.generic_elem = sdata->u.ap.generic_elem;
 		conf.generic_elem_len = sdata->u.ap.generic_elem_len;
 		conf.beacon = beacon;
+		conf.beacon_control = control;
 	}
 	return local->ops->config_interface(local_to_hw(local),
 					   dev->ifindex, &conf);
@@ -1888,20 +1890,21 @@ static int __ieee80211_if_config(struct 
 
 int ieee80211_if_config(struct net_device *dev)
 {
-	return __ieee80211_if_config(dev, NULL);
+	return __ieee80211_if_config(dev, NULL, NULL);
 }
 
 int ieee80211_if_config_beacon(struct net_device *dev)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_tx_control control;
 	struct sk_buff *skb;
 
 	if (!(local->hw.flags & IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE))
 		return 0;
-	skb = ieee80211_beacon_get(local_to_hw(local), dev->ifindex, NULL);
+	skb = ieee80211_beacon_get(local_to_hw(local), dev->ifindex, &control);
 	if (!skb)
 		return -ENOMEM;
-	return __ieee80211_if_config(dev, skb);
+	return __ieee80211_if_config(dev, skb, &control);
 }
 
 int ieee80211_hw_config(struct ieee80211_local *local)
