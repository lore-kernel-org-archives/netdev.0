From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH 4/8] caif-hsi: Making read and writes asynchronous.
Date: Thu, 13 Oct 2011 23:29:25 +0200
Message-ID: <1318541369-8141-5-git-send-email-sjur.brandeland@stericsson.com>
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
	with ESMTP id S1753941Ab1JMW37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 18:29:59 -0400
Received: from ignis-smin.broadpark.no ([80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LT0001EAX1N7670@eterpe-smout.broadpark.no> for
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

Some platforms do not allow to put HSI block into low-power
mode when FIFO is not empty. The patch flushes (by reading)
=46IFO at wake down sequence. Asynchronous read and write is
implemented for that. As a side effect this will also greatly
improve performance.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_hsi.c |  263 +++++++++++++++++++++--------------=
--------
 include/net/caif/caif_hsi.h |   29 ++++--
 2 files changed, 147 insertions(+), 145 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 82c4d6c..478b025 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -145,7 +145,7 @@ static int cfhsi_flush_fifo(struct cfhsi *cfhsi)
 		}
=20
 		ret =3D 5 * HZ;
-		wait_event_interruptible_timeout(cfhsi->flush_fifo_wait,
+		ret =3D wait_event_interruptible_timeout(cfhsi->flush_fifo_wait,
 			 !test_bit(CFHSI_FLUSH_FIFO, &cfhsi->bits), ret);
=20
 		if (ret < 0) {
@@ -272,16 +272,13 @@ static int cfhsi_tx_frm(struct cfhsi_desc *desc, =
struct cfhsi *cfhsi)
 	return CFHSI_DESC_SZ + pld_len;
 }
=20
-static void cfhsi_tx_done_work(struct work_struct *work)
+static void cfhsi_tx_done(struct cfhsi *cfhsi)
 {
-	struct cfhsi *cfhsi =3D NULL;
 	struct cfhsi_desc *desc =3D NULL;
 	int len =3D 0;
 	int res;
=20
-	cfhsi =3D container_of(work, struct cfhsi, tx_done_work);
-	dev_dbg(&cfhsi->ndev->dev, "%s.\n",
-		__func__);
+	dev_dbg(&cfhsi->ndev->dev, "%s.\n", __func__);
=20
 	if (test_bit(CFHSI_SHUTDOWN, &cfhsi->bits))
 		return;
@@ -343,11 +340,11 @@ static void cfhsi_tx_done_cb(struct cfhsi_drv *dr=
v)
=20
 	if (test_bit(CFHSI_SHUTDOWN, &cfhsi->bits))
 		return;
-
-	queue_work(cfhsi->wq, &cfhsi->tx_done_work);
+	cfhsi_tx_done(cfhsi);
 }
=20
-static int cfhsi_rx_desc(struct cfhsi_desc *desc, struct cfhsi *cfhsi)
+static int cfhsi_rx_desc(struct cfhsi_desc *desc, struct cfhsi *cfhsi,
+				bool *dump)
 {
 	int xfer_sz =3D 0;
 	int nfrms =3D 0;
@@ -358,6 +355,7 @@ static int cfhsi_rx_desc(struct cfhsi_desc *desc, s=
truct cfhsi *cfhsi)
 			(desc->offset > CFHSI_MAX_EMB_FRM_SZ)) {
 		dev_err(&cfhsi->ndev->dev, "%s: Invalid descriptor.\n",
 			__func__);
+		*dump =3D true;
 		return 0;
 	}
=20
@@ -365,7 +363,7 @@ static int cfhsi_rx_desc(struct cfhsi_desc *desc, s=
truct cfhsi *cfhsi)
 	if (desc->offset) {
 		struct sk_buff *skb;
 		u8 *dst =3D NULL;
-		int len =3D 0, retries =3D 0;
+		int len =3D 0;
 		pfrm =3D ((u8 *)desc) + desc->offset;
=20
 		/* Remove offset padding. */
@@ -378,24 +376,11 @@ static int cfhsi_rx_desc(struct cfhsi_desc *desc,=
 struct cfhsi *cfhsi)
=20
=20
 		/* Allocate SKB (OK even in IRQ context). */
-		skb =3D alloc_skb(len + 1, GFP_KERNEL);
-		while (!skb) {
-			retries++;
-			schedule_timeout(1);
-			skb =3D alloc_skb(len + 1, GFP_KERNEL);
-			if (skb) {
-				printk(KERN_WARNING "%s: slept for %u "
-						"before getting memory\n",
-						__func__, retries);
-				break;
-			}
-			if (retries > HZ) {
-				printk(KERN_ERR "%s: slept for 1HZ and "
-						"did not get memory\n",
-						__func__);
-				cfhsi->ndev->stats.rx_dropped++;
-				goto drop_frame;
-			}
+		skb =3D alloc_skb(len + 1, GFP_ATOMIC);
+		if (!skb) {
+			dev_err(&cfhsi->ndev->dev, "%s: Out of memory !\n",
+				__func__);
+			return -ENOMEM;
 		}
 		caif_assert(skb !=3D NULL);
=20
@@ -421,7 +406,6 @@ static int cfhsi_rx_desc(struct cfhsi_desc *desc, s=
truct cfhsi *cfhsi)
 		cfhsi->ndev->stats.rx_bytes +=3D len;
 	}
=20
-drop_frame:
 	/* Calculate transfer length. */
 	plen =3D desc->cffrm_len;
 	while (nfrms < CFHSI_MAX_PKTS && *plen) {
@@ -439,12 +423,13 @@ drop_frame:
 				"%s: Invalid payload len: %d, ignored.\n",
 			__func__, xfer_sz);
 		xfer_sz =3D 0;
+		*dump =3D true;
 	}
-
 	return xfer_sz;
 }
=20
-static int cfhsi_rx_pld(struct cfhsi_desc *desc, struct cfhsi *cfhsi)
+static int cfhsi_rx_pld(struct cfhsi_desc *desc, struct cfhsi *cfhsi,
+				bool *dump)
 {
 	int rx_sz =3D 0;
 	int nfrms =3D 0;
@@ -456,21 +441,33 @@ static int cfhsi_rx_pld(struct cfhsi_desc *desc, =
struct cfhsi *cfhsi)
 			(desc->offset > CFHSI_MAX_EMB_FRM_SZ))) {
 		dev_err(&cfhsi->ndev->dev, "%s: Invalid descriptor.\n",
 			__func__);
+		*dump =3D true;
 		return -EINVAL;
 	}
