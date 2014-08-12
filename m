From: Christoph Jaeger <cj-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] openvswitch: Fix memory leak in ovs_vport_alloc()
	error path
Date: Tue, 12 Aug 2014 09:27:57 +0200
Message-ID: <1407828477-10287-1-git-send-email-cj@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Christoph Jaeger <cj-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
To: pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
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

ovs_vport_alloc() bails out without freeing the memory 'vport' points to.

Picked up by Coverity - CID 1230503.

Fixes: 5cd667b0a4 ("openvswitch: Allow each vport to have an array of 'port_id's.")
Signed-off-by: Christoph Jaeger <cj-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
---
 net/openvswitch/vport.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 702fb21..6d8f2ec 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -137,8 +137,10 @@ struct vport *ovs_vport_alloc(int priv_size, const struct vport_ops *ops,
 	vport->ops = ops;
 	INIT_HLIST_NODE(&vport->dp_hash_node);
 
-	if (ovs_vport_set_upcall_portids(vport, parms->upcall_portids))
+	if (ovs_vport_set_upcall_portids(vport, parms->upcall_portids)) {
+		kfree(vport);
 		return ERR_PTR(-EINVAL);
+	}
 
 	vport->percpu_stats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
 	if (!vport->percpu_stats) {
-- 
1.9.3
