From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 10/11] RFC: net: API for RX handover of multiple
 SKBs to stack
Date: Tue, 02 Feb 2016 22:15:07 +0100
Message-ID: <20160202211454.16315.11275.stgit@firesoul>
References: <20160202211051.16315.51808.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux.com>, tom@herbertland.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	alexei.starovoitov@gmail.com,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	ogerlitz@mellanox.com, gerlitz.or@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38450 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755788AbcBBVPJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 16:15:09 -0500
In-Reply-To: <20160202211051.16315.51808.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce napi_gro_receive_list() which takes a full SKB-list
for processing by the stack.

It also take over invoking eth_type_trans().

One purpose is to disconnect the icache usage/sharing between
driver level RX (NAPI loop) and upper RX network stack.

Another advantage is that the stack now knows how many packets it
received, and can do the appropiate packet bundling inside the
stack.  E.g. flush/process these bundles when the skb list is empty.

PITFALLS: Slightly overkill to use a struct sk_buff_head (24 bytes),
to handover packets.  Which is allocated on callers stack.  It
also maintains a qlen, which is unnecessary in this hotpath code.
A simple list within the first SKB could be a minimum solution.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c |   12 +-----------
 include/linux/netdevice.h                       |    3 +++
 net/core/dev.c                                  |   18 ++++++++++++++++++
 3 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 88f88d354abc..b6e7cc29f02c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -230,7 +230,6 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 {
 	struct mlx5e_rq *rq = container_of(cq, struct mlx5e_rq, cq);
 	struct sk_buff_head rx_skb_list;
-	struct sk_buff *rx_skb;
 	int work_done;
 
 	/* Using SKB list infrastructure, even-though some instructions
@@ -281,16 +280,7 @@ wq_ll_pop:
 		mlx5_wq_ll_pop(&rq->wq, wqe_counter_be,
 			       &wqe->next.next_wqe_index);
 	}
-
-	while ((rx_skb = __skb_dequeue(&rx_skb_list)) != NULL) {
-		rx_skb->protocol = eth_type_trans(rx_skb, rq->netdev);
-		napi_gro_receive(cq->napi, rx_skb);
-
-		/* NOT FOR UPSTREAM INCLUSION:
-		 * How I did isolated testing of driver RX, I here called:
-		 *  napi_consume_skb(rx_skb, budget);
-		 */
-	}
+	napi_gro_receive_list(cq->napi, &rx_skb_list, rq->netdev);
 
 	mlx5_cqwq_update_db_record(&cq->wq);
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5ac140dcb789..11df9af41a3c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3142,6 +3142,9 @@ int netif_rx(struct sk_buff *skb);
 int netif_rx_ni(struct sk_buff *skb);
 int netif_receive_skb(struct sk_buff *skb);
 gro_result_t napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb);
+void napi_gro_receive_list(struct napi_struct *napi,
+			   struct sk_buff_head *skb_list,
+			   struct net_device *netdev);
 void napi_gro_flush(struct napi_struct *napi, bool flush_old);
 struct sk_buff *napi_get_frags(struct napi_struct *napi);
 gro_result_t napi_gro_frags(struct napi_struct *napi);
diff --git a/net/core/dev.c b/net/core/dev.c
index 24be1d07d854..35c92a968937 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4579,6 +4579,24 @@ gro_result_t napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(napi_gro_receive);
 
+void napi_gro_receive_list(struct napi_struct *napi,
+			   struct sk_buff_head *skb_list,
+			   struct net_device *netdev)
+{
+	struct sk_buff *skb;
+
+	while ((skb = __skb_dequeue(skb_list)) != NULL) {
+		skb->protocol = eth_type_trans(skb, netdev);
+
+		skb_mark_napi_id(skb, napi);
+		trace_napi_gro_receive_entry(skb);
+
+		skb_gro_reset_offset(skb);
+		napi_skb_finish(dev_gro_receive(napi, skb), skb);
+	}
+}
+EXPORT_SYMBOL(napi_gro_receive_list);
+
 static void napi_reuse_skb(struct napi_struct *napi, struct sk_buff *skb)
 {
 	if (unlikely(skb->pfmemalloc)) {