=20
 	/* Set frame pointer to start of payload. */
 	pfrm =3D desc->emb_frm + CFHSI_MAX_EMB_FRM_SZ;
 	plen =3D desc->cffrm_len;
+
+	/* Skip already processed frames. */
+	while (nfrms < cfhsi->rx_state.nfrms) {
+		pfrm +=3D *plen;
+		rx_sz +=3D *plen;
+		plen++;
+		nfrms++;
+	}
+
+	/* Parse payload. */
 	while (nfrms < CFHSI_MAX_PKTS && *plen) {
 		struct sk_buff *skb;
 		u8 *dst =3D NULL;
 		u8 *pcffrm =3D NULL;
-		int len =3D 0, retries =3D 0;
+		int len =3D 0;
=20
 		if (WARN_ON(desc->cffrm_len[nfrms] > CFHSI_MAX_PAYLOAD_SZ)) {
 			dev_err(&cfhsi->ndev->dev, "%s: Invalid payload.\n",
 				__func__);
+			*dump =3D true;
 			return -EINVAL;
 		}
=20
@@ -483,24 +480,12 @@ static int cfhsi_rx_pld(struct cfhsi_desc *desc, =
struct cfhsi *cfhsi)
 		len +=3D 2;	/* Add FCS fields. */
=20
 		/* Allocate SKB (OK even in IRQ context). */
-		skb =3D alloc_skb(len + 1, GFP_KERNEL);
-		while (!skb) {
-			retries++;
-			schedule_timeout(1);
-			skb =3D alloc_skb(len + 1, GFP_KERNEL);
-			if (skb) {
-				printk(KERN_WARNING "%s: slept for %u "
-						"before getting memory\n",
-						__func__, retries);
-				break;
-			}
-			if (retries > HZ) {
-				printk(KERN_ERR "%s: slept for 1HZ "
-						"and did not get memory\n",
-						__func__);
-				cfhsi->ndev->stats.rx_dropped++;
-				goto drop_frame;
-			}
+		skb =3D alloc_skb(len + 1, GFP_ATOMIC);
+		if (!skb) {
+			dev_err(&cfhsi->ndev->dev, "%s: Out of memory !\n",
+				__func__);
+			cfhsi->rx_state.nfrms =3D nfrms;
+			return -ENOMEM;
 		}
 		caif_assert(skb !=3D NULL);
=20
@@ -524,7 +509,6 @@ static int cfhsi_rx_pld(struct cfhsi_desc *desc, st=
ruct cfhsi *cfhsi)
 		cfhsi->ndev->stats.rx_packets++;
 		cfhsi->ndev->stats.rx_bytes +=3D len;
=20
-drop_frame:
 		pfrm +=3D *plen;
 		rx_sz +=3D *plen;
 		plen++;
@@ -534,18 +518,16 @@ drop_frame:
 	return rx_sz;
 }
=20
-static void cfhsi_rx_done_work(struct work_struct *work)
+static void cfhsi_rx_done(struct cfhsi *cfhsi)
 {
 	int res;
 	int desc_pld_len =3D 0;
-	struct cfhsi *cfhsi =3D NULL;
 	struct cfhsi_desc *desc =3D NULL;
+	bool dump =3D false;
=20
-	cfhsi =3D container_of(work, struct cfhsi, rx_done_work);
 	desc =3D (struct cfhsi_desc *)cfhsi->rx_buf;
=20
-	dev_dbg(&cfhsi->ndev->dev, "%s: Kick timer if pending.\n",
-		__func__);
+	dev_dbg(&cfhsi->ndev->dev, "%s\n", __func__);
=20
 	if (test_bit(CFHSI_SHUTDOWN, &cfhsi->bits))
 		return;
@@ -555,21 +537,33 @@ static void cfhsi_rx_done_work(struct work_struct=
 *work)
 	mod_timer_pending(&cfhsi->timer, jiffies + CFHSI_INACTIVITY_TOUT);
 	spin_unlock_bh(&cfhsi->lock);
=20
-	if (cfhsi->rx_state =3D=3D CFHSI_RX_STATE_DESC) {
-		desc_pld_len =3D cfhsi_rx_desc(desc, cfhsi);
+	if (cfhsi->rx_state.state =3D=3D CFHSI_RX_STATE_DESC) {
+		desc_pld_len =3D cfhsi_rx_desc(desc, cfhsi, &dump);
+		if (desc_pld_len =3D=3D -ENOMEM)
+			goto restart;
 	} else {
 		int pld_len;
=20
-		pld_len =3D cfhsi_rx_pld(desc, cfhsi);
+		if (!cfhsi->rx_state.piggy_desc) {
+			pld_len =3D cfhsi_rx_pld(desc, cfhsi, &dump);
+			if (pld_len =3D=3D -ENOMEM)
+				goto restart;
+			cfhsi->rx_state.pld_len =3D pld_len;
+		} else {
+			pld_len =3D cfhsi->rx_state.pld_len;
+		}
=20
 		if ((pld_len > 0) && (desc->header & CFHSI_PIGGY_DESC)) {
 			struct cfhsi_desc *piggy_desc;
 			piggy_desc =3D (struct cfhsi_desc *)
 				(desc->emb_frm + CFHSI_MAX_EMB_FRM_SZ +
 						pld_len);
+			cfhsi->rx_state.piggy_desc =3D true;
=20
 			/* Extract piggy-backed descriptor. */
-			desc_pld_len =3D cfhsi_rx_desc(piggy_desc, cfhsi);
+			desc_pld_len =3D cfhsi_rx_desc(piggy_desc, cfhsi, &dump);
+			if (desc_pld_len =3D=3D -ENOMEM)
+				goto restart;
=20
 			/*
 			 * Copy needed information from the piggy-backed
@@ -580,16 +574,24 @@ static void cfhsi_rx_done_work(struct work_struct=
 *work)
 		}
 	}
=20
+	if (unlikely(dump)) {
+		size_t rx_offset =3D cfhsi->rx_ptr - cfhsi->rx_buf;
+		dev_err(&cfhsi->ndev->dev, "%s: RX offset: %u.\n",
+			__func__, (unsigned) rx_offset);
+		print_hex_dump_bytes("--> ", DUMP_PREFIX_NONE,
+				cfhsi->rx_buf, cfhsi->rx_len + rx_offset);
+	}
+
+	memset(&cfhsi->rx_state, 0, sizeof(cfhsi->rx_state));
 	if (desc_pld_len) {
-		cfhsi->rx_state =3D CFHSI_RX_STATE_PAYLOAD;
+		cfhsi->rx_state.state =3D CFHSI_RX_STATE_PAYLOAD;
 		cfhsi->rx_ptr =3D cfhsi->rx_buf + CFHSI_DESC_SZ;
 		cfhsi->rx_len =3D desc_pld_len;
 	} else {
-		cfhsi->rx_state =3D CFHSI_RX_STATE_DESC;
+		cfhsi->rx_state.state =3D CFHSI_RX_STATE_DESC;
 		cfhsi->rx_ptr =3D cfhsi->rx_buf;
 		cfhsi->rx_len =3D CFHSI_DESC_SZ;
 	}
-	clear_bit(CFHSI_PENDING_RX, &cfhsi->bits);
=20
 	if (test_bit(CFHSI_AWAKE, &cfhsi->bits)) {
 		/* Set up new transfer. */
@@ -604,6 +606,26 @@ static void cfhsi_rx_done_work(struct work_struct =
*work)
 			cfhsi->ndev->stats.rx_dropped++;
 		}
 	}
+	return;
+
+restart:
+	if (++cfhsi->rx_state.retries > CFHSI_MAX_RX_RETRIES) {
+		dev_err(&cfhsi->ndev->dev, "%s: No memory available "
+			"in %d iterations.\n",
+			__func__, CFHSI_MAX_RX_RETRIES);
+		BUG();
+	}
+	mod_timer(&cfhsi->rx_slowpath_timer, jiffies + 1);
+}
+
+static void cfhsi_rx_slowpath(unsigned long arg)
+{
+	struct cfhsi *cfhsi =3D (struct cfhsi *)arg;
+
+	dev_dbg(&cfhsi->ndev->dev, "%s.\n",
+		__func__);
+
+	cfhsi_rx_done(cfhsi);
 }
=20
 static void cfhsi_rx_done_cb(struct cfhsi_drv *drv)
@@ -617,12 +639,10 @@ static void cfhsi_rx_done_cb(struct cfhsi_drv *dr=
v)
 	if (test_bit(CFHSI_SHUTDOWN, &cfhsi->bits))
 		return;
=20
-	set_bit(CFHSI_PENDING_RX, &cfhsi->bits);
-
 	if (test_and_clear_bit(CFHSI_FLUSH_FIFO, &cfhsi->bits))
 		wake_up_interruptible(&cfhsi->flush_fifo_wait);
 	else
-		queue_work(cfhsi->wq, &cfhsi->rx_done_work);
+		cfhsi_rx_done(cfhsi);
 }
=20
 static void cfhsi_wake_up(struct work_struct *work)
@@ -651,9 +671,9 @@ static void cfhsi_wake_up(struct work_struct *work)
 		__func__);
