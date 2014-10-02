From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 0/2] sunvnet: Packet processing in non-interrupt
 context.
Date: Thu, 2 Oct 2014 16:12:03 -0400
Message-ID: <20141002201203.GA6001@oracle.com>
References: <542C5C37.1040409@oracle.com>
 <20141001.161508.1823792090990427608.davem@davemloft.net>
 <20141001202315.GN17706@oracle.com>
 <20141001.162529.2246298941833907545.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44244 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751971AbaJBUMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 16:12:12 -0400
Content-Disposition: inline
In-Reply-To: <20141001.162529.2246298941833907545.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (10/01/14 16:25), David Miller wrote:
> 
> The limit is by default 64 packets, it won't matter.
> 
> I think you're overplaying the things that block use of NAPI, how
> about implementing it properly, using netif_gso_receive() and proper
> RCU accesses, and coming back with some real performance measurements?

I hope I did not give the impression that I've cut some corners and
did not do adequate testing to get here, because that is not the case.

I dont know what s/netif_skb_receive/napi_gro_receive has to do with it -  
but I resurrected my napi prototype, caught up with Jumbo MTU patc,
and replaced netif_receive_skb with napi_gro_receive.

The patch is attached to the end of this email. "Real performance
measurements" are below.

Afaict, the patch is quite "proper" - I was following
   http://www.linuxfoundation.org/collaborate/workgroups/networking/napi -
and the patch even goes to a lot of trouble to avoid sending needless
ldc messages arising from some napi-imposed budget. Here's the perf
data. Remember that packet size is 1500 bytes, so, e.g., 2 Gbps is approx
167k pps. Also the baseline perf today (without napi) is 1 - 1.3 Gbps.

     budget      iperf throughput
      64           336 Mbps
     128           556 Mbps
     512           398 Mbps

