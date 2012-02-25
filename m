From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] mlx4_en: dont change mac_header on xmit
Date: Sat, 25 Feb 2012 11:51:05 +0100
Message-ID: <1330167065.2462.53.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54078 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754833Ab2BYKvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Feb 2012 05:51:11 -0500
Received: by wgbdr13 with SMTP id dr13so397546wgb.1
        for <netdev@vger.kernel.org>; Sat, 25 Feb 2012 02:51:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A driver xmit function is not allowed to change skb without special
care.

mlx4_en_xmit() should not call skb_reset_mac_header() and instead should
use skb->data to access ethernet header.

This removes a dumb test : if (ethh && ethh->h_dest)

Also remove this slow mlx4_en_mac_to_u64() call, we can use
get_unaligned() to get faster code.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
Please test this patch before we can commit it, thanks !

 drivers/net/ethernet/mellanox/mlx4/en_tx.c |   15 +++------------
 include/linux/mlx4/qp.h                    |    5 ++++-
 2 files changed, 7 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index ff32505..2fd5140 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -601,8 +601,6 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct skb_frag_struct *frag;
 	struct mlx4_en_tx_info *tx_info;
 	struct ethhdr *ethh;
-	u64 mac;
-	u32 mac_l, mac_h;
 	int tx_ind = 0;
 	int nr_txbb;
 	int desc_size;
@@ -687,16 +685,9 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	/* Copy dst mac address to wqe */
-	skb_reset_mac_header(skb);
-	ethh = eth_hdr(skb);
-	if (ethh && ethh->h_dest) {
-		mac = mlx4_en_mac_to_u64(ethh->h_dest);
-		mac_h = (u32) ((mac & 0xffff00000000ULL) >> 16);
-		mac_l = (u32) (mac & 0xffffffff);
-		tx_desc->ctrl.srcrb_flags |= cpu_to_be32(mac_h);
-		tx_desc->ctrl.imm = cpu_to_be32(mac_l);
-	}
-
+	ethh = (struct ethhdr *)skb->data;
+	tx_desc->ctrl.srcrb_flags16[0] = get_unaligned((u16 *)ethh->h_dest);
+	tx_desc->ctrl.imm = get_unaligned((u32 *)(ethh->h_dest + 2));
 	/* Handle LSO (TSO) packets */
 	if (lso_header_size) {
 		/* Mark opcode as LSO */
diff --git a/include/linux/mlx4/qp.h b/include/linux/mlx4/qp.h
index bee8fa2..091f9e7 100644
--- a/include/linux/mlx4/qp.h
+++ b/include/linux/mlx4/qp.h
@@ -212,7 +212,10 @@ struct mlx4_wqe_ctrl_seg {
 	 * [1]   SE (solicited event)
 	 * [0]   FL (force loopback)
 	 */
-	__be32			srcrb_flags;
+	union {
+		__be32			srcrb_flags;
+		__be16			srcrb_flags16[2];
+	};
 	/*
 	 * imm is immediate data for send/RDMA write w/ immediate;
 	 * also invalidation key for send with invalidate; input
