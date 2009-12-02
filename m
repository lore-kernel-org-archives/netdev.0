From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] net: Teach vlans to cleanup as a pernet subsystem
Date: Wed, 02 Dec 2009 15:19:08 -0800
Message-ID: <m1d42xrmkz.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:44895 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752199AbZLBXTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 18:19:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Take advantage of the fact that an explicit rtnl_kill_links is
unnecessary (and skipping it improves batching), as network namespace
exit calls dellink on all remaining virtual devices, and
rtnl_link_unregister calls dellink on all outstanding devices in that
network namespace.  To do this we need to leave the vlan proc
directories in place until after network device exit time, which is
done by using register_pernet_subsys instead of
register_pernet_device.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 net/8021q/vlan.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 91e9073..ec37692 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -698,8 +698,6 @@ static int vlan_init_net(struct net *net)
 
 static void vlan_exit_net(struct net *net)
 {
-	rtnl_kill_links(net, &vlan_link_ops);
-
 	vlan_proc_cleanup(net);
 }
 
@@ -717,7 +715,7 @@ static int __init vlan_proto_init(void)
 	pr_info("%s v%s %s\n", vlan_fullname, vlan_version, vlan_copyright);
 	pr_info("All bugs added by %s\n", vlan_buggyright);
 
-	err = register_pernet_device(&vlan_net_ops);
+	err = register_pernet_subsys(&vlan_net_ops);
 	if (err < 0)
 		goto err0;
 
@@ -742,7 +740,7 @@ err4:
 err3:
 	unregister_netdevice_notifier(&vlan_notifier_block);
 err2:
-	unregister_pernet_device(&vlan_net_ops);
+	unregister_pernet_subsys(&vlan_net_ops);
 err0:
 	return err;
 }
@@ -762,7 +760,7 @@ static void __exit vlan_cleanup_module(void)
 	for (i = 0; i < VLAN_GRP_HASH_SIZE; i++)
 		BUG_ON(!hlist_empty(&vlan_group_hash[i]));
 
-	unregister_pernet_device(&vlan_net_ops);
+	unregister_pernet_subsys(&vlan_net_ops);
 	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 
 	vlan_gvrp_uninit();
-- 
1.6.5.2.143.g8cc62

