From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH 6/8] caif-hsi: Make inactivity timeout configurable.
Date: Thu, 13 Oct 2011 23:29:27 +0200
Message-ID: <1318541369-8141-7-git-send-email-sjur.brandeland@stericsson.com>
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
	with ESMTP id S1754957Ab1JMWaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 18:30:00 -0400
Received: from ignis-smin.broadpark.no ([80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LT0001EOX1O7670@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Thu, 13 Oct 2011 23:29:48 +0200 (CEST)
Received: from localhost.localdomain ([80.203.143.169])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LT000HN3X1J7Y00@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Thu, 13 Oct 2011 23:29:48 +0200 (CEST)
In-reply-to: <1318541369-8141-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>

CAIF HSI uses a timer for inactivity. Upon timeout HSI-wake signaling
is initiated to allow power-down of the HSI block.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_hsi.c |   28 +++++++++++++++++++++++-----
 include/net/caif/caif_hsi.h |    1 +
 2 files changed, 24 insertions(+), 5 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index f46ab4d..1e1f0a3 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -29,6 +29,10 @@ MODULE_DESCRIPTION("CAIF HSI driver");
 #define PAD_POW2(x, pow) ((((x)&((pow)-1)) =3D=3D 0) ? 0 :\
 				(((pow)-((x)&((pow)-1)))))
=20
+static int inactivity_timeout =3D 1000;
+module_param(inactivity_timeout, int, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(inactivity_timeout, "Inactivity timeout on HSI, ms.")=
;
+
 /*
  * HSI padding options.
  * Warning: must be a base of 2 (& operation used) and can not be zero=
 !
@@ -98,7 +102,8 @@ static void cfhsi_abort_tx(struct cfhsi *cfhsi)
 	}
 	cfhsi->tx_state =3D CFHSI_TX_STATE_IDLE;
 	if (!test_bit(CFHSI_SHUTDOWN, &cfhsi->bits))
-		mod_timer(&cfhsi->timer, jiffies + CFHSI_INACTIVITY_TOUT);
+		mod_timer(&cfhsi->timer,
+			jiffies + cfhsi->inactivity_timeout);
 	spin_unlock_bh(&cfhsi->lock);
 }
=20
@@ -312,7 +317,7 @@ static void cfhsi_tx_done(struct cfhsi *cfhsi)
 				cfhsi->tx_state =3D CFHSI_TX_STATE_IDLE;
 				/* Start inactivity timer. */
 				mod_timer(&cfhsi->timer,
-					jiffies + CFHSI_INACTIVITY_TOUT);
+					jiffies + cfhsi->inactivity_timeout);
 				spin_unlock_bh(&cfhsi->lock);
 				goto done;
 			}
@@ -534,7 +539,8 @@ static void cfhsi_rx_done(struct cfhsi *cfhsi)
=20
 	/* Update inactivity timer if pending. */
 	spin_lock_bh(&cfhsi->lock);
-	mod_timer_pending(&cfhsi->timer, jiffies + CFHSI_INACTIVITY_TOUT);
+	mod_timer_pending(&cfhsi->timer,
+			jiffies + cfhsi->inactivity_timeout);
 	spin_unlock_bh(&cfhsi->lock);
=20
 	if (cfhsi->rx_state.state =3D=3D CFHSI_RX_STATE_DESC) {
@@ -715,7 +721,7 @@ static void cfhsi_wake_up(struct work_struct *work)
 			__func__);
 		/* Start inactivity timer. */
 		mod_timer(&cfhsi->timer,
-				jiffies + CFHSI_INACTIVITY_TOUT);
+				jiffies + cfhsi->inactivity_timeout);
 		spin_unlock_bh(&cfhsi->lock);
 		return;
 	}
@@ -989,7 +995,19 @@ int cfhsi_probe(struct platform_device *pdev)
 		goto err_alloc_rx;
 	}
=20
-	/* Initialize receive variables. */
+	/* Pre-calculate inactivity timeout. */
+	if (inactivity_timeout !=3D -1) {
+		cfhsi->inactivity_timeout =3D
+				inactivity_timeout * HZ / 1000;
+		if (!cfhsi->inactivity_timeout)
+			cfhsi->inactivity_timeout =3D 1;
+		else if (cfhsi->inactivity_timeout > NEXT_TIMER_MAX_DELTA)
+			cfhsi->inactivity_timeout =3D NEXT_TIMER_MAX_DELTA;
+	} else {
+		cfhsi->inactivity_timeout =3D NEXT_TIMER_MAX_DELTA;
+	}
+
+	/* Initialize recieve vaiables. */
 	cfhsi->rx_ptr =3D cfhsi->rx_buf;
 	cfhsi->rx_len =3D CFHSI_DESC_SZ;
=20
diff --git a/include/net/caif/caif_hsi.h b/include/net/caif/caif_hsi.h
index 17dff45..9b69d15 100644
--- a/include/net/caif/caif_hsi.h
+++ b/include/net/caif/caif_hsi.h
@@ -131,6 +131,7 @@ struct cfhsi {
 	struct cfhsi_dev *dev;
 	int tx_state;
 	struct cfhsi_rx_state rx_state;
+	unsigned long inactivity_timeout;
 	int rx_len;
 	u8 *rx_ptr;
 	u8 *tx_buf;
--=20
1.7.0.4
