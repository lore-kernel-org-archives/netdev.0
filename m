From: roy.qing.li-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Subject: [PATCH] openvswitch: distinguish between the dropped and
	consumed skb
Date: Tue,  2 Sep 2014 20:52:49 +0800
Message-ID: <1409662369-2528-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Li RongQing <roy.qing.li-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

distinguish between the dropped and consumed skb, not assume the skb
is consumed always

Cc: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Li RongQing <roy.qing.li-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/openvswitch/datapath.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 35d866f..dacf56f 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -266,7 +266,6 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
 		upcall.userdata = NULL;
 		upcall.portid = ovs_vport_find_upcall_portid(p, skb);
 		ovs_dp_upcall(dp, skb, &upcall);
-		consume_skb(skb);
 		stats_counter = &stats->n_missed;
 		goto out;
 	}
@@ -304,9 +303,11 @@ int ovs_dp_upcall(struct datapath *dp, struct sk_buff *skb,
 	if (err)
 		goto err;
 
+	consume_skb(skb);
 	return 0;
 
 err:
+	kfree_skb(skb);
 	stats = this_cpu_ptr(dp->stats_percpu);
 
 	u64_stats_update_begin(&stats->syncp);
-- 
1.7.10.4
