From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 6/5] rt2x00: per-queue TX flow control
Date: Wed, 14 Jun 2006 20:35:40 +0200
Message-ID: <200606142035.44451.IvDoorn@gmail.com>
References: <20060612211454.409884000.midnight@suse.cz> <20060614183635.546d3346@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1158464.Vxabbd8tgU";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:6249 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1750721AbWFNScP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 14:32:15 -0400
Received: by nf-out-0910.google.com with SMTP id y38so120961nfb
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2006 11:32:14 -0700 (PDT)
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060614183635.546d3346@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1158464.Vxabbd8tgU
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

On Wednesday 14 June 2006 18:36, Jiri Benc wrote:
> This is a patch for rt2x00 driver to do TX flow control.
>=20
> It is compile-tested only.
>
> Signed-off-by: Jiri Benc <jbenc@suse.cz>

I'll put my comments for the rt2400pci driver only,
since the same changes are made for each rt2x00 driver.

> --- dscape.orig/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
> +++ dscape/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
> @@ -1001,7 +1001,7 @@ rt2400pci_txdone(void *data)
>  	struct data_entry	*entry;
>  	struct txd		*txd;
>  	int			tx_status;
> -	int			ack;
> +	int			ack, wake, queue;
> =20
>  	while (!rt2x00_ring_empty(ring)) {
>  		entry =3D rt2x00_get_data_entry_done(ring);
> @@ -1048,7 +1048,11 @@ rt2400pci_txdone(void *data)
>  		rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 0);
>  		entry->skb =3D NULL;
> =20
> +		wake =3D rt2x00_ring_full(ring);
> +		queue =3D entry->tx_status.control.queue;
>  		rt2x00_ring_index_done_inc(ring);
> +		if (wake)
> +			ieee80211_wake_queue(ring->net_dev, queue);
>  	}

This will not give the correct result I fear, and it would cause (unwanted)
overhead of checking if the queue was full.
Queue_full can be checked when the loop starts, and the
waking of the queue can best be done after freeing all entries
and after the second check if the queue is still not full. (There is no gua=
rentee
the while() loop will end while there are free entries in the queue)

