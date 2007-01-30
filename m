From: Larry Finger <larry.finger@lwfinger.net>
Subject: Re: Hidden SSID's
Date: Mon, 29 Jan 2007 22:52:20 -0600
Message-ID: <45BECF04.3070904@lwfinger.net>
References: <45BACB71.2080107@lwfinger.net>	 <1169899689.25670.3.camel@localhost.localdomain>	 <1170019717.30318.0.camel@johannes.berg>	 <1170075611.2895.2.camel@localhost.localdomain>	 <20070130030911.GA6637@jm.kir.nu> <1170128208.3448.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkmaline@cc.hut.fi>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:39023 "EHLO
	mtiwmhc11.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752534AbXA3Ewa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jan 2007 23:52:30 -0500
In-Reply-To: <1170128208.3448.6.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Williams wrote:
> On Mon, 2007-01-29 at 19:09 -0800, Jouni Malinen wrote:
>> On Mon, Jan 29, 2007 at 08:00:11AM -0500, Dan Williams wrote:
>>
>>> Well, there's no way a userspace program could depend on all hidden SSID
>>> APs having the <hidden> tag, since if you stick in another,
>>> non-ieee80211-stack card it won't be like that.  So I don't think we
>>> should care about <hidden> in d80211, but I don't think we can remove it
>>> from ieee80211 either.
>> Use of '<hidden>' is just not acceptable. IMHO, it should be removed
>> from everywhere, including net/ieee80211. The sooner this is done, the
>> better.
> 
> You're probably right.  Lets just pull it out of ieee80211 and be done.
Before it gets pulled, please look at this patch.

Larry

=======================================



When an AP has a hidden SSID, ieee80211 fails, at least with wpa_supplicant,
which searches through the scan data looking for a particular ssid. Because
ieee80211 has substituted a false ssid, namely "<hidden>", wpa_supplicant
cannot authenticate. This behavior is fixed by adding a new argument to
ieee80211_translate_scan that contains the expected ssid. A new routine,
ieee80211_wx_get_scan_essid, has an additional argument that contains the essid
of the AP that wpa_supplicant is trying to find. The existing routine,
ieee80211_wx_get_scan, calls the new one with the false ssid. The code in
ieee80211softmac is also modified to use the new routine and has been tested
with bcm43xx.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

Index: linux-2.6/include/net/ieee80211.h
===================================================================
--- linux-2.6.orig/include/net/ieee80211.h
+++ linux-2.6/include/net/ieee80211.h
@@ -946,6 +946,11 @@ struct ieee80211_network {
 	struct list_head list;
 };

