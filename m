From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 2/2] net: davinci_cpdma: reduce time holding chan->lock in cpdma_chan_submit
Date: Tue, 26 Jul 2016 14:02:25 +0200
Message-ID: <1469534545-14478-3-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1469534545-14478-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-omap@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de
To: Mugunthan V N <mugunthanvnm@ti.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:34245 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754598AbcGZMCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 08:02:45 -0400
In-Reply-To: <1469534545-14478-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocating and preparing a dma descriptor doesn't need to happen under
the channel's lock. So do this before taking the channel's lock. The on=
ly
down side is that the dma descriptor might be allocated even though the
channel is about to be stopped. This is unlikely though.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/ethernet/ti/davinci_cpdma.c | 38 +++++++++++++++++--------=
--------
 1 file changed, 20 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethe=
rnet/ti/davinci_cpdma.c
index 5ffa04a306c6..ba3462707ae3 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -542,24 +542,10 @@ int cpdma_chan_submit(struct cpdma_chan *chan, vo=
id *token, void *data,
 	u32				mode;
 	int				ret =3D 0;
=20
-	spin_lock_irqsave(&chan->lock, flags);
-
-	if (chan->state =3D=3D CPDMA_STATE_TEARDOWN) {
-		ret =3D -EINVAL;
-		goto unlock_ret;
-	}
-
-	if (chan->count >=3D chan->desc_num)	{
-		chan->stats.desc_alloc_fail++;
-		ret =3D -ENOMEM;
-		goto unlock_ret;
-	}
-
 	desc =3D cpdma_desc_alloc(ctlr->pool);
 	if (!desc) {
 		chan->stats.desc_alloc_fail++;
-		ret =3D -ENOMEM;
-		goto unlock_ret;
+		return -ENOMEM;
 	}
=20
 	if (len < ctlr->params.min_packet_size) {
@@ -571,8 +557,7 @@ int cpdma_chan_submit(struct cpdma_chan *chan, void=
 *token, void *data,
 	ret =3D dma_mapping_error(ctlr->dev, buffer);
 	if (ret) {
 		cpdma_desc_free(ctlr->pool, desc, 1);
-		ret =3D -EINVAL;
-		goto unlock_ret;
+		return -EINVAL;
 	}
=20
 	mode =3D CPDMA_DESC_OWNER | CPDMA_DESC_SOP | CPDMA_DESC_EOP;
@@ -586,6 +571,19 @@ int cpdma_chan_submit(struct cpdma_chan *chan, voi=
d *token, void *data,
 	desc_write(desc, sw_buffer, buffer);
 	desc_write(desc, sw_len,    len);
=20
+	spin_lock_irqsave(&chan->lock, flags);
+
+	if (chan->state =3D=3D CPDMA_STATE_TEARDOWN) {
+		ret =3D -EINVAL;
+		goto unlock_free;
+	}
+
+	if (chan->count >=3D chan->desc_num)	{
+		chan->stats.desc_alloc_fail++;
+		ret =3D -ENOMEM;
+		goto unlock_free;
+	}
+
 	__cpdma_chan_submit(chan, desc);
=20
 	if (chan->state =3D=3D CPDMA_STATE_ACTIVE && chan->rxfree)
@@ -593,8 +591,12 @@ int cpdma_chan_submit(struct cpdma_chan *chan, voi=
d *token, void *data,
=20
 	chan->count++;
=20
-unlock_ret:
 	spin_unlock_irqrestore(&chan->lock, flags);
+	return 0;
+
+unlock_free:
+	spin_unlock_irqrestore(&chan->lock, flags);
+	cpdma_desc_free(ctlr->pool, desc, 1);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(cpdma_chan_submit);
--=20
2.8.1
