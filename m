From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 1/3] d80211: Add control structure for beacontemplates
Date: Tue, 6 Feb 2007 00:46:45 +0100
Message-ID: <200702060046.45560.IvDoorn@gmail.com>
References: <200702031725.19080.IvDoorn@gmail.com> <20070205212802.36477fd4@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>,
	Michael Wu <flamingice@sourmilk.net>, netdev@vger.kernel.org
To: Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:12186 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751994AbXBEXrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 18:47:08 -0500
Received: by nf-out-0910.google.com with SMTP id o25so2291422nfa
        for <netdev@vger.kernel.org>; Mon, 05 Feb 2007 15:47:06 -0800 (PST)
In-Reply-To: <20070205212802.36477fd4@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 05 February 2007 21:28, Jiri Benc wrote:
> On Sat, 3 Feb 2007 17:25:18 +0100, Ivo van Doorn wrote:
> > When rt2500usb and rt73usb will start using beacontemplates,
> > they would also need a control structure to be passed along to
> > correctly set the tx parameters.
> 
> Good catch, thanks.
> 
> > This patch will add the allocation an initialization of a
> > ieee80211_tx_control especially for the beacontemplate.
> > 
> > This does require drivers that have the BEACON_TEMPLATE flag
> > set to also free the control structure. (bcm43xx and p54 will be
> > fixed in the next 2 patches)
> 
> I would prefer using local variable for tx_control. Driver will be
> responsible for copying it somewhere if it needs to. I believe most
> drivers won't need to do that and it will prevent potential memory
> leaks as it's easy to forget to free the structure.

Sounds good to me, that would absolute the fix for bcm43xx I had send,
but the updated patch for p54 would still be required to make sure p54
no longer requests the beacon without ever using (or freeing it).

This is the updated patch to add the control structure to the beacontemplate.
This time no seperately allocated control structure, but a local variable
inside the ieee80211_if_conf structure.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff -rpU3 dscape/include/net/d80211.h dscape.control/include/net/d80211.h
--- dscape/include/net/d80211.h	2007-02-06 00:19:37.000000000 +0100
+++ dscape.control/include/net/d80211.h	2007-02-06 00:23:45.000000000 +0100
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
+	struct ieee80211_tx_control beacon_control;
 };
 
 typedef enum { ALG_NONE, ALG_WEP, ALG_TKIP, ALG_CCMP, ALG_NULL }
diff -rpU3 dscape/net/d80211/ieee80211.c dscape.control/net/d80211/ieee80211.c
--- dscape/net/d80211/ieee80211.c	2007-02-06 00:19:38.000000000 +0100
+++ dscape.control/net/d80211/ieee80211.c	2007-02-06 00:25:26.000000000 +0100
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
+		memcpy(&conf.beacon_control, control, sizeof(*control));
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
