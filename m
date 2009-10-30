From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 5/6] bond: Implement a basic set of rtnl link ops
Date: Thu, 29 Oct 2009 17:18:25 -0700
Message-ID: <1256861906-5059-5-git-send-email-ebiederm@xmission.com>
References: <m1tyxhwxah.fsf@fess.ebiederm.org>
Cc: <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:35839 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755846AbZJ3ASn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 20:18:43 -0400
In-Reply-To: <m1tyxhwxah.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@aristanetworks.com>

This implements a basic set of rtnl link ops and takes advantage of
the fact that rtnl_link_unregister kills all of the surviving
devices to all us to kill bond_free_all.  A module alias
is added so ip link add can pull in the bonding module.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/bonding/bond_main.c |   55 +++++++++++++++++++++-----------------
 1 files changed, 30 insertions(+), 25 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7a37ecf..6da2a82 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4612,22 +4612,6 @@ static void bond_uninit(struct net_device *bond_dev)
 	netif_addr_unlock_bh(bond_dev);
 }
 
-/* Unregister and free all bond devices.
- * Caller must hold rtnl_lock.
- */
-static void bond_free_all(void)
-{
-	struct bonding *bond, *nxt;
-
-	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list) {
-		struct net_device *bond_dev = bond->dev;
-
-		unregister_netdevice(bond_dev);
-	}
-
-	bond_destroy_proc_dir();
-}
-
 /*------------------------- Module initialization ---------------------------*/
 
 /*
@@ -5065,6 +5049,23 @@ static int bond_init(struct net_device *bond_dev)
 	return 0;
 }
 
+static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
+{
+	if (tb[IFLA_ADDRESS]) {
+		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
+			return -EINVAL;
+		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
+			return -EADDRNOTAVAIL;
+	}
+	return 0;
+}
+
+static struct rtnl_link_ops bond_link_ops __read_mostly = {
+	.kind		= "bond",
+	.setup		= bond_setup,
+	.validate	= bond_validate,
+};
+
 /* Create a new bond based on the specified name and bonding parameters.
  * If name is NULL, obtain a suitable "bond%d" name for us.
  * Caller must NOT hold rtnl_lock; we need to release it here before we
@@ -5086,6 +5087,8 @@ int bond_create(const char *name)
 		goto out;
 	}
 
+	bond_dev->rtnl_link_ops = &bond_link_ops;
+
 	if (!name) {
 		res = dev_alloc_name(bond_dev, "bond%d");
 		if (res < 0)
@@ -5115,6 +5118,10 @@ static int __init bonding_init(void)
 
 	bond_create_proc_dir();
 
+	res = rtnl_link_register(&bond_link_ops);
+	if (res)
+		goto err;
+
 	for (i = 0; i < max_bonds; i++) {
 		res = bond_create(NULL);
 		if (res)
@@ -5128,14 +5135,12 @@ static int __init bonding_init(void)
 	register_netdevice_notifier(&bond_netdev_notifier);
 	register_inetaddr_notifier(&bond_inetaddr_notifier);
 	bond_register_ipv6_notifier();
-
-	goto out;
-err:
-	rtnl_lock();
-	bond_free_all();
-	rtnl_unlock();
 out:
 	return res;
+err:
+	rtnl_link_unregister(&bond_link_ops);
+	bond_destroy_proc_dir();
+	goto out;
 
 }
 
@@ -5147,9 +5152,8 @@ static void __exit bonding_exit(void)
 
 	bond_destroy_sysfs();
 
-	rtnl_lock();
-	bond_free_all();
-	rtnl_unlock();
+	rtnl_link_unregister(&bond_link_ops);
+	bond_destroy_proc_dir();
 }
 
 module_init(bonding_init);
@@ -5158,3 +5162,4 @@ MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 MODULE_DESCRIPTION(DRV_DESCRIPTION ", v" DRV_VERSION);
 MODULE_AUTHOR("Thomas Davis, tadavis@lbl.gov and many others");
+MODULE_ALIAS_RTNL_LINK("bond");
-- 
1.6.3.1.54.g99dd.dirty

