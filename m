From: roy.qing.li@gmail.com
Subject: [PATCH][net-next] openvswitch: change the data type of error status to atomic_long_t
Date: Sat,  6 Sep 2014 19:06:11 +0800
Message-ID: <1410001571-13338-1-git-send-email-roy.qing.li@gmail.com>
Cc: pshelar@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:56886 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042AbaIFLGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2014 07:06:22 -0400
Received: by mail-pa0-f45.google.com with SMTP id bj1so23776132pad.4
        for <netdev@vger.kernel.org>; Sat, 06 Sep 2014 04:06:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

Change the date type of error status from u64 to atomic_long_t, and use atomic
operation, then remove the lock which is used to protect the error status.

The operation of atomic maybe faster than spin lock.

Cc: Pravin Shelar <pshelar@nicira.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/openvswitch/vport.c |   25 ++++++++-----------------
 net/openvswitch/vport.h |   10 ++++------
 2 files changed, 12 insertions(+), 23 deletions(-)

diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 6d8f2ec..f7e63f9 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -148,8 +148,6 @@ struct vport *ovs_vport_alloc(int priv_size, const struct vport_ops *ops,
 		return ERR_PTR(-ENOMEM);
 	}
 
-	spin_lock_init(&vport->stats_lock);
-
 	return vport;
 }
 
@@ -268,14 +266,10 @@ void ovs_vport_get_stats(struct vport *vport, struct ovs_vport_stats *stats)
 	 * netdev-stats can be directly read over netlink-ioctl.
 	 */
 
-	spin_lock_bh(&vport->stats_lock);
-
-	stats->rx_errors	= vport->err_stats.rx_errors;
-	stats->tx_errors	= vport->err_stats.tx_errors;
-	stats->tx_dropped	= vport->err_stats.tx_dropped;
-	stats->rx_dropped	= vport->err_stats.rx_dropped;
-
-	spin_unlock_bh(&vport->stats_lock);
+	stats->rx_errors  = atomic_long_read(&vport->err_stats.rx_errors);
+	stats->tx_errors  = atomic_long_read(&vport->err_stats.tx_errors);
+	stats->tx_dropped = atomic_long_read(&vport->err_stats.tx_dropped);
+	stats->rx_dropped = atomic_long_read(&vport->err_stats.rx_dropped);
 
 	for_each_possible_cpu(i) {
 		const struct pcpu_sw_netstats *percpu_stats;
@@ -495,27 +489,24 @@ int ovs_vport_send(struct vport *vport, struct sk_buff *skb)
 static void ovs_vport_record_error(struct vport *vport,
 				   enum vport_err_type err_type)
 {
-	spin_lock(&vport->stats_lock);
-
 	switch (err_type) {
 	case VPORT_E_RX_DROPPED:
-		vport->err_stats.rx_dropped++;
+		atomic_long_inc(&vport->err_stats.rx_dropped);
 		break;
 
 	case VPORT_E_RX_ERROR:
-		vport->err_stats.rx_errors++;
+		atomic_long_inc(&vport->err_stats.rx_errors);
 		break;
 
 	case VPORT_E_TX_DROPPED:
-		vport->err_stats.tx_dropped++;
+		atomic_long_inc(&vport->err_stats.tx_dropped);
 		break;
 
 	case VPORT_E_TX_ERROR:
-		vport->err_stats.tx_errors++;
+		atomic_long_inc(&vport->err_stats.tx_errors);
 		break;
 	}
 
-	spin_unlock(&vport->stats_lock);
 }
 
 static void free_vport_rcu(struct rcu_head *rcu)
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 35f89d8..0d95b9f 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -62,10 +62,10 @@ int ovs_vport_send(struct vport *, struct sk_buff *);
 /* The following definitions are for implementers of vport devices: */
 
 struct vport_err_stats {
-	u64 rx_dropped;
-	u64 rx_errors;
-	u64 tx_dropped;
-	u64 tx_errors;
+	atomic_long_t rx_dropped;
+	atomic_long_t rx_errors;
+	atomic_long_t tx_dropped;
+	atomic_long_t tx_errors;
 };
 /**
  * struct vport_portids - array of netlink portids of a vport.
@@ -93,7 +93,6 @@ struct vport_portids {
  * @dp_hash_node: Element in @datapath->ports hash table in datapath.c.
  * @ops: Class structure.
  * @percpu_stats: Points to per-CPU statistics used and maintained by vport
- * @stats_lock: Protects @err_stats;
  * @err_stats: Points to error statistics used and maintained by vport
  */
 struct vport {
@@ -108,7 +107,6 @@ struct vport {
 
 	struct pcpu_sw_netstats __percpu *percpu_stats;
 
-	spinlock_t stats_lock;
 	struct vport_err_stats err_stats;
 };
 
-- 
1.7.10.4