>  	/*
> @@ -1541,24 +1545,31 @@ rt2400pci_tx(struct net_device *net_dev,
>  		ERROR("Attempt to send packet over invalid queue %d.\n"
>  			"Please file bug report to %s.\n",
>  			control->queue, DRV_PROJECT);
> -		return NET_XMIT_DROP;
> +		dev_kfree_skb_any(skb);
> +		return NETDEV_TX_OK;
>  	}
> =20
> -	if (rt2x00_ring_full(ring))
> -		return NET_XMIT_DROP;
> +	if (rt2x00_ring_full(ring)) {
> +		ieee80211_stop_queue(net_dev, control->queue);
> +		return NETDEV_TX_BUSY;
> +	}
> =20
>  	entry =3D rt2x00_get_data_entry(ring);
>  	txd =3D entry->desc_addr;
> =20
> -	if (rt2x00_get_field32(txd->word0, TXD_W0_OWNER_NIC)
> -	|| rt2x00_get_field32(txd->word0, TXD_W0_VALID))
> -		return NET_XMIT_DROP;
> +	if (rt2x00_get_field32(txd->word0, TXD_W0_OWNER_NIC) ||
> +	    rt2x00_get_field32(txd->word0, TXD_W0_VALID)) {
> +		ieee80211_stop_queue(net_dev, control->queue);
> +		return NETDEV_TX_BUSY;
> +	}

Not sure if I am happy with this one. When this check is made,
it occurs after the ring_full check. This means that when this statement
is true, the queue is not full. Instead it has more of a meaning that somet=
hing
has gone wrong with the queue and this should not have happened.

But this is not really a problem in the patch itself, just a problem I only
now recognize thanks to your patch. ;)

=46or the time being I'll add a debug message, but I need to find a method
to clean up the ring if this occurs.
This check currently does not happen in the rt2570 and rt73 USB drivers,
but it is safer to add them in there as well.

>  	memcpy(entry->data_addr, skb->data, skb->len);
>  	rt2400pci_write_tx_desc(rt2x00pci, txd, skb, control);
>  	entry->skb =3D skb;
> =20
>  	rt2x00_ring_index_inc(ring);
> +	if (rt2x00_ring_full(ring))
> +		ieee80211_stop_queue(net_dev, control->queue);
> =20
>  	rt2x00_register_read(rt2x00pci, TXCSR0, &reg);
>  	if (control->queue =3D=3D IEEE80211_TX_QUEUE_DATA0)
> @@ -1668,6 +1679,7 @@ rt2400pci_open(struct net_device *net_de
>  	rt2x00_register_write(rt2x00pci, CSR8, reg);
> =20
>  	SET_FLAG(rt2x00pci, RADIO_ENABLED);
> +	ieee80211_start_queues(net_dev);
> =20
>  	return 0;

Based on Jiri's patch for rt2x00 driver to do TX flow control.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

=2D--

diff --git a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c b/drivers/net/w=
ireless/d80211/rt2x00/rt2400pci.c
index 8b856dd..946cf86 100644
=2D-- a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
@@ -1002,6 +1002,12 @@ rt2400pci_txdone(void *data)
 	struct txd		*txd;
 	int			tx_status;
 	int			ack;
+	int			ring_full;
+
+	/*
+	 * Store the current status of the ring.
+	 */
+	ring_full =3D rt2x00_ring_full(ring);
=20
 	while (!rt2x00_ring_empty(ring)) {
 		entry =3D rt2x00_get_data_entry_done(ring);
@@ -1062,6 +1068,16 @@ rt2400pci_txdone(void *data)
 		rt2x00pci->scan->status =3D SCANNING_READY;
 		complete(&rt2x00pci->scan->completion);
 	}
+
+	/*
+	 * If the data ring was full before the txdone handler
+	 * we must make sure the packet queue in the d80211 stack
+	 * is reenabled when the txdone handler has finished.
+	 */
+	entry =3D ring->entry;
+	if (ring_full && !rt2x00_ring_full(ring))
+		ieee80211_wake_queue(ring->net_dev,
+			entry->tx_status.control.queue);
 }
=20
 static irqreturn_t
@@ -1541,18 +1557,26 @@ rt2400pci_tx(struct net_device *net_dev,
 		ERROR("Attempt to send packet over invalid queue %d.\n"
 			"Please file bug report to %s.\n",
 			control->queue, DRV_PROJECT);
=2D		return NET_XMIT_DROP;
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
 	}
=20
=2D	if (rt2x00_ring_full(ring))
=2D		return NET_XMIT_DROP;
+	if (rt2x00_ring_full(ring)) {
+		ieee80211_stop_queue(net_dev, control->queue);
+		return NETDEV_TX_BUSY;
+	}
=20
 	entry =3D rt2x00_get_data_entry(ring);
 	txd =3D entry->desc_addr;
=20
 	if (rt2x00_get_field32(txd->word0, TXD_W0_OWNER_NIC)
=2D	|| rt2x00_get_field32(txd->word0, TXD_W0_VALID))
=2D		return NET_XMIT_DROP;
+	|| rt2x00_get_field32(txd->word0, TXD_W0_VALID)) {
+		ERROR("Arrived at non-free entry in the non-full queue %d.\n"
+			"Please file bug report to %s.\n",
+			control->queue, DRV_PROJECT);
+		ieee80211_stop_queue(net_dev, control->queue);
+		return NETDEV_TX_BUSY;
+	}
=20
 	memcpy(entry->data_addr, skb->data, skb->len);
 	rt2400pci_write_tx_desc(rt2x00pci, txd, skb, control);
