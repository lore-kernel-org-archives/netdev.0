From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next] bonding: destroy proc directory only after all bonds are gone
Date: Thu, 17 Jul 2014 12:04:08 +0200
Message-ID: <1405591448-31797-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34500 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754827AbaGQKIg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2014 06:08:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we might arrive to bond_net_exit() with some bonds left (that
were created while the module is unloading). We take care of that by
destroying sysfs (the last possibility to add new bonds) and then
destroying all the remaining bonds.

However, we destroy the /proc/net/bonding directory before destroying those
last bonds, and get a warning that we're trying to destroy a non-empty
proc directory (containing /proc/net/bonding/bondX).

Fix this by moving bond_destroy_proc_dir() after all the bonds are
destroyed, so that we're sure that no bonds exist.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bond_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1ff676ca..b4cee84 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4450,7 +4450,6 @@ static void __net_exit bond_net_exit(struct net *net)
 	LIST_HEAD(list);
 
 	bond_destroy_sysfs(bn);
-	bond_destroy_proc_dir(bn);
 
 	/* Kill off any bonds created after unregistering bond rtnl ops */
 	rtnl_lock();
@@ -4458,6 +4457,8 @@ static void __net_exit bond_net_exit(struct net *net)
 		unregister_netdevice_queue(bond->dev, &list);
 	unregister_netdevice_many(&list);
 	rtnl_unlock();
+
+	bond_destroy_proc_dir(bn);
 }
 
 static struct pernet_operations bond_net_ops = {
-- 
1.8.4
