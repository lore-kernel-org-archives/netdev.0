From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] openvswitch: fix hangup on vxlan/gre/geneve device deletion
Date: Tue,  1 Dec 2015 18:33:36 +0100
Message-ID: <d3c53f79dfaacd71bebf97427388d60dc5652eae.1448989843.git.pabeni@redhat.com>
Cc: Pravin B Shelar <pshelar@nicira.com>, Thomas Graf <tgraf@suug.ch>,
	dev@openvswitch.org, fbl@sysclose.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36390 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751894AbbLAReA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2015 12:34:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each openvswitch tunnel vport (vxlan,gre,geneve) holds a reference
to the underlying tunnel device, but never released it when such
device is deleted.
Deleting the underlying device via the ip tool cause the kernel to
hangup in the netdev_wait_allrefs() loop.
This commit ensure that on device unregistration dp_detach_port_notify()
is called for all vports that hold the device reference, properly
releasing it.

Fixes: 614732eaa12d ("openvswitch: Use regular VXLAN net_device device")
Fixes: b2acd1dc3949 ("openvswitch: Use regular GRE net_device instead of vport")
Fixes: 6b001e682e90 ("openvswitch: Use Geneve device.")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/openvswitch/dp_notify.c    | 2 +-
 net/openvswitch/vport-netdev.c | 8 ++++++--
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/dp_notify.c b/net/openvswitch/dp_notify.c
index a7a80a6..653d073 100644
--- a/net/openvswitch/dp_notify.c
+++ b/net/openvswitch/dp_notify.c
@@ -58,7 +58,7 @@ void ovs_dp_notify_wq(struct work_struct *work)
 			struct hlist_node *n;
 
 			hlist_for_each_entry_safe(vport, n, &dp->ports[i], dp_hash_node) {
-				if (vport->ops->type != OVS_VPORT_TYPE_NETDEV)
+				if (vport->ops->type == OVS_VPORT_TYPE_INTERNAL)
 					continue;
 
 				if (!(vport->dev->priv_flags & IFF_OVS_DATAPATH))
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index b327368..6b0190b 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -180,9 +180,13 @@ void ovs_netdev_tunnel_destroy(struct vport *vport)
 	if (vport->dev->priv_flags & IFF_OVS_DATAPATH)
 		ovs_netdev_detach_dev(vport);
 
-	/* Early release so we can unregister the device */
+	/* We can be invoked by both explicit vport deletion and
+	 * underlying netdev deregistration; delete the link only
+	 * if it's not already shutting down.
+	 */
+	if (vport->dev->reg_state == NETREG_REGISTERED)
+		rtnl_delete_link(vport->dev);
 	dev_put(vport->dev);
-	rtnl_delete_link(vport->dev);
 	vport->dev = NULL;
 	rtnl_unlock();
 
-- 
1.8.3.1
