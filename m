From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH 5/8] caif-hsi: HSI-Platform device register and unregisters
 itself
Date: Thu, 13 Oct 2011 23:29:26 +0200
Message-ID: <1318541369-8141-6-git-send-email-sjur.brandeland@stericsson.com>
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
	with ESMTP id S1754396Ab1JMWaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 18:30:00 -0400
Received: from ignis-smin.broadpark.no ([80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LT0001EGX1N7670@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Thu, 13 Oct 2011 23:29:47 +0200 (CEST)
Received: from localhost.localdomain ([80.203.143.169])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LT000HN3X1J7Y00@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Thu, 13 Oct 2011 23:29:47 +0200 (CEST)
In-reply-to: <1318541369-8141-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Daniel Martensson <daniel.martensson@stericsson.com>

Platform device is no longer removed from caif_hsi at shutdown.
The HSI-platform device must do it's own registration and unregistratio=
n.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_hsi.c |   16 ++++------------
 1 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 478b025..f46ab4d 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -1083,7 +1083,7 @@ int cfhsi_probe(struct platform_device *pdev)
 	return res;
 }
=20
-static void cfhsi_shutdown(struct cfhsi *cfhsi, bool remove_platform_d=
ev)
+static void cfhsi_shutdown(struct cfhsi *cfhsi)
 {
 	u8 *tx_buf, *rx_buf;
=20
@@ -1093,14 +1093,6 @@ static void cfhsi_shutdown(struct cfhsi *cfhsi, =
bool remove_platform_dev)
 	/* going to shutdown driver */
 	set_bit(CFHSI_SHUTDOWN, &cfhsi->bits);
=20
-	if (remove_platform_dev) {
-		/* Flush workqueue */
-		flush_workqueue(cfhsi->wq);
-
-		/* Notify device. */
-		platform_device_unregister(cfhsi->pdev);
-	}
-
 	/* Flush workqueue */
 	flush_workqueue(cfhsi->wq);
=20
@@ -1111,7 +1103,7 @@ static void cfhsi_shutdown(struct cfhsi *cfhsi, b=
ool remove_platform_dev)
 	/* Cancel pending RX request (if any) */
 	cfhsi->dev->cfhsi_rx_cancel(cfhsi->dev);
=20
-	/* Flush again and destroy workqueue */
+	/* Destroy workqueue */
 	destroy_workqueue(cfhsi->wq);
=20
 	/* Store bufferes: will be freed later. */
@@ -1150,7 +1142,7 @@ int cfhsi_remove(struct platform_device *pdev)
 			spin_unlock(&cfhsi_list_lock);
=20
 			/* Shutdown driver. */
-			cfhsi_shutdown(cfhsi, false);
+			cfhsi_shutdown(cfhsi);
=20
 			return 0;
 		}
@@ -1183,7 +1175,7 @@ static void __exit cfhsi_exit_module(void)
 		spin_unlock(&cfhsi_list_lock);
=20
 		/* Shutdown driver. */
-		cfhsi_shutdown(cfhsi, true);
+		cfhsi_shutdown(cfhsi);
=20
 		spin_lock(&cfhsi_list_lock);
 	}
--=20
1.7.0.4
