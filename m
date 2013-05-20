From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net-next 1/2] xen-netback: split event channels feature support
Date: Tue, 21 May 2013 00:02:10 +0100
Message-ID: <1369090931-27306-2-git-send-email-wei.liu2@citrix.com>
References: <1369090931-27306-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ian.campbell@citrix.com>, <konrad.wilk@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:7824 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757094Ab3ETXCP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 May 2013 19:02:15 -0400
In-Reply-To: <1369090931-27306-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Netback and netfront only use one event channel to do TX / RX notification,
which may cause unnecessary wake-up of processing routines. This patch adds a
new feature called feature-split-event-channels to netback, enabling it to
handle TX and RX events separately.

Netback will use tx_irq to notify guest for TX completion, rx_irq for RX
notification.

If frontend doesn't support this feature, tx_irq is equal to rx_irq.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/common.h    |   11 +++--
 drivers/net/xen-netback/interface.c |   87 +++++++++++++++++++++++++++++------
 drivers/net/xen-netback/netback.c   |    7 ++-
 drivers/net/xen-netback/xenbus.c    |   40 +++++++++++++---
 4 files changed, 117 insertions(+), 28 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 6102a6c..ac82042 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -57,8 +57,12 @@ struct xenvif {
 
 	u8               fe_dev_addr[6];
 
-	/* Physical parameters of the comms window. */
-	unsigned int     irq;
+	/* When feature-split-event-channels = 0, tx_irq = rx_irq. */
+	unsigned int tx_irq;
+	unsigned int rx_irq;
+	/* Only used when feature-split-event-channels = 1 */
+	char tx_irq_name[IFNAMSIZ+4]; /* DEVNAME-tx */
+	char rx_irq_name[IFNAMSIZ+4]; /* DEVNAME-rx */
 
 	/* List of frontends to notify after a batch of frames sent. */
 	struct list_head notify_list;
@@ -113,7 +117,8 @@ struct xenvif *xenvif_alloc(struct device *parent,
 			    unsigned int handle);
 
 int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
-		   unsigned long rx_ring_ref, unsigned int evtchn);
+		   unsigned long rx_ring_ref, unsigned int tx_evtchn,
+		   unsigned int rx_evtchn);
 void xenvif_disconnect(struct xenvif *vif);
 
 void xenvif_get(struct xenvif *vif);
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 82202c2..bbed5da 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -60,7 +60,7 @@ static int xenvif_rx_schedulable(struct xenvif *vif)
 	return xenvif_schedulable(vif) && !xen_netbk_rx_ring_full(vif);
 }
 
