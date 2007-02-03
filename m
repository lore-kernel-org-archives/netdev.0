From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 1/3] d80211: Add control structure for beacontemplates
Date: Sat, 3 Feb 2007 17:25:18 +0100
Message-ID: <200702031725.19080.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Benc <jbenc@suse.cz>,
	"John Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>,
	Michael Wu <flamingice@sourmilk.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:20470 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946478AbXBCQZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Feb 2007 11:25:39 -0500
Received: by nf-out-0910.google.com with SMTP id o25so1597470nfa
        for <netdev@vger.kernel.org>; Sat, 03 Feb 2007 08:25:37 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When rt2500usb and rt73usb will start using beacontemplates,
they would also need a control structure to be passed along to
correctly set the tx parameters.

This patch will add the allocation an initialization of a
ieee80211_tx_control especially for the beacontemplate.

This does require drivers that have the BEACON_TEMPLATE flag
set to also free the control structure. (bcm43xx and p54 will be
fixed in the next 2 patches)

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff --git a/include/net/d80211.h b/include/net/d80211.h
index 65a5d36..b1b40f0 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -374,6 +374,9 @@ struct ieee80211_if_init_conf {
  * @beacon: beacon template. Valid only if @host_gen_beacon_template in
  *	&struct ieee80211_hw is set. The driver is responsible of freeing
  *	the sk_buff.
+ * @beacon_control: tx_control for the beacon template, this field is only
+ *	valid when the @beacon field was set. The driver is responsible of
+ *	freeing the buffer.
  *
  * This structure is passed to the config_interface() callback of
  * &struct ieee80211_hw.
@@ -386,6 +389,7 @@ struct ieee80211_if_conf {
 	u8 *generic_elem;
 	size_t generic_elem_len;
 	struct sk_buff *beacon;
+	struct ieee80211_tx_control *beacon_control;
 };
 
 typedef enum { ALG_NONE, ALG_WEP, ALG_TKIP, ALG_CCMP, ALG_NULL }
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 7353ed3..3e79f0c 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1857,7 +1857,8 @@ ieee80211_get_buffered_bc(struct ieee80211_hw *hw, int if_id,
 EXPORT_SYMBOL(ieee80211_get_buffered_bc);
 
 static int __ieee80211_if_config(struct net_device *dev,
-				 struct sk_buff *beacon)
+				 struct sk_buff *beacon,
+				 struct ieee80211_tx_control *control)
 {
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct ieee80211_local *local = dev->ieee80211_ptr;
@@ -1881,6 +1882,7 @@ static int __ieee80211_if_config(struct net_device *dev,
 		conf.generic_elem = sdata->u.ap.generic_elem;
 		conf.generic_elem_len = sdata->u.ap.generic_elem_len;
 		conf.beacon = beacon;
+		conf.beacon_control = control;
 	}
 	return local->ops->config_interface(local_to_hw(local),
 					   dev->ifindex, &conf);
@@ -1888,20 +1890,27 @@ static int __ieee80211_if_config(struct net_device *dev,
 
 int ieee80211_if_config(struct net_device *dev)
 {
-	return __ieee80211_if_config(dev, NULL);
+	return __ieee80211_if_config(dev, NULL, NULL);
 }
 
 int ieee80211_if_config_beacon(struct net_device *dev)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee80211_tx_control *control;
 	struct sk_buff *skb;
 
 	if (!(local->hw.flags & IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE))
 		return 0;
-	skb = ieee80211_beacon_get(local_to_hw(local), dev->ifindex, NULL);
+
+	control = kzalloc(sizeof(struct ieee80211_tx_control), GFP_KERNEL);
+	if (!control)
+		return -ENOMEM;
+
+	skb = ieee80211_beacon_get(local_to_hw(local), dev->ifindex, control);
 	if (!skb)
 		return -ENOMEM;
-	return __ieee80211_if_config(dev, skb);
+
+	return __ieee80211_if_config(dev, skb, control);
 }
 
 int ieee80211_hw_config(struct ieee80211_local *local)
