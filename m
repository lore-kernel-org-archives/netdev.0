From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH net-next 3/3] caif: Add wakeline status tracking
Date: Thu,  2 Feb 2012 12:19:25 +0100
Message-ID: <1328181565-13781-3-git-send-email-sjur.brandeland@stericsson.com>
References: <1328181565-13781-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:41161 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753917Ab2BBLTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 06:19:37 -0500
Received: by mail-lpp01m010-f46.google.com with SMTP id u2so1211951lag.19
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2012 03:19:36 -0800 (PST)
In-Reply-To: <1328181565-13781-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add initial support for tracking of wake-line status so we at any time
know when we have a timer running and HSI wake-line high.

The cfhsi_notify_rx, and cfhsi_wakeline_aquired/released are
dummies for now.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_hsi.c |   25 +++++++++++++++++++++++--
 include/net/caif/caif_hsi.h |    8 ++++++++
 2 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 0a4fc62..749586f 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -399,6 +399,7 @@ static int cfhsi_rx_desc(struct cfhsi_desc *desc, s=
truct cfhsi *cfhsi)
 			netif_rx(skb);
 		else
 			netif_rx_ni(skb);
+		cfhsi_notify_rx(cfhsi);
=20
 		/* Update network statistics. */
 		cfhsi->ndev->stats.rx_packets++;
@@ -500,6 +501,7 @@ static int cfhsi_rx_pld(struct cfhsi_desc *desc, st=
ruct cfhsi *cfhsi)
 			netif_rx(skb);
 		else
 			netif_rx_ni(skb);
+		cfhsi_notify_rx(cfhsi);
=20
 		/* Update network statistics. */
 		cfhsi->ndev->stats.rx_packets++;
@@ -787,6 +789,9 @@ static void cfhsi_wake_down(struct work_struct *wor=
k)
 	if (test_bit(CFHSI_SHUTDOWN, &cfhsi->bits))
 		return;
=20
+	/* Clear spurious states (if any) */
+	WARN_ON(test_and_clear_bit(CFHSI_WAKE_DOWN_ACK, &cfhsi->bits));
+
 	/* Deactivate wake line. */
 	cfhsi->dev->cfhsi_wake_down(cfhsi->dev);
=20
@@ -836,6 +841,10 @@ static void cfhsi_wake_down(struct work_struct *wo=
rk)
 	/* Cancel pending RX requests. */
 	cfhsi->dev->cfhsi_rx_cancel(cfhsi->dev);
=20
+	spin_lock_bh(&cfhsi->lock);
+	if (!test_bit(CFHSI_WAKE_UP, &cfhsi->bits))
+		cfhsi_wakeline_released(cfhsi);
+	spin_unlock_bh(&cfhsi->lock);
 }
=20
 static void cfhsi_out_of_sync(struct work_struct *work)
@@ -864,8 +873,12 @@ static void cfhsi_wake_up_cb(struct cfhsi_drv *drv=
)
 		return;
=20
 	/* Schedule wake up work queue if the peer initiates. */
-	if (!test_and_set_bit(CFHSI_WAKE_UP, &cfhsi->bits))
+	spin_lock_bh(&cfhsi->lock);
+	if (!test_and_set_bit(CFHSI_WAKE_UP, &cfhsi->bits)) {
+		cfhsi_wakeline_aquired(cfhsi);
 		queue_work(cfhsi->wq, &cfhsi->wake_up_work);
+	}
+	spin_unlock_bh(&cfhsi->lock);
 }
=20
 static void cfhsi_wake_down_cb(struct cfhsi_drv *drv)
@@ -944,8 +957,12 @@ static int cfhsi_xmit(struct sk_buff *skb, struct =
net_device *dev)
 		}
 	} else {
 		/* Schedule wake up work queue if the we initiate. */
-		if (!test_and_set_bit(CFHSI_WAKE_UP, &cfhsi->bits))
+		spin_lock_bh(&cfhsi->lock);
+		if (!test_and_set_bit(CFHSI_WAKE_UP, &cfhsi->bits)) {
+			cfhsi_wakeline_aquired(cfhsi);
 			queue_work(cfhsi->wq, &cfhsi->wake_up_work);
+		}
+		spin_unlock_bh(&cfhsi->lock);
 	}
=20
 	return 0;
@@ -1099,6 +1116,8 @@ int cfhsi_probe(struct platform_device *pdev)
 	cfhsi->rx_slowpath_timer.data =3D (unsigned long)cfhsi;
 	cfhsi->rx_slowpath_timer.function =3D cfhsi_rx_slowpath;
=20
+	cfhsi_wakeline_init();
+
 	/* Add CAIF HSI device to list. */
 	spin_lock(&cfhsi_list_lock);
 	list_add_tail(&cfhsi->list, &cfhsi_list);
@@ -1180,6 +1199,8 @@ static void cfhsi_shutdown(struct cfhsi *cfhsi)
 	/* Deactivate interface */
 	cfhsi->dev->cfhsi_down(cfhsi->dev);
=20
+	cfhsi_wakeline_deinit();
+
 	/* Finally unregister the network device. */
 	unregister_netdev(cfhsi->ndev);
=20
diff --git a/include/net/caif/caif_hsi.h b/include/net/caif/caif_hsi.h
index 8d55251..5caefc6 100644
--- a/include/net/caif/caif_hsi.h
+++ b/include/net/caif/caif_hsi.h
@@ -157,4 +157,12 @@ struct cfhsi {
=20
 extern struct platform_driver cfhsi_driver;
=20
+#ifndef CFHSI_WAKELOCKS
+#define cfhsi_wakeline_aquired(dev)
+#define cfhsi_wakeline_released(dev)
+#define cfhsi_notify_rx(dev)
+#define cfhsi_wakeline_init(dev)
+#define cfhsi_wakeline_deinit(dev)
+#endif
+
 #endif		/* CAIF_HSI_H_ */
--=20
1.7.5.4
