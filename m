From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCH net-next 1/6] sunvnet: rename vnet_port_alloc_tx_bufs and
 move after version negotiation
Date: Tue, 02 Dec 2014 15:30:55 -0500
Message-ID: <547E217F.50305@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:31008 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932844AbaLBUbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 15:31:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the name of vnet_port_alloc_tx_bufs to
vnet_port_alloc_tx_ring, since there are no buffer allocations after
transmit zero copy support was added. This patch also moves the ring
allocation to after VIO version negotiation to allow for
different-sized descriptors in later VIO versions.

Signed-off-by: David L Stevens <david.stevens@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index a556eba..62823fa 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -73,13 +73,19 @@ static int vnet_handle_unknown(struct vnet_port *port, void *arg)
 	return -ECONNRESET;
 }
 
+static int vnet_port_alloc_tx_ring(struct vnet_port *port);
+
 static int vnet_send_attr(struct vio_driver_state *vio)
 {
 	struct vnet_port *port = to_vnet_port(vio);
 	struct net_device *dev = port->vp->dev;
 	struct vio_net_attr_info pkt;
 	int framelen = ETH_FRAME_LEN;
-	int i;
+	int i, err;
+
+	err = vnet_port_alloc_tx_ring(to_vnet_port(vio));
+	if (err)
+		return err;
 
 	memset(&pkt, 0, sizeof(pkt));
 	pkt.tag.type = VIO_TYPE_CTRL;
@@ -1361,7 +1367,7 @@ static void vnet_port_free_tx_bufs(struct vnet_port *port)
 	}
 }
 
-static int vnet_port_alloc_tx_bufs(struct vnet_port *port)
+static int vnet_port_alloc_tx_ring(struct vnet_port *port)
 {
 	struct vio_dring_state *dr;
 	unsigned long len;
@@ -1640,10 +1646,6 @@ static int vnet_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 
 	netif_napi_add(port->vp->dev, &port->napi, vnet_poll, NAPI_POLL_WEIGHT);
 
-	err = vnet_port_alloc_tx_bufs(port);
-	if (err)
-		goto err_out_free_ldc;
-
 	INIT_HLIST_NODE(&port->hash);
 	INIT_LIST_HEAD(&port->list);
 
@@ -1677,10 +1679,6 @@ static int vnet_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 
 	return 0;
 
-err_out_free_ldc:
-	netif_napi_del(&port->napi);
-	vio_ldc_free(&port->vio);
-
 err_out_free_port:
 	kfree(port);
 
-- 
1.7.1
