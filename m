From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2008-11-12
Date: Wed, 12 Nov 2008 17:27:39 -0500
Message-ID: <20081112222739.GK2411@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36209 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752923AbYKLWbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 17:31:08 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

A few fixes intended for 2.6.28.  Included are a couple of USB IDs, a
mac80211 fix to avoid sleeping during RCU, and a nasty hack to hostap to
make it's skb->cb trickery work again...

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit d809a1595610a7c0b0bd55f159e5dc37def0ac28:
  David S. Miller (1):
        Merge branch 'davem-fixes' of master.kernel.org:/.../jgarzik/netdev-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Bob Jolliffe (1):
      rtl8187 : support for Sitecom WL-168 0001 v4

Ivan Kuten (1):
      rtl8187: Add Abocom USB ID

Johannes Berg (2):
      mac80211: fix notify_mac function
      hostap: pad the skb->cb usage in lieu of a proper fix

 drivers/net/wireless/hostap/hostap_wlan.h |    5 ++++-
 drivers/net/wireless/rtl8187_dev.c        |    3 +++
 net/mac80211/mlme.c                       |    6 +++---
 3 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_wlan.h b/drivers/net/wireless/hostap/hostap_wlan.h
index ffdf487..a68f97c 100644
--- a/drivers/net/wireless/hostap/hostap_wlan.h
+++ b/drivers/net/wireless/hostap/hostap_wlan.h
@@ -918,9 +918,12 @@ struct hostap_interface {
 
 /*
  * TX meta data - stored in skb->cb buffer, so this must not be increased over
- * the 40-byte limit
+ * the 48-byte limit.
+ * THE PADDING THIS STARTS WITH IS A HORRIBLE HACK THAT SHOULD NOT LIVE
+ * TO SEE THE DAY.
  */
 struct hostap_skb_tx_data {
+	unsigned int __padding_for_default_qdiscs;
 	u32 magic; /* HOSTAP_SKB_TX_DATA_MAGIC */
 	u8 rate; /* transmit rate */
 #define HOSTAP_TX_FLAGS_WDS BIT(0)
diff --git a/drivers/net/wireless/rtl8187_dev.c b/drivers/net/wireless/rtl8187_dev.c
index 431e3c7..69eb013 100644
--- a/drivers/net/wireless/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl8187_dev.c
@@ -48,6 +48,9 @@ static struct usb_device_id rtl8187_table[] __devinitdata = {
 	{USB_DEVICE(0x03f0, 0xca02), .driver_info = DEVICE_RTL8187},
 	/* Sitecom */
 	{USB_DEVICE(0x0df6, 0x000d), .driver_info = DEVICE_RTL8187},
+	{USB_DEVICE(0x0df6, 0x0028), .driver_info = DEVICE_RTL8187B},
+	/* Abocom */
+	{USB_DEVICE(0x13d1, 0xabe6), .driver_info = DEVICE_RTL8187},
 	{}
 };
 
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 87665d7..14d165f 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -2570,14 +2570,14 @@ void ieee80211_notify_mac(struct ieee80211_hw *hw,
 
 	switch (notif_type) {
 	case IEEE80211_NOTIFY_RE_ASSOC:
-		rcu_read_lock();
-		list_for_each_entry_rcu(sdata, &local->interfaces, list) {
+		rtnl_lock();
+		list_for_each_entry(sdata, &local->interfaces, list) {
 			if (sdata->vif.type != NL80211_IFTYPE_STATION)
 				continue;
 
 			ieee80211_sta_req_auth(sdata, &sdata->u.sta);
 		}
-		rcu_read_unlock();
+		rtnl_unlock();
 		break;
 	}
 }
-- 
John W. Linville		Linux should be at the core
linville@tuxdriver.com			of your literate lifestyle.