+struct ieee80211_essid {
+	u8 len;
+	char data[IW_ESSID_MAX_SIZE];
+};
+
 enum ieee80211_state {
 	IEEE80211_UNINITIALIZED = 0,
 	IEEE80211_INITIALIZED,
@@ -1296,6 +1301,10 @@ extern const struct ieee80211_channel *i
 extern int ieee80211_wx_get_scan(struct ieee80211_device *ieee,
 				 struct iw_request_info *info,
 				 union iwreq_data *wrqu, char *key);
+extern int ieee80211_wx_get_scan_essid(struct ieee80211_device *ieee,
+				 struct iw_request_info *info,
+				 union iwreq_data *wrqu, char *key,
+				 struct ieee80211_essid *essid);
 extern int ieee80211_wx_set_encode(struct ieee80211_device *ieee,
 				   struct iw_request_info *info,
 				   union iwreq_data *wrqu, char *key);
Index: linux-2.6/net/ieee80211/ieee80211_wx.c
===================================================================
--- linux-2.6.orig/net/ieee80211/ieee80211_wx.c
+++ linux-2.6/net/ieee80211/ieee80211_wx.c
@@ -44,7 +44,8 @@ static const char *ieee80211_modes[] = {
 #define MAX_CUSTOM_LEN 64
 static char *ieee80211_translate_scan(struct ieee80211_device *ieee,
 					   char *start, char *stop,
-					   struct ieee80211_network *network)
+					   struct ieee80211_network *network,
+					   struct ieee80211_essid *essid)
 {
 	char custom[MAX_CUSTOM_LEN];
 	char *p;
@@ -65,10 +66,10 @@ static char *ieee80211_translate_scan(st
 	iwe.cmd = SIOCGIWESSID;
 	iwe.u.data.flags = 1;
 	if (network->flags & NETWORK_EMPTY_ESSID) {
-		iwe.u.data.length = sizeof("<hidden>");
-		start = iwe_stream_add_point(start, stop, &iwe, "<hidden>");
+		iwe.u.data.length = min(essid->len, (u8) IW_ESSID_MAX_SIZE);
+		start = iwe_stream_add_point(start, stop, &iwe, essid->data);
 	} else {
-		iwe.u.data.length = min(network->ssid_len, (u8) 32);
+		iwe.u.data.length = min(network->ssid_len, (u8) IW_ESSID_MAX_SIZE);
 		start = iwe_stream_add_point(start, stop, &iwe, network->ssid);
 	}

@@ -247,9 +248,15 @@ static char *ieee80211_translate_scan(st

 #define SCAN_ITEM_SIZE 128

-int ieee80211_wx_get_scan(struct ieee80211_device *ieee,
+static struct ieee80211_essid hidden_essid = {
+	.len  = sizeof ("<hidden>"),
+	.data = {"<hidden>"},
+};
+
+int ieee80211_wx_get_scan_essid(struct ieee80211_device *ieee,
 			  struct iw_request_info *info,
-			  union iwreq_data *wrqu, char *extra)
+			  union iwreq_data *wrqu, char *extra,
+			  struct ieee80211_essid *essid)
 {
 	struct ieee80211_network *network;
 	unsigned long flags;
@@ -272,7 +279,7 @@ int ieee80211_wx_get_scan(struct ieee802

 		if (ieee->scan_age == 0 ||
 		    time_after(network->last_scanned + ieee->scan_age, jiffies))
-			ev = ieee80211_translate_scan(ieee, ev, stop, network);
+			ev = ieee80211_translate_scan(ieee, ev, stop, network, essid);
 		else
 			IEEE80211_DEBUG_SCAN("Not showing network '%s ("
 					     MAC_FMT ")' due to age (%dms).\n",
@@ -294,6 +301,13 @@ int ieee80211_wx_get_scan(struct ieee802
 	return err;
 }

+int ieee80211_wx_get_scan(struct ieee80211_device *ieee,
+			  struct iw_request_info *info,
+			  union iwreq_data *wrqu, char *extra)
+{
+	return ieee80211_wx_get_scan_essid(ieee, info, wrqu, extra,  &hidden_essid);
+}
+
 int ieee80211_wx_set_encode(struct ieee80211_device *ieee,
 			    struct iw_request_info *info,
 			    union iwreq_data *wrqu, char *keybuf)
@@ -834,6 +848,7 @@ EXPORT_SYMBOL(ieee80211_wx_set_encodeext
 EXPORT_SYMBOL(ieee80211_wx_get_encodeext);

 EXPORT_SYMBOL(ieee80211_wx_get_scan);
+EXPORT_SYMBOL(ieee80211_wx_get_scan_essid);
 EXPORT_SYMBOL(ieee80211_wx_set_encode);
 EXPORT_SYMBOL(ieee80211_wx_get_encode);

Index: linux-2.6/net/ieee80211/softmac/ieee80211softmac_wx.c
===================================================================
--- linux-2.6.orig/net/ieee80211/softmac/ieee80211softmac_wx.c
+++ linux-2.6/net/ieee80211/softmac/ieee80211softmac_wx.c
@@ -37,6 +37,10 @@ ieee80211softmac_wx_trigger_scan(struct
 				 char *extra)
 {
 	struct ieee80211softmac_device *sm = ieee80211_priv(net_dev);
+	struct iw_scan_req *req = (struct iw_scan_req *) extra;
+
+	sm->scan_essid.len = req->essid_len;
+	memcpy(sm->scan_essid.data, req->essid, req->essid_len);
 	return ieee80211softmac_start_scan(sm);
 }
 EXPORT_SYMBOL_GPL(ieee80211softmac_wx_trigger_scan);
@@ -59,7 +63,7 @@ ieee80211softmac_wx_get_scan_results(str
 		return -EAGAIN;
 	}
 	spin_unlock_irqrestore(&sm->lock, flags);
-	return ieee80211_wx_get_scan(sm->ieee, info, data, extra);
+	return ieee80211_wx_get_scan_essid(sm->ieee, info, data, extra, &sm->scan_essid);
 }
 EXPORT_SYMBOL_GPL(ieee80211softmac_wx_get_scan_results);

Index: linux-2.6/include/net/ieee80211softmac.h
===================================================================
--- linux-2.6.orig/include/net/ieee80211softmac.h
+++ linux-2.6/include/net/ieee80211softmac.h
@@ -209,6 +209,10 @@ struct ieee80211softmac_device {

 	/* we'll need something about beacons here too, for AP or ad-hoc modes */

+	/* keep track of the essid for scanning so that we can associate with
+	 * APs that are hidden */
+	struct ieee80211_essid scan_essid;
+
 	/* Transmission rates to be used by the driver.
 	 * The SoftMAC figures out the best possible rates.
 	 * The driver just needs to read them.

