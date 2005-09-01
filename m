From: Michael Ellerman <michael@ellerman.id.au>
Subject: [PATCH 7/18] iseries_veth: Only call dma_unmap_single() if
	dma_map_single() succeeded
Date: Thu,  1 Sep 2005 11:29:07 +1000 (EST)
Message-ID: <20050901012907.A531B681F5@ozlabs.org>
References: <1125538127.859382.875909607846.qpush@concordia>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc64-dev@ozlabs.org
Return-path: <linuxppc64-dev-bounces@ozlabs.org>
To: <jgarzik@pobox.com>
In-Reply-To: <1125538127.859382.875909607846.qpush@concordia>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces@ozlabs.org
Errors-To: linuxppc64-dev-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

The iseries_veth driver unconditionally calls dma_unmap_single() even
when the corresponding dma_map_single() may have failed.

Rework the code a bit to keep the return value from dma_unmap_single()
around, and then check if it's a dma_mapping_error() before we do
the dma_unmap_single().

Signed-off-by: Michael Ellerman <michael@ellerman.id.au>
---

 drivers/net/iseries_veth.c |   17 ++++++++---------
 1 files changed, 8 insertions(+), 9 deletions(-)

Index: veth-dev2/drivers/net/iseries_veth.c
===================================================================
--- veth-dev2.orig/drivers/net/iseries_veth.c
+++ veth-dev2/drivers/net/iseries_veth.c
@@ -931,7 +931,6 @@ static int veth_transmit_to_one(struct s
 	struct veth_lpar_connection *cnx = veth_cnx[rlp];
 	struct veth_port *port = (struct veth_port *) dev->priv;
 	HvLpEvent_Rc rc;
-	u32 dma_address, dma_length;
 	struct veth_msg *msg = NULL;
 	int err = 0;
 	unsigned long flags;
@@ -959,20 +958,19 @@ static int veth_transmit_to_one(struct s
 
 	msg->in_use = 1;
 
-	dma_length = skb->len;
-	dma_address = dma_map_single(port->dev, skb->data,
-				     dma_length, DMA_TO_DEVICE);
+	msg->data.addr[0] = dma_map_single(port->dev, skb->data,
+				skb->len, DMA_TO_DEVICE);
 
-	if (dma_mapping_error(dma_address))
+	if (dma_mapping_error(msg->data.addr[0]))
 		goto recycle_and_drop;
 
 	/* Is it really necessary to check the length and address
 	 * fields of the first entry here? */
 	msg->skb = skb;
 	msg->dev = port->dev;
-	msg->data.addr[0] = dma_address;
-	msg->data.len[0] = dma_length;
+	msg->data.len[0] = skb->len;
 	msg->data.eofmask = 1 << VETH_EOF_SHIFT;
+
 	rc = veth_signaldata(cnx, VethEventTypeFrames, msg->token, &msg->data);
 
 	if (rc != HvLpEvent_Rc_Good)
@@ -1076,8 +1074,9 @@ static void veth_recycle_msg(struct veth
 		dma_address = msg->data.addr[0];
 		dma_length = msg->data.len[0];
 
-		dma_unmap_single(msg->dev, dma_address, dma_length,
-				 DMA_TO_DEVICE);
+		if (!dma_mapping_error(dma_address))
+			dma_unmap_single(msg->dev, dma_address, dma_length,
+					DMA_TO_DEVICE);
 
 		if (msg->skb) {
 			dev_kfree_skb_any(msg->skb);