@@ -1560,6 +1584,9 @@ rt2400pci_tx(struct net_device *net_dev,
=20
 	rt2x00_ring_index_inc(ring);
=20
+	if (rt2x00_ring_full(ring))
+		ieee80211_stop_queue(net_dev, control->queue);
+
 	rt2x00_register_read(rt2x00pci, TXCSR0, &reg);
 	if (control->queue =3D=3D IEEE80211_TX_QUEUE_DATA0)
 		rt2x00_set_field32(&reg, TXCSR0_KICK_PRIO, 1);
@@ -1569,7 +1596,7 @@ rt2400pci_tx(struct net_device *net_dev,
 		rt2x00_set_field32(&reg, TXCSR0_KICK_ATIM, 1);
 	rt2x00_register_write(rt2x00pci, TXCSR0, reg);
=20
=2D	return 0;
+	return NETDEV_TX_OK;
 }
=20
 static int
@@ -1669,6 +1696,8 @@ rt2400pci_open(struct net_device *net_de
=20
 	SET_FLAG(rt2x00pci, RADIO_ENABLED);
=20
+	ieee80211_start_queues(net_dev);
+
 	return 0;
=20
 exit_fail:
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c b/drivers/net/w=
ireless/d80211/rt2x00/rt2500pci.c
index 6aeaf1a..ca0edd5 100644
=2D-- a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
@@ -1090,6 +1090,12 @@ rt2500pci_txdone(void *data)
 	struct txd		*txd;
 	int			tx_status;
 	int			ack;
+	int			ring_full;
+
+	/*
+	 * Store the current status of the ring.
+	 */
+	ring_full =3D rt2x00_ring_full(ring);
=20
 	while (!rt2x00_ring_empty(ring)) {
 		entry =3D rt2x00_get_data_entry_done(ring);
@@ -1150,6 +1156,16 @@ rt2500pci_txdone(void *data)
 		rt2x00pci->scan->status =3D SCANNING_READY;
 		complete(&rt2x00pci->scan->completion);
 	}
+
+	/*
+	 * If the data ring was full before the txdone handler
+	 * we must make sure the packet queue in the d80211 stack
+	 * is reenabled when the txdone handler has finished.
+	 */
+	entry =3D ring->entry;
+	if (ring_full && !rt2x00_ring_full(ring))
+		ieee80211_wake_queue(ring->net_dev,
+			entry->tx_status.control.queue);
 }
=20
 static irqreturn_t
@@ -1664,18 +1680,26 @@ rt2500pci_tx(struct net_device *net_dev,
 		ERROR("Attempt to send packet over invalid queue %d.\n"
 			"Please file bug report to %s.\n",
 			control->queue, DRV_PROJECT);
=2D		return NET_XMIT_DROP;
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
 	}
=20
=2D	if (rt2x00_ring_full(ring))
=2D		return NET_XMIT_DROP;
+	if (rt2x00_ring_full(ring)) {
+		ieee80211_stop_queue(net_dev, control->queue);
+		return NETDEV_TX_BUSY;
+	}
=20
 	entry =3D rt2x00_get_data_entry(ring);
 	txd =3D entry->desc_addr;
=20
 	if (rt2x00_get_field32(txd->word0, TXD_W0_OWNER_NIC)
=2D	|| rt2x00_get_field32(txd->word0, TXD_W0_VALID))
=2D		return NET_XMIT_DROP;
+	|| rt2x00_get_field32(txd->word0, TXD_W0_VALID)) {
+		ERROR("Arrived at non-free entry in the non-full queue %d.\n"
+			"Please file bug report to %s.\n",
+			control->queue, DRV_PROJECT);
+		ieee80211_stop_queue(net_dev, control->queue);
+		return NETDEV_TX_BUSY;
+	}
=20
 	memcpy(entry->data_addr, skb->data, skb->len);
 	rt2500pci_write_tx_desc(rt2x00pci, txd, skb, control);