=20
 	/* Wait for acknowledge. */
-	ret =3D CFHSI_WAKEUP_TOUT;
-	wait_event_interruptible_timeout(cfhsi->wake_up_wait,
-					test_bit(CFHSI_WAKE_UP_ACK,
+	ret =3D CFHSI_WAKE_TOUT;
+	ret =3D wait_event_interruptible_timeout(cfhsi->wake_up_wait,
+					test_and_clear_bit(CFHSI_WAKE_UP_ACK,
 							&cfhsi->bits), ret);
 	if (unlikely(ret < 0)) {
 		/* Interrupted by signal. */
@@ -678,16 +698,11 @@ static void cfhsi_wake_up(struct work_struct *wor=
k)
 	clear_bit(CFHSI_WAKE_UP, &cfhsi->bits);
=20
 	/* Resume read operation. */
-	if (!test_bit(CFHSI_PENDING_RX, &cfhsi->bits)) {
-		dev_dbg(&cfhsi->ndev->dev, "%s: Start RX.\n",
-			__func__);
-		res =3D cfhsi->dev->cfhsi_rx(cfhsi->rx_ptr,
-				cfhsi->rx_len, cfhsi->dev);
-		if (WARN_ON(res < 0)) {
-			dev_err(&cfhsi->ndev->dev, "%s: RX error %d.\n",
-				__func__, res);
-		}
-	}
+	dev_dbg(&cfhsi->ndev->dev, "%s: Start RX.\n", __func__);
+	res =3D cfhsi->dev->cfhsi_rx(cfhsi->rx_ptr, cfhsi->rx_len, cfhsi->dev=
);
+
+	if (WARN_ON(res < 0))
+		dev_err(&cfhsi->ndev->dev, "%s: RX err %d.\n", __func__, res);
=20
 	/* Clear power up acknowledment. */
 	clear_bit(CFHSI_WAKE_UP_ACK, &cfhsi->bits);
@@ -726,50 +741,29 @@ static void cfhsi_wake_up(struct work_struct *wor=
k)
 				"%s: Failed to create HSI frame: %d.\n",
 				__func__, len);
 	}
-
 }
