From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net] openvswitch: Fix net exit.
Date: Tue, 17 Feb 2015 11:23:10 -0800
Message-ID: <1424200990-1558-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org, amuller@redhat.com,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog109.obsmtp.com ([74.125.149.201]:38621 "HELO
	na3sys009aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753114AbbBQTXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 14:23:36 -0500
Received: by mail-pd0-f173.google.com with SMTP id v10so45731847pde.7
        for <netdev@vger.kernel.org>; Tue, 17 Feb 2015 11:23:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Open vSwitch allows moving internal vport to different namespace
while still connected to the bridge. But when namespace deleted
OVS does not detach these vports, that results in dangling
pointer to netdevice which causes kernel panic as follows.
This issue is fixed by detaching all ovs ports from the deleted
namespace at net-exit.

BUG: unable to handle kernel NULL pointer dereference at 0000000000000028
IP: [<ffffffffa0aadaa5>] ovs_vport_locate+0x35/0x80 [openvswitch]
Oops: 0000 [#1] SMP
Call Trace:
 [<ffffffffa0aa6391>] lookup_vport+0x21/0xd0 [openvswitch]
 [<ffffffffa0aa65f9>] ovs_vport_cmd_get+0x59/0xf0 [openvswitch]
 [<ffffffff8167e07c>] genl_family_rcv_msg+0x1bc/0x3e0
 [<ffffffff8167e319>] genl_rcv_msg+0x79/0xc0
 [<ffffffff8167d919>] netlink_rcv_skb+0xb9/0xe0
 [<ffffffff8167deac>] genl_rcv+0x2c/0x40
 [<ffffffff8167cffd>] netlink_unicast+0x12d/0x1c0
 [<ffffffff8167d3da>] netlink_sendmsg+0x34a/0x6b0
 [<ffffffff8162e140>] sock_sendmsg+0xa0/0xe0
 [<ffffffff8162e5e8>] ___sys_sendmsg+0x408/0x420
 [<ffffffff8162f541>] __sys_sendmsg+0x51/0x90
 [<ffffffff8162f592>] SyS_sendmsg+0x12/0x20
 [<ffffffff81764ee9>] system_call_fastpath+0x12/0x17

Reported-by: Assaf Muller <amuller@redhat.com>
Fixes: 46df7b81454("openvswitch: Add support for network namespaces.")
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/datapath.c |   45 ++++++++++++++++++++++++++++++++++++++++++-
 net/openvswitch/vport.h    |    2 +
 2 files changed, 45 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index ae5e77c..5bae724 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -2194,14 +2194,55 @@ static int __net_init ovs_init_net(struct net *net)
 	return 0;
 }
 
-static void __net_exit ovs_exit_net(struct net *net)
+static void __net_exit list_vports_from_net(struct net *net, struct net *dnet,
+					    struct list_head *head)
 {
-	struct datapath *dp, *dp_next;
 	struct ovs_net *ovs_net = net_generic(net, ovs_net_id);
+	struct datapath *dp;
+
+	list_for_each_entry(dp, &ovs_net->dps, list_node) {
+		int i;
+
+		for (i = 0; i < DP_VPORT_HASH_BUCKETS; i++) {
+			struct vport *vport;
+
+			hlist_for_each_entry(vport, &dp->ports[i], dp_hash_node) {
+				struct netdev_vport *netdev_vport;
+
+				if (vport->ops->type != OVS_VPORT_TYPE_INTERNAL)
+					continue;
+
+				netdev_vport = netdev_vport_priv(vport);
+				if (dev_net(netdev_vport->dev) == dnet)
+					list_add(&vport->detach_list, head);
+			}
+		}
+	}
+}
+
+static void __net_exit ovs_exit_net(struct net *dnet)
+{
+	struct datapath *dp, *dp_next;
+	struct ovs_net *ovs_net = net_generic(dnet, ovs_net_id);
+	struct vport *vport, *vport_next;
+	struct net *net;
+	LIST_HEAD(head);
 
 	ovs_lock();
 	list_for_each_entry_safe(dp, dp_next, &ovs_net->dps, list_node)
 		__dp_destroy(dp);
+
+	rtnl_lock();
+	for_each_net(net)
+		list_vports_from_net(net, dnet, &head);
+	rtnl_unlock();
+
+	/* Detach all vports from given namespace. */
+	list_for_each_entry_safe(vport, vport_next, &head, detach_list) {
+		list_del(&vport->detach_list);
+		ovs_dp_detach_port(vport);
+	}
+
 	ovs_unlock();
 
 	cancel_work_sync(&ovs_net->dp_notify_work);
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index f8ae295..bc85331 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -103,6 +103,7 @@ struct vport_portids {
  * @ops: Class structure.
  * @percpu_stats: Points to per-CPU statistics used and maintained by vport
  * @err_stats: Points to error statistics used and maintained by vport
+ * @detach_list: list used for detaching vport in net-exit call.
  */
 struct vport {
 	struct rcu_head rcu;
@@ -117,6 +118,7 @@ struct vport {
 	struct pcpu_sw_netstats __percpu *percpu_stats;
 
 	struct vport_err_stats err_stats;
+	struct list_head detach_list;
 };
 
 /**
-- 
1.7.1