@@ -1683,6 +1707,9 @@ rt2500pci_tx(struct net_device *net_dev,
=20
 	rt2x00_ring_index_inc(ring);
=20
+	if (rt2x00_ring_full(ring))
+		ieee80211_stop_queue(net_dev, control->queue);
+
 	rt2x00_register_read(rt2x00pci, TXCSR0, &reg);
 	if (control->queue =3D=3D IEEE80211_TX_QUEUE_DATA0)
 		rt2x00_set_field32(&reg, TXCSR0_KICK_PRIO, 1);
@@ -1692,7 +1719,7 @@ rt2500pci_tx(struct net_device *net_dev,
 		rt2x00_set_field32(&reg, TXCSR0_KICK_ATIM, 1);
 	rt2x00_register_write(rt2x00pci, TXCSR0, reg);
=20
=2D	return 0;
+	return NETDEV_TX_OK;
 }
=20
 static int
@@ -1792,6 +1819,8 @@ rt2500pci_open(struct net_device *net_de
=20
 	SET_FLAG(rt2x00pci, RADIO_ENABLED);
=20
+	ieee80211_start_queues(net_dev);
+
 	return 0;
=20
 exit_fail:
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500usb.c b/drivers/net/w=
ireless/d80211/rt2x00/rt2500usb.c
index 1193e60..76c3a68 100644
=2D-- a/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
@@ -930,6 +930,12 @@ rt2500usb_txdone(void *data)
 	struct data_entry	*entry;
 	struct txd		*txd;
 	int			ack;
+	int			ring_full;
+
+	/*
+	 * Store the current status of the ring.
+	 */
+	ring_full =3D rt2x00_ring_full(ring);
=20
 	 while (!rt2x00_ring_empty(ring)) {
 		entry =3D rt2x00_get_data_entry_done(ring);
@@ -982,6 +988,16 @@ rt2500usb_txdone(void *data)
 		rt2x00usb->scan->status =3D SCANNING_READY;
 		complete(&rt2x00usb->scan->completion);
 	}
+
+	/*
+	 * If the data ring was full before the txdone handler
+	 * we must make sure the packet queue in the d80211 stack
+	 * is reenabled when the txdone handler has finished.
+	 */
+	entry =3D ring->entry;
+	if (ring_full && !rt2x00_ring_full(ring))
+		ieee80211_wake_queue(ring->net_dev,
+			entry->tx_status.control.queue);
 }
=20
 static void
@@ -1376,15 +1392,26 @@ rt2500usb_tx(struct net_device *net_dev,
 		ERROR("Attempt to send packet over invalid queue %d.\n"
 			"Please file bug report to %s.\n",
 			control->queue, DRV_PROJECT);
=2D		return NET_XMIT_DROP;
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
 	}
=20
=2D	if (rt2x00_ring_full(ring))
=2D		return NET_XMIT_DROP;
+	if (rt2x00_ring_full(ring)) {
+		ieee80211_stop_queue(net_dev, control->queue);
+		return NETDEV_TX_BUSY;
+	}
=20
 	entry =3D rt2x00_get_data_entry(ring);
 	txd =3D rt2x00usb_txdesc_addr(entry);
=20
+	if (GET_FLAG(entry, ENTRY_OWNER_NIC)) {
+		ERROR("Arrived at non-free entry in the non-full queue %d.\n"
+			"Please file bug report to %s.\n",
+			control->queue, DRV_PROJECT);
+		ieee80211_stop_queue(net_dev, control->queue);
+		return NETDEV_TX_BUSY;
+	}
+
 	memcpy(rt2x00usb_txdata_addr(entry), skb->data, skb->len);
 	rt2500usb_write_tx_desc(rt2x00usb, txd, skb, control);
 	entry->skb =3D skb;
@@ -1402,7 +1429,10 @@ rt2500usb_tx(struct net_device *net_dev,
=20
 	rt2x00_ring_index_inc(ring);
=20
=2D	return 0;
+	if (rt2x00_ring_full(ring))
+		ieee80211_stop_queue(net_dev, control->queue);
+
+	return NETDEV_TX_OK;
 }
=20
 static inline void
@@ -1469,6 +1499,8 @@ rt2500usb_open(struct net_device *net_de
=20
 	SET_FLAG(rt2x00usb, RADIO_ENABLED);
=20
+	ieee80211_start_queues(net_dev);
+
 	return 0;
=20
 exit_fail:
diff --git a/drivers/net/wireless/d80211/rt2x00/rt61pci.c b/drivers/net/wir=
eless/d80211/rt2x00/rt61pci.c
index fdbfa60..0799f9f 100644
=2D-- a/drivers/net/wireless/d80211/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
@@ -1353,6 +1353,12 @@ rt61pci_txdone(void *data)
 	int			tx_status;
 	int			ack;
 	int			reg;
+	int			ring_full;
+
+	/*
+	 * Store the current status of the ring.
+	 */
+	ring_full =3D rt2x00_ring_full(ring);
=20
 	while (!rt2x00_ring_empty(ring)) {
 		entry =3D rt2x00_get_data_entry_done(ring);
@@ -1418,6 +1424,16 @@ rt61pci_txdone(void *data)
 		rt2x00pci->scan->status =3D SCANNING_READY;
 		complete(&rt2x00pci->scan->completion);
 	}
+
+	/*
+	 * If the data ring was full before the txdone handler
+	 * we must make sure the packet queue in the d80211 stack
+	 * is reenabled when the txdone handler has finished.
+	 */
+	entry =3D ring->entry;
+	if (ring_full && !rt2x00_ring_full(ring))
+		ieee80211_wake_queue(ring->net_dev,
+			entry->tx_status.control.queue);
 }
=20
 static irqreturn_t
@@ -2100,18 +2116,26 @@ rt61pci_tx(struct net_device *net_dev,
 		ERROR("Attempt to send packet over invalid queue %d.\n"
 			"Please file bug report to %s.\n",
 			control->queue, DRV_PROJECT);
=2D		return NET_XMIT_DROP;
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
 	}
=20
=2D	if (rt2x00_ring_full(ring))
=2D		return NET_XMIT_DROP;
+	if (rt2x00_ring_full(ring)) {
+		ieee80211_stop_queue(net_dev, control->queue);
+		return NETDEV_TX_BUSY;
+	}
=20
 	entry =3D rt2x00_get_data_entry(ring);
 	txd =3D entry->desc_addr;
=20
 	if (rt2x00_get_field32(txd->word0, TXD_W0_OWNER_NIC)
=2D	|| rt2x00_get_field32(txd->word0, TXD_W0_VALID))
=2D		return NET_XMIT_DROP;
+	|| rt2x00_get_field32(txd->word0, TXD_W0_VALID)) {
+		ERROR("Arrived at non-free entry in the non-full queue %d.\n"
+			"Please file bug report to %s.\n",
+			control->queue, DRV_PROJECT);
+		ieee80211_stop_queue(net_dev, control->queue);
+		return NETDEV_TX_BUSY;
+	}
=20
 	memcpy(entry->data_addr, skb->data, skb->len);
 	rt61pci_write_tx_desc(rt2x00pci, txd, skb, control);
