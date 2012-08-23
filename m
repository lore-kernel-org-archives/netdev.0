From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] orinoco: use is_zero_ether_addr() instead of memcmp()
Date: Thu, 23 Aug 2012 14:55:02 +0800
Message-ID: <CAPgLHd8vJYvcUnDUwD-WuZTcxbfA8f+gjhQihuvLqTzS==sR9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:35918 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753235Ab2HWGzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 02:55:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Using is_zero_ether_addr() instead of directly use
memcmp() to determine if the ethernet address is all
zeros.

spatch with a semantic match is used to found this problem.
(http://coccinelle.lip6.fr/)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/wireless/orinoco/wext.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/orinoco/wext.c b/drivers/net/wireless/orinoco/wext.c
index 33747e1..3b5508f 100644
--- a/drivers/net/wireless/orinoco/wext.c
+++ b/drivers/net/wireless/orinoco/wext.c
@@ -7,6 +7,7 @@
 #include <linux/if_arp.h>
 #include <linux/wireless.h>
 #include <linux/ieee80211.h>
+#include <linux/etherdevice.h>
 #include <net/iw_handler.h>
 #include <net/cfg80211.h>
 #include <net/cfg80211-wext.h>
@@ -159,15 +160,13 @@ static int orinoco_ioctl_setwap(struct net_device *dev,
 	struct orinoco_private *priv = ndev_priv(dev);
 	int err = -EINPROGRESS;		/* Call commit handler */
 	unsigned long flags;
-	static const u8 off_addr[] = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
-	static const u8 any_addr[] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
 
 	if (orinoco_lock(priv, &flags) != 0)
 		return -EBUSY;
 
 	/* Enable automatic roaming - no sanity checks are needed */
-	if (memcmp(&ap_addr->sa_data, off_addr, ETH_ALEN) == 0 ||
-	    memcmp(&ap_addr->sa_data, any_addr, ETH_ALEN) == 0) {
+	if (is_zero_ether_addr(ap_addr->sa_data) ||
+	    is_broadcast_ether_addr(ap_addr->sa_data)) {
 		priv->bssid_fixed = 0;
 		memset(priv->desired_bssid, 0, ETH_ALEN);
 
