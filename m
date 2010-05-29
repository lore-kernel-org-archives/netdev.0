From: =?utf-8?q?Eric=20B=C3=A9nard?= <eric@eukrea.com>
Subject: [PATCH v2] net/fec: fix pm to survive to suspend/resume
Date: Sat, 29 May 2010 22:04:50 +0200
Message-ID: <1275163490-13027-1-git-send-email-eric@eukrea.com>
References: <20100529.001534.57459102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: s.hauer@pengutronix.de, sshtylyov@mvista.com,
	linux-arm-kernel@lists.infradead.org, fabioestevam@yahoo.com,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:51584 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755324Ab0E2UFA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 May 2010 16:05:00 -0400
In-Reply-To: <20100529.001534.57459102.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* in the actual driver, calling fec_stop and fec_enet_init doesn't
allow to have a working network interface at resume (where a
ifconfig down and up is required to recover the interface)
* by using fec_enet_close and fec_enet_open, this patch solves this
problem and handle the case where the link changed between suspend
and resume
* this patch also disable clock at suspend and reenable it at resume

Signed-off-by: Eric B=C3=A9nard <eric@eukrea.com>
Cc: s.hauer@pengutronix.de
Cc: sshtylyov@mvista.com
Cc: linux-arm-kernel@lists.infradead.org
Cc: fabioestevam@yahoo.com
Cc: davem@davemloft.net
---
 drivers/net/fec.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 9b4e8f7..40ffdb8 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1975,10 +1975,9 @@ fec_suspend(struct platform_device *dev, pm_mess=
age_t state)
=20
 	if (ndev) {
 		fep =3D netdev_priv(ndev);
-		if (netif_running(ndev)) {
-			netif_device_detach(ndev);
-			fec_stop(ndev);
-		}
+		if (netif_running(ndev))
+			fec_enet_close(ndev);
+		clk_disable(fep->clk);
 	}
 	return 0;
 }
@@ -1987,12 +1986,13 @@ static int
 fec_resume(struct platform_device *dev)
 {
 	struct net_device *ndev =3D platform_get_drvdata(dev);
+	struct fec_enet_private *fep;
=20
 	if (ndev) {
-		if (netif_running(ndev)) {
-			fec_enet_init(ndev, 0);
-			netif_device_attach(ndev);
-		}
+		fep =3D netdev_priv(ndev);
+		clk_enable(fep->clk);
+		if (netif_running(ndev))
+			fec_enet_open(ndev);
 	}
 	return 0;
 }
--=20
1.6.3.3

