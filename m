From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Don't handle broken frames in monitor mode
Date: Mon, 26 Mar 2007 00:59:47 +0100 (BST)
Message-ID: <20070325235947.454967B409F@zog.reactivated.net>
Cc: netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:33281 "EHLO
	mtaout02-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933058AbXCYX7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Mar 2007 19:59:42 -0400
Cc: linux-wireless@vger.kernel.org
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using monitor mode, Johannes Berg observed out that lots of corrupted
and otherwise invalid frames were being passed to the host.

When in monitor mode we were disabling the hardware filtering here, but
this is not how monitor mode should work.

Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_mac.c |   13 ++-----------
 1 files changed, 2 insertions(+), 11 deletions(-)

Index: linux-zd1211rw/drivers/net/wireless/zd1211rw/zd_mac.c
===================================================================
--- linux-zd1211rw.orig/drivers/net/wireless/zd1211rw/zd_mac.c
+++ linux-zd1211rw/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -156,17 +156,8 @@ void zd_mac_clear(struct zd_mac *mac)
 static int reset_mode(struct zd_mac *mac)
 {
 	struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
-	struct zd_ioreq32 ioreqs[] = {
-		{ CR_RX_FILTER, STA_RX_FILTER },
-		{ CR_SNIFFER_ON, 0U },
-	};
-
-	if (ieee->iw_mode == IW_MODE_MONITOR) {
-		ioreqs[0].value = 0xffffffff;
-		ioreqs[1].value = 0x1;
-	}
-
-	return zd_iowrite32a(&mac->chip, ioreqs, ARRAY_SIZE(ioreqs));
+	u32 filter = (ieee->iw_mode == IW_MODE_MONITOR) ? ~0 : STA_RX_FILTER;
+	return zd_iowrite32(&mac->chip, CR_RX_FILTER, filter);
 }
 
 int zd_mac_open(struct net_device *netdev)
