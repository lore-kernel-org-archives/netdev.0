From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH net] net/mlx4_en: correct the endianness of doorbell_qpn on big endian platform
Date: Sun, 30 Nov 2014 10:43:51 +0800
Message-ID: <1417315431-16761-1-git-send-email-weiyang@linux.vnet.ibm.com>
Cc: davem@davemloft.net, gideonn@mellanox.com,
	Wei Yang <weiyang@linux.vnet.ibm.com>,
	Eric Dumazet <edumazet@google.com>,
	Amir Vadai <amirv@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp07.au.ibm.com ([202.81.31.140]:50737 "EHLO
	e23smtp07.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751686AbaK3CvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2014 21:51:14 -0500
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Sun, 30 Nov 2014 12:51:13 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 2717F3578048
	for <netdev@vger.kernel.org>; Sun, 30 Nov 2014 13:43:55 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sAU2hs4a39125018
	for <netdev@vger.kernel.org>; Sun, 30 Nov 2014 13:43:55 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sAU2hrdW028326
	for <netdev@vger.kernel.org>; Sun, 30 Nov 2014 13:43:54 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 6a4e812 (net/mlx4_en: Avoid calling bswap in tx fast path), we store
doorbell_qpn in big endian to avoid bswap(). Then we try to write it directly
by iowrite32() instead of iowrite32be().

This works fine on little endian platform, while has some problem on big
endian platform. Here is the definition in general:

	#define iowrite32(v, addr)	writel((v), (addr))
	#define writel(b,addr)		__raw_writel(__cpu_to_le32(b),addr)

On little endian platform, the value is not swapped before write. While on big
endian platform, the value is swapped. This is not expected to happen.

This patch does the swap on big endian platform before it is written.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
CC: Eric Dumazet <edumazet@google.com>
CC: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 454d9fe..76f028b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -954,7 +954,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		tx_desc->ctrl.owner_opcode = op_own;
 		if (send_doorbell) {
 			wmb();
-			iowrite32(ring->doorbell_qpn,
+			iowrite32(__cpu_to_le32(ring->doorbell_qpn),
 				  ring->bf.uar->map + MLX4_SEND_DOORBELL);
 		} else {
 			ring->xmit_more++;
-- 
1.7.9.5