=20
 static void cfhsi_wake_down(struct work_struct *work)
 {
 	long ret;
 	struct cfhsi *cfhsi =3D NULL;
-	size_t fifo_occupancy;
+	size_t fifo_occupancy =3D 0;
+	int retry =3D CFHSI_WAKE_TOUT;
=20
 	cfhsi =3D container_of(work, struct cfhsi, wake_down_work);
-	dev_dbg(&cfhsi->ndev->dev, "%s.\n",
-		__func__);
+	dev_dbg(&cfhsi->ndev->dev, "%s.\n", __func__);
=20
 	if (test_bit(CFHSI_SHUTDOWN, &cfhsi->bits))
 		return;
=20
-	/* Check if there is something in FIFO. */
-	if (WARN_ON(cfhsi->dev->cfhsi_fifo_occupancy(cfhsi->dev,
-							&fifo_occupancy)))
-		fifo_occupancy =3D 0;
-
-	if (fifo_occupancy) {
-		dev_dbg(&cfhsi->ndev->dev,
-				"%s: %u words in RX FIFO, restart timer.\n",
-				__func__, (unsigned) fifo_occupancy);
-		spin_lock_bh(&cfhsi->lock);
-		mod_timer(&cfhsi->timer,
-				jiffies + CFHSI_INACTIVITY_TOUT);
-		spin_unlock_bh(&cfhsi->lock);
-		return;
-	}
-
-	/* Cancel pending RX requests */
-	cfhsi->dev->cfhsi_rx_cancel(cfhsi->dev);
-
 	/* Deactivate wake line. */
 	cfhsi->dev->cfhsi_wake_down(cfhsi->dev);
=20
 	/* Wait for acknowledge. */
-	ret =3D CFHSI_WAKEUP_TOUT;
+	ret =3D CFHSI_WAKE_TOUT;
 	ret =3D wait_event_interruptible_timeout(cfhsi->wake_down_wait,
-					test_bit(CFHSI_WAKE_DOWN_ACK,
-							&cfhsi->bits),
-					ret);
+					test_and_clear_bit(CFHSI_WAKE_DOWN_ACK,
+							&cfhsi->bits), ret);
 	if (ret < 0) {
 		/* Interrupted by signal. */
 		dev_info(&cfhsi->ndev->dev, "%s: Signalled: %ld.\n",
@@ -777,28 +771,31 @@ static void cfhsi_wake_down(struct work_struct *w=
ork)
 		return;
 	} else if (!ret) {
 		/* Timeout */
-		dev_err(&cfhsi->ndev->dev, "%s: Timeout.\n",
-			__func__);
+		dev_err(&cfhsi->ndev->dev, "%s: Timeout.\n", __func__);
 	}
=20
-	/* Clear power down acknowledment. */
-	clear_bit(CFHSI_WAKE_DOWN_ACK, &cfhsi->bits);
+	/* Check FIFO occupancy. */
+	while (retry) {
+		WARN_ON(cfhsi->dev->cfhsi_fifo_occupancy(cfhsi->dev,
+							&fifo_occupancy));
+
+		if (!fifo_occupancy)
+			break;
+
+		set_current_state(TASK_INTERRUPTIBLE);
+		schedule_timeout(1);
+		retry--;
+	}
+
+	if (!retry)
+		dev_err(&cfhsi->ndev->dev, "%s: FIFO Timeout.\n", __func__);
+
+	/* Clear AWAKE condition. */
 	clear_bit(CFHSI_AWAKE, &cfhsi->bits);
=20
-	/* Check if there is something in FIFO. */
-	if (WARN_ON(cfhsi->dev->cfhsi_fifo_occupancy(cfhsi->dev,
-							&fifo_occupancy)))
-		fifo_occupancy =3D 0;
+	/* Cancel pending RX requests. */
+	cfhsi->dev->cfhsi_rx_cancel(cfhsi->dev);
=20
-	if (fifo_occupancy) {
-		dev_dbg(&cfhsi->ndev->dev,
-				"%s: %u words in RX FIFO, wakeup forced.\n",
-				__func__, (unsigned) fifo_occupancy);
-		if (!test_and_set_bit(CFHSI_WAKE_UP, &cfhsi->bits))
-			queue_work(cfhsi->wq, &cfhsi->wake_up_work);
-	} else
-		dev_dbg(&cfhsi->ndev->dev, "%s: Done.\n",
-			__func__);
 }
