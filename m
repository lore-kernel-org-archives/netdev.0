From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH 7/8] caif-hsi: Added sanity check for length of CAIF frames
Date: Thu, 13 Oct 2011 23:29:28 +0200
Message-ID: <1318541369-8141-8-git-send-email-sjur.brandeland@stericsson.com>
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
	with ESMTP id S1754970Ab1JMWaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 18:30:01 -0400
Received: from ignis-smin.broadpark.no ([80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LT0001EUX1P7670@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Thu, 13 Oct 2011 23:29:49 +0200 (CEST)
Received: from localhost.localdomain ([80.203.143.169])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LT000HN3X1J7Y00@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Thu, 13 Oct 2011 23:29:49 +0200 (CEST)
In-reply-to: <1318541369-8141-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Daniel Martensson <daniel.martensson@stericsson.com>

Added sanity check for length of CAIF frames, and tear down of
CAIF link-layer device upon protocol error.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_hsi.c |   79 ++++++++++++++++++++++++++---------=
-------
 include/net/caif/caif_hsi.h |    6 ++-
 2 files changed, 53 insertions(+), 32 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 1e1f0a3..e9e7cbf 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -18,6 +18,7 @@
 #include <linux/sched.h>
 #include <linux/if_arp.h>
 #include <linux/timer.h>
+#include <linux/rtnetlink.h>
 #include <net/caif/caif_layer.h>
 #include <net/caif/caif_hsi.h>
=20
@@ -348,8 +349,7 @@ static void cfhsi_tx_done_cb(struct cfhsi_drv *drv)
 	cfhsi_tx_done(cfhsi);
 }
=20
-static int cfhsi_rx_desc(struct cfhsi_desc *desc, struct cfhsi *cfhsi,
-				bool *dump)
+static int cfhsi_rx_desc(struct cfhsi_desc *desc, struct cfhsi *cfhsi)
 {
 	int xfer_sz =3D 0;
 	int nfrms =3D 0;
@@ -360,8 +360,7 @@ static int cfhsi_rx_desc(struct cfhsi_desc *desc, s=
truct cfhsi *cfhsi,
 			(desc->offset > CFHSI_MAX_EMB_FRM_SZ)) {
 		dev_err(&cfhsi->ndev->dev, "%s: Invalid descriptor.\n",
 			__func__);
-		*dump =3D true;
-		return 0;
+		return -EPROTO;
 	}
=20
 	/* Check for embedded CAIF frame. */
@@ -379,6 +378,12 @@ static int cfhsi_rx_desc(struct cfhsi_desc *desc, =
struct cfhsi *cfhsi,
 		len |=3D ((*(pfrm+1)) << 8) & 0xFF00;
 		len +=3D 2;	/* Add FCS fields. */
=20
+		/* Sanity check length of CAIF frame. */
+		if (unlikely(len > CFHSI_MAX_CAIF_FRAME_SZ)) {
+			dev_err(&cfhsi->ndev->dev, "%s: Invalid length.\n",
+				__func__);
+			return -EPROTO;
+		}
=20
 		/* Allocate SKB (OK even in IRQ context). */
 		skb =3D alloc_skb(len + 1, GFP_ATOMIC);
@@ -423,18 +428,16 @@ static int cfhsi_rx_desc(struct cfhsi_desc *desc,=
 struct cfhsi *cfhsi,
 	if (desc->header & CFHSI_PIGGY_DESC)
 		xfer_sz +=3D CFHSI_DESC_SZ;
=20
-	if (xfer_sz % 4) {
+	if ((xfer_sz % 4) || (xfer_sz > (CFHSI_BUF_SZ_RX - CFHSI_DESC_SZ))) {
 		dev_err(&cfhsi->ndev->dev,
 				"%s: Invalid payload len: %d, ignored.\n",
 			__func__, xfer_sz);
-		xfer_sz =3D 0;
-		*dump =3D true;
+		return -EPROTO;
 	}
 	return xfer_sz;
 }
=20
-static int cfhsi_rx_pld(struct cfhsi_desc *desc, struct cfhsi *cfhsi,
-				bool *dump)
+static int cfhsi_rx_pld(struct cfhsi_desc *desc, struct cfhsi *cfhsi)
 {
 	int rx_sz =3D 0;
 	int nfrms =3D 0;
@@ -446,8 +449,7 @@ static int cfhsi_rx_pld(struct cfhsi_desc *desc, st=
ruct cfhsi *cfhsi,
 			(desc->offset > CFHSI_MAX_EMB_FRM_SZ))) {
 		dev_err(&cfhsi->ndev->dev, "%s: Invalid descriptor.\n",
 			__func__);
-		*dump =3D true;
-		return -EINVAL;
+		return -EPROTO;
 	}
=20
 	/* Set frame pointer to start of payload. */
@@ -469,13 +471,6 @@ static int cfhsi_rx_pld(struct cfhsi_desc *desc, s=
truct cfhsi *cfhsi,
 		u8 *pcffrm =3D NULL;
 		int len =3D 0;
=20
-		if (WARN_ON(desc->cffrm_len[nfrms] > CFHSI_MAX_PAYLOAD_SZ)) {
-			dev_err(&cfhsi->ndev->dev, "%s: Invalid payload.\n",
-				__func__);
-			*dump =3D true;
-			return -EINVAL;
-		}
-
 		/* CAIF frame starts after head padding. */
 		pcffrm =3D pfrm + *pfrm + 1;
=20
@@ -484,6 +479,13 @@ static int cfhsi_rx_pld(struct cfhsi_desc *desc, s=
truct cfhsi *cfhsi,
 		len |=3D ((*(pcffrm + 1)) << 8) & 0xFF00;
 		len +=3D 2;	/* Add FCS fields. */
=20
+		/* Sanity check length of CAIF frames. */
+		if (unlikely(len > CFHSI_MAX_CAIF_FRAME_SZ)) {
+			dev_err(&cfhsi->ndev->dev, "%s: Invalid length.\n",
+				__func__);
+			return -EPROTO;
+		}
+
 		/* Allocate SKB (OK even in IRQ context). */
 		skb =3D alloc_skb(len + 1, GFP_ATOMIC);
 		if (!skb) {
@@ -528,7 +530,6 @@ static void cfhsi_rx_done(struct cfhsi *cfhsi)
 	int res;
 	int desc_pld_len =3D 0;
 	struct cfhsi_desc *desc =3D NULL;
-	bool dump =3D false;
=20
 	desc =3D (struct cfhsi_desc *)cfhsi->rx_buf;
=20
@@ -544,16 +545,20 @@ static void cfhsi_rx_done(struct cfhsi *cfhsi)
 	spin_unlock_bh(&cfhsi->lock);
=20
 	if (cfhsi->rx_state.state =3D=3D CFHSI_RX_STATE_DESC) {
-		desc_pld_len =3D cfhsi_rx_desc(desc, cfhsi, &dump);
+		desc_pld_len =3D cfhsi_rx_desc(desc, cfhsi);
 		if (desc_pld_len =3D=3D -ENOMEM)
 			goto restart;
+		if (desc_pld_len =3D=3D -EPROTO)
+			goto out_of_sync;
 	} else {
 		int pld_len;
=20
 		if (!cfhsi->rx_state.piggy_desc) {
-			pld_len =3D cfhsi_rx_pld(desc, cfhsi, &dump);
+			pld_len =3D cfhsi_rx_pld(desc, cfhsi);
 			if (pld_len =3D=3D -ENOMEM)
 				goto restart;
+			if (pld_len =3D=3D -EPROTO)
+				goto out_of_sync;
 			cfhsi->rx_state.pld_len =3D pld_len;
 		} else {
 			pld_len =3D cfhsi->rx_state.pld_len;
@@ -567,7 +572,7 @@ static void cfhsi_rx_done(struct cfhsi *cfhsi)
 			cfhsi->rx_state.piggy_desc =3D true;
=20
 			/* Extract piggy-backed descriptor. */
-			desc_pld_len =3D cfhsi_rx_desc(piggy_desc, cfhsi, &dump);
+			desc_pld_len =3D cfhsi_rx_desc(piggy_desc, cfhsi);
 			if (desc_pld_len =3D=3D -ENOMEM)
 				goto restart;
=20
@@ -577,15 +582,10 @@ static void cfhsi_rx_done(struct cfhsi *cfhsi)
 			 */
 			memcpy((u8 *)desc, (u8 *)piggy_desc,
 					CFHSI_DESC_SHORT_SZ);
-		}
-	}
=20
-	if (unlikely(dump)) {
-		size_t rx_offset =3D cfhsi->rx_ptr - cfhsi->rx_buf;
-		dev_err(&cfhsi->ndev->dev, "%s: RX offset: %u.\n",
-			__func__, (unsigned) rx_offset);
-		print_hex_dump_bytes("--> ", DUMP_PREFIX_NONE,
-				cfhsi->rx_buf, cfhsi->rx_len + rx_offset);
+			if (desc_pld_len =3D=3D -EPROTO)
+				goto out_of_sync;
+		}
 	}
=20
 	memset(&cfhsi->rx_state, 0, sizeof(cfhsi->rx_state));
@@ -622,6 +622,13 @@ restart:
 		BUG();
 	}
 	mod_timer(&cfhsi->rx_slowpath_timer, jiffies + 1);
+	return;
+
+out_of_sync:
+	dev_err(&cfhsi->ndev->dev, "%s: Out of sync.\n", __func__);
+	print_hex_dump_bytes("--> ", DUMP_PREFIX_NONE,
+			cfhsi->rx_buf, CFHSI_DESC_SZ);
+	schedule_work(&cfhsi->out_of_sync_work);
 }
=20
 static void cfhsi_rx_slowpath(unsigned long arg)
@@ -804,6 +811,17 @@ static void cfhsi_wake_down(struct work_struct *wo=
rk)
=20
 }
=20
+static void cfhsi_out_of_sync(struct work_struct *work)
+{
+	struct cfhsi *cfhsi =3D NULL;
+
+	cfhsi =3D container_of(work, struct cfhsi, out_of_sync_work);
+
+	rtnl_lock();
+	dev_close(cfhsi->ndev);
+	rtnl_unlock();
+}
+
 static void cfhsi_wake_up_cb(struct cfhsi_drv *drv)
 {
 	struct cfhsi *cfhsi =3D NULL;
@@ -1023,6 +1041,7 @@ int cfhsi_probe(struct platform_device *pdev)
 	/* Initialize the work queues. */
 	INIT_WORK(&cfhsi->wake_up_work, cfhsi_wake_up);
 	INIT_WORK(&cfhsi->wake_down_work, cfhsi_wake_down);
+	INIT_WORK(&cfhsi->out_of_sync_work, cfhsi_out_of_sync);
=20
 	/* Clear all bit fields. */
 	clear_bit(CFHSI_WAKE_UP_ACK, &cfhsi->bits);
diff --git a/include/net/caif/caif_hsi.h b/include/net/caif/caif_hsi.h
index 9b69d15..3356769 100644
--- a/include/net/caif/caif_hsi.h
+++ b/include/net/caif/caif_hsi.h
@@ -52,8 +52,9 @@ struct cfhsi_desc {
 /*
  * Maximum bytes transferred in one transfer.
  */
-/* TODO: 4096 is temporary... */
-#define CFHSI_MAX_PAYLOAD_SZ (CFHSI_MAX_PKTS * 4096)
+#define CFHSI_MAX_CAIF_FRAME_SZ 4096
+
+#define CFHSI_MAX_PAYLOAD_SZ (CFHSI_MAX_PKTS * CFHSI_MAX_CAIF_FRAME_SZ=
)
=20
 /* Size of the complete HSI TX buffer. */
 #define CFHSI_BUF_SZ_TX (CFHSI_DESC_SZ + CFHSI_MAX_PAYLOAD_SZ)
@@ -143,6 +144,7 @@ struct cfhsi {
 	struct list_head list;
 	struct work_struct wake_up_work;
 	struct work_struct wake_down_work;
+	struct work_struct out_of_sync_work;
 	struct workqueue_struct *wq;
 	wait_queue_head_t wake_up_wait;
 	wait_queue_head_t wake_down_wait;
--=20
1.7.0.4