-static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
+static irqreturn_t xenvif_tx_interrupt(int irq, void *dev_id)
 {
 	struct xenvif *vif = dev_id;
 
@@ -69,12 +69,35 @@ static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
 
 	xen_netbk_schedule_xenvif(vif);
 
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t xenvif_rx_interrupt(int irq, void *dev_id)
+{
+	struct xenvif *vif = dev_id;
+
+	if (vif->netbk == NULL)
+		return IRQ_NONE;
+
 	if (xenvif_rx_schedulable(vif))
 		netif_wake_queue(vif->dev);
 
 	return IRQ_HANDLED;
 }
 
+static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
+{
+	struct xenvif *vif = dev_id;
+
+	if (vif->netbk == NULL)
+		return IRQ_NONE;
+
+	xenvif_tx_interrupt(irq, dev_id);
+	xenvif_rx_interrupt(irq, dev_id);
+
+	return IRQ_HANDLED;
+}
+
 static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct xenvif *vif = netdev_priv(dev);
@@ -125,13 +148,15 @@ static struct net_device_stats *xenvif_get_stats(struct net_device *dev)
 static void xenvif_up(struct xenvif *vif)
 {
 	xen_netbk_add_xenvif(vif);
-	enable_irq(vif->irq);
+	enable_irq(vif->tx_irq);
+	enable_irq(vif->rx_irq);
 	xen_netbk_check_rx_xenvif(vif);
 }
 
 static void xenvif_down(struct xenvif *vif)
 {
-	disable_irq(vif->irq);
+	disable_irq(vif->tx_irq);
+	disable_irq(vif->rx_irq);
 	del_timer_sync(&vif->credit_timeout);
 	xen_netbk_deschedule_xenvif(vif);
 	xen_netbk_remove_xenvif(vif);
@@ -308,12 +333,13 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 }
 
 int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
-		   unsigned long rx_ring_ref, unsigned int evtchn)
+		   unsigned long rx_ring_ref, unsigned int tx_evtchn,
+		   unsigned int rx_evtchn)
 {
 	int err = -ENOMEM;
 
 	/* Already connected through? */
-	if (vif->irq)
+	if (vif->tx_irq)
 		return 0;
 
 	__module_get(THIS_MODULE);
@@ -322,13 +348,38 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 	if (err < 0)
 		goto err;
 
-	err = bind_interdomain_evtchn_to_irqhandler(
-		vif->domid, evtchn, xenvif_interrupt, 0,
-		vif->dev->name, vif);
-	if (err < 0)
-		goto err_unmap;
-	vif->irq = err;
-	disable_irq(vif->irq);
+	if (tx_evtchn == rx_evtchn) {
+		/* feature-split-event-channels == 0 */
+		err = bind_interdomain_evtchn_to_irqhandler(
+			vif->domid, tx_evtchn, xenvif_interrupt, 0,
+			vif->dev->name, vif);
+		if (err < 0)
+			goto err_unmap;
+		vif->tx_irq = vif->rx_irq = err;
+		disable_irq(vif->tx_irq);
+		disable_irq(vif->rx_irq);
+	} else {
+		/* feature-split-event-channels == 1 */
+		snprintf(vif->tx_irq_name, sizeof(vif->tx_irq_name),
+			 "%s-tx", vif->dev->name);
+		err = bind_interdomain_evtchn_to_irqhandler(
+			vif->domid, tx_evtchn, xenvif_tx_interrupt, 0,
+			vif->tx_irq_name, vif);
+		if (err < 0)
+			goto err_unmap;
+		vif->tx_irq = err;
+		disable_irq(vif->tx_irq);
+
+		snprintf(vif->rx_irq_name, sizeof(vif->rx_irq_name),
+			 "%s-rx", vif->dev->name);
+		err = bind_interdomain_evtchn_to_irqhandler(
+			vif->domid, rx_evtchn, xenvif_rx_interrupt, 0,
+			vif->rx_irq_name, vif);
+		if (err < 0)
+			goto err_tx_unbind;
+		vif->rx_irq = err;
+		disable_irq(vif->rx_irq);
+	}
 
 	xenvif_get(vif);
 
@@ -342,6 +393,9 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 	rtnl_unlock();
 
 	return 0;
+err_tx_unbind:
+	unbind_from_irqhandler(vif->tx_irq, vif);
+	vif->tx_irq = 0;
 err_unmap:
 	xen_netbk_unmap_frontend_rings(vif);
 err:
@@ -375,8 +429,13 @@ void xenvif_disconnect(struct xenvif *vif)
 	atomic_dec(&vif->refcnt);
 	wait_event(vif->waiting_to_free, atomic_read(&vif->refcnt) == 0);
 
-	if (vif->irq) {
-		unbind_from_irqhandler(vif->irq, vif);
+	if (vif->tx_irq) {
+		if (vif->tx_irq == vif->rx_irq)
+			unbind_from_irqhandler(vif->tx_irq, vif);
+		else {
+			unbind_from_irqhandler(vif->tx_irq, vif);
+			unbind_from_irqhandler(vif->rx_irq, vif);
+		}
 		/* vif->irq is valid, we had a module_get in
 		 * xenvif_connect.
 		 */
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 2d9477f..5f858bc 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -662,7 +662,7 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
 {
 	struct xenvif *vif = NULL, *tmp;
 	s8 status;
-	u16 irq, flags;
+	u16 flags;
 	struct xen_netif_rx_response *resp;
 	struct sk_buff_head rxq;
 	struct sk_buff *skb;
@@ -771,7 +771,6 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
 					 sco->meta_slots_used);
 
 		RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&vif->rx, ret);
-		irq = vif->irq;
 		if (ret && list_empty(&vif->notify_list))
 			list_add_tail(&vif->notify_list, &notify);
 
@@ -783,7 +782,7 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
 	}
 
 	list_for_each_entry_safe(vif, tmp, &notify, notify_list) {
-		notify_remote_via_irq(vif->irq);
+		notify_remote_via_irq(vif->rx_irq);
 		list_del_init(&vif->notify_list);
 	}
 
@@ -1762,7 +1761,7 @@ static void make_tx_response(struct xenvif *vif,
 	vif->tx.rsp_prod_pvt = ++i;
 	RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&vif->tx, notify);
 	if (notify)
-		notify_remote_via_irq(vif->irq);
+		notify_remote_via_irq(vif->tx_irq);
 }
 
 static struct xen_netif_rx_response *make_rx_response(struct xenvif *vif,
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index d230c14..79b40db 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -114,6 +114,15 @@ static int netback_probe(struct xenbus_device *dev,
 			goto abort_transaction;
 		}
 
+		/* Split event channels support */
+		err = xenbus_printf(xbt, dev->nodename,
+				"feature-split-event-channels",
+				"%u", 1);
+		if (err) {
+			message = "writing feature-split-event-channels";
+			goto abort_transaction;
+		}
+
 		err = xenbus_transaction_end(xbt, 0);
 	} while (err == -EAGAIN);
 
