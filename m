From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next v2 1/2] Avoid sending superfluous LDC messages.
Date: Tue, 2 Sep 2014 12:20:07 -0400
Message-ID: <20140902162007.GB31516@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, raghuram.kothakota@oracle.com,
	sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25818 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbaIBQUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 12:20:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When sending out a burst of packets across multiple descriptor,
it is sufficient to send one LDC "start" trigger for
the first descriptor, so do not send an LDC "start" for every
pass through vnet_start_xmit. Similarly, it is sufficient to send
one "DRING_STOPPED" trigger for the last dring (and if that
fails, hold off and send the trigger later).

Optimizations to the number of LDC messages helps avoid
filling up the LDC channel with superfluous LDC messages
that risk triggering flow-control on the channel,
and also boosts performance.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Acked-by: Raghuram Kothakota <raghuram.kothakota@oracle.com>
---
changes since v1: moved unused label/variable to patch 2/2

 drivers/net/ethernet/sun/sunvnet.c | 64 +++++++++++++++++++++++++++++++++++---
 drivers/net/ethernet/sun/sunvnet.h |  4 +++
 2 files changed, 63 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 23c89ab..8f90b57 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -37,6 +37,8 @@ MODULE_VERSION(DRV_MODULE_VERSION);
  */
 #define	VNET_MAX_RETRIES	10
 
+static int __vnet_tx_trigger(struct vnet_port *port, u32 start);
+
 /* Ordered from largest major to lowest */
 static struct vio_version vnet_versions[] = {
 	{ .major = 1, .minor = 0 },
@@ -283,10 +285,18 @@ static int vnet_send_ack(struct vnet_port *port, struct vio_dring_state *dr,
 				port->raddr[0], port->raddr[1],
 				port->raddr[2], port->raddr[3],
 				port->raddr[4], port->raddr[5]);
-			err = -ECONNRESET;
+			break;
 		}
 	} while (err == -EAGAIN);
 
+	if (err <= 0 && vio_dring_state == VIO_DRING_STOPPED) {
+		port->stop_rx_idx = end;
+		port->stop_rx = true;
+	} else {
+		port->stop_rx_idx = 0;
+		port->stop_rx = false;
+	}
+
 	return err;
 }
 
@@ -448,7 +458,7 @@ static int vnet_ack(struct vnet_port *port, void *msgbuf)
 	struct net_device *dev;
 	struct vnet *vp;
 	u32 end;
-
+	struct vio_net_desc *desc;
 	if (unlikely(pkt->tag.stype_env != VIO_DRING_DATA))
 		return 0;
 
@@ -456,7 +466,24 @@ static int vnet_ack(struct vnet_port *port, void *msgbuf)
 	if (unlikely(!idx_is_pending(dr, end)))
 		return 0;
 
+	/* sync for race conditions with vnet_start_xmit() and tell xmit it
+	 * is time to send a trigger.
+	 */
 	dr->cons = next_idx(end, dr);
+	desc = vio_dring_entry(dr, dr->cons);
+	if (desc->hdr.state == VIO_DESC_READY && port->start_cons) {
+		/* vnet_start_xmit() just populated this dring but missed
+		 * sending the "start" LDC message to the consumer.
+		 * Send a "start" trigger on its behalf.
+		 */
+		if (__vnet_tx_trigger(port, dr->cons) > 0)
+			port->start_cons = false;
+		else
+			port->start_cons = true;
+	} else {
+		port->start_cons = true;
+	}
+
 
 	vp = port->vp;
 	dev = vp->dev;
@@ -597,7 +624,7 @@ static void vnet_event(void *arg, int event)
 	local_irq_restore(flags);
 }
 
-static int __vnet_tx_trigger(struct vnet_port *port)
+static int __vnet_tx_trigger(struct vnet_port *port, u32 start)
 {
 	struct vio_dring_state *dr = &port->vio.drings[VIO_DRIVER_TX_RING];
 	struct vio_dring_data hdr = {
@@ -608,12 +635,21 @@ static int __vnet_tx_trigger(struct vnet_port *port)
 			.sid		= vio_send_sid(&port->vio),
 		},
 		.dring_ident		= dr->ident,
-		.start_idx		= dr->prod,
+		.start_idx		= start,
 		.end_idx		= (u32) -1,
 	};
 	int err, delay;
 	int retries = 0;
 
+	if (port->stop_rx) {
+		err = vnet_send_ack(port,
+				    &port->vio.drings[VIO_DRIVER_RX_RING],
+				    port->stop_rx_idx, -1,
+				    VIO_DRING_STOPPED);
+		if (err <= 0)
+			return err;
+	}
+
 	hdr.seq = dr->snd_nxt;
 	delay = 1;
 	do {
@@ -734,7 +770,21 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	d->hdr.state = VIO_DESC_READY;
 
-	err = __vnet_tx_trigger(port);
+	/* Exactly one ldc "start" trigger (for dr->cons) needs to be sent
+	 * to notify the consumer that some descriptors are READY.
+	 * After that "start" trigger, no additional triggers are needed until
+	 * a DRING_STOPPED is received from the consumer. The dr->cons field
+	 * (set up by vnet_ack()) has the value of the next dring index
+	 * that has not yet been ack-ed. We send a "start" trigger here
+	 * if, and only if, start_cons is true (reset it afterward). Conversely,
+	 * vnet_ack() should check if the dring corresponding to cons
+	 * is marked READY, but start_cons was false.
+	 * If so, vnet_ack() should send out the missed "start" trigger.
+	 */
+	if (!port->start_cons)
+		goto ldc_start_done; /* previous trigger suffices */
+
+	err = __vnet_tx_trigger(port, dr->cons);
 	if (unlikely(err < 0)) {
 		netdev_info(dev, "TX trigger error %d\n", err);
 		d->hdr.state = VIO_DESC_FREE;
@@ -742,6 +792,9 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto out_dropped_unlock;
 	}
 
+ldc_start_done:
+	port->start_cons = false;
+
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
 
@@ -1035,6 +1088,7 @@ static int vnet_port_alloc_tx_bufs(struct vnet_port *port)
 			  (sizeof(struct ldc_trans_cookie) * 2));
 	dr->num_entries = VNET_TX_RING_SIZE;
 	dr->prod = dr->cons = 0;
+	port->start_cons  = true; /* need an initial trigger */
 	dr->pending = VNET_TX_RING_SIZE;
 	dr->ncookies = ncookies;
 
diff --git a/drivers/net/ethernet/sun/sunvnet.h b/drivers/net/ethernet/sun/sunvnet.h
index de5c2c6..da49337 100644
--- a/drivers/net/ethernet/sun/sunvnet.h
+++ b/drivers/net/ethernet/sun/sunvnet.h
@@ -40,6 +40,10 @@ struct vnet_port {
 	struct vnet_tx_entry	tx_bufs[VNET_TX_RING_SIZE];
 
 	struct list_head	list;
+
+	u32			stop_rx_idx;
+	bool			stop_rx;
+	bool			start_cons;
 };
 
 static inline struct vnet_port *to_vnet_port(struct vio_driver_state *vio)
-- 
1.8.4.2
