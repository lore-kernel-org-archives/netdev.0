From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH RFC v2 net-next 1/2] ip_tunnel: Create percpu gro_cell
Date: Tue, 13 Jan 2015 15:42:43 -0800
Message-ID: <1421192564-437455-2-git-send-email-kafai@fb.com>
References: <1421192564-437455-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:34638 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753872AbbAMXn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 18:43:29 -0500
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t0DNdEIv023623
	for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 15:43:28 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1rw9qm0rvg-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 15:43:28 -0800
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 f7d7b4a49b7d11e482810002c991e86a-103d7390 for <netdev@vger.kernel.org>;	Tue,
 13 Jan 2015 15:43:26 -0800
In-Reply-To: <1421192564-437455-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the ipip tunnel, the skb->queue_mapping is lost in ipip_rcv().
All skb will be queued to the same cell->napi_skbs.  The
gro_cell_poll is pinned to one core under load.  In production traffic,
we also see severe rx_dropped in the tunl iface and it is probably due to
this limit: skb_queue_len(&cell->napi_skbs) > netdev_max_backlog.

This patch is trying to alloc_percpu(struct gro_cell) and schedule
gro_cell_poll to process the skb in the same core.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 include/net/gro_cells.h | 29 ++++++++++++-----------------
 1 file changed, 12 insertions(+), 17 deletions(-)

diff --git a/include/net/gro_cells.h b/include/net/gro_cells.h
index 734d9b5..0f712c0 100644
--- a/include/net/gro_cells.h
+++ b/include/net/gro_cells.h
@@ -8,25 +8,23 @@
 struct gro_cell {
 	struct sk_buff_head	napi_skbs;
 	struct napi_struct	napi;
-} ____cacheline_aligned_in_smp;
+};
 
 struct gro_cells {
-	unsigned int		gro_cells_mask;
-	struct gro_cell		*cells;
+	struct gro_cell __percpu	*cells;
 };
 
 static inline void gro_cells_receive(struct gro_cells *gcells, struct sk_buff *skb)
 {
-	struct gro_cell *cell = gcells->cells;
+	struct gro_cell *cell;
 	struct net_device *dev = skb->dev;
 
-	if (!cell || skb_cloned(skb) || !(dev->features & NETIF_F_GRO)) {
+	if (!gcells->cells || skb_cloned(skb) || !(dev->features & NETIF_F_GRO)) {
 		netif_rx(skb);
 		return;
 	}
 
-	if (skb_rx_queue_recorded(skb))
-		cell += skb_get_rx_queue(skb) & gcells->gro_cells_mask;
+	cell = this_cpu_ptr(gcells->cells);
 
 	if (skb_queue_len(&cell->napi_skbs) > netdev_max_backlog) {
 		atomic_long_inc(&dev->rx_dropped);
@@ -72,15 +70,12 @@ static inline int gro_cells_init(struct gro_cells *gcells, struct net_device *de
 {
 	int i;
 
-	gcells->gro_cells_mask = roundup_pow_of_two(netif_get_num_default_rss_queues()) - 1;
-	gcells->cells = kcalloc(gcells->gro_cells_mask + 1,
-				sizeof(struct gro_cell),
-				GFP_KERNEL);
+	gcells->cells = alloc_percpu(struct gro_cell);
 	if (!gcells->cells)
 		return -ENOMEM;
 
-	for (i = 0; i <= gcells->gro_cells_mask; i++) {
-		struct gro_cell *cell = gcells->cells + i;
+	for_each_possible_cpu(i) {
+		struct gro_cell *cell = per_cpu_ptr(gcells->cells, i);
 
 		skb_queue_head_init(&cell->napi_skbs);
 		netif_napi_add(dev, &cell->napi, gro_cell_poll, 64);
@@ -91,16 +86,16 @@ static inline int gro_cells_init(struct gro_cells *gcells, struct net_device *de
 
 static inline void gro_cells_destroy(struct gro_cells *gcells)
 {
-	struct gro_cell *cell = gcells->cells;
 	int i;
 
-	if (!cell)
+	if (!gcells->cells)
 		return;
-	for (i = 0; i <= gcells->gro_cells_mask; i++,cell++) {
+	for_each_possible_cpu(i) {
+		struct gro_cell *cell = per_cpu_ptr(gcells->cells, i);
 		netif_napi_del(&cell->napi);
 		skb_queue_purge(&cell->napi_skbs);
 	}
-	kfree(gcells->cells);
+	free_percpu(gcells->cells);
 	gcells->cells = NULL;
 }
 
-- 
1.8.1
