From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH] mlx4_en: fix transmit of packages when blue frame is enabled
Date: Fri, 30 Sep 2011 10:23:15 -0300
Message-ID: <1317388995-411-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:45880 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752827Ab1I3NXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 09:23:31 -0400
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp02.br.ibm.com (8.14.4/8.13.1) with ESMTP id p8UAMpGq025116
	for <netdev@vger.kernel.org>; Fri, 30 Sep 2011 07:22:51 -0300
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8UDQoqr1994770
	for <netdev@vger.kernel.org>; Fri, 30 Sep 2011 10:26:51 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8UDNI6Y012810
	for <netdev@vger.kernel.org>; Fri, 30 Sep 2011 10:23:19 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the addition of Blue Frame support in the network driver for mlx4,
the doorbell is not written in the path where blue frame is enabled and
the package follows some characteristics.

The consequence of that is that ICMP ECHO requests, for example, were
not transmitted by the device. A ping flood, for example, would make the
watchdog dispatch, because the ring was full and transmissions have
timed out.

After this fix, I could ping two systems using mlx4_en (both with the
fix).

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 6e03de0..270da80 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -811,10 +811,11 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		* before setting ownership of this descriptor to HW */
 		wmb();
 		tx_desc->ctrl.owner_opcode = op_own;
-		wmb();
-		writel(ring->doorbell_qpn, ring->bf.uar->map + MLX4_SEND_DOORBELL);
 	}
 
+	wmb();
+	writel(ring->doorbell_qpn, ring->bf.uar->map + MLX4_SEND_DOORBELL);
+
 	/* Poll CQ here */
 	mlx4_en_xmit_poll(priv, tx_ind);
 
-- 
1.7.4.4
