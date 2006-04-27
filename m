From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 16/32] rt2x00: Make sure TX rings are empty when scanning
Date: Fri, 28 Apr 2006 00:03:08 +0200
Message-ID: <200604280003.08666.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart30983570.FQ9bHq5sx3";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.191]:40300 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751784AbWD0WCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:02:06 -0400
Received: by nproxy.gmail.com with SMTP id x30so1388658nfb
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:02:05 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart30983570.FQ9bHq5sx3
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

Improve the waiting when a skb buffer needs to be send
before the channel switch. This also makes sure no
pending packets are still on the TX ring while making the
channel switch.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-27 21:47:52.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
c	2006-04-27 21:48:21.000000000 +0200
@@ -838,7 +838,6 @@ rt2400pci_txdone(void *data)
 	struct rt2x00_pci	*rt2x00pci =3D (struct rt2x00_pci*)ring->dev;
 	struct net_device	*net_dev =3D pci_get_drvdata(rt2x00pci->pci_dev);
 	struct data_entry	*entry;
=2D	struct skb_cb		*cb;
 	struct txd		*txd;
 	int			tx_status;
 	int			ack;
@@ -851,13 +850,6 @@ rt2400pci_txdone(void *data)
 		|| !rt2x00_get_field32(txd->word0, TXD_W0_VALID))
 			break;
=20
=2D		/*
=2D		 * Check if this frame was send for the scan routine.
=2D		 */
=2D		cb =3D (struct skb_cb*)&entry->skb->cb;
=2D		if (rt2x00pci->scan && cb->scan_complete)
=2D			complete(&rt2x00pci->scan->completion);
=2D
 		ack =3D rt2x00_get_field32(txd->word0, TXD_W0_ACK);
=20
 		/*
@@ -896,6 +888,18 @@ rt2400pci_txdone(void *data)
=20
 		rt2x00_ring_index_done_inc(ring);
 	} while (!rt2x00_ring_empty(ring));
+
+	/*
+	 * Check if we are waiting on an empty queue
+	 * to start scanning.
+	 */
+	if (rt2x00pci->scan
+	&& rt2x00_ring_empty(&rt2x00pci->tx)
+	&& rt2x00_ring_empty(&rt2x00pci->atim)
+	&& rt2x00_ring_empty(&rt2x00pci->prio)) {
+		rt2x00pci->scan->status =3D SCANNING_READY;
+		complete(&rt2x00pci->scan->completion);
+	}
 }
=20
 static irqreturn_t
