From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCH 1/2 net-next] sunvnet: free pending tx buffers before clearing
 ring data
Date: Mon, 26 Jan 2015 15:54:35 -0500
Message-ID: <54C6A98B.40406@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25432 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757013AbbAZUyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 15:54:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 This patch moves the clearing of ring data in vnet_port_free_tx_bufs to after
 the freeing of pending buffers in the ring. Otherwise, this can result in
 dereferencing a NULL pointer.

Reported-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Signed-off-by: David L Stevens <david.stevens@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index b5a1d3d..fe044f3 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -1637,16 +1637,9 @@ static void vnet_port_free_tx_bufs(struct vnet_port *port)
 	int i;
 
 	dr = &port->vio.drings[VIO_DRIVER_TX_RING];
-	if (dr->base) {
-		ldc_free_exp_dring(port->vio.lp, dr->base,
-				   (dr->entry_size * dr->num_entries),
-				   dr->cookies, dr->ncookies);
-		dr->base = NULL;
-		dr->entry_size = 0;
-		dr->num_entries = 0;
-		dr->pending = 0;
-		dr->ncookies = 0;
-	}
+
+	if (dr->base == NULL)
+		return;
 
 	for (i = 0; i < VNET_TX_RING_SIZE; i++) {
 		struct vio_net_desc *d;
@@ -1666,6 +1659,14 @@ static void vnet_port_free_tx_bufs(struct vnet_port *port)
 		port->tx_bufs[i].skb = NULL;
 		d->hdr.state = VIO_DESC_FREE;
 	}
+	ldc_free_exp_dring(port->vio.lp, dr->base,
+			   (dr->entry_size * dr->num_entries),
+			   dr->cookies, dr->ncookies);
+	dr->base = NULL;
+	dr->entry_size = 0;
+	dr->num_entries = 0;
+	dr->pending = 0;
+	dr->ncookies = 0;
 }
 
 static int vnet_port_alloc_tx_ring(struct vnet_port *port)
-- 
1.7.1
