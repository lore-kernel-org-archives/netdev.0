From: Mark Bloch <markb@mellanox.com>
Subject: [net] vxlan: fix use-after-free on deletion
Date: Thu, 1 Jun 2017 11:43:35 +0300
Message-ID: <1496306615-770-1-git-send-email-markb@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <jbenc@redhat.com>, <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0041.outbound.protection.outlook.com ([104.47.0.41]:14368
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751563AbdFAInp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 04:43:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding a vxlan interface to a socket isn't symmetrical, while adding
is done in vxlan_open() the deletion is done in vxlan_dellink().
This can cause a use-after-free error when we close the vxlan
interface before deleting it.

We add vxlan_vs_del_dev() to match vxlan_vs_add_dev() and call
it from vxlan_stop() to match the call from vxlan_open().

Signed-off-by: Mark Bloch <markb@mellanox.com>
---
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