@@ -1517,6 +1521,14 @@ rt2400pci_stop(struct net_device *net_de
 	rt2x00_register_write(rt2x00pci, CSR8, reg);
=20
 	/*
+	 * Cancel scanning.
+	 */
+	if (rt2x00pci->scan) {
+		rt2x00pci->scan->status =3D SCANNING_CANCELLED;
+		complete_all(&rt2x00pci->scan->completion);
+	}
+
+	/*
 	 * Free DMA rings.
 	 */
 	rt2400pci_free_rings(rt2x00pci);
@@ -1564,35 +1576,23 @@ static void
 rt2400pci_scan(void *data)
 {
 	struct rt2x00_pci	*rt2x00pci =3D data;
=2D	struct net_device	*net_dev =3D pci_get_drvdata(rt2x00pci->pci_dev);
=2D	struct skb_cb		*cb;
=20
 	if (unlikely(!rt2x00pci->scan))
 		return;
=20
 	/*
=2D	 * Check if we have to send a packet before the
=2D	 * channel switch.
+	 * Before we can start switch the channel for scanning
+	 * we need to wait untill all TX rings are empty to
+	 * guarentee that all frames are send on the correct channel.
 	 */
=2D	if (rt2x00pci->scan->conf.skb) {
=2D		cb =3D (struct skb_cb*)&rt2x00pci->scan->conf.skb->cb;
=2D		cb->scan_complete =3D 1;
=2D
=2D		if (rt2400pci_tx(net_dev, rt2x00pci->scan->conf.skb,
=2D			rt2x00pci->scan->conf.tx_control))
=2D			goto exit;
=2D
=2D		/*
=2D		 * Wait for the frame to be correctly transmitted.
=2D		 */
+	if (rt2x00pci->scan->status !=3D SCANNING_READY)
 		wait_for_completion(&rt2x00pci->scan->completion);
=2D	}
=20
 	/*
 	 * Check if this scan has been cancelled while
 	 * work was still scheduled.
 	 */
=2D	if (rt2x00pci->scan->cancelled)
+	if (rt2x00pci->scan->status =3D=3D SCANNING_CANCELLED)
 		goto exit;
=20
 	/*
@@ -1633,9 +1633,24 @@ rt2400pci_passive_scan(struct net_device
 {
 	struct rt2x00_pci	*rt2x00pci =3D ieee80211_dev_hw_data(net_dev);
=20
+	if (rt2x00pci->scan)
+		return -EBUSY;
+
+	/*
+	 * Allocate scanning structure to store scanning info.
+	 */
 	rt2x00pci->scan =3D kmalloc(sizeof(struct scanning), GFP_ATOMIC);
 	if (!rt2x00pci->scan)
=2D		return 0;
+		return -ENOMEM;
+
+	/*
+	 * Check if we have to send a packet before the
+	 * channel switch.
+	 */
+	if (conf->skb) {
+		if (rt2400pci_tx(net_dev, conf->skb, conf->tx_control))
+			goto exit;
+	}
=20
 	/*
 	 * Initialize Scanning structure.
@@ -1646,14 +1661,21 @@ rt2400pci_passive_scan(struct net_device
=20
 	rt2x00pci->scan->state =3D state;
=20
=2D	rt2x00pci->scan->cancelled =3D 0;
+	rt2x00pci->scan->status =3D 0;
=20
 	/*
 	 * Queue work.
 	 */
=2D	queue_work(rt2x00pci->workqueue, &rt2x00pci->scan_work);
+	if (!queue_work(rt2x00pci->workqueue, &rt2x00pci->scan_work))
+		goto exit;
=20
 	return 0;
+
+exit:
+	kfree(rt2x00pci->scan);
+	rt2x00pci->scan =3D NULL;
+
+	return -EIO;
 }
=20
 static int
@@ -2207,11 +2229,6 @@ rt2400pci_uninitialize(struct net_device
 		rt2x00pci->csr_addr =3D NULL;
 	}
=20
=2D	if (rt2x00pci->scan) {
=2D		rt2x00pci->scan->cancelled =3D 1;
=2D		complete_all(&rt2x00pci->scan->completion);
=2D	}
=2D
 	if (likely(rt2x00pci->workqueue)) {
 		flush_workqueue(rt2x00pci->workqueue);
 		destroy_workqueue(rt2x00pci->workqueue);
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-27 21:47:52.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-27 21:48:21.000000000 +0200
@@ -923,7 +923,6 @@ rt2500pci_txdone(void *data)
 	struct rt2x00_pci	*rt2x00pci =3D (struct rt2x00_pci*)ring->dev;
 	struct net_device	*net_dev =3D pci_get_drvdata(rt2x00pci->pci_dev);
 	struct data_entry	*entry;
=2D	struct skb_cb		*cb;
 	struct txd		*txd;
 	int			tx_status;
 	int			ack;
@@ -936,13 +935,6 @@ rt2500pci_txdone(void *data)
 		|| !rt2x00_get_field32(txd->word0, TXD_W0_VALID))
 			break;
=20
=2D		/*
=2D		 * Check if this frame was send for the scan routine.
=2D		 */
=2D		cb =3D (struct skb_cb*)&entry->skb->cb;
=2D		if (rt2x00pci->scan && cb->scan_complete)
=2D			complete(&rt2x00pci->scan->completion);
=2D
 		ack =3D rt2x00_get_field32(txd->word0, TXD_W0_ACK);
=20
 		/*
@@ -981,6 +973,18 @@ rt2500pci_txdone(void *data)
=20
 		rt2x00_ring_index_done_inc(ring);
 	} while (!rt2x00_ring_empty(ring));
+
+	/*
+	 * Check if we are waiting on an empty queue
+	 * to start scanning.
+	 */
+	if (rt2x00pci->scan
+	&& rt2x00_ring_empty(&rt2x00pci->tx)
+	&& rt2x00_ring_empty(&rt2x00pci->atim)
+	&& rt2x00_ring_empty(&rt2x00pci->prio)) {
+		rt2x00pci->scan->status =3D SCANNING_READY;
+		complete(&rt2x00pci->scan->completion);
+	}
 }
