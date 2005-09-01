From: Michael Ellerman <michael@ellerman.id.au>
Subject: [PATCH 6/18] iseries_veth: Replace lock-protected atomic with an
	ordinary variable
Date: Thu,  1 Sep 2005 11:29:06 +1000 (EST)
Message-ID: <20050901012906.9EF9568206@ozlabs.org>
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

The iseries_veth driver uses atomic ops to manipulate the in_use field of
one of its per-connection structures. However all references to the
flag occur while the connection's lock is held, so the atomic ops aren't
necessary.

Signed-off-by: Michael Ellerman <michael@ellerman.id.au>
---

 drivers/net/iseries_veth.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

Index: veth-dev2/drivers/net/iseries_veth.c
===================================================================
--- veth-dev2.orig/drivers/net/iseries_veth.c
+++ veth-dev2/drivers/net/iseries_veth.c
@@ -117,7 +117,7 @@ struct veth_msg {
 	struct veth_msg *next;
 	struct VethFramesData data;
 	int token;
-	unsigned long in_use;
+	int in_use;
 	struct sk_buff *skb;
 	struct device *dev;
 };
@@ -957,6 +957,8 @@ static int veth_transmit_to_one(struct s
 		goto drop;
 	}
 
+	msg->in_use = 1;
+
 	dma_length = skb->len;
 	dma_address = dma_map_single(port->dev, skb->data,
 				     dma_length, DMA_TO_DEVICE);
@@ -971,7 +973,6 @@ static int veth_transmit_to_one(struct s
 	msg->data.addr[0] = dma_address;
 	msg->data.len[0] = dma_length;
 	msg->data.eofmask = 1 << VETH_EOF_SHIFT;
-	set_bit(0, &(msg->in_use));
 	rc = veth_signaldata(cnx, VethEventTypeFrames, msg->token, &msg->data);
 
 	if (rc != HvLpEvent_Rc_Good)
@@ -981,10 +982,8 @@ static int veth_transmit_to_one(struct s
 	return 0;
 
  recycle_and_drop:
+	/* we free the skb below, so tell veth_recycle_msg() not to. */
 	msg->skb = NULL;
-	/* need to set in use to make veth_recycle_msg in case this
-	 * was a mapping failure */
-	set_bit(0, &msg->in_use);
 	veth_recycle_msg(cnx, msg);
  drop:
 	port->stats.tx_errors++;
@@ -1066,12 +1065,14 @@ static int veth_start_xmit(struct sk_buf
 	return 0;
 }
 
+/* You must hold the connection's lock when you call this function. */
 static void veth_recycle_msg(struct veth_lpar_connection *cnx,
 			     struct veth_msg *msg)
 {
 	u32 dma_address, dma_length;
 
-	if (test_and_clear_bit(0, &msg->in_use)) {
+	if (msg->in_use) {
+		msg->in_use = 0;
 		dma_address = msg->data.addr[0];
 		dma_length = msg->data.len[0];
