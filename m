From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH 1/8] caif-hsi: HSI Fix uninitialized data in HSI header
Date: Thu, 13 Oct 2011 23:29:22 +0200
Message-ID: <1318541369-8141-2-git-send-email-sjur.brandeland@stericsson.com>
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
	with ESMTP id S1754396Ab1JMW34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 18:29:56 -0400
Received: from ignis-smin.broadpark.no ([80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LT0001DRX1L7670@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Thu, 13 Oct 2011 23:29:45 +0200 (CEST)
Received: from localhost.localdomain ([80.203.143.169])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LT000HN3X1J7Y00@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Thu, 13 Oct 2011 23:29:45 +0200 (CEST)
In-reply-to: <1318541369-8141-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CAIF HSI header may be uninitialized and cause last message to
be repeated if transmit size is ~86 bytes long.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_hsi.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 2fcabba..1937813 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -178,6 +178,9 @@ static int cfhsi_tx_frm(struct cfhsi_desc *desc, st=
ruct cfhsi *cfhsi)
 	if (!skb)
 		return 0;
=20
+	/* Clear offset. */
+	desc->offset =3D 0;
+
 	/* Check if we can embed a CAIF frame. */
 	if (skb->len < CFHSI_MAX_EMB_FRM_SZ) {
 		struct caif_payload_info *info;
@@ -206,9 +209,7 @@ static int cfhsi_tx_frm(struct cfhsi_desc *desc, st=
ruct cfhsi *cfhsi)
 			consume_skb(skb);
 			skb =3D NULL;
 		}
-	} else
-		/* Clear offset. */
-		desc->offset =3D 0;
+	}
=20
 	/* Create payload CAIF frames. */
 	pfrm =3D desc->emb_frm + CFHSI_MAX_EMB_FRM_SZ;
@@ -990,6 +991,8 @@ int cfhsi_probe(struct platform_device *pdev)
 	/* Set up the driver. */
 	cfhsi->drv.tx_done_cb =3D cfhsi_tx_done_cb;
 	cfhsi->drv.rx_done_cb =3D cfhsi_rx_done_cb;
+	cfhsi->drv.wake_up_cb =3D cfhsi_wake_up_cb;
+	cfhsi->drv.wake_down_cb =3D cfhsi_wake_down_cb;
=20
 	/* Initialize the work queues. */
 	INIT_WORK(&cfhsi->wake_up_work, cfhsi_wake_up);
@@ -1045,9 +1048,6 @@ int cfhsi_probe(struct platform_device *pdev)
 		goto err_net_reg;
 	}
=20
-	cfhsi->drv.wake_up_cb =3D cfhsi_wake_up_cb;
-	cfhsi->drv.wake_down_cb =3D cfhsi_wake_down_cb;
-
 	/* Register network device. */
 	res =3D register_netdev(ndev);
 	if (res) {
--=20
1.7.0.4
