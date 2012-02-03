From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH 3/3] caif-hsi: Add RX flip buffer
Date: Fri,  3 Feb 2012 15:36:21 +0100
Message-ID: <1328279781-4745-3-git-send-email-sjur.brandeland@stericsson.com>
References: <1328279781-4745-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:39416 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756726Ab2BCOgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 09:36:40 -0500
Received: by lagu2 with SMTP id u2so1877418lag.19
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2012 06:36:39 -0800 (PST)
In-Reply-To: <1328279781-4745-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement RX flip buffer in the cfhsi_rx_done function,
piggy-backed frames is also supported.
This gives a significant performance gain for CAIF over HSI.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_hsi.c |  145 ++++++++++++++++++++++++++++++-----=
-------
 include/net/caif/caif_hsi.h |    1 +
 2 files changed, 104 insertions(+), 42 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 0a4fc62..c8afd62 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -426,6 +426,35 @@ static int cfhsi_rx_desc(struct cfhsi_desc *desc, =
struct cfhsi *cfhsi)
 	return xfer_sz;
 }
=20
+static int cfhsi_rx_desc_len(struct cfhsi_desc *desc)
+{
+	int xfer_sz =3D 0;
+	int nfrms =3D 0;
+	u16 *plen;
+
+	if ((desc->header & ~CFHSI_PIGGY_DESC) ||
+			(desc->offset > CFHSI_MAX_EMB_FRM_SZ)) {
+
+		pr_err("Invalid descriptor. %x %x\n", desc->header,
+				desc->offset);
+		return -EPROTO;
+	}
+
+	/* Calculate transfer length. */
+	plen =3D desc->cffrm_len;
+	while (nfrms < CFHSI_MAX_PKTS && *plen) {
+		xfer_sz +=3D *plen;
+		plen++;
+		nfrms++;
+	}
+
+	if (xfer_sz % 4) {
+		pr_err("Invalid payload len: %d, ignored.\n", xfer_sz);
+		return -EPROTO;
+	}
+	return xfer_sz;
+}
+
 static int cfhsi_rx_pld(struct cfhsi_desc *desc, struct cfhsi *cfhsi)
 {
 	int rx_sz =3D 0;
@@ -517,8 +546,10 @@ static int cfhsi_rx_pld(struct cfhsi_desc *desc, s=
truct cfhsi *cfhsi)
 static void cfhsi_rx_done(struct cfhsi *cfhsi)
 {
 	int res;
-	int desc_pld_len =3D 0;
+	int desc_pld_len =3D 0, rx_len, rx_state;
 	struct cfhsi_desc *desc =3D NULL;
+	u8 *rx_ptr, *rx_buf;
+	struct cfhsi_desc *piggy_desc =3D NULL;
=20
 	desc =3D (struct cfhsi_desc *)cfhsi->rx_buf;
=20
@@ -534,65 +565,71 @@ static void cfhsi_rx_done(struct cfhsi *cfhsi)
 	spin_unlock_bh(&cfhsi->lock);
=20
 	if (cfhsi->rx_state.state =3D=3D CFHSI_RX_STATE_DESC) {
-		desc_pld_len =3D cfhsi_rx_desc(desc, cfhsi);
-		if (desc_pld_len =3D=3D -ENOMEM)
-			goto restart;
-		if (desc_pld_len =3D=3D -EPROTO)
+		desc_pld_len =3D cfhsi_rx_desc_len(desc);
+
+		if (desc_pld_len < 0)
 			goto out_of_sync;
+
+		rx_buf =3D cfhsi->rx_buf;
+		rx_len =3D desc_pld_len;
+		if (desc_pld_len > 0 && (desc->header & CFHSI_PIGGY_DESC))
+			rx_len +=3D CFHSI_DESC_SZ;
+		if (desc_pld_len =3D=3D 0)
+			rx_buf =3D cfhsi->rx_flip_buf;
 	} else {
-		int pld_len;
+		rx_buf =3D cfhsi->rx_flip_buf;
=20
-		if (!cfhsi->rx_state.piggy_desc) {
-			pld_len =3D cfhsi_rx_pld(desc, cfhsi);
-			if (pld_len =3D=3D -ENOMEM)
-				goto restart;
-			if (pld_len =3D=3D -EPROTO)
-				goto out_of_sync;
-			cfhsi->rx_state.pld_len =3D pld_len;
-		} else {
-			pld_len =3D cfhsi->rx_state.pld_len;
-		}
+		rx_len =3D CFHSI_DESC_SZ;
+		if (cfhsi->rx_state.pld_len > 0 &&
+				(desc->header & CFHSI_PIGGY_DESC)) {
=20
-		if ((pld_len > 0) && (desc->header & CFHSI_PIGGY_DESC)) {
-			struct cfhsi_desc *piggy_desc;
 			piggy_desc =3D (struct cfhsi_desc *)
 				(desc->emb_frm + CFHSI_MAX_EMB_FRM_SZ +
-						pld_len);
+						cfhsi->rx_state.pld_len);
+
 			cfhsi->rx_state.piggy_desc =3D true;
=20
-			/* Extract piggy-backed descriptor. */
-			desc_pld_len =3D cfhsi_rx_desc(piggy_desc, cfhsi);
-			if (desc_pld_len =3D=3D -ENOMEM)
-				goto restart;
+			/* Extract payload len from piggy-backed descriptor. */
+			desc_pld_len =3D cfhsi_rx_desc_len(piggy_desc);
+			if (desc_pld_len < 0)
+				goto out_of_sync;
+
+			if (desc_pld_len > 0)
+				rx_len =3D desc_pld_len;
+
+			if (desc_pld_len > 0 &&
+					(piggy_desc->header & CFHSI_PIGGY_DESC))
+				rx_len +=3D CFHSI_DESC_SZ;
=20
 			/*
 			 * Copy needed information from the piggy-backed
 			 * descriptor to the descriptor in the start.
 			 */
-			memcpy((u8 *)desc, (u8 *)piggy_desc,
+			memcpy(rx_buf, (u8 *)piggy_desc,
 					CFHSI_DESC_SHORT_SZ);
-
+			/* Mark no embedded frame here */
+			piggy_desc->offset =3D 0;
 			if (desc_pld_len =3D=3D -EPROTO)
 				goto out_of_sync;
 		}
 	}
=20
-	memset(&cfhsi->rx_state, 0, sizeof(cfhsi->rx_state));
 	if (desc_pld_len) {
-		cfhsi->rx_state.state =3D CFHSI_RX_STATE_PAYLOAD;
-		cfhsi->rx_ptr =3D cfhsi->rx_buf + CFHSI_DESC_SZ;
-		cfhsi->rx_len =3D desc_pld_len;
+		rx_state =3D CFHSI_RX_STATE_PAYLOAD;
+		rx_ptr =3D rx_buf + CFHSI_DESC_SZ;
 	} else {
-		cfhsi->rx_state.state =3D CFHSI_RX_STATE_DESC;
-		cfhsi->rx_ptr =3D cfhsi->rx_buf;
-		cfhsi->rx_len =3D CFHSI_DESC_SZ;
+		rx_state =3D CFHSI_RX_STATE_DESC;
+		rx_ptr =3D rx_buf;
+		rx_len =3D CFHSI_DESC_SZ;
 	}
=20
+	/* Initiate next read */
 	if (test_bit(CFHSI_AWAKE, &cfhsi->bits)) {
 		/* Set up new transfer. */
 		dev_dbg(&cfhsi->ndev->dev, "%s: Start RX.\n",
-			__func__);
-		res =3D cfhsi->dev->cfhsi_rx(cfhsi->rx_ptr, cfhsi->rx_len,
+				__func__);
+
+		res =3D cfhsi->dev->cfhsi_rx(rx_ptr, rx_len,
 				cfhsi->dev);
 		if (WARN_ON(res < 0)) {
 			dev_err(&cfhsi->ndev->dev, "%s: RX error %d.\n",
@@ -601,16 +638,32 @@ static void cfhsi_rx_done(struct cfhsi *cfhsi)
 			cfhsi->ndev->stats.rx_dropped++;
 		}
 	}
-	return;
=20
-restart:
-	if (++cfhsi->rx_state.retries > CFHSI_MAX_RX_RETRIES) {
-		dev_err(&cfhsi->ndev->dev, "%s: No memory available "
-			"in %d iterations.\n",
-			__func__, CFHSI_MAX_RX_RETRIES);
-		BUG();
+	if (cfhsi->rx_state.state =3D=3D CFHSI_RX_STATE_DESC) {
+		/* Extract payload from descriptor */
+		if (cfhsi_rx_desc(desc, cfhsi) < 0)
+			goto out_of_sync;
+	} else {
+		/* Extract payload */
+		if (cfhsi_rx_pld(desc, cfhsi) < 0)
+			goto out_of_sync;
+		if (piggy_desc) {
+			/* Extract any payload in piggyback descriptor. */
+			if (cfhsi_rx_desc(piggy_desc, cfhsi) < 0)
+				goto out_of_sync;
+		}
 	}
-	mod_timer(&cfhsi->rx_slowpath_timer, jiffies + 1);
+
+	/* Update state info */
+	memset(&cfhsi->rx_state, 0, sizeof(cfhsi->rx_state));
+	cfhsi->rx_state.state =3D rx_state;
+	cfhsi->rx_ptr =3D rx_ptr;
+	cfhsi->rx_len =3D rx_len;
+	cfhsi->rx_state.pld_len =3D desc_pld_len;
+	cfhsi->rx_state.piggy_desc =3D desc->header & CFHSI_PIGGY_DESC;
+
+	if (rx_buf !=3D cfhsi->rx_buf)
+		swap(cfhsi->rx_buf, cfhsi->rx_flip_buf);
 	return;
=20
 out_of_sync:
@@ -1040,6 +1093,12 @@ int cfhsi_probe(struct platform_device *pdev)
 		goto err_alloc_rx;
 	}
=20
+	cfhsi->rx_flip_buf =3D kzalloc(CFHSI_BUF_SZ_RX, GFP_KERNEL);
+	if (!cfhsi->rx_flip_buf) {
+		res =3D -ENODEV;
+		goto err_alloc_rx_flip;
+	}
+
 	/* Pre-calculate inactivity timeout. */
 	if (inactivity_timeout !=3D -1) {
 		cfhsi->inactivity_timeout =3D
@@ -1138,6 +1197,8 @@ int cfhsi_probe(struct platform_device *pdev)
  err_activate:
 	destroy_workqueue(cfhsi->wq);
  err_create_wq:
+	kfree(cfhsi->rx_flip_buf);
+ err_alloc_rx_flip:
 	kfree(cfhsi->rx_buf);
  err_alloc_rx:
 	kfree(cfhsi->tx_buf);
diff --git a/include/net/caif/caif_hsi.h b/include/net/caif/caif_hsi.h
index 8d55251..6db8ecf 100644
--- a/include/net/caif/caif_hsi.h
+++ b/include/net/caif/caif_hsi.h
@@ -138,6 +138,7 @@ struct cfhsi {
 	u8 *rx_ptr;
 	u8 *tx_buf;
 	u8 *rx_buf;
+	u8 *rx_flip_buf;
 	spinlock_t lock;
 	int flow_off_sent;
 	u32 q_low_mark;
--=20
1.7.5.4
