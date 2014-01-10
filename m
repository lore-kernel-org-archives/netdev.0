From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH v3 net-next] net: vxlan: when lower dev unregisters remove vxlan dev as well
Date: Fri, 10 Jan 2014 23:35:17 +0100
Message-ID: <1389393317-26563-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3682 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758298AbaAJWfW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 17:35:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can create a vxlan device with an explicit underlying carrier.
In that case, when the carrier link is being deleted from the
system (e.g. due to module unload) we should also clean up all
created vxlan devices on top of it since otherwise we're in an
inconsistent state in vxlan device. In that case, the user needs
to remove all such devices, while in case of other virtual devs
that sit on top of physical ones, it is usually the case that
these devices do unregister automatically as well and do not
leave the burden on the user.

This work is not necessary when vxlan device was not created with
a real underlying device, as connections can resume in that case
when driver is plugged again. But at least for the other cases,
we should go ahead and do the cleanup on removal.

We don't register the notifier during vxlan_newlink() here since
I consider this event rather rare, and therefore we should not
bloat vxlan's core structure unecessary. Also, we can simply make
use of unregister_netdevice_many() to batch that.

E.g. `ip -d link show vxlan13` after carrier removal before
this patch:

5: vxlan13: <BROADCAST,MULTICAST> mtu 1450 qdisc noop state DOWN mode DEFAULT group default
    link/ether 1e:47:da:6d:4d:99 brd ff:ff:ff:ff:ff:ff promiscuity 0
    vxlan id 13 group 239.0.0.10 dev 2 port 32768 61000 ageing 300
                                 ^^^^^
While at it, we should also use vxlan_dellink() handler in
vxlan_exit_net(), since i) we're not in hurry and we should better
be consistent, ii) in case future code will kfree() things in
vxlan_dellink(), we would leak it right here unnoticed. Therfore,
do not only half of the cleanup work, but make it properly.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 v1->v2:
  - Removed BUG_ON as it's not needed.
 v2->v3:
  - Removed dev->reg_state check.

 drivers/net/vxlan.c | 60 ++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 53 insertions(+), 7 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 481f85d..7255527 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2656,6 +2656,45 @@ static struct rtnl_link_ops vxlan_link_ops __read_mostly = {
 	.fill_info	= vxlan_fill_info,
 };
 
+static void vxlan_handle_lowerdev_unregister(struct vxlan_net *vn,
+					     struct net_device *dev)
+{
+	struct vxlan_dev *vxlan, *next;
+	LIST_HEAD(list_kill);
+
+	list_for_each_entry_safe(vxlan, next, &vn->vxlan_list, next) {
+		struct vxlan_rdst *dst = &vxlan->default_dst;
+
+		/* In case we created vxlan device with carrier
+		 * and we loose the carrier due to module unload
+		 * we also need to remove vxlan device. In other
+		 * cases, it's not necessary and remote_ifindex
+		 * is 0 here, so no matches.
+		 */
+		if (dst->remote_ifindex == dev->ifindex)
+			vxlan_dellink(vxlan->dev, &list_kill);
+	}
+
+	unregister_netdevice_many(&list_kill);
+	list_del(&list_kill);
+}
+
+static int vxlan_lowerdev_event(struct notifier_block *unused,
+				unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
+
+	if (event == NETDEV_UNREGISTER)
+		vxlan_handle_lowerdev_unregister(vn, dev);
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block vxlan_notifier_block __read_mostly = {
+	.notifier_call = vxlan_lowerdev_event,
+};
+
 static __net_init int vxlan_init_net(struct net *net)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
@@ -2673,13 +2712,14 @@ static __net_init int vxlan_init_net(struct net *net)
 static __net_exit void vxlan_exit_net(struct net *net)
 {
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
-	struct vxlan_dev *vxlan;
-	LIST_HEAD(list);
+	struct vxlan_dev *vxlan, *next;
+	LIST_HEAD(list_kill);
 
 	rtnl_lock();
-	list_for_each_entry(vxlan, &vn->vxlan_list, next)
-		unregister_netdevice_queue(vxlan->dev, &list);
-	unregister_netdevice_many(&list);
+	list_for_each_entry_safe(vxlan, next, &vn->vxlan_list, next)
+		vxlan_dellink(vxlan->dev, &list_kill);
+	unregister_netdevice_many(&list_kill);
+	list_del(&list_kill);
 	rtnl_unlock();
 }
 
@@ -2704,12 +2744,17 @@ static int __init vxlan_init_module(void)
 	if (rc)
 		goto out1;
 
-	rc = rtnl_link_register(&vxlan_link_ops);
+	rc = register_netdevice_notifier(&vxlan_notifier_block);
 	if (rc)
 		goto out2;
 
-	return 0;
+	rc = rtnl_link_register(&vxlan_link_ops);
+	if (rc)
+		goto out3;
 
+	return 0;
+out3:
+	unregister_netdevice_notifier(&vxlan_notifier_block);
 out2:
 	unregister_pernet_device(&vxlan_net_ops);
 out1:
@@ -2721,6 +2766,7 @@ late_initcall(vxlan_init_module);
 static void __exit vxlan_cleanup_module(void)
 {
 	rtnl_link_unregister(&vxlan_link_ops);
+	unregister_netdevice_notifier(&vxlan_notifier_block);
 	destroy_workqueue(vxlan_wq);
 	unregister_pernet_device(&vxlan_net_ops);
 	rcu_barrier();
-- 
1.7.11.7
