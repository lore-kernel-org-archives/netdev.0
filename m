From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 3/6] bond: Simplify bond_create.
Date: Thu, 29 Oct 2009 17:18:23 -0700
Message-ID: <1256861906-5059-3-git-send-email-ebiederm@xmission.com>
References: <m1tyxhwxah.fsf@fess.ebiederm.org>
Cc: <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:56327 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755586AbZJ3ASl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 20:18:41 -0400
In-Reply-To: <m1tyxhwxah.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@aristanetworks.com>

Stop calling dev_get_by_name to see if the bond device already
exists.  register_netdevice already does that.

Stop calling bond_deinit if register_netdevice fails as bond_uninit
is guaranteed to be called if bond_init succeeds.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/bonding/bond_main.c |   22 ++++------------------
 1 files changed, 4 insertions(+), 18 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f73d2de..3ce31e7 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -5089,14 +5089,6 @@ int bond_create(const char *name)
 	int res;
 
 	rtnl_lock();
-	/* Check to see if the bond already exists. */
-	/* FIXME: pass netns from caller */
-	if (name && __dev_get_by_name(&init_net, name)) {
-		pr_err(DRV_NAME ": cannot add bond %s; already exists\n",
-		       name);
-		res = -EEXIST;
-		goto out_rtnl;
-	}
 
 	bond_dev = alloc_netdev(sizeof(struct bonding), name ? name : "",
 				bond_setup);
@@ -5104,7 +5096,7 @@ int bond_create(const char *name)
 		pr_err(DRV_NAME ": %s: eek! can't alloc netdev!\n",
 		       name);
 		res = -ENOMEM;
-		goto out_rtnl;
+		goto out;
 	}
 
 	if (!name) {
@@ -5114,19 +5106,13 @@ int bond_create(const char *name)
 	}
 
 	res = register_netdevice(bond_dev);
-	if (res < 0)
-		goto out_bond;
 
+out:
 	rtnl_unlock();
-	return 0;
-
-out_bond:
-	bond_deinit(bond_dev);
+	return res;
 out_netdev:
 	free_netdev(bond_dev);
-out_rtnl:
-	rtnl_unlock();
-	return res;
+	goto out;
 }
 
 static int __init bonding_init(void)
-- 
1.6.3.1.54.g99dd.dirty

