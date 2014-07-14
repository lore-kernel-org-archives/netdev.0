From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net] mlx4: mark napi id for gro_skb
Date: Mon, 14 Jul 2014 11:42:44 +0800
Message-ID: <1405309364-32258-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: amirv@mellanox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47927 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752110AbaGNDms (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Jul 2014 23:42:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Napi id was not marked for gro_skb, this will lead rx busy loop won't
work correctly since they stack never try to call low latency receive
method because of a zero socket napi id. Fix this by marking napi id
for gro_skb.

The transaction rate of 1 byte netperf tcp_rr gets about 50% increased
(from 20531.68 to 30610.88).

Cc: Amir Vadai <amirv@mellanox.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 9672417..5535862 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -783,6 +783,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 							     PKT_HASH_TYPE_L3);
 
 					skb_record_rx_queue(gro_skb, cq->ring);
+					skb_mark_napi_id(gro_skb, &cq->napi);
 
 					if (ring->hwtstamp_rx_filter == HWTSTAMP_FILTER_ALL) {
 						timestamp = mlx4_en_get_cqe_ts(cqe);
-- 
1.9.1
