From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: vxlan: convert to act as a pernet subsystem
Date: Wed, 22 Jan 2014 21:07:53 +0100
Message-ID: <1390421273-20152-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12701 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752852AbaAVUH7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 15:07:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As per suggestion from Eric W. Biederman, vxlan should be using
{un,}register_pernet_subsys() instead of {un,}register_pernet_device()
to ensure the vxlan_net structure is initialized before and cleaned
up after all network devices in a given network namespace i.e. when
dealing with network notifiers. This is similarly handeled already in
commit 91e2ff3528ac ("net: Teach vlans to cleanup as a pernet subsystem")
and, thus, improves upon fd27e0d44a89 ("net: vxlan: do not use vxlan_net
before checking event type"). Just as in 91e2ff3528ac, we do not need
to explicitly handle deletion of vxlan devices as network namespace
exit calls dellink on all remaining virtual devices, and
rtnl_link_unregister() calls dellink on all outstanding devices in that
network namespace, so we can entirely drop the pernet exit operation
as well. Moreover, on vxlan module exit, rcu_barrier() is called by
netns since commit 3a765edadb28 ("netns: Add an explicit rcu_barrier
to unregister_pernet_{device|subsys}"), so this may be omitted. Tested
with various scenarios and works well on my side.

Suggested-by: Eric W. Biederman <ebiederm@xmission.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 drivers/net/vxlan.c | 28 ++++++----------------------
 1 file changed, 6 insertions(+), 22 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 942acc2..e1bc925 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2784,12 +2784,10 @@ static int vxlan_lowerdev_event(struct notifier_block *unused,
 				unsigned long event, void *ptr)
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
-	struct vxlan_net *vn;
+	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
 
-	if (event == NETDEV_UNREGISTER) {
-		vn = net_generic(dev_net(dev), vxlan_net_id);
+	if (event == NETDEV_UNREGISTER)
 		vxlan_handle_lowerdev_unregister(vn, dev);
-	}
 
 	return NOTIFY_DONE;
 }
@@ -2812,22 +2810,8 @@ static __net_init int vxlan_init_net(struct net *net)
 	return 0;
 }
 
-static __net_exit void vxlan_exit_net(struct net *net)
-{
-	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
-	struct vxlan_dev *vxlan, *next;
-	LIST_HEAD(list_kill);
-
-	rtnl_lock();
-	list_for_each_entry_safe(vxlan, next, &vn->vxlan_list, next)
-		vxlan_dellink(vxlan->dev, &list_kill);
-	unregister_netdevice_many(&list_kill);
-	rtnl_unlock();
-}
-
 static struct pernet_operations vxlan_net_ops = {
 	.init = vxlan_init_net,
-	.exit = vxlan_exit_net,
 	.id   = &vxlan_net_id,
 	.size = sizeof(struct vxlan_net),
 };
@@ -2842,7 +2826,7 @@ static int __init vxlan_init_module(void)
 
 	get_random_bytes(&vxlan_salt, sizeof(vxlan_salt));
 
-	rc = register_pernet_device(&vxlan_net_ops);
+	rc = register_pernet_subsys(&vxlan_net_ops);
 	if (rc)
 		goto out1;
 
@@ -2858,7 +2842,7 @@ static int __init vxlan_init_module(void)
 out3:
 	unregister_netdevice_notifier(&vxlan_notifier_block);
 out2:
-	unregister_pernet_device(&vxlan_net_ops);
+	unregister_pernet_subsys(&vxlan_net_ops);
 out1:
 	destroy_workqueue(vxlan_wq);
 	return rc;
@@ -2870,8 +2854,8 @@ static void __exit vxlan_cleanup_module(void)
 	rtnl_link_unregister(&vxlan_link_ops);
 	unregister_netdevice_notifier(&vxlan_notifier_block);
 	destroy_workqueue(vxlan_wq);
-	unregister_pernet_device(&vxlan_net_ops);
-	rcu_barrier();
+	unregister_pernet_subsys(&vxlan_net_ops);
+	/* rcu_barrier() is called by netns */
 }
 module_exit(vxlan_cleanup_module);
 
-- 
1.7.11.7
