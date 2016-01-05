From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] staging: r8192U: Fix check pointer after usage problem
Date: Mon,  4 Jan 2016 20:30:58 -0600
Message-ID: <1451961058-5235-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Yong Shi <brave_shi@163.com>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:36211 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753913AbcAECbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 21:31:15 -0500
Received: by mail-ob0-f173.google.com with SMTP id ba1so263706624obb.3
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 18:31:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In routine rtl8192_tx_isr(), pointer skb is dereferenced before it is
checked for NULL. This patch has only been compile-tested, as I do not
have the hardware. This problem was reported at
https://bugzilla.kernel.org/show_bug.cgi?id=109951.

Fixes: bugzilla.kernel.org: #109951
Reported-by: Yong Shi <brave_shi@163.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Yong Shi <brave_shi@163.com>
---
 drivers/staging/rtl8192u/r8192U_core.c | 21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/rtl8192u/r8192U_core.c b/drivers/staging/rtl8192u/r8192U_core.c
index f4a4eae..87093c0 100644
--- a/drivers/staging/rtl8192u/r8192U_core.c
+++ b/drivers/staging/rtl8192u/r8192U_core.c
@@ -1092,10 +1092,17 @@ static int rtl8192_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 static void rtl8192_tx_isr(struct urb *tx_urb)
 {
 	struct sk_buff *skb = (struct sk_buff *)tx_urb->context;
-	struct net_device *dev = (struct net_device *)(skb->cb);
+	struct net_device *dev;
 	struct r8192_priv *priv = NULL;
-	cb_desc *tcb_desc = (cb_desc *)(skb->cb + MAX_DEV_ADDR_SIZE);
-	u8  queue_index = tcb_desc->queue_index;
+	cb_desc *tcb_desc;
+	u8  queue_index;
+
+	if (!skb)
+		return;
+
+	dev = (struct net_device *)(skb->cb);
+	tcb_desc = (cb_desc *)(skb->cb + MAX_DEV_ADDR_SIZE);
+	queue_index = tcb_desc->queue_index;
 
 	priv = ieee80211_priv(dev);
 
@@ -1113,11 +1120,9 @@ static void rtl8192_tx_isr(struct urb *tx_urb)
 	}
 
 	/* free skb and tx_urb */
-	if (skb != NULL) {
-		dev_kfree_skb_any(skb);
-		usb_free_urb(tx_urb);
-		atomic_dec(&priv->tx_pending[queue_index]);
-	}
+	dev_kfree_skb_any(skb);
+	usb_free_urb(tx_urb);
+	atomic_dec(&priv->tx_pending[queue_index]);
 
 	/*
 	 * Handle HW Beacon:
-- 
2.1.4
