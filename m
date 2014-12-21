From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net] net/mlx4_en: Doorbell is byteswapped in Little Endian archs
Date: Sun, 21 Dec 2014 20:18:58 +0200
Message-ID: <1419185938-28987-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Wei Yang <weiyang@linux.vnet.ibm.com>,
	David Laight <david.laight@aculab.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:38536 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751277AbaLUSTI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Dec 2014 13:19:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iowrite32() will byteswap it's argument on big endian archs.
iowrite32be() will byteswap on little endian archs.
Since we don't want to do this unnecessary byteswap on the fast path,
doorbell is stored in the NIC's native endianness. Using the right
iowrite() according to the arch endianness.

CC: Wei Yang <weiyang@linux.vnet.ibm.com>
CC: David Laight <david.laight@aculab.com>
Fixes: 6a4e812 ("net/mlx4_en: Avoid calling bswap in tx fast path")
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index a308d41..6477cc7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -962,7 +962,16 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		tx_desc->ctrl.owner_opcode = op_own;
 		if (send_doorbell) {
 			wmb();
-			iowrite32(ring->doorbell_qpn,
+		/* Since there is no iowrite*_native() that writes the value
+		 * as is, without byteswapping - using the one the doesn't do
+		 * byteswapping in the relevant arch endianness.
+		 */
+#if defined(__LITTLE_ENDIAN)
+			iowrite32(
+#else
+			iowrite32be(
+#endif
+				  ring->doorbell_qpn,
 				  ring->bf.uar->map + MLX4_SEND_DOORBELL);
 		} else {
 			ring->xmit_more++;
-- 
1.9.3