=20
 static irqreturn_t
@@ -1630,6 +1634,14 @@ rt2500pci_stop(struct net_device *net_de
 	rt2x00_register_write(rt2x00pci, CSR8, reg);
=20
 	/*
+	 * Cancel scanning.
+	 */
+	if (rt2x00pci->scan) {
+		rt2x00pci->scan->status =3D SCANNING_CANCELLED;
+		complete_all(&rt2x00pci->scan->completion);
+	}
+
+	/*
 	 * Free DMA rings.
 	 */
 	rt2500pci_free_rings(rt2x00pci);
@@ -1677,35 +1689,23 @@ static void
 rt2500pci_scan(void *data)
 {
 	struct rt2x00_pci	*rt2x00pci =3D data;
=2D	struct net_device	*net_dev =3D pci_get_drvdata(rt2x00pci->pci_dev);
=2D	struct skb_cb		*cb;
=20
 	if (unlikely(!rt2x00pci->scan))
 		return;
=20
 	/*
=2D	 * Check if we have to send a packet before the
=2D	 * channel switch.
+	 * Before we can start switch the channel for scanning
+	 * we need to wait untill all TX rings are empty to
+	 * guarentee that all frames are send on the correct channel.
 	 */
=2D	if (rt2x00pci->scan->conf.skb) {
=2D		cb =3D (struct skb_cb*)&rt2x00pci->scan->conf.skb->cb;
=2D		cb->scan_complete =3D 1;
=2D
=2D		if (rt2500pci_tx(net_dev, rt2x00pci->scan->conf.skb,
=2D			rt2x00pci->scan->conf.tx_control))
=2D			goto exit;
=2D
=2D		/*
=2D		 * Wait for the frame to be correctly transmitted.
=2D		 */
+	if (rt2x00pci->scan->status !=3D SCANNING_READY)
 		wait_for_completion(&rt2x00pci->scan->completion);
=2D	}
=20
 	/*
 	 * Check if this scan has been cancelled while
 	 * work was still scheduled.
 	 */
=2D	if (rt2x00pci->scan->cancelled)
+	if (rt2x00pci->scan->status =3D=3D SCANNING_CANCELLED)
 		goto exit;
=20
 	/*
@@ -1742,9 +1742,24 @@ rt2500pci_passive_scan(struct net_device
 {
 	struct rt2x00_pci	*rt2x00pci =3D ieee80211_dev_hw_data(net_dev);
=20
+	if (rt2x00pci->scan)
+		return -EBUSY;
+
+	/*
+	 * Allocate scanning structure to store scanning info.
+	 */
 	rt2x00pci->scan =3D kmalloc(sizeof(struct scanning), GFP_ATOMIC);
 	if (!rt2x00pci->scan)
=2D		return 0;
+		return -ENOMEM;
+
+	/*
+	 * Check if we have to send a packet before the
+	 * channel switch.
+	 */
+	if (conf->skb) {
+		if (rt2500pci_tx(net_dev, conf->skb, conf->tx_control))
+			goto exit;
+	}
=20
 	/*
 	 * Initialize Scanning structure.
@@ -1755,14 +1770,21 @@ rt2500pci_passive_scan(struct net_device
=20
 	rt2x00pci->scan->state =3D state;
=20
=2D	rt2x00pci->scan->cancelled =3D 0;
+	rt2x00pci->scan->status =3D 0;
=20
 	/*
 	 * Queue work.
 	 */
=2D	queue_work(rt2x00pci->workqueue, &rt2x00pci->scan_work);
+	if (!queue_work(rt2x00pci->workqueue, &rt2x00pci->scan_work))
+		goto exit;
=20
 	return 0;
+
+exit:
+	kfree(rt2x00pci->scan);
+	rt2x00pci->scan =3D NULL;
+
+	return -EIO;
 }
=20
 static int
@@ -2505,20 +2527,15 @@ rt2500pci_uninitialize(struct net_device
 		rt2x00pci->csr_addr =3D NULL;
 	}
=20
=2D	if (rt2x00pci->scan) {
=2D		rt2x00pci->scan->cancelled =3D 1;
=2D		complete_all(&rt2x00pci->scan->completion);
=2D	}
=2D
 	if (likely(rt2x00pci->workqueue)) {
 		flush_workqueue(rt2x00pci->workqueue);
 		destroy_workqueue(rt2x00pci->workqueue);
 		rt2x00pci->workqueue =3D NULL;
 	}
=20
=2D		kfree(rt2x00pci->hw.modes);
=2D		rt2x00pci->hw.modes =3D NULL;
=2D	}
+	kfree(rt2x00pci->hw.modes);
+	rt2x00pci->hw.modes =3D NULL;
+}
=20
 /*
  * PCI driver handlers.
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-27 21:47:52.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-27 21:48:21.000000000 +0200
@@ -769,7 +769,6 @@ rt2500usb_txdone(void *data)
 	struct net_device	*net_dev =3D usb_get_intfdata(
 						rt2x00usb->usb_intf);
 	struct data_entry	*entry;
=2D	struct skb_cb		*cb;
 	struct txd		*txd;
 	int			ack;
=20
@@ -777,13 +776,6 @@ rt2500usb_txdone(void *data)
 		entry =3D rt2x00_get_data_entry_done(ring);
 		txd =3D entry->desc_addr;
=20
=2D		/*
=2D		 * Check if this frame was send for the scan routine.
=2D		 */
=2D		cb =3D (struct skb_cb*)&entry->skb->cb;
=2D		if (rt2x00usb->scan && cb->scan_complete)
=2D			complete(&rt2x00usb->scan->completion);
=2D
 		ack =3D rt2x00_get_field32(txd->word0, TXD_W0_ACK);
 =09
 		/*
@@ -815,6 +807,18 @@ rt2500usb_txdone(void *data)
 =09
 		rt2x00_ring_index_done_inc(entry->ring);
 	} while (!rt2x00_ring_empty(ring));
+
+	/*
+	 * Check if we are waiting on an empty queue
+	 * to start scanning.
+	 */
+	if (rt2x00usb->scan
+	&& rt2x00_ring_empty(&rt2x00usb->tx)
+	&& rt2x00_ring_empty(&rt2x00usb->atim)
+	&& rt2x00_ring_empty(&rt2x00usb->prio)) {
+		rt2x00usb->scan->status =3D SCANNING_READY;
+		complete(&rt2x00usb->scan->completion);
+	}
 }
