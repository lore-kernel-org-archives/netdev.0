From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 10/10] openvswitch: Use generic struct pcpu_tstats.
Date: Tue, 16 Apr 2013 14:00:19 -0700
Message-ID: <1366146019-9015-11-git-send-email-jesse@nicira.com>
References: <1366146019-9015-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog138.obsmtp.com ([74.125.149.19]:35730 "HELO
	na3sys009aog138.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S965307Ab3DPVA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 17:00:27 -0400
Received: by mail-da0-f71.google.com with SMTP id f4so682692dal.10
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 14:00:26 -0700 (PDT)
In-Reply-To: <1366146019-9015-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>

Rather than defining ovs specific stats struct (vport_percpu_stats),
we can use existing pcpu_tstats to achieve exactly same functionality.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/vport.c |   22 +++++++++++-----------
 net/openvswitch/vport.h |   11 ++---------
 2 files changed, 13 insertions(+), 20 deletions(-)

diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index c90d856..7206231 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -128,7 +128,7 @@ struct vport *ovs_vport_alloc(int priv_size, const struct vport_ops *ops,
 	vport->ops = ops;
 	INIT_HLIST_NODE(&vport->dp_hash_node);
 
-	vport->percpu_stats = alloc_percpu(struct vport_percpu_stats);
+	vport->percpu_stats = alloc_percpu(struct pcpu_tstats);
 	if (!vport->percpu_stats) {
 		kfree(vport);
 		return ERR_PTR(-ENOMEM);
@@ -260,16 +260,16 @@ void ovs_vport_get_stats(struct vport *vport, struct ovs_vport_stats *stats)
 	spin_unlock_bh(&vport->stats_lock);
 
 	for_each_possible_cpu(i) {
-		const struct vport_percpu_stats *percpu_stats;
-		struct vport_percpu_stats local_stats;
+		const struct pcpu_tstats *percpu_stats;
+		struct pcpu_tstats local_stats;
 		unsigned int start;
 
 		percpu_stats = per_cpu_ptr(vport->percpu_stats, i);
 
 		do {
-			start = u64_stats_fetch_begin_bh(&percpu_stats->sync);
+			start = u64_stats_fetch_begin_bh(&percpu_stats->syncp);
 			local_stats = *percpu_stats;
-		} while (u64_stats_fetch_retry_bh(&percpu_stats->sync, start));
+		} while (u64_stats_fetch_retry_bh(&percpu_stats->syncp, start));
 
 		stats->rx_bytes		+= local_stats.rx_bytes;
 		stats->rx_packets	+= local_stats.rx_packets;
@@ -327,13 +327,13 @@ int ovs_vport_get_options(const struct vport *vport, struct sk_buff *skb)
  */
 void ovs_vport_receive(struct vport *vport, struct sk_buff *skb)
 {
-	struct vport_percpu_stats *stats;
+	struct pcpu_tstats *stats;
 
 	stats = this_cpu_ptr(vport->percpu_stats);
-	u64_stats_update_begin(&stats->sync);
+	u64_stats_update_begin(&stats->syncp);
 	stats->rx_packets++;
 	stats->rx_bytes += skb->len;
-	u64_stats_update_end(&stats->sync);
+	u64_stats_update_end(&stats->syncp);
 
 	ovs_dp_process_received_packet(vport, skb);
 }
@@ -352,14 +352,14 @@ int ovs_vport_send(struct vport *vport, struct sk_buff *skb)
 	int sent = vport->ops->send(vport, skb);
 
 	if (likely(sent)) {
-		struct vport_percpu_stats *stats;
+		struct pcpu_tstats *stats;
 
 		stats = this_cpu_ptr(vport->percpu_stats);
 
-		u64_stats_update_begin(&stats->sync);
+		u64_stats_update_begin(&stats->syncp);
 		stats->tx_packets++;
 		stats->tx_bytes += sent;
-		u64_stats_update_end(&stats->sync);
+		u64_stats_update_end(&stats->syncp);
 	}
 	return sent;
 }
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 7282b84..7ba08c3 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -19,6 +19,7 @@
 #ifndef VPORT_H
 #define VPORT_H 1
 
+#include <linux/if_tunnel.h>
 #include <linux/list.h>
 #include <linux/netlink.h>
 #include <linux/openvswitch.h>
@@ -50,14 +51,6 @@ int ovs_vport_send(struct vport *, struct sk_buff *);
 
 /* The following definitions are for implementers of vport devices: */
 
-struct vport_percpu_stats {
-	u64 rx_bytes;
-	u64 rx_packets;
-	u64 tx_bytes;
-	u64 tx_packets;
-	struct u64_stats_sync sync;
-};
-
 struct vport_err_stats {
 	u64 rx_dropped;
 	u64 rx_errors;
@@ -89,7 +82,7 @@ struct vport {
 	struct hlist_node dp_hash_node;
 	const struct vport_ops *ops;
 
-	struct vport_percpu_stats __percpu *percpu_stats;
+	struct pcpu_tstats __percpu *percpu_stats;
 
 	spinlock_t stats_lock;
 	struct vport_err_stats err_stats;
-- 
1.7.10.4
