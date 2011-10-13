From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH 8/8] caif-hsi: Added recovery check of CA wake status.
Date: Thu, 13 Oct 2011 23:29:29 +0200
Message-ID: <1318541369-8141-9-git-send-email-sjur.brandeland@stericsson.com>
References: <1318541369-8141-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dmitry.tarnyagin@stericsson.com, daniel.martensson@stericsson.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eterpe-smout.broadpark.no ([80.202.8.16]:41517 "EHLO
	eterpe-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755050Ab1JMWaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 18:30:03 -0400
Received: from ignis-smin.broadpark.no ([80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LT0001F1X1Q7670@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Thu, 13 Oct 2011 23:29:50 +0200 (CEST)
Received: from localhost.localdomain ([80.203.143.169])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LT000HN3X1J7Y00@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Thu, 13 Oct 2011 23:29:50 +0200 (CEST)
In-reply-to: <1318541369-8141-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Daniel Martensson <daniel.martensson@stericsson.com>

Added recovery check of CA wake status in case of wake up timeout.
Added check of CA wake status in case of wake down timeout.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_hsi.c |   42 +++++++++++++++++++++++++++++++++++=
+++++--
 include/net/caif/caif_hsi.h |    1 +
 2 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index e9e7cbf..0733525 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -674,6 +674,7 @@ static void cfhsi_wake_up(struct work_struct *work)
 		/* It happenes when wakeup is requested by
 		 * both ends at the same time. */
 		clear_bit(CFHSI_WAKE_UP, &cfhsi->bits);
+		clear_bit(CFHSI_WAKE_UP_ACK, &cfhsi->bits);
 		return;
 	}
=20
@@ -690,19 +691,47 @@ static void cfhsi_wake_up(struct work_struct *wor=
k)
 							&cfhsi->bits), ret);
 	if (unlikely(ret < 0)) {
 		/* Interrupted by signal. */
-		dev_info(&cfhsi->ndev->dev, "%s: Signalled: %ld.\n",
+		dev_err(&cfhsi->ndev->dev, "%s: Signalled: %ld.\n",
 			__func__, ret);
+
 		clear_bit(CFHSI_WAKE_UP, &cfhsi->bits);
 		cfhsi->dev->cfhsi_wake_down(cfhsi->dev);
 		return;
 	} else if (!ret) {
+		bool ca_wake =3D false;
+		size_t fifo_occupancy =3D 0;
+
 		/* Wakeup timeout */
 		dev_err(&cfhsi->ndev->dev, "%s: Timeout.\n",
 			__func__);
+
+		/* Check FIFO to check if modem has sent something. */
+		WARN_ON(cfhsi->dev->cfhsi_fifo_occupancy(cfhsi->dev,
+					&fifo_occupancy));
+
+		dev_err(&cfhsi->ndev->dev, "%s: Bytes in FIFO: %u.\n",
+				__func__, (unsigned) fifo_occupancy);
+
+		/* Check if we misssed the interrupt. */
+		WARN_ON(cfhsi->dev->cfhsi_get_peer_wake(cfhsi->dev,
+							&ca_wake));
+
+		if (ca_wake) {
+			dev_err(&cfhsi->ndev->dev, "%s: CA Wake missed !.\n",
+				__func__);
+
+			/* Clear the CFHSI_WAKE_UP_ACK bit to prevent race. */
+			clear_bit(CFHSI_WAKE_UP_ACK, &cfhsi->bits);
+
+			/* Continue execution. */
+			goto wake_ack;
+		}
+
 		clear_bit(CFHSI_WAKE_UP, &cfhsi->bits);
 		cfhsi->dev->cfhsi_wake_down(cfhsi->dev);
 		return;
 	}
+wake_ack:
 	dev_dbg(&cfhsi->ndev->dev, "%s: Woken.\n",
 		__func__);
=20
@@ -779,12 +808,21 @@ static void cfhsi_wake_down(struct work_struct *w=
ork)
 							&cfhsi->bits), ret);
 	if (ret < 0) {
 		/* Interrupted by signal. */
-		dev_info(&cfhsi->ndev->dev, "%s: Signalled: %ld.\n",
+		dev_err(&cfhsi->ndev->dev, "%s: Signalled: %ld.\n",
 			__func__, ret);
 		return;
 	} else if (!ret) {
+		bool ca_wake =3D true;
+
 		/* Timeout */
 		dev_err(&cfhsi->ndev->dev, "%s: Timeout.\n", __func__);
+
+		/* Check if we misssed the interrupt. */
+		WARN_ON(cfhsi->dev->cfhsi_get_peer_wake(cfhsi->dev,
+							&ca_wake));
+		if (!ca_wake)
+			dev_err(&cfhsi->ndev->dev, "%s: CA Wake missed !.\n",
+				__func__);
 	}
=20
 	/* Check FIFO occupancy. */
diff --git a/include/net/caif/caif_hsi.h b/include/net/caif/caif_hsi.h
index 3356769..8d55251 100644
--- a/include/net/caif/caif_hsi.h
+++ b/include/net/caif/caif_hsi.h
@@ -108,6 +108,7 @@ struct cfhsi_dev {
 	int (*cfhsi_rx) (u8 *ptr, int len, struct cfhsi_dev *dev);
 	int (*cfhsi_wake_up) (struct cfhsi_dev *dev);
 	int (*cfhsi_wake_down) (struct cfhsi_dev *dev);
+	int (*cfhsi_get_peer_wake) (struct cfhsi_dev *dev, bool *status);
 	int (*cfhsi_fifo_occupancy)(struct cfhsi_dev *dev, size_t *occupancy)=
;
 	int (*cfhsi_rx_cancel)(struct cfhsi_dev *dev);
 	struct cfhsi_drv *drv;
--=20
1.7.0.4
