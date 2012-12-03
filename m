From: John Greene <jogreene@redhat.com>
Subject: [RFT PATCH] 8139cp: properly support change of MTU values [v2]
Date: Mon,  3 Dec 2012 11:19:33 -0500
Message-ID: <1354551573-23721-1-git-send-email-jogreene@redhat.com>
Cc: John Greene <jogreene@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpe-075-189-159-031.nc.res.rr.com ([75.189.159.31]:38906 "EHLO
	jgpicker" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751758Ab2LCQVl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2012 11:21:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 8139cp driver has a change_mtu function that has not been
enabled since the dawn of the git repository. However, the
generic eth_change_mtu is not used in its place, so that
invalid MTU values can be set on the interface.

Original patch salvages the broken code for the single case of
setting the MTU while the interface is down, which is safe
and also includes the range check.  Now enhanced to support up
or down interface.

v2: fix case where rxbufsz isn't changed in the up state case

Original patch from
http://lkml.indiana.edu/hypermail/linux/kernel/1202.2/00770.html

Testing: has been test on virtual 8139cp setup without issue,
have no access real hardware 8139cp, need testing help.

Signed-off-by: "John Greene" <jogreene@redhat.com>
CC: "David S. Miller" <davem@davemloft.net>
---
 drivers/net/ethernet/realtek/8139cp.c | 23 ++++-------------------
 1 file changed, 4 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 6cb96b4..0da3f5e 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -1226,12 +1226,9 @@ static void cp_tx_timeout(struct net_device *dev)
 	spin_unlock_irqrestore(&cp->lock, flags);
 }
 
-#ifdef BROKEN
 static int cp_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct cp_private *cp = netdev_priv(dev);
-	int rc;
-	unsigned long flags;
 
 	/* check for invalid MTU, according to hardware limits */
 	if (new_mtu < CP_MIN_MTU || new_mtu > CP_MAX_MTU)
@@ -1244,22 +1241,12 @@ static int cp_change_mtu(struct net_device *dev, int new_mtu)
 		return 0;
 	}
 
-	spin_lock_irqsave(&cp->lock, flags);
-
-	cp_stop_hw(cp);			/* stop h/w and free rings */
-	cp_clean_rings(cp);
-
+	/* network IS up, close it, reset MTU, and come up again. */
+	cp_close(dev);
 	dev->mtu = new_mtu;
-	cp_set_rxbufsize(cp);		/* set new rx buf size */
-
-	rc = cp_init_rings(cp);		/* realloc and restart h/w */
-	cp_start_hw(cp);
-
-	spin_unlock_irqrestore(&cp->lock, flags);
-
-	return rc;
+	cp_set_rxbufsize(cp);
+	return cp_open(dev);
 }
-#endif /* BROKEN */
 
 static const char mii_2_8139_map[8] = {
 	BasicModeCtrl,
@@ -1835,9 +1822,7 @@ static const struct net_device_ops cp_netdev_ops = {
 	.ndo_start_xmit		= cp_start_xmit,
 	.ndo_tx_timeout		= cp_tx_timeout,
 	.ndo_set_features	= cp_set_features,
-#ifdef BROKEN
 	.ndo_change_mtu		= cp_change_mtu,
-#endif
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= cp_poll_controller,
-- 
1.7.11.7
