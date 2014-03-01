From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next] ieee802154: fix at86rf212_set_txpower() exit path
Date: Sat,  1 Mar 2014 15:54:36 -0700
Message-ID: <1393714476-21515-1-git-send-email-sakiwit@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:47851 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753296AbaCAW56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Mar 2014 17:57:58 -0500
Received: by mail-pb0-f53.google.com with SMTP id rp16so2244197pbb.26
        for <netdev@vger.kernel.org>; Sat, 01 Mar 2014 14:57:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 9b2777d6089bc ("ieee802154: add TX power control to
wpan_phy") introduced the new function at86rf212_set_txpower() with
the questionable check of the return of __at86rf230_write() in the
exit path:

1) Both at86rf212_set_txpower() and __at86rf230_write() have the
   same return type.

2) Whatever __at86rf230_write() returns becomes the return value of
   at86rf212_set_txpower().

Thus, fix the exit path by getting rid of that check entirely.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Cc: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 drivers/net/ieee802154/at86rf230.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index dd9ef5e1c730..03e24c560b2e 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -786,7 +786,6 @@ static int
 at86rf212_set_txpower(struct ieee802154_dev *dev, int db)
 {
 	struct at86rf230_local *lp = dev->priv;
-	int rc;
 
 	/* typical maximum output is 5dBm with RG_PHY_TX_PWR 0x60, lower five
 	 * bits decrease power in 1dB steps. 0x60 represents extra PA gain of
@@ -799,11 +798,7 @@ at86rf212_set_txpower(struct ieee802154_dev *dev, int db)
 
 	db = -(db - 5);
 
-	rc = __at86rf230_write(lp, RG_PHY_TX_PWR, 0x60 | db);
-	if (rc)
-		return rc;
-
-	return 0;
+	return __at86rf230_write(lp, RG_PHY_TX_PWR, 0x60 | db);
 }
 
 static int
