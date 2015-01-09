From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH RFC net-next] ip_tunnel: create percpu gro_cell
Date: Fri, 9 Jan 2015 10:42:13 -0800
Message-ID: <1420828933-844290-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:17318 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750807AbbAISmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 13:42:17 -0500
Received: from pps.filterd (m0004346 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t09IeTVw010230
	for <netdev@vger.kernel.org>; Fri, 9 Jan 2015 10:42:17 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1rtkhe040n-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 10:42:16 -0800
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 3a693ff6982f11e484340002c95209d8-b3d646d0 for <netdev@vger.kernel.org>;	Fri,
 09 Jan 2015 10:42:14 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the ipip tunnel, the skb->queue_mapping is lost in ipip_rcv().
All skb will be queued to the same cell->napi_skbs.  The
gro_cell_poll is pinned to one core under load. In production traffic,
we also see severe rx_dropped in the tunl iface and it is probably due to
this limit: skb_queue_len(&cell->napi_skbs) > netdev_max_backlog

This patch is trying to alloc_percpu(struct gro_cell) and schedule
gro_cell_poll to process it in the same core.

Setup:
VIP_PREFIX=9.9.9.9/32
REMOTE_REAL_IP=10.228.95.75

if [ "$1" = "encap" ]
then
    sudo ip tunnel add mode ipip remote ${REMOTE_REAL_IP}
    sudo ip link set dev ipip0 up
    sudo ip route add dev ipip0 ${VIP_PREFIX}
else
    # Decapsulating host

    sudo ip tunnel add mode ipip
    sudo ip link set dev tunl0 up
    sudo ip addr add dev lo ${VIP_PREFIX}
    sudo sysctl -a  | grep '\.rp_filter' | awk '{print $1;}' | \
        xargs -n1 -I{} sudo sysctl {}=0
fi

Before:
[root@DECAP ~]# netserver -p 8888
[root@ENCAP ~]# super_netperf 200 -t TCP_RR -H 9.9.9.9 -p 8888 \
-l 30 -- -d 0x6 -m 8k,64k -s 1M -S 1M
332215
[root@DECAP ~]# perf probe -a gro_cell_poll
[root@DECAP ~]# perf stat -I 1000 -a -A -e probe:gro_cell_poll
   117.258518273 CPU0                     0      probe:gro_cell_poll
   117.258518273 CPU1                     0      probe:gro_cell_poll
   117.258518273 CPU2                     0      probe:gro_cell_poll
   117.258518273 CPU3                     0      probe:gro_cell_poll
   117.258518273 CPU4                     0      probe:gro_cell_poll
   117.258518273 CPU5                     0      probe:gro_cell_poll
   117.258518273 CPU6                     0      probe:gro_cell_poll
   117.258518273 CPU7                     0      probe:gro_cell_poll
   117.258518273 CPU8                     0      probe:gro_cell_poll
   117.258518273 CPU9                     0      probe:gro_cell_poll
   117.258518273 CPU10                    0      probe:gro_cell_poll
   117.258518273 CPU11                    0      probe:gro_cell_poll
   117.258518273 CPU12                    0      probe:gro_cell_poll
   117.258518273 CPU13                    0      probe:gro_cell_poll
   117.258518273 CPU14                    0      probe:gro_cell_poll
   117.258518273 CPU15                4,882      probe:gro_cell_poll
   117.258518273 CPU16                    0      probe:gro_cell_poll
   117.258518273 CPU17                    0      probe:gro_cell_poll
   117.258518273 CPU18                    0      probe:gro_cell_poll
   117.258518273 CPU19                    0      probe:gro_cell_poll
   117.258518273 CPU20                    0      probe:gro_cell_poll
   117.258518273 CPU21                    0      probe:gro_cell_poll
   117.258518273 CPU22                    0      probe:gro_cell_poll
   117.258518273 CPU23                    0      probe:gro_cell_poll
   117.258518273 CPU24                    0      probe:gro_cell_poll
   117.258518273 CPU25                    0      probe:gro_cell_poll
   117.258518273 CPU26                    0      probe:gro_cell_poll
   117.258518273 CPU27                    0      probe:gro_cell_poll
   117.258518273 CPU28                    0      probe:gro_cell_poll
   117.258518273 CPU29                    0      probe:gro_cell_poll
   117.258518273 CPU30                    0      probe:gro_cell_poll
   117.258518273 CPU31                    0      probe:gro_cell_poll
   117.258518273 CPU32                    0      probe:gro_cell_poll
   117.258518273 CPU33                    0      probe:gro_cell_poll
   117.258518273 CPU34                    0      probe:gro_cell_poll
   117.258518273 CPU35                    0      probe:gro_cell_poll
   117.258518273 CPU36                    0      probe:gro_cell_poll
   117.258518273 CPU37                    0      probe:gro_cell_poll
   117.258518273 CPU38                    0      probe:gro_cell_poll
   117.258518273 CPU39                    0      probe:gro_cell_poll

After:
[root@DECAP ~]# netserver -p 8888
[root@ENCAP ~]# super_netperf 200 -t TCP_RR -H 9.9.9.9 -p 8888 \
-l 30 -- -d 0x6 -m 8k,64k -s 1M -S 1M
877530
[root@DECAP ~]# perf probe -a gro_cell_poll
[root@DECAP ~]# perf stat -I 1000 -a -A -e probe:gro_cell_poll
    40.085714389 CPU0                13,607      probe:gro_cell_poll
    40.085714389 CPU1                13,188      probe:gro_cell_poll
    40.085714389 CPU2                12,913      probe:gro_cell_poll
    40.085714389 CPU3                12,790      probe:gro_cell_poll
    40.085714389 CPU4                13,395      probe:gro_cell_poll
    40.085714389 CPU5                13,121      probe:gro_cell_poll
    40.085714389 CPU6                11,083      probe:gro_cell_poll
    40.085714389 CPU7                12,945      probe:gro_cell_poll
    40.085714389 CPU8                13,704      probe:gro_cell_poll
    40.085714389 CPU9                13,514      probe:gro_cell_poll
    40.085714389 CPU10                    0      probe:gro_cell_poll
    40.085714389 CPU11                    0      probe:gro_cell_poll
    40.085714389 CPU12                    0      probe:gro_cell_poll
    40.085714389 CPU13                    0      probe:gro_cell_poll
    40.085714389 CPU14                    0      probe:gro_cell_poll
    40.085714389 CPU15                    0      probe:gro_cell_poll
    40.085714389 CPU16                    0      probe:gro_cell_poll
    40.085714389 CPU17                    0      probe:gro_cell_poll
    40.085714389 CPU18                    0      probe:gro_cell_poll
    40.085714389 CPU19                    0      probe:gro_cell_poll
    40.085714389 CPU20               10,402      probe:gro_cell_poll
    40.085714389 CPU21               12,312      probe:gro_cell_poll
    40.085714389 CPU22               11,913      probe:gro_cell_poll
    40.085714389 CPU23               12,964      probe:gro_cell_poll
    40.085714389 CPU24               13,727      probe:gro_cell_poll
    40.085714389 CPU25               12,943      probe:gro_cell_poll
    40.085714389 CPU26               13,558      probe:gro_cell_poll
    40.085714389 CPU27               12,676      probe:gro_cell_poll
    40.085714389 CPU28               13,754      probe:gro_cell_poll
    40.085714389 CPU29               13,379      probe:gro_cell_poll
    40.085714389 CPU30                    0      probe:gro_cell_poll
    40.085714389 CPU31                    0      probe:gro_cell_poll
    40.085714389 CPU32                    0      probe:gro_cell_poll
    40.085714389 CPU33                    0      probe:gro_cell_poll
    40.085714389 CPU34                    0      probe:gro_cell_poll
    40.085714389 CPU35                    0      probe:gro_cell_poll
    40.085714389 CPU36                    0      probe:gro_cell_poll
    40.085714389 CPU37                    0      probe:gro_cell_poll
    40.085714389 CPU38                    0      probe:gro_cell_poll
    40.085714389 CPU39                    0      probe:gro_cell_poll

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 include/net/gro_cells.h | 27 +++++++++++----------------
 1 file changed, 11 insertions(+), 16 deletions(-)

diff --git a/include/net/gro_cells.h b/include/net/gro_cells.h
index 734d9b5..cdac448 100644
--- a/include/net/gro_cells.h
+++ b/include/net/gro_cells.h
@@ -11,22 +11,20 @@ struct gro_cell {
 } ____cacheline_aligned_in_smp;
 
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
