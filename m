From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] mlx4: exploit skb->xmit_more to conditionally send
 doorbell
Date: Thu, 25 Sep 2014 07:17:49 -0700
Message-ID: <1411654669.16953.17.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:43590 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753040AbaIYORu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 10:17:50 -0400
Received: by mail-pd0-f182.google.com with SMTP id p10so10643974pdj.13
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 07:17:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

skb->xmit_more tells us if another skb is coming next.

We need to send doorbell when : xmit_more is not set,
or txqueue is stopped (preventing next skb to come immediately)

Tested with a modified pktgen version, I got a 40% increase of
throughput.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |   23 +++++++++++++------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index c44f4237b9be..adedc47e947d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -667,6 +667,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	int lso_header_size;
 	void *fragptr;
 	bool bounce = false;
+	bool send_doorbell;
 
 	if (!priv->port_up)
 		goto tx_drop;
@@ -878,12 +879,16 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	skb_tx_timestamp(skb);
 
-	if (ring->bf_enabled && desc_size <= MAX_BF && !bounce && !vlan_tx_tag_present(skb)) {
+	send_doorbell = !skb->xmit_more || netif_xmit_stopped(ring->tx_queue);
+
+	if (ring->bf_enabled && desc_size <= MAX_BF && !bounce &&
+	    !vlan_tx_tag_present(skb) && send_doorbell) {
 		tx_desc->ctrl.bf_qpn |= cpu_to_be32(ring->doorbell_qpn);
 
 		op_own |= htonl((bf_index & 0xffff) << 8);
-		/* Ensure new descirptor hits memory
-		* before setting ownership of this descriptor to HW */
+		/* Ensure new descriptor hits memory
+		 * before setting ownership of this descriptor to HW
+		 */
 		wmb();
 		tx_desc->ctrl.owner_opcode = op_own;
 
@@ -896,12 +901,16 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		ring->bf.offset ^= ring->bf.buf_size;
 	} else {
-		/* Ensure new descirptor hits memory
-		* before setting ownership of this descriptor to HW */
+		/* Ensure new descriptor hits memory
+		 * before setting ownership of this descriptor to HW
+		 */
 		wmb();
 		tx_desc->ctrl.owner_opcode = op_own;
-		wmb();
-		iowrite32be(ring->doorbell_qpn, ring->bf.uar->map + MLX4_SEND_DOORBELL);
+		if (send_doorbell) {
+			wmb();
+			iowrite32be(ring->doorbell_qpn,
+				    ring->bf.uar->map + MLX4_SEND_DOORBELL);
+		}
 	}
 
 	return NETDEV_TX_OK;
