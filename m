From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 3/7] bonding: fix NULL pointer deref in startup processing
Date: Tue, 29 Jan 2008 18:07:45 -0800
Message-ID: <12016588712034-git-send-email-fubar@us.ibm.com>
References: <12016588691476-git-send-email-fubar@us.ibm.com>
 <12016588701127-git-send-email-fubar@us.ibm.com>
 <12016588714065-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:32835 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753236AbYA3CH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 21:07:58 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0U14Rxg023834
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 20:04:27 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0U27qZR150900
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 19:07:52 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0U27qO6015833
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 19:07:52 -0700
In-Reply-To: <12016588714065-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Fix the "are we creating a duplicate" check to not compare
the name if the name is NULL (meaning that the system should select
a name).  Bug reported by Benny Amorsen <benny+usenet@amorsen.dk>.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 591b8b4..63866da 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4896,14 +4896,16 @@ int bond_create(char *name, struct bond_params *params, struct bonding **newbond
 	down_write(&bonding_rwsem);
 
 	/* Check to see if the bond already exists. */
-	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list)
-		if (strnicmp(bond->dev->name, name, IFNAMSIZ) == 0) {
-			printk(KERN_ERR DRV_NAME
+	if (name) {
+		list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list)
+			if (strnicmp(bond->dev->name, name, IFNAMSIZ) == 0) {
+				printk(KERN_ERR DRV_NAME
 			       ": cannot add bond %s; it already exists\n",
-			       name);
-			res = -EPERM;
-			goto out_rtnl;
-		}
+				       name);
+				res = -EPERM;
+				goto out_rtnl;
+			}
+	}
 
 	bond_dev = alloc_netdev(sizeof(struct bonding), name ? name : "",
 				ether_setup);
-- 
1.5.3.4.206.g58ba4-dirty

