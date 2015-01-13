From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH RFC v2 net-next 2/2] ip_tunnel: Remove struct gro_cells
Date: Tue, 13 Jan 2015 15:42:44 -0800
Message-ID: <1421192564-437455-3-git-send-email-kafai@fb.com>
References: <1421192564-437455-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:34415 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753871AbbAMXn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 18:43:28 -0500
Received: from pps.filterd (m0044012 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t0DNgFhV031161
	for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 15:43:28 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1rwbqrg6bx-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 15:43:27 -0800
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 f7dc63aa9b7d11e4be810002c95209d8-5add9390 for <netdev@vger.kernel.org>;	Tue,
 13 Jan 2015 15:43:26 -0800
In-Reply-To: <1421192564-437455-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After adding percpu gro_cells, struct gro_cells can be removed.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 include/net/gro_cells.h  | 34 ++++++++++++++++------------------
 include/net/ip_tunnels.h |  2 +-
 net/ipv4/ip_tunnel.c     | 11 +++++------
 3 files changed, 22 insertions(+), 25 deletions(-)

diff --git a/include/net/gro_cells.h b/include/net/gro_cells.h
index 0f712c0..b1aeea1 100644
--- a/include/net/gro_cells.h
+++ b/include/net/gro_cells.h
@@ -10,21 +10,18 @@ struct gro_cell {
 	struct napi_struct	napi;
 };
 
-struct gro_cells {
-	struct gro_cell __percpu	*cells;
-};
-
-static inline void gro_cells_receive(struct gro_cells *gcells, struct sk_buff *skb)
+static inline void gro_cells_receive(struct gro_cell __percpu *gcells,
+				     struct sk_buff *skb)
 {
 	struct gro_cell *cell;
 	struct net_device *dev = skb->dev;
 
-	if (!gcells->cells || skb_cloned(skb) || !(dev->features & NETIF_F_GRO)) {
+	if (!gcells || skb_cloned(skb) || !(dev->features & NETIF_F_GRO)) {
 		netif_rx(skb);
 		return;
 	}
 
-	cell = this_cpu_ptr(gcells->cells);
+	cell = this_cpu_ptr(gcells);
 
 	if (skb_queue_len(&cell->napi_skbs) > netdev_max_backlog) {
 		atomic_long_inc(&dev->rx_dropped);
@@ -66,37 +63,38 @@ static inline int gro_cell_poll(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
-static inline int gro_cells_init(struct gro_cells *gcells, struct net_device *dev)
+static inline struct gro_cell __percpu *
+gro_cell_alloc_percpu(struct net_device *dev)
 {
+	struct gro_cell __percpu *gcells;
 	int i;
 
-	gcells->cells = alloc_percpu(struct gro_cell);
-	if (!gcells->cells)
-		return -ENOMEM;
+	gcells = alloc_percpu(struct gro_cell);
+	if (!gcells)
+		return ERR_PTR(-ENOMEM);
 
 	for_each_possible_cpu(i) {
-		struct gro_cell *cell = per_cpu_ptr(gcells->cells, i);
+		struct gro_cell *cell = per_cpu_ptr(gcells, i);
 
 		skb_queue_head_init(&cell->napi_skbs);
 		netif_napi_add(dev, &cell->napi, gro_cell_poll, 64);
 		napi_enable(&cell->napi);
 	}
-	return 0;
+	return gcells;
 }
 
-static inline void gro_cells_destroy(struct gro_cells *gcells)
+static inline void gro_cell_free_percpu(struct gro_cell __percpu *gcells)
 {
 	int i;
 
-	if (!gcells->cells)
+	if (IS_ERR_OR_NULL(gcells))
 		return;
 	for_each_possible_cpu(i) {
-		struct gro_cell *cell = per_cpu_ptr(gcells->cells, i);
+		struct gro_cell *cell = per_cpu_ptr(gcells, i);
 		netif_napi_del(&cell->napi);
 		skb_queue_purge(&cell->napi_skbs);
 	}
-	free_percpu(gcells->cells);
-	gcells->cells = NULL;
+	free_percpu(gcells);
 }
 
 #endif
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 25a59eb..e406bc3 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -83,7 +83,7 @@ struct ip_tunnel {
 	struct ip_tunnel_prl_entry __rcu *prl;	/* potential router list */
 	unsigned int		prl_count;	/* # of entries in PRL */
 	int			ip_tnl_net_id;
-	struct gro_cells	gro_cells;
+	struct gro_cell __percpu *gro_cells;
 };
 
 #define TUNNEL_CSUM		__cpu_to_be16(0x01)
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index d3e4479..fcc92c0 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -479,7 +479,7 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 		skb->dev = tunnel->dev;
 	}
 
-	gro_cells_receive(&tunnel->gro_cells, skb);
+	gro_cells_receive(tunnel->gro_cells, skb);
 	return 0;
 
 drop:
@@ -952,7 +952,7 @@ static void ip_tunnel_dev_free(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 
-	gro_cells_destroy(&tunnel->gro_cells);
+	gro_cell_free_percpu(tunnel->gro_cells);
 	free_percpu(tunnel->dst_cache);
 	free_percpu(dev->tstats);
 	free_netdev(dev);
@@ -1120,7 +1120,6 @@ int ip_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct iphdr *iph = &tunnel->parms.iph;
-	int err;
 
 	dev->destructor	= ip_tunnel_dev_free;
 	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
@@ -1133,11 +1132,11 @@ int ip_tunnel_init(struct net_device *dev)
 		return -ENOMEM;
 	}
 
-	err = gro_cells_init(&tunnel->gro_cells, dev);
-	if (err) {
+	tunnel->gro_cells = gro_cell_alloc_percpu(dev);
+	if (IS_ERR(tunnel->gro_cells)) {
 		free_percpu(tunnel->dst_cache);
 		free_percpu(dev->tstats);
-		return err;
+		return PTR_ERR(tunnel->gro_cells);
 	}
 
 	tunnel->dev = dev;
-- 
1.8.1
