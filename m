From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH] mlx4_en: fix endianness with blue frame support
Date: Mon, 10 Oct 2011 13:42:23 -0300
Message-ID: <1318264943-10009-1-git-send-email-cascardo@linux.vnet.ibm.com>
References: <1318231920.29415.404.camel@pasglop>
Cc: linuxppc-dev@lists.ozlabs.org,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Eli Cohen <eli@dev.mellanox.co.il>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:58297 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944Ab1JJQmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 12:42:46 -0400
Received: from /spool/local
	by br.ibm.com with XMail ESMTP
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Mon, 10 Oct 2011 13:42:43 -0300
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9AGkBq23575828
	for <netdev@vger.kernel.org>; Mon, 10 Oct 2011 13:46:11 -0300
Received: from d24av05.br.ibm.com (loopback [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9AGgaGw007299
	for <netdev@vger.kernel.org>; Mon, 10 Oct 2011 13:42:37 -0300
In-Reply-To: <1318231920.29415.404.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The doorbell register was being unconditionally swapped. In x86, that
meant it was being swapped to BE and written to the descriptor and to
memory, depending on the case of blue frame support or writing to
doorbell register. On PPC, this meant it was being swapped to LE and
then swapped back to BE while writing to the register. But in the blue
frame case, it was being written as LE to the descriptor.

The fix is not to swap doorbell unconditionally, write it to the
register as BE and convert it to BE when writing it to the descriptor.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Reported-by: Richard Hendrickson <richhend@us.ibm.com>
Cc: Eli Cohen <eli@dev.mellanox.co.il>
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/mlx4/en_tx.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/mlx4/en_tx.c
index 6e03de0..f76ab6b 100644
--- a/drivers/net/mlx4/en_tx.c
+++ b/drivers/net/mlx4/en_tx.c
@@ -172,7 +172,7 @@ int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
 	memset(ring->buf, 0, ring->buf_size);
 
 	ring->qp_state = MLX4_QP_STATE_RST;
-	ring->doorbell_qpn = swab32(ring->qp.qpn << 8);
+	ring->doorbell_qpn = ring->qp.qpn << 8;
 
 	mlx4_en_fill_qp_context(priv, ring->size, ring->stride, 1, 0, ring->qpn,
 				ring->cqn, &ring->context);
@@ -791,7 +791,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		skb_orphan(skb);
 
 	if (ring->bf_enabled && desc_size <= MAX_BF && !bounce && !vlan_tag) {
-		*(u32 *) (&tx_desc->ctrl.vlan_tag) |= ring->doorbell_qpn;
+		*(__be32 *) (&tx_desc->ctrl.vlan_tag) |= cpu_to_be32(ring->doorbell_qpn);
 		op_own |= htonl((bf_index & 0xffff) << 8);
 		/* Ensure new descirptor hits memory
 		* before setting ownership of this descriptor to HW */
@@ -812,7 +812,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		wmb();
 		tx_desc->ctrl.owner_opcode = op_own;
 		wmb();
-		writel(ring->doorbell_qpn, ring->bf.uar->map + MLX4_SEND_DOORBELL);
+		iowrite32be(ring->doorbell_qpn, ring->bf.uar->map + MLX4_SEND_DOORBELL);
 	}
 
 	/* Poll CQ here */
-- 
1.7.4.4