=20
 static void cfhsi_wake_up_cb(struct cfhsi_drv *drv)
@@ -874,11 +871,7 @@ static int cfhsi_xmit(struct sk_buff *skb, struct =
net_device *dev)
 	}
=20
 	/* Delete inactivity timer if started. */
-#ifdef CONFIG_SMP
 	timer_active =3D del_timer_sync(&cfhsi->timer);
-#else
-	timer_active =3D del_timer(&cfhsi->timer);
-#endif /* CONFIG_SMP */
=20
 	spin_unlock_bh(&cfhsi->lock);
=20
@@ -962,7 +955,7 @@ int cfhsi_probe(struct platform_device *pdev)
=20
 	/* Initialize state vaiables. */
 	cfhsi->tx_state =3D CFHSI_TX_STATE_IDLE;
-	cfhsi->rx_state =3D CFHSI_RX_STATE_DESC;
+	cfhsi->rx_state.state =3D CFHSI_RX_STATE_DESC;
=20
 	/* Set flow info */
 	cfhsi->flow_off_sent =3D 0;
@@ -1012,15 +1005,12 @@ int cfhsi_probe(struct platform_device *pdev)
 	/* Initialize the work queues. */
 	INIT_WORK(&cfhsi->wake_up_work, cfhsi_wake_up);
 	INIT_WORK(&cfhsi->wake_down_work, cfhsi_wake_down);
