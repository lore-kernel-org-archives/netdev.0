From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'fixes-davem' branch of wireless-2.6
Date: Thu, 18 Oct 2007 18:08:59 -0400
Message-ID: <20071018220859.GG8510@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Another one for 2.6.24...

Thanks,

John

---

Individual patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes-davem

---

The following changes since commit 52f095ee88d8851866bc7694ab991ca5abf21d5e:
  Pavel Emelyanov (1):
        [IPV6]: Fix again the fl6_sock_lookup() fixed locking

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-davem

John W. Linville (1):
      mac80211: make ieee802_11_parse_elems return void

 net/mac80211/ieee80211_sta.c |   55 +++++++-----------------------------------
 1 files changed, 9 insertions(+), 46 deletions(-)

diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index db81aef..f7ffeec 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -108,14 +108,11 @@ struct ieee802_11_elems {
 	u8 wmm_param_len;
 };
 
-enum ParseRes { ParseOK = 0, ParseUnknown = 1, ParseFailed = -1 };
-
-static enum ParseRes ieee802_11_parse_elems(u8 *start, size_t len,
-					    struct ieee802_11_elems *elems)
+static void ieee802_11_parse_elems(u8 *start, size_t len,
+				   struct ieee802_11_elems *elems)
 {
 	size_t left = len;
 	u8 *pos = start;
-	int unknown = 0;
 
 	memset(elems, 0, sizeof(*elems));
 
@@ -126,15 +123,8 @@ static enum ParseRes ieee802_11_parse_elems(u8 *start, size_t len,
 		elen = *pos++;
 		left -= 2;
 
-		if (elen > left) {
-#if 0
-			if (net_ratelimit())
-				printk(KERN_DEBUG "IEEE 802.11 element parse "
-				       "failed (id=%d elen=%d left=%d)\n",
-				       id, elen, left);
-#endif
-			return ParseFailed;
-		}
+		if (elen > left)
+			return;
 
 		switch (id) {
 		case WLAN_EID_SSID:
@@ -201,28 +191,15 @@ static enum ParseRes ieee802_11_parse_elems(u8 *start, size_t len,
 			elems->ext_supp_rates_len = elen;
 			break;
 		default:
-#if 0
-			printk(KERN_DEBUG "IEEE 802.11 element parse ignored "
-				      "unknown element (id=%d elen=%d)\n",
-				      id, elen);
-#endif
-			unknown++;
 			break;
 		}
 
 		left -= elen;
 		pos += elen;
 	}
-
-	/* Do not trigger error if left == 1 as Apple Airport base stations
-	 * send AssocResps that are one spurious byte too long. */
-
-	return unknown ? ParseUnknown : ParseOK;
 }
 
 
-
-
 static int ecw2cw(int ecw)
 {
 	int cw = 1;
@@ -931,12 +908,7 @@ static void ieee80211_auth_challenge(struct net_device *dev,
 
 	printk(KERN_DEBUG "%s: replying to auth challenge\n", dev->name);
 	pos = mgmt->u.auth.variable;
-	if (ieee802_11_parse_elems(pos, len - (pos - (u8 *) mgmt), &elems)
-	    == ParseFailed) {
-		printk(KERN_DEBUG "%s: failed to parse Auth(challenge)\n",
-		       dev->name);
-		return;
-	}
+	ieee802_11_parse_elems(pos, len - (pos - (u8 *) mgmt), &elems);
 	if (!elems.challenge) {
 		printk(KERN_DEBUG "%s: no challenge IE in shared key auth "
 		       "frame\n", dev->name);
@@ -1230,12 +1202,7 @@ static void ieee80211_rx_mgmt_assoc_resp(struct net_device *dev,
 	aid &= ~(BIT(15) | BIT(14));
 
 	pos = mgmt->u.assoc_resp.variable;
-	if (ieee802_11_parse_elems(pos, len - (pos - (u8 *) mgmt), &elems)
-	    == ParseFailed) {
-		printk(KERN_DEBUG "%s: failed to parse AssocResp\n",
-		       dev->name);
-		return;
-	}
+	ieee802_11_parse_elems(pos, len - (pos - (u8 *) mgmt), &elems);
 
 	if (!elems.supp_rates) {
 		printk(KERN_DEBUG "%s: no SuppRates element in AssocResp\n",
@@ -1459,7 +1426,7 @@ static void ieee80211_rx_bss_info(struct net_device *dev,
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee802_11_elems elems;
 	size_t baselen;
-	int channel, invalid = 0, clen;
+	int channel, clen;
 	struct ieee80211_sta_bss *bss;
 	struct sta_info *sta;
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
@@ -1505,9 +1472,7 @@ static void ieee80211_rx_bss_info(struct net_device *dev,
 #endif /* CONFIG_MAC80211_IBSS_DEBUG */
 	}
 
-	if (ieee802_11_parse_elems(mgmt->u.beacon.variable, len - baselen,
-				   &elems) == ParseFailed)
-		invalid = 1;
+	ieee802_11_parse_elems(mgmt->u.beacon.variable, len - baselen, &elems);
 
 	if (sdata->type == IEEE80211_IF_TYPE_IBSS && elems.supp_rates &&
 	    memcmp(mgmt->bssid, sdata->u.sta.bssid, ETH_ALEN) == 0 &&
@@ -1724,9 +1689,7 @@ static void ieee80211_rx_mgmt_beacon(struct net_device *dev,
 	if (baselen > len)
 		return;
 
-	if (ieee802_11_parse_elems(mgmt->u.beacon.variable, len - baselen,
-				   &elems) == ParseFailed)
-		return;
+	ieee802_11_parse_elems(mgmt->u.beacon.variable, len - baselen, &elems);
 
 	if (elems.erp_info && elems.erp_info_len >= 1)
 		ieee80211_handle_erp_ie(dev, elems.erp_info[0]);
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
