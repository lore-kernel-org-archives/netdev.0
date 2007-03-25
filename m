From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw-mac80211: Fix for monitor mode bug
Date: Mon, 26 Mar 2007 00:18:17 +0100 (BST)
Message-ID: <20070325231817.9C5887B409F@zog.reactivated.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>

The ZD1211 supports the delivery of packets with a wrong CRC value
to the host. We switched that feature on in monitor mode, so that
incomplete packets were delivered.

This problem has been reported to bugzilla.kernel.org as bug 8152.
This patch fixes it for the mac80211 stack.

Signed-off-by: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/mac80211/zd1211rw/zd_mac.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c b/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
index 097f614..65eabfa 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
@@ -91,17 +91,9 @@ void zd_mac_clear(struct zd_mac *mac)
 
 static int reset_mode(struct zd_mac *mac)
 {
-	struct zd_ioreq32 ioreqs[] = {
-		{ CR_RX_FILTER, STA_RX_FILTER },
-		{ CR_SNIFFER_ON, 0U },
-	};
-
-	if (mac->mode == IEEE80211_IF_TYPE_MNTR) {
-		ioreqs[0].value = 0xffffffff;
-		ioreqs[1].value = 0x1;
-	}
+	u32 filter = mac->mode == IEEE80211_IF_TYPE_MNTR ? ~0 : STA_RX_FILTER;
 
-	return zd_iowrite32a(&mac->chip, ioreqs, ARRAY_SIZE(ioreqs));
+	return zd_iowrite32(&mac->chip, CR_RX_FILTER, filter);
 }
 
 static int zd_mac_open(struct ieee80211_hw *dev)
-- 
1.5.0.5
