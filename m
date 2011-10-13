From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH 2/8] caif-hsi: Fixing a race condition in the caif_hsi code
Date: Thu, 13 Oct 2011 23:29:23 +0200
Message-ID: <1318541369-8141-3-git-send-email-sjur.brandeland@stericsson.com>
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
	with ESMTP id S1753941Ab1JMW35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 18:29:57 -0400
Received: from ignis-smin.broadpark.no ([80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LT0001DXX1M7670@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Thu, 13 Oct 2011 23:29:46 +0200 (CEST)
Received: from localhost.localdomain ([80.203.143.169])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LT000HN3X1J7Y00@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Thu, 13 Oct 2011 23:29:46 +0200 (CEST)
In-reply-to: <1318541369-8141-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>

cfhsi->tx_state was not protected by a spin lock. TX soft-irq could int=
errupt
cfhsi_tx_done_work work leading to inconsistent state of the driver.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_hsi.c |   25 ++++++++++++++++++-------
 1 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 1937813..36da27b 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -304,14 +304,22 @@ static void cfhsi_tx_done_work(struct work_struct=
 *work)
 		spin_unlock_bh(&cfhsi->lock);
=20
 		/* Create HSI frame. */
-		len =3D cfhsi_tx_frm(desc, cfhsi);
-		if (!len) {
-			cfhsi->tx_state =3D CFHSI_TX_STATE_IDLE;
-			/* Start inactivity timer. */
-			mod_timer(&cfhsi->timer,
+		do {
+			len =3D cfhsi_tx_frm(desc, cfhsi);
+			if (!len) {
+				spin_lock_bh(&cfhsi->lock);
+				if (unlikely(skb_peek(&cfhsi->qhead))) {
+					spin_unlock_bh(&cfhsi->lock);
+					continue;
+				}
+				cfhsi->tx_state =3D CFHSI_TX_STATE_IDLE;
+				/* Start inactivity timer. */
+				mod_timer(&cfhsi->timer,
 					jiffies + CFHSI_INACTIVITY_TOUT);
-			break;
-		}
+				spin_unlock_bh(&cfhsi->lock);
+				goto done;
+			}
+		} while (!len);
=20
 		/* Set up new transfer. */
 		res =3D cfhsi->dev->cfhsi_tx(cfhsi->tx_buf, len, cfhsi->dev);
@@ -320,6 +328,9 @@ static void cfhsi_tx_done_work(struct work_struct *=
work)
 				__func__, res);
 		}
 	} while (res < 0);
+
+done:
+	return;
 }
=20
 static void cfhsi_tx_done_cb(struct cfhsi_drv *drv)
--=20
1.7.0.4
