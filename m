From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH 2/2] bonding: fix bonding_masters race condition in bond unloading
Date: Sat,  6 Apr 2013 12:54:38 +0200
Message-ID: <1365245678-4455-2-git-send-email-nikolay@redhat.com>
References: <1365245678-4455-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net,
	vfalico@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41644 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1163051Ab3DFK5b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Apr 2013 06:57:31 -0400
In-Reply-To: <1365245678-4455-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While the bonding module is unloading, it is considered that after
rtnl_link_unregister all bond devices are destroyed but since no
synchronization mechanism exists, a new bond device can be created
via bonding_masters before unregister_pernet_subsys which would 
lead to multiple problems (e.g. NULL pointer dereference, wrong RIP,
list corruption).

This patch fixes the issue by removing any bond devices left in the
netns after bonding_masters is removed from sysfs.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a51241b..07401a3 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4846,9 +4846,18 @@ static int __net_init bond_net_init(struct net *net)
 static void __net_exit bond_net_exit(struct net *net)
 {
 	struct bond_net *bn = net_generic(net, bond_net_id);
+	struct bonding *bond, *tmp_bond;
+	LIST_HEAD(list);
 
 	bond_destroy_sysfs(bn);
 	bond_destroy_proc_dir(bn);
+
+	/* Kill off any bonds created after unregistering bond rtnl ops */
+	rtnl_lock();
+	list_for_each_entry_safe(bond, tmp_bond, &bn->dev_list, bond_list)
+		unregister_netdevice_queue(bond->dev, &list);
+	unregister_netdevice_many(&list);
+	rtnl_unlock();
 }
 
 static struct pernet_operations bond_net_ops = {
-- 
1.8.1.4
