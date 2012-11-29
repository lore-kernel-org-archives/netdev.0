From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 5/7] net: openvswitch: use this_cpu_ptr
	per-cpu helper
Date: Thu, 29 Nov 2012 10:35:47 -0800
Message-ID: <1354214149-33651-6-git-send-email-jesse@nicira.com>
References: <1354214149-33651-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Shan Wei <davidshan-1Nz4purKYjRBDgjK7y7TUQ@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1354214149-33651-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Shan Wei <davidshan-1Nz4purKYjRBDgjK7y7TUQ@public.gmane.org>

just use more faster this_cpu_ptr instead of per_cpu_ptr(p, smp_processor_id());

Signed-off-by: Shan Wei <davidshan-1Nz4purKYjRBDgjK7y7TUQ@public.gmane.org>
Reviewed-by: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c |    4 ++--
 net/openvswitch/vport.c    |    5 ++---
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index fd4a6a4..7b1d6d2 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -208,7 +208,7 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
 	int error;
 	int key_len;
 
-	stats = per_cpu_ptr(dp->stats_percpu, smp_processor_id());
+	stats = this_cpu_ptr(dp->stats_percpu);
 
 	/* Extract flow from 'skb' into 'key'. */
 	error = ovs_flow_extract(skb, p->port_no, &key, &key_len);
@@ -282,7 +282,7 @@ int ovs_dp_upcall(struct datapath *dp, struct sk_buff *skb,
 	return 0;
 
 err:
-	stats = per_cpu_ptr(dp->stats_percpu, smp_processor_id());
+	stats = this_cpu_ptr(dp->stats_percpu);
 
 	u64_stats_update_begin(&stats->sync);
 	stats->n_lost++;
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 03779e8..70af0be 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -333,8 +333,7 @@ void ovs_vport_receive(struct vport *vport, struct sk_buff *skb)
 {
 	struct vport_percpu_stats *stats;
 
-	stats = per_cpu_ptr(vport->percpu_stats, smp_processor_id());
-
+	stats = this_cpu_ptr(vport->percpu_stats);
 	u64_stats_update_begin(&stats->sync);
 	stats->rx_packets++;
 	stats->rx_bytes += skb->len;
@@ -359,7 +358,7 @@ int ovs_vport_send(struct vport *vport, struct sk_buff *skb)
 	if (likely(sent)) {
 		struct vport_percpu_stats *stats;
 
-		stats = per_cpu_ptr(vport->percpu_stats, smp_processor_id());
+		stats = this_cpu_ptr(vport->percpu_stats);
 
 		u64_stats_update_begin(&stats->sync);
 		stats->tx_packets++;
-- 
1.7.9.5