-	INIT_WORK(&cfhsi->rx_done_work, cfhsi_rx_done_work);
-	INIT_WORK(&cfhsi->tx_done_work, cfhsi_tx_done_work);
=20
 	/* Clear all bit fields. */
 	clear_bit(CFHSI_WAKE_UP_ACK, &cfhsi->bits);
 	clear_bit(CFHSI_WAKE_DOWN_ACK, &cfhsi->bits);
 	clear_bit(CFHSI_WAKE_UP, &cfhsi->bits);
 	clear_bit(CFHSI_AWAKE, &cfhsi->bits);
-	clear_bit(CFHSI_PENDING_RX, &cfhsi->bits);
=20
 	/* Create work thread. */
 	cfhsi->wq =3D create_singlethread_workqueue(pdev->name);
@@ -1040,6 +1030,10 @@ int cfhsi_probe(struct platform_device *pdev)
 	init_timer(&cfhsi->timer);
 	cfhsi->timer.data =3D (unsigned long)cfhsi;
 	cfhsi->timer.function =3D cfhsi_inactivity_tout;
+	/* Setup the slowpath RX timer. */
+	init_timer(&cfhsi->rx_slowpath_timer);
+	cfhsi->rx_slowpath_timer.data =3D (unsigned long)cfhsi;
+	cfhsi->rx_slowpath_timer.function =3D cfhsi_rx_slowpath;
=20
 	/* Add CAIF HSI device to list. */
 	spin_lock(&cfhsi_list_lock);
