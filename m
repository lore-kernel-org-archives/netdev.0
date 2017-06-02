From: Mark Bloch <markb@mellanox.com>
Subject: [net,V2] vxlan: fix use-after-free on deletion
Date: Fri,  2 Jun 2017 03:24:08 +0300
Message-ID: <1496363048-21138-1-git-send-email-markb@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: jbenc@redhat.com, roid@mellanox.com, roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0047.outbound.protection.outlook.com ([104.47.2.47]:58464
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751130AbdFBAYT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 20:24:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding a vxlan interface to a socket isn't symmetrical, while adding
is done in vxlan_open() the deletion is done in vxlan_dellink().
This can cause a use-after-free error when we close the vxlan
interface before deleting it.

We add vxlan_vs_del_dev() to match vxlan_vs_add_dev() and call
it from vxlan_stop() to match the call from vxlan_open().

Fixes: 56ef9c909b40 ("vxlan: Move socket initialization to within rtnl scope")
Acked-by: Jiri Benc <jbenc@redhat.com>
Tested-by: Roi Dayan <roid@mellanox.com>
Signed-off-by: Mark Bloch <markb@mellanox.com>
---
V2: Added a Fixes tag.
    Added Acked-by and Tested-by from Jiri and Roi.

 drivers/net/vxlan.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 328b471..f6a4310 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -59,6 +59,8 @@
 
 static int vxlan_sock_add(struct vxlan_dev *vxlan);
 
+static void vxlan_vs_del_dev(struct vxlan_dev *vxlan);
+
 /* per-network namespace private data for this module */
 struct vxlan_net {
 	struct list_head  vxlan_list;
@@ -1067,6 +1069,8 @@ static void vxlan_sock_release(struct vxlan_dev *vxlan)
 	rcu_assign_pointer(vxlan->vn4_sock, NULL);
 	synchronize_net();
 
+	vxlan_vs_del_dev(vxlan);
+
 	if (__vxlan_sock_release_prep(sock4)) {
 		udp_tunnel_sock_release(sock4->sock);
 		kfree(sock4);
@@ -2342,6 +2346,15 @@ static void vxlan_cleanup(unsigned long arg)
 	mod_timer(&vxlan->age_timer, next_timer);
 }
 
+static void vxlan_vs_del_dev(struct vxlan_dev *vxlan)
+{
+	struct vxlan_net *vn = net_generic(vxlan->net, vxlan_net_id);
+
+	spin_lock(&vn->sock_lock);
+	hlist_del_init_rcu(&vxlan->hlist);
+	spin_unlock(&vn->sock_lock);
+}
+
 static void vxlan_vs_add_dev(struct vxlan_sock *vs, struct vxlan_dev *vxlan)
 {
 	struct vxlan_net *vn = net_generic(vxlan->net, vxlan_net_id);
@@ -3286,15 +3299,9 @@ static int vxlan_changelink(struct net_device *dev, struct nlattr *tb[],
 static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct vxlan_net *vn = net_generic(vxlan->net, vxlan_net_id);
 
 	vxlan_flush(vxlan, true);
 
-	spin_lock(&vn->sock_lock);
-	if (!hlist_unhashed(&vxlan->hlist))
-		hlist_del_rcu(&vxlan->hlist);
-	spin_unlock(&vn->sock_lock);
-
 	gro_cells_destroy(&vxlan->gro_cells);
 	list_del(&vxlan->next);
 	unregister_netdevice_queue(dev, head);
-- 
1.8.4.3
