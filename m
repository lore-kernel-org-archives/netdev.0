From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH 15/21] datapath: Remove mlink element from
	tnl_mutable_config
Date: Thu, 24 May 2012 18:09:08 +0900
Message-ID: <1337850554-10339-16-git-send-email-horms@verge.net.au>
References: <1337850554-10339-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1337850554-10339-1-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
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

Multicast may be handled in user-space (but isn't yet).

Cc: Kyle Mestery <kmestery-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
---
 datapath/tunnel.c | 22 ----------------------
 datapath/tunnel.h |  3 ---
 2 files changed, 25 deletions(-)

diff --git a/datapath/tunnel.c b/datapath/tunnel.c
index f07ec69..cdcb0a7 100644
--- a/datapath/tunnel.c
+++ b/datapath/tunnel.c
@@ -162,21 +162,6 @@ static void free_cache_rcu(struct rcu_head *rcu)
 	free_cache(c);
 }
 
-/* Frees the portion of 'mutable' that requires RTNL and thus can't happen
- * within an RCU callback.  Fortunately this part doesn't require waiting for
- * an RCU grace period.
- */
-static void free_mutable_rtnl(struct tnl_mutable_config *mutable)
-{
-	ASSERT_RTNL();
-	if (ipv4_is_multicast(mutable->key.daddr) && mutable->mlink) {
-		struct in_device *in_dev;
-		in_dev = inetdev_by_index(port_key_get_net(&mutable->key), mutable->mlink);
-		if (in_dev)
-			ip_mc_dec_group(in_dev, mutable->key.daddr);
-	}
-}
-
 static void assign_config_rcu(struct vport *vport,
 			      struct tnl_mutable_config *new_config)
 {
@@ -186,7 +171,6 @@ static void assign_config_rcu(struct vport *vport,
 	old_config = rtnl_dereference(tnl_vport->mutable);
 	rcu_assign_pointer(tnl_vport->mutable, new_config);
 
-	free_mutable_rtnl(old_config);
 	call_rcu(&old_config->rcu, free_config_rcu);
 }
 
@@ -1391,8 +1375,6 @@ static int tnl_set_config(struct net *net,
 	if (old_vport && old_vport != cur_vport)
 		return -EEXIST;
 
-	mutable->mlink = 0;
-
 	return 0;
 }
 
@@ -1445,7 +1427,6 @@ struct vport *ovs_tnl_create(const struct vport_parms *parms,
 	return vport;
 
 error_free_mutable:
-	free_mutable_rtnl(mutable);
 	kfree(mutable);
 error_free_vport:
 	ovs_vport_free(vport);
@@ -1470,7 +1451,6 @@ void ovs_tnl_destroy(struct vport *vport)
 
 	mutable = rtnl_dereference(tnl_vport->mutable);
 	port_table_remove_port(vport);
-	free_mutable_rtnl(mutable);
 	call_rcu(&tnl_vport->rcu, free_port_rcu);
 }
 
@@ -1484,8 +1464,6 @@ int ovs_tnl_set_addr(struct vport *vport, const unsigned char *addr)
 	if (!mutable)
 		return -ENOMEM;
 
-	old_mutable->mlink = 0;
-
 	memcpy(mutable->eth_addr, addr, ETH_ALEN);
 	assign_config_rcu(vport, mutable);
 
diff --git a/datapath/tunnel.h b/datapath/tunnel.h
index 7d78297..0af27ac 100644
--- a/datapath/tunnel.h
+++ b/datapath/tunnel.h
@@ -117,9 +117,6 @@ struct tnl_mutable_config {
 	u32	flags;
 	u8	tos;
 	u8	ttl;
-
-	/* Multicast configuration. */
-	int	mlink;
 };
 
 struct tnl_ops {
-- 
1.7.10.2.484.gcd07cc5
