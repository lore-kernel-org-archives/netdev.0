From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 1/2] net: davinci_cpdma: reduce time holding ctlr->lock in cpdma_control_set
Date: Tue, 26 Jul 2016 14:02:24 +0200
Message-ID: <1469534545-14478-2-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1469534545-14478-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-omap@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de
To: Mugunthan V N <mugunthanvnm@ti.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:42677 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754598AbcGZMCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 08:02:37 -0400
In-Reply-To: <1469534545-14478-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only user of cpdma_control_set (i.e. cpsw_ndo_open) doesn't check
the return code, so it doesn't matter, which error triggers. So the
checks that are independant of the fields protected by ctlr->lock can b=
e
moved out of the critical section.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/ethernet/ti/davinci_cpdma.c | 20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethe=
rnet/ti/davinci_cpdma.c
index 73638f7a55d4..5ffa04a306c6 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -877,23 +877,21 @@ int cpdma_control_set(struct cpdma_ctlr *ctlr, in=
t control, int value)
 	int ret;
 	u32 val;
=20
-	spin_lock_irqsave(&ctlr->lock, flags);
-
-	ret =3D -ENOTSUPP;
 	if (!ctlr->params.has_ext_regs)
-		goto unlock_ret;
+		return -ENOTSUPP;
=20
-	ret =3D -EINVAL;
-	if (ctlr->state !=3D CPDMA_STATE_ACTIVE)
-		goto unlock_ret;
-
-	ret =3D -ENOENT;
 	if (control < 0 || control >=3D ARRAY_SIZE(controls))
-		goto unlock_ret;
+		return -ENOENT;
=20
-	ret =3D -EPERM;
 	if ((info->access & ACCESS_WO) !=3D ACCESS_WO)
+		return -EPERM;
+
+	spin_lock_irqsave(&ctlr->lock, flags);
+
+	if (ctlr->state !=3D CPDMA_STATE_ACTIVE) {
+		ret =3D -EINVAL;
 		goto unlock_ret;
+	}
=20
 	val  =3D dma_reg_read(ctlr, info->reg);
 	val &=3D ~(info->mask << info->shift);
--=20
2.8.1
