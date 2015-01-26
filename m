From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCH 2/2 net-next] sunvnet: improve error handling when a remote
 crashes
Date: Mon, 26 Jan 2015 15:54:27 -0500
Message-ID: <54C6A982.7030908@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44111 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756170AbbAZUyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 15:54:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a remote machine crashes while there are pending transmit buffers, the
sunvnet driver reallocates the ring descriptors giving us enries that have
state VIO_DESC_FREE but also an allocated skb. This results in a BUG_ON()
call when the remote reboots and we reach that point in the ring.

This patch:

1) clears pending tx packets in the ring on port reset
2) changes a BUG_ON() to a pr_warn() when a remote host has given us an invalid
	descriptor state
3) collapses multiple active buffer frees in a ring to a single message per
	ring and adds the device name and remote MAC address

This fixes the particular problem of not cleaning up pending buffers on a
reset, but also prevents us from crashing if the remote handles descriptors
out of order or sets an unexpected state for a descriptor.

Signed-off-by: David L Stevens <david.stevens@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c |   62 +++++++++++++++++++----------------
 1 files changed, 34 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index fe044f3..2b719cc 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -50,6 +50,7 @@ MODULE_VERSION(DRV_MODULE_VERSION);
 #define	VNET_MAX_RETRIES	10
 
 static int __vnet_tx_trigger(struct vnet_port *port, u32 start);
+static void vnet_port_reset(struct vnet_port *port);
 
 /* Ordered from largest major to lowest */
 static struct vio_version vnet_versions[] = {
@@ -736,9 +737,7 @@ ldc_ctrl:
 		vio_link_state_change(vio, event);
 
 		if (event == LDC_EVENT_RESET) {
-			port->rmtu = 0;
-			port->tso = true;
-			port->tsolen = 0;
+			vnet_port_reset(port);
 			vio_port_up(vio);
 		}
 		port->rx_event = 0;
@@ -934,36 +933,36 @@ static struct sk_buff *vnet_clean_tx_ring(struct vnet_port *port,
 
 	*pending = 0;
 
-	txi = dr->prod-1;
-	if (txi < 0)
-		txi = VNET_TX_RING_SIZE-1;
-
+	txi = dr->prod;
 	for (i = 0; i < VNET_TX_RING_SIZE; ++i) {
 		struct vio_net_desc *d;
 
-		d = vio_dring_entry(dr, txi);
-
-		if (d->hdr.state == VIO_DESC_DONE) {
-			if (port->tx_bufs[txi].skb) {
-				BUG_ON(port->tx_bufs[txi].skb->next);
+		--txi;
+		if (txi < 0)
+			txi = VNET_TX_RING_SIZE-1;
 
-				port->tx_bufs[txi].skb->next = skb;
-				skb = port->tx_bufs[txi].skb;
-				port->tx_bufs[txi].skb = NULL;
+		d = vio_dring_entry(dr, txi);
 
-				ldc_unmap(port->vio.lp,
-					  port->tx_bufs[txi].cookies,
-					  port->tx_bufs[txi].ncookies);
-			}
-			d->hdr.state = VIO_DESC_FREE;
-		} else if (d->hdr.state == VIO_DESC_READY) {
+		if (d->hdr.state == VIO_DESC_READY) {
 			(*pending)++;
-		} else if (d->hdr.state == VIO_DESC_FREE) {
-			break;
+			continue;
 		}
-		--txi;
-		if (txi < 0)
-			txi = VNET_TX_RING_SIZE-1;
+		if (port->tx_bufs[txi].skb) {
+			if (d->hdr.state != VIO_DESC_DONE)
+				pr_notice("invalid ring buffer state %d\n",
+					  d->hdr.state);
+			BUG_ON(port->tx_bufs[txi].skb->next);
+
+			port->tx_bufs[txi].skb->next = skb;
+			skb = port->tx_bufs[txi].skb;
+			port->tx_bufs[txi].skb = NULL;
+
+			ldc_unmap(port->vio.lp,
+				  port->tx_bufs[txi].cookies,
+				  port->tx_bufs[txi].ncookies);
+		} else if (d->hdr.state == VIO_DESC_FREE)
+			break;
+		d->hdr.state = VIO_DESC_FREE;
 	}
 	return skb;
 }
@@ -1649,8 +1648,6 @@ static void vnet_port_free_tx_bufs(struct vnet_port *port)
 			continue;
 
 		d = vio_dring_entry(dr, i);
-		if (d->hdr.state == VIO_DESC_READY)
-			pr_warn("active transmit buffers freed\n");
 
 		ldc_unmap(port->vio.lp,
 			  port->tx_bufs[i].cookies,
@@ -1669,6 +1666,15 @@ static void vnet_port_free_tx_bufs(struct vnet_port *port)
 	dr->ncookies = 0;
 }
 
+static void vnet_port_reset(struct vnet_port *port)
+{
+	del_timer(&port->clean_timer);
+	vnet_port_free_tx_bufs(port);
+	port->rmtu = 0;
+	port->tso = true;
+	port->tsolen = 0;
+}
+
 static int vnet_port_alloc_tx_ring(struct vnet_port *port)
 {
 	struct vio_dring_state *dr;
-- 
1.7.1