=20
 static void
@@ -1368,6 +1372,14 @@ rt2500usb_stop(struct net_device *net_de
 	rt2x00_register_write(rt2x00usb, MAC_CSR14, 0x2121);
=20
 	/*
+	 * Cancel scanning.
+	 */
+	if (rt2x00usb->scan) {
+		rt2x00usb->scan->status =3D SCANNING_CANCELLED;
+		complete_all(&rt2x00usb->scan->completion);
+	}
+
+	/*
 	 * Free DMA rings.
 	 */
 	rt2500usb_free_rings(rt2x00usb);
@@ -1414,36 +1426,23 @@ static void
 rt2500usb_scan(void *data)
 {
 	struct rt2x00_usb	*rt2x00usb =3D data;
=2D	struct net_device	*net_dev =3D
=2D		usb_get_intfdata(rt2x00usb->usb_intf);
=2D	struct skb_cb		*cb;
=20
 	if (unlikely(!rt2x00usb->scan))
 		return;
=20
 	/*
=2D	 * Check if we have to send a packet before the
=2D	 * channel switch.
+	 * Before we can start switch the channel for scanning
+	 * we need to wait untill all TX rings are empty to
+	 * guarentee that all frames are send on the correct channel.
 	 */
=2D	if (rt2x00usb->scan->conf.skb) {
=2D		cb =3D (struct skb_cb*)&rt2x00usb->scan->conf.skb->cb;
=2D		cb->scan_complete =3D 1;
=2D
=2D		if (rt2500usb_tx(net_dev, rt2x00usb->scan->conf.skb,
=2D			rt2x00usb->scan->conf.tx_control))
=2D			goto exit;
=2D
=2D		/*
=2D		 * Wait for the frame to be correctly transmitted.
=2D		 */
+	if (rt2x00usb->scan->status !=3D SCANNING_READY)
 		wait_for_completion(&rt2x00usb->scan->completion);
=2D	}
=20
 	/*
 	 * Check if this scan has been cancelled while
 	 * work was still scheduled.
 	 */
=2D	if (rt2x00usb->scan->cancelled)
+	if (rt2x00usb->scan->status =3D=3D SCANNING_CANCELLED)
 		goto exit;
=20
 	/*
@@ -1480,9 +1479,24 @@ rt2500usb_passive_scan(struct net_device
 {
 	struct rt2x00_usb	*rt2x00usb =3D ieee80211_dev_hw_data(net_dev);
=20
+	if (rt2x00usb->scan)
+		return -EBUSY;
+
+	/*
+	 * Allocate scanning structure to store scanning info.
+	 */
 	rt2x00usb->scan =3D kmalloc(sizeof(struct scanning), GFP_ATOMIC);
 	if (!rt2x00usb->scan)
=2D		return 0;
+		return -ENOMEM;
+
+	/*
+	 * Check if we have to send a packet before the
+	 * channel switch.
+	 */
+	if (conf->skb) {
+		if (rt2500usb_tx(net_dev, conf->skb, conf->tx_control))
+			goto exit;
+	}
=20
 	/*
 	 * Initialize Scanning structure.
@@ -1493,14 +1507,21 @@ rt2500usb_passive_scan(struct net_device
=20
 	rt2x00usb->scan->state =3D state;
=20
=2D	rt2x00usb->scan->cancelled =3D 0;
+	rt2x00usb->scan->status =3D 0;
=20
 	/*
 	 * Queue work.
 	 */
=2D	queue_work(rt2x00usb->workqueue, &rt2x00usb->scan_work);
+	if (!queue_work(rt2x00usb->workqueue, &rt2x00usb->scan_work))
+		goto exit;
=20
 	return 0;
+
+exit:
+	kfree(rt2x00usb->scan);
+	rt2x00usb->scan =3D NULL;
+
+	return -EIO;
 }
=20
 static int
@@ -2121,19 +2142,14 @@ rt2500usb_uninitialize(struct net_device
=20
 	kfree(rt2x00usb->eeprom);
=20
=2D	if (rt2x00usb->scan) {
=2D		rt2x00usb->scan->cancelled =3D 1;
=2D		complete_all(&rt2x00usb->scan->completion);
=2D	}
=2D
 	if (likely(rt2x00usb->workqueue)) {
 		flush_workqueue(rt2x00usb->workqueue);
 		destroy_workqueue(rt2x00usb->workqueue);
 		rt2x00usb->workqueue =3D NULL;
 	}
=20
=2D		kfree(rt2x00usb->hw.modes);
=2D		rt2x00usb->hw.modes =3D NULL;
+	kfree(rt2x00usb->hw.modes);
+	rt2x00usb->hw.modes =3D NULL;
 }
=20
 /*
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00.h =
wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2x00.h
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-=
04-27 21:47:52.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2=
006-04-27 21:48:21.000000000 +0200
@@ -428,15 +428,6 @@ rt2x00_rf(const struct _rt2x00_chip *chi
 }
=20
 /*
=2D * Data to be placed in the skb->cb array.
=2D * therefor this structure may not exceed the 40 bytes.
=2D */
=2Dstruct skb_cb{
=2D	int					scan_complete;
=2D} __attribute__ ((packed));
=2D
=2D
=2D/*
  * data_ring
  * Data rings are used by the device to send and receive packets.
  * The data_addr is the base address of the data memory.
@@ -589,7 +580,9 @@ struct scanning{
 	/*
 	 * Flag to see if this scan has been cancelled.
 	 */
=2D	short					cancelled;
+	short					status;
+#define SCANNING_READY				0x0001
+#define SCANNING_CANCELLED			0x0002
 } __attribute__ ((packed));
=20
=20

--nextPart30983570.FQ9bHq5sx3
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+caqndE37Em0gRAnAqAKCWp3fLmsESmiippk422H2TCWq/nACgnG2s
KKWN0RyVvXj6MiU4uEtHoms=
=hLn+
-----END PGP SIGNATURE-----

--nextPart30983570.FQ9bHq5sx3--
