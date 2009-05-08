From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] bonding: fix panic if initialization fails
Date: Fri,  8 May 2009 23:49:11 +0200
Message-ID: <1241819351-26356-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:39965 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752136AbZEHVqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 17:46:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If module initialisation failed (e.g. because the bonding sysfs entry
cannot be created), kernel panics:
 IP: [<ffffffff8024910a>] destroy_workqueue+0x2d/0x146
Call Trace:
 [<ffffffff808268c4>] bond_destructor+0x28/0x78
 [<ffffffff80b64471>] netdev_run_todo+0x231/0x25a
 [<ffffffff80b6dbcd>] rtnl_unlock+0x9/0xb
 [<ffffffff81567907>] bonding_init+0x83e/0x84a

Remove the calls to bond_work_cancel_all() and destroy_workqueue();
both are also called/scheduled via bond_free_all().

bond_destroy_sysfs is unecessary because the sysfs entry has
not been created in the error case.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/bonding/bond_main.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 815191d..56830a4 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -5199,7 +5199,6 @@ static int __init bonding_init(void)
 {
 	int i;
 	int res;
-	struct bonding *bond;
 
 	printk(KERN_INFO "%s", version);
 
@@ -5228,13 +5227,6 @@ static int __init bonding_init(void)
 
 	goto out;
 err:
-	list_for_each_entry(bond, &bond_dev_list, bond_list) {
-		bond_work_cancel_all(bond);
-		destroy_workqueue(bond->wq);
-	}
-
-	bond_destroy_sysfs();
-
 	rtnl_lock();
 	bond_free_all();
 	rtnl_unlock();
-- 
1.6.0.6