@@ -2119,6 +2143,9 @@ rt61pci_tx(struct net_device *net_dev,
=20
 	rt2x00_ring_index_inc(ring);
=20
+	if (rt2x00_ring_full(ring))
+		ieee80211_stop_queue(net_dev, control->queue);
+
 	rt2x00_register_read(rt2x00pci, TX_CNTL_CSR, &reg);
 	if (control->queue =3D=3D IEEE80211_TX_QUEUE_DATA0)
 		rt2x00_set_field32(&reg, TX_CNTL_CSR_KICK_TX_AC0, 1);
@@ -2132,7 +2159,7 @@ rt61pci_tx(struct net_device *net_dev,
 		rt2x00_set_field32(&reg, TX_CNTL_CSR_KICK_TX_MGMT, 1);
 	rt2x00_register_write(rt2x00pci, TX_CNTL_CSR, reg);
=20
=2D	return 0;
+	return NETDEV_TX_OK;
 }
=20
 static int
@@ -2249,6 +2276,8 @@ rt61pci_open(struct net_device *net_dev)
=20
 	SET_FLAG(rt2x00pci, RADIO_ENABLED);
=20
+	ieee80211_start_queues(net_dev);
+
 	return 0;
=20
 exit_fail:
diff --git a/drivers/net/wireless/d80211/rt2x00/rt73usb.c b/drivers/net/wir=
eless/d80211/rt2x00/rt73usb.c
index 48e9917..1871204 100644
=2D-- a/drivers/net/wireless/d80211/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt73usb.c
@@ -1094,6 +1094,12 @@ rt73usb_txdone(void *data)
 	struct data_entry	*entry;
 	struct txd		*txd;
 	int			ack;
+	int			ring_full;
+
+	/*
+	 * Store the current status of the ring.
+	 */
+	ring_full =3D rt2x00_ring_full(ring);
=20
 	while (!rt2x00_ring_empty(ring)) {
 		entry =3D rt2x00_get_data_entry_done(ring);
@@ -1148,6 +1154,16 @@ rt73usb_txdone(void *data)
 		rt2x00usb->scan->status =3D SCANNING_READY;
 		complete(&rt2x00usb->scan->completion);
 	}
+
+	/*
+	 * If the data ring was full before the txdone handler
+	 * we must make sure the packet queue in the d80211 stack
+	 * is reenabled when the txdone handler has finished.
+	 */
+	entry =3D ring->entry;
+	if (ring_full && !rt2x00_ring_full(ring))
+		ieee80211_wake_queue(ring->net_dev,
+			entry->tx_status.control.queue);
 }