@@ -393,21 +402,36 @@ static int connect_rings(struct backend_info *be)
 	struct xenvif *vif = be->vif;
 	struct xenbus_device *dev = be->dev;
 	unsigned long tx_ring_ref, rx_ring_ref;
-	unsigned int evtchn, rx_copy;
+	unsigned int tx_evtchn, rx_evtchn, rx_copy;
 	int err;
 	int val;
 
 	err = xenbus_gather(XBT_NIL, dev->otherend,
 			    "tx-ring-ref", "%lu", &tx_ring_ref,
-			    "rx-ring-ref", "%lu", &rx_ring_ref,
-			    "event-channel", "%u", &evtchn, NULL);
+			    "rx-ring-ref", "%lu", &rx_ring_ref, NULL);
 	if (err) {
 		xenbus_dev_fatal(dev, err,
-				 "reading %s/ring-ref and event-channel",
+				 "reading %s/ring-ref",
 				 dev->otherend);
 		return err;
 	}
 
+	/* Try split event channels first, then single event channel. */
+	err = xenbus_gather(XBT_NIL, dev->otherend,
+			    "event-channel-tx", "%u", &tx_evtchn,
+			    "event-channel-rx", "%u", &rx_evtchn, NULL);
+	if (err) {
+		err = xenbus_scanf(XBT_NIL, dev->otherend,
+				   "event-channel", "%u", &tx_evtchn);
+		if (err) {
+			xenbus_dev_fatal(dev, err,
+					 "reading %s/event-channel(-tx/rx)",
+					 dev->otherend);
+			return err;
+		}
+		rx_evtchn = tx_evtchn;
+	}
+
 	err = xenbus_scanf(XBT_NIL, dev->otherend, "request-rx-copy", "%u",
 			   &rx_copy);
 	if (err == -ENOENT) {
@@ -454,11 +478,13 @@ static int connect_rings(struct backend_info *be)
 	vif->csum = !val;
 
 	/* Map the shared frame, irq etc. */
-	err = xenvif_connect(vif, tx_ring_ref, rx_ring_ref, evtchn);
+	err = xenvif_connect(vif, tx_ring_ref, rx_ring_ref,
+			     tx_evtchn, rx_evtchn);
 	if (err) {
 		xenbus_dev_fatal(dev, err,
-				 "mapping shared-frames %lu/%lu port %u",
-				 tx_ring_ref, rx_ring_ref, evtchn);
+				 "mapping shared-frames %lu/%lu port tx %u rx %u",
+				 tx_ring_ref, rx_ring_ref,
+				 tx_evtchn, rx_evtchn);
 		return err;
 	}
 	return 0;
-- 
1.7.10.4
