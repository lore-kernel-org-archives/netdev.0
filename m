From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] vxlan: do not use vxlan_net before checking event type
Date: Thu, 16 Jan 2014 20:20:10 -0800
Message-ID: <1389932410-21080-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:58440 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194AbaAQEUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 23:20:37 -0500
Received: by mail-pa0-f51.google.com with SMTP id ld10so1272251pab.24
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 20:20:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When cloning a netns, loopback device will be registered
and therefore an event will be notified. Of course
vxlan doesn't care about it, therefore should check if it
is NETDEV_UNREGISTER before getting the vxlan_net struct.
Otherwise, vxlan_net is probably not initialized yet at
this point.

Fixes: commit acaf4e70997ff5ef3588f5a 
Reported-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index a2dee80..2812559 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2655,36 +2655,30 @@ static struct rtnl_link_ops vxlan_link_ops __read_mostly = {
 	.fill_info	= vxlan_fill_info,
 };
 
-static void vxlan_handle_lowerdev_unregister(struct vxlan_net *vn,
-					     struct net_device *dev)
-{
-	struct vxlan_dev *vxlan, *next;
-	LIST_HEAD(list_kill);
-
-	list_for_each_entry_safe(vxlan, next, &vn->vxlan_list, next) {
-		struct vxlan_rdst *dst = &vxlan->default_dst;
-
-		/* In case we created vxlan device with carrier
-		 * and we loose the carrier due to module unload
-		 * we also need to remove vxlan device. In other
-		 * cases, it's not necessary and remote_ifindex
-		 * is 0 here, so no matches.
-		 */
-		if (dst->remote_ifindex == dev->ifindex)
-			vxlan_dellink(vxlan->dev, &list_kill);
-	}
-
-	unregister_netdevice_many(&list_kill);
-}
-
 static int vxlan_lowerdev_event(struct notifier_block *unused,
 				unsigned long event, void *ptr)
 {
-	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
-	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
+	if (event == NETDEV_UNREGISTER) {
+		struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+		struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
+		struct vxlan_dev *vxlan, *next;
+		LIST_HEAD(list_kill);
+
+		list_for_each_entry_safe(vxlan, next, &vn->vxlan_list, next) {
+			struct vxlan_rdst *dst = &vxlan->default_dst;
+
+			/* In case we created vxlan device with carrier
+			 * and we loose the carrier due to module unload
+			 * we also need to remove vxlan device. In other
+			 * cases, it's not necessary and remote_ifindex
+			 * is 0 here, so no matches.
+			 */
+			if (dst->remote_ifindex == dev->ifindex)
+				vxlan_dellink(vxlan->dev, &list_kill);
+		}
 
-	if (event == NETDEV_UNREGISTER)
-		vxlan_handle_lowerdev_unregister(vn, dev);
+		unregister_netdevice_many(&list_kill);
+	}
 
 	return NOTIFY_DONE;
 }