=20
 static void
@@ -1668,15 +1684,26 @@ rt73usb_tx(struct net_device *net_dev,
 		ERROR("Attempt to send packet over invalid queue %d.\n"
 			"Please file bug report to %s.\n",
 			control->queue, DRV_PROJECT);
=2D		return NET_XMIT_DROP;
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
 	}
=20
=2D	if (rt2x00_ring_full(ring))
=2D		return NET_XMIT_DROP;
+	if (rt2x00_ring_full(ring)) {
+		ieee80211_stop_queue(net_dev, control->queue);
+		return NETDEV_TX_BUSY;
+	}
=20
 	entry =3D rt2x00_get_data_entry(ring);
 	txd =3D rt2x00usb_txdesc_addr(entry);
=20
+	if (GET_FLAG(entry, ENTRY_OWNER_NIC)) {
+		ERROR("Arrived at non-free entry in the non-full queue %d.\n"
+			"Please file bug report to %s.\n",
+			control->queue, DRV_PROJECT);
+		ieee80211_stop_queue(net_dev, control->queue);
+		return NETDEV_TX_BUSY;
+	}
+
 	memcpy(rt2x00usb_txdata_addr(entry), skb->data, skb->len);
 	rt73usb_write_tx_desc(rt2x00usb, txd, skb, control);
 	entry->skb =3D skb;
@@ -1694,7 +1721,10 @@ rt73usb_tx(struct net_device *net_dev,
=20
 	rt2x00_ring_index_inc(ring);
=20
=2D	return 0;
+	if (rt2x00_ring_full(ring))
+		ieee80211_stop_queue(net_dev, control->queue);
+
+	return NETDEV_TX_OK;
 }
=20
 static inline void
@@ -1766,6 +1796,8 @@ rt73usb_open(struct net_device *net_dev)
=20
 	SET_FLAG(rt2x00usb, RADIO_ENABLED);
=20
+	ieee80211_start_queues(net_dev);
+
 	return 0;
=20
 exit_fail:

--nextPart1158464.Vxabbd8tgU
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEkFcAaqndE37Em0gRAkrgAKCQ1X3T1HD6D/pSdoaet1mO4DGFAACeMDhZ
pIc+LgnnuS79N11ze/h+W1Y=
=x+sg
-----END PGP SIGNATURE-----

--nextPart1158464.Vxabbd8tgU--