If I over-budget to 2048, and force my vnet_poll() to lie by returning
`budget', I can get an iperf throughput of approx 2.2 - 2.3 Gbps
for 1500 byte packets i.e., 167k pps. Yes, I violate NAPI rules in doing
this, and from reading the code, this forces me to a non-polling, 
pure-softirq mode. But this is also the best number I can get.

And as for mpstat output it comes out wit 100% of the softirqs on
2 cpus- something like this:

CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle
all    0.00    0.00    0.57    0.06    0.00   12.67    0.00    0.00   86.70
0    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
1    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
2    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
3    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
4    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
5    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
6    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
7    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
8    0.00    0.00    1.00    0.00    0.00    0.00    0.00    0.00   99.00
9    0.00    0.00    0.00    0.00    0.00  100.00    0.00    0.00    0.00
10    0.00    0.00    1.98    0.00    0.00    0.00    0.00    0.00   98.02
11    0.00    0.00    0.99    0.00    0.00    0.00    0.00    0.00   99.01
12    0.00    0.00    0.00    0.00    0.00  100.00    0.00    0.00    0.00
13    0.00    0.00    3.00    0.00    0.00    0.00    0.00    0.00   97.00
14    0.00    0.00    2.56    0.00    0.00    0.00    0.00    0.00   97.44
15    0.00    0.00    1.00    1.00    0.00    0.00    0.00    0.00   98.00

Whereas with the workq, the load was spread nicely across multiple cpus.
I can share "Real performance data" for that as well, if you are curious.

Some differences between sunvnet-ldc and the typical network driver
that might be causing the perf drop here:

- The biggest benefit of NAPI is that it permits the reading of multiple
  packets in the context of a single interrupt, but the ldc/sunvnet infra
  already does that anyway. So the extra polling offered by NAPI does
  not have a significant benefit for my test- I can just as easily
  achieve load-spreading and fare-share in a non-interrupt context with
  a workq/kthread?

- But the VDC driver is also different from the typical driver in the
  "STOPPED" message- usually drivers only get signalled when the producer
  publishes data, the consumer does not send any signal back to producer,
  though the VDC driver does the latter. I've had to add more state-tracking
  code to get around this. 
 
Note that I am *not* attempting to fix the vnet race condition here-
that one is a pre-existing condition that I caught by merely reading
the code (I can easily look the other way), and my patch does not make
it worse.  Let's discuss that one later.  

NAPI Patch follows. Please tell me what's improper about it.

---------------------------------------------------------------------

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 1539672..da05d68 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -33,6 +33,9 @@
 #define DRV_MODULE_VERSION	"1.0"
 #define DRV_MODULE_RELDATE	"June 25, 2007"
 
+/* #define	VNET_BUDGET	2048 */	 /* see comments in vnet_poll() */
+#define	VNET_BUDGET	64	 /*  typical budget */
+
 static char version[] =
 	DRV_MODULE_NAME ".c:v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 MODULE_AUTHOR("David S. Miller (davem@davemloft.net)");
@@ -274,6 +277,7 @@ static struct sk_buff *alloc_and_align_skb(struct net_device *dev,
 	return skb;
 }
 
+/* reads in exactly one sk_buff */
 static int vnet_rx_one(struct vnet_port *port, unsigned int len,
 		       struct ldc_trans_cookie *cookies, int ncookies)
 {
@@ -311,9 +315,7 @@ static int vnet_rx_one(struct vnet_port *port, unsigned int len,
 
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += len;
-
-	netif_rx(skb);
-
+	napi_gro_receive(&port->napi, skb);
 	return 0;
 
 out_free_skb:
@@ -444,6 +446,7 @@ static int vnet_walk_rx_one(struct vnet_port *port,
 	       desc->cookies[0].cookie_addr,
 	       desc->cookies[0].cookie_size);
 
+	/* read in one packet */
 	err = vnet_rx_one(port, desc->size, desc->cookies, desc->ncookies);
 	if (err == -ECONNRESET)
 		return err;
@@ -456,10 +459,11 @@ static int vnet_walk_rx_one(struct vnet_port *port,
 }
 
 static int vnet_walk_rx(struct vnet_port *port, struct vio_dring_state *dr,
-			u32 start, u32 end)
+			u32 start, u32 end, int *npkts, int budget)
 {
 	struct vio_driver_state *vio = &port->vio;
 	int ack_start = -1, ack_end = -1;
+	int send_ack = 1;
 
 	end = (end == (u32) -1) ? prev_idx(start, dr) : next_idx(end, dr);
 
@@ -471,6 +475,7 @@ static int vnet_walk_rx(struct vnet_port *port, struct vio_dring_state *dr,
 			return err;
 		if (err != 0)
 			break;
+		(*npkts)++;
 		if (ack_start == -1)
 			ack_start = start;
 		ack_end = start;
@@ -482,13 +487,28 @@ static int vnet_walk_rx(struct vnet_port *port, struct vio_dring_state *dr,
 				return err;
 			ack_start = -1;
 		}
+		if ((*npkts) >= budget ) {
+			send_ack = 0;
+			break;
+		}
 	}
 	if (unlikely(ack_start == -1))
 		ack_start = ack_end = prev_idx(start, dr);
-	return vnet_send_ack(port, dr, ack_start, ack_end, VIO_DRING_STOPPED);
+	if (send_ack) {
+		int ret;
+		port->napi_resume = false;
+		ret = vnet_send_ack(port, dr, ack_start, ack_end,
+				     VIO_DRING_STOPPED);
+		return ret;
+	} else  {
+		port->napi_resume = true;
+		port->napi_stop_idx = ack_end;
+		return (56);
+	}
 }
 
-static int vnet_rx(struct vnet_port *port, void *msgbuf)
+static int vnet_rx(struct vnet_port *port, void *msgbuf, int *npkts,
+		   int budget)
 {
 	struct vio_dring_data *pkt = msgbuf;
 	struct vio_dring_state *dr = &port->vio.drings[VIO_DRIVER_RX_RING];
@@ -505,11 +525,13 @@ static int vnet_rx(struct vnet_port *port, void *msgbuf)
 		return 0;
 	}
 
-	dr->rcv_nxt++;
+	if (!port->napi_resume)
+		dr->rcv_nxt++;
 
 	/* XXX Validate pkt->start_idx and pkt->end_idx XXX */
 
-	return vnet_walk_rx(port, dr, pkt->start_idx, pkt->end_idx);
+	return vnet_walk_rx(port, dr, pkt->start_idx, pkt->end_idx,
+			    npkts, budget);
 }
 
 static int idx_is_pending(struct vio_dring_state *dr, u32 end)
@@ -534,7 +556,10 @@ static int vnet_ack(struct vnet_port *port, void *msgbuf)
 	struct net_device *dev;
 	struct vnet *vp;
 	u32 end;
+	unsigned long flags;
 	struct vio_net_desc *desc;
+	bool need_trigger = false;
+
 	if (unlikely(pkt->tag.stype_env != VIO_DRING_DATA))
 		return 0;
 
@@ -545,21 +570,17 @@ static int vnet_ack(struct vnet_port *port, void *msgbuf)
 	/* sync for race conditions with vnet_start_xmit() and tell xmit it
 	 * is time to send a trigger.
 	 */
+	spin_lock_irqsave(&port->vio.lock, flags);
 	dr->cons = next_idx(end, dr);
 	desc = vio_dring_entry(dr, dr->cons);
-	if (desc->hdr.state == VIO_DESC_READY && port->start_cons) {
-		/* vnet_start_xmit() just populated this dring but missed
-		 * sending the "start" LDC message to the consumer.
-		 * Send a "start" trigger on its behalf.
-		 */
-		if (__vnet_tx_trigger(port, dr->cons) > 0)
-			port->start_cons = false;
-		else
-			port->start_cons = true;
-	} else {
-		port->start_cons = true;
-	}
+	if (desc->hdr.state == VIO_DESC_READY && !port->start_cons)
+		need_trigger = true;
+	else
+		port->start_cons = true; /* vnet_start_xmit will send trigger */
+	spin_unlock_irqrestore(&port->vio.lock, flags);
 
+	if (need_trigger && __vnet_tx_trigger(port, dr->cons) <= 0)
+		port->start_cons = true;
 
 	vp = port->vp;
 	dev = vp->dev;
@@ -617,33 +638,12 @@ static void maybe_tx_wakeup(unsigned long param)
 	netif_tx_unlock(dev);
 }
 
-static void vnet_event(void *arg, int event)
+static int vnet_event_napi(struct vnet_port *port, int budget)
 {
-	struct vnet_port *port = arg;
 	struct vio_driver_state *vio = &port->vio;
-	unsigned long flags;
 	int tx_wakeup, err;
 
-	spin_lock_irqsave(&vio->lock, flags);
-
-	if (unlikely(event == LDC_EVENT_RESET ||
-		     event == LDC_EVENT_UP)) {
-		vio_link_state_change(vio, event);
-		spin_unlock_irqrestore(&vio->lock, flags);
-
-		if (event == LDC_EVENT_RESET) {
-			port->rmtu = 0;
-			vio_port_up(vio);
-		}
-		return;
-	}
-
-	if (unlikely(event != LDC_EVENT_DATA_READY)) {
-		pr_warn("Unexpected LDC event %d\n", event);
-		spin_unlock_irqrestore(&vio->lock, flags);
-		return;
-	}
-
+	int npkts = 0;
 	tx_wakeup = err = 0;
 	while (1) {
 		union {
@@ -651,6 +651,20 @@ static void vnet_event(void *arg, int event)
 			u64 raw[8];
 		} msgbuf;
 
+		if (port->napi_resume) {
+			struct vio_dring_data *pkt =
+				(struct vio_dring_data *)&msgbuf;
+			struct vio_dring_state *dr =
+				&port->vio.drings[VIO_DRIVER_RX_RING];
+
+			pkt->tag.type = VIO_TYPE_DATA;
+			pkt->tag.stype = VIO_SUBTYPE_INFO;
+			pkt->tag.stype_env = VIO_DRING_DATA;
+			pkt->seq = dr->rcv_nxt;
+			pkt->start_idx = next_idx(port->napi_stop_idx, dr);
+			pkt->end_idx = -1;
+			goto napi_resume;
+		}
 		err = ldc_read(vio->lp, &msgbuf, sizeof(msgbuf));
 		if (unlikely(err < 0)) {
 			if (err == -ECONNRESET)
@@ -667,10 +681,12 @@ static void vnet_event(void *arg, int event)
 		err = vio_validate_sid(vio, &msgbuf.tag);
 		if (err < 0)
 			break;
-
+napi_resume:
 		if (likely(msgbuf.tag.type == VIO_TYPE_DATA)) {
 			if (msgbuf.tag.stype == VIO_SUBTYPE_INFO) {
-				err = vnet_rx(port, &msgbuf);
+				err = vnet_rx(port, &msgbuf, &npkts, budget);
+				if (npkts >= budget || npkts == 0)
+					break;
 			} else if (msgbuf.tag.stype == VIO_SUBTYPE_ACK) {
 				err = vnet_ack(port, &msgbuf);
 				if (err > 0)
@@ -691,15 +707,54 @@ static void vnet_event(void *arg, int event)
 		if (err == -ECONNRESET)
 			break;
 	}
-	spin_unlock(&vio->lock);
-	/* Kick off a tasklet to wake the queue.  We cannot call
-	 * maybe_tx_wakeup directly here because we could deadlock on
-	 * netif_tx_lock() with dev_watchdog()
-	 */
 	if (unlikely(tx_wakeup && err != -ECONNRESET))
 		tasklet_schedule(&port->vp->vnet_tx_wakeup);
+	return npkts;
+}
 
+static int vnet_poll(struct napi_struct *napi, int budget)
+{
+	struct vnet_port *port = container_of(napi, struct vnet_port, napi);
+	struct vio_driver_state *vio = &port->vio;
+	int processed = vnet_event_napi(port, budget);
+
+	if (processed < budget) {
+		napi_complete(napi);
+		napi_reschedule(napi);
+		vio_set_intr(vio->vdev->rx_ino, HV_INTR_ENABLED);
+	}
+	/* return budget; */ /* liar! but better throughput! */
+	return processed;
+}
+
+static void vnet_event(void *arg, int event)
+{
+	struct vnet_port *port = arg;
+	struct vio_driver_state *vio = &port->vio;
+	unsigned long flags;
+
+	spin_lock_irqsave(&vio->lock, flags);
+
+	if (unlikely(event == LDC_EVENT_RESET ||
+		     event == LDC_EVENT_UP)) {
+		vio_link_state_change(vio, event);
+		spin_unlock_irqrestore(&vio->lock, flags);
+
+		if (event == LDC_EVENT_RESET)
+			vio_port_up(vio);
+		return;
+	}
+
+	if (unlikely(event != LDC_EVENT_DATA_READY)) {
+		pr_warning("Unexpected LDC event %d\n", event);
+		spin_unlock_irqrestore(&vio->lock, flags);
+		return;
+	}
+
+	spin_unlock(&vio->lock);
 	local_irq_restore(flags);
+	vio_set_intr(vio->vdev->rx_ino, HV_INTR_DISABLED);
+	napi_schedule(&port->napi);
 }
 
 static int __vnet_tx_trigger(struct vnet_port *port, u32 start)
@@ -1342,6 +1397,22 @@ err_out:
 	return err;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void vnet_poll_controller(struct net_device *dev)
+{
+	struct vnet *vp = netdev_priv(dev);
+	struct vnet_port *port;
+	unsigned long flags;
+
+	spin_lock_irqsave(&vp->lock, flags);
+	if (!list_empty(&vp->port_list)) {
+		port = list_entry(vp->port_list.next, struct vnet_port, list);
+		napi_schedule(&port->napi);
+	}
+	spin_unlock_irqrestore(&vp->lock, flags);
+
+}
+#endif
 static LIST_HEAD(vnet_list);
 static DEFINE_MUTEX(vnet_list_mutex);
 
@@ -1354,6 +1425,9 @@ static const struct net_device_ops vnet_ops = {
 	.ndo_tx_timeout		= vnet_tx_timeout,
 	.ndo_change_mtu		= vnet_change_mtu,
 	.ndo_start_xmit		= vnet_start_xmit,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= vnet_poll_controller,
+#endif
 };
 
 static struct vnet *vnet_new(const u64 *local_mac)
@@ -1536,6 +1610,9 @@ static int vnet_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 	if (err)
 		goto err_out_free_port;
 
+	netif_napi_add(port->vp->dev, &port->napi, vnet_poll, VNET_BUDGET);
+	napi_enable(&port->napi);
+
 	err = vnet_port_alloc_tx_bufs(port);
 	if (err)
 		goto err_out_free_ldc;
@@ -1592,6 +1669,8 @@ static int vnet_port_remove(struct vio_dev *vdev)
 		del_timer_sync(&port->vio.timer);
 		del_timer_sync(&port->clean_timer);
 
+		napi_disable(&port->napi);
+
 		spin_lock_irqsave(&vp->lock, flags);
 		list_del(&port->list);
 		hlist_del(&port->hash);
                hlist_del(&port->hash);
diff --git a/drivers/net/ethernet/sun/sunvnet.h b/drivers/net/ethernet/sun/sunvnet.h
index c911045..3c745d0 100644
--- a/drivers/net/ethernet/sun/sunvnet.h
+++ b/drivers/net/ethernet/sun/sunvnet.h
@@ -56,6 +56,10 @@ struct vnet_port {
        struct timer_list       clean_timer;

        u64                     rmtu;
+
+       struct napi_struct      napi;
+       u32                     napi_stop_idx;
+       bool                    napi_resume;
 };

 static inline struct vnet_port *to_vnet_port(struct vio_driver_state *vio)
