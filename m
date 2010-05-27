From: =?utf-8?q?Eric=20B=C3=A9nard?= <eric@eukrea.com>
Subject: [PATCH] net/fec: fix pm to survive to suspend/resume
Date: Thu, 27 May 2010 19:53:48 +0200
Message-ID: <1274982828-13082-1-git-send-email-eric@eukrea.com>
References: <536177.31761.qm@web51001.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: s.hauer@pengutronix.de, sshtylyov@mvista.com,
	linux-arm-kernel@lists.infradead.org, fabioestevam@yahoo.com,
	netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpfb2-g21.free.fr ([212.27.42.10]:55439 "EHLO
	smtpfb2-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753843Ab0E0Ryh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 13:54:37 -0400
Received: from smtp2-g21.free.fr (smtp2-g21.free.fr [212.27.42.2])
	by smtpfb2-g21.free.fr (Postfix) with ESMTP id C8CC1D1AD62
	for <netdev@vger.kernel.org>; Thu, 27 May 2010 19:54:32 +0200 (CEST)
In-Reply-To: <536177.31761.qm@web51001.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* with this patch, if the connection if active before suspend, it
will be active after resume.
* before this patch, it was necessary to close the interface and
reopen it to recover the connection.

Signed-off-by: Eric B=C3=A9nard <eric@eukrea.com>
Cc: s.hauer@pengutronix.de
Cc: sshtylyov@mvista.com
Cc: linux-arm-kernel@lists.infradead.org
Cc: fabioestevam@yahoo.com
Cc: netdev@vger.kernel.org
---
 drivers/net/fec.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 9b4e8f7..1521972 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1974,10 +1974,11 @@ fec_suspend(struct platform_device *dev, pm_mes=
sage_t state)
 	struct fec_enet_private *fep;
=20
 	if (ndev) {
-		fep =3D netdev_priv(ndev);
 		if (netif_running(ndev)) {
+			fep =3D netdev_priv(ndev);
+			netif_stop_queue(ndev);
 			netif_device_detach(ndev);
-			fec_stop(ndev);
+			clk_disable(fep->clk);
 		}
 	}
 	return 0;
@@ -1987,11 +1988,14 @@ static int
 fec_resume(struct platform_device *dev)
 {
 	struct net_device *ndev =3D platform_get_drvdata(dev);
+	struct fec_enet_private *fep;
=20
 	if (ndev) {
 		if (netif_running(ndev)) {
-			fec_enet_init(ndev, 0);
+			fep =3D netdev_priv(ndev);
+			clk_enable(fep->clk);
 			netif_device_attach(ndev);
+			netif_start_queue(ndev);
 		}
 	}
 	return 0;
--=20
1.6.3.3

