From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next] vxlan: Fix vs->vni_list locking.
Date: Wed, 10 Jul 2013 15:04:44 -0700
Message-ID: <1373493884-7915-1-git-send-email-pshelar@nicira.com>
Cc: stephen@networkplumber.org, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog116.obsmtp.com ([74.125.149.240]:37123 "HELO
	na3sys009aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754906Ab3GJWEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 18:04:50 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz11so7111391pad.2
        for <netdev@vger.kernel.org>; Wed, 10 Jul 2013 15:04:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use rtnl lock to protect vs->vni_list updates.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 227b54a..deca481 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -89,7 +89,7 @@ struct vxlan_sock {
 	struct work_struct del_work;
 	atomic_t	  refcnt;
 	struct socket	  *sock;
-	struct hlist_head vni_list[VNI_HASH_SIZE];
+	struct hlist_head vni_list[VNI_HASH_SIZE]; /* Protected by RTNL. */
 };
 
 /* per-network namespace private data for this module */
@@ -122,7 +122,7 @@ struct vxlan_fdb {
 
 /* Pseudo network device */
 struct vxlan_dev {
-	struct hlist_node hlist;	/* vni hash table */
+	struct hlist_node hlist;	/* vni hash table (vni_list) */
 	struct list_head  next;		/* vxlan's per namespace list */
 	struct vxlan_sock *vn_sock;	/* listening socket */
 	struct net_device *dev;
@@ -1644,16 +1644,21 @@ static void vxlan_sock_work(struct work_struct *work)
 	if (ovs) {
 		atomic_inc(&ovs->refcnt);
 		vxlan->vn_sock = ovs;
-		hlist_add_head_rcu(&vxlan->hlist, vni_head(ovs, vni));
 		spin_unlock(&vn->sock_lock);
 
+		rtnl_lock();
+		hlist_add_head_rcu(&vxlan->hlist, vni_head(ovs, vni));
+		rtnl_unlock();
+
 		sk_release_kernel(nvs->sock->sk);
 		kfree(nvs);
 	} else {
 		vxlan->vn_sock = nvs;
 		hlist_add_head_rcu(&nvs->hlist, vs_head(net, port));
-		hlist_add_head_rcu(&vxlan->hlist, vni_head(nvs, vni));
 		spin_unlock(&vn->sock_lock);
+		rtnl_lock();
+		hlist_add_head_rcu(&vxlan->hlist, vni_head(nvs, vni));
+		rtnl_unlock();
 	}
 out:
 	dev_put(dev);
-- 
1.7.1