@@ -1110,12 +1104,9 @@ static void cfhsi_shutdown(struct cfhsi *cfhsi, =
bool remove_platform_dev)
 	/* Flush workqueue */
 	flush_workqueue(cfhsi->wq);
=20
-	/* Delete timer if pending */
-#ifdef CONFIG_SMP
+	/* Delete timers if pending */
 	del_timer_sync(&cfhsi->timer);
-#else
-	del_timer(&cfhsi->timer);
-#endif /* CONFIG_SMP */
+	del_timer_sync(&cfhsi->rx_slowpath_timer);
=20
 	/* Cancel pending RX request (if any) */
 	cfhsi->dev->cfhsi_rx_cancel(cfhsi->dev);
diff --git a/include/net/caif/caif_hsi.h b/include/net/caif/caif_hsi.h
index c5dedd8..17dff45 100644
--- a/include/net/caif/caif_hsi.h
+++ b/include/net/caif/caif_hsi.h
@@ -75,18 +75,21 @@ struct cfhsi_desc {
 #define CFHSI_WAKE_UP_ACK			1
 #define CFHSI_WAKE_DOWN_ACK			2
 #define CFHSI_AWAKE				3
-#define CFHSI_PENDING_RX			4
-#define CFHSI_SHUTDOWN				6
-#define CFHSI_FLUSH_FIFO			7
+#define CFHSI_WAKELOCK_HELD			4
+#define CFHSI_SHUTDOWN				5
+#define CFHSI_FLUSH_FIFO			6
=20
 #ifndef CFHSI_INACTIVITY_TOUT
 #define CFHSI_INACTIVITY_TOUT			(1 * HZ)
 #endif /* CFHSI_INACTIVITY_TOUT */
=20
-#ifndef CFHSI_WAKEUP_TOUT
-#define CFHSI_WAKEUP_TOUT			(3 * HZ)
-#endif /* CFHSI_WAKEUP_TOUT */
+#ifndef CFHSI_WAKE_TOUT
+#define CFHSI_WAKE_TOUT			(3 * HZ)
+#endif /* CFHSI_WAKE_TOUT */
=20
+#ifndef CFHSI_MAX_RX_RETRIES
+#define CFHSI_MAX_RX_RETRIES		(10 * HZ)
+#endif
=20
 /* Structure implemented by the CAIF HSI driver. */
 struct cfhsi_drv {
@@ -109,6 +112,15 @@ struct cfhsi_dev {
 	struct cfhsi_drv *drv;
 };
=20
+/* Structure holds status of received CAIF frames processing */
+struct cfhsi_rx_state {
+	int state;
+	int nfrms;
+	int pld_len;
+	int retries;
+	bool piggy_desc;
+};
+
 /* Structure implemented by CAIF HSI drivers. */
 struct cfhsi {
 	struct caif_dev_common cfdev;
@@ -118,7 +130,7 @@ struct cfhsi {
 	struct cfhsi_drv drv;
 	struct cfhsi_dev *dev;
 	int tx_state;
-	int rx_state;
+	struct cfhsi_rx_state rx_state;
 	int rx_len;
 	u8 *rx_ptr;
 	u8 *tx_buf;
@@ -130,13 +142,12 @@ struct cfhsi {
 	struct list_head list;
 	struct work_struct wake_up_work;
 	struct work_struct wake_down_work;
-	struct work_struct rx_done_work;
-	struct work_struct tx_done_work;
 	struct workqueue_struct *wq;
 	wait_queue_head_t wake_up_wait;
 	wait_queue_head_t wake_down_wait;
 	wait_queue_head_t flush_fifo_wait;
 	struct timer_list timer;
+	struct timer_list rx_slowpath_timer;
 	unsigned long bits;
 };
=20
--=20
1.7.0.4
